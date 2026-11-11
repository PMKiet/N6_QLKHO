using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class NhaCungCap : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        // 1. Hiển thị dữ liệu lên GridView (hỗ trợ tìm kiếm)
        private void BindGrid(string keyword)
        {
            string query = "SELECT MaNCC, TenNCC, DiaChi, SoDienThoai, Email FROM NhaCungCap";
            SqlParameter[] parameters = null;

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query + " WHERE MaNCC LIKE @kw OR TenNCC LIKE @kw OR SoDienThoai LIKE @kw";
                parameters = new SqlParameter[1];
                parameters[0] = new SqlParameter("@kw", "%" + keyword + "%");
            }

            gvNhaCungCap.DataSource = DatabaseHelper.ExecuteQuery(query, parameters);
            gvNhaCungCap.DataBind();
        }

        // Overload phương thức BindGrid không tham số
        private void BindGrid()
        {
            BindGrid("");
        }

        // 2. Thêm mới nhà cung cấp
        protected void btnLuuNCC_Click(object sender, EventArgs e)
        {
            string maNCC = txtMaNCC.Text.Trim();
            string tenNCC = txtTenNCC.Text.Trim();
            string sdt = txtSoDienThoai.Text.Trim();
            string email = txtEmail.Text.Trim();
            string diaChi = txtDiaChi.Text.Trim();

            if (string.IsNullOrEmpty(maNCC) || string.IsNullOrEmpty(tenNCC) || string.IsNullOrEmpty(sdt))
            {
                HienThiThongBao("Vui lòng điền đầy đủ các thông tin bắt buộc (*)", "danger");
                return;
            }

            try
            {
                string query = "INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SoDienThoai, Email) VALUES (@Ma, @Ten, @DiaChi, @SDT, @Email)";
                SqlParameter[] parameters = new SqlParameter[5];
                parameters[0] = new SqlParameter("@Ma", maNCC);
                parameters[1] = new SqlParameter("@Ten", tenNCC);
                parameters[2] = new SqlParameter("@DiaChi", diaChi);
                parameters[3] = new SqlParameter("@SDT", sdt);
                parameters[4] = new SqlParameter("@Email", email);

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                HienThiThongBao("Thêm nhà cung cấp thành công!", "success");

                txtMaNCC.Text = "";
                txtTenNCC.Text = "";
                txtSoDienThoai.Text = "";
                txtEmail.Text = "";
                txtDiaChi.Text = "";

                BindGrid();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi thêm nhà cung cấp (Có thể trùng mã): " + ex.Message, "danger");
            }
        }

        // 3. Bật chế độ sửa trực tiếp trên dòng (RowEditing)
        protected void gvNhaCungCap_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvNhaCungCap.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        // 4. Hủy chỉnh sửa trực tiếp (RowCancelingEdit)
        protected void gvNhaCungCap_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvNhaCungCap.EditIndex = -1;
            BindGrid();
        }

        // 5. Cập nhật dữ liệu chỉnh sửa trực tiếp vào cơ sở dữ liệu (RowUpdating)
        protected void gvNhaCungCap_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = gvNhaCungCap.Rows[e.RowIndex];
            string maNCC = gvNhaCungCap.DataKeys[e.RowIndex].Value.ToString();

            TextBox txtTen = (TextBox)row.FindControl("txtEditTenNCC");
            TextBox txtSDT = (TextBox)row.FindControl("txtEditSoDienThoai");
            TextBox txtEmailEdit = (TextBox)row.FindControl("txtEditEmail");
            TextBox txtDiaChiEdit = (TextBox)row.FindControl("txtEditDiaChi");

            if (txtTen == null || txtSDT == null || string.IsNullOrEmpty(txtTen.Text.Trim()) || string.IsNullOrEmpty(txtSDT.Text.Trim()))
            {
                HienThiThongBao("Tên và số điện thoại không được để trống!", "danger");
                return;
            }

            try
            {
                string diaChiVal = "";
                if (txtDiaChiEdit != null)
                {
                    diaChiVal = txtDiaChiEdit.Text.Trim();
                }

                string emailVal = "";
                if (txtEmailEdit != null)
                {
                    emailVal = txtEmailEdit.Text.Trim();
                }

                string query = "UPDATE NhaCungCap SET TenNCC = @Ten, DiaChi = @DiaChi, SoDienThoai = @SDT, Email = @Email WHERE MaNCC = @Ma";
                SqlParameter[] parameters = new SqlParameter[5];
                parameters[0] = new SqlParameter("@Ma", maNCC);
                parameters[1] = new SqlParameter("@Ten", txtTen.Text.Trim());
                parameters[2] = new SqlParameter("@DiaChi", diaChiVal);
                parameters[3] = new SqlParameter("@SDT", txtSDT.Text.Trim());
                parameters[4] = new SqlParameter("@Email", emailVal);

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                HienThiThongBao("Cập nhật thông tin nhà cung cấp thành công!", "success");

                gvNhaCungCap.EditIndex = -1;
                BindGrid();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi cập nhật nhà cung cấp: " + ex.Message, "danger");
            }
        }

        // 6. Xử lý sự kiện dòng GridView (Xóa)
        protected void gvNhaCungCap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteItem")
            {
                string maNCC = e.CommandArgument.ToString();
                try
                {
                    string query = "DELETE FROM NhaCungCap WHERE MaNCC = @Ma";
                    SqlParameter[] parameters = new SqlParameter[1];
                    parameters[0] = new SqlParameter("@Ma", maNCC);

                    DatabaseHelper.ExecuteNonQuery(query, parameters);
                    HienThiThongBao("Đã xóa nhà cung cấp thành công!", "success");
                    BindGrid();
                }
                catch (Exception ex)
                {
                    HienThiThongBao("Không thể xóa do nhà cung cấp này đang có phiếu nhập liên quan!", "danger");
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindGrid();
        }

        private void HienThiThongBao(string message, string type)
        {
            lblThongBao.Text = "<div class='alert alert-" + type + " alert-dismissible fade show' role='alert'>" +
                               "<i class='fa-solid fa-circle-exclamation me-2'></i> " + message +
                               "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               "</div>";
        }
    }
}