using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace N6_QLKHO
{
    public partial class DonDatHang : System.Web.UI.Page
    {
        string chuoiKetNoi = ConfigurationManager.ConnectionStrings["N6_QLKHOVATTUConnectionString"] != null
                            ? ConfigurationManager.ConnectionStrings["N6_QLKHOVATTUConnectionString"].ConnectionString
                            : @"Data Source=DESKTOP-UKT66TU;Initial Catalog=N6_QLKHOVATTU;Integrated Security=True;Encrypt=False";

        protected string ChiTietJson { get; set; } = "{}";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDanhSachHangHoa();
                LoadDanhSachDonHang();
            }
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadDanhSachDonHang();
        }

        protected void btnDatLai_Click(object sender, EventArgs e)
        {
            txtMaDon.Text = string.Empty;
            ddlTrangThai.SelectedIndex = 0;
            LoadDanhSachDonHang();
        }

        // Nạp danh sách hàng hóa vào DropDownList trong modal thêm/sửa
        private void LoadDanhSachHangHoa()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                {
                    string query = "SELECT MaHangHoa, TenHangHoa FROM HangHoa";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            ddlHangHoa.DataSource = dt;
                            ddlHangHoa.DataTextField = "TenHangHoa";
                            ddlHangHoa.DataValueField = "MaHangHoa";
                            ddlHangHoa.DataBind();
                            ddlHangHoa.Items.Insert(0, new ListItem("Chọn hàng hóa", ""));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblLoi.Text = "Lỗi tải danh mục hàng hóa: " + ex.Message;
                lblLoi.Visible = true;
            }
        }

        private void LoadDanhSachDonHang()
        {
            lblLoi.Visible = false;
            try
            {
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                {
                    string sqlDon = @"SELECT d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai, 
                                     ISNULL(SUM(c.SoLuongDat * c.DonGia), 0) AS TongTien 
                              FROM DonDatHang d 
                              LEFT JOIN ChiTietDonDatHang c ON d.MaDonHang = c.MaDonHang
                              WHERE (@TuKhoa = '' OR d.MaDonHang LIKE '%' + @TuKhoa + '%' OR d.TenKhachHang LIKE '%' + @TuKhoa + '%')
                                AND (@TrangThai = '' OR d.TrangThai = @TrangThai)
                              GROUP BY d.MaDonHang, d.NgayDatHang, d.TenKhachHang, d.SoDienThoai, d.TrangThai
                              ORDER BY d.NgayDatHang DESC";

                    string sqlChiTiet = @"SELECT c.MaDonHang, c.MaHangHoa, h.TenHangHoa, c.SoLuongDat, c.DonGia 
                                         FROM ChiTietDonDatHang c
                                         INNER JOIN HangHoa h ON c.MaHangHoa = h.MaHangHoa";

                    using (SqlCommand cmdDon = new SqlCommand(sqlDon, conn))
                    {
                        cmdDon.Parameters.AddWithValue("@TuKhoa", txtMaDon.Text.Trim());
                        cmdDon.Parameters.AddWithValue("@TrangThai", ddlTrangThai.SelectedValue);

                        using (SqlDataAdapter daDon = new SqlDataAdapter(cmdDon))
                        {
                            DataTable dtDon = new DataTable();
                            daDon.Fill(dtDon);

                            lvDonHang.DataSource = dtDon;
                            lvDonHang.DataBind();

                            lblSoLuong.Text = "Tổng số lượng: " + dtDon.Rows.Count + " đơn đặt hàng";

                            using (SqlCommand cmdChiTiet = new SqlCommand(sqlChiTiet, conn))
                            {
                                using (SqlDataAdapter daChiTiet = new SqlDataAdapter(cmdChiTiet))
                                {
                                    DataTable dtChiTiet = new DataTable();
                                    daChiTiet.Fill(dtChiTiet);
                                    ChiTietJson = TaoChuoiJson(dtDon, dtChiTiet);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblLoi.Text = "Lỗi kết nối hoặc truy xuất cơ sở dữ liệu: " + ex.Message;
                lblLoi.Visible = true;
            }
        }

        private string TaoChuoiJson(DataTable dtDon, DataTable dtChiTiet)
        {
            var dict = new Dictionary<string, object>();

            foreach (DataRow rowDon in dtDon.Rows)
            {
                string maDon = rowDon["MaDonHang"].ToString();
                DateTime ngay = Convert.ToDateTime(rowDon["NgayDatHang"]);

                var dsChiTiet = new List<object>();
                foreach (DataRow rowChiTiet in dtChiTiet.Rows)
                {
                    if (rowChiTiet["MaDonHang"].ToString() == maDon)
                    {
                        dsChiTiet.Add(new
                        {
                            MaHang = rowChiTiet["MaHangHoa"].ToString(),
                            TenHang = rowChiTiet["TenHangHoa"].ToString(),
                            SoLuong = Convert.ToInt32(rowChiTiet["SoLuongDat"]),
                            DonGia = Convert.ToDecimal(rowChiTiet["DonGia"])
                        });
                    }
                }

                dict[maDon] = new
                {
                    khach = rowDon["TenKhachHang"].ToString(),
                    sdt = rowDon["SoDienThoai"].ToString(),
                    ngay = ngay.ToString("dd/MM/yyyy HH:mm"),
                    ngayRaw = ngay.ToString("yyyy-MM-ddTHH:mm"), // Dùng để gán vào input datetime-local khi sửa
                    trangThai = rowDon["TrangThai"].ToString(),
                    dong = dsChiTiet
                };
            }

            var serializer = new JavaScriptSerializer();
            return serializer.Serialize(dict);
        }

        protected void lvDonHang_ItemCommand(object sender, ListViewCommandEventArgs e)
        {
            string maDonHang = e.CommandArgument.ToString();

            if (e.CommandName == "XoaDon")
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                    {
                        string query = "DELETE FROM DonDatHang WHERE MaDonHang = @MaDonHang";
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@MaDonHang", maDonHang);
                            conn.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }
                    LoadDanhSachDonHang();
                }
                catch (Exception ex)
                {
                    lblLoi.Text = "Lỗi khi xóa: " + ex.Message;
                    lblLoi.Visible = true;
                }
            }
        }

        protected void btnLuuDon_Click(object sender, EventArgs e)
        {
            // Xử lý lưu dữ liệu thêm mới hoặc cập nhật khi bấm nút Lưu đơn trong modal
            string cheDo = hdCheDo.Value;
            string maDon = mdMaDon.Text.Trim();
            string tenKhach = mdTenKhach.Text.Trim();
            string sdt = mdSdt.Text.Trim();
            string trangThai = mdTrangThai.SelectedValue;
            DateTime ngayDat;

            if (!DateTime.TryParse(mdNgayDat.Text, out ngayDat))
            {
                ngayDat = DateTime.Now;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(chuoiKetNoi))
                {
                    conn.Open();
                    if (cheDo == "Them")
                    {
                        string insertDon = "INSERT INTO DonDatHang(MaDonHang, NgayDatHang, TenKhachHang, SoDienThoai, TrangThai) VALUES(@MaDon, @NgayDat, @TenKhach, @Sdt, @TrangThai)";
                        using (SqlCommand cmd = new SqlCommand(insertDon, conn))
                        {
                            cmd.Parameters.AddWithValue("@MaDon", maDon);
                            cmd.Parameters.AddWithValue("@NgayDat", ngayDat);
                            cmd.Parameters.AddWithValue("@TenKhach", tenKhach);
                            cmd.Parameters.AddWithValue("@Sdt", sdt);
                            cmd.Parameters.AddWithValue("@TrangThai", trangThai);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (cheDo == "Sua")
                    {
                        string updateDon = "UPDATE DonDatHang SET NgayDatHang = @NgayDat, TenKhachHang = @TenKhach, SoDienThoai = @Sdt, TrangThai = @TrangThai WHERE MaDonHang = @MaDon";
                        using (SqlCommand cmd = new SqlCommand(updateDon, conn))
                        {
                            cmd.Parameters.AddWithValue("@MaDon", maDon);
                            cmd.Parameters.AddWithValue("@NgayDat", ngayDat);
                            cmd.Parameters.AddWithValue("@TenKhach", tenKhach);
                            cmd.Parameters.AddWithValue("@Sdt", sdt);
                            cmd.Parameters.AddWithValue("@TrangThai", trangThai);
                            cmd.ExecuteNonQuery();
                        }

                        // Xóa chi tiết cũ để ghi nhận lại danh sách chi tiết mới
                        string deleteChiTiet = "DELETE FROM ChiTietDonDatHang WHERE MaDonHang = @MaDon";
                        using (SqlCommand cmdDel = new SqlCommand(deleteChiTiet, conn))
                        {
                            cmdDel.Parameters.AddWithValue("@MaDon", maDon);
                            cmdDel.ExecuteNonQuery();
                        }
                    }
                }
                LoadDanhSachDonHang();
            }
            catch (Exception ex)
            {
                lblLoi.Text = "Lỗi khi lưu đơn hàng: " + ex.Message;
                lblLoi.Visible = true;
            }
        }

        protected static string FormatNgay(object value)
        {
            try
            {
                if (value == null || value == DBNull.Value) return string.Empty;
                return Convert.ToDateTime(value).ToString("dd/MM/yyyy HH:mm");
            }
            catch { return string.Empty; }
        }

        protected static string FormatTien(object value)
        {
            try
            {
                if (value == null || value == DBNull.Value) return "0 ₫";
                return Convert.ToDecimal(value).ToString("N0") + " ₫";
            }
            catch { return "0 ₫"; }
        }

        protected static string LopTrangThai(object value)
        {
            string trangThai = Convert.ToString(value);
            switch (trangThai)
            {
                case "Đã xuất kho": return "bg-success";
                case "Đang xử lý": return "bg-warning text-dark";
                default: return "bg-secondary";
            }
        }
    }
}