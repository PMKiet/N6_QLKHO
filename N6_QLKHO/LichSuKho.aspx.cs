using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class LichSuKho : System.Web.UI.Page
    {
        // Mã phiếu hợp lệ (chống dữ liệu lạ gửi lên từ ô tick / nút lệnh)
        private static readonly Regex MaHopLe = new Regex("^[A-Za-z0-9_-]{1,10}$");

        // Dữ liệu một phiếu (đầu phiếu + chi tiết) dùng cho xem / in / xuất file
        private class PhieuData
        {
            public bool Nhap;
            public string Ma;
            public DateTime Ngay;
            public string DoiTac;
            public string NhanVien;
            public string TrangThai;
            public decimal TongTien;
            public DataTable ChiTiet;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["MaNhanVien"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDuLieu();
            }
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            lblThongBao.Text = "";
            LoadDuLieu();
        }

        // ================= TRUY VẤN DANH SÁCH =================

        private bool ParseNgay(string s, out DateTime d)
        {
            d = DateTime.MinValue;
            s = (s ?? "").Trim();
            if (s == "") return false;
            if (!DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d) || d.Year < 1900)
                throw new NghiepVuException("Ngày lọc không hợp lệ.");
            return true;
        }

        // Một hàm dùng chung cho lưới dữ liệu và xuất file.
        // chon != null: chỉ lấy các mã phiếu được tick.
        private DataTable TruyVan(bool nhap, string[] chon)
        {
            string tuKhoa = txtTuKhoa.Text.Trim();
            DateTime tuNgay, denNgay;
            bool coTu = ParseNgay(txtTuNgay.Text, out tuNgay);
            bool coDen = ParseNgay(txtDenNgay.Text, out denNgay);
            if (coTu && coDen && tuNgay > denNgay)
                throw new NghiepVuException("\"Từ ngày\" không được sau \"Đến ngày\".");

            string cotMa = nhap ? "pn.MaPhieuNhap" : "px.MaPhieuXuat";
            string cotNgay = nhap ? "pn.NgayNhap" : "px.NgayXuat";
            string cotDoiTac = nhap ? "ncc.TenNCC" : "ddh.TenKhachHang";

            StringBuilder q = new StringBuilder();
            if (nhap)
            {
                q.Append("SELECT pn.MaPhieuNhap AS MaPhieu, pn.NgayNhap AS Ngay, ncc.TenNCC AS DoiTac, nd.HoTen AS NhanVien, pn.TrangThaiThanhToan, " +
                         "ISNULL((SELECT SUM(ct.SoLuongNhap * ct.DonGiaNhap) FROM ChiTietPhieuNhap ct WHERE ct.MaPhieuNhap = pn.MaPhieuNhap), pn.TongTien) AS TongTien ");
                q.Append("FROM PhieuNhap pn JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC JOIN NguoiDung nd ON pn.MaNhanVien = nd.MaNhanVien ");
            }
            else
            {
                q.Append("SELECT px.MaPhieuXuat AS MaPhieu, px.NgayXuat AS Ngay, ISNULL(ddh.TenKhachHang, N'Khách lẻ / Trực tiếp') AS DoiTac, nd.HoTen AS NhanVien, px.TrangThaiThanhToan, " +
                         "ISNULL((SELECT SUM(ct.SoLuongXuat * ct.DonGiaXuat) FROM ChiTietPhieuXuat ct WHERE ct.MaPhieuXuat = px.MaPhieuXuat), px.TongTien) AS TongTien ");
                q.Append("FROM PhieuXuat px LEFT JOIN DonDatHang ddh ON px.MaDonHang = ddh.MaDonHang JOIN NguoiDung nd ON px.MaNhanVien = nd.MaNhanVien ");
            }
            q.Append("WHERE 1 = 1");

            List<SqlParameter> ps = new List<SqlParameter>();

            if (tuKhoa != "")
            {
                q.Append(" AND (" + cotMa + " LIKE @TuKhoa OR " + cotDoiTac + " LIKE @TuKhoa OR nd.HoTen LIKE @TuKhoa)");
                ps.Add(new SqlParameter("@TuKhoa", "%" + tuKhoa + "%"));
            }
            if (coTu)
            {
                q.Append(" AND " + cotNgay + " >= @TuNgay");
                ps.Add(new SqlParameter("@TuNgay", tuNgay));
            }
            if (coDen)
            {
                q.Append(" AND " + cotNgay + " < @DenNgay");
                ps.Add(new SqlParameter("@DenNgay", denNgay.AddDays(1)));
            }
            if (chon != null && chon.Length > 0)
            {
                List<string> tenThamSo = new List<string>();
                for (int i = 0; i < chon.Length; i++)
                {
                    string ten = "@Chon" + i;
                    tenThamSo.Add(ten);
                    ps.Add(new SqlParameter(ten, chon[i]));
                }
                q.Append(" AND " + cotMa + " IN (" + string.Join(", ", tenThamSo.ToArray()) + ")");
            }

            q.Append(" ORDER BY " + cotNgay + " DESC");
            return DatabaseHelper.ExecuteQuery(q.ToString(), ps.ToArray());
        }

        private void LoadDuLieu()
        {
            try
            {
                gvPhieuNhap.DataSource = TruyVan(true, null);
                gvPhieuNhap.DataBind();
                gvPhieuXuat.DataSource = TruyVan(false, null);
                gvPhieuXuat.DataBind();
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), ex is NghiepVuException ? "warning" : "danger");
            }
        }

        // Đọc các ô tick từ form (name = chkNhap / chkXuat). Trả về null nếu không tick phiếu nào.
        private string[] LayChon(string tenO)
        {
            string[] raw = Request.Form.GetValues(tenO);
            if (raw == null) return null;

            List<string> ds = new List<string>();
            foreach (string s in raw)
            {
                string ma = (s ?? "").Trim();
                if (MaHopLe.IsMatch(ma) && !ds.Contains(ma)) ds.Add(ma);
                if (ds.Count >= 200) break;
            }
            return ds.Count == 0 ? null : ds.ToArray();
        }

        // ================= THAO TÁC TRÊN DÒNG =================

        protected void gvPhieuNhap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string maPhieuNhap = Convert.ToString(e.CommandArgument);
            if (!MaHopLe.IsMatch(maPhieuNhap)) return;

            if (e.CommandName == "InPhieuNhap")
            {
                MoChiTiet(true, maPhieuNhap);
            }
            else if (e.CommandName == "XoaPhieuNhap")
            {
                try
                {
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM PhieuNhap WHERE MaPhieuNhap = @Ma", new SqlParameter[] { new SqlParameter("@Ma", maPhieuNhap) });
                    LoadDuLieu();
                    HienThiThongBao("Đã xóa phiếu nhập " + maPhieuNhap + " thành công.", "success");
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
            }
            else if (e.CommandName == "DoiTrangThaiNhap")
            {
                try
                {
                    object currentStatus = DatabaseHelper.ExecuteScalar("SELECT TrangThaiThanhToan FROM PhieuNhap WHERE MaPhieuNhap = @Ma", new SqlParameter[] { new SqlParameter("@Ma", maPhieuNhap) });
                    string newStatus = "Đã thanh toán";
                    if (currentStatus != null && currentStatus.ToString() == "Đã thanh toán")
                    {
                        newStatus = "Chưa thanh toán";
                    }

                    DatabaseHelper.ExecuteNonQuery("UPDATE PhieuNhap SET TrangThaiThanhToan = @TrangThai WHERE MaPhieuNhap = @Ma", new SqlParameter[]
                    {
                        new SqlParameter("@TrangThai", newStatus),
                        new SqlParameter("@Ma", maPhieuNhap)
                    });
                    LoadDuLieu();
                    HienThiThongBao("Đã cập nhật trạng thái thanh toán cho phiếu " + maPhieuNhap + ".", "success");
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
            }
        }

        protected void gvPhieuXuat_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string maPhieuXuat = Convert.ToString(e.CommandArgument);
            if (!MaHopLe.IsMatch(maPhieuXuat)) return;

            if (e.CommandName == "InPhieuXuat")
            {
                MoChiTiet(false, maPhieuXuat);
            }
            else if (e.CommandName == "XoaPhieuXuat")
            {
                try
                {
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM PhieuXuat WHERE MaPhieuXuat = @Ma", new SqlParameter[] { new SqlParameter("@Ma", maPhieuXuat) });
                    LoadDuLieu();
                    HienThiThongBao("Đã xóa phiếu xuất " + maPhieuXuat + " thành công.", "success");
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
            }
            else if (e.CommandName == "DoiTrangThaiXuat")
            {
                try
                {
                    object currentStatus = DatabaseHelper.ExecuteScalar("SELECT TrangThaiThanhToan FROM PhieuXuat WHERE MaPhieuXuat = @Ma", new SqlParameter[] { new SqlParameter("@Ma", maPhieuXuat) });
                    string newStatus = "Đã thanh toán";
                    if (currentStatus != null && currentStatus.ToString() == "Đã thanh toán")
                    {
                        newStatus = "Chưa thanh toán";
                    }

                    DatabaseHelper.ExecuteNonQuery("UPDATE PhieuXuat SET TrangThaiThanhToan = @TrangThai WHERE MaPhieuXuat = @Ma", new SqlParameter[]
                    {
                        new SqlParameter("@TrangThai", newStatus),
                        new SqlParameter("@Ma", maPhieuXuat)
                    });
                    LoadDuLieu();
                    HienThiThongBao("Đã cập nhật trạng thái thanh toán cho phiếu " + maPhieuXuat + ".", "success");
                }
                catch (Exception ex)
                {
                    HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
            }
        }

        // ================= XEM CHI TIẾT / IN MỘT PHIẾU =================

        private PhieuData LayPhieu(bool nhap, string ma)
        {
            SqlParameter[] p = new SqlParameter[] { new SqlParameter("@Ma", ma) };
            DataTable dauPhieu;
            DataTable chiTiet;

            if (nhap)
            {
                dauPhieu = DatabaseHelper.ExecuteQuery(
                    "SELECT pn.MaPhieuNhap AS MaPhieu, pn.NgayNhap AS Ngay, ncc.TenNCC AS DoiTac, nd.HoTen AS NhanVien, pn.TrangThaiThanhToan, pn.TongTien " +
                    "FROM PhieuNhap pn JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC JOIN NguoiDung nd ON pn.MaNhanVien = nd.MaNhanVien " +
                    "WHERE pn.MaPhieuNhap = @Ma", p);
                chiTiet = DatabaseHelper.ExecuteQuery(
                    "SELECT ct.MaHangHoa, hh.TenHangHoa, hh.DonViTinh, ct.SoLuongNhap AS SoLuong, ct.DonGiaNhap AS DonGia, ct.HanSuDungLo, ct.SoLuongNhap * ct.DonGiaNhap AS ThanhTien " +
                    "FROM ChiTietPhieuNhap ct JOIN HangHoa hh ON ct.MaHangHoa = hh.MaHangHoa " +
                    "WHERE ct.MaPhieuNhap = @Ma ORDER BY ct.MaHangHoa",
                    new SqlParameter[] { new SqlParameter("@Ma", ma) });
            }
            else
            {
                dauPhieu = DatabaseHelper.ExecuteQuery(
                    "SELECT px.MaPhieuXuat AS MaPhieu, px.NgayXuat AS Ngay, ISNULL(ddh.TenKhachHang, N'Khách lẻ / Trực tiếp') AS DoiTac, nd.HoTen AS NhanVien, px.TrangThaiThanhToan, px.TongTien " +
                    "FROM PhieuXuat px LEFT JOIN DonDatHang ddh ON px.MaDonHang = ddh.MaDonHang JOIN NguoiDung nd ON px.MaNhanVien = nd.MaNhanVien " +
                    "WHERE px.MaPhieuXuat = @Ma", p);
                chiTiet = DatabaseHelper.ExecuteQuery(
                    "SELECT ct.MaHangHoa, hh.TenHangHoa, hh.DonViTinh, ct.SoLuongXuat AS SoLuong, ct.DonGiaXuat AS DonGia, ct.SoLuongXuat * ct.DonGiaXuat AS ThanhTien " +
                    "FROM ChiTietPhieuXuat ct JOIN HangHoa hh ON ct.MaHangHoa = hh.MaHangHoa " +
                    "WHERE ct.MaPhieuXuat = @Ma ORDER BY ct.MaHangHoa",
                    new SqlParameter[] { new SqlParameter("@Ma", ma) });
            }

            if (dauPhieu.Rows.Count == 0)
                throw new NghiepVuException("Không tìm thấy phiếu " + ma + " (có thể đã bị xóa).");

            DataRow h = dauPhieu.Rows[0];
            decimal tongChiTiet = 0m;
            foreach (DataRow r in chiTiet.Rows)
            {
                tongChiTiet += Convert.ToDecimal(r["ThanhTien"]);
            }
            decimal tongTienHienThi = chiTiet.Rows.Count > 0 ? tongChiTiet : Convert.ToDecimal(h["TongTien"]);

            return new PhieuData
            {
                Nhap = nhap,
                Ma = Convert.ToString(h["MaPhieu"]),
                Ngay = Convert.ToDateTime(h["Ngay"]),
                DoiTac = Convert.ToString(h["DoiTac"]),
                NhanVien = Convert.ToString(h["NhanVien"]),
                TrangThai = Convert.ToString(h["TrangThaiThanhToan"]),
                TongTien = tongTienHienThi,
                ChiTiet = chiTiet
            };
        }

        private void MoChiTiet(bool nhap, string ma)
        {
            try
            {
                PhieuData d = LayPhieu(nhap, ma);
                litPhieu.Text = TaoHtmlManHinh(d);
                ViewState["PhieuDangXem"] = (nhap ? "N:" : "X:") + ma;
                lblThongBao.Text = "";
                ChuyenCheDo(true);
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), ex is NghiepVuException ? "warning" : "danger");
            }
        }

        protected void btnQuayLai_Click(object sender, EventArgs e)
        {
            ChuyenCheDo(false);
        }

        // Hiển thị phiếu để xem / in: cùng khung với màn hình xem trước ở PhieuNhap / PhieuXuat
        private string TaoHtmlManHinh(PhieuData d)
        {
            string tieuDe = d.Nhap ? "PHIẾU NHẬP KHO" : "PHIẾU XUẤT KHO";
            string nhanDoiTac = d.Nhap ? "Nhà cung cấp" : "Khách hàng / Đơn hàng";
            string mauSo = d.Nhap ? "01 - VT" : "02 - VT";
            string boPhan = d.Nhap ? "Bộ phận Kho vận &amp; Cung ứng vật tư" : "Bộ phận Kho vận &amp; Xuất hàng";
            string badge = "<span class='badge " + (d.TrangThai == "Đã thanh toán" ? "bg-success" : "bg-warning text-dark") + "'>" +
                           Server.HtmlEncode(d.TrangThai) + "</span>";

            int tongSL = 0;
            foreach (DataRow r in d.ChiTiet.Rows) tongSL += Convert.ToInt32(r["SoLuong"]);

            StringBuilder sb = new StringBuilder();
            sb.Append("<div class='phieu-in wms-card bg-white'><div class='card-body p-4 p-md-5'>");

            // Đầu phiếu
            sb.Append("<div class='row border-bottom pb-3 mb-4 align-items-center'>" +
                      "<div class='col-7'><div class='fw-bold text-uppercase text-primary fs-6'>HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHO)</div>" +
                      "<div class='text-muted small'>" + boPhan + "</div></div>" +
                      "<div class='col-5 text-end'><div class='fw-bold small'>Mẫu số: " + mauSo + "</div>" +
                      "<div class='text-muted small'>Ngày in: " + DateTime.Now.ToString("dd/MM/yyyy HH:mm") + "</div></div></div>");

            sb.Append("<div class='text-center mb-4'><h4 class='fw-bold text-uppercase text-dark mb-1'>" + tieuDe + "</h4>" +
                      "<div class='text-muted small'>Số phiếu: <strong>" + Server.HtmlEncode(d.Ma) + "</strong></div></div>");

            // Khối thông tin
            sb.Append("<div class='bg-light rounded-3 p-3 mb-4 border'><div class='row g-3'>");
            sb.Append(OThongTin(d.Nhap ? "Mã phiếu nhập" : "Mã phiếu xuất", Server.HtmlEncode(d.Ma)));
            sb.Append(OThongTin(d.Nhap ? "Ngày nhập" : "Ngày xuất", d.Ngay.ToString("dd/MM/yyyy")));
            sb.Append(OThongTin("Người lập phiếu", Server.HtmlEncode(d.NhanVien)));
            sb.Append(OThongTin(nhanDoiTac, Server.HtmlEncode(d.DoiTac)));
            sb.Append(OThongTin("Số mặt hàng / Tổng số lượng", d.ChiTiet.Rows.Count + " mặt hàng / " + tongSL.ToString("N0") + " sản phẩm"));
            sb.Append(OThongTin("Trạng thái thanh toán", badge));
            sb.Append("</div></div>");

            // Bảng hàng hóa
            sb.Append("<div class='table-responsive'><table class='table table-bordered table-custom mb-0 align-middle'>");
            sb.Append("<thead><tr><th class='text-center col-nowrap'>STT</th><th class='col-nowrap'>Mã Hàng</th><th>Tên Hàng Hóa</th><th class='col-nowrap'>ĐVT</th>" +
                      "<th class='text-end col-nowrap'>Số Lượng</th><th class='text-end col-nowrap'>Đơn Giá (VND)</th>" +
                      (d.Nhap ? "<th class='text-center col-nowrap'>Hạn Dùng Lô</th>" : "") +
                      "<th class='text-end col-nowrap'>Thành Tiền (VND)</th></tr></thead><tbody>");

            int stt = 0;
            foreach (DataRow r in d.ChiTiet.Rows)
            {
                stt++;
                sb.Append("<tr>");
                sb.Append("<td class='text-center col-nowrap tabular-nums'>" + stt + "</td>");
                sb.Append("<td class='col-nowrap fw-semibold'>" + Server.HtmlEncode(Convert.ToString(r["MaHangHoa"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["TenHangHoa"])) + "</td>");
                sb.Append("<td class='col-nowrap'>" + Server.HtmlEncode(Convert.ToString(r["DonViTinh"])) + "</td>");
                sb.Append("<td class='text-end col-nowrap tabular-nums'>" + Convert.ToInt32(r["SoLuong"]).ToString("N0") + "</td>");
                sb.Append("<td class='text-end col-nowrap tabular-nums'>" + Convert.ToDecimal(r["DonGia"]).ToString("N0") + " VND</td>");
                if (d.Nhap)
                    sb.Append("<td class='text-center col-nowrap tabular-nums'>" + Convert.ToDateTime(r["HanSuDungLo"]).ToString("dd/MM/yyyy") + "</td>");
                sb.Append("<td class='text-end fw-semibold col-nowrap tabular-nums'>" + Convert.ToDecimal(r["ThanhTien"]).ToString("N0") + " VND</td>");
                sb.Append("</tr>");
            }
            if (d.ChiTiet.Rows.Count == 0)
                sb.Append("<tr><td colspan='" + (d.Nhap ? 8 : 7) + "' class='text-center text-muted py-4'>Phiếu này chưa có chi tiết hàng hóa.</td></tr>");
            sb.Append("</tbody></table></div>");

            // Tổng tiền
            sb.Append("<div class='d-flex justify-content-end align-items-center gap-3 mt-3 pt-3 border-top'>" +
                      "<span class='text-secondary fw-semibold'>Tổng tiền thanh toán:</span>" +
                      "<span class='fs-4 fw-bold tabular-nums " + (d.Nhap ? "text-success" : "text-primary") + "'>" + d.TongTien.ToString("N0") + " VND</span></div>");

            // Chữ ký
            sb.Append("<div class='row text-center mt-5 pt-3'>" +
                      OChuKy("Người lập phiếu", d.NhanVien) +
                      OChuKy(d.Nhap ? "Người giao hàng (NCC)" : "Người nhận hàng", "") +
                      OChuKy("Thủ kho / Kế toán", "") +
                      "</div>");

            sb.Append("</div></div>");
            return sb.ToString();
        }

        private string OThongTin(string nhan, string giaTriHtml)
        {
            return "<div class='col-12 col-md-4'><div class='small text-secondary mb-1'>" + Server.HtmlEncode(nhan) +
                   "</div><div class='fw-semibold text-dark'>" + giaTriHtml + "</div></div>";
        }

        private string OChuKy(string chucDanh, string ten)
        {
            return "<div class='col-4'><div class='fw-bold small'>" + Server.HtmlEncode(chucDanh) + "</div>" +
                   "<div class='text-muted fst-italic small'>(Ký, họ tên)</div>" +
                   "<div class='sig-space'></div><div class='fw-semibold small'>" + Server.HtmlEncode(ten) + "</div></div>";
        }

        // ================= XUẤT FILE 1 PHIẾU (từ màn hình chi tiết) =================

        protected void btnXuatExcelPhieu_Click(object sender, EventArgs e)
        {
            XuatPhieu(true);
        }

        protected void btnXuatWordPhieu_Click(object sender, EventArgs e)
        {
            XuatPhieu(false);
        }

        private void XuatPhieu(bool excel)
        {
            try
            {
                string dangXem = Convert.ToString(ViewState["PhieuDangXem"]);
                if (dangXem.Length < 3)
                    throw new NghiepVuException("Chưa chọn phiếu nào để xuất. Hãy mở lại phiếu cần in.");

                bool nhap = dangXem.StartsWith("N:");
                string ma = dangXem.Substring(2);
                if (!MaHopLe.IsMatch(ma))
                    throw new NghiepVuException("Mã phiếu không hợp lệ.");

                PhieuData d = LayPhieu(nhap, ma);
                string tenFile = (nhap ? "PhieuNhap_" : "PhieuXuat_") + d.Ma + "_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + (excel ? ".xls" : ".doc");
                XuatFileHelper.GuiFile(Response, TaoHtmlFilePhieu(d, excel), excel ? "application/vnd.ms-excel" : "application/msword", tenFile);
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), ex is NghiepVuException ? "warning" : "danger");
            }
        }

        private string TaoHtmlFilePhieu(PhieuData d, bool excel)
        {
            int cols = d.Nhap ? 8 : 7;
            string tieuDe = d.Nhap ? "PHIẾU NHẬP KHO" : "PHIẾU XUẤT KHO";

            StringBuilder sb = new StringBuilder();
            sb.Append(XuatFileHelper.BatDau());
            sb.Append("<table>");
            sb.Append("<tr>" + XuatFileHelper.O("title", tieuDe, cols) + "</tr>");
            sb.Append("<tr>" + XuatFileHelper.O("sub", "Số: " + XuatFileHelper.Mh(d.Ma) + " - Ngày " + d.Ngay.ToString("dd/MM/yyyy HH:mm"), cols) + "</tr>");
            sb.Append(XuatFileHelper.DongTrong(cols));
            sb.Append(XuatFileHelper.DongTin(d.Nhap ? "Nhà cung cấp" : "Khách hàng / Đơn hàng", d.DoiTac, cols));
            sb.Append(XuatFileHelper.DongTin("Nhân viên lập phiếu", d.NhanVien, cols));
            sb.Append(XuatFileHelper.DongTin("Trạng thái thanh toán", d.TrangThai, cols));
            sb.Append(XuatFileHelper.DongTrong(cols));

            sb.Append("<tr>");
            sb.Append(XuatFileHelper.O("th", "STT", 1, "width:45px"));
            sb.Append(XuatFileHelper.O("th", "Mã hàng", 1, "width:90px"));
            sb.Append(XuatFileHelper.O("th", "Tên hàng hóa", 1, "width:240px"));
            sb.Append(XuatFileHelper.O("th", "ĐVT", 1, "width:60px"));
            sb.Append(XuatFileHelper.O("th", "Số lượng", 1, "width:80px"));
            sb.Append(XuatFileHelper.O("th", "Đơn giá (đ)", 1, "width:110px"));
            if (d.Nhap) sb.Append(XuatFileHelper.O("th", "Hạn dùng lô", 1, "width:100px"));
            sb.Append(XuatFileHelper.O("th", "Thành tiền (đ)", 1, "width:130px"));
            sb.Append("</tr>");

            int stt = 0;
            int tongSL = 0;
            foreach (DataRow r in d.ChiTiet.Rows)
            {
                stt++;
                int sl = Convert.ToInt32(r["SoLuong"]);
                tongSL += sl;
                sb.Append("<tr>");
                sb.Append(XuatFileHelper.O("b c", stt.ToString()));
                sb.Append(XuatFileHelper.O("b txt", XuatFileHelper.Mh(Convert.ToString(r["MaHangHoa"]))));
                sb.Append(XuatFileHelper.O("b", XuatFileHelper.Mh(Convert.ToString(r["TenHangHoa"]))));
                sb.Append(XuatFileHelper.O("b c", XuatFileHelper.Mh(Convert.ToString(r["DonViTinh"]))));
                sb.Append(XuatFileHelper.O("b r num", XuatFileHelper.So(excel, sl)));
                sb.Append(XuatFileHelper.O("b r num", XuatFileHelper.So(excel, Convert.ToDecimal(r["DonGia"]))));
                if (d.Nhap)
                    sb.Append(XuatFileHelper.O("b c txt", Convert.ToDateTime(r["HanSuDungLo"]).ToString("dd/MM/yyyy")));
                sb.Append(XuatFileHelper.O("b r num", XuatFileHelper.So(excel, Convert.ToDecimal(r["ThanhTien"]))));
                sb.Append("</tr>");
            }

            sb.Append("<tr>");
            sb.Append(XuatFileHelper.O("tot r", "TỔNG CỘNG", 4));
            sb.Append(XuatFileHelper.O("tot r num", XuatFileHelper.So(excel, tongSL)));
            sb.Append(XuatFileHelper.O("tot", "&nbsp;", d.Nhap ? 2 : 1));
            sb.Append(XuatFileHelper.O("tot r num", XuatFileHelper.So(excel, d.TongTien)));
            sb.Append("</tr>");

            sb.Append(XuatFileHelper.DongTrong(cols));
            sb.Append("<tr>" + XuatFileHelper.O("r", "<i>Ngày " + d.Ngay.Day + " tháng " + d.Ngay.Month + " năm " + d.Ngay.Year + "</i>", cols) + "</tr>");
            sb.Append(XuatFileHelper.ChuKy(d.Nhap ? new[] { 3, 3, 2 } : new[] { 2, 3, 2 },
                new[] { "Người lập phiếu", "Thủ kho", d.Nhap ? "Người giao hàng (NCC)" : "Người nhận hàng" }, d.NhanVien));
            sb.Append("</table>");
            sb.Append(XuatFileHelper.KetThuc);
            return sb.ToString();
        }

        // ================= XUẤT FILE DANH SÁCH (theo ô tick, hoặc toàn bộ kết quả lọc) =================

        protected void btnXuatExcel_Click(object sender, EventArgs e)
        {
            XuatDanhSach(true);
        }

        protected void btnXuatWord_Click(object sender, EventArgs e)
        {
            XuatDanhSach(false);
        }

        private void XuatDanhSach(bool excel)
        {
            try
            {
                string[] chonNhap = LayChon("chkNhap");
                string[] chonXuat = LayChon("chkXuat");
                bool coChon = chonNhap != null || chonXuat != null;

                // Có tick phiếu: chỉ xuất phần đã tick. Không tick: xuất toàn bộ kết quả đang lọc.
                DataTable dtNhap = coChon ? (chonNhap != null ? TruyVan(true, chonNhap) : null) : TruyVan(true, null);
                DataTable dtXuat = coChon ? (chonXuat != null ? TruyVan(false, chonXuat) : null) : TruyVan(false, null);

                const int COLS = 7;
                StringBuilder sb = new StringBuilder();
                sb.Append(XuatFileHelper.BatDau());
                sb.Append("<table>");
                sb.Append("<tr>" + XuatFileHelper.O("title", "BÁO CÁO LỊCH SỬ GIAO DỊCH KHO", COLS) + "</tr>");
                sb.Append("<tr>" + XuatFileHelper.O("sub", "Ngày xuất báo cáo: " + DateTime.Now.ToString("dd/MM/yyyy HH:mm") +
                    (coChon ? " - Chỉ gồm các phiếu đã chọn" : ""), COLS) + "</tr>");
                sb.Append(XuatFileHelper.DongTrong(COLS));

                if (dtNhap != null) ThemPhanDanhSach(sb, "1. DANH SÁCH PHIẾU NHẬP KHO", "Nhà cung cấp", dtNhap, excel, COLS);
                if (dtXuat != null) ThemPhanDanhSach(sb, "2. DANH SÁCH PHIẾU XUẤT KHO", "Khách hàng", dtXuat, excel, COLS);

                sb.Append("</table>");
                sb.Append(XuatFileHelper.KetThuc);

                string tenFile = "LichSuKho_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + (excel ? ".xls" : ".doc");
                XuatFileHelper.GuiFile(Response, sb.ToString(), excel ? "application/vnd.ms-excel" : "application/msword", tenFile);
            }
            catch (Exception ex)
            {
                HienThiThongBao(DatabaseHelper.LayThongBaoLoi(ex), ex is NghiepVuException ? "warning" : "danger");
            }
        }

        private void ThemPhanDanhSach(StringBuilder sb, string tieuDe, string nhanDoiTac, DataTable dt, bool excel, int cols)
        {
            sb.Append("<tr>" + XuatFileHelper.O("lbl", XuatFileHelper.Mh(tieuDe), cols) + "</tr>");
            sb.Append("<tr>");
            sb.Append(XuatFileHelper.O("th", "STT", 1, "width:45px"));
            sb.Append(XuatFileHelper.O("th", "Mã phiếu", 1, "width:90px"));
            sb.Append(XuatFileHelper.O("th", "Ngày", 1, "width:130px"));
            sb.Append(XuatFileHelper.O("th", XuatFileHelper.Mh(nhanDoiTac), 1, "width:200px"));
            sb.Append(XuatFileHelper.O("th", "Nhân viên lập", 1, "width:160px"));
            sb.Append(XuatFileHelper.O("th", "Thanh toán", 1, "width:110px"));
            sb.Append(XuatFileHelper.O("th", "Tổng tiền (đ)", 1, "width:130px"));
            sb.Append("</tr>");

            decimal tong = 0;
            int stt = 0;
            foreach (DataRow r in dt.Rows)
            {
                stt++;
                decimal tien = Convert.ToDecimal(r["TongTien"]);
                tong += tien;
                sb.Append("<tr>");
                sb.Append(XuatFileHelper.O("b c", stt.ToString()));
                sb.Append(XuatFileHelper.O("b c txt", XuatFileHelper.Mh(Convert.ToString(r["MaPhieu"]))));
                sb.Append(XuatFileHelper.O("b c txt", Convert.ToDateTime(r["Ngay"]).ToString("dd/MM/yyyy HH:mm")));
                sb.Append(XuatFileHelper.O("b", XuatFileHelper.Mh(Convert.ToString(r["DoiTac"]))));
                sb.Append(XuatFileHelper.O("b", XuatFileHelper.Mh(Convert.ToString(r["NhanVien"]))));
                sb.Append(XuatFileHelper.O("b c", XuatFileHelper.Mh(Convert.ToString(r["TrangThaiThanhToan"]))));
                sb.Append(XuatFileHelper.O("b r num", XuatFileHelper.So(excel, tien)));
                sb.Append("</tr>");
            }

            if (dt.Rows.Count == 0)
            {
                sb.Append("<tr>" + XuatFileHelper.O("b c", "<i>(Không có dữ liệu)</i>", cols) + "</tr>");
            }
            else
            {
                sb.Append("<tr>");
                sb.Append(XuatFileHelper.O("tot r", "TỔNG CỘNG (" + dt.Rows.Count + " phiếu)", cols - 1));
                sb.Append(XuatFileHelper.O("tot r num", XuatFileHelper.So(excel, tong)));
                sb.Append("</tr>");
            }
            sb.Append(XuatFileHelper.DongTrong(cols));
        }

        // ================= TIỆN ÍCH GIAO DIỆN =================

        // Chỉ ẩn/hiện bằng CSS để lưới dữ liệu và ô tick giữ nguyên trạng thái
        private void ChuyenCheDo(bool chiTiet)
        {
            pnlDanhSach.Style["display"] = chiTiet ? "none" : "block";
            pnlCongCu.Style["display"] = chiTiet ? "none" : "flex";
            pnlChiTiet.Style["display"] = chiTiet ? "block" : "none";
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
