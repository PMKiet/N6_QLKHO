<%@ Page Title="Quản Lý Tài Khoản" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuanLyTaiKhoan.aspx.cs" Inherits="N6_QLKHO.QuanLyTaiKhoan" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Thanh tiêu đề trang -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-users-gear"></i>
                </div>
                <div>
                    <h1 class="page-title mb-1">Quản Lý Tài Khoản</h1>
                    <p class="page-subtitle">Quản lý hồ sơ nhân sự, phân quyền chức vụ và bảo mật đăng nhập hệ thống</p>
                </div>
            </div>
            <div>
                <button type="button" class="btn btn-primary btn-icon fw-semibold px-3 py-2 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalThemTK"
                        onclick="document.getElementById('<%= lblLoiThem.ClientID %>').textContent = '';">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Thêm tài khoản</span>
                </button>
            </div>
        </div>

        <!-- Thông báo trạng thái -->
        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false" Visible="false" />

        <!-- Bộ lọc & Tìm kiếm -->
        <div class="wms-card">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <span>Tra Cứu Tài Khoản Nhân Sự</span>
                </h2>
                <span class="text-muted small">Tìm nhanh theo mã nhân viên, tên đăng nhập, họ tên hoặc SĐT</span>
            </div>
            <div class="p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-8 col-lg-9">
                        <label for="txtTimKiem" class="form-label-wms">Từ khóa tìm kiếm</label>
                        <div class="search-box">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <asp:TextBox ID="txtTimKiem" runat="server" CssClass="form-control" placeholder="Tìm theo mã nhân viên, tên đăng nhập, họ tên hoặc số điện thoại..." />
                        </div>
                    </div>
                    <div class="col-12 col-md-4 col-lg-3 d-grid">
                        <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm tài khoản" CssClass="btn btn-primary btn-search fw-semibold shadow-sm" OnClick="btnTimKiem_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Bảng danh sách tài khoản -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-id-card-clip"></i>
                    <span>Danh Sách Tài Khoản Hệ Thống</span>
                </h2>
                <span class="badge badge-soft-primary px-3 py-2 rounded-pill">
                    <i class="fa-solid fa-shield-halved me-1"></i>Phân quyền truy cập
                </span>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvNguoiDung" runat="server" AutoGenerateColumns="false" DataKeyNames="MaNhanVien"
                    CssClass="table table-custom align-middle mb-0" GridLines="None" OnRowCommand="gvNguoiDung_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Mã NV" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                            <ItemTemplate>
                                <span class="sku-badge"><%#: Eval("MaNhanVien") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tên Đăng Nhập" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                            <ItemTemplate>
                                <span class="fw-semibold text-primary">
                                    <i class="fa-regular fa-user me-1 text-muted small"></i><%#: Eval("TenDangNhap") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="HoTen" HeaderText="Họ Tên" ItemStyle-CssClass="fw-semibold text-dark" />
                        <asp:BoundField DataField="SoDienThoai" HeaderText="Số Điện Thoại" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap tabular-nums" />
                        <asp:BoundField DataField="DiaChi" HeaderText="Địa Chỉ" />
                        <asp:TemplateField HeaderText="Chức Vụ" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                            <ItemTemplate>
                                <span class='badge rounded-pill px-3 py-2 <%# Convert.ToString(Eval("ChucVu")) == "Quản lý" ? "badge-soft-primary" : "badge-soft-secondary" %>'>
                                    <i class='fa-solid <%# Convert.ToString(Eval("ChucVu")) == "Quản lý" ? "fa-user-shield" : "fa-id-badge" %> me-1'></i><%#: Eval("ChucVu") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao Tác" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap" ItemStyle-Width="120px">
                            <ItemTemplate>
                                <div class="row-actions">
                                    <%-- Nút Sửa tài khoản --%>
                                    <asp:LinkButton runat="server" CssClass="btn-action-icon edit" CommandName="Sua"
                                        CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                        ToolTip="Sửa tài khoản">
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </asp:LinkButton>

                                    <%-- Nút Xoá tài khoản --%>
                                    <asp:LinkButton runat="server" CssClass="btn-action-icon delete" CommandName="Xoa"
                                        CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                        ToolTip="Xoá tài khoản"
                                        OnClientClick="return confirm('Bạn có chắc muốn xoá tài khoản này?');">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <div class="empty-state-icon">
                                <i class="fa-solid fa-users-slash"></i>
                            </div>
                            <h6 class="fw-bold text-dark mb-1">Không tìm thấy tài khoản nào</h6>
                            <p class="small text-muted mb-0">Hãy thử thay đổi từ khóa tìm kiếm hoặc bấm "Thêm tài khoản" để tạo mới.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- MODAL THÊM TÀI KHOẢN -->
        <div class="modal fade" id="modalThemTK" tabindex="-1" aria-labelledby="modalThemTKLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold mb-0" id="modalThemTKLabel">
                            <i class="fa-solid fa-user-plus me-2 text-primary"></i>Thêm Tài Khoản Mới
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:Label ID="lblLoiThem" runat="server" CssClass="modal-error alert alert-danger d-block" EnableViewState="false" />
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Nhân Viên <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtMaNV" runat="server" CssClass="form-control" MaxLength="10" Placeholder="VD: NV04" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtTenDN" runat="server" CssClass="form-control" MaxLength="50" Placeholder="Từ 3-50 ký tự không dấu" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mật Khẩu <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control" TextMode="Password" MaxLength="50" autocomplete="new-password" Placeholder="Từ 6-50 ký tự" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Họ Tên <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control" MaxLength="100" Placeholder="Nhập họ và tên nhân viên" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Số Điện Thoại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSDT" runat="server" CssClass="form-control" MaxLength="11" Placeholder="0939xxxxxx"
                                    inputmode="numeric"
                                    onkeypress="return event.charCode >= 48 && event.charCode <= 57;"
                                    oninput="this.value = this.value.replace(/\D/g, '');" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Chức Vụ</label>
                                <asp:DropDownList ID="ddlChucVu" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Nhân viên" Value="Nhân viên" />
                                    <asp:ListItem Text="Quản lý" Value="Quản lý" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Địa Chỉ <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Nhập địa chỉ liên hệ..." />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuu" runat="server" Text="Lưu Tài Khoản" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuu_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL CHỈNH SỬA TÀI KHOẢN -->
        <div class="modal fade" id="modalSuaTK" tabindex="-1" aria-labelledby="modalSuaTKLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h5 class="modal-title fw-bold mb-0" id="modalSuaTKLabel">
                            <i class="fa-solid fa-pen-to-square me-2 text-warning"></i>Chỉnh Sửa Thông Tin Tài Khoản
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:HiddenField ID="hfMaGoc" runat="server" />
                        <asp:Label ID="lblLoiSua" runat="server" CssClass="modal-error alert alert-danger d-block" EnableViewState="false" />
                        <div class="row g-3">
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mã Nhân Viên (Khóa)</label>
                                <asp:TextBox ID="txtSuaMaNV" runat="server" CssClass="form-control readonly-user" ReadOnly="true" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaTenDN" runat="server" CssClass="form-control" MaxLength="50" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Mật Khẩu Mới (bỏ trống nếu không đổi)</label>
                                <asp:TextBox ID="txtSuaMatKhau" runat="server" CssClass="form-control" TextMode="Password" MaxLength="50" autocomplete="new-password" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Họ Tên <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaHoTen" runat="server" CssClass="form-control" MaxLength="100" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Số Điện Thoại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaSDT" runat="server" CssClass="form-control" MaxLength="11" Placeholder="0939xxxxxx"
                                    inputmode="numeric"
                                    onkeypress="return event.charCode >= 48 && event.charCode <= 57;"
                                    oninput="this.value = this.value.replace(/\D/g, '');" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label-wms">Chức Vụ</label>
                                <asp:DropDownList ID="ddlSuaChucVu" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Nhân viên" Value="Nhân viên" />
                                    <asp:ListItem Text="Quản lý" Value="Quản lý" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-12">
                                <label class="form-label-wms">Địa Chỉ <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtSuaDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern d-flex justify-content-between">
                        <asp:Button ID="btnLamMoiSua" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary px-4" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                            <asp:Button ID="btnLuuSua" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuuSua_Click" CausesValidation="false" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Biểu tượng con mắt xem / ẩn mật khẩu cho 2 ô mật khẩu -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var eyeOpen = "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg>";
            var eyeOff = "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24'/><line x1='1' y1='1' x2='23' y2='23'/></svg>";

            function themConMat(inputId) {
                var txt = document.getElementById(inputId);
                if (!txt) return;

                var wrap = document.createElement('div');
                wrap.style.position = 'relative';
                txt.parentNode.insertBefore(wrap, txt);
                wrap.appendChild(txt);
                txt.style.paddingRight = '42px';

                var btn = document.createElement('button');
                btn.type = 'button'; // không gây postback
                btn.title = 'Hiện / ẩn mật khẩu';
                btn.innerHTML = eyeOpen;
                btn.style.cssText = 'position:absolute;right:10px;top:50%;transform:translateY(-50%);' +
                    'border:0;background:transparent;padding:0;cursor:pointer;color:#6c757d;display:flex;align-items:center;';
                btn.onclick = function () {
                    if (txt.type === 'password') { txt.type = 'text'; btn.innerHTML = eyeOff; }
                    else { txt.type = 'password'; btn.innerHTML = eyeOpen; }
                };
                wrap.appendChild(btn);
            }

            themConMat('<%= txtMatKhau.ClientID %>');
            themConMat('<%= txtSuaMatKhau.ClientID %>');
        });
    </script>
</asp:Content>
