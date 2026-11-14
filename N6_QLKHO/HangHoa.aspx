<%@ Page Title="Quản Lý Hàng Hóa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HangHoa.aspx.cs" Inherits="N6_QLKHO.HangHoa" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- THANH TIÊU ĐỀ TRANG & NÚT HÀNH ĐỘNG -->
        <div class="wms-topbar d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-box-open"></i>
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h4 class="page-title mb-0">Quản Lý Hàng Hóa</h4>
                        <span class="badge badge-soft-primary">Danh mục vật tư</span>
                    </div>
                    <p class="page-subtitle mt-1">Quản lý danh mục sản phẩm, đơn vị tính, đơn giá tham chiếu, hạn sử dụng và phân loại hàng hóa.</p>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-primary btn-icon px-4 py-2 fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#modalThemHang">
                    <i class="fa-solid fa-plus"></i>
                    <span>Thêm Hàng Hóa Mới</span>
                </button>
            </div>
        </div>

        <!-- KHUNG TÌM KIẾM & LỌC DỮ LIỆU -->
        <div class="wms-card">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-filter"></i>
                    <span>Bộ Lọc &amp; Tìm Kiếm Sản Phẩm</span>
                </h5>
                <span class="text-muted small">Tra cứu nhanh theo mã hàng, tên sản phẩm hoặc nhóm loại</span>
            </div>
            <div class="card-body p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-5">
                        <label class="form-label-wms">Tìm kiếm sản phẩm</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" Placeholder="Nhập mã hoặc tên hàng hóa cần tìm..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-12 col-md-4">
                        <label class="form-label-wms">Lọc theo loại hàng</label>
                        <asp:DropDownList ID="ddlLoaiHang" runat="server" CssClass="form-select">
                        </asp:DropDownList>
                    </div>
                    <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                        <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary w-100 py-2 fw-semibold shadow-sm" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2 px-3 fw-semibold" OnClick="btnReset_Click" title="Đặt lại bộ lọc" />
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG HIỂN THỊ DANH SÁCH HÀNG HÓA -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-boxes-stacked"></i>
                    <span>Danh Sách Hàng Hóa Trong Hệ Thống</span>
                </h5>
                <span class="badge badge-soft-secondary"><i class="fa-solid fa-table-list me-1"></i>Dữ liệu danh mục</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <asp:GridView ID="gvHangHoa" runat="server" CssClass="table table-custom table-hover mb-0 align-middle" 
                        AutoGenerateColumns="false" DataKeyNames="MaHangHoa" OnRowCommand="gvHangHoa_RowCommand" GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="Mã Hàng" ItemStyle-Width="130px" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                <ItemTemplate>
                                    <span class="sku-badge"><%# Eval("MaHangHoa") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tên Hàng Hóa">
                                <ItemTemplate>
                                    <span class="fw-semibold text-dark"><%# Eval("TenHangHoa") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Loại Hàng" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                <ItemTemplate>
                                    <span class="badge badge-category"><%# Eval("TenLoai") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="DonViTinh" HeaderText="Đơn Vị Tính" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap fw-medium text-secondary" />
                            <asp:TemplateField HeaderText="Đơn Giá" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end col-nowrap tabular-nums">
                                <ItemTemplate>
                                    <span class="text-success fw-bold tabular-nums"><%# Eval("DonGia", "{0:N0}") %> VND</span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Hạn Sử Dụng" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap tabular-nums">
                                <ItemTemplate>
                                    <span class="badge badge-soft-secondary tabular-nums"><i class="fa-regular fa-calendar-days me-1"></i><%# Eval("HanSuDung", "{0:dd/MM/yyyy}") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap">
                                <ItemTemplate>
                                    <div class="row-actions">
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("MaHangHoa") %>' CssClass="btn-action-icon edit" title="Sửa thông tin">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaHangHoa") %>' CssClass="btn-action-icon delete" title="Xóa hàng hóa" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa hàng hóa này không?');">
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fa-solid fa-box-open"></i>
                                </div>
                                <div class="fw-semibold text-dark mb-1">Không tìm thấy dữ liệu hàng hóa</div>
                                <p class="small text-muted mb-0">Chưa có sản phẩm phù hợp với bộ lọc hoặc danh mục đang trống. Hãy bấm <strong>Thêm Hàng Hóa Mới</strong> để khởi tạo.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- MODAL THÊM MỚI HÀNG HÓA -->
        <div class="modal fade" id="modalThemHang" tabindex="-1" aria-labelledby="modalThemHangLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalThemHangLabel">
                            <i class="fa-solid fa-box-open text-primary"></i>
                            <span>Thêm Hàng Hóa Mới</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtMaHang" runat="server" CssClass="form-control" Placeholder="VD: HH001"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtTenHang" runat="server" CssClass="form-control" Placeholder="VD: Khẩu trang y tế..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Loại Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlThemLoaiHang" runat="server" CssClass="form-select">
                                </asp:DropDownList>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Đơn Vị Tính <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtDonViTinh" runat="server" CssClass="form-control" Placeholder="Hộp, Cái, Thùng, Lốc..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Đơn Giá (VNĐ) <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtDonGia" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Hạn Sử Dụng <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtHanSuDung" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLưuHang" runat="server" Text="Lưu Hàng Hóa" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLưuHang_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL CHỈNH SỬA HÀNG HÓA -->
        <div class="modal fade" id="modalSuaHang" tabindex="-1" aria-labelledby="modalSuaHangLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalSuaHangLabel">
                            <i class="fa-solid fa-pen-to-square text-warning"></i>
                            <span>Chỉnh Sửa Thông Tin Hàng Hóa</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Hàng Hóa (Khóa)</label>
                                <asp:TextBox ID="txtSuaMaHang" runat="server" CssClass="form-control readonly-user" ReadOnly="true"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaTenHang" runat="server" CssClass="form-control" Placeholder="Nhập tên hàng hóa..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Loại Hàng Hóa <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlSuaLoaiHang" runat="server" CssClass="form-select">
                                </asp:DropDownList>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Đơn Vị Tính <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaDonViTinh" runat="server" CssClass="form-control" Placeholder="Hộp, Cái, Thùng..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Đơn Giá (VNĐ) <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaDonGia" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Hạn Sử Dụng <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaHanSuDung" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern d-flex justify-content-between">
                        <asp:Button ID="btnLamMoiSua" runat="server" Text="Khôi phục gốc" CssClass="btn btn-outline-secondary px-3" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                            <asp:Button ID="btnLuuSuaHang" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuSuaHang_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
