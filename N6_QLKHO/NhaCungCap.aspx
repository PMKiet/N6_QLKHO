<%@ Page Title="Quản Lý Nhà Cung Cấp" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NhaCungCap.aspx.cs" Inherits="N6_QLKHO.NhaCungCap" %>

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
        .badge-ncc {
            background-color: #f0fdf4;
            color: #16a34a;
            border: 1px solid #dcfce7;
            font-weight: 500;
            padding: 5px 10px;
            border-radius: 6px;
        }
    </style>

    <!-- Script chặn nhập ký tự không phải là số -->
    <script type="text/javascript">
        function isNumberKey(evt) {
            var charCode = (evt.which) ? evt.which : event.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }
            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Tiêu đề trang & Nút hành động -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Quản Lý Nhà Cung Cấp</h3>
            <p class="text-muted small mb-0">Quản lý thông tin đối tác, nhà cung cấp vật tư và thông tin liên hệ.</p>
        </div>
        <div>
            <button type="button" class="btn btn-primary shadow-sm px-4 py-2 d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#modalThemNCC">
                <i class="fa-solid fa-plus"></i>
                <span>Thêm Nhà Cung Cấp Mới</span>
            </button>
        </div>
    </div>

    <!-- Label thông báo -->
    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

    <!-- KHUNG TÌM KIẾM DỮ LIỆU -->
    <div class="card page-header-card shadow-sm mb-4">
        <div class="card-body p-4">
            <div class="row g-3">
                <div class="col-12 col-md-9">
                    <label class="form-label small fw-semibold text-secondary">Tìm kiếm nhà cung cấp</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control border-start-0 ps-0" Placeholder="Nhập mã, tên nhà cung cấp hoặc số điện thoại..."></asp:TextBox>
                    </div>
                </div>
                <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-dark w-100 py-2 fw-semibold" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary py-2" OnClick="btnReset_Click" title="Đặt lại bộ lọc" />
                </div>
            </div>
        </div>
    </div>

    <!-- BẢNG HIỂN THỊ DANH SÁCH NHÀ CUNG CẤP (CHỈNH SỬA TRỰC TIẾP TRÊN DÒNG) -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvNhaCungCap" runat="server" CssClass="table table-custom table-hover mb-0 align-middle text-nowrap" 
                    AutoGenerateColumns="false" DataKeyNames="MaNCC" 
                    OnRowEditing="gvNhaCungCap_RowEditing" 
                    OnRowUpdating="gvNhaCungCap_RowUpdating" 
                    OnRowCancelingEdit="gvNhaCungCap_RowCancelingEdit" 
                    OnRowCommand="gvNhaCungCap_RowCommand" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="MaNCC" HeaderText="Mã NCC" ReadOnly="true" />
                        
                        <asp:TemplateField HeaderText="Tên Nhà Cung Cấp">
                            <ItemTemplate>
                                <span class="fw-semibold text-dark"><%# Eval("TenNCC") %></span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditTenNCC" runat="server" Text='<%# Bind("TenNCC") %>' CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Số Điện Thoại">
                            <ItemTemplate>
                                <%# Eval("SoDienThoai") %>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <!-- Đã thêm onkeypress để chỉ cho phép gõ số -->
                                <asp:TextBox ID="txtEditSoDienThoai" runat="server" Text='<%# Bind("SoDienThoai") %>' CssClass="form-control form-control-sm" onkeypress="return isNumberKey(event);" MaxLength="15"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate>
                                <%# Eval("Email") %>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditEmail" runat="server" Text='<%# Bind("Email") %>' TextMode="Email" CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Địa Chỉ">
                            <ItemTemplate>
                                <span class="text-muted small"><%# Eval("DiaChi") %></span>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditDiaChi" runat="server" Text='<%# Bind("DiaChi") %>' CssClass="form-control form-control-sm"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <div class="d-flex gap-1">
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-light text-primary border" title="Sửa thông tin trực tiếp">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("MaNCC") %>' CssClass="btn btn-sm btn-light text-danger border" title="Xóa nhà cung cấp" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa nhà cung cấp này không?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="d-flex gap-1">
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
                    <EmptyDataTemplate>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-solid fa-truck-field fs-1 mb-3 text-secondary opacity-50"></i>
                            <p class="mb-0">Không tìm thấy dữ liệu nhà cung cấp nào trong hệ thống.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- MODAL THÊM MỚI NHÀ CUNG CẤP -->
    <div class="modal fade" id="modalThemNCC" tabindex="-1" aria-labelledby="modalThemNCCLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-dark text-white px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalThemNCCLabel">
                        <i class="fa-solid fa-truck-field me-2 text-primary"></i> Thêm Nhà Cung Cấp Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Nhà Cung Cấp <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMaNCC" runat="server" CssClass="form-control" Placeholder="VD: NCC04"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Nhà Cung Cấp <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTenNCC" runat="server" CssClass="form-control" Placeholder="VD: Công ty TNHH..."></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Số Điện Thoại <span class="text-danger">*</span></label>
                            <!-- Đã thêm onkeypress để chỉ cho phép gõ số -->
                            <asp:TextBox ID="txtSoDienThoai" runat="server" CssClass="form-control" Placeholder="0939xxxxxx" onkeypress="return isNumberKey(event);" MaxLength="15"></asp:TextBox>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Email <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" Placeholder="contact@domain.com"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Địa Chỉ <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Số nhà, đường, phường/xã, tỉnh/TP..."></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <asp:Button ID="btnLuuNCC" runat="server" Text="Lưu Nhà Cung Cấp" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuNCC_Click" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>