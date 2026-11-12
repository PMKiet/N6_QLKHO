using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class QuanLyTaiKhoan : System.Web.UI.Page
    {
        // =====================================================================
        // 1. KHAI BÁO HẰNG SỐ VÀ BIỂU THỨC CHÍNH QUY (REGEX)
        // =====================================================================
        private const string ChucVuQuanLy = "Quản lý";
        private const string ChucVuNhanVien = "Nhân viên";

        // Regex kiểm tra Mã nhân viên: chỉ gồm chữ, số, gạch dưới, tối đa 10 ký tự
        private static readonly Regex RegexMa = new Regex(@"^[A-Za-z0-9_]{1,10}$");
        
        // Regex kiểm tra Tên đăng nhập: 3-50 ký tự, không dấu, có thể chứa dấu chấm/gạch dưới
        private static readonly Regex RegexTenDN = new Regex(@"^[A-Za-z0-9_.]{3,50}$");
        
        // Regex kiểm tra Số điện thoại: bắt buộc bắt đầu bằng số 0 và có từ 10 đến 11 chữ số (tuyệt đối không chứa chữ cái)
        private static readonly Regex RegexSDT = new Regex(@"^0\d{9,10}$");

        // =====================================================================
        // 2. SỰ KIỆN VÒNG ĐỜI TRANG (PAGE LIFE CYCLE)
        // =====================================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Chỉ nạp dữ liệu danh sách vào lần đầu tiên tải trang (tránh load lại khi bấm nút)
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        // =====================================================================
        // 3. CÁC HÀM TIỆN ÍCH DÙNG CHUNG (HELPER FUNCTIONS)
        // =====================================================================
        
        // Hàm rút gọn thực thi truy vấn trả về một giá trị duy nhất (Ví dụ: đếm số lượng COUNT(*))
        private int Count(string sql, params SqlParameter[] ps)
        {
            object val = DatabaseHelper.ExecuteScalar(sql, ps);
            if (val == null || val == DBNull.Value) return 0;
            return Convert.ToInt32(val);
        }

        // Hàm rút gọn tạo tham số SQL để phòng chống lỗi SQL Injection
        private static SqlParameter P(string name, SqlDbType type, int size, object value)
        {
            var p = new SqlParameter(name, type, size);
            p.Value = value ?? DBNull.Value;
            return p;
        }

        // Hàm mã hóa mật khẩu người dùng sang định dạng MD5 trước khi lưu vào CSDL
        private static string Md5(string input)
        {
            using (var md5 = MD5.Create())
            {
                byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
                var sb = new StringBuilder();
                foreach (byte b in hash) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
