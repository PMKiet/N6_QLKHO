<%@ Page Title="Quản Lý Hàng Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HangHoa.aspx.cs" Inherits="N6_QLKHO.HangHoa" %>

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
        .badge-category {
            background-color: #eff6ff;
            color: #2563eb;
            border: 1px solid #dbeafe;
            font-weight: 500;
            padding: 5px 10px;
            border-radius: 6px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Tiêu đề trang & Nút hành động -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Quản Lý Hàng Hóa</h3>
            <p class="text-muted small mb-0">Quản lý danh mục sản phẩm, đơn giá, hạn sử dụng và phân loại hàng hóa.</p>
        </div>
        <div>
            <button type="button" class="btn btn-primary shadow-sm px-4 py-2 d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#modalThemHang">
                <i class="fa-solid fa-plus"></i>
                <span>Thêm Hàng Hóa Mới</span>
            </button>
        </div>
    </div>

    <!-- KHUNG TÌM KIẾM & LỌC DỮ LIỆU -->
    <div class="card page-header-card shadow-sm mb-4">
        <div class="card-body p-4">
            <div class="row g-3">
                <div class="col-12 col-md-5">
                    <label class="form-label small fw-semibold text-secondary">Tìm kiếm sản phẩm</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" Placeholder="Nhập mã hoặc tên hàng hóa cần tìm..."></asp:TextBox>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label small fw-semibold text-secondary">Lọc theo loại hàng</label>
                    <asp:DropDownList ID="ddlLoaiHang" runat="server" CssClass="form-select">
                    </asp:DropDownList>
                </div>
                <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-dark w-100 py-2 fw-semibold" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2" OnClick="btnReset_Click" title="Đặt lại bộ lọc" />
                </div>
            </div>
        </div>
    </div>

    <!-- BẢNG HIỂN THỊ DANH SÁCH HÀNG HÓA -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvHangHoa" runat="server" CssClass="table table-custom table-hover mb-0 align-middle text-nowrap" 
                    AutoGenerateColumns="false" DataKeyNames="MaHangHoa" OnRowCommand="gvHangHoa_RowCommand" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="MaHangHoa" HeaderText="Mã Hàng" />
                        <asp:TemplateField HeaderText="Tên Hàng Hóa">
                            <ItemTemplate>
                                <span class="fw-semibold text-dark"><%# Eval("TenHangHoa") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Loại Hàng">
                            <ItemTemplate>
                                <span class="badge badge-category"><%# Eval("TenLoai") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DonViTinh" HeaderText="Đơn Vị Tính" />
                        <asp:TemplateField HeaderText="Đơn Giá">
                            <ItemTemplate>
                                <span class="text-success fw-bold"><%# Eval("DonGia", "{0:N0}") %> đ</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Hạn Sử Dụng">
                            <ItemTemplate>
                                <span class="text-muted small"><i class="fa-regular fa-calendar-days me-1"></i><%# Eval("HanSuDung", "{0:dd/MM/yyyy}") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <div class="d-flex gap-1">
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("MaHangHoa") %>' CssClass="btn btn-sm btn-light text-primary border" title="Sửa thông tin">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaHangHoa") %>' CssClass="btn btn-sm btn-light text-danger border" title="Xóa hàng hóa" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa hàng hóa này không?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-solid fa-box-open fs-1 mb-3 text-secondary opacity-50"></i>
                            <p class="mb-0">Không tìm thấy dữ liệu hàng hóa nào trong hệ thống.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- MODAL THÊM MỚI HÀNG HÓA -->
    <div class="modal fade" id="modalThemHang" tabindex="-1" aria-labelledby="modalThemHangLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-dark text-white px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalThemHangLabel">
                        <i class="fa-solid fa-box-open me-2 text-primary"></i> Thêm Hàng Hóa Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMaHang" runat="server" CssClass="form-control" Placeholder="VD: HH001"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTenHang" runat="server" CssClass="form-control" Placeholder="VD: Khẩu trang y tế..."></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Loại Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlThemLoaiHang" runat="server" CssClass="form-select">
                            </asp:DropDownList>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Đơn Vị Tính <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDonViTinh" runat="server" CssClass="form-control" Placeholder="Hộp, Cái, Thùng, Lốc..."></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Đơn Giá (VNĐ) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDonGia" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Hạn Sử Dụng <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtHanSuDung" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <asp:Button ID="btnLưuHang" runat="server" Text="Lưu Hàng Hóa" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLưuHang_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL CHỈNH SỬA HÀNG HÓA -->
    <div class="modal fade" id="modalSuaHang" tabindex="-1" aria-labelledby="modalSuaHangLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-warning text-dark px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalSuaHangLabel">
                        <i class="fa-solid fa-pen-to-square me-2"></i> Chỉnh Sửa Thông Tin Hàng Hóa
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Hàng Hóa (Khóa)</label>
                            <asp:TextBox ID="txtSuaMaHang" runat="server" CssClass="form-control bg-light" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaTenHang" runat="server" CssClass="form-control" Placeholder="Nhập tên hàng hóa..."></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Loại Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlSuaLoaiHang" runat="server" CssClass="form-select">
                            </asp:DropDownList>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Đơn Vị Tính <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaDonViTinh" runat="server" CssClass="form-control" Placeholder="Hộp, Cái, Thùng..."></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Đơn Giá (VNĐ) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaDonGia" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Hạn Sử Dụng <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaHanSuDung" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3 d-flex justify-content-between">
                    <asp:Button ID="btnLamMoiSua" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary px-4" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuuSuaHang" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-warning px-4 fw-semibold shadow-sm text-dark" OnClick="btnLuuSuaHang_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>