using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class HangHoa : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLoaiHang();
                BindGrid();
            }
        }

        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, this.GetType(), key, script, true);
        }

        private void MoModalSua()
        {
            ChayScriptSauKhiTaiTrang("PopModalSua",
                "var el = document.getElementById('modalSuaHang');" +
                "if (el && window.bootstrap) { new bootstrap.Modal(el).show(); }");
        }

        private void DongModalSua()
        {
            ChayScriptSauKhiTaiTrang("HideModalSua",
                "var el = document.getElementById('modalSuaHang');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

        private void HienThiThongBao(string message, string type)
        {
            string msgJs = HttpUtility.JavaScriptStringEncode(message);
            string typeJs = HttpUtility.JavaScriptStringEncode(type);

            string js =
                "var d = document.createElement('div');" +
                "d.className = 'alert alert-" + typeJs + " alert-dismissible fade show shadow';" +
                "d.setAttribute('role', 'alert');" +
                "d.style.cssText = 'position:fixed;top:20px;right:20px;z-index:2000;max-width:420px;';" +
                "d.appendChild(document.createTextNode('" + msgJs + "'));" +
                "var b = document.createElement('button');" +
                "b.type = 'button'; b.className = 'btn-close';" +
                "b.setAttribute('data-bs-dismiss', 'alert'); b.setAttribute('aria-label', 'Close');" +
                "d.appendChild(b);" +
                "document.body.appendChild(d);" +
                "setTimeout(function () { if (d.parentNode) { d.parentNode.removeChild(d); } }, 5000);";

            ChayScriptSauKhiTaiTrang("ThongBao", js);
        }

        private void DoDuLieuVaoFormSua(DataRow row)
        {
            txtSuaMaHang.Text = row["MaHangHoa"].ToString();
            txtSuaTenHang.Text = row["TenHangHoa"].ToString();
            ddlSuaLoaiHang.SelectedValue = row["MaLoai"].ToString();
            txtSuaDonViTinh.Text = row["DonViTinh"].ToString();

            txtSuaDonGia.Text = Convert.ToDecimal(row["DonGia"]).ToString("0.##", CultureInfo.InvariantCulture);

            if (row["HanSuDung"] != DBNull.Value)
            {
                txtSuaHanSuDung.Text = Convert.ToDateTime(row["HanSuDung"]).ToString("yyyy-MM-dd");
            }
        }

        private void LoadLoaiHang()
        {
            string query = "SELECT MaLoai, TenLoai FROM LoaiHangHoa";
            DataTable dt = DatabaseHelper.ExecuteQuery(query);

            ddlLoaiHang.DataSource = dt;
            ddlLoaiHang.DataTextField = "TenLoai";
            ddlLoaiHang.DataValueField = "MaLoai";
            ddlLoaiHang.DataBind();
            ddlLoaiHang.Items.Insert(0, new ListItem("-- Tất cả loại hàng hóa --", ""));

            ddlThemLoaiHang.DataSource = dt;
            ddlThemLoaiHang.DataTextField = "TenLoai";
            ddlThemLoaiHang.DataValueField = "MaLoai";
            ddlThemLoaiHang.DataBind();

            ddlSuaLoaiHang.DataSource = dt;
            ddlSuaLoaiHang.DataTextField = "TenLoai";
            ddlSuaLoaiHang.DataValueField = "MaLoai";
            ddlSuaLoaiHang.DataBind();
        }

        private void BindGrid(string searchKeyword = "", string maLoai = "")
        {
            string query = @"SELECT h.MaHangHoa, h.TenHangHoa, l.TenLoai, h.DonViTinh, h.DonGia, h.HanSuDung 
                             FROM HangHoa h 
                             INNER JOIN LoaiHangHoa l ON h.MaLoai = l.MaLoai 
                             WHERE (h.TenHangHoa LIKE @keyword OR h.MaHangHoa LIKE @keyword)";

            if (!string.IsNullOrEmpty(maLoai))
            {
                query += " AND h.MaLoai = @maLoai";
            }

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@keyword", "%" + searchKeyword + "%"),
                new SqlParameter("@maLoai", string.IsNullOrEmpty(maLoai) ? (object)DBNull.Value : maLoai)
            };

            gvHangHoa.DataSource = DatabaseHelper.ExecuteQuery(query, parameters);
            gvHangHoa.DataBind();
        }

        protected void btnLưuHang_Click(object sender, EventArgs e)
        {
            string query = "INSERT INTO HangHoa (MaHangHoa, TenHangHoa, DonViTinh, DonGia, HanSuDung, MaLoai) VALUES (@Ma, @Ten, @DVT, @Gia, @HSD, @MaLoai)";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@Ma", txtMaHang.Text.Trim()),
                new SqlParameter("@Ten", txtTenHang.Text.Trim()),
                new SqlParameter("@DVT", txtDonViTinh.Text.Trim()),
                new SqlParameter("@Gia", Convert.ToDecimal(txtDonGia.Text.Trim())),
                new SqlParameter("@HSD", Convert.ToDateTime(txtHanSuDung.Text)),
                new SqlParameter("@MaLoai", ddlThemLoaiHang.SelectedValue)
            };

            DatabaseHelper.ExecuteNonQuery(query, parameters);

            BindGrid();
        }

        protected void gvHangHoa_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                string maHang = e.CommandArgument.ToString();

                string query = "SELECT * FROM HangHoa WHERE MaHangHoa = @Ma";
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maHang)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    DoDuLieuVaoFormSua(dt.Rows[0]);
                    MoModalSua();
                }
                else
                {
                    HienThiThongBao("Hàng hóa " + maHang + " không còn tồn tại (có thể đã bị xóa).", "danger");
                    BindGrid();
                }
            }
            else if (e.CommandName == "DeleteItem")
            {
                string maHang = e.CommandArgument.ToString();
                string query = "DELETE FROM HangHoa WHERE MaHangHoa = @Ma";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maHang)
                };

                DatabaseHelper.ExecuteNonQuery(query, parameters);
                BindGrid();
            }
        }

        protected void btnLuuSuaHang_Click(object sender, EventArgs e)
        {
            string ma = txtSuaMaHang.Text.Trim();
            string ten = txtSuaTenHang.Text.Trim();
            string dvt = txtSuaDonViTinh.Text.Trim();
            string giaText = txtSuaDonGia.Text.Trim();
            string hsdText = txtSuaHanSuDung.Text.Trim();

            if (ten.Length == 0 || dvt.Length == 0 || giaText.Length == 0 || hsdText.Length == 0)
            {
                HienThiThongBao("Vui lòng nhập đầy đủ tên, đơn vị tính, đơn giá và hạn sử dụng.", "danger");
                MoModalSua();
                return;
            }
            if (ten.Length > 150 || dvt.Length > 20)
            {
                HienThiThongBao("Tên hàng tối đa 150 ký tự, đơn vị tính tối đa 20 ký tự.", "danger");
                MoModalSua();
                return;
            }

            decimal gia;
            if (!decimal.TryParse(giaText, NumberStyles.Number, CultureInfo.InvariantCulture, out gia) || gia < 0)
            {
                HienThiThongBao("Đơn giá phải là số không âm (ví dụ: 92000).", "danger");
                MoModalSua();
                return;
            }

            DateTime hsd;
            if (!DateTime.TryParse(hsdText, CultureInfo.InvariantCulture, DateTimeStyles.None, out hsd))
            {
                HienThiThongBao("Hạn sử dụng không hợp lệ.", "danger");
                MoModalSua();
                return;
            }

            try
            {
                string query = @"UPDATE HangHoa 
                     SET TenHangHoa = @Ten, 
                         DonViTinh = @DVT, 
                         DonGia = @Gia, 
                         HanSuDung = @HSD, 
                         MaLoai = @MaLoai 
                     WHERE MaHangHoa = @Ma";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", ma),
                    new SqlParameter("@Ten", ten),
                    new SqlParameter("@DVT", dvt),
                    new SqlParameter("@Gia", gia),
                    new SqlParameter("@HSD", hsd),
                    new SqlParameter("@MaLoai", ddlSuaLoaiHang.SelectedValue)
                };

                int n = DatabaseHelper.ExecuteNonQuery(query, parameters);
                if (n == 0)
                {
                    HienThiThongBao("Hàng hóa " + ma + " không còn tồn tại nên không thể cập nhật.", "danger");
                    BindGrid();
                    return;
                }

                HienThiThongBao("Cập nhật hàng hóa " + ma + " thành công!", "success");
                BindGrid();

                DongModalSua();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi cập nhật hàng hóa: " + ex.Message, "danger");
                MoModalSua();
            }
        }

        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string maHang = txtSuaMaHang.Text.Trim();

            string query = "SELECT * FROM HangHoa WHERE MaHangHoa = @Ma";
            SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maHang) };
            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DoDuLieuVaoFormSua(dt.Rows[0]);
            }

            MoModalSua();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlLoaiHang.SelectedIndex = 0;
            BindGrid();
        }
    }
}
