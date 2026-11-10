<%@ Page Title="Lập Phiếu Xuất Kho" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PhieuXuat.aspx.cs" Inherits="N6_QLKHO.PhieuXuat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-header-card {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid #e2e8f0;
            border-radius: 12px;
        }
        .table-custom th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 12px 16px;
        }
        .table-custom td {
            padding: 14px 16px;
            color: #1e293b;
            vertical-align: middle;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Tiêu đề trang -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Lập Phiếu Xuất Kho</h3>
            <p class="text-muted small mb-0">Tạo phiếu xuất hàng hóa theo đơn đặt hàng hoặc xuất kho trực tiếp.</p>
        </div>
    </div>

    <!-- Label thông báo lỗi hoặc thành công -->
    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label> 

    <!-- KHUNG THÔNG TIN CHUNG PHIẾU XUẤT -->
    <div class="card page-header-card shadow-sm mb-4">
        <div class="card-header bg-transparent py-3 border-0">
            <h5 class="card-title text-primary mb-0 fw-bold"><i class="fa-solid fa-file-invoice-dollar me-2"></i> Thông Tin Chung Phiếu Xuất</h5>
        </div>
        <div class="card-body px-4 pb-4 pt-0">
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label fw-semibold small text-secondary">Mã Phiếu Xuất <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtMaPhieuXuat" runat="server" CssClass="form-control" Placeholder="VD: PX001"></asp:TextBox>
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label fw-semibold small text-secondary">Ngày Xuất <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtNgayXuat" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label fw-semibold small text-secondary">Đơn Đặt Hàng</label>
                    <asp:DropDownList ID="ddlDonHang" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Chọn đơn đặt hàng (nếu có) --" Value="" />
                    </asp:DropDownList>
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label fw-semibold small text-secondary">Nhân Viên Thực Hiện <span class="text-danger">*</span></label>
                    <asp:DropDownList ID="ddlNhanVien" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Chọn nhân viên kho --" Value="" />
                    </asp:DropDownList>
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label fw-semibold small text-secondary">Trạng Thái Thanh Toán <span class="text-danger">*</span></label>
                    <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Đã thanh toán" Value="Đã thanh toán" />
                        <asp:ListItem Text="Chưa thanh toán" Value="Chưa thanh toán" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>

    <!-- KHU VỰC CHI TIẾT HÀNG XUẤT -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
        <div class="card-header bg-white py-3 border-0">
            <h5 class="card-title text-primary mb-0 fw-bold"><i class="fa-solid fa-dolly me-2"></i> Chi Tiết Hàng Xuất Kho</h5>
        </div>
        <div class="card-body px-4 pb-4">
            <!-- Form dòng nhập nhanh sản phẩm xuất -->
            <div class="row g-3 align-items-end mb-4 p-3 bg-light rounded-3 border">
                <div class="col-12 col-md-5">
                    <label class="form-label fw-semibold small text-secondary">Chọn Hàng Hóa Tồn Kho</label>
                    <asp:DropDownList ID="ddlHangHoa" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Chọn hàng hóa --" Value="" />
                    </asp:DropDownList>
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label fw-semibold small text-secondary">Số Lượng Xuất</label>
                    <asp:TextBox ID="txtSoLuongXuat" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                </div>
                <div class="col-12 col-md-2">
                    <label class="form-label fw-semibold small text-secondary">Đơn Giá Xuất</label>
                    <asp:TextBox ID="txtDonGiaXuat" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                </div>
                <div class="col-12 col-md-2">
                    <!-- Đã chuyển sang asp:Button để gọi được code-behind -->
                    <asp:Button ID="btnThemDong" runat="server" Text="Thêm dòng" CssClass="btn btn-success w-100 fw-semibold" OnClick="btnThemDong_Click" />
                </div>
            </div>

            <!-- Bảng hiển thị danh sách sản phẩm xuất tạm -->
            <div class="table-responsive">
                <asp:GridView ID="gvChiTietPhieuXuat" runat="server" CssClass="table table-custom table-hover mb-0 align-middle text-nowrap" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvChiTietPhieuXuat_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="MaHangHoa" HeaderText="Mã Hàng" />
                        <asp:TemplateField HeaderText="Tên Hàng Hóa">
                            <ItemTemplate>
                                <span class="fw-semibold text-dark"><%# Eval("TenHangHoa") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="SoLuongXuat" HeaderText="Số Lượng" />
                        <asp:BoundField DataField="DonGiaXuat" HeaderText="Đơn Giá" DataFormatString="{0:N0} đ" />
                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnXoaDong" runat="server" CommandName="XoaDong" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-sm btn-light text-danger border" title="Xóa dòng">
                                    <i class="fa-solid fa-trash"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center py-4 text-muted">
                            <i class="fa-solid fa-basket-shopping fs-2 mb-2 text-secondary opacity-50"></i>
                            <p class="mb-0">Chưa có sản phẩm nào được chọn để xuất kho.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- NÚT HOÀN TẤT -->
    <div class="text-end mb-5">
        <!-- Đã chuyển sang asp:Button để kích hoạt hàm kiểm tra và lưu phiếu -->
        <asp:Button ID="btnLuuPhieuXuat" runat="server" Text="Lưu Phiếu Xuất Kho" CssClass="btn btn-primary btn-lg px-5 shadow-sm fw-semibold" OnClick="btnLuuPhieuXuat_Click" />
    </div>

</asp:Content>