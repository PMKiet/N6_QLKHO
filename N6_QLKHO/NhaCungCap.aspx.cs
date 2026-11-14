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

        // Kích hoạt hiển thị hộp thoại Modal Thêm nhà cung cấp trên giao diện
        private void MoModalThem()
        {
            ChayScriptSauKhiTaiTrang("PopModalThem",
                "var el = document.getElementById('modalThemNCC');" +
                "if (el && window.bootstrap) { bootstrap.Modal.getOrCreateInstance(el).show(); }");
        }

        // Ẩn/Đóng hộp thoại Modal Thêm
        private void DongModalThem()
        {
            ChayScriptSauKhiTaiTrang("HideModalThem",
                "var el = document.getElementById('modalThemNCC');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

        // Kích hoạt hiển thị hộp thoại Modal Sửa nhà cung cấp trên giao diện
        private void MoModalSua()
        {
            ChayScriptSauKhiTaiTrang("PopModal",
                "var el = document.getElementById('modalSuaNCC');" +
                "if (el && window.bootstrap) { bootstrap.Modal.getOrCreateInstance(el).show(); }");
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
            string query = "SELECT RTRIM(LTRIM(MaNCC)) AS MaNCC, TenNCC, DiaChi, SoDienThoai, Email FROM NhaCungCap";
            SqlParameter[] parameters = null;

            if (!string.IsNullOrEmpty(keyword))
            {
                query += " WHERE MaNCC LIKE @kw OR TenNCC LIKE @kw OR SoDienThoai LIKE @kw";
                parameters = new SqlParameter[]
                {
                    new SqlParameter("@kw", "%" + keyword + "%")
                };
            }

            query += " ORDER BY MaNCC";

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
                MoModalThem();
                return;
            }

            // Kiểm tra định dạng tính hợp lệ của số điện thoại bằng Regex (phòng trường hợp người dùng lách luật qua mặt trình duyệt)
            if (!RegexSDT.IsMatch(sdt))
            {
                HienThiThongBao("Số điện thoại phải bắt đầu bằng 0 và gồm đúng 10 hoặc 11 chữ số (không chứa chữ cái).", "danger");
                MoModalThem();
                return;
            }

            try
            {
                object checkCount = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM NhaCungCap WHERE RTRIM(LTRIM(MaNCC)) = @Ma",
                    new SqlParameter[] { new SqlParameter("@Ma", maNCC) });
                if (Convert.ToInt32(checkCount) > 0)
                {
                    HienThiThongBao("Mã nhà cung cấp \"" + maNCC + "\" đã tồn tại trong hệ thống!", "danger");
                    MoModalThem();
                    return;
                }

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
                HienThiThongBao("Thêm nhà cung cấp " + maNCC + " thành công!", "success");

                // Xóa sạch các ô nhập liệu sau khi thêm mới thành công
                txtMaNCC.Text = "";
                txtTenNCC.Text = "";
                txtSoDienThoai.Text = "";
                txtEmail.Text = "";
                txtDiaChi.Text = "";

                DongModalThem();
                BindGrid(txtSearch.Text.Trim()); // Tải lại danh sách trên bảng
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi thêm nhà cung cấp: " + DatabaseHelper.LayThongBaoLoi(ex), "danger");
                MoModalThem();
            }
        }
        // =====================================================================
        // 6. XỬ LÝ SỰ KIỆN TRÊN DÒNG GRIDVIEW (EDIT / DELETE ROUTING)
        // =====================================================================
        protected void gvNhaCungCap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                // Khi bấm nút Sửa (icon bút): lấy mã nhà cung cấp, truy vấn lấy thông tin cũ đổ vào modal sửa rồi mở modal lên
                string maNCC = Convert.ToString(e.CommandArgument).Trim();
                string query = "SELECT * FROM NhaCungCap WHERE RTRIM(LTRIM(MaNCC)) = @Ma";
                SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maNCC) };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    txtSuaMaNCC.Text = Convert.ToString(row["MaNCC"]).Trim();
                    txtSuaTenNCC.Text = Convert.ToString(row["TenNCC"]);
                    txtSuaSoDienThoai.Text = Convert.ToString(row["SoDienThoai"]);
                    txtSuaEmail.Text = Convert.ToString(row["Email"]);
                    txtSuaDiaChi.Text = Convert.ToString(row["DiaChi"]);

                    MoModalSua(); // Hiển thị Modal Sửa lên màn hình
                }
                else
                {
                    HienThiThongBao("Nhà cung cấp " + maNCC + " không còn tồn tại (có thể đã bị xóa).", "danger");
                    BindGrid(txtSearch.Text.Trim());
                }
            }
            else if (e.CommandName == "DeleteItem")
            {
                // Khi bấm nút Xóa (icon thùng rác): thực hiện xóa nhà cung cấp theo mã tương ứng
                string maNCC = Convert.ToString(e.CommandArgument).Trim();
                try
                {
                    string query = "DELETE FROM NhaCungCap WHERE RTRIM(LTRIM(MaNCC)) = @Ma";
                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maNCC) };
                    DatabaseHelper.ExecuteNonQuery(query, parameters);
                    HienThiThongBao("Đã xóa nhà cung cấp " + maNCC + " thành công!", "success");
                    BindGrid(txtSearch.Text.Trim());
                }
                catch (Exception)
                {
                    // Bắt lỗi ràng buộc khóa ngoại nếu nhà cung cấp này đang được sử dụng ở bảng phiếu nhập
                    HienThiThongBao("Không thể xóa do nhà cung cấp này đang có phiếu nhập liên quan!", "danger");
                }
            }
        }
        // =====================================================================
        // 7. CHỨC NĂNG CẬP NHẬT / LƯU THÔNG TIN SỬA (UPDATE)
        // =====================================================================
        protected void btnLuuSuaNCC_Click(object sender, EventArgs e)
        {
            string maNCC = txtSuaMaNCC.Text.Trim();
            string tenNCC = txtSuaTenNCC.Text.Trim();
            string sdt = txtSuaSoDienThoai.Text.Trim();
            string email = txtSuaEmail.Text.Trim();
            string diaChi = txtSuaDiaChi.Text.Trim();

            // Kiểm tra các trường thông tin bắt buộc trong form sửa
            if (string.IsNullOrEmpty(tenNCC) || string.IsNullOrEmpty(sdt))
            {
                HienThiThongBao("Tên và số điện thoại không được để trống!", "danger");
                MoModalSua(); // Giữ form sửa tiếp tục mở để người dùng nhập bù thông tin
                return;
            }

            // Kiểm tra lại tính hợp lệ của số điện thoại sau khi sửa
            if (!RegexSDT.IsMatch(sdt))
            {
                HienThiThongBao("Số điện thoại phải bắt đầu bằng 0 và gồm đúng 10 hoặc 11 chữ số (không chứa chữ cái).", "danger");
                MoModalSua(); // Giữ form sửa mở để người dùng chỉnh sửa lại
                return;
            }

            try
            {
                string query = "UPDATE NhaCungCap SET TenNCC = @Ten, DiaChi = @DiaChi, SoDienThoai = @SDT, Email = @Email WHERE RTRIM(LTRIM(MaNCC)) = @Ma";
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maNCC),
                    new SqlParameter("@Ten", tenNCC),
                    new SqlParameter("@DiaChi", diaChi),
                    new SqlParameter("@SDT", sdt),
                    new SqlParameter("@Email", email)
                };

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                HienThiThongBao("Cập nhật thông tin nhà cung cấp " + maNCC + " thành công!", "success");
                BindGrid(txtSearch.Text.Trim());

                DongModalSua(); // Đóng Modal Sửa sau khi cập nhật thành công
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi cập nhật nhà cung cấp: " + DatabaseHelper.LayThongBaoLoi(ex), "danger");
                MoModalSua(); // Giữ modal mở nếu xảy ra lỗi ngoại lệ CSDL
            }
        }
        // =====================================================================
        // 8. CHỨC NĂNG LÀM MỚI / HOÀN TÁC DỮ LIỆU TRONG MODAL SỬA (RESET MODAL)
        // =====================================================================
        // Tải lại nguyên bản dữ liệu cũ từ cơ sở dữ liệu đổ ngược lại vào các ô nhập trong modal (hủy các thay đổi đang nhập dở)
        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string maNCC = txtSuaMaNCC.Text.Trim();
            string query = "SELECT * FROM NhaCungCap WHERE RTRIM(LTRIM(MaNCC)) = @Ma";
            SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maNCC) };
            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtSuaTenNCC.Text = row["TenNCC"].ToString();
                txtSuaSoDienThoai.Text = row["SoDienThoai"].ToString();
                txtSuaEmail.Text = row["Email"].ToString();
                txtSuaDiaChi.Text = row["DiaChi"].ToString();
            }

            MoModalSua(); // Giữ modal mở sau khi reset
        }
        // =====================================================================
        // 9. HÀM HIỂN THỊ THÔNG BÁO TRẠNG THÁI (NOTIFICATION HELPER)
        // =====================================================================
        // Tạo khung HTML cảnh báo Bootstrap động để thông báo thành công hoặc lỗi cho người dùng
        private void HienThiThongBao(string message, string type)
        {
            lblThongBao.Text = $"<div class='alert alert-{type} alert-dismissible fade show' role='alert'>" +
                               $"<i class='fa-solid fa-circle-exclamation me-2'></i> {message}" +
                               $"<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               $"</div>";
        }
    }
}
