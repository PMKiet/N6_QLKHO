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
            // Cấu hình ô nhập liệu (SĐT chỉ nhập số, biểu tượng con mắt xem mật khẩu) - chạy ở mọi lần tải trang
            CauHinhNhapLieu();

            // Chỉ nạp dữ liệu danh sách vào lần đầu tiên tải trang (tránh load lại khi bấm nút)
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        // =====================================================================
        // 2.1. CẤU HÌNH Ô NHẬP LIỆU PHÍA TRÌNH DUYỆT
        // =====================================================================
        // - Ô Số điện thoại: chỉ cho gõ/dán chữ số, tối đa 11 số
        // - Ô Mật khẩu: có biểu tượng con mắt nằm trong ô để hiện/ẩn mật khẩu
        private void CauHinhNhapLieu()
        {
            // ---- Số điện thoại chỉ được nhập số ----
            txtSDT.MaxLength = 11;
            txtSDT.Attributes["inputmode"] = "numeric"; // Điện thoại sẽ hiện bàn phím số
            // Chặn phím không phải số (48 = '0', 57 = '9')
            txtSDT.Attributes["onkeypress"] = "return event.charCode >= 48 && event.charCode <= 57;";
            // Xóa mọi ký tự không phải số (kể cả khi người dùng dán chuỗi có chữ vào)
            txtSDT.Attributes["oninput"] = "this.value = this.value.replace(/\\D/g, '');";

            // ---- Biểu tượng con mắt xem / ẩn mật khẩu ----
            txtMatKhau.Attributes["autocomplete"] = "new-password";

            string script = @"
(function () {
  var txt = document.getElementById('{ID}');
  if (!txt || document.getElementById('btnXemMK')) return;

  // Ẩn biểu tượng xem mật khẩu mặc định của trình duyệt Edge để không bị hiện 2 con mắt
  var st = document.createElement('style');
  st.textContent = '#{ID}::-ms-reveal{display:none;}';
  document.head.appendChild(st);

  var eyeOpen = ""<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg>"";
  var eyeOff  = ""<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24'/><line x1='1' y1='1' x2='23' y2='23'/></svg>"";

  // Bọc ô mật khẩu trong một khung để đặt biểu tượng nằm bên phải, bên trong ô
  var wrap = document.createElement('div');
  wrap.style.position = 'relative';
  txt.parentNode.insertBefore(wrap, txt);
  wrap.appendChild(txt);
  txt.style.paddingRight = '42px';

  var btn = document.createElement('button');
  btn.type = 'button';   // type=button: không gây postback
  btn.id = 'btnXemMK';
  btn.title = 'Hiện / ẩn mật khẩu';
  btn.innerHTML = eyeOpen;
  btn.style.cssText = 'position:absolute;right:10px;top:50%;transform:translateY(-50%);' +
                      'border:0;background:transparent;padding:0;cursor:pointer;color:#6c757d;' +
                      'display:flex;align-items:center;';
  btn.onclick = function () {
    if (txt.type === 'password') { txt.type = 'text'; btn.innerHTML = eyeOff; }
    else { txt.type = 'password'; btn.innerHTML = eyeOpen; }
  };
  wrap.appendChild(btn);
})();";

            script = script.Replace("{ID}", txtMatKhau.ClientID);

            ClientScript.RegisterStartupScript(this.GetType(), "XemMatKhau", script, true);
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

        // =====================================================================
        // 8. CHỨC NĂNG SỬA TÀI KHOẢN (UPDATE - LOAD DATA TO FORM)
        // =====================================================================
        // Đọc thông tin chi tiết của 1 tài khoản đổ lên form để người dùng chỉnh sửa
        private void MoFormSua(string ma)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT TenDangNhap, HoTen, SoDienThoai, DiaChi, ChucVu FROM NguoiDung WHERE MaNhanVien = @ma",
                    new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Tài khoản " + ma + " không còn tồn tại (có thể đã bị xoá).", false);
                    LoadData();
                    return;
                }

                DataRow r = dt.Rows[0];
                hfMaGoc.Value = ma;
                txtMaNV.Text = ma;
                txtMaNV.Enabled = false; // Khóa ô Mã nhân viên không cho sửa khóa chính
                txtTenDN.Text = Convert.ToString(r["TenDangNhap"]);
                txtMatKhau.Text = "";    // Để trống mật khẩu (nếu không nhập nghĩa là giữ nguyên mật khẩu cũ)
                txtHoTen.Text = Convert.ToString(r["HoTen"]);
                txtSDT.Text = Convert.ToString(r["SoDienThoai"]);
                txtDiaChi.Text = Convert.ToString(r["DiaChi"]);

                string cv = Convert.ToString(r["ChucVu"]);
                ddlChucVu.SelectedValue = ddlChucVu.Items.FindByValue(cv) != null ? cv : ChucVuNhanVien;

                lblTieuDeForm.Text = "Sửa tài khoản " + ma;
                lblMatKhau.Text = "Mật khẩu mới (bỏ trống nếu không đổi)";
                pnlForm.Visible = true;
            }
            catch (Exception ex)
            {
                ShowMessage(DescribeError(ex, "mở thông tin tài khoản"), false);
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
        // 11. CHỨC NĂNG LƯU DỮ LIỆU (SAVE / INSERT OR UPDATE)
        // =====================================================================
        // Sự kiện bấm nút Lưu (kiểm tra phân nhánh tự động gọi Thêm mới hoặc Cập nhật)
        protected void btnLuu_Click(object sender, EventArgs e)
        {
            bool isEdit = hfMaGoc.Value.Length > 0; // Nếu HiddenField có giá trị nghĩa là đang ở chế độ Sửa
            string ma = isEdit ? hfMaGoc.Value : txtMaNV.Text.Trim();
            string tenDN = txtTenDN.Text.Trim();
            string mk = txtMatKhau.Text;
            string hoTen = txtHoTen.Text.Trim();
            string sdt = txtSDT.Text.Trim();
            string diaChi = txtDiaChi.Text.Trim();
            string chucVu = ddlChucVu.SelectedValue;

            // Bước kiểm tra định dạng dữ liệu đầu vào
            string loi = ValidateInput(isEdit, ma, tenDN, mk, hoTen, sdt, diaChi, chucVu);
            if (loi != null)
            {
                ShowMessage(loi, false);
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
                    ShowMessage("Tên đăng nhập \"" + tenDN + "\" đã tồn tại.", false);
                    return;
                }

                // Phân nhánh thực thi: Sửa hoặc Thêm mới
                if (isEdit)
                    CapNhat(ma, tenDN, mk, hoTen, sdt, diaChi, chucVu);
                else
                    ThemMoi(ma, tenDN, mk, hoTen, sdt, diaChi, chucVu);
            }
            catch (Exception ex)
            {
                ShowMessage(DescribeError(ex, isEdit ? "cập nhật tài khoản" : "thêm tài khoản"), false);
            }
        }

        // Thực hiện thêm mới tài khoản vào cơ sở dữ liệu
        private void ThemMoi(string ma, string tenDN, string mk, string hoTen, string sdt, string diaChi, string chucVu)
        {
            // Kiểm tra xem Mã nhân viên đã tồn tại chưa trước khi thêm
            if (Count("SELECT COUNT(*) FROM NguoiDung WHERE MaNhanVien = @ma", P("@ma", SqlDbType.VarChar, 10, ma)) > 0)
            {
                ShowMessage("Mã nhân viên \"" + ma + "\" đã tồn tại.", false);
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

            ShowMessage("Đã thêm tài khoản " + ma + ".", true);
            HoanTatLuu();
        }

        // Thực hiện cập nhật thông tin tài khoản trong cơ sở dữ liệu
        private void CapNhat(string ma, string tenDN, string mk, string hoTen, string sdt, string diaChi, string chucVu)
        {
            // Ràng buộc an toàn: Không cho phép hạ chức vụ nếu đó là tài khoản Quản lý duy nhất còn lại
            if (chucVu != ChucVuQuanLy)
            {
                DataTable cu = DatabaseHelper.ExecuteQuery(
                    "SELECT ChucVu FROM NguoiDung WHERE MaNhanVien = @ma",
                    new SqlParameter[] { P("@ma", SqlDbType.VarChar, 10, ma) });

                if (cu.Rows.Count > 0 && Convert.ToString(cu.Rows[0]["ChucVu"]) == ChucVuQuanLy &&
                    Count("SELECT COUNT(*) FROM NguoiDung WHERE ChucVu = @cv", P("@cv", SqlDbType.NVarChar, 50, ChucVuQuanLy)) <= 1)
                {
                    ShowMessage("Không thể đổi chức vụ: hệ thống phải còn ít nhất một tài khoản Quản lý.", false);
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
            if (n == 0)
            {
                ShowMessage("Tài khoản " + ma + " không còn tồn tại nên không thể cập nhật.", false);
                LoadData();
                return;
            }

            ShowMessage("Đã cập nhật tài khoản " + ma + ".", true);
            HoanTatLuu();
        }

        // Hoàn tất quá trình lưu: xóa form, ẩn panel chi tiết và tải lại danh sách
        private void HoanTatLuu()
        {
            ClearForm();
            pnlForm.Visible = false;
            LoadData();
        }
    }
}
