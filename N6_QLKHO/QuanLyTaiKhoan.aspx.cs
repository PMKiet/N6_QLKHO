using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
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
        // 3.1. HÀM HỖ TRỢ MỞ / ĐÓNG FORM (MODAL) VÀ THÔNG BÁO
        // =====================================================================
        // Chạy script sau khi trang tải xong (kể cả thư viện Bootstrap nằm cuối trang)
        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, GetType(), key, script, true);
        }

        // Mở form (modal) theo id
        private void MoModal(string modalId)
        {
            ChayScriptSauKhiTaiTrang("show_" + modalId,
                "var el = document.getElementById('" + modalId + "');" +
                "if (el && window.bootstrap) { new bootstrap.Modal(el).show(); }");
        }

        // Đóng form (modal) theo id - an toàn kể cả khi form chưa từng được mở
        private void DongModal(string modalId)
        {
            ChayScriptSauKhiTaiTrang("hide_" + modalId,
                "var el = document.getElementById('" + modalId + "');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

        // Hiển thị thông báo trạng thái (thành công hoặc lỗi) ở đầu trang
        private void ShowMessage(string text, bool ok)
        {
            lblThongBao.Text = Server.HtmlEncode(text);
            lblThongBao.CssClass = "d-block mb-3 alert " + (ok ? "alert-success" : "alert-danger");
            lblThongBao.Visible = true;
        }

        // Hiển thị lỗi ngay trong form và mở lại form để người dùng sửa tiếp
        private void LoiTrongModal(Label lbl, string text, string modalId)
        {
            lbl.Text = Server.HtmlEncode(text);
            MoModal(modalId);
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

        // Xóa trắng các ô nhập liệu trong form thêm tài khoản
        private void ClearFormThem()
        {
            txtMaNV.Text = txtTenDN.Text = txtMatKhau.Text = txtHoTen.Text = txtSDT.Text = txtDiaChi.Text = "";
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

        // =====================================================================
        // 8. CHỨC NĂNG SỬA TÀI KHOẢN (BẤM ICON BÚT XANH -> MỞ FORM SỬA)
        // =====================================================================
        // Đọc thông tin tài khoản từ CSDL đổ vào form sửa. Trả về false nếu tài khoản không còn tồn tại.
        private bool NapDuLieuFormSua(string ma)
        {
            DataTable dt = DatabaseHelper.ExecuteQuery(
                "SELECT TenDangNhap, HoTen, SoDienThoai, DiaChi, ChucVu FROM NguoiDung WHERE MaNhanVien = @ma",
                new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

            if (dt.Rows.Count == 0) return false;

            DataRow r = dt.Rows[0];
            hfMaGoc.Value = ma;
            txtSuaMaNV.Text = ma;
            txtSuaTenDN.Text = Convert.ToString(r["TenDangNhap"]);
            txtSuaMatKhau.Text = ""; // Để trống (không nhập nghĩa là giữ nguyên mật khẩu cũ)
            txtSuaHoTen.Text = Convert.ToString(r["HoTen"]);
            txtSuaSDT.Text = Convert.ToString(r["SoDienThoai"]);
            txtSuaDiaChi.Text = Convert.ToString(r["DiaChi"]);

            string cv = Convert.ToString(r["ChucVu"]);
            ddlSuaChucVu.SelectedValue = ddlSuaChucVu.Items.FindByValue(cv) != null ? cv : ChucVuNhanVien;
            return true;
        }

        // Mở form sửa với dữ liệu của tài khoản được chọn
        private void MoFormSua(string ma)
        {
            try
            {
                if (!NapDuLieuFormSua(ma))
                {
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại (có thể đã bị xoá).", false);
                    LoadData();
                    return;
                }

                MoModal("modalSuaTK");
            }
            catch (Exception ex)
            {
                ShowMessage(DescribeError(ex, "mở thông tin tài khoản"), false);
            }
        }

        // Nút Làm mới trong form sửa: nạp lại dữ liệu gốc từ CSDL
        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string ma = hfMaGoc.Value;
            try
            {
                if (!NapDuLieuFormSua(ma))
                {
                    DongModal("modalSuaTK");
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại (có thể đã bị xoá).", false);
                    LoadData();
                    return;
                }

                MoModal("modalSuaTK"); // Giữ form mở để tiếp tục chỉnh sửa
            }
            catch (Exception ex)
            {
                LoiTrongModal(lblLoiSua, DescribeError(ex, "làm mới thông tin tài khoản"), "modalSuaTK");
            }
        }

        // Nút Lưu Thay Đổi trong form sửa
        protected void btnLuuSua_Click(object sender, EventArgs e)
        {
            string ma = hfMaGoc.Value;
            string tenDN = txtSuaTenDN.Text.Trim();
            string mk = txtSuaMatKhau.Text;
            string hoTen = txtSuaHoTen.Text.Trim();
            string sdt = txtSuaSDT.Text.Trim();
            string diaChi = txtSuaDiaChi.Text.Trim();
            string chucVu = ddlSuaChucVu.SelectedValue;

            if (ma.Length == 0)
            {
                ShowMessage("Không xác định được tài khoản cần cập nhật.", false);
                return;
            }

            // Bước kiểm tra định dạng dữ liệu đầu vào
            string loi = ValidateInput(true, ma, tenDN, mk, hoTen, sdt, diaChi, chucVu);
            if (loi != null)
            {
                LoiTrongModal(lblLoiSua, loi, "modalSuaTK");
                return;
            }

            try
            {
                // Kiểm tra trùng lặp tên đăng nhập với các tài khoản khác
                int trungTen = Count(
                    "SELECT COUNT(*) FROM NguoiDung WHERE TenDangNhap = @tdn AND MaNhanVien <> @ma",
                    P("@tdn", SqlDbType.VarChar, 50, tenDN), P("@ma", SqlDbType.VarChar, 10, ma));
                if (trungTen > 0)
                {
                    LoiTrongModal(lblLoiSua, "Tên đăng nhập \"" + tenDN + "\" đã tồn tại.", "modalSuaTK");
                    return;
                }

                // Ràng buộc an toàn: Không cho phép hạ chức vụ nếu đó là tài khoản Quản lý duy nhất còn lại
                if (chucVu != ChucVuQuanLy)
                {
                    DataTable cu = DatabaseHelper.ExecuteQuery(
                        "SELECT ChucVu FROM NguoiDung WHERE MaNhanVien = @ma",
                        new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

                    if (cu.Rows.Count > 0 && Convert.ToString(cu.Rows[0]["ChucVu"]) == ChucVuQuanLy &&
                        Count("SELECT COUNT(*) FROM NguoiDung WHERE ChucVu = @cv", P("@cv", SqlDbType.NVarChar, 50, ChucVuQuanLy)) <= 1)
                    {
                        LoiTrongModal(lblLoiSua, "Không thể đổi chức vụ: hệ thống phải còn ít nhất một tài khoản Quản lý.", "modalSuaTK");
                        return;
                    }
                }

                // Xây dựng câu lệnh SQL cập nhật (nếu có nhập mật khẩu mới thì cập nhật luôn mật khẩu, ngược lại giữ nguyên)
                string sql = "UPDATE NguoiDung SET TenDangNhap=@tdn, HoTen=@ht, SoDienThoai=@sdt, DiaChi=@dc, ChucVu=@cv"
                           + (mk.Length > 0 ? ", MatKhau=@mk" : "") + " WHERE MaNhanVien=@ma";

                var ps = new List<SqlParameter>
                {
                    P("@tdn", SqlDbType.VarChar, 50, tenDN),
                    P("@ht", SqlDbType.NVarChar, 100, hoTen),
                    P("@sdt", SqlDbType.VarChar, 15, sdt),
                    P("@dc", SqlDbType.NVarChar, 255, diaChi),
                    P("@cv", SqlDbType.NVarChar, 50, chucVu),
                    P("@ma", SqlDbType.VarChar, 10, ma)
                };
                if (mk.Length > 0) ps.Add(P("@mk", SqlDbType.VarChar, 255, Md5(mk)));

                int n = DatabaseHelper.ExecuteNonQuery(sql, ps.ToArray());

                LoadData();
                DongModal("modalSuaTK");
                if (n == 0)
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại nên không thể cập nhật.", false);
                else
                    ShowMessage("Đã cập nhật tài khoản " + ma + ".", true);
            }
            catch (Exception ex)
            {
                LoiTrongModal(lblLoiSua, DescribeError(ex, "cập nhật tài khoản"), "modalSuaTK");
            }
        }

        // =====================================================================
        // 9. CHỨC NĂNG ĐẶT LẠI MẬT KHẨU (RESET PASSWORD)
        // =====================================================================
        // Đặt lại mật khẩu mặc định của một tài khoản về chuỗi "123456" (đã mã hóa MD5)
        private void DatLaiMatKhau(string ma)
        {
            try
            {
                int n = DatabaseHelper.ExecuteNonQuery(
                    "UPDATE NguoiDung SET MatKhau = @mk WHERE MaNhanVien = @ma",
                    new SqlParameter[] {
                        P("@mk", SqlDbType.VarChar, 255, Md5("123456")),
                        P("@ma", SqlDbType.VarChar, 10, ma)
                    });

                if (n == 0)
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại.", false);
                else
                    ShowMessage("Đã đặt lại mật khẩu của " + ma + " về 123456.", true);
            }
            catch (Exception ex)
            {
                ShowMessage(DescribeError(ex, "đặt lại mật khẩu"), false);
            }
        }

        // =====================================================================
        // 10. CHỨC NĂNG XÓA TÀI KHOẢN (DELETE)
        // =====================================================================
        // Xóa một tài khoản khỏi hệ thống (có kiểm tra an toàn: không được xóa chính mình, phải còn ít nhất 1 Quản lý)
        private void XoaTaiKhoan(string ma)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT TenDangNhap, ChucVu FROM NguoiDung WHERE MaNhanVien = @ma",
                    new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại (có thể đã bị xoá).", false);
                    LoadData();
                    return;
                }

                string tenDN = Convert.ToString(dt.Rows[0]["TenDangNhap"]);
                string chucVu = Convert.ToString(dt.Rows[0]["ChucVu"]);

                // Kiểm tra ràng buộc 1: Không cho phép tự xóa tài khoản đang đăng nhập
                string current = Session["TenDangNhap"] as string;
                if (!string.IsNullOrEmpty(current) &&
                    string.Equals(tenDN, current, StringComparison.OrdinalIgnoreCase))
                {
                    ShowMessage("Không thể xoá tài khoản đang đăng nhập.", false);
                    return;
                }

                // Kiểm tra ràng buộc 2: Hệ thống bắt buộc phải còn duy trì ít nhất một tài khoản Quản lý
                if (chucVu == ChucVuQuanLy &&
                    Count("SELECT COUNT(*) FROM NguoiDung WHERE ChucVu = @cv", P("@cv", SqlDbType.NVarChar, 50, ChucVuQuanLy)) <= 1)
                {
                    ShowMessage("Không thể xoá: hệ thống phải còn ít nhất một tài khoản Quản lý.", false);
                    return;
                }

                int n = DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM NguoiDung WHERE MaNhanVien = @ma",
                    new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

                if (n == 0)
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại.", false);
                else
                    ShowMessage("Đã xoá tài khoản " + ma + ".", true);

                LoadData();
            }
            catch (Exception ex)
            {
                ShowMessage(DescribeError(ex, "xoá tài khoản"), false);
            }
        }

        // =====================================================================
        // 11. CHỨC NĂNG THÊM TÀI KHOẢN MỚI
        // =====================================================================
        // Nút Lưu Tài Khoản trong form thêm
        protected void btnLuu_Click(object sender, EventArgs e)
        {
            string ma = txtMaNV.Text.Trim();
            string tenDN = txtTenDN.Text.Trim();
            string mk = txtMatKhau.Text;
            string hoTen = txtHoTen.Text.Trim();
            string sdt = txtSDT.Text.Trim();
            string diaChi = txtDiaChi.Text.Trim();
            string chucVu = ddlChucVu.SelectedValue;

            // Bước kiểm tra định dạng dữ liệu đầu vào
            string loi = ValidateInput(false, ma, tenDN, mk, hoTen, sdt, diaChi, chucVu);
            if (loi != null)
            {
                LoiTrongModal(lblLoiThem, loi, "modalThemTK");
                return;
            }

            try
            {
                // Kiểm tra trùng Mã nhân viên
                if (Count("SELECT COUNT(*) FROM NguoiDung WHERE MaNhanVien = @ma", P("@ma", SqlDbType.VarChar, 10, ma)) > 0)
                {
                    LoiTrongModal(lblLoiThem, "Mã nhân viên \"" + ma + "\" đã tồn tại.", "modalThemTK");
                    return;
                }

                // Kiểm tra trùng Tên đăng nhập
                if (Count("SELECT COUNT(*) FROM NguoiDung WHERE TenDangNhap = @tdn", P("@tdn", SqlDbType.VarChar, 50, tenDN)) > 0)
                {
                    LoiTrongModal(lblLoiThem, "Tên đăng nhập \"" + tenDN + "\" đã tồn tại.", "modalThemTK");
                    return;
                }

                DatabaseHelper.ExecuteNonQuery(
                    "INSERT INTO NguoiDung (MaNhanVien, TenDangNhap, MatKhau, HoTen, SoDienThoai, DiaChi, ChucVu) " +
                    "VALUES (@ma, @tdn, @mk, @ht, @sdt, @dc, @cv)",
                    new SqlParameter[] {
                        P("@ma", SqlDbType.VarChar, 10, ma),
                        P("@tdn", SqlDbType.VarChar, 50, tenDN),
                        P("@mk", SqlDbType.VarChar, 255, Md5(mk)),
                        P("@ht", SqlDbType.NVarChar, 100, hoTen),
                        P("@sdt", SqlDbType.VarChar, 15, sdt),
                        P("@dc", SqlDbType.NVarChar, 255, diaChi),
                        P("@cv", SqlDbType.NVarChar, 50, chucVu)
                    });

                ClearFormThem();
                LoadData();
                DongModal("modalThemTK");
                ShowMessage("Đã thêm tài khoản " + ma + ".", true);
            }
            catch (Exception ex)
            {
                LoiTrongModal(lblLoiThem, DescribeError(ex, "thêm tài khoản"), "modalThemTK");
            }
        }
    }
}
