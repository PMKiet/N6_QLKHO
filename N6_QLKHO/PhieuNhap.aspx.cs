using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class PhieuNhap : System.Web.UI.Page
    {
        // Giới hạn hợp lý cho tiền tệ Việt Nam (VND): tối thiểu 1.000 VND, tối đa 1.000.000.000 VND
        private const int SO_LUONG_TOI_DA = 1000000;
        private const decimal DON_GIA_TOI_THIEU = 1000m;
        private const decimal DON_GIA_TOI_DA = 1000000000m;
        private static readonly Regex MaPhieuHopLe = new Regex("^[A-Za-z0-9_-]{1,10}$");

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["MaNhanVien"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            txtNhanVien.Text = Convert.ToString(Session["HoTen"]) + " (" + Convert.ToString(Session["ChucVu"]) + ")";
            txtNgayNhap.Attributes["max"] = DateTime.Today.ToString("yyyy-MM-dd");
            txtHanSuDungLo.Attributes["min"] = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                txtNgayNhap.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtHanSuDungLo.Text = DateTime.Today.AddYears(1).ToString("yyyy-MM-dd");
                try
                {
                    LoadDropdownData();
                    txtMaPhieuNhap.Text = GoiYMaPhieu();
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
                KhoiTaoBangChiTiet();
            }

            DangKyBangGiaThamChieu();
        }

        // 1. Nạp dữ liệu danh mục
        private void LoadDropdownData()
        {
            ddlNhaCungCap.DataSource = DatabaseHelper.ExecuteQuery(
                "SELECT RTRIM(LTRIM(MaNCC)) AS MaNCC, RTRIM(LTRIM(MaNCC)) + N' - ' + TenNCC AS TenHienThi FROM NhaCungCap ORDER BY TenNCC");
            ddlNhaCungCap.DataTextField = "TenHienThi";
            ddlNhaCungCap.DataValueField = "MaNCC";
            ddlNhaCungCap.DataBind();
            ddlNhaCungCap.Items.Insert(0, new ListItem("-- Chọn đối tác cung cấp --", ""));

            ddlHangHoa.DataSource = DatabaseHelper.ExecuteQuery(
                "SELECT RTRIM(LTRIM(MaHangHoa)) AS MaHangHoa, RTRIM(LTRIM(MaHangHoa)) + N' - ' + TenHangHoa + N'  (' + DonViTinh + N')' AS TenHienThi FROM HangHoa ORDER BY MaHangHoa");
            ddlHangHoa.DataTextField = "TenHienThi";
            ddlHangHoa.DataValueField = "MaHangHoa";
            ddlHangHoa.DataBind();
            ddlHangHoa.Items.Insert(0, new ListItem("-- Chọn hàng hóa cần nhập --", ""));
        }

        // Đưa đơn giá tham chiếu từ bảng HangHoa xuống trình duyệt để gợi ý nhanh khi chọn mặt hàng
        private void DangKyBangGiaThamChieu()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT RTRIM(LTRIM(MaHangHoa)) AS MaHangHoa, DonGia FROM HangHoa");
                StringBuilder sb = new StringBuilder("var giaThamChieu = {");
                foreach (DataRow r in dt.Rows)
                {
                    string ma = Convert.ToString(r["MaHangHoa"]).Trim().Replace("\\", "").Replace("'", "");
                    decimal gia = Convert.ToDecimal(r["DonGia"]);
                    sb.Append("'").Append(ma).Append("':")
                      .Append(Math.Round(gia, 0).ToString("0", CultureInfo.InvariantCulture))
                      .Append(",");
                }
                sb.Append("};");
                ClientScript.RegisterStartupScript(GetType(), "giaThamChieu", sb.ToString(), true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
            }
        }

        // Gợi ý mã phiếu kế tiếp (PN01, PN02, ...)
        private string GoiYMaPhieu()
        {
            object kq = DatabaseHelper.ExecuteScalar(
                "SELECT ISNULL(MAX(CASE WHEN MaPhieuNhap LIKE 'PN[0-9]%' AND MaPhieuNhap NOT LIKE 'PN%[^0-9]%' " +
                "THEN CAST(SUBSTRING(MaPhieuNhap, 3, 8) AS int) END), 0) + 1 FROM PhieuNhap");
            int so = 1;
            if (kq != null && kq != DBNull.Value)
            {
                so = Convert.ToInt32(kq);
            }
            return "PN" + so.ToString("D2");
        }

        // 2. Bảng tạm chi tiết nhập
        private DataTable TaoBangChiTiet()
        {
            DataTable dt = new DataTable("ChiTietNhap");
            dt.Columns.Add("MaHangHoa", typeof(string));
            dt.Columns.Add("TenHangHoa", typeof(string));
            dt.Columns.Add("SoLuongNhap", typeof(int));
            dt.Columns.Add("DonGiaNhap", typeof(decimal));
            dt.Columns.Add("HanSuDungLo", typeof(DateTime));
            dt.Columns.Add("ThanhTien", typeof(decimal));
            return dt;
        }

        private void KhoiTaoBangChiTiet()
        {
            DataTable dt = TaoBangChiTiet();
            ViewState["ChiTietNhap"] = dt;
            HienThiBangTam(dt);
        }

        private DataTable LayBangChiTiet()
        {
            DataTable dt = ViewState["ChiTietNhap"] as DataTable;
            if (dt == null)
            {
                dt = TaoBangChiTiet();
                ViewState["ChiTietNhap"] = dt;
            }
            return dt;
        }

        // Bind bảng tạm và cập nhật dòng tổng cộng (đơn vị VND)
        private void HienThiBangTam(DataTable dt)
        {
            gvChiTietPhieuNhap.DataSource = dt;
            gvChiTietPhieuNhap.DataBind();

            decimal tongTien = 0m;
            int tongSL = 0;
            foreach (DataRow r in dt.Rows)
            {
                tongTien += Convert.ToDecimal(r["ThanhTien"]);
                tongSL += Convert.ToInt32(r["SoLuongNhap"]);
            }

            if (dt.Rows.Count == 0)
            {
                litTongTamTinh.Text = "";
            }
            else
            {
                litTongTamTinh.Text =
                    "<div class='summary-footer-bar d-flex flex-wrap justify-content-between align-items-center gap-3 mt-3'>" +
                    "<div class='text-secondary small fw-semibold'><i class='fa-solid fa-layer-group me-1 text-success'></i>Tổng hợp bảng kê: <strong>" + dt.Rows.Count + "</strong> mặt hàng &bull; <strong>" + tongSL.ToString("N0") + "</strong> sản phẩm</div>" +
                    "<div class='d-flex align-items-center gap-2'>" +
                    "<span class='text-secondary fw-semibold'>Tổng tiền tạm tính:</span>" +
                    "<span class='fs-5 fw-bold text-success tabular-nums'>" + tongTien.ToString("N0") + " VND</span>" +
                    "</div></div>";
            }
        }

        // 3. Nút Thêm dòng
        protected void btnThemDong_Click(object sender, EventArgs e)
        {
            lblThongBao.Text = "";

            try
            {
                string maHang = ddlHangHoa.SelectedValue;
                if (string.IsNullOrEmpty(maHang))
                {
                    HienThiThongBao("Vui lòng chọn hàng hóa cần nhập kho!", "warning");
                    return;
                }

                int soLuong;
                if (!int.TryParse(txtSoLuongNhap.Text.Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out soLuong) || soLuong <= 0)
                {
                    HienThiThongBao("Số lượng nhập phải là số nguyên dương (từ 1 trở lên)!", "warning");
                    return;
                }
                if (soLuong > SO_LUONG_TOI_DA)
                {
                    HienThiThongBao("Số lượng nhập tối đa mỗi dòng là " + SO_LUONG_TOI_DA.ToString("N0") + "!", "warning");
                    return;
                }

                decimal donGia;
                if (!decimal.TryParse(txtDonGiaNhap.Text.Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out donGia) || donGia < DON_GIA_TOI_THIEU)
                {
                    HienThiThongBao("Đơn giá nhập không hợp lệ! Vui lòng nhập số nguyên từ " + DON_GIA_TOI_THIEU.ToString("N0") + " VND trở lên (không nhập 1, 2...).", "warning");
                    return;
                }
                if (donGia > DON_GIA_TOI_DA)
                {
                    HienThiThongBao("Đơn giá nhập tối đa là " + DON_GIA_TOI_DA.ToString("N0") + " VND!", "warning");
                    return;
                }

                DateTime hanLo;
                if (!DateTime.TryParseExact(txtHanSuDungLo.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out hanLo))
                {
                    HienThiThongBao("Vui lòng chọn hạn sử dụng lô hàng hợp lệ!", "warning");
                    return;
                }
                if (hanLo.Date <= DateTime.Today)
                {
                    HienThiThongBao("Hạn sử dụng lô hàng phải sau ngày hôm nay (lô đã hết hạn không thể nhập kho)!", "warning");
                    return;
                }
                if (hanLo.Year > 2100)
                {
                    HienThiThongBao("Hạn sử dụng lô hàng không hợp lệ!", "warning");
                    return;
                }

                DataTable dt = LayBangChiTiet();

                DataRow dongCu = null;
                foreach (DataRow r in dt.Rows)
                {
                    if (Convert.ToString(r["MaHangHoa"]) == maHang)
                    {
                        dongCu = r;
                        break;
                    }
                }

                string tenHang = ddlHangHoa.SelectedItem.Text.Split(new string[] { "  (" }, StringSplitOptions.None)[0];

                if (dongCu != null)
                {
                    if (Convert.ToDecimal(dongCu["DonGiaNhap"]) != donGia || Convert.ToDateTime(dongCu["HanSuDungLo"]).Date != hanLo.Date)
                    {
                        HienThiThongBao("Hàng này đã có trong phiếu với đơn giá hoặc hạn dùng khác. Hãy xóa dòng cũ hoặc nhập cùng đơn giá và hạn dùng để gộp số lượng.", "warning");
                        return;
                    }

                    int daCo = Convert.ToInt32(dongCu["SoLuongNhap"]);
                    if ((long)daCo + soLuong > SO_LUONG_TOI_DA)
                    {
                        HienThiThongBao("Tổng số lượng của một mặt hàng tối đa là " + SO_LUONG_TOI_DA.ToString("N0") + "!", "warning");
                        return;
                    }
                    dongCu["SoLuongNhap"] = daCo + soLuong;
                    dongCu["ThanhTien"] = (daCo + soLuong) * donGia;
                }
                else
                {
                    dt.Rows.Add(maHang, tenHang, soLuong, donGia, hanLo.Date, soLuong * donGia);
                }

                ViewState["ChiTietNhap"] = dt;
                HienThiBangTam(dt);

                ddlHangHoa.SelectedIndex = 0;
                txtSoLuongNhap.Text = "";
                txtDonGiaNhap.Text = "";
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
            }
        }

        // 4. Xóa dòng tạm
        protected void gvChiTietPhieuNhap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "XoaDong")
            {
                return;
            }

            int rowIndex;
            DataTable dt = LayBangChiTiet();
            if (int.TryParse(Convert.ToString(e.CommandArgument), out rowIndex) && rowIndex >= 0 && rowIndex < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(rowIndex);
                ViewState["ChiTietNhap"] = dt;
                HienThiBangTam(dt);
            }
        }

        // 5. Kiểm tra toàn bộ phiếu
        private string KiemTraThongTinPhieu()
        {
            string maPN = txtMaPhieuNhap.Text.Trim();
            if (!MaPhieuHopLe.IsMatch(maPN))
            {
                return "Mã phiếu nhập chỉ gồm chữ, số, dấu '-' hoặc '_' và dài tối đa 10 ký tự!";
            }

            DateTime ngayNhap;
            if (!DateTime.TryParseExact(txtNgayNhap.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out ngayNhap)
                || ngayNhap < new DateTime(2000, 1, 1))
            {
                return "Vui lòng chọn Ngày nhập hợp lệ!";
            }
            if (ngayNhap.Date > DateTime.Today)
            {
                return "Ngày nhập không được ở tương lai!";
            }

            if (string.IsNullOrEmpty(ddlNhaCungCap.SelectedValue))
            {
                return "Vui lòng chọn Nhà cung cấp!";
            }

            if (string.IsNullOrEmpty(ddlTrangThai.SelectedValue))
            {
                return "Vui lòng chọn Trạng thái thanh toán!";
            }

            object nv = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM NguoiDung WHERE MaNhanVien = @MaNV",
                new SqlParameter[] { new SqlParameter("@MaNV", Convert.ToString(Session["MaNhanVien"])) });
            if (Convert.ToInt32(nv) == 0)
            {
                return "Tài khoản đăng nhập không còn hợp lệ. Vui lòng đăng nhập lại!";
            }

            object ncc = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM NhaCungCap WHERE MaNCC = @MaNCC",
                new SqlParameter[] { new SqlParameter("@MaNCC", ddlNhaCungCap.SelectedValue) });
            if (Convert.ToInt32(ncc) == 0)
            {
                return "Nhà cung cấp đã chọn không còn tồn tại!";
            }

            DataTable dtChiTiet = LayBangChiTiet();
            if (dtChiTiet.Rows.Count == 0)
            {
                return "Phiếu nhập chưa có sản phẩm nào! Vui lòng thêm ít nhất một mặt hàng.";
            }

            foreach (DataRow r in dtChiTiet.Rows)
            {
                if (Convert.ToDecimal(r["DonGiaNhap"]) < DON_GIA_TOI_THIEU)
                {
                    return "Đơn giá của \"" + Convert.ToString(r["TenHangHoa"]) + "\" phải từ " + DON_GIA_TOI_THIEU.ToString("N0") + " VND trở lên!";
                }
                if (Convert.ToDateTime(r["HanSuDungLo"]).Date <= ngayNhap.Date)
                {
                    return "Hạn sử dụng của \"" + Convert.ToString(r["TenHangHoa"]) + "\" phải sau ngày nhập!";
                }
            }

            object trung = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM PhieuNhap WHERE MaPhieuNhap = @MaPN",
                new SqlParameter[] { new SqlParameter("@MaPN", maPN) });
            if (Convert.ToInt32(trung) > 0)
            {
                return "Mã phiếu nhập \"" + maPN + "\" đã tồn tại! Vui lòng nhập mã khác.";
            }

            return null;
        }

        // 6. Nút "Xem trước phiếu"
        protected void btnXemTruoc_Click(object sender, EventArgs e)
        {
            try
            {
                string loi = KiemTraThongTinPhieu();
                if (loi != null)
                {
                    HienThiThongBao(loi, "danger");
                    return;
                }

                DataTable dtChiTiet = LayBangChiTiet();
                decimal tongTien = 0m;
                int tongSL = 0;
                foreach (DataRow r in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(r["ThanhTien"]);
                    tongSL += Convert.ToInt32(r["SoLuongNhap"]);
                }

                gvXemTruoc.DataSource = dtChiTiet;
                gvXemTruoc.DataBind();

                DateTime ngayNhap = DateTime.ParseExact(txtNgayNhap.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
                string trangThai = ddlTrangThai.SelectedValue;
                string badge = "";
                if (trangThai == "Đã thanh toán")
                {
                    badge = "<span class='badge bg-success'>" + Server.HtmlEncode(trangThai) + "</span>";
                }
                else
                {
                    badge = "<span class='badge bg-warning text-dark'>" + Server.HtmlEncode(trangThai) + "</span>";
                }

                litThongTinXemTruoc.Text =
                    "<div class='row g-3'>" +
                    DongThongTin("Mã phiếu nhập", txtMaPhieuNhap.Text.Trim(), true) +
                    DongThongTin("Ngày nhập", ngayNhap.ToString("dd/MM/yyyy"), true) +
                    DongThongTin("Người lập phiếu", Convert.ToString(Session["HoTen"]), true) +
                    DongThongTin("Nhà cung cấp", ddlNhaCungCap.SelectedItem.Text, true) +
                    DongThongTin("Số mặt hàng / Tổng số lượng", dtChiTiet.Rows.Count + " mặt hàng / " + tongSL.ToString("N0") + " sản phẩm", true) +
                    DongThongTin("Trạng thái thanh toán", badge, false) +
                    "</div>";

                litTongTienXemTruoc.Text = tongTien.ToString("N0") + " VND";
                litMaPhieuHeader.Text = Server.HtmlEncode(txtMaPhieuNhap.Text.Trim());
                litChuKyNguoiLap.Text = Server.HtmlEncode(Convert.ToString(Session["HoTen"]));

                lblThongBao.Text = "";
                ChuyenCheDo(true);
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
            }
        }

        // 7. Quay lại chỉnh sửa
        protected void btnQuayLai_Click(object sender, EventArgs e)
        {
            ChuyenCheDo(false);
        }

        // 8. Xác nhận lập phiếu
        protected void btnLuuPhieuNhap_Click(object sender, EventArgs e)
        {
            try
            {
                string loi = KiemTraThongTinPhieu();
                if (loi != null)
                {
                    ChuyenCheDo(false);
                    HienThiThongBao(loi, "danger");
                    return;
                }

                string maPN = txtMaPhieuNhap.Text.Trim();
                string maNCC = ddlNhaCungCap.SelectedValue;
                string maNV = Convert.ToString(Session["MaNhanVien"]);
                string trangThai = ddlTrangThai.SelectedValue;
                DateTime ngayNhap = DateTime.ParseExact(txtNgayNhap.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
                DataTable dtChiTiet = LayBangChiTiet();

                decimal tongTien = 0m;
                foreach (DataRow r in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(r["SoLuongNhap"]) * Convert.ToDecimal(r["DonGiaNhap"]);
                }

                DatabaseHelper.ExecuteTransaction(delegate (SqlConnection conn, SqlTransaction tran)
                {
                    using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                        "INSERT INTO PhieuNhap (MaPhieuNhap, NgayNhap, TongTien, TrangThaiThanhToan, MaNCC, MaNhanVien) " +
                        "VALUES (@MaPN, @NgayNhap, @TongTien, @TrangThai, @MaNCC, @MaNV)",
                        new SqlParameter("@MaPN", maPN),
                        new SqlParameter("@NgayNhap", ngayNhap),
                        new SqlParameter("@TongTien", tongTien),
                        new SqlParameter("@TrangThai", trangThai),
                        new SqlParameter("@MaNCC", maNCC),
                        new SqlParameter("@MaNV", maNV)))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    foreach (DataRow r in dtChiTiet.Rows)
                    {
                        string maHH = Convert.ToString(r["MaHangHoa"]);
                        int sl = Convert.ToInt32(r["SoLuongNhap"]);
                        decimal dg = Convert.ToDecimal(r["DonGiaNhap"]);
                        DateTime hanLo = Convert.ToDateTime(r["HanSuDungLo"]).Date;

                        using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                            "INSERT INTO ChiTietPhieuNhap (MaPhieuNhap, MaHangHoa, SoLuongNhap, DonGiaNhap, HanSuDungLo) " +
                            "VALUES (@MaPN, @MaHH, @SL, @DG, @Han)",
                            new SqlParameter("@MaPN", maPN),
                            new SqlParameter("@MaHH", maHH),
                            new SqlParameter("@SL", sl),
                            new SqlParameter("@DG", dg),
                            new SqlParameter("@Han", hanLo)))
                        {
                            cmd.ExecuteNonQuery();
                        }

                        using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                            "UPDATE TonKho SET SoLuongTon = SoLuongTon + @SL WHERE MaHangHoa = @MaHH AND HanSuDung = @Han; " +
                            "IF @@ROWCOUNT = 0 INSERT INTO TonKho (MaHangHoa, SoLuongTon, HanSuDung) VALUES (@MaHH, @SL, @Han);",
                            new SqlParameter("@MaHH", maHH),
                            new SqlParameter("@SL", sl),
                            new SqlParameter("@Han", hanLo)))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                });

                KhoiTaoBangChiTiet();
                txtMaPhieuNhap.Text = GoiYMaPhieu();
                ChuyenCheDo(false);
                HienThiThongBao("Lập phiếu nhập kho thành công! Tồn kho đã được cập nhật.", "success");
            }
            catch (Exception ex)
            {
                ChuyenCheDo(false);
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
            }
        }

        // 9. Xuất file Excel & Word từ bản xem trước
        private string TaoHtmlPhieuNhap()
        {
            DataTable dtChiTiet = LayBangChiTiet();
            DateTime ngayNhap = DateTime.ParseExact(txtNgayNhap.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
            string maPN = Server.HtmlEncode(txtMaPhieuNhap.Text.Trim());
            string ncc = Server.HtmlEncode(ddlNhaCungCap.SelectedItem.Text);
            string nguoiLap = Server.HtmlEncode(Convert.ToString(Session["HoTen"]));
            string trangThai = Server.HtmlEncode(ddlTrangThai.SelectedValue);

            decimal tongTien = 0m;
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8' /></head><body style='font-family: Times New Roman, Arial, sans-serif; font-size: 13pt;'>");
            sb.Append("<table width='100%' border='0'><tr>");
            sb.Append("<td><b>HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHO)</b><br/><i>Bộ phận Kho vận &amp; Cung ứng</i></td>");
            sb.Append("<td align='right'><b>Mẫu số: 01 - VT</b><br/>Ngày xuất file: " + DateTime.Now.ToString("dd/MM/yyyy HH:mm") + "</td>");
            sb.Append("</tr></table>");

            sb.Append("<h2 align='center' style='margin-bottom:4px;'>PHIẾU NHẬP KHO</h2>");
            sb.Append("<p align='center' style='margin-top:0;'>Số phiếu: <b>" + maPN + "</b> &nbsp;|&nbsp; Ngày nhập: <b>" + ngayNhap.ToString("dd/MM/yyyy") + "</b></p>");

            sb.Append("<table width='100%' border='0' cellpadding='4' style='margin-bottom:10px;'>");
            sb.Append("<tr><td width='50%'><b>Nhà cung cấp:</b> " + ncc + "</td><td width='50%'><b>Người lập phiếu:</b> " + nguoiLap + "</td></tr>");
            sb.Append("<tr><td><b>Trạng thái thanh toán:</b> " + trangThai + "</td><td></td></tr>");
            sb.Append("</table>");

            sb.Append("<table width='100%' border='1' cellspacing='0' cellpadding='6' style='border-collapse:collapse;'>");
            sb.Append("<tr style='background-color:#e2e8f0; font-weight:bold; text-align:center;'>");
            sb.Append("<th>STT</th><th>Mã Hàng</th><th>Tên Hàng Hóa</th><th>Số Lượng</th><th>Đơn Giá (VND)</th><th>Hạn Dùng Lô</th><th>Thành Tiền (VND)</th>");
            sb.Append("</tr>");

            int stt = 1;
            foreach (DataRow r in dtChiTiet.Rows)
            {
                decimal thanhTien = Convert.ToDecimal(r["ThanhTien"]);
                tongTien += thanhTien;
                sb.Append("<tr>");
                sb.Append("<td align='center'>" + stt + "</td>");
                sb.Append("<td align='center'>" + Server.HtmlEncode(Convert.ToString(r["MaHangHoa"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["TenHangHoa"])) + "</td>");
                sb.Append("<td align='right'>" + Convert.ToInt32(r["SoLuongNhap"]).ToString("N0") + "</td>");
                sb.Append("<td align='right'>" + Convert.ToDecimal(r["DonGiaNhap"]).ToString("N0") + " VND</td>");
                sb.Append("<td align='center'>" + Convert.ToDateTime(r["HanSuDungLo"]).ToString("dd/MM/yyyy") + "</td>");
                sb.Append("<td align='right'><b>" + thanhTien.ToString("N0") + " VND</b></td>");
                sb.Append("</tr>");
                stt++;
            }

            sb.Append("<tr><td colspan='6' align='right'><b>TỔNG CỘNG THANH TOÁN:</b></td><td align='right'><b>" + tongTien.ToString("N0") + " VND</b></td></tr>");
            sb.Append("</table><br/><br/>");

            sb.Append("<table width='100%' border='0' style='text-align:center;'><tr>");
            sb.Append("<td width='33%'><b>Người lập phiếu</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/><b>" + nguoiLap + "</b></td>");
            sb.Append("<td width='33%'><b>Người giao hàng</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/></td>");
            sb.Append("<td width='33%'><b>Thủ kho / Kế toán</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/></td>");
            sb.Append("</tr></table>");
            sb.Append("</body></html>");
            return sb.ToString();
        }

        protected void btnXuatExcel_Click(object sender, EventArgs e)
        {
            string loi = KiemTraThongTinPhieu();
            if (loi != null)
            {
                HienThiThongBao(loi, "danger");
                return;
            }

            string tenFile = "PhieuNhap_" + txtMaPhieuNhap.Text.Trim() + ".xls";
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.ContentEncoding = Encoding.UTF8;
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + tenFile);
            Response.Write("\uFEFF" + TaoHtmlPhieuNhap());
            Response.End();
        }

        protected void btnXuatWord_Click(object sender, EventArgs e)
        {
            string loi = KiemTraThongTinPhieu();
            if (loi != null)
            {
                HienThiThongBao(loi, "danger");
                return;
            }

            string tenFile = "PhieuNhap_" + txtMaPhieuNhap.Text.Trim() + ".doc";
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/msword";
            Response.ContentEncoding = Encoding.UTF8;
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + tenFile);
            Response.Write("\uFEFF" + TaoHtmlPhieuNhap());
            Response.End();
        }

        private void ChuyenCheDo(bool xemTruoc)
        {
            if (xemTruoc)
            {
                pnlNhapLieu.Style["display"] = "none";
                pnlXemTruoc.Style["display"] = "block";
            }
            else
            {
                pnlNhapLieu.Style["display"] = "block";
                pnlXemTruoc.Style["display"] = "none";
            }
        }

        private string DongThongTin(string nhan, string giaTri, bool encode)
        {
            string noiDung = giaTri;
            if (encode)
            {
                noiDung = Server.HtmlEncode(giaTri);
            }
            return "<div class='col-12 col-md-4'>" +
                   "<div class='small text-secondary mb-1'>" + Server.HtmlEncode(nhan) + "</div>" +
                   "<div class='fw-semibold text-dark'>" + noiDung + "</div>" +
                   "</div>";
        }

        private void HienThiThongBao(string message, string type)
        {
            string icon = "fa-circle-exclamation";
            if (type == "success")
            {
                icon = "fa-circle-check";
            }
            else if (type == "warning")
            {
                icon = "fa-triangle-exclamation";
            }

            lblThongBao.Text = "<div class='alert alert-" + type + " alert-dismissible fade show d-flex align-items-start shadow-sm' role='alert'>" +
                               "<i class='fa-solid " + icon + " me-2 mt-1'></i><div>" + Server.HtmlEncode(message) + "</div>" +
                               "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               "</div>";
        }
    }
}
