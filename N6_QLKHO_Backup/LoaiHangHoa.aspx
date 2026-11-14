<%@ Page Title="Quản Lý Loại Hàng Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LoaiHangHoa.aspx.cs" Inherits="N6_QLKHO.LoaiHangHoa" %>

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
        .pager-custom table { margin: 12px auto; }
        .pager-custom td { padding: 0 3px; }
        .pager-custom a, .pager-custom span {
            display: inline-block;
            padding: 4px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            text-decoration: none;
            color: #475569;
        }
        .pager-custom span { background: #0d6efd; color: #fff; border-color: #0d6efd; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Tiêu đề trang & Nút hành động -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Quản Lý Loại Hàng Hóa</h3>
            <p class="text-muted small mb-0">Quản lý các nhóm, loại hàng hóa và vật tư trong kho.</p>
        </div>
        <div>
            <button type="button" class="btn btn-primary shadow-sm px-4 py-2 d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#modalThemLoai">
                <i class="fa-solid fa-plus"></i>
                <span>Thêm Loại Hàng Hóa</span>
            </button>
        </div>
    </div>

    <!-- KHUNG TÌM KIẾM -->
    <div class="card page-header-card shadow-sm mb-4">
        <div class="card-body p-4">
            <div class="row g-3">
                <div class="col-12 col-md-9">
                    <label class="form-label small fw-semibold text-secondary">Tìm kiếm loại hàng hóa</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0"
                            Placeholder="Nhập mã hoặc tên loại hàng hóa..."
                            AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    </div>
                </div>
                <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                    <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="btn btn-dark w-100 py-2 fw-semibold" OnClick="btnTimKiem_Click" />
                    <asp:Button ID="btnLamMoi" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2" OnClick="btnLamMoi_Click" title="Đặt lại bộ lọc" />
                </div>
            </div>
        </div>
    </div>

    <!-- BẢNG DANH SÁCH LOẠI HÀNG HÓA -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvLoaiHangHoa" runat="server"
                    CssClass="table table-custom table-hover mb-0 align-middle"
                    AutoGenerateColumns="false" GridLines="None"
                    DataKeyNames="MaLoai"
                    AllowPaging="true" PageSize="10"
                    PagerStyle-CssClass="pager-custom" PagerStyle-HorizontalAlign="Center"
                    OnRowCommand="gvLoaiHangHoa_RowCommand"
                    OnPageIndexChanging="gvLoaiHangHoa_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="MaLoai" HeaderText="Mã Loại" />
                        <asp:TemplateField HeaderText="Tên Loại Hàng Hóa">
                            <ItemTemplate>
                                <span class="fw-semibold text-dark"><%# Eval("TenLoai") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Mô Tả">
                            <ItemTemplate>
                                <span class="text-muted small"><%# Eval("MoTa") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <div class="d-flex gap-1">
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("MaLoai") %>'
                                        CssClass="btn btn-sm btn-light text-primary border" title="Sửa thông tin">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaLoai") %>'
                                        CssClass="btn btn-sm btn-light text-danger border" title="Xóa loại hàng hóa"
                                        OnClientClick="return confirm('Bạn có chắc chắn muốn xóa loại hàng hóa này không?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-solid fa-boxes-stacked fs-1 mb-3 text-secondary opacity-50"></i>
                            <p class="mb-0">Không có loại hàng hóa nào trong hệ thống.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- MODAL THÊM MỚI LOẠI HÀNG HÓA -->
    <div class="modal fade" id="modalThemLoai" tabindex="-1" aria-labelledby="modalThemLoaiLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-dark text-white px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalThemLoaiLabel">
                        <i class="fa-solid fa-boxes-stacked me-2 text-primary"></i> Thêm Loại Hàng Hóa
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Loại <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMaLoai" runat="server" CssClass="form-control" MaxLength="10" Placeholder="VD: L06"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Loại Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTenLoai" runat="server" CssClass="form-control" MaxLength="100" Placeholder="VD: Vật liệu xây dựng"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Mô Tả</label>
                            <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Mô tả loại hàng hóa..."></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <asp:Button ID="btnLuu" runat="server" Text="Lưu Loại Hàng Hóa" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLưu_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL CHỈNH SỬA LOẠI HÀNG HÓA -->
    <div class="modal fade" id="modalSuaLoai" tabindex="-1" aria-labelledby="modalSuaLoaiLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-warning text-dark px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalSuaLoaiLabel">
                        <i class="fa-solid fa-pen-to-square me-2"></i> Chỉnh Sửa Loại Hàng Hóa
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Loại (Khóa)</label>
                            <asp:TextBox ID="txtSuaMaLoai" runat="server" CssClass="form-control bg-light" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Loại Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaTenLoai" runat="server" CssClass="form-control" MaxLength="100" Placeholder="Nhập tên loại hàng hóa..."></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Mô Tả</label>
                            <asp:TextBox ID="txtSuaMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" Placeholder="Mô tả loại hàng hóa..."></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3 d-flex justify-content-between">
                    <asp:Button ID="btnLamMoiSua" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary px-4" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuuSuaLoai" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-warning px-4 fw-semibold shadow-sm text-dark" OnClick="btnLuuSuaLoai_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
