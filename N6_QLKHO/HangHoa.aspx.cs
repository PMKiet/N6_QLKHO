using System;
using System.Data;
using System.Data.SqlClient;
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

        // 1. Tải danh sách loại hàng vào các Dropdown (Tìm kiếm, Thêm, Sửa)
        private void LoadLoaiHang()
        {
            string query = "SELECT MaLoai, TenLoai FROM LoaiHangHoa";
            DataTable dt = DatabaseHelper.ExecuteQuery(query);

            // Dropdown tìm kiếm
            ddlLoaiHang.DataSource = dt;
            ddlLoaiHang.DataTextField = "TenLoai";
            ddlLoaiHang.DataValueField = "MaLoai";
            ddlLoaiHang.DataBind();
            ddlLoaiHang.Items.Insert(0, new ListItem("-- Tất cả loại hàng hóa --", ""));

            // Dropdown trong Modal thêm mới
            ddlThemLoaiHang.DataSource = dt;
            ddlThemLoaiHang.DataTextField = "TenLoai";
            ddlThemLoaiHang.DataValueField = "MaLoai";
            ddlThemLoaiHang.DataBind();

            // Dropdown trong Modal chỉnh sửa
            ddlSuaLoaiHang.DataSource = dt;
            ddlSuaLoaiHang.DataTextField = "TenLoai";
            ddlSuaLoaiHang.DataValueField = "MaLoai";
            ddlSuaLoaiHang.DataBind();
        }

        // 2. Hiển thị dữ liệu lên GridView
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

        // 3. Xử lý Thêm mới hàng hóa
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

            BindGrid(); // Tải lại bảng
        }

        // 4. Xử lý sự kiện trên GridView (Sửa / Xóa)
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
                    DataRow row = dt.Rows[0];

                    txtSuaMaHang.Text = row["MaHangHoa"].ToString();
                    txtSuaTenHang.Text = row["TenHangHoa"].ToString();
                    ddlSuaLoaiHang.SelectedValue = row["MaLoai"].ToString();
                    txtSuaDonViTinh.Text = row["DonViTinh"].ToString();
                    txtSuaDonGia.Text = row["DonGia"].ToString();

                    if (row["HanSuDung"] != DBNull.Value)
                    {
                        txtSuaHanSuDung.Text = Convert.ToDateTime(row["HanSuDung"]).ToString("yyyy-MM-dd");
                    }

                    // Kích hoạt hiển thị Modal Sửa bằng JavaScript
                    string script = "var myModal = new bootstrap.Modal(document.getElementById('modalSuaHang')); myModal.show();";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", script, true);
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

        // 5. Xử lý Lưu thông tin sau khi chỉnh sửa
        protected void btnLuuSuaHang_Click(object sender, EventArgs e)
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
                new SqlParameter("@Ma", txtSuaMaHang.Text.Trim()),
                new SqlParameter("@Ten", txtSuaTenHang.Text.Trim()),
                new SqlParameter("@DVT", txtSuaDonViTinh.Text.Trim()),
                new SqlParameter("@Gia", Convert.ToDecimal(txtSuaDonGia.Text.Trim())),
                new SqlParameter("@HSD", Convert.ToDateTime(txtSuaHanSuDung.Text)),
                new SqlParameter("@MaLoai", ddlSuaLoaiHang.SelectedValue)
            };

            DatabaseHelper.ExecuteNonQuery(query, parameters);

            BindGrid(); // Tải lại bảng dữ liệu

            // Đóng Modal sau khi lưu thành công
            string script = "var myModalEl = document.getElementById('modalSuaHang'); var modal = bootstrap.Modal.getInstance(myModalEl); modal.hide();";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "HideModal", script, true);
        }

        // 6. Xử lý nút Làm mới trong Modal Sửa
        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string maHang = txtSuaMaHang.Text.Trim();

            string query = "SELECT * FROM HangHoa WHERE MaHangHoa = @Ma";
            SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maHang) };
            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtSuaTenHang.Text = row["TenHangHoa"].ToString();
                ddlSuaLoaiHang.SelectedValue = row["MaLoai"].ToString();
                txtSuaDonViTinh.Text = row["DonViTinh"].ToString();
                txtSuaDonGia.Text = row["DonGia"].ToString();
                if (row["HanSuDung"] != DBNull.Value)
                {
                    txtSuaHanSuDung.Text = Convert.ToDateTime(row["HanSuDung"]).ToString("yyyy-MM-dd");
                }
            }

            // Giữ Modal mở để tiếp tục chỉnh sửa
            string script = "var myModal = new bootstrap.Modal(document.getElementById('modalSuaHang')); myModal.show();";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", script, true);
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