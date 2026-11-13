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
    public partial class PhieuXuat : System.Web.UI.Page
    {
        // Giới hạn hợp lý để tránh tràn số (cột TongTien là decimal(18,2))
        private const int SO_LUONG_TOI_DA = 1000000;
        private const decimal DON_GIA_TOI_DA = 1000000000m;
        private static readonly Regex MaPhieuHopLe = new Regex("^[A-Za-z0-9_-]{1,10}$");

        protected void Page_Load(object sender, EventArgs e)
        {
            // Chưa đăng nhập thì quay về trang đăng nhập
            if (Session["MaNhanVien"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Người lập phiếu chính là tài khoản đang đăng nhập (chỉ hiển thị, không cho chọn)
            txtNhanVien.Text = Convert.ToString(Session["HoTen"]) + " (" + Convert.ToString(Session["ChucVu"]) + ")";
            txtNgayXuat.Attributes["max"] = DateTime.Today.ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                txtNgayXuat.Text = DateTime.Today.ToString("yyyy-MM-dd");
                try
                {
                    LoadDropdownData();
                    txtMaPhieuXuat.Text = GoiYMaPhieu();
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
                KhoiTaoBangChiTiet();
            }

            DangKyBangGiaMacDinh();
        }

        // 1. Nạp dữ liệu danh mục cho các Dropdown
        private void LoadDropdownData()
        {
            // Chỉ liệt kê đơn đặt hàng chưa có phiếu xuất
            ddlDonHang.DataSource = DatabaseHelper.ExecuteQuery(
                "SELECT d.MaDonHang, d.MaDonHang + N' - ' + d.TenKhachHang AS TenHienThi " +
                "FROM DonDatHang d " +
                "WHERE NOT EXISTS (SELECT 1 FROM PhieuXuat p WHERE p.MaDonHang = d.MaDonHang) " +
                "ORDER BY d.NgayDatHang DESC");
            ddlDonHang.DataTextField = "TenHienThi";
            ddlDonHang.DataValueField = "MaDonHang";
            ddlDonHang.DataBind();
            ddlDonHang.Items.Insert(0, new ListItem("-- Xuất trực tiếp (không theo đơn) --", ""));

            // Hàng hóa kèm số lượng tồn khả dụng (chưa hết hạn)
            ddlHangHoa.DataSource = DatabaseHelper.ExecuteQuery(
                "SELECT h.MaHangHoa, " +
                "h.MaHangHoa + N' - ' + h.TenHangHoa + N'  (Tồn: ' + " +
                "CAST(ISNULL((SELECT SUM(t.SoLuongTon) FROM TonKho t WHERE t.MaHangHoa = h.MaHangHoa AND t.HanSuDung >= CAST(GETDATE() AS date)), 0) AS nvarchar(20)) " +
                "+ N' ' + h.DonViTinh + N')' AS TenHienThi " +
                "FROM HangHoa h ORDER BY h.MaHangHoa");
            ddlHangHoa.DataTextField = "TenHienThi";
            ddlHangHoa.DataValueField = "MaHangHoa";
            ddlHangHoa.DataBind();
            ddlHangHoa.Items.Insert(0, new ListItem("-- Chọn hàng hóa --", ""));
        }

        // Gợi ý mã phiếu kế tiếp (PX01, PX02, ...) - người dùng vẫn có thể sửa
        private string GoiYMaPhieu()
        {
            object kq = DatabaseHelper.ExecuteScalar(
                "SELECT ISNULL(MAX(CASE WHEN MaPhieuXuat LIKE 'PX[0-9]%' AND MaPhieuXuat NOT LIKE 'PX%[^0-9]%' " +
                "THEN CAST(SUBSTRING(MaPhieuXuat, 3, 8) AS int) END), 0) + 1 FROM PhieuXuat");
            int so = (kq == null || kq == DBNull.Value) ? 1 : Convert.ToInt32(kq);
            return "PX" + so.ToString("D2");
        }

        // Đưa bảng giá bán mặc định xuống trình duyệt để tự điền đơn giá khi chọn hàng
        private void DangKyBangGiaMacDinh()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT MaHangHoa, DonGia FROM HangHoa");
                StringBuilder sb = new StringBuilder("var giaMacDinh = {");
                foreach (DataRow r in dt.Rows)
                {
                    string ma = Convert.ToString(r["MaHangHoa"]).Replace("\\", "").Replace("'", "");
                    sb.Append("'").Append(ma).Append("':")
                      .Append(Convert.ToDecimal(r["DonGia"]).ToString("0.##", CultureInfo.InvariantCulture))
                      .Append(",");
                }
                sb.Append("};");
                ClientScript.RegisterStartupScript(GetType(), "giaMacDinh", sb.ToString(), true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
            }
        }

        // 2. Bảng tạm chi tiết xuất - dùng kiểu dữ liệu thật (int/decimal)
        private DataTable TaoBangChiTiet()
        {
            DataTable dt = new DataTable("ChiTietXuat");
            dt.Columns.Add("MaHangHoa", typeof(string));
            dt.Columns.Add("TenHangHoa", typeof(string));
            dt.Columns.Add("SoLuongXuat", typeof(int));
            dt.Columns.Add("DonGiaXuat", typeof(decimal));
            dt.Columns.Add("ThanhTien", typeof(decimal));
            return dt;
        }

        private void KhoiTaoBangChiTiet()
        {
            DataTable dt = TaoBangChiTiet();
            ViewState["ChiTietXuat"] = dt;
            HienThiBangTam(dt);
        }

        private DataTable LayBangChiTiet()
        {
            DataTable dt = ViewState["ChiTietXuat"] as DataTable;
            if (dt == null)
            {
                dt = TaoBangChiTiet();
                ViewState["ChiTietXuat"] = dt;
            }
            return dt;
        }

        // Bind bảng tạm và cập nhật dòng tổng cộng
        private void HienThiBangTam(DataTable dt)
        {
            gvChiTietPhieuXuat.DataSource = dt;
            gvChiTietPhieuXuat.DataBind();

            decimal tongTien = 0;
            int tongSL = 0;
            foreach (DataRow r in dt.Rows)
            {
                tongTien += Convert.ToDecimal(r["ThanhTien"]);
                tongSL += Convert.ToInt32(r["SoLuongXuat"]);
            }

            if (dt.Rows.Count == 0)
            {
                litTongTamTinh.Text = "";
            }
            else
            {
                litTongTamTinh.Text =
                    "<div class='d-flex flex-wrap justify-content-end align-items-center gap-3 mt-3 pt-3 border-top'>" +
                    "<span class='text-secondary small'>" + dt.Rows.Count + " mặt hàng &middot; " + tongSL.ToString("N0") + " sản phẩm</span>" +
                    "<span class='text-secondary fw-semibold'>Tạm tính:</span>" +
                    "<span class='fs-5 fw-bold text-primary'>" + tongTien.ToString("N0") + " đ</span>" +
                    "</div>";
            }
        }

        // Tồn khả dụng = tổng các lô còn hạn sử dụng
        private int LayTonKhaDung(string maHH)
        {
            object kq = DatabaseHelper.ExecuteScalar(
                "SELECT ISNULL(SUM(SoLuongTon), 0) FROM TonKho WHERE MaHangHoa = @Ma AND HanSuDung >= CAST(GETDATE() AS date)",
                new SqlParameter[] { new SqlParameter("@Ma", maHH) });
            return Convert.ToInt32(kq);
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
                    HienThiThongBao("Vui lòng chọn hàng hóa cần xuất kho!", "warning");
                    return;
                }

                int soLuong;
                if (!int.TryParse(txtSoLuongXuat.Text.Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out soLuong) || soLuong <= 0)
                {
                    HienThiThongBao("Số lượng xuất phải là số nguyên dương (từ 1 trở lên)!", "warning");
                    return;
                }
                if (soLuong > SO_LUONG_TOI_DA)
                {
                    HienThiThongBao("Số lượng xuất tối đa mỗi dòng là " + SO_LUONG_TOI_DA.ToString("N0") + "!", "warning");
                    return;
                }

                decimal donGia;
                if (!decimal.TryParse(txtDonGiaXuat.Text.Trim(), NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out donGia) || donGia <= 0)
                {
                    HienThiThongBao("Đơn giá xuất phải là số lớn hơn 0 (không được để trống hoặc âm)!", "warning");
                    return;
                }
                donGia = Math.Round(donGia, 2);
                if (donGia > DON_GIA_TOI_DA)
                {
                    HienThiThongBao("Đơn giá xuất tối đa là " + DON_GIA_TOI_DA.ToString("N0") + " đ!", "warning");
                    return;
                }

                DataTable dt = LayBangChiTiet();

                DataRow dongCu = null;
                foreach (DataRow r in dt.Rows)
                {
                    if (Convert.ToString(r["MaHangHoa"]) == maHang) { dongCu = r; break; }
                }

                int daCo = dongCu == null ? 0 : Convert.ToInt32(dongCu["SoLuongXuat"]);
                if (dongCu != null && Convert.ToDecimal(dongCu["DonGiaXuat"]) != donGia)
                {
                    HienThiThongBao("Hàng này đã có trong phiếu với đơn giá khác. Hãy xóa dòng cũ hoặc nhập cùng đơn giá để gộp số lượng.", "warning");
                    return;
                }
                if ((long)daCo + soLuong > SO_LUONG_TOI_DA)
                {
                    HienThiThongBao("Tổng số lượng của một mặt hàng tối đa là " + SO_LUONG_TOI_DA.ToString("N0") + "!", "warning");
                    return;
                }

                int tonKhaDung = LayTonKhaDung(maHang);
                if (daCo + soLuong > tonKhaDung)
                {
                    HienThiThongBao("Không đủ tồn kho cho \"" + ddlHangHoa.SelectedItem.Text.Split(new[] { "  (Tồn" }, StringSplitOptions.None)[0] +
                                    "\": tồn khả dụng " + tonKhaDung.ToString("N0") + ", trong phiếu đã có " + daCo.ToString("N0") +
                                    ", đang thêm " + soLuong.ToString("N0") + ".", "warning");
                    return;
                }

                if (dongCu != null)
                {
                    dongCu["SoLuongXuat"] = daCo + soLuong;
                    dongCu["ThanhTien"] = (daCo + soLuong) * donGia;
                }
                else
                {
                    string tenHang = ddlHangHoa.SelectedItem.Text.Split(new[] { "  (Tồn" }, StringSplitOptions.None)[0];
                    dt.Rows.Add(maHang, tenHang, soLuong, donGia, soLuong * donGia);
                }

                ViewState["ChiTietXuat"] = dt;
                HienThiBangTam(dt);

                ddlHangHoa.SelectedIndex = 0;
                txtSoLuongXuat.Text = "";
                txtDonGiaXuat.Text = "";
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
            }
        }

        // 4. Xóa dòng trong bảng chi tiết tạm
        protected void gvChiTietPhieuXuat_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "XoaDong") return;

            int rowIndex;
            DataTable dt = LayBangChiTiet();
            if (int.TryParse(Convert.ToString(e.CommandArgument), out rowIndex) && rowIndex >= 0 && rowIndex < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(rowIndex);
                ViewState["ChiTietXuat"] = dt;
                HienThiBangTam(dt);
            }
        }

        // 5. Kiểm tra toàn bộ phiếu
        private string KiemTraThongTinPhieu()
        {
            string maPX = txtMaPhieuXuat.Text.Trim();
            if (!MaPhieuHopLe.IsMatch(maPX))
                return "Mã phiếu xuất chỉ gồm chữ, số, dấu '-' hoặc '_' và dài tối đa 10 ký tự!";

            DateTime ngayXuat;
            if (!DateTime.TryParseExact(txtNgayXuat.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out ngayXuat)
                || ngayXuat < new DateTime(2000, 1, 1))
                return "Vui lòng chọn Ngày xuất hợp lệ!";
            if (ngayXuat.Date > DateTime.Today)
                return "Ngày xuất không được ở tương lai!";

            if (string.IsNullOrEmpty(ddlTrangThai.SelectedValue))
                return "Vui lòng chọn Trạng thái thanh toán!";

            object nv = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM NguoiDung WHERE MaNhanVien = @MaNV",
                new SqlParameter[] { new SqlParameter("@MaNV", Convert.ToString(Session["MaNhanVien"])) });
            if (Convert.ToInt32(nv) == 0)
                return "Tài khoản đăng nhập không còn hợp lệ. Vui lòng đăng nhập lại!";

            DataTable dtChiTiet = LayBangChiTiet();
            if (dtChiTiet.Rows.Count == 0)
                return "Phiếu xuất chưa có sản phẩm nào! Vui lòng thêm ít nhất một mặt hàng.";

            object trung = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM PhieuXuat WHERE MaPhieuXuat = @MaPX",
                new SqlParameter[] { new SqlParameter("@MaPX", maPX) });
            if (Convert.ToInt32(trung) > 0)
                return "Mã phiếu xuất \"" + maPX + "\" đã tồn tại! Vui lòng nhập mã khác.";

            if (!string.IsNullOrEmpty(ddlDonHang.SelectedValue))
            {
                object daXuat = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM PhieuXuat WHERE MaDonHang = @MaDH",
                    new SqlParameter[] { new SqlParameter("@MaDH", ddlDonHang.SelectedValue) });
                if (Convert.ToInt32(daXuat) > 0)
                    return "Đơn đặt hàng này đã được lập phiếu xuất trước đó!";
            }

            foreach (DataRow r in dtChiTiet.Rows)
            {
                string ma = Convert.ToString(r["MaHangHoa"]);
                int can = Convert.ToInt32(r["SoLuongXuat"]);
                int ton = LayTonKhaDung(ma);
                if (can > ton)
                    return "Hàng \"" + Convert.ToString(r["TenHangHoa"]) + "\" không đủ tồn kho (cần " + can.ToString("N0") + ", còn " + ton.ToString("N0") + ")!";
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
                decimal tongTien = 0;
                int tongSL = 0;
                foreach (DataRow r in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(r["ThanhTien"]);
                    tongSL += Convert.ToInt32(r["SoLuongXuat"]);
                }

                gvXemTruoc.DataSource = dtChiTiet;
                gvXemTruoc.DataBind();

                string donHang = string.IsNullOrEmpty(ddlDonHang.SelectedValue)
                    ? "Xuất trực tiếp (không theo đơn đặt hàng)"
                    : ddlDonHang.SelectedItem.Text;

                DateTime ngayXuat = DateTime.ParseExact(txtNgayXuat.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
                string trangThai = ddlTrangThai.SelectedValue;
                string badge = trangThai == "Đã thanh toán"
                    ? "<span class='badge bg-success'>" + Server.HtmlEncode(trangThai) + "</span>"
                    : "<span class='badge bg-warning text-dark'>" + Server.HtmlEncode(trangThai) + "</span>";

                litThongTinXemTruoc.Text =
                    "<div class='row g-3'>" +
                    DongThongTin("Mã phiếu xuất", txtMaPhieuXuat.Text.Trim(), true) +
                    DongThongTin("Ngày xuất", ngayXuat.ToString("dd/MM/yyyy"), true) +
                    DongThongTin("Người lập phiếu", Convert.ToString(Session["HoTen"]), true) +
                    DongThongTin("Đơn đặt hàng", donHang, true) +
                    DongThongTin("Số mặt hàng / Tổng số lượng", dtChiTiet.Rows.Count + " mặt hàng / " + tongSL.ToString("N0") + " sản phẩm", true) +
                    DongThongTin("Trạng thái thanh toán", badge, false) +
                    "</div>";

                litTongTienXemTruoc.Text = tongTien.ToString("N0") + " đ";
                litMaPhieuHeader.Text = Server.HtmlEncode(txtMaPhieuXuat.Text.Trim());
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

        // 8. Xác nhận lập phiếu: ghi phiếu + chi tiết + trừ tồn kho trong MỘT transaction
        protected void btnLuuPhieuXuat_Click(object sender, EventArgs e)
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

                string maPX = txtMaPhieuXuat.Text.Trim();
                string maNV = Convert.ToString(Session["MaNhanVien"]);
                string trangThai = ddlTrangThai.SelectedValue;
                string maDonHang = string.IsNullOrEmpty(ddlDonHang.SelectedValue) ? null : ddlDonHang.SelectedValue;
                DateTime ngayXuat = DateTime.ParseExact(txtNgayXuat.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
                DataTable dtChiTiet = LayBangChiTiet();

                decimal tongTien = 0;
                foreach (DataRow r in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(r["SoLuongXuat"]) * Convert.ToDecimal(r["DonGiaXuat"]);
                }

                DatabaseHelper.ExecuteTransaction((conn, tran) =>
                {
                    // A. Phiếu xuất
                    using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                        "INSERT INTO PhieuXuat (MaPhieuXuat, NgayXuat, TongTien, TrangThaiThanhToan, MaDonHang, MaNhanVien) " +
                        "VALUES (@MaPX, @NgayXuat, @TongTien, @TrangThai, @MaDonHang, @MaNV)",
                        new SqlParameter("@MaPX", maPX),
                        new SqlParameter("@NgayXuat", ngayXuat),
                        new SqlParameter("@TongTien", tongTien),
                        new SqlParameter("@TrangThai", trangThai),
                        new SqlParameter("@MaDonHang", maDonHang == null ? (object)DBNull.Value : maDonHang),
                        new SqlParameter("@MaNV", maNV)))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // B. Chi tiết + trừ tồn kho từng mặt hàng
                    foreach (DataRow r in dtChiTiet.Rows)
                    {
                        string maHH = Convert.ToString(r["MaHangHoa"]);
                        string tenHH = Convert.ToString(r["TenHangHoa"]);
                        int sl = Convert.ToInt32(r["SoLuongXuat"]);
                        decimal dg = Convert.ToDecimal(r["DonGiaXuat"]);

                        using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                            "INSERT INTO ChiTietPhieuXuat (MaPhieuXuat, MaHangHoa, SoLuongXuat, DonGiaXuat) VALUES (@MaPX, @MaHH, @SL, @DG)",
                            new SqlParameter("@MaPX", maPX),
                            new SqlParameter("@MaHH", maHH),
                            new SqlParameter("@SL", sl),
                            new SqlParameter("@DG", dg)))
                        {
                            cmd.ExecuteNonQuery();
                        }

                        TruTonKho(conn, tran, maHH, tenHH, sl);
                    }

                    // C. Đánh dấu đơn đặt hàng đã xuất kho
                    if (maDonHang != null)
                    {
                        using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                            "UPDATE DonDatHang SET TrangThai = N'Đã xuất kho' WHERE MaDonHang = @MaDH",
                            new SqlParameter("@MaDH", maDonHang)))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                });

                KhoiTaoBangChiTiet();
                LoadDropdownData();
                txtMaPhieuXuat.Text = GoiYMaPhieu();
                ChuyenCheDo(false);
                HienThiThongBao("Lập phiếu xuất kho thành công! Tồn kho đã được cập nhật.", "success");
            }
            catch (Exception ex)
            {
                ChuyenCheDo(false);
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
            }
        }

        // Trừ tồn theo nguyên tắc FEFO
        private void TruTonKho(SqlConnection conn, SqlTransaction tran, string maHH, string tenHH, int canXuat)
        {
            DataTable cacLo = new DataTable();
            using (SqlCommand cmd = DatabaseHelper.TaoLenh(conn, tran,
                "SELECT HanSuDung, SoLuongTon FROM TonKho WITH (UPDLOCK, ROWLOCK) " +
                "WHERE MaHangHoa = @Ma AND SoLuongTon > 0 AND HanSuDung >= CAST(GETDATE() AS date) " +
                "ORDER BY HanSuDung",
                new SqlParameter("@Ma", maHH)))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                da.Fill(cacLo);
            }

            int conLai = canXuat;
            foreach (DataRow lo in cacLo.Rows)
            {
                if (conLai <= 0) break;

                int ton = Convert.ToInt32(lo["SoLuongTon"]);
                int tru = Math.Min(ton, conLai);

                using (SqlCommand up = DatabaseHelper.TaoLenh(conn, tran,
                    "UPDATE TonKho SET SoLuongTon = SoLuongTon - @Tru WHERE MaHangHoa = @Ma AND HanSuDung = @Han",
                    new SqlParameter("@Tru", tru),
                    new SqlParameter("@Ma", maHH),
                    new SqlParameter("@Han", Convert.ToDateTime(lo["HanSuDung"]))))
                {
                    up.ExecuteNonQuery();
                }
                conLai -= tru;
            }

            if (conLai > 0)
            {
                throw new NghiepVuException("Hàng \"" + tenHH + "\" không đủ tồn kho (cần " + canXuat.ToString("N0") +
                                            ", chỉ còn " + (canXuat - conLai).ToString("N0") + "). Phiếu chưa được lưu.");
            }
        }

        // 9. Xuất file Excel & Word từ bản xem trước
        private string TaoHtmlPhieuXuat()
        {
            DataTable dtChiTiet = LayBangChiTiet();
            DateTime ngayXuat = DateTime.ParseExact(txtNgayXuat.Text.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture);
            string maPX = Server.HtmlEncode(txtMaPhieuXuat.Text.Trim());
            string donHang = string.IsNullOrEmpty(ddlDonHang.SelectedValue)
                ? "Xuất trực tiếp (không theo đơn đặt hàng)"
                : Server.HtmlEncode(ddlDonHang.SelectedItem.Text);
            string nguoiLap = Server.HtmlEncode(Convert.ToString(Session["HoTen"]));
            string trangThai = Server.HtmlEncode(ddlTrangThai.SelectedValue);

            decimal tongTien = 0;
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8' /></head><body style='font-family: Times New Roman, Arial, sans-serif; font-size: 13pt;'>");
            sb.Append("<table width='100%' border='0'><tr>");
            sb.Append("<td><b>HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHO)</b><br/><i>Bộ phận Kho vận &amp; Xuất hàng</i></td>");
            sb.Append("<td align='right'><b>Mẫu số: 02 - VT</b><br/>Ngày xuất file: " + DateTime.Now.ToString("dd/MM/yyyy HH:mm") + "</td>");
            sb.Append("</tr></table>");

            sb.Append("<h2 align='center' style='margin-bottom:4px;'>PHIẾU XUẤT KHO</h2>");
            sb.Append("<p align='center' style='margin-top:0;'>Số phiếu: <b>" + maPX + "</b> &nbsp;|&nbsp; Ngày xuất: <b>" + ngayXuat.ToString("dd/MM/yyyy") + "</b></p>");

            sb.Append("<table width='100%' border='0' cellpadding='4' style='margin-bottom:10px;'>");
            sb.Append("<tr><td width='50%'><b>Đơn đặt hàng:</b> " + donHang + "</td><td width='50%'><b>Người lập phiếu:</b> " + nguoiLap + "</td></tr>");
            sb.Append("<tr><td><b>Trạng thái thanh toán:</b> " + trangThai + "</td><td></td></tr>");
            sb.Append("</table>");

            sb.Append("<table width='100%' border='1' cellspacing='0' cellpadding='6' style='border-collapse:collapse;'>");
            sb.Append("<tr style='background-color:#e2e8f0; font-weight:bold; text-align:center;'>");
            sb.Append("<th>STT</th><th>Mã Hàng</th><th>Tên Hàng Hóa</th><th>Số Lượng</th><th>Đơn Giá (đ)</th><th>Thành Tiền (đ)</th>");
            sb.Append("</tr>");

            int stt = 1;
            foreach (DataRow r in dtChiTiet.Rows)
            {
                decimal thanhTien = Convert.ToDecimal(r["ThanhTien"]);
                tongTien += thanhTien;
                sb.Append("<tr>");
                sb.Append("<td align='center'>" + stt++ + "</td>");
                sb.Append("<td align='center'>" + Server.HtmlEncode(Convert.ToString(r["MaHangHoa"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["TenHangHoa"])) + "</td>");
                sb.Append("<td align='right'>" + Convert.ToInt32(r["SoLuongXuat"]).ToString("N0") + "</td>");
                sb.Append("<td align='right'>" + Convert.ToDecimal(r["DonGiaXuat"]).ToString("N0") + "</td>");
                sb.Append("<td align='right'><b>" + thanhTien.ToString("N0") + "</b></td>");
                sb.Append("</tr>");
            }

            sb.Append("<tr><td colspan='5' align='right'><b>TỔNG CỘNG THANH TOÁN:</b></td><td align='right'><b>" + tongTien.ToString("N0") + " đ</b></td></tr>");
            sb.Append("</table><br/><br/>");

            sb.Append("<table width='100%' border='0' style='text-align:center;'><tr>");
            sb.Append("<td width='33%'><b>Người lập phiếu</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/><b>" + nguoiLap + "</b></td>");
            sb.Append("<td width='33%'><b>Người nhận hàng</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/></td>");
            sb.Append("<td width='33%'><b>Thủ kho / Kế toán</b><br/><i>(Ký, họ tên)</i><br/><br/><br/><br/></td>");
            sb.Append("</tr></table>");
            sb.Append("</body></html>");
            return sb.ToString();
        }

        protected void btnXuatExcel_Click(object sender, EventArgs e)
        {
            string loi = KiemTraThongTinPhieu();
            if (loi != null) { HienThiThongBao(loi, "danger"); return; }

            string tenFile = "PhieuXuat_" + txtMaPhieuXuat.Text.Trim() + ".xls";
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.ContentEncoding = Encoding.UTF8;
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + tenFile);
            Response.Write("\uFEFF" + TaoHtmlPhieuXuat());
            Response.End();
        }

        protected void btnXuatWord_Click(object sender, EventArgs e)
        {
            string loi = KiemTraThongTinPhieu();
            if (loi != null) { HienThiThongBao(loi, "danger"); return; }

            string tenFile = "PhieuXuat_" + txtMaPhieuXuat.Text.Trim() + ".doc";
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/msword";
            Response.ContentEncoding = Encoding.UTF8;
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + tenFile);
            Response.Write("\uFEFF" + TaoHtmlPhieuXuat());
            Response.End();
        }

        // Chỉ ẩn/hiện bằng CSS để các ô nhập vẫn được gửi lên server và giữ nguyên giá trị
        private void ChuyenCheDo(bool xemTruoc)
        {
            pnlNhapLieu.Style["display"] = xemTruoc ? "none" : "block";
            pnlXemTruoc.Style["display"] = xemTruoc ? "block" : "none";
        }

        // Ô thông tin trong khung xem trước
        private string DongThongTin(string nhan, string giaTri, bool encode)
        {
            return "<div class='col-12 col-md-4'>" +
                   "<div class='small text-secondary mb-1'>" + Server.HtmlEncode(nhan) + "</div>" +
                   "<div class='fw-semibold text-dark'>" + (encode ? Server.HtmlEncode(giaTri) : giaTri) + "</div>" +
                   "</div>";
        }

        // Hiển thị thông báo
        private void HienThiThongBao(string message, string type)
        {
            string icon = type == "success" ? "fa-circle-check"
                        : type == "warning" ? "fa-triangle-exclamation"
                        : "fa-circle-exclamation";

            lblThongBao.Text = "<div class='alert alert-" + type + " alert-dismissible fade show d-flex align-items-start' role='alert'>" +
                               "<i class='fa-solid " + icon + " me-2 mt-1'></i><div>" + Server.HtmlEncode(message) + "</div>" +
                               "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               "</div>";
        }
    }
}
