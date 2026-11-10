using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class PhieuXuat : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtNgayXuat.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadDropdownData();
                KhoiTaoBangChiTiet();
            }
        }

        // 1. Nạp dữ liệu danh mục cho các Dropdown
        private void LoadDropdownData()
        {
            // Đơn đặt hàng từ khách hàng
            ddlDonHang.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaDonHang, TenKhachHang FROM DonDatHang");
            ddlDonHang.DataTextField = "TenKhachHang";
            ddlDonHang.DataValueField = "MaDonHang";
            ddlDonHang.DataBind();
            ddlDonHang.Items.Insert(0, new ListItem("-- Chọn đơn đặt hàng (nếu có) --", ""));

            // Nhân viên thực hiện
            ddlNhanVien.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaNhanVien, HoTen FROM NguoiDung");
            ddlNhanVien.DataTextField = "HoTen";
            ddlNhanVien.DataValueField = "MaNhanVien";
            ddlNhanVien.DataBind();
            ddlNhanVien.Items.Insert(0, new ListItem("-- Chọn nhân viên kho --", ""));

            // Hàng hóa có sẵn trong kho
            ddlHangHoa.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaHangHoa, TenHangHoa FROM HangHoa");
            ddlHangHoa.DataTextField = "TenHangHoa";
            ddlHangHoa.DataValueField = "MaHangHoa";
            ddlHangHoa.DataBind();
            ddlHangHoa.Items.Insert(0, new ListItem("-- Chọn hàng hóa --", ""));
        }

        // 2. Khởi tạo bảng dữ liệu tạm thời cho GridView chi tiết xuất
        private void KhoiTaoBangChiTiet()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MaHangHoa");
            dt.Columns.Add("TenHangHoa");
            dt.Columns.Add("SoLuongXuat");
            dt.Columns.Add("DonGiaXuat");
            ViewState["ChiTietXuat"] = dt;
            gvChiTietPhieuXuat.DataSource = dt;
            gvChiTietPhieuXuat.DataBind();
        }

        // 3. Xử lý nút Thêm dòng hàng vào danh sách xuất tạm (có kiểm tra dữ liệu)
        protected void btnThemDong_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlHangHoa.SelectedValue))
            {
                HienThiThongBao("Vui lòng chọn hàng hóa cần xuất kho!", "warning");
                return;
            }

            string soLuongStr = txtSoLuongXuat.Text.Trim();
            string donGiaStr = txtDonGiaXuat.Text.Trim();

            if (string.IsNullOrEmpty(soLuongStr) || Convert.ToInt32(soLuongStr) <= 0)
            {
                HienThiThongBao("Số lượng xuất phải lớn hơn 0!", "warning");
                txtSoLuongXuat.Focus();
                return;
            }

            if (string.IsNullOrEmpty(donGiaStr) || Convert.ToDecimal(donGiaStr) < 0)
            {
                HienThiThongBao("Đơn giá xuất không được để trống hoặc âm!", "warning");
                txtDonGiaXuat.Focus();
                return;
            }

            DataTable dt = ViewState["ChiTietXuat"] as DataTable;
            if (dt != null)
            {
                string maHang = ddlHangHoa.SelectedValue;
                string tenHang = ddlHangHoa.SelectedItem.Text;

                dt.Rows.Add(maHang, tenHang, soLuongStr, donGiaStr);
                ViewState["ChiTietXuat"] = dt;

                gvChiTietPhieuXuat.DataSource = dt;
                gvChiTietPhieuXuat.DataBind();

                // Xóa thông báo lỗi cũ nếu thêm thành công và reset ô nhập
                lblThongBao.Text = "";
                ddlHangHoa.SelectedIndex = 0;
                txtSoLuongXuat.Text = "";
                txtDonGiaXuat.Text = "";
            }
        }

        // 4. Xử lý xóa dòng trong bảng chi tiết tạm
        protected void gvChiTietPhieuXuat_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "XoaDong")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                DataTable dt = ViewState["ChiTietXuat"] as DataTable;
                if (dt != null)
                {
                    dt.Rows.RemoveAt(rowIndex);
                    ViewState["ChiTietXuat"] = dt;
                    gvChiTietPhieuXuat.DataSource = dt;
                    gvChiTietPhieuXuat.DataBind();
                }
            }
        }

        // 5. Xử lý Lưu hoàn tất Phiếu Xuất Kho vào CSDL (có kiểm tra toàn diện thông tin lập phiếu)
        protected void btnLuuPhieuXuat_Click(object sender, EventArgs e)
        {
            // Kiểm tra thông tin chung phiếu xuất
            string maPX = txtMaPhieuXuat.Text.Trim();
            string ngayXuatStr = txtNgayXuat.Text.Trim();
            string maNV = ddlNhanVien.SelectedValue;
            string trangThai = ddlTrangThai.SelectedValue;
            string maDonHang = string.IsNullOrEmpty(ddlDonHang.SelectedValue) ? null : ddlDonHang.SelectedValue;

            if (string.IsNullOrEmpty(maPX))
            {
                HienThiThongBao("Vui lòng nhập Mã phiếu xuất kho!", "danger");
                txtMaPhieuXuat.Focus();
                return;
            }

            if (string.IsNullOrEmpty(ngayXuatStr))
            {
                HienThiThongBao("Vui lòng chọn Ngày xuất kho!", "danger");
                txtNgayXuat.Focus();
                return;
            }

            if (string.IsNullOrEmpty(maNV))
            {
                HienThiThongBao("Vui lòng chọn Nhân viên thực hiện lập phiếu!", "danger");
                ddlNhanVien.Focus();
                return;
            }

            if (string.IsNullOrEmpty(trangThai))
            {
                HienThiThongBao("Vui lòng chọn Trạng thái thanh toán!", "danger");
                ddlTrangThai.Focus();
                return;
            }

            // Kiểm tra bảng chi tiết sản phẩm xuất
            DataTable dtChiTiet = ViewState["ChiTietXuat"] as DataTable;
            if (dtChiTiet == null || dtChiTiet.Rows.Count == 0)
            {
                HienThiThongBao("Phiếu xuất chưa có sản phẩm chi tiết nào! Vui lòng thêm ít nhất một mặt hàng.", "danger");
                return;
            }

            try
            {
                decimal tongTien = 0;
                foreach (DataRow row in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(row["SoLuongXuat"]) * Convert.ToDecimal(row["DonGiaXuat"]);
                }

                DateTime ngayXuat = Convert.ToDateTime(ngayXuatStr);

                // A. Lưu thông tin chung vào bảng PhieuXuat
                string queryPhieuXuat = "INSERT INTO PhieuXuat (MaPhieuXuat, NgayXuat, TongTien, TrangThaiThanhToan, MaDonHang, MaNhanVien) VALUES (@MaPX, @NgayXuat, @TongTien, @TrangThai, @MaDonHang, @MaNV)";
                SqlParameter[] paramPX = new SqlParameter[]
                {
                    new SqlParameter("@MaPX", maPX),
                    new SqlParameter("@NgayXuat", ngayXuat),
                    new SqlParameter("@TongTien", tongTien),
                    new SqlParameter("@TrangThai", trangThai),
                    new SqlParameter("@MaDonHang", string.IsNullOrEmpty(maDonHang) ? (object)DBNull.Value : maDonHang),
                    new SqlParameter("@MaNV", maNV)
                };

                DatabaseHelper.ExecuteNonQuery(queryPhieuXuat, paramPX);

                // B. Lưu chi tiết vào bảng ChiTietPhieuXuat
                foreach (DataRow row in dtChiTiet.Rows)
                {
                    string maHH = row["MaHangHoa"].ToString();
                    int slXuat = Convert.ToInt32(row["SoLuongXuat"]);
                    decimal dgXuat = Convert.ToDecimal(row["DonGiaXuat"]);

                    string queryCT = "INSERT INTO ChiTietPhieuXuat (MaPhieuXuat, MaHangHoa, SoLuongXuat, DonGiaXuat) VALUES (@MaPX, @MaHH, @SLXuat, @DGXuat)";
                    SqlParameter[] paramCT = new SqlParameter[]
                    {
                        new SqlParameter("@MaPX", maPX),
                        new SqlParameter("@MaHH", maHH),
                        new SqlParameter("@SLXuat", slXuat),
                        new SqlParameter("@DGXuat", dgXuat)
                    };
                    DatabaseHelper.ExecuteNonQuery(queryCT, paramCT);
                }

                HienThiThongBao("Lập phiếu xuất kho thành công và đã lưu vào hệ thống!", "success");

                // Reset form sau khi lưu thành công
                txtMaPhieuXuat.Text = "";
                KhoiTaoBangChiTiet();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi lưu phiếu xuất: " + ex.Message, "danger");
            }
        }

        // Hàm hỗ trợ hiển thị thông báo trực quan trên giao diện
        private void HienThiThongBao(string message, string type)
        {
            lblThongBao.Text = $"<div class='alert alert-{type} alert-dismissible fade show' role='alert'>" +
                               $"<i class='fa-solid fa-circle-exclamation me-2'></i> {message}" +
                               $"<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>" +
                               $"</div>";
        }
    }
}