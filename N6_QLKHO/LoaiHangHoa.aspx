<%@ Page Title="Quản Lý Loại Hàng Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LoaiHangHoa.aspx.cs" Inherits="N6_QLKHO.LoaiHangHoa" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- THANH TIÊU ĐỀ TRANG & NÚT HÀNH ĐỘNG -->
        <div class="wms-topbar d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-tags"></i>
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h4 class="page-title mb-0">Quản Lý Loại Hàng Hóa</h4>
                        <span class="badge badge-soft-info">Phân nhóm vật tư</span>
                    </div>
                    <p class="page-subtitle mt-1">Quản lý các nhóm danh mục, phân loại hàng hóa và vật tư lưu trữ trong kho.</p>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-primary btn-icon px-4 py-2 fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#modalThemLoai">
                    <i class="fa-solid fa-plus"></i>
                    <span>Thêm Loại Hàng Hóa</span>
                </button>
            </div>
        </div>

        <!-- KHUNG TÌM KIẾM -->
        <div class="wms-card">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <span>Tra Cứu Nhóm &amp; Loại Hàng Hóa</span>
                </h5>
                <span class="text-muted small">Hỗ trợ lọc tự động khi nhập từ khóa</span>
            </div>
            <div class="card-body p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-9">
                        <label class="form-label-wms">Tìm kiếm loại hàng hóa</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0"
                                Placeholder="Nhập mã hoặc tên loại hàng hóa..."
                                AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                        <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary w-100 py-2 fw-semibold shadow-sm" OnClick="btnTimKiem_Click" />
                        <asp:Button ID="btnLamMoi" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2 px-3 fw-semibold" OnClick="btnLamMoi_Click" title="Đặt lại bộ lọc" />
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH LOẠI HÀNG HÓA -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Danh Sách Loại Hàng Hóa</span>
                </h5>
                <span class="badge badge-soft-secondary"><i class="fa-solid fa-list-ul me-1"></i>Phân trang 10 dòng/trang</span>
            </div>
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
                            <asp:TemplateField HeaderText="Mã Loại" ItemStyle-Width="140px" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                <ItemTemplate>
                                    <span class="sku-badge"><%# Eval("MaLoai") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tên Loại Hàng Hóa" ItemStyle-Width="280px">
                                <ItemTemplate>
                                    <span class="fw-semibold text-dark"><%# Eval("TenLoai") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Mô Tả Chi Tiết">
                                <ItemTemplate>
                                    <span class="text-secondary small"><%# Eval("MoTa") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap">
                                <ItemTemplate>
                                    <div class="row-actions">
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("MaLoai") %>'
                                            CssClass="btn-action-icon edit" title="Sửa thông tin">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaLoai") %>'
                                            CssClass="btn-action-icon delete" title="Xóa loại hàng hóa"
                                            OnClientClick="return confirm('Bạn có chắc chắn muốn xóa loại hàng hóa này không?');">
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fa-solid fa-boxes-stacked"></i>
                                </div>
                                <div class="fw-semibold text-dark mb-1">Không có loại hàng hóa nào trong hệ thống</div>
                                <p class="small text-muted mb-0">Hãy bấm nút <strong>Thêm Loại Hàng Hóa</strong> ở góc trên để tạo phân nhóm vật tư mới.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- MODAL THÊM MỚI LOẠI HÀNG HÓA -->
        <div class="modal fade" id="modalThemLoai" tabindex="-1" aria-labelledby="modalThemLoaiLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalThemLoaiLabel">
                            <i class="fa-solid fa-tags text-primary"></i>
                            <span>Thêm Loại Hàng Hóa</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Loại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtMaLoai" runat="server" CssClass="form-control" MaxLength="10" Placeholder="VD: L06"></asp:TextBox>
                                <div class="form-text small">Tối đa 10 ký tự</div>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Loại Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtTenLoai" runat="server" CssClass="form-control" MaxLength="100" Placeholder="VD: Vật liệu xây dựng"></asp:TextBox>
                                <div class="form-text small">Tối đa 100 ký tự</div>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Mô Tả</label>
                                <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" Placeholder="Mô tả đặc điểm nhóm loại hàng hóa..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuu" runat="server" Text="Lưu Loại Hàng Hóa" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLưu_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL CHỈNH SỬA LOẠI HÀNG HÓA -->
        <div class="modal fade" id="modalSuaLoai" tabindex="-1" aria-labelledby="modalSuaLoaiLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalSuaLoaiLabel">
                            <i class="fa-solid fa-pen-to-square text-warning"></i>
                            <span>Chỉnh Sửa Loại Hàng Hóa</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Loại (Khóa)</label>
                                <asp:TextBox ID="txtSuaMaLoai" runat="server" CssClass="form-control readonly-user" ReadOnly="true"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Loại Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaTenLoai" runat="server" CssClass="form-control" MaxLength="100" Placeholder="Nhập tên loại hàng hóa..."></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Mô Tả</label>
                                <asp:TextBox ID="txtSuaMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" Placeholder="Mô tả loại hàng hóa..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern d-flex justify-content-between">
                        <asp:Button ID="btnLamMoiSua" runat="server" Text="Khôi phục gốc" CssClass="btn btn-outline-secondary px-3" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                            <asp:Button ID="btnLuuSuaLoai" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuSuaLoai_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
