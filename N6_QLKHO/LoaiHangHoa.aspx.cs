using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class LoaiHangHoa : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        // =====================================================================
        // HÀM HỖ TRỢ THÔNG BÁO VÀ MỞ / ĐÓNG FORM (MODAL)
        // =====================================================================
        // Chạy script sau khi trang tải xong (kể cả thư viện Bootstrap nằm cuối trang)
        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, GetType(), key, script, true);
        }

        // Hiện hộp thoại thông báo (đã mã hóa an toàn nội dung)
        private void ThongBao(string message)
        {
            ChayScriptSauKhiTaiTrang("alert", "alert('" + HttpUtility.JavaScriptStringEncode(message) + "');");
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

        // =====================================================================
        // HIỂN THỊ DỮ LIỆU
        // =====================================================================
        private void LoadData(string keyword = "")
        {
            string query = "SELECT MaLoai, TenLoai, MoTa FROM LoaiHangHoa WHERE @Keyword = '' OR MaLoai LIKE @LikeKey OR TenLoai LIKE @LikeKey ORDER BY MaLoai";

            SqlParameter[] parameters = {
                new SqlParameter("@Keyword", keyword),
                new SqlParameter("@LikeKey", "%" + keyword + "%")
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
            gvLoaiHangHoa.DataSource = dt;
            gvLoaiHangHoa.DataBind();
        }

        // =====================================================================
        // THÊM MỚI
        // =====================================================================
        protected void btnLưu_Click(object sender, EventArgs e)
        {
            string maLoai = txtMaLoai.Text.Trim();
            string tenLoai = txtTenLoai.Text.Trim();
            string moTa = txtMoTa.Text.Trim();

            if (string.IsNullOrEmpty(maLoai) || string.IsNullOrEmpty(tenLoai))
            {
                ThongBao("Vui lòng điền đầy đủ Mã loại và Tên loại hàng hóa!");
                MoModal("modalThemLoai"); // Mở lại form để người dùng nhập tiếp
                return;
            }

            if (maLoai.Length > 10)
            {
                ThongBao("Mã loại tối đa 10 ký tự!");
                MoModal("modalThemLoai");
                return;
            }

            if (tenLoai.Length > 100)
            {
                ThongBao("Tên loại hàng hóa tối đa 100 ký tự!");
                MoModal("modalThemLoai");
                return;
            }

            try
            {
                // Kiểm tra mã loại đã tồn tại chưa
                string checkQuery = "SELECT COUNT(1) FROM LoaiHangHoa WHERE MaLoai = @MaLoai";
                SqlParameter[] checkParams = {
                    new SqlParameter("@MaLoai", maLoai)
                };

                int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkParams));
                if (count > 0)
                {
                    ThongBao("Mã loại này đã tồn tại trong hệ thống. Vui lòng nhập mã khác!");
                    MoModal("modalThemLoai");
                    return;
                }

                // Thực hiện thêm mới
                string insertQuery = "INSERT INTO LoaiHangHoa (MaLoai, TenLoai, MoTa) VALUES (@MaLoai, @TenLoai, @MoTa)";
                SqlParameter[] insertParams = {
                    new SqlParameter("@MaLoai", maLoai),
                    new SqlParameter("@TenLoai", tenLoai),
                    new SqlParameter("@MoTa", moTa)
                };

                DatabaseHelper.ExecuteNonQuery(insertQuery, insertParams);
                LoadData(txtSearch.Text.Trim());
                ClearForm();

                // Đóng form và báo thành công
                DongModal("modalThemLoai");
                ThongBao("Thêm mới loại hàng hóa thành công!");
            }
            catch (Exception ex)
            {
                ThongBao("Lỗi xử lý dữ liệu: " + ex.Message);
                MoModal("modalThemLoai");
            }
        }

        // =====================================================================
        // SỬA / XÓA TRÊN TỪNG DÒNG CỦA BẢNG
        // =====================================================================
        protected void gvLoaiHangHoa_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                // Bấm icon bút xanh: đọc dữ liệu dòng đó đổ vào form sửa rồi mở form
                string maLoai = e.CommandArgument.ToString();
                DataTable dt = LayLoaiHang(maLoai);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    txtSuaMaLoai.Text = row["MaLoai"].ToString();
                    txtSuaTenLoai.Text = row["TenLoai"].ToString();
                    txtSuaMoTa.Text = row["MoTa"].ToString();

                    MoModal("modalSuaLoai");
                }
                else
                {
                    ThongBao("Loại hàng hóa " + maLoai + " không còn tồn tại (có thể đã bị xóa)!");
                    LoadData(txtSearch.Text.Trim());
                }
            }
            else if (e.CommandName == "DeleteItem")
            {
                string maLoai = e.CommandArgument.ToString();

                try
                {
                    string deleteQuery = "DELETE FROM LoaiHangHoa WHERE MaLoai = @MaLoai";
                    SqlParameter[] deleteParams = {
                        new SqlParameter("@MaLoai", maLoai)
                    };

                    DatabaseHelper.ExecuteNonQuery(deleteQuery, deleteParams);
                    LoadData(txtSearch.Text.Trim());
                }
                catch (Exception)
                {
                    ThongBao("Không thể xóa vì loại hàng hóa này đang được liên kết với bảng Hàng Hóa!");
                }
            }
        }

        // Lấy thông tin 1 loại hàng hóa theo mã
        private DataTable LayLoaiHang(string maLoai)
        {
            string query = "SELECT MaLoai, TenLoai, MoTa FROM LoaiHangHoa WHERE MaLoai = @MaLoai";
            SqlParameter[] parameters = { new SqlParameter("@MaLoai", maLoai) };
            return DatabaseHelper.ExecuteQuery(query, parameters);
        }

        // =====================================================================
        // LƯU THÔNG TIN SAU KHI CHỈNH SỬA
        // =====================================================================
        protected void btnLuuSuaLoai_Click(object sender, EventArgs e)
        {
            string maLoai = txtSuaMaLoai.Text.Trim();
            string tenLoai = txtSuaTenLoai.Text.Trim();
            string moTa = txtSuaMoTa.Text.Trim();

            if (string.IsNullOrEmpty(tenLoai))
            {
                ThongBao("Tên loại hàng hóa không được để trống!");
                MoModal("modalSuaLoai"); // Mở lại form sửa để người dùng nhập tiếp
                return;
            }

            if (tenLoai.Length > 100)
            {
                ThongBao("Tên loại hàng hóa tối đa 100 ký tự!");
                MoModal("modalSuaLoai");
                return;
            }

            try
            {
                string updateQuery = "UPDATE LoaiHangHoa SET TenLoai = @TenLoai, MoTa = @MoTa WHERE MaLoai = @MaLoai";
                SqlParameter[] updateParams = {
                    new SqlParameter("@TenLoai", tenLoai),
                    new SqlParameter("@MoTa", moTa),
                    new SqlParameter("@MaLoai", maLoai)
                };

                int n = DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams);
                LoadData(txtSearch.Text.Trim());

                DongModal("modalSuaLoai");
                if (n == 0)
                    ThongBao("Loại hàng hóa " + maLoai + " không còn tồn tại nên không thể cập nhật!");
                else
                    ThongBao("Cập nhật loại hàng hóa " + maLoai + " thành công!");
            }
            catch (Exception ex)
            {
                ThongBao("Lỗi cập nhật: " + ex.Message);
                MoModal("modalSuaLoai"); // Giữ form sửa mở để người dùng chỉnh lại
            }
        }

        // =====================================================================
        // NÚT LÀM MỚI TRONG FORM SỬA: nạp lại dữ liệu gốc từ CSDL
        // =====================================================================
        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            DataTable dt = LayLoaiHang(txtSuaMaLoai.Text.Trim());

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtSuaTenLoai.Text = row["TenLoai"].ToString();
                txtSuaMoTa.Text = row["MoTa"].ToString();
            }

            MoModal("modalSuaLoai"); // Giữ form mở để tiếp tục chỉnh sửa
        }

        // =====================================================================
        // TÌM KIẾM, LÀM MỚI, PHÂN TRANG
        // =====================================================================
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            gvLoaiHangHoa.PageIndex = 0;
            LoadData(txtSearch.Text.Trim());
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            gvLoaiHangHoa.PageIndex = 0;
            LoadData(txtSearch.Text.Trim());
        }

        protected void btnLamMoi_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            gvLoaiHangHoa.PageIndex = 0;
            LoadData();
        }

        protected void gvLoaiHangHoa_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLoaiHangHoa.PageIndex = e.NewPageIndex;
            LoadData(txtSearch.Text.Trim());
        }

        private void ClearForm()
        {
            txtMaLoai.Text = "";
            txtTenLoai.Text = "";
            txtMoTa.Text = "";
        }
    }
}
