using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class PhieuNhap : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtNgayNhap.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtHanSuDungLo.Text = DateTime.Now.AddYears(1).ToString("yyyy-MM-dd");
                LoadDropdownData();
                KhoiTaoBangChiTiet();
            }
        }

        // 1. Nạp dữ liệu danh mục khớp đúng tên cột trong CSDL
        private void LoadDropdownData()
        {
            // Bảng NhaCungCap dùng cột MaNCC, TenNCC[cite: 5]
            ddlNhaCungCap.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaNCC, TenNCC FROM NhaCungCap");
            ddlNhaCungCap.DataTextField = "TenNCC";
            ddlNhaCungCap.DataValueField = "MaNCC";
            ddlNhaCungCap.DataBind();
            ddlNhaCungCap.Items.Insert(0, new ListItem("-- Chọn nhà cung cấp --", ""));

            // Bảng NguoiDung dùng cột MaNhanVien, HoTen[cite: 5]
            ddlNhanVien.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaNhanVien, HoTen FROM NguoiDung");
            ddlNhanVien.DataTextField = "HoTen";
            ddlNhanVien.DataValueField = "MaNhanVien";
            ddlNhanVien.DataBind();
            ddlNhanVien.Items.Insert(0, new ListItem("-- Chọn nhân viên kho --", ""));

            // Bảng HangHoa dùng cột MaHangHoa, TenHangHoa[cite: 5]
            ddlHangHoa.DataSource = DatabaseHelper.ExecuteQuery("SELECT MaHangHoa, TenHangHoa FROM HangHoa");
            ddlHangHoa.DataTextField = "TenHangHoa";
            ddlHangHoa.DataValueField = "MaHangHoa";
            ddlHangHoa.DataBind();
            ddlHangHoa.Items.Insert(0, new ListItem("-- Chọn hàng hóa --", ""));
        }

        // 2. Khởi tạo bảng tạm có chứa cột HanSuDungLo khớp với ChiTietPhieuNhap[cite: 5]
        private void KhoiTaoBangChiTiet()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MaHangHoa");
            dt.Columns.Add("TenHangHoa");
            dt.Columns.Add("SoLuongNhap");
            dt.Columns.Add("DonGiaNhap");
            dt.Columns.Add("HanSuDungLo");
            ViewState["ChiTietNhap"] = dt;
            gvChiTietPhieuNhap.DataSource = dt;
            gvChiTietPhieuNhap.DataBind();
        }

        // 3. Xử lý nút Thêm dòng hàng vào danh sách nhập tạm
        protected void btnThemDong_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlHangHoa.SelectedValue))
            {
                HienThiThongBao("Vui lòng chọn hàng hóa cần nhập kho!", "warning");
                return;
            }

            string soLuongStr = txtSoLuongNhap.Text.Trim();
            string donGiaStr = txtDonGiaNhap.Text.Trim();
            string hanDungLo = txtHanSuDungLo.Text.Trim();

            if (string.IsNullOrEmpty(soLuongStr) || Convert.ToInt32(soLuongStr) <= 0)
            {
                HienThiThongBao("Số lượng nhập phải lớn hơn 0!", "warning");
                txtSoLuongNhap.Focus();
                return;
            }

            if (string.IsNullOrEmpty(donGiaStr) || Convert.ToDecimal(donGiaStr) < 0)
            {
                HienThiThongBao("Đơn giá nhập không hợp lệ!", "warning");
                txtDonGiaNhap.Focus();
                return;
            }

            if (string.IsNullOrEmpty(hanDungLo))
            {
                HienThiThongBao("Vui lòng nhập hạn sử dụng lô hàng!", "warning");
                txtHanSuDungLo.Focus();
                return;
            }

            DataTable dt = ViewState["ChiTietNhap"] as DataTable;
            if (dt != null)
            {
                string maHang = ddlHangHoa.SelectedValue;
                string tenHang = ddlHangHoa.SelectedItem.Text;

                dt.Rows.Add(maHang, tenHang, soLuongStr, donGiaStr, hanDungLo);
                ViewState["ChiTietNhap"] = dt;

                gvChiTietPhieuNhap.DataSource = dt;
                gvChiTietPhieuNhap.DataBind();

                lblThongBao.Text = "";
                ddlHangHoa.SelectedIndex = 0;
                txtSoLuongNhap.Text = "";
                txtDonGiaNhap.Text = "";
            }
        }

        // 4. Xóa dòng tạm
        protected void gvChiTietPhieuNhap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "XoaDong")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                DataTable dt = ViewState["ChiTietNhap"] as DataTable;
                if (dt != null)
                {
                    dt.Rows.RemoveAt(rowIndex);
                    ViewState["ChiTietNhap"] = dt;
                    gvChiTietPhieuNhap.DataSource = dt;
                    gvChiTietPhieuNhap.DataBind();
                }
            }
        }

        // 5. Lưu hoàn tất vào CSDL đúng các tên cột PhieuNhap và ChiTietPhieuNhap[cite: 5]
        protected void btnLuuPhieuNhap_Click(object sender, EventArgs e)
        {
            string maPN = txtMaPhieuNhap.Text.Trim();
            string ngayNhapStr = txtNgayNhap.Text.Trim();
            string maNCC = ddlNhaCungCap.SelectedValue; // Khớp cột MaNCC
            string maNV = ddlNhanVien.SelectedValue;     // Khớp cột MaNhanVien
            string trangThai = ddlTrangThai.SelectedValue; // Khớp cột TrangThaiThanhToan

            if (string.IsNullOrEmpty(maPN))
            {
                HienThiThongBao("Vui lòng nhập Mã phiếu nhập kho!", "danger");
                txtMaPhieuNhap.Focus();
                return;
            }

            if (string.IsNullOrEmpty(ngayNhapStr) || string.IsNullOrEmpty(maNCC) || string.IsNullOrEmpty(maNV))
            {
                HienThiThongBao("Vui lòng điền đầy đủ thông tin chung (Ngày nhập, Nhà cung cấp, Nhân viên)!", "danger");
                return;
            }

            DataTable dtChiTiet = ViewState["ChiTietNhap"] as DataTable;
            if (dtChiTiet == null || dtChiTiet.Rows.Count == 0)
            {
                HienThiThongBao("Phiếu nhập chưa có sản phẩm chi tiết nào!", "danger");
                return;
            }

            try
            {
                decimal tongTien = 0;
                foreach (DataRow row in dtChiTiet.Rows)
                {
                    tongTien += Convert.ToDecimal(row["SoLuongNhap"]) * Convert.ToDecimal(row["DonGiaNhap"]);
                }

                DateTime ngayNhap = Convert.ToDateTime(ngayNhapStr);

                // A. Lưu bảng PhieuNhap (đúng tên cột MaNCC)[cite: 5]
                string queryPhieuNhap = "INSERT INTO PhieuNhap (MaPhieuNhap, NgayNhap, TongTien, TrangThaiThanhToan, MaNCC, MaNhanVien) VALUES (@MaPN, @NgayNhap, @TongTien, @TrangThai, @MaNCC, @MaNV)";
                SqlParameter[] paramPN = new SqlParameter[]
                {
                    new SqlParameter("@MaPN", maPN),
                    new SqlParameter("@NgayNhap", ngayNhap),
                    new SqlParameter("@TongTien", tongTien),
                    new SqlParameter("@TrangThai", trangThai),
                    new SqlParameter("@MaNCC", maNCC),
                    new SqlParameter("@MaNV", maNV)
                };

                DatabaseHelper.ExecuteNonQuery(queryPhieuNhap, paramPN);

                // B. Lưu bảng ChiTietPhieuNhap (đúng cột HanSuDungLo)[cite: 5]
                foreach (DataRow row in dtChiTiet.Rows)
                {
                    string maHH = row["MaHangHoa"].ToString();
                    int slNhap = Convert.ToInt32(row["SoLuongNhap"]);
                    decimal dgNhap = Convert.ToDecimal(row["DonGiaNhap"]);
                    DateTime hanLo = Convert.ToDateTime(row["HanSuDungLo"]);

                    string queryCT = "INSERT INTO ChiTietPhieuNhap (MaPhieuNhap, MaHangHoa, SoLuongNhap, DonGiaNhap, HanSuDungLo) VALUES (@MaPN, @MaHH, @SLNhap, @DGNhap, @HanLo)";
                    SqlParameter[] paramCT = new SqlParameter[]
                    {
                        new SqlParameter("@MaPN", maPN),
                        new SqlParameter("@MaHH", maHH),
                        new SqlParameter("@SLNhap", slNhap),
                        new SqlParameter("@DGNhap", dgNhap),
                        new SqlParameter("@HanLo", hanLo)
                    };
                    DatabaseHelper.ExecuteNonQuery(queryCT, paramCT);
                }

                HienThiThongBao("Lập phiếu nhập kho thành công và đã lưu vào hệ thống!", "success");
                txtMaPhieuNhap.Text = "";
                KhoiTaoBangChiTiet();
            }
            catch (Exception ex)
            {
                HienThiThongBao("Lỗi khi lưu phiếu nhập: " + ex.Message, "danger");
            }
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