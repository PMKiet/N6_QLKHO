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
        // =====================================================================
        // 4. XỬ LÝ VÀ GHI LOG NGOẠI LỆ (EXCEPTION HANDLING)
        // =====================================================================
        // Chuyển đổi các mã lỗi hệ thống/SQL khó hiểu thành thông báo thân thiện cho người dùng
        private string DescribeError(Exception ex, string hanhDong)
        {
            System.Diagnostics.Trace.TraceError("[QuanLyTaiKhoan] Lỗi khi " + hanhDong + ": " + ex);

            var sqlEx = ex as SqlException;
            if (sqlEx != null)
            {
                switch (sqlEx.Number)
                {
                    case 547: // Vi phạm ràng buộc khóa ngoại (Foreign Key Constraint)
                        return "Không thể " + hanhDong + ": dữ liệu đang được sử dụng ở nơi khác (đã lập phiếu nhập hoặc phiếu xuất).";
                    case 2627:
                    case 2601: // Vi phạm khóa chính hoặc UNIQUE (trùng mã / trùng tên đăng nhập)
                        return "Không thể " + hanhDong + ": mã nhân viên hoặc tên đăng nhập đã tồn tại.";
                    case 515: // Chèn giá trị NULL vào cột bắt buộc NOT NULL
                        return "Không thể " + hanhDong + ": còn thiếu thông tin bắt buộc.";
                    case 8152:
                    case 2628: // Dữ liệu nhập vào vượt quá độ dài cho phép của cột
                        return "Không thể " + hanhDong + ": có thông tin nhập quá dài.";
                    case 1205: // Lỗi kẹt dòng (Deadlock)
                        return "Hệ thống đang bận, vui lòng thử lại sau vài giây.";
                    case -2: // Timeout kết nối CSDL
                        return "Máy chủ phản hồi quá lâu, vui lòng thử lại.";
                    case 4060: // Không tìm thấy hoặc không mở được Database
                        return "Không mở được cơ sở dữ liệu N6_QLKHOVATTU. Hãy kiểm tra tên database trong Web.config.";
                    case 18456: // Lỗi đăng nhập SQL Server (sai tài khoản/mật khẩu SQL)
                        return "Đăng nhập SQL Server thất bại. Hãy kiểm tra tài khoản trong chuỗi kết nối.";
                    case -1:
                    case 2:
                    case 53:
                    case 1231: // Lỗi mất kết nối tới máy chủ chứa SQL Server
                        return "Không kết nối được SQL Server. Hãy kiểm tra dịch vụ SQL Server và Web.config.";
                    default:
                        return "Lỗi cơ sở dữ liệu khi " + hanhDong + " (mã " + sqlEx.Number + ").";
                }
            }

            if (ex is InvalidOperationException)
                return "Không thể kết nối cơ sở dữ liệu. Vui lòng kiểm tra chuỗi kết nối trong Web.config.";

            return "Đã xảy ra lỗi không mong muốn khi " + hanhDong + ". Vui lòng thử lại.";
        }
        // =====================================================================
        // 5. KIỂM TRA TÍNH HỢP LỆ DỮ LIỆU ĐẦU VÀO (VALIDATION)
        // =====================================================================
        // Kiểm tra toàn bộ thông tin trên form trước khi thực hiện thêm mới hoặc cập nhật
        private string ValidateInput(bool isEdit, string ma, string tenDN, string mk,
                                   string hoTen, string sdt, string diaChi, string chucVu)
        {
            // Kiểm tra các trường bắt buộc không được bỏ trống
            if (ma.Length == 0 || tenDN.Length == 0 || hoTen.Length == 0 || sdt.Length == 0 || diaChi.Length == 0)
                return "Vui lòng nhập đầy đủ thông tin.";

            // Kiểm tra định dạng Mã nhân viên bằng Regex
            if (!RegexMa.IsMatch(ma))
                return "Mã nhân viên chỉ gồm chữ, số hoặc dấu gạch dưới, tối đa 10 ký tự.";

            // Kiểm tra định dạng Tên đăng nhập bằng Regex
            if (!RegexTenDN.IsMatch(tenDN))
                return "Tên đăng nhập gồm 3 đến 50 ký tự, chỉ dùng chữ không dấu, số, dấu chấm hoặc gạch dưới.";

            // Khi thêm mới thì mật khẩu không được để trống
            if (!isEdit && mk.Length == 0)
                return "Vui lòng nhập mật khẩu.";

            // Kiểm tra độ dài mật khẩu nếu có nhập
            if (mk.Length > 0 && (mk.Length < 6 || mk.Length > 50))
                return "Mật khẩu phải từ 6 đến 50 ký tự.";

            // Kiểm tra độ dài họ tên tối đa
            if (hoTen.Length > 100)
                return "Họ tên tối đa 100 ký tự.";

            // Kiểm tra tính hợp lệ của Số điện thoại (bắt buộc bắt đầu bằng 0, chỉ chứa số)
            if (!RegexSDT.IsMatch(sdt))
                return "Số điện thoại phải bắt đầu bằng 0 và gồm đúng 10 hoặc 11 chữ số (không chứa chữ cái).";

            // Kiểm tra độ dài địa chỉ tối đa
            if (diaChi.Length > 255)
                return "Địa chỉ tối đa 255 ký tự.";

            // Kiểm tra giá trị chức vụ hợp lệ
            if (chucVu != ChucVuQuanLy && chucVu != ChucVuNhanVien)
                return "Chức vụ không hợp lệ.";

            return null; // Trả về null nghĩa là dữ liệu hoàn toàn hợp lệ
        }
        // =====================================================================
        // 6. HIỂN THỊ VÀ TÌM KIẾM DỮ LIỆU (READ)
        // =====================================================================
        // Tải danh sách người dùng lên GridView (có hỗ trợ lọc theo từ khóa tìm kiếm)
        private void LoadData()
        {
            try
            {
                string kw = txtTimKiem.Text.Trim();
                string sql = "SELECT MaNhanVien, TenDangNhap, HoTen, SoDienThoai, DiaChi, ChucVu FROM NguoiDung";
                DataTable dt;

                if (kw.Length > 0)
                {
                    // Lọc và bảo mật chuỗi tìm kiếm chống lỗi ký tự đặc biệt trong lệnh LIKE
                    string safe = kw.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]");
                    sql += " WHERE MaNhanVien LIKE @kw OR TenDangNhap LIKE @kw OR HoTen LIKE @kw OR SoDienThoai LIKE @kw ORDER BY MaNhanVien";
                    dt = DatabaseHelper.ExecuteQuery(sql, new SqlParameter[] { P("@kw", SqlDbType.NVarChar, 120, "%" + safe + "%") });
                }
                else
                {
                    sql += " ORDER BY MaNhanVien";
                    dt = DatabaseHelper.ExecuteQuery(sql);
                }

                gvNguoiDung.DataSource = dt;
                gvNguoiDung.DataBind();
            }
            catch (Exception ex)
            {
                gvNguoiDung.DataSource = null;
                gvNguoiDung.DataBind();
                ShowMessage(DescribeError(ex, "tải danh sách tài khoản"), false);
            }
        }

        // Hiển thị thông báo trạng thái (thành công hoặc lỗi) lên giao diện
        private void ShowMessage(string text, bool ok)
        {
            lblThongBao.Text = Server.HtmlEncode(text);
            lblThongBao.CssClass = "nd-msg " + (ok ? "ok" : "err");
            lblThongBao.Visible = true;
        }

        // Xóa trắng toàn bộ các ô nhập liệu trên form chi tiết
        private void ClearForm()
        {
            hfMaGoc.Value = "";
            txtMaNV.Text = txtTenDN.Text = txtMatKhau.Text = txtHoTen.Text = txtSDT.Text = txtDiaChi.Text = "";
            txtMaNV.Enabled = true; // Cho phép nhập lại mã khi chuyển sang chế độ thêm mới
            ddlChucVu.SelectedIndex = 0;
        }
        // =====================================================================
        // 7. CÁC SỰ KIỆN TƯƠNG TÁC GIAO DIỆN (UI EVENTS)
        // =====================================================================
        
        // Sự kiện bấm nút Tìm kiếm
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        // Sự kiện bấm nút Thêm tài khoản (mở form nhập liệu mới)
        protected void btnThem_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblTieuDeForm.Text = "Thêm tài khoản";
            lblMatKhau.Text = "Mật khẩu";
            pnlForm.Visible = true;
        }

        // Sự kiện bấm nút Hủy (đóng form nhập liệu)
        protected void btnHuy_Click(object sender, EventArgs e)
        {
            ClearForm();
            pnlForm.Visible = false;
        }

        // Sự kiện điều hướng các thao tác trên từng dòng của GridView (Sửa, Xóa, Đặt lại mật khẩu)
        protected void gvNguoiDung_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string ma = Convert.ToString(e.CommandArgument);
            if (string.IsNullOrWhiteSpace(ma))
            {
                ShowMessage("Không xác định được tài khoản cần thao tác.", false);
                return;
            }

            switch (e.CommandName)
            {
                case "Sua": MoFormSua(ma); break;
                case "Xoa": XoaTaiKhoan(ma); break;
                case "DatLai": DatLaiMatKhau(ma); break;
            }
        }
