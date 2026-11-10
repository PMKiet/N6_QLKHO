using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class DonDatHang : System.Web.UI.Page
    {

        // ====== ĐỔI TÊN BẢNG Ở ĐÂY NẾU CSDL CỦA BẠN ĐẶT TÊN KHÁC ======
        private const string BangDon = "DonDatHang";           // MaDonHang, NgayDatHang, TenKhachHang, SoDienThoai, TrangThai
        private const string BangChiTiet = "ChiTietDonDatHang"; // MaDonHang, MaHangHoa, SoLuongDat, DonGia
                                                                // ================================================================

        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        // Điều kiện lọc dùng chung cho cả truy vấn danh sách đơn và truy vấn chi tiết
        private const string DieuKienLoc =
            @"(@TuKhoa = N'' OR d.MaDonHang LIKE N'%' + @TuKhoa + N'%' OR d.TenKhachHang LIKE N'%' + @TuKhoa + N'%')
              AND (@TuNgay IS NULL OR d.NgayDatHang >= @TuNgay)
              AND (@DenNgay IS NULL OR d.NgayDatHang < DATEADD(DAY, 1, @DenNgay))
              AND (@TrangThai = N'' OR d.TrangThai = @TrangThai)";

        // JSON chi tiết các đơn đang hiển thị, được in ra trang để modal "Chi tiết" đọc
        protected string ChiTietJson { get; private set; } = "{}";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnDatLai_Click(object sender, EventArgs e)
        {
            txtMaDon.Text = string.Empty;
            txtTuNgay.Text = string.Empty;
            txtDenNgay.Text = string.Empty;
            ddlTrangThai.SelectedIndex = 0;
            LoadData();
        }

        private SqlParameter[] TaoThamSo()
        {
            DateTime tu, den;
            bool coTu = DateTime.TryParseExact(txtTuNgay.Text, "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out tu);
            bool coDen = DateTime.TryParseExact(txtDenNgay.Text, "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out den);

            string tuKhoa = txtMaDon.Text.Trim();
            if (tuKhoa.Length > 100) tuKhoa = tuKhoa.Substring(0, 100);

            return new[]
            {
                new SqlParameter("@TuKhoa", SqlDbType.NVarChar, 100) { Value = tuKhoa },
                new SqlParameter("@TuNgay", SqlDbType.DateTime) { Value = coTu ? (object)tu : DBNull.Value },
                new SqlParameter("@DenNgay", SqlDbType.DateTime) { Value = coDen ? (object)den : DBNull.Value },
                new SqlParameter("@TrangThai", SqlDbType.NVarChar, 50) { Value = ddlTrangThai.SelectedValue ?? string.Empty }
            };
        }

        private void LoadData()
        {
            lblLoi.Visible = false;
            try
            {
                string sqlDon =
                    "SELECT d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai, " +
                    "       ISNULL(SUM(c.SoLuongDat * c.DonGia), 0) AS TongTien " +
                    "FROM " + BangDon + " d " +
                    "LEFT JOIN " + BangChiTiet + " c ON c.MaDonHang = d.MaDonHang " +
                    "WHERE " + DieuKienLoc + " " +
                    "GROUP BY d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai " +
                    "ORDER BY d.NgayDatHang DESC";

                string sqlChiTiet =
                    "SELECT c.MaDonHang, c.MaHangHoa, c.SoLuongDat, c.DonGia " +
                    "FROM " + BangChiTiet + " c " +
                    "WHERE c.MaDonHang IN (SELECT d.MaDonHang FROM " + BangDon + " d WHERE " + DieuKienLoc + ") " +
                    "ORDER BY c.MaDonHang, c.MaHangHoa";

                DataTable dtDon = DatabaseHelper.ExecuteQuery(sqlDon, TaoThamSo());
                DataTable dtChiTiet = DatabaseHelper.ExecuteQuery(sqlChiTiet, TaoThamSo());

                rptDonHang.DataSource = dtDon;
                rptDonHang.DataBind();

                pnlTrong.Visible = dtDon.Rows.Count == 0;
                lblSoLuong.Text = dtDon.Rows.Count == 0
                    ? "Không có đơn nào"
                    : "Hiển thị " + dtDon.Rows.Count + " đơn đặt hàng";

                ChiTietJson = TaoJsonChiTiet(dtDon, dtChiTiet);
            }
            catch (Exception ex)
            {
                rptDonHang.DataSource = null;
                rptDonHang.DataBind();
                pnlTrong.Visible = false;
                lblSoLuong.Text = string.Empty;
                ChiTietJson = "{}";
                lblLoi.Text = "Không tải được dữ liệu đơn đặt hàng: " + Server.HtmlEncode(ex.Message);
                lblLoi.Visible = true;
            }
        }

        private static string TaoJsonChiTiet(DataTable dtDon, DataTable dtChiTiet)
        {
            var dong = new Dictionary<string, List<object[]>>();
            foreach (DataRow r in dtChiTiet.Rows)
            {
                string ma = Convert.ToString(r["MaDonHang"]);
                if (!dong.ContainsKey(ma)) dong[ma] = new List<object[]>();
                dong[ma].Add(new object[]
                {
                    Convert.ToString(r["MaHangHoa"]),
                    Convert.ToDecimal(r["SoLuongDat"]),
                    Convert.ToDecimal(r["DonGia"])
                });
            }

            var ketQua = new Dictionary<string, object>();
            foreach (DataRow r in dtDon.Rows)
            {
                string ma = Convert.ToString(r["MaDonHang"]);
                ketQua[ma] = new Dictionary<string, object>
                {
                    { "khach", Convert.ToString(r["TenKhachHang"]) },
                    { "sdt", Convert.ToString(r["SoDienThoai"]) },
                    { "ngay", FormatNgay(r["NgayDatHang"]) },
                    { "trangThai", Convert.ToString(r["TrangThai"]) },
                    { "dong", dong.ContainsKey(ma) ? dong[ma] : new List<object[]>() }
                };
            }

            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            // Thay "<" để dữ liệu không thể đóng thẻ </script> khi in vào trang
            return serializer.Serialize(ketQua).Replace("<", "\\u003c");
        }

        // ----- Hàm định dạng dùng trong .aspx -----
        protected static string FormatNgay(object value)
        {
            if (value == null || value == DBNull.Value) return string.Empty;
            return Convert.ToDateTime(value).ToString("dd/MM/yyyy HH:mm", Vi);
        }

        protected static string FormatTien(object value)
        {
            if (value == null || value == DBNull.Value) return "0 ₫";
            return Convert.ToDecimal(value).ToString("N0", Vi) + " ₫";
        }

        protected static string LopTrangThai(object value)
        {
            switch (Convert.ToString(value))
            {
                case "Đã xuất kho": return "bg-success";
                case "Đang xử lý": return "bg-warning text-dark";
                default: return "bg-secondary";
            }
        }
    }
}