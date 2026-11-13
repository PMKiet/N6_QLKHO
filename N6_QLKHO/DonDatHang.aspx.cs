using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

namespace N6_QLKHO
{
    public partial class DonDatHang : System.Web.UI.Page
    {
        protected string ChiTietJson { get; set; } = "{}";
        protected string GiaHangJson { get; set; } = "{}";

        private class DongHang
        {
            public string MaHang;
            public int SoLuong;
            public decimal DonGia;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            TaiGiaHangHoa(); // luôn chạy để JS có bảng giá sau mỗi lần postback

            if (!IsPostBack)
            {
                LoadDanhSachHangHoa();
                LoadDanhSachDonHang();
            }
        }

        // =====================================================================
        //  THÔNG BÁO (dùng chung cho thêm / sửa / xóa / lỗi)
        //  - Server gọi ThongBao(...) -> sinh script gọi hienThongBao() bên JS
        //  - JS hiển thị toast, tự ẩn sau 4 giây, có nút X để tắt thủ công
        // =====================================================================
        private static string DuaVaoJs(string json)
        {
            // tránh chuỗi "</script>" trong dữ liệu làm vỡ thẻ script
            return json.Replace("<", "\\u003c").Replace(">", "\\u003e");
        }

        private void ThongBao(string noiDung, bool thanhCong)
        {
            string json = DuaVaoJs(new JavaScriptSerializer().Serialize(noiDung));
            string js = "window.addEventListener('load',function(){hienThongBao(" + json + "," + (thanhCong ? "true" : "false") + ");});";

            // key khác nhau mỗi lần để nhiều thông báo không đè nhau
            ClientScript.RegisterStartupScript(this.GetType(), "TB_" + Guid.NewGuid().ToString("N"), js, true);
        }

        // Đổi lỗi SQL kỹ thuật thành câu dễ hiểu
        private static string LoiThanThien(Exception ex)
        {
            SqlException sqlEx = ex as SqlException;
            if (sqlEx != null)
            {
                if (sqlEx.Number == 547)
                    return "Không thể thực hiện vì đơn hàng đang được dùng ở dữ liệu khác (ví dụ phiếu xuất kho).";
                if (sqlEx.Number == 2627 || sqlEx.Number == 2601)
                    return "Dữ liệu bị trùng (mã đơn hoặc hàng hóa đã tồn tại).";
            }
            return ex.Message;
        }

        private void TaiGiaHangHoa()
        {
            try
            {
                var dict = new Dictionary<string, decimal>();
                using (SqlConnection conn = DatabaseHelper.TaoKetNoi())
                using (SqlCommand cmd = new SqlCommand("SELECT MaHangHoa, DonGia FROM HangHoa", conn))
                {
                    conn.Open();
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                            dict[rd["MaHangHoa"].ToString()] = Convert.ToDecimal(rd["DonGia"]);
                    }
                }
                GiaHangJson = DuaVaoJs(new JavaScriptSerializer().Serialize(dict));
            }
            catch
            {
                GiaHangJson = "{}";
            }
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            //tro ve trang dau khi tim kiem
            dpDonHang.SetPageProperties(0, dpDonHang.PageSize, false);
            LoadDanhSachDonHang();
        }

        protected void btnDatLai_Click(object sender, EventArgs e)
        {
            txtMaDon.Text = string.Empty;
            txtTuNgay.Text = string.Empty;
            txtDenNgay.Text = string.Empty;
            ddlTrangThai.SelectedIndex = 0;
            dpDonHang.SetPageProperties(0, dpDonHang.PageSize, false);
            LoadDanhSachDonHang();
        }

        // Nạp danh sách hàng hóa vào DropDownList trong modal thêm/sửa
        private void LoadDanhSachHangHoa()
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.TaoKetNoi())
                using (SqlCommand cmd = new SqlCommand("SELECT MaHangHoa, TenHangHoa FROM HangHoa", conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlHangHoa.DataSource = dt;
                    ddlHangHoa.DataTextField = "TenHangHoa";
                    ddlHangHoa.DataValueField = "MaHangHoa";
                    ddlHangHoa.DataBind();
                    ddlHangHoa.Items.Insert(0, new ListItem("Chọn hàng hóa", ""));
                }
            }
            catch (Exception ex)
            {
                ThongBao("Lỗi tải danh mục hàng hóa: " + LoiThanThien(ex), false);
            }
        }

        private void LoadDanhSachDonHang()
        {
            try
            {
                using (SqlConnection conn = DatabaseHelper.TaoKetNoi())
                {
                    string sqlDon = @"SELECT d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai, 
                                     ISNULL(SUM(c.SoLuongDat * c.DonGia), 0) AS TongTien 
                              FROM DonDatHang d 
                              LEFT JOIN ChiTietDonDatHang c ON d.MaDonHang = c.MaDonHang
                              WHERE (@TuKhoa = '' OR d.MaDonHang LIKE '%' + @TuKhoa + '%' OR d.TenKhachHang LIKE '%' + @TuKhoa + '%')
                                AND (@TrangThai = '' OR d.TrangThai = @TrangThai)
                                AND (@TuNgay IS NULL OR d.NgayDatHang >= @TuNgay)
                                AND (@DenNgay IS NULL OR d.NgayDatHang < DATEADD(DAY, 1, @DenNgay))
                              GROUP BY d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai
                              ORDER BY d.NgayDatHang DESC";

                    string sqlChiTiet = @"SELECT c.MaDonHang, c.MaHangHoa, h.TenHangHoa, c.SoLuongDat, c.DonGia 
                                         FROM ChiTietDonDatHang c
                                         INNER JOIN HangHoa h ON c.MaHangHoa = h.MaHangHoa";

                    DateTime tuNgay, denNgay;
                    bool coTu = DateTime.TryParse(txtTuNgay.Text, out tuNgay);
                    bool coDen = DateTime.TryParse(txtDenNgay.Text, out denNgay);

                    using (SqlCommand cmdDon = new SqlCommand(sqlDon, conn))
                    {
                        cmdDon.Parameters.AddWithValue("@TuKhoa", txtMaDon.Text.Trim());
                        cmdDon.Parameters.AddWithValue("@TrangThai", ddlTrangThai.SelectedValue);
                        cmdDon.Parameters.AddWithValue("@TuNgay", coTu ? (object)tuNgay.Date : DBNull.Value);
                        cmdDon.Parameters.AddWithValue("@DenNgay", coDen ? (object)denNgay.Date : DBNull.Value);

                        using (SqlDataAdapter daDon = new SqlDataAdapter(cmdDon))
                        {
                            DataTable dtDon = new DataTable();
                            daDon.Fill(dtDon);

                            lvDonHang.DataSource = dtDon;
                            lvDonHang.DataBind();

                            lblSoLuong.Text = "Tổng số lượng: " + dtDon.Rows.Count + " đơn đặt hàng";

                            using (SqlCommand cmdChiTiet = new SqlCommand(sqlChiTiet, conn))
                            using (SqlDataAdapter daChiTiet = new SqlDataAdapter(cmdChiTiet))
                            {
                                DataTable dtChiTiet = new DataTable();
                                daChiTiet.Fill(dtChiTiet);
                                ChiTietJson = TaoChuoiJson(dtDon, dtChiTiet);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ThongBao("Lỗi kết nối hoặc truy xuất cơ sở dữ liệu: " + LoiThanThien(ex), false);
            }
        }

        private string TaoChuoiJson(DataTable dtDon, DataTable dtChiTiet)
        {
            var dict = new Dictionary<string, object>();

            foreach (DataRow rowDon in dtDon.Rows)
            {
                string maDon = rowDon["MaDonHang"].ToString();
                DateTime ngay = Convert.ToDateTime(rowDon["NgayDatHang"]);

                var dsChiTiet = new List<object>();
                foreach (DataRow rowChiTiet in dtChiTiet.Rows)
                {
                    if (rowChiTiet["MaDonHang"].ToString() == maDon)
                    {
                        dsChiTiet.Add(new
                        {
                            MaHang = rowChiTiet["MaHangHoa"].ToString(),
                            TenHang = rowChiTiet["TenHangHoa"].ToString(),
                            SoLuong = Convert.ToInt32(rowChiTiet["SoLuongDat"]),
                            DonGia = Convert.ToDecimal(rowChiTiet["DonGia"])
                        });
                    }
                }

                dict[maDon] = new
                {
                    khach = rowDon["TenKhachHang"].ToString(),
                    sdt = rowDon["SoDienThoai"].ToString(),
                    ngay = ngay.ToString("dd/MM/yyyy HH:mm"),
                    ngayRaw = ngay.ToString("yyyy-MM-ddTHH:mm"), // gán vào input datetime-local khi sửa
                    trangThai = rowDon["TrangThai"].ToString(),
                    dong = dsChiTiet
                };
            }

            return DuaVaoJs(new JavaScriptSerializer().Serialize(dict));
        }

        // =====================================================================
        //  XÓA
        // =====================================================================
        protected void lvDonHang_ItemCommand(object sender, ListViewCommandEventArgs e)
        {
            if (e.CommandName != "XoaDon") return;

            string maDonHang = e.CommandArgument.ToString();

            try
            {
                using (SqlConnection conn = DatabaseHelper.TaoKetNoi())
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        try
                        {
                            // Xóa chi tiết trước rồi mới xóa đơn (tránh lỗi khóa ngoại)
                            using (SqlCommand cmd = new SqlCommand("DELETE FROM ChiTietDonDatHang WHERE MaDonHang = @MaDonHang", conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDonHang", maDonHang);
                                cmd.ExecuteNonQuery();
                            }

                            int soDong;
                            using (SqlCommand cmd = new SqlCommand("DELETE FROM DonDatHang WHERE MaDonHang = @MaDonHang", conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDonHang", maDonHang);
                                soDong = cmd.ExecuteNonQuery();
                            }

                            if (soDong == 0)
                                throw new Exception("Không tìm thấy đơn hàng " + maDonHang + " (có thể đã bị xóa trước đó).");

                            tran.Commit();
                        }
                        catch
                        {
                            tran.Rollback();
                            throw;
                        }
                    }
                }

                ThongBao("Xóa đơn hàng " + maDonHang + " thành công!", true);
            }
            catch (Exception ex)
            {
                ThongBao("Xóa đơn hàng thất bại: " + LoiThanThien(ex), false);
            }

            LoadDanhSachDonHang();
        }

        protected static string FormatNgay(object value)
        {
            try
            {
                if (value == null || value == DBNull.Value) return string.Empty;
                return Convert.ToDateTime(value).ToString("dd/MM/yyyy HH:mm");
            }
            catch { return string.Empty; }
        }

        protected static string FormatTien(object value)
        {
            try
            {
                if (value == null || value == DBNull.Value) return "0 ₫";
                return Convert.ToDecimal(value).ToString("N0") + " ₫";
            }
            catch { return "0 ₫"; }
        }

        protected static string LopTrangThai(object value)
        {
            string trangThai = Convert.ToString(value);
            switch (trangThai)
            {
                case "Đã xuất kho": return "bg-success";
                case "Đang xử lý": return "bg-warning text-dark";
                default: return "bg-secondary";
            }
        }

        // =====================================================================
        //  THÊM / SỬA
        // =====================================================================
        protected void btnLuuDon_Click(object sender, EventArgs e)
        {
            string cheDo = hdCheDo.Value == "Sua" ? "Sua" : "Them";
            string maDon = mdMaDon.Text.Trim();
            string tenKhach = mdTenKhach.Text.Trim();
            string sdt = mdSdt.Text.Trim();
            string trangThai = mdTrangThai.SelectedValue;

            // Ngày đặt: bắt buộc nhập (không còn tự gán DateTime.Now)
            DateTime ngayDat;
            bool coNgay = DateTime.TryParse(mdNgayDat.Text, out ngayDat);

            // Lấy danh sách dòng hàng hóa từ form
            string[] maHang = Request.Form.GetValues(ddlHangHoa.UniqueID) ?? new string[0];
            string[] soLuong = Request.Form.GetValues("SoLuong") ?? new string[0];
            string[] donGia = Request.Form.GetValues("DonGia") ?? new string[0];

            string loi = null;
            var dsDong = new List<DongHang>();

            // ---- Kiểm tra dữ liệu đầu vào: tất cả đều bắt buộc ----
            if (string.IsNullOrEmpty(maDon))
            {
                loi = "Mã đơn hàng không được để trống!";
            }
            else if (!coNgay)
            {
                loi = "Ngày đặt không được để trống!";
            }
            else if (string.IsNullOrEmpty(tenKhach))
            {
                loi = "Tên khách hàng không được để trống!";
            }
            else if (string.IsNullOrEmpty(sdt))
            {
                loi = "Số điện thoại không được để trống!";
            }
            else if (!Regex.IsMatch(sdt, @"^\d{9,11}$"))
            {
                loi = "Số điện thoại không hợp lệ (chỉ gồm 9–11 chữ số)!";
            }
            else if (maHang.Length == 0)
            {
                loi = "Vui lòng chọn ít nhất một hàng hóa cho đơn!";
            }
            else if (maHang.Length != soLuong.Length || maHang.Length != donGia.Length)
            {
                loi = "Dữ liệu hàng hóa không hợp lệ!";
            }
            else
            {
                var daCo = new HashSet<string>();
                for (int i = 0; i < maHang.Length; i++)
                {
                    string dong = " ở dòng " + (i + 1) + "!";

                    if (string.IsNullOrWhiteSpace(maHang[i])) { loi = "Vui lòng chọn hàng hóa" + dong; break; }
                    if (string.IsNullOrWhiteSpace(soLuong[i])) { loi = "Số lượng không được để trống" + dong; break; }
                    if (string.IsNullOrWhiteSpace(donGia[i])) { loi = "Đơn giá không được để trống" + dong; break; }

                    int sl;
                    decimal gia;
                    if (!int.TryParse(soLuong[i], out sl) || sl < 1 ||
                        !decimal.TryParse(donGia[i], NumberStyles.Any, CultureInfo.InvariantCulture, out gia) || gia < 0)
                    {
                        loi = "Số lượng hoặc đơn giá không hợp lệ" + dong;
                        break;
                    }

                    if (!daCo.Add(maHang[i]))
                    {
                        loi = "Hàng hóa " + maHang[i] + " bị trùng ở nhiều dòng!";
                        break;
                    }

                    dsDong.Add(new DongHang { MaHang = maHang[i], SoLuong = sl, DonGia = gia });
                }
            }

            // ---- Ghi vào CSDL ----
            if (loi == null)
            {
                try
                {
                    LuuDonHang(cheDo, maDon, ngayDat, tenKhach, sdt, trangThai, dsDong);
                }
                catch (Exception ex)
                {
                    loi = LoiThanThien(ex);
                }
            }

            if (loi != null)
            {
                ThongBao((cheDo == "Them" ? "Thêm mới" : "Cập nhật") + " đơn đặt hàng thất bại: " + loi, false);
                MoLaiModal(cheDo, maHang, soLuong, donGia); // giữ nguyên dữ liệu người dùng đã nhập
            }
            else
            {
                ThongBao((cheDo == "Them" ? "Thêm mới" : "Cập nhật") + " đơn đặt hàng " + maDon + " thành công!", true);
            }

            // Luôn nạp lại danh sách để ChiTietJson (dùng cho nút Chi tiết / Sửa) luôn có dữ liệu
            LoadDanhSachDonHang();
        }

        private void LuuDonHang(string cheDo, string maDon, DateTime ngayDat, string tenKhach,
                                string sdt, string trangThai, List<DongHang> dsDong)
        {
            using (SqlConnection conn = DatabaseHelper.TaoKetNoi())
            {
                conn.Open();
                using (SqlTransaction tran = conn.BeginTransaction())
                {
                    try
                    {
                        if (cheDo == "Them")
                        {
                            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM DonDatHang WHERE MaDonHang = @MaDon", conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                if ((int)cmd.ExecuteScalar() > 0)
                                    throw new Exception("Mã đơn hàng " + maDon + " đã tồn tại!");
                            }

                            string sql = @"INSERT INTO DonDatHang (MaDonHang, NgayDatHang, TenKhachHang, SoDienThoai, TrangThai)
                                           VALUES (@MaDon, @NgayDat, @TenKhach, @Sdt, @TrangThai)";
                            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.Parameters.AddWithValue("@NgayDat", ngayDat);
                                cmd.Parameters.AddWithValue("@TenKhach", tenKhach);
                                cmd.Parameters.AddWithValue("@Sdt", sdt);
                                cmd.Parameters.AddWithValue("@TrangThai", trangThai);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            string sql = @"UPDATE DonDatHang SET
                                           NgayDatHang = @NgayDat,
                                           TenKhachHang = @TenKhach,
                                           SoDienThoai = @Sdt,
                                           TrangThai = @TrangThai
                                           WHERE MaDonHang = @MaDon";
                            int soDong;
                            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.Parameters.AddWithValue("@NgayDat", ngayDat);
                                cmd.Parameters.AddWithValue("@TenKhach", tenKhach);
                                cmd.Parameters.AddWithValue("@Sdt", sdt);
                                cmd.Parameters.AddWithValue("@TrangThai", trangThai);
                                soDong = cmd.ExecuteNonQuery();
                            }

                            if (soDong == 0)
                                throw new Exception("Không tìm thấy đơn hàng " + maDon + " để cập nhật.");

                            // Xóa chi tiết cũ để ghi chi tiết mới
                            using (SqlCommand cmd = new SqlCommand("DELETE FROM ChiTietDonDatHang WHERE MaDonHang = @MaDon", conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        foreach (DongHang d in dsDong)
                        {
                            string sql = @"INSERT INTO ChiTietDonDatHang (MaDonHang, MaHangHoa, SoLuongDat, DonGia)
                                           VALUES (@MaDon, @MaHang, @SoLuong, @DonGia)";
                            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.Parameters.AddWithValue("@MaHang", d.MaHang);
                                cmd.Parameters.AddWithValue("@SoLuong", d.SoLuong);
                                cmd.Parameters.AddWithValue("@DonGia", d.DonGia);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                    catch
                    {
                        tran.Rollback();
                        throw;
                    }
                }
            }
        }

        // Khi lưu lỗi: mở lại modal + dựng lại các dòng hàng hóa đã nhập (postback làm mất dòng thêm bằng JS)
        private void MoLaiModal(string cheDo, string[] maHang, string[] soLuong, string[] donGia)
        {
            var dong = new List<object>();
            for (int i = 0; i < maHang.Length; i++)
            {
                dong.Add(new
                {
                    ma = maHang[i],
                    sl = i < soLuong.Length ? soLuong[i] : "1",
                    gia = i < donGia.Length ? donGia[i] : "0"
                });
            }

            string json = DuaVaoJs(new JavaScriptSerializer().Serialize(dong));
            string js = "window.addEventListener('load',function(){khoiPhucForm('" + cheDo + "'," + json + ");});";
            ClientScript.RegisterStartupScript(this.GetType(), "KhoiPhucForm", js, true);
        }


        //xu ly phan trang
        protected void lvDonHang_PagePropertiesChanging(object sender, PagePropertiesChangingEventArgs e)
        {
            dpDonHang.SetPageProperties(e.StartRowIndex, e.MaximumRows, false);
            LoadDanhSachDonHang();
        }
    }
}