using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace N6_QLKHO
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Nếu đã đăng nhập trước đó có thể chuyển hướng sẵn
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string user = txtTenDangNhap.Text.Trim();
            string pass = txtMatKhau.Text.Trim();

            if (string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
            {
                HienThiThongBao("Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!", "danger");
                return;
            }

            try
            {
                // Truy vấn kiểm tra tài khoản trong bảng NguoiDung
                // Lưu ý: Trong CSDL mẫu của bạn, mật khẩu đang được lưu dưới dạng mã hóa MD5 (ví dụ: 'e10adc3949ba59abbe56e057f20f883e' cho '123456')
                string query = "SELECT MaNhanVien, HoTen, ChucVu FROM NguoiDung WHERE TenDangNhap = @User AND MatKhau = @Pass";

                // Nếu bạn đang lưu mật khẩu dạng chuỗi thuần (plain text) thì giữ nguyên biến pass. 
                // Nếu dùng mã hóa MD5, bạn có thể truyền chuỗi mã hóa MD5 của mật khẩu vào đây.
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@User", user),
                    new SqlParameter("@Pass", pass) // Hoặc đổi thành hàm băm MD5(pass) nếu CSDL mã hóa MD5
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    // Lưu thông tin người dùng vào Session để sử dụng toàn hệ thống
                    Session["MaNhanVien"] = row["MaNhanVien"].ToString();
                    Session["HoTen"] = row["HoTen"].ToString();
                    Session["ChucVu"] = row["ChucVu"].ToString();

                    // Đăng nhập thành công, chuyển hướng về trang chủ quản lý hàng hóa
                    Response.Redirect("HangHoa.aspx");
                }
                else
                {
                    HienThiThongBao("Tên đăng nhập hoặc mật khẩu không chính xác!", "danger");
                }
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi hệ thống: " + ex.Message, "danger");
            }
        }

        private void HienThiThongBao(string message, string type)
        {
            lblThongBao.Text = $"<div class='alert alert-{type} alert-dismissible fade show py-2 small mb-0' role='alert'>" +
                               $"<i class='fa-solid fa-triangle-exclamation me-1'></i> {message}" +
                               $"<button type='button' class='btn-close py-2' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               $"</div>";
        }
    }
}