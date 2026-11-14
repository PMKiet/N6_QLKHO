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
            else if (ddlThemLoaiHang.Items.Count == 0 || ddlSuaLoaiHang.Items.Count == 0 || ddlLoaiHang.Items.Count == 0)
            {
                LoadLoaiHang();
            }
        }

        // =====================================================================
        // HÀM HỖ TRỢ MỞ / ĐÓNG FORM (MODAL) VÀ THÔNG BÁO
        // =====================================================================
        // Chạy script sau khi trang tải xong (kể cả thư viện Bootstrap nằm cuối trang)
        private void ChayScriptSauKhiTaiTrang(string key, string js)
        {
            string script = "window.addEventListener('load', function () {" + js + "});";
            ScriptManager.RegisterStartupScript(this, this.GetType(), key, script, true);
        }

        // Mở form thêm mới
        private void MoModalThem()
        {
            ChayScriptSauKhiTaiTrang("PopModalThem",
                "var el = document.getElementById('modalThemHang');" +
                "if (el && window.bootstrap) { bootstrap.Modal.getOrCreateInstance(el).show(); }");
        }

        // Đóng form thêm mới
        private void DongModalThem()
        {
            ChayScriptSauKhiTaiTrang("HideModalThem",
                "var el = document.getElementById('modalThemHang');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

        // Mở form sửa
        private void MoModalSua()
        {
            ChayScriptSauKhiTaiTrang("PopModalSua",
                "var el = document.getElementById('modalSuaHang');" +
                "if (el && window.bootstrap) { bootstrap.Modal.getOrCreateInstance(el).show(); }");
        }

        // Đóng form sửa - an toàn kể cả khi form chưa từng được mở
        private void DongModalSua()
        {
            ChayScriptSauKhiTaiTrang("HideModalSua",
                "var el = document.getElementById('modalSuaHang');" +
                "if (el && window.bootstrap) { var m = bootstrap.Modal.getInstance(el); if (m) { m.hide(); } }");
        }

        // Hiển thị thông báo (success / danger) ở góc phải màn hình, tự tắt sau 5 giây
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

        // Chọn giá trị an toàn cho DropDownList (tránh lỗi ArgumentOutOfRangeException khi MaLoai có khoảng trắng hoặc chưa khớp)
        private void ChonGiaTriDropdownAnToan(DropDownList ddl, string value)
        {
            if (ddl == null || ddl.Items.Count == 0) return;
            ddl.ClearSelection();
            string cleanVal = (value ?? "").Trim();
            if (cleanVal.Length == 0)
            {
                ddl.SelectedIndex = 0;
                return;
            }

            ListItem item = ddl.Items.FindByValue(cleanVal);
            if (item == null)
            {
                foreach (ListItem li in ddl.Items)
                {
                    if (string.Equals(li.Value.Trim(), cleanVal, StringComparison.OrdinalIgnoreCase))
                    {
                        item = li;
                        break;
                    }
                }
            }

            if (item != null)
            {
                item.Selected = true;
            }
            else
            {
                ddl.SelectedIndex = 0;
            }
        }

        // Đổ dữ liệu 1 dòng hàng hóa vào các ô trong form sửa
        private void DoDuLieuVaoFormSua(DataRow row)
        {
            if (ddlSuaLoaiHang.Items.Count == 0)
            {
                LoadLoaiHang();
            }

            txtSuaMaHang.Text = Convert.ToString(row["MaHangHoa"]).Trim();
            txtSuaTenHang.Text = Convert.ToString(row["TenHangHoa"]);
            ChonGiaTriDropdownAnToan(ddlSuaLoaiHang, Convert.ToString(row["MaLoai"]));
            txtSuaDonViTinh.Text = Convert.ToString(row["DonViTinh"]);

            // Hiển thị đơn giá dạng số thuần (92000), tránh lệch dấu . , theo ngôn ngữ máy
            if (row["DonGia"] != DBNull.Value)
            {
                txtSuaDonGia.Text = Convert.ToDecimal(row["DonGia"]).ToString("0.##", CultureInfo.InvariantCulture);
            }
            else
            {
                txtSuaDonGia.Text = "0";
            }

            if (row["HanSuDung"] != DBNull.Value)
            {
                txtSuaHanSuDung.Text = Convert.ToDateTime(row["HanSuDung"]).ToString("yyyy-MM-dd");
            }
            else
            {
                txtSuaHanSuDung.Text = "";
            }
        }

        // 1. Tải danh sách loại hàng vào các Dropdown (Tìm kiếm, Thêm, Sửa)
        private void LoadLoaiHang()
        {
            string selectedFilter = ddlLoaiHang.SelectedValue;
            string selectedThem = ddlThemLoaiHang.SelectedValue;
            string selectedSua = ddlSuaLoaiHang.SelectedValue;

            string query = "SELECT RTRIM(LTRIM(MaLoai)) AS MaLoai, TenLoai FROM LoaiHangHoa ORDER BY MaLoai";
            DataTable dt = DatabaseHelper.ExecuteQuery(query);

            // Dropdown tìm kiếm
            ddlLoaiHang.DataSource = dt;
            ddlLoaiHang.DataTextField = "TenLoai";
            ddlLoaiHang.DataValueField = "MaLoai";
            ddlLoaiHang.DataBind();
            ddlLoaiHang.Items.Insert(0, new ListItem("-- Tất cả loại hàng hóa --", ""));
            ChonGiaTriDropdownAnToan(ddlLoaiHang, selectedFilter);

            // Dropdown trong Modal thêm mới
            ddlThemLoaiHang.DataSource = dt;
            ddlThemLoaiHang.DataTextField = "TenLoai";
            ddlThemLoaiHang.DataValueField = "MaLoai";
            ddlThemLoaiHang.DataBind();
            ChonGiaTriDropdownAnToan(ddlThemLoaiHang, selectedThem);

            // Dropdown trong Modal chỉnh sửa
            ddlSuaLoaiHang.DataSource = dt;
            ddlSuaLoaiHang.DataTextField = "TenLoai";
            ddlSuaLoaiHang.DataValueField = "MaLoai";
            ddlSuaLoaiHang.DataBind();
            ChonGiaTriDropdownAnToan(ddlSuaLoaiHang, selectedSua);
        }

        // 2. Hiển thị dữ liệu lên GridView
        private void BindGrid(string searchKeyword = "", string maLoai = "")
        {
            string query = @"SELECT h.MaHangHoa, h.TenHangHoa, ISNULL(l.TenLoai, N'Chưa phân loại') AS TenLoai, h.DonViTinh, h.DonGia, h.HanSuDung 
                             FROM HangHoa h 
                             LEFT JOIN LoaiHangHoa l ON RTRIM(LTRIM(h.MaLoai)) = RTRIM(LTRIM(l.MaLoai)) 
                             WHERE (h.TenHangHoa LIKE @keyword OR h.MaHangHoa LIKE @keyword)";

            if (!string.IsNullOrEmpty(maLoai))
            {
                query += " AND RTRIM(LTRIM(h.MaLoai)) = @maLoai";
            }

            query += " ORDER BY h.MaHangHoa";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@keyword", "%" + searchKeyword + "%"),
                new SqlParameter("@maLoai", string.IsNullOrEmpty(maLoai) ? (object)DBNull.Value : maLoai.Trim())
            };

            gvHangHoa.DataSource = DatabaseHelper.ExecuteQuery(query, parameters);
            gvHangHoa.DataBind();
        }

        // 3. Xử lý Thêm mới hàng hóa
        protected void btnLưuHang_Click(object sender, EventArgs e)
        {
            string ma = txtMaHang.Text.Trim();
            string ten = txtTenHang.Text.Trim();
            string dvt = txtDonViTinh.Text.Trim();
            string giaText = txtDonGia.Text.Trim();
            string hsdText = txtHanSuDung.Text.Trim();
            string maLoai = (ddlThemLoaiHang.SelectedValue ?? "").Trim();

            if (ma.Length == 0 || ten.Length == 0 || dvt.Length == 0 || giaText.Length == 0 || hsdText.Length == 0 || maLoai.Length == 0)
            {
                HienThiThongBao("Vui lòng nhập đầy đủ mã hàng, tên hàng, loại hàng, đơn vị tính, đơn giá và hạn sử dụng.", "danger");
                MoModalThem();
                return;
            }

            if (ma.Length > 10 || ten.Length > 150 || dvt.Length > 20)
            {
                HienThiThongBao("Mã hàng tối đa 10 ký tự, tên hàng tối đa 150 ký tự, đơn vị tính tối đa 20 ký tự.", "danger");
                MoModalThem();
                return;
            }

            decimal gia;
            if (!decimal.TryParse(giaText, NumberStyles.Number, CultureInfo.InvariantCulture, out gia) || gia < 0)
            {
                HienThiThongBao("Đơn giá phải là số không âm (ví dụ: 92000).", "danger");
                MoModalThem();
                return;
            }

            DateTime hsd;
            if (!DateTime.TryParse(hsdText, CultureInfo.InvariantCulture, DateTimeStyles.None, out hsd))
            {
                HienThiThongBao("Hạn sử dụng không hợp lệ.", "danger");
                MoModalThem();
                return;
            }

            try
            {
                object checkCount = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM HangHoa WHERE RTRIM(LTRIM(MaHangHoa)) = @Ma",
                    new SqlParameter[] { new SqlParameter("@Ma", ma) });
                if (Convert.ToInt32(checkCount) > 0)
                {
                    HienThiThongBao("Mã hàng hóa \"" + ma + "\" đã tồn tại trong hệ thống. Vui lòng nhập mã khác!", "danger");
                    MoModalThem();
                    return;
                }

                string query = "INSERT INTO HangHoa (MaHangHoa, TenHangHoa, DonViTinh, DonGia, HanSuDung, MaLoai) VALUES (@Ma, @Ten, @DVT, @Gia, @HSD, @MaLoai)";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", ma),
                    new SqlParameter("@Ten", ten),
                    new SqlParameter("@DVT", dvt),
                    new SqlParameter("@Gia", gia),
                    new SqlParameter("@HSD", hsd),
                    new SqlParameter("@MaLoai", maLoai)
                };

                DatabaseHelper.ExecuteNonQuery(query, parameters);

                txtMaHang.Text = "";
                txtTenHang.Text = "";
                txtDonViTinh.Text = "";
                txtDonGia.Text = "";
                txtHanSuDung.Text = "";
                if (ddlThemLoaiHang.Items.Count > 0) ddlThemLoaiHang.SelectedIndex = 0;

                DongModalThem();
                HienThiThongBao("Thêm mới hàng hóa " + ma + " thành công!", "success");
                BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue);
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi thêm hàng hóa: " + DatabaseHelper.LayThongBaoLoi(ex), "danger");
                MoModalThem();
            }
        }

        // 4. Xử lý sự kiện trên GridView (Sửa / Xóa)
        protected void gvHangHoa_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                // Bấm icon bút xanh: đọc dữ liệu dòng đó đổ vào form sửa rồi mở form
                string maHang = Convert.ToString(e.CommandArgument).Trim();

                string query = "SELECT * FROM HangHoa WHERE RTRIM(LTRIM(MaHangHoa)) = @Ma";
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", maHang)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    DoDuLieuVaoFormSua(dt.Rows[0]);
                    MoModalSua(); // Kích hoạt hiển thị Modal Sửa
                }
                else
                {
                    HienThiThongBao("Hàng hóa " + maHang + " không còn tồn tại (có thể đã bị xóa).", "danger");
                    BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue);
                }
            }
            else if (e.CommandName == "DeleteItem")
            {
                string maHang = Convert.ToString(e.CommandArgument).Trim();
                try
                {
                    string query = "DELETE FROM HangHoa WHERE RTRIM(LTRIM(MaHangHoa)) = @Ma";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@Ma", maHang)
                    };

                    DatabaseHelper.ExecuteNonQuery(query, parameters);
                    HienThiThongBao("Đã xóa hàng hóa " + maHang + " thành công!", "success");
                    BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue);
                }
                catch (Exception ex)
                {
                    HienThiThongBao("Không thể xóa hàng hóa " + maHang + " do đang phát sinh tồn kho hoặc phiếu giao dịch: " + DatabaseHelper.LayThongBaoLoi(ex), "danger");
                }
            }
        }

        // 5. Xử lý Lưu thông tin sau khi chỉnh sửa
        protected void btnLuuSuaHang_Click(object sender, EventArgs e)
        {
            string ma = txtSuaMaHang.Text.Trim();
            string ten = txtSuaTenHang.Text.Trim();
            string dvt = txtSuaDonViTinh.Text.Trim();
            string giaText = txtSuaDonGia.Text.Trim();
            string hsdText = txtSuaHanSuDung.Text.Trim();

            // Kiểm tra dữ liệu nhập
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
                     WHERE RTRIM(LTRIM(MaHangHoa)) = @Ma";

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Ma", ma),
                    new SqlParameter("@Ten", ten),
                    new SqlParameter("@DVT", dvt),
                    new SqlParameter("@Gia", gia),
                    new SqlParameter("@HSD", hsd),
                    new SqlParameter("@MaLoai", (ddlSuaLoaiHang.SelectedValue ?? "").Trim())
                };

                int n = DatabaseHelper.ExecuteNonQuery(query, parameters);
                if (n == 0)
                {
                    HienThiThongBao("Hàng hóa " + ma + " không còn tồn tại nên không thể cập nhật.", "danger");
                    BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue);
                    return;
                }

                HienThiThongBao("Cập nhật hàng hóa " + ma + " thành công!", "success");
                BindGrid(txtSearch.Text.Trim(), ddlLoaiHang.SelectedValue); // Tải lại bảng dữ liệu

                // Đóng Modal sau khi lưu thành công
                DongModalSua();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi cập nhật hàng hóa: " + DatabaseHelper.LayThongBaoLoi(ex), "danger");
                MoModalSua(); // Giữ form sửa mở để người dùng chỉnh lại
            }
        }

        // 6. Xử lý nút Làm mới trong Modal Sửa
        protected void btnLamMoiSua_Click(object sender, EventArgs e)
        {
            string maHang = txtSuaMaHang.Text.Trim();

            string query = "SELECT * FROM HangHoa WHERE RTRIM(LTRIM(MaHangHoa)) = @Ma";
            SqlParameter[] parameters = new SqlParameter[] { new SqlParameter("@Ma", maHang) };
            DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DoDuLieuVaoFormSua(dt.Rows[0]);
            }

            // Giữ Modal mở để tiếp tục chỉnh sửa
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
