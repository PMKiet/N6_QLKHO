using System;
using System.Data;
using System.Data.SqlClient;
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

        private void LoadData(string keyword = "")
        {
            string query = "SELECT MaLoai, TenLoai, MoTa FROM LoaiHangHoa WHERE @Keyword = '' OR MaLoai LIKE @LikeKey OR TenLoai LIKE @LikeKey";

            SqlParameter[] parameters = {
                new SqlParameter("@Keyword", keyword),
                new SqlParameter("@LikeKey", "%" + keyword + "%")
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
            gvLoaiHangHoa.DataSource = dt;
            gvLoaiHangHoa.DataBind();
        }

        protected void btnLưu_Click(object sender, EventArgs e)
        {
            string maLoai = txtMaLoai.Text.Trim();
            string tenLoai = txtTenLoai.Text.Trim();
            string moTa = txtMoTa.Text.Trim();

            if (string.IsNullOrEmpty(maLoai) || string.IsNullOrEmpty(tenLoai))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Vui lòng điền đầy đủ Mã loại và Tên loại hàng hóa!');", true);
                return;
            }

            // Kiểm tra mã loại đã tồn tại chưa bằng DatabaseHelper.ExecuteScalar
            string checkQuery = "SELECT COUNT(1) FROM LoaiHangHoa WHERE MaLoai = @MaLoai";
            SqlParameter[] checkParams = {
                new SqlParameter("@MaLoai", maLoai)
            };

            int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkParams));
            if (count > 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Mã loại này đã tồn tại trong hệ thống. Vui lòng nhập mã khác!');", true);
                return;
            }

            // Thực hiện thêm mới
            string insertQuery = "INSERT INTO LoaiHangHoa (MaLoai, TenLoai, MoTa) VALUES (@MaLoai, @TenLoai, @MoTa)";
            SqlParameter[] insertParams = {
                new SqlParameter("@MaLoai", maLoai),
                new SqlParameter("@TenLoai", tenLoai),
                new SqlParameter("@MoTa", moTa)
            };

            try
            {
                DatabaseHelper.ExecuteNonQuery(insertQuery, insertParams);
                LoadData();
                ClearForm();
                // Đóng modal và báo thành công
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "var myModal = bootstrap.Modal.getInstance(document.getElementById('modalThemLoai')); if(myModal) myModal.hide(); alert('Thêm mới loại hàng hóa thành công!');", true);
            }
            catch (Exception ex)
            {
                string errorMsg = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi xử lý dữ liệu: {errorMsg}');", true);
            }
        }

        protected void gvLoaiHangHoa_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvLoaiHangHoa.EditIndex = e.NewEditIndex;
            LoadData(txtSearch.Text.Trim());
        }

        protected void gvLoaiHangHoa_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvLoaiHangHoa.EditIndex = -1;
            LoadData(txtSearch.Text.Trim());
        }

        protected void gvLoaiHangHoa_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = gvLoaiHangHoa.Rows[e.RowIndex];
            string maLoai = gvLoaiHangHoa.DataKeys[e.RowIndex].Value.ToString();

            TextBox txtEditTenLoai = (TextBox)row.FindControl("txtEditTenLoai");
            TextBox txtEditMoTa = (TextBox)row.FindControl("txtEditMoTa");

            string tenLoai = txtEditTenLoai != null ? txtEditTenLoai.Text.Trim() : "";
            string moTa = txtEditMoTa != null ? txtEditMoTa.Text.Trim() : "";

            if (string.IsNullOrEmpty(tenLoai))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Tên loại hàng hóa không được để trống!');", true);
                return;
            }

            string updateQuery = "UPDATE LoaiHangHoa SET TenLoai = @TenLoai, MoTa = @MoTa WHERE MaLoai = @MaLoai";
            SqlParameter[] updateParams = {
                new SqlParameter("@TenLoai", tenLoai),
                new SqlParameter("@MoTa", moTa),
                new SqlParameter("@MaLoai", maLoai)
            };

            try
            {
                DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams);
                gvLoaiHangHoa.EditIndex = -1;
                LoadData(txtSearch.Text.Trim());
            }
            catch (Exception ex)
            {
                string errorMsg = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi cập nhật: {errorMsg}');", true);
            }
        }

        protected void gvLoaiHangHoa_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string maLoai = gvLoaiHangHoa.DataKeys[e.RowIndex].Value.ToString();

            string deleteQuery = "DELETE FROM LoaiHangHoa WHERE MaLoai = @MaLoai";
            SqlParameter[] deleteParams = {
                new SqlParameter("@MaLoai", maLoai)
            };

            try
            {
                DatabaseHelper.ExecuteNonQuery(deleteQuery, deleteParams);
                LoadData(txtSearch.Text.Trim());
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Không thể xóa vì loại hàng hóa này đang được liên kết với bảng Hàng Hóa!');", true);
            }
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadData(txtSearch.Text.Trim());
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadData(txtSearch.Text.Trim());
        }

        protected void btnLamMoi_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
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