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
        private static readonly Regex RegexSDT = new Regex(@"^0\d{9,10}$");

        protected void Page_Load(object sender, EventArgs e)
        {
            CauHinhSoDienThoai();

            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void CauHinhSoDienThoai()
        {
            TextBox[] cacOSdt = { txtSoDienThoai, txtSuaSoDienThoai };
            foreach (TextBox tb in cacOSdt)
            {
                tb.MaxLength = 11;
                tb.Attributes["inputmode"] = "numeric";
                tb.Attributes["onkeypress"] = "return event.charCode >= 48 && event.charCode <= 57;";
                tb.Attributes["oninput"] = "this.value = this.value.replace(/\\D/g, '');";
            }
        }

        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, this.GetType(), key, script, true);
        }

        private void MoModalSua()
        {
            ChayScriptSauKhiTaiTrang("PopModal",
                "var el = document.getElementById('modalSuaNCC');" +
                "if (el && window.bootstrap) { new bootstrap.Modal(el).show(); }");
        }

        private void DongModalSua()
        {
            ChayScriptSauKhiTaiTrang("HideModal",
                "var el = document.getElementById('modalSuaNCC');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindGrid();
        }

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

        protected void gvNhaCungCap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                string maNCC = e.CommandArgument.ToString();
                string query = "SELECT * FROM NhaCungCap WHERE MaNCC = @Ma";
                SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maNCC) };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    txtSuaMaNCC.Text = row["MaNCC"].ToString();
                    txtSuaTenNCC.Text = row["TenNCC"].ToString();
                    txtSuaSoDienThoai.Text = row["SoDienThoai"].ToString();
                    txtSuaEmail.Text = row["Email"].ToString();
                    txtSuaDiaChi.Text = row["DiaChi"].ToString();

                    MoModalSua();
                }
                else
                {
                    HienThiThongBao("Nhà cung cấp " + maNCC + " không còn tồn tại (có thể đã bị xóa).", "danger");
                    BindGrid();
                }
            }
            else if (e.CommandName == "DeleteItem")
            {
                string maNCC = e.CommandArgument.ToString();
                try
                {
                    string query = "DELETE FROM NhaCungCap WHERE MaNCC = @Ma";
                    SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maNCC) };
                    DatabaseHelper.ExecuteNonQuery(query, parameters);
                    HienThiThongBao("Đã xóa nhà cung cấp thành công!", "success");
                    BindGrid();
                }
                catch (Exception)
                {
                    HienThiThongBao("Không thể xóa do nhà cung cấp này đang có phiếu nhập liên quan!", "danger");
                }
            }
        }

        protected void btnLuuSuaNCC_Click(object sender, EventArgs e)
        {
            string maNCC = txtSuaMaNCC.Text.Trim();
            string tenNCC = txtSuaTenNCC.Text.Trim();
            string sdt = txtSuaSoDienThoai.Text.Trim();
            string email = txtSuaEmail.Text.Trim();
            string diaChi = txtSuaDiaChi.Text.Trim();

            if (string.IsNullOrEmpty(tenNCC) || string.IsNullOrEmpty(sdt))
            {
                HienThiThongBao("Tên và số điện thoại không được để trống!", "danger");
                MoModalSua();
                return;
            }

            if (!RegexSDT.IsMatch(sdt))
            {
                HienThiThongBao("Số điện thoại phải bắt đầu bằng 0 và gồm đúng 10 hoặc 11 chữ số (không chứa chữ cái).", "danger");
                MoModalSua();
                return;
            }

            try
            {
                string query = "UPDATE NhaCungCap SET TenNCC = @Ten, DiaChi = @DiaChi, SoDienThoai = @SDT, Email = @Email WHERE MaNCC = @Ma";
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maNCC),
                    new SqlParameter("@Ten", tenNCC),
                    new SqlParameter("@DiaChi", diaChi),
                    new SqlParameter("@SDT", sdt),
                    new SqlParameter("@Email", email)
                };

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                HienThiThongBao("Cập nhật thông tin nhà cung cấp thành công!", "success");
                BindGrid();

                DongModalSua();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi cập nhật nhà cung cấp: " + ex.Message, "danger");
                MoModalSua();
            }
        }

        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string maNCC = txtSuaMaNCC.Text.Trim();
            string query = "SELECT * FROM NhaCungCap WHERE MaNCC = @Ma";
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

            MoModalSua();
        }

        private void HienThiThongBao(string message, string type)
        {
            lblThongBao.Text = $"<div class='alert alert-{type} alert-dismissible fade show' role='alert'>" +
                               $"<i class='fa-solid fa-circle-exclamation me-2'></i> {message}" +
                               $"<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               $"</div>";
        }
    }
}
