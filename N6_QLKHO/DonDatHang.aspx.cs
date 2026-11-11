using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class DonDatHang : System.Web.UI.Page
    {
        string chuoiKetNoi = ConfigurationManager.ConnectionStrings["N6_QLKHOVATTUConnectionString"] != null
                            ? ConfigurationManager.ConnectionStrings["N6_QLKHOVATTUConnectionString"].ConnectionString
                            : @"Data Source=DESKTOP-UKT66TU;Initial Catalog=N6_QLKHOVATTU;Integrated Security=True;Encrypt=False";

        protected string ChiTietJson { get; set; } = "{}";
        protected string GiaHangJson { get; set; } = "{}";
        protected void Page_Load(object sender, EventArgs e)
        {
            TaiGiaHangHoa(); // luôn chạy để JS có bảng giá sau mỗi lần postback

            if (!IsPostBack)
            {
                LoadDanhSachHangHoa();
                LoadDanhSachDonHang();
            }
        }



        private void TaiGiaHangHoa()
        {
            try
            {
                var dict = new Dictionary<string, decimal>();
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                using (SqlCommand cmd = new SqlCommand("SELECT MaHangHoa, DonGia FROM HangHoa", conn))
                {
                    conn.Open();
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                            dict[rd["MaHangHoa"].ToString()] = Convert.ToDecimal(rd["DonGia"]);
                    }
                }
                GiaHangJson = new JavaScriptSerializer().Serialize(dict);
            }
            catch
            {
                GiaHangJson = "{}";
            }
        }
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadDanhSachDonHang();
        }

        protected void btnDatLai_Click(object sender, EventArgs e)
        {
            txtMaDon.Text = string.Empty;
            ddlTrangThai.SelectedIndex = 0;
            LoadDanhSachDonHang();
        }

        // Nạp danh sách hàng hóa vào DropDownList trong modal thêm/sửa
        private void LoadDanhSachHangHoa()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                {
                    string query = "SELECT MaHangHoa, TenHangHoa FROM HangHoa";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
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
                }
            }
            catch (Exception ex)
            {
                lblLoi.Text = "Lỗi tải danh mục hàng hóa: " + ex.Message;
                lblLoi.Visible = true;
            }
        }

        private void LoadDanhSachDonHang()
        {
            lblLoi.Visible = false;
            try
            {
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                {
                    string sqlDon = @"SELECT d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai, 
                                     ISNULL(SUM(c.SoLuongDat * c.DonGia), 0) AS TongTien 
                              FROM DonDatHang d 
                              LEFT JOIN ChiTietDonDatHang c ON d.MaDonHang = c.MaDonHang
                              WHERE (@TuKhoa = '' OR d.MaDonHang LIKE '%' + @TuKhoa + '%' OR d.TenKhachHang LIKE '%' + @TuKhoa + '%')
                                AND (@TrangThai = '' OR d.TrangThai = @TrangThai)
                              GROUP BY d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai
                              ORDER BY d.NgayDatHang DESC";

                    string sqlChiTiet = @"SELECT c.MaDonHang, c.MaHangHoa, h.TenHangHoa, c.SoLuongDat, c.DonGia 
                                         FROM ChiTietDonDatHang c
                                         INNER JOIN HangHoa h ON c.MaHangHoa = h.MaHangHoa";

                    using (SqlCommand cmdDon = new SqlCommand(sqlDon, conn))
                    {
                        cmdDon.Parameters.AddWithValue("@TuKhoa", txtMaDon.Text.Trim());
                        cmdDon.Parameters.AddWithValue("@TrangThai", ddlTrangThai.SelectedValue);

                        using (SqlDataAdapter daDon = new SqlDataAdapter(cmdDon))
                        {
                            DataTable dtDon = new DataTable();
                            daDon.Fill(dtDon);

                            lvDonHang.DataSource = dtDon;
                            lvDonHang.DataBind();

                            lblSoLuong.Text = "Tổng số lượng: " + dtDon.Rows.Count + " đơn đặt hàng";

                            using (SqlCommand cmdChiTiet = new SqlCommand(sqlChiTiet, conn))
                            {
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
            }
            catch (Exception ex)
            {
                lblLoi.Text = "Lỗi kết nối hoặc truy xuất cơ sở dữ liệu: " + ex.Message;
                lblLoi.Visible = true;
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
                    ngayRaw = ngay.ToString("yyyy-MM-ddTHH:mm"), // Dùng để gán vào input datetime-local khi sửa
                    trangThai = rowDon["TrangThai"].ToString(),
                    dong = dsChiTiet
                };
            }

            var serializer = new JavaScriptSerializer();
            return serializer.Serialize(dict);
        }

        protected void lvDonHang_ItemCommand(object sender, ListViewCommandEventArgs e)
        {
            string maDonHang = e.CommandArgument.ToString();

            if (e.CommandName == "XoaDon")
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                    {
                        string query = "DELETE FROM DonDatHang WHERE MaDonHang = @MaDonHang";
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@MaDonHang", maDonHang);
                            conn.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }
                    LoadDanhSachDonHang();
                }
                catch (Exception ex)
                {
                    lblLoi.Text = "Lỗi khi xóa: " + ex.Message;
                    lblLoi.Visible = true;
                }
            }
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


        // them moi

        protected void btnLuuDon_Click(object sender, EventArgs e)
        {
            string cheDo = hdCheDo.Value;
            string maDon = mdMaDon.Text.Trim();
            string tenKhach = mdTenKhach.Text.Trim();
            string sdt = mdSdt.Text.Trim();
            string trangThai = mdTrangThai.SelectedValue;

            DateTime ngayDat;
            if (!DateTime.TryParse(mdNgayDat.Text, out ngayDat))
                ngayDat = DateTime.Now;

            // Lấy danh sách sản phẩm từ form
            string[] maHang = Request.Form.GetValues(ddlHangHoa.UniqueID)
    ?? new string[0];

            string[] soLuong = Request.Form.GetValues("SoLuong");
            string[] donGia = Request.Form.GetValues("DonGia");

            if (string.IsNullOrEmpty(maDon))
            {
                lblLoi.Text = "Mã đơn hàng không được để trống!";
                lblLoi.Visible = true;
                return;
            }

            if (soLuong == null || donGia == null ||
                maHang.Length != soLuong.Length ||
                maHang.Length != donGia.Length)
            {
                lblLoi.Text = "Dữ liệu hàng hóa không hợp lệ!";
                lblLoi.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
            {
                conn.Open();

                using (SqlTransaction tran = conn.BeginTransaction())
                {
                    try
                    {
                        if (cheDo == "Them")
                        {
                            string checkSql =
                                "SELECT COUNT(1) FROM DonDatHang WHERE MaDonHang = @MaDon";

                            using (SqlCommand cmd = new SqlCommand(checkSql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);

                                if ((int)cmd.ExecuteScalar() > 0)
                                    throw new Exception("Mã đơn hàng đã tồn tại!");
                            }

                            string sql = @"INSERT INTO DonDatHang
                        (MaDonHang, NgayDatHang, TenKhachHang, SoDienThoai, TrangThai)
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

                            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.Parameters.AddWithValue("@NgayDat", ngayDat);
                                cmd.Parameters.AddWithValue("@TenKhach", tenKhach);
                                cmd.Parameters.AddWithValue("@Sdt", sdt);
                                cmd.Parameters.AddWithValue("@TrangThai", trangThai);
                                cmd.ExecuteNonQuery();
                            }

                            // Xóa chi tiết cũ để cập nhật chi tiết mới
                            using (SqlCommand cmd = new SqlCommand(
                                "DELETE FROM ChiTietDonDatHang WHERE MaDonHang = @MaDon",
                                conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Lưu từng sản phẩm vào bảng ChiTietDonDatHang
                        for (int i = 0; i < maHang.Length; i++)
                        {
                            if (string.IsNullOrWhiteSpace(maHang[i]))
                                continue;

                            int sl;
                            decimal gia;

                            if (!int.TryParse(soLuong[i], out sl) || sl < 1 ||
                                !decimal.TryParse(
                                    donGia[i],
                                    System.Globalization.NumberStyles.Any,
                                    System.Globalization.CultureInfo.InvariantCulture,
                                    out gia) || gia < 0)
                            {
                                throw new Exception("Số lượng hoặc đơn giá không hợp lệ!");
                            }

                            string sql = @"INSERT INTO ChiTietDonDatHang
                        (MaDonHang, MaHangHoa, SoLuongDat, DonGia)
                        VALUES (@MaDon, @MaHang, @SoLuong, @DonGia)";

                            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@MaDon", maDon);
                                cmd.Parameters.AddWithValue("@MaHang", maHang[i]);
                                cmd.Parameters.AddWithValue("@SoLuong", sl);
                                cmd.Parameters.AddWithValue("@DonGia", gia);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        lblLoi.Text = "Lỗi lưu đơn hàng: " + ex.Message;
                        lblLoi.Visible = true;
                        return;
                    }
                }
            }

            // Tải lại dữ liệu sau khi lưu
            LoadDanhSachHangHoa();
            LoadDanhSachDonHang();

            ClientScript.RegisterStartupScript(
                this.GetType(),
                "HideModal",
                "var m = bootstrap.Modal.getInstance(document.getElementById('modalDonDatHang')); if(m) m.hide();",
                true);
        }

    }
}