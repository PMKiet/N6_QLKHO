<%@ Page Title="Quản lý tài khoản" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuanLyTaiKhoan.aspx.cs" Inherits="N6_QLKHO.QuanLyTaiKhoan" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .nd-wrap { padding: 20px; }
        .nd-wrap h2 { margin: 0 0 16px; font-size: 22px; }
        .nd-bar { display: flex; gap: 8px; align-items: center; margin-bottom: 14px; flex-wrap: wrap; }
        .nd-bar .grow { flex: 1; }
        .nd-input { padding: 7px 10px; border: 1px solid #c9ced6; border-radius: 4px; width: 100%; box-sizing: border-box; }
        .nd-btn { padding: 7px 14px; border: 0; border-radius: 4px; cursor: pointer; color: #fff; background: #2f6fed; }
        .nd-btn.green { background: #198754; }
        .nd-table { width: 100%; border-collapse: collapse; background: #fff; }
        .nd-table th { background: #1f2937; color: #fff; text-align: left; padding: 9px 10px; }
        .nd-table td { padding: 8px 10px; border-bottom: 1px solid #e5e7eb; }
        .nd-table tr:hover td { background: #f3f6fb; }
        .nd-scroll { overflow-x: auto; }

        /* Cụm nút thao tác trên mỗi dòng */
        .nd-row-actions { display: flex; align-items: center; gap: 6px; }

        /* Nút icon vuông dùng chung (Sửa / Xoá) */
        .nd-icon-btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 34px; border-radius: 6px; border: 1px solid transparent;
            cursor: pointer; text-decoration: none;
            transition: background .15s, border-color .15s, color .15s;
        }
        .nd-icon-btn svg { display: block; }

        /* Nút Sửa: cây bút xanh, nền xanh nhạt */
        .nd-icon-btn.edit { background: #eaf1ff; border-color: #cfe0ff; color: #2f6fed; }
        .nd-icon-btn.edit:hover { background: #d9e6ff; border-color: #2f6fed; color: #1d57c9; }

        /* Nút Xoá: thùng rác đỏ, nền đỏ nhạt */
        .nd-icon-btn.delete { background: #fdecee; border-color: #f8c9cf; color: #dc3545; }
        .nd-icon-btn.delete:hover { background: #fad7dc; border-color: #dc3545; color: #b02a37; }

        /* Thông báo lỗi trong form: rỗng thì tự ẩn (cần !important để thắng class d-block của Bootstrap) */
        .modal-error:empty { display: none !important; }

        /* Ẩn con mắt mặc định của trình duyệt Edge để không bị hiện 2 con mắt */
        input[type="password"]::-ms-reveal { display: none; }
    </style>

    <!-- Làm sáng đúng mục "Quản Lý Tài Khoản" trong menu (không cần sửa Site.Master) -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.sidebar .nav-link.active').forEach(function (a) {
                a.classList.remove('active');
            });

            var link = document.querySelector('.sidebar a.nav-link[href$="QuanLyTaiKhoan.aspx"]');
            if (link) link.classList.add('active');

            var box = document.getElementById('adminSubmenu');
            if (box) {
                box.classList.add('show');
                var toggle = document.querySelector('[href="#adminSubmenu"]');
                if (toggle) toggle.setAttribute('aria-expanded', 'true');
            }
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="nd-wrap">
        <h2>Quản lý tài khoản</h2>

        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false" Visible="false" />

        <div class="nd-bar">
            <asp:TextBox ID="txtTimKiem" runat="server" CssClass="nd-input grow" placeholder="Tìm theo mã, tên đăng nhập, họ tên hoặc số điện thoại" />
            <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="nd-btn" OnClick="btnTimKiem_Click" CausesValidation="false" />
            <button type="button" class="nd-btn green" data-bs-toggle="modal" data-bs-target="#modalThemTK"
                onclick="document.getElementById('<%= lblLoiThem.ClientID %>').textContent = '';">Thêm tài khoản</button>
        </div>

        <div class="nd-scroll">
            <asp:GridView ID="gvNguoiDung" runat="server" AutoGenerateColumns="false" DataKeyNames="MaNhanVien"
                CssClass="nd-table" GridLines="None" OnRowCommand="gvNguoiDung_RowCommand"
                EmptyDataText="Không có tài khoản nào.">
                <Columns>
                    <asp:BoundField DataField="MaNhanVien" HeaderText="Mã NV" />
                    <asp:BoundField DataField="TenDangNhap" HeaderText="Tên đăng nhập" />
                    <asp:BoundField DataField="HoTen" HeaderText="Họ tên" />
                    <asp:BoundField DataField="SoDienThoai" HeaderText="Số điện thoại" />
                    <asp:BoundField DataField="DiaChi" HeaderText="Địa chỉ" />
                    <asp:BoundField DataField="ChucVu" HeaderText="Chức vụ" />
                    <asp:TemplateField HeaderText="Thao tác">
                        <ItemTemplate>
                            <div class="nd-row-actions">
                                <%-- Icon cây bút xanh: bấm vào để mở form sửa --%>
                                <asp:LinkButton runat="server" CssClass="nd-icon-btn edit" CommandName="Sua"
                                    CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                    ToolTip="Sửa tài khoản">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                    </svg>
                                </asp:LinkButton>

                                <%-- Icon thùng rác đỏ: bấm vào để xoá tài khoản --%>
                                <asp:LinkButton runat="server" CssClass="nd-icon-btn delete" CommandName="Xoa"
                                    CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                    ToolTip="Xoá tài khoản"
                                    OnClientClick="return confirm('Bạn có chắc muốn xoá tài khoản này?');">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <polyline points="3 6 5 6 21 6"></polyline>
                                        <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"></path>
                                        <path d="M10 11v6"></path>
                                        <path d="M14 11v6"></path>
                                        <path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"></path>
                                    </svg>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- MODAL THÊM TÀI KHOẢN -->
    <div class="modal fade" id="modalThemTK" tabindex="-1" aria-labelledby="modalThemTKLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-dark text-white px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalThemTKLabel">
                        <i class="fa-solid fa-user-plus me-2 text-primary"></i> Thêm Tài Khoản Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <asp:Label ID="lblLoiThem" runat="server" CssClass="modal-error alert alert-danger d-block" EnableViewState="false" />
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Nhân Viên <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMaNV" runat="server" CssClass="form-control" MaxLength="10" Placeholder="VD: NV04" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Đăng Nhập <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTenDN" runat="server" CssClass="form-control" MaxLength="50" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mật Khẩu <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control" TextMode="Password" MaxLength="50" autocomplete="new-password" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Họ Tên <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control" MaxLength="100" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Số Điện Thoại <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSDT" runat="server" CssClass="form-control" MaxLength="11" Placeholder="0939xxxxxx"
                                inputmode="numeric"
                                onkeypress="return event.charCode >= 48 && event.charCode <= 57;"
                                oninput="this.value = this.value.replace(/\D/g, '');" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Chức Vụ</label>
                            <asp:DropDownList ID="ddlChucVu" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Nhân viên" Value="Nhân viên" />
                                <asp:ListItem Text="Quản lý" Value="Quản lý" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Địa Chỉ <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <asp:Button ID="btnLuu" runat="server" Text="Lưu Tài Khoản" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" OnClick="btnLuu_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL CHỈNH SỬA TÀI KHOẢN -->
    <div class="modal fade" id="modalSuaTK" tabindex="-1" aria-labelledby="modalSuaTKLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-header bg-warning text-dark px-4 py-3">
                    <h5 class="modal-title fw-bold" id="modalSuaTKLabel">
                        <i class="fa-solid fa-pen-to-square me-2"></i> Chỉnh Sửa Thông Tin Tài Khoản
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <asp:HiddenField ID="hfMaGoc" runat="server" />
                    <asp:Label ID="lblLoiSua" runat="server" CssClass="modal-error alert alert-danger d-block" EnableViewState="false" />
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mã Nhân Viên (Khóa)</label>
                            <asp:TextBox ID="txtSuaMaNV" runat="server" CssClass="form-control bg-light" ReadOnly="true" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Tên Đăng Nhập <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaTenDN" runat="server" CssClass="form-control" MaxLength="50" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Mật Khẩu Mới (bỏ trống nếu không đổi)</label>
                            <asp:TextBox ID="txtSuaMatKhau" runat="server" CssClass="form-control" TextMode="Password" MaxLength="50" autocomplete="new-password" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Họ Tên <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaHoTen" runat="server" CssClass="form-control" MaxLength="100" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Số Điện Thoại <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaSDT" runat="server" CssClass="form-control" MaxLength="11" Placeholder="0939xxxxxx"
                                inputmode="numeric"
                                onkeypress="return event.charCode >= 48 && event.charCode <= 57;"
                                oninput="this.value = this.value.replace(/\D/g, '');" />
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label fw-semibold small text-secondary">Chức Vụ</label>
                            <asp:DropDownList ID="ddlSuaChucVu" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Nhân viên" Value="Nhân viên" />
                                <asp:ListItem Text="Quản lý" Value="Quản lý" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-secondary">Địa Chỉ <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSuaDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3 d-flex justify-content-between">
                    <asp:Button ID="btnLamMoiSua" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary px-4" OnClick="btnLamMoiSua_Click" CausesValidation="false" />
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-dark px-3" data-bs-dismiss="modal">Hủy bỏ</button>
                        <asp:Button ID="btnLuuSua" runat="server" Text="Lưu Thay Đổi" CssClass="btn btn-warning px-4 fw-semibold shadow-sm text-dark" OnClick="btnLuuSua_Click" CausesValidation="false" />
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
