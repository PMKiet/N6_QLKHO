<%@ Page Title="Quản Lý Nhà Cung Cấp" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NhaCungCap.aspx.cs" Inherits="N6_QLKHO.NhaCungCap" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- THANH TIÊU ĐỀ TRANG & NÚT HÀNH ĐỘNG -->
        <div class="wms-topbar d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-truck-field"></i>
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h4 class="page-title mb-0">Quản Lý Nhà Cung Cấp</h4>
                        <span class="badge badge-soft-success">Đối tác cung ứng</span>
                    </div>
                    <p class="page-subtitle mt-1">Quản lý hồ sơ đối tác, nhà phân phối vật tư, số điện thoại, email và địa chỉ giao dịch.</p>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-primary btn-icon px-4 py-2 fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#modalThemNCC">
                    <i class="fa-solid fa-plus"></i>
                    <span>Thêm Nhà Cung Cấp Mới</span>
                </button>
            </div>
        </div>

        <!-- Label thông báo -->
        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

        <!-- KHUNG TÌM KIẾM DỮ LIỆU -->
        <div class="wms-card">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <span>Tìm Kiếm Đối Tác &amp; Nhà Cung Cấp</span>
                </h5>
                <span class="text-muted small">Tra cứu theo mã NCC, tên đơn vị hoặc số điện thoại liên hệ</span>
            </div>
            <div class="card-body p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-9">
                        <label class="form-label-wms">Tìm kiếm nhà cung cấp</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" Placeholder="Nhập mã, tên nhà cung cấp hoặc số điện thoại..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                        <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary w-100 py-2 fw-semibold shadow-sm" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2 px-3 fw-semibold" OnClick="btnReset_Click" title="Đặt lại bộ lọc" />
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG HIỂN THỊ DANH SÁCH NHÀ CUNG CẤP -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-building-shield"></i>
                    <span>Danh Sách Nhà Cung Cấp</span>
                </h5>
                <span class="badge badge-soft-secondary"><i class="fa-solid fa-address-book me-1"></i>Danh bạ đối tác</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <asp:GridView ID="gvNhaCungCap" runat="server" CssClass="table table-custom table-hover mb-0 align-middle" 
                        AutoGenerateColumns="false" DataKeyNames="MaNCC" OnRowCommand="gvNhaCungCap_RowCommand" GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="Mã NCC" ItemStyle-Width="120px" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                <ItemTemplate>
                                    <span class="sku-badge"><%# Eval("MaNCC") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tên Nhà Cung Cấp">
                                <ItemTemplate>
                                    <span class="fw-semibold text-dark"><%# Eval("TenNCC") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Số Điện Thoại" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap tabular-nums">
                                <ItemTemplate>
                                    <span class="badge badge-soft-primary tabular-nums"><i class="fa-solid fa-phone me-1"></i><%# Eval("SoDienThoai") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Email" HeaderText="Email" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap text-secondary small" />
                            <asp:TemplateField HeaderText="Địa Chỉ">
                                <ItemTemplate>
                                    <span class="text-secondary small"><%# Eval("DiaChi") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap">
                                <ItemTemplate>
                                    <div class="row-actions">
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("MaNCC") %>' CssClass="btn-action-icon edit" title="Sửa thông tin">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaNCC") %>' CssClass="btn-action-icon delete" title="Xóa nhà cung cấp" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa nhà cung cấp này không?');">
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fa-solid fa-truck-field"></i>
                                </div>
                                <div class="fw-semibold text-dark mb-1">Không tìm thấy dữ liệu nhà cung cấp</div>
                                <p class="small text-muted mb-0">Chưa có nhà cung cấp nào khớp với từ khóa hoặc danh sách đang trống. Hãy bấm <strong>Thêm Nhà Cung Cấp Mới</strong> để bổ sung.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- MODAL THÊM MỚI NHÀ CUNG CẤP -->
        <div class="modal fade" id="modalThemNCC" tabindex="-1" aria-labelledby="modalThemNCCLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalThemNCCLabel">
                            <i class="fa-solid fa-truck-field text-primary"></i>
                            <span>Thêm Nhà Cung Cấp Mới</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Nhà Cung Cấp <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtMaNCC" runat="server" CssClass="form-control" Placeholder="VD: NCC04"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Nhà Cung Cấp <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtTenNCC" runat="server" CssClass="form-control" Placeholder="VD: Công ty TNHH..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Số Điện Thoại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSoDienThoai" runat="server" CssClass="form-control" Placeholder="0939xxxxxx"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Email <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" Placeholder="contact@domain.com"></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Địa Chỉ <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Số nhà, đường, phường/xã, tỉnh/TP..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuuNCC" runat="server" Text="Lưu Nhà Cung Cấp" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuNCC_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL CHỈNH SỬA NHÀ CUNG CẤP -->
        <div class="modal fade" id="modalSuaNCC" tabindex="-1" aria-labelledby="modalSuaNCCLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="modalSuaNCCLabel">
                            <i class="fa-solid fa-pen-to-square text-warning"></i>
                            <span>Chỉnh Sửa Thông Tin Nhà Cung Cấp</span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Nhà Cung Cấp (Khóa)</label>
                                <asp:TextBox ID="txtSuaMaNCC" runat="server" CssClass="form-control readonly-user" ReadOnly="true"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Nhà Cung Cấp <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaTenNCC" runat="server" CssClass="form-control" Placeholder="Nhập tên nhà cung cấp..."></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Số Điện Thoại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaSoDienThoai" runat="server" CssClass="form-control" Placeholder="0939xxxxxx"></asp:TextBox>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Email <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaEmail" runat="server" CssClass="form-control" TextMode="Email" Placeholder="contact@domain.com"></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Địa Chỉ <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Địa chỉ nhà cung cấp..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern d-flex justify-content-between">
                        <asp:Button ID="btnLamMoiSua" runat="server" Text="Khôi phục gốc" CssClass="btn btn-outline-secondary px-3" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                            <asp:Button ID="btnLuuSuaNCC" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuSuaNCC_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
