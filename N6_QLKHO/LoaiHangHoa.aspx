<%@ Page Title="Quản lý Loại Hàng Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LoaiHangHoa.aspx.cs" Inherits="N6_QLKHO.LoaiHangHoa" %>

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

    <!-- Tiêu đề trang & Nút mở Modal Thêm mới -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Quản Lý Loại Hàng Hóa</h3>
            <p class="text-muted small mb-0">Quản lý danh mục phân loại sản phẩm, nhóm hàng trong kho.</p>
        </div>
        <div>
            <button type="button" class="btn btn-primary shadow-sm px-4 py-2 d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#modalThemLoai">
                <i class="fa-solid fa-plus"></i>
                <span>Thêm Loại Mới</span>
            </button>
        </div>
    </div>

    <!-- KHUNG TÌM KIẾM & LỌC DỮ LIỆU -->
    <div class="card page-header-card shadow-sm mb-4">
        <div class="card-body p-4">
            <div class="row g-3">
                <div class="col-12 col-md-9">
                    <label class="form-label small fw-semibold text-secondary">Tìm kiếm loại hàng hóa</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Nhập mã hoặc tên loại hàng hóa cần tìm..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    </div>
                </div>
                <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                    <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="btn btn-dark w-100 py-2 fw-semibold" OnClick="btnTimKiem_Click" />
                    <asp:Button ID="btnLamMoi" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2" OnClick="btnLamMoi_Click" title="Đặt lại bộ lọc" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <!-- BẢNG HIỂN THỊ DANH SÁCH LOẠI HÀNG HÓA -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvLoaiHangHoa" runat="server" CssClass="table table-custom table-hover mb-0 align-middle text-nowrap" 
                    AutoGenerateColumns="False" DataKeyNames="MaLoai" 
                    AllowPaging="True" PageSize="5" OnPageIndexChanging="gvLoaiHangHoa_PageIndexChanging" 
                    OnRowEditing="gvLoaiHangHoa_RowEditing"
                    OnRowCancelingEdit="gvLoaiHangHoa_RowCancelingEdit"
                    OnRowUpdating="gvLoaiHangHoa_RowUpdating"
                    OnRowDeleting="gvLoaiHangHoa_RowDeleting" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="MaLoai" HeaderText="Mã Loại" ReadOnly="true" ItemStyle-Width="150px" />

                        <asp:TemplateField HeaderText="Tên Loại Hàng Hóa">
                            <ItemTemplate>
                                <span class="badge badge-category"><%# Eval("TenLoai") %></span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditTenLoai" runat="server" Text='<%# Bind("TenLoai") %>' CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Mô Tả">
                            <ItemTemplate>
                                <span class="text-muted"><%# Eval("MoTa") %></span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditMoTa" runat="server" Text='<%# Bind("MoTa") %>' CssClass="form-control form-control-sm" TextMode="MultiLine" Rows="1"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <div class="d-flex gap-1 justify-content-center">
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-light text-primary border" title="Sửa trực tiếp">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-light text-danger border" title="Xóa loại hàng" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa loại hàng hóa này không?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="d-flex gap-1 justify-content-center">
                                    <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn btn-sm btn-success text-white" title="Lưu thay đổi">
                                        <i class="fa-solid fa-check"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn btn-sm btn-secondary text-white" title="Hủy bỏ">
                                        <i class="fa-solid fa-xmark"></i>
                                    </asp:LinkButton>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination-container p-3 text-end" />
                    <EmptyDataTemplate>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-solid fa-folder-open fs-1 mb-3 text-secondary opacity-50"></i>
                            <p class="mb-0">Không tìm thấy loại hàng hóa nào trong hệ thống.</p>
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
                        <i class="fa-solid fa-folder-plus me-2 text-primary"></i> Thêm Mới Loại Hàng Hóa
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold small text-secondary">Mã Loại <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMaLoai" runat="server" CssClass="form-control" placeholder="Ví dụ: L05"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-8">
                            <label class="form-label fw-semibold small text-secondary">Tên Loại Hàng Hóa <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTenLoai" runat="server" CssClass="form-control" placeholder="Nhập tên loại hàng hóa..."></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Mô Tả Chi Tiết</label>
                            <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Nhập mô tả loại hàng hóa..."></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <asp:Button ID="btnLưu" runat="server" Text="Lưu Loại Hàng" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLưu_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Script Bootstrap local -->
    <script src="Scripts/bootstrap.bundle.min.js"></script>
</asp:Content>