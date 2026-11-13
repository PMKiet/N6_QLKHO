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
        // =====================================================================
        // 3. CÁC HÀM TIỆN ÍCH HỖ TRỢ GIAO DIỆN & MODAL (UI HELPERS)
        // =====================================================================

        // Thiết lập thuộc tính giới hạn chỉ cho nhập số, bật bàn phím số trên mobile và chống dán chữ cho ô điện thoại
        private void CauHinhSoDienThoai()
        {
            TextBox[] cacOSdt = { txtSoDienThoai, txtSuaSoDienThoai };
            foreach (TextBox tb in cacOSdt)
            {
                tb.MaxLength = 11;
                tb.Attributes["inputmode"] = "numeric"; // Hiển thị bàn phím số trên thiết bị di động
                // Chặn gõ các ký tự không phải số từ bàn phím (mã ASCII từ 48 đến 57 tương ứng từ '0' đến '9')
                tb.Attributes["onkeypress"] = "return event.charCode >= 48 && event.charCode <= 57;";
                // Tự động xóa sạch các ký tự không phải số ngay khi người dùng thao tác dán (paste) dữ liệu vào
                tb.Attributes["oninput"] = "this.value = this.value.replace(/\\D/g, '');";
            }
        }

        // Hàm bổ trợ thực thi mã lệnh JavaScript sau khi trang đã tải hoàn tất (kể cả các thư viện JS ngoài như Bootstrap đặt cuối trang)
        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, this.GetType(), key, script, true);
        }

        // Kích hoạt hiển thị hộp thoại Modal Sửa nhà cung cấp trên giao diện
        private void MoModalSua()
        {
            ChayScriptSauKhiTaiTrang("PopModal",
                "var el = document.getElementById('modalSuaNCC');" +
                "if (el && window.bootstrap) { new bootstrap.Modal(el).show(); }");
        }

        // Ẩn/Đóng hộp thoại Modal Sửa (đảm bảo an toàn tuyệt đối ngay cả khi Modal chưa từng được mở)
        private void DongModalSua()
        {
            ChayScriptSauKhiTaiTrang("HideModal",
                "var el = document.getElementById('modalSuaNCC');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }
        // =====================================================================
        // 4. CHỨC NĂNG HIỂN THỊ VÀ TÌM KIẾM DỮ LIỆU (READ / SEARCH)
        // =====================================================================

        // Nạp danh sách nhà cung cấp lên GridView (có hỗ trợ lọc theo từ khóa tìm kiếm)
        private void BindGrid(string keyword = "")
        {
            string query = "SELECT MaNCC, TenNCC, DiaChi, SoDienThoai, Email FROM NhaCungCap";
            SqlParameter[] parameters = null;

            if (!string.IsNullOrEmpty(keyword))
            {
                query += " WHERE MaNCC LIKE @kw OR TenNCC LIKE @kw OR SoDienThoai LIKE @kw";
                parameters = new SqlParameter[]
                {
                    new SqlParameter("@kw", "%" + keyword + "%")
                };
            }

            gvNhaCungCap.DataSource = DatabaseHelper.ExecuteQuery(query, parameters);
            gvNhaCungCap.DataBind();
        }

        // Xử lý sự kiện bấm nút Tìm kiếm
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(txtSearch.Text.Trim());
        }

        // Xử lý sự kiện bấm nút Làm mới / Reset bộ lọc tìm kiếm
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindGrid();
        }
        // =====================================================================
        // 5. CHỨC NĂNG THÊM MỚI NHÀ CUNG CẤP (CREATE)
        // =====================================================================
        protected void btnLuuNCC_Click(object sender, EventArgs e)
        {
            string maNCC = txtMaNCC.Text.Trim();
            string tenNCC = txtTenNCC.Text.Trim();
            string sdt = txtSoDienThoai.Text.Trim();
            string email = txtEmail.Text.Trim();
            string diaChi = txtDiaChi.Text.Trim();

            // Kiểm tra các trường dữ liệu bắt buộc không được bỏ trống
            if (string.IsNullOrEmpty(maNCC) || string.IsNullOrEmpty(tenNCC) || string.IsNullOrEmpty(sdt))
            {
                HienThiThongBao("Vui lòng điền đầy đủ các thông tin bắt buộc (*)", "danger");
                return;
            }

            // Kiểm tra định dạng tính hợp lệ của số điện thoại bằng Regex (phòng trường hợp người dùng lách luật qua mặt trình duyệt)
            if (!RegexSDT.IsMatch(sdt))
            {
                HienThiThongBao("Số điện thoại phải bắt đầu bằng 0 và gồm đúng 10 hoặc 11 chữ số (không chứa chữ cái).", "danger");
                return;
            }

            try
            {
                string query = "INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SoDienThoai, Email) VALUES (@Ma, @Ten, @DiaChi, @SDT, @Email)";
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maNCC),
                    new SqlParameter("@Ten", tenNCC),
                    new SqlParameter("@DiaChi", diaChi),
                    new SqlParameter("@SDT", sdt),
                    new SqlParameter("@Email", email)
                };

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                HienThiThongBao("Thêm nhà cung cấp thành công!", "success");

                // Xóa sạch các ô nhập liệu sau khi thêm mới thành công
                txtMaNCC.Text = "";
                txtTenNCC.Text = "";
                txtSoDienThoai.Text = "";
                txtEmail.Text = "";
                txtDiaChi.Text = "";

                BindGrid(); // Tải lại danh sách trên bảng
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi thêm nhà cung cấp (Có thể trùng mã): " + ex.Message, "danger");
            }
        }
