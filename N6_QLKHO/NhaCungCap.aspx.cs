using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class NhaCungCap : System.Web.UI.Page
    {
        // =====================================================================
        // 1. BIỂU THỨC CHÍNH QUY (REGEX) KIỂM TRA DỮ LIỆU
        // =====================================================================
        // Số điện thoại: bắt buộc bắt đầu bằng số 0 và có tổng cộng 10 hoặc 11 chữ số (không chứa chữ cái)
        private static readonly Regex RegexSDT = new Regex(@"^0\d{9,10}$");
        // =====================================================================
        // 2. VÒNG ĐỜI TRANG (PAGE LIFE CYCLE)
        // =====================================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Cấu hình ràng buộc nhập số cho các ô số điện thoại ở mọi phiên tải trang
            CauHinhSoDienThoai();

            // Chỉ nạp dữ liệu cho GridView vào lần đầu tiên tải trang (tránh load lại khi bấm các nút chức năng khác)
            if (!IsPostBack)
            {
                BindGrid();
            }
        }
