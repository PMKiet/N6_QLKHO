<%@ Page Title="Quản lý tài khoản" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuanLyTaiKhoan.aspx.cs" Inherits="N6_QLKHO.QuanLyTaiKhoan" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .nd-wrap { padding: 20px; }
        .nd-wrap h2 { margin: 0 0 16px; font-size: 22px; }
        .nd-bar { display: flex; gap: 8px; align-items: center; margin-bottom: 14px; flex-wrap: wrap; }
        .nd-bar .grow { flex: 1; }
        .nd-input { padding: 7px 10px; border: 1px solid #c9ced6; border-radius: 4px; width: 100%; box-sizing: border-box; }
        .nd-btn { padding: 7px 14px; border: 0; border-radius: 4px; cursor: pointer; color: #fff; background: #2f6fed; }
        .nd-btn.gray { background: #6b7280; }
        .nd-btn.green { background: #198754; }
        .nd-btn.red { background: #d63a3a; }
        .nd-btn.amber { background: #d98a00; }
        .nd-form { background: #f6f7f9; border: 1px solid #dfe3e8; border-radius: 6px; padding: 16px; margin-bottom: 18px; }
        .nd-form h3 { margin: 0 0 12px; font-size: 17px; }
        .nd-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 12px; }
        .nd-grid label { display: block; margin-bottom: 4px; font-size: 13px; color: #444; }
        .nd-actions { margin-top: 14px; display: flex; gap: 8px; }
        .nd-msg { margin-bottom: 12px; font-weight: 600; }
        .nd-msg.ok { color: #198754; }
        .nd-msg.err { color: #d63a3a; }
        .nd-table { width: 100%; border-collapse: collapse; background: #fff; }
        .nd-table th { background: #1f2937; color: #fff; text-align: left; padding: 9px 10px; }
        .nd-table td { padding: 8px 10px; border-bottom: 1px solid #e5e7eb; }
        .nd-table tr:hover td { background: #f3f6fb; }
        .nd-scroll { overflow-x: auto; }
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

        <asp:Label ID="lblThongBao" runat="server" CssClass="nd-msg" Visible="false" />

        <div class="nd-bar">
            <asp:TextBox ID="txtTimKiem" runat="server" CssClass="nd-input grow" placeholder="Tìm theo mã, tên đăng nhập, họ tên hoặc số điện thoại" />
            <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="nd-btn" OnClick="btnTimKiem_Click" CausesValidation="false" />
            <asp:Button ID="btnThem" runat="server" Text="Thêm tài khoản" CssClass="nd-btn green" OnClick="btnThem_Click" CausesValidation="false" />
        </div>

        <asp:Panel ID="pnlForm" runat="server" CssClass="nd-form" Visible="false">
            <h3><asp:Label ID="lblTieuDeForm" runat="server" /></h3>
            <asp:HiddenField ID="hfMaGoc" runat="server" />
            <div class="nd-grid">
                <div>
                    <label>Mã nhân viên</label>
                    <asp:TextBox ID="txtMaNV" runat="server" CssClass="nd-input" MaxLength="10" />
                </div>
                <div>
                    <label>Tên đăng nhập</label>
                    <asp:TextBox ID="txtTenDN" runat="server" CssClass="nd-input" MaxLength="50" />
                </div>
                <div>
                    <label><asp:Label ID="lblMatKhau" runat="server" Text="Mật khẩu" /></label>
                    <asp:TextBox ID="txtMatKhau" runat="server" CssClass="nd-input" TextMode="Password" MaxLength="50" />
                </div>
                <div>
                    <label>Họ tên</label>
                    <asp:TextBox ID="txtHoTen" runat="server" CssClass="nd-input" MaxLength="100" />
                </div>
                <div>
                    <label>Số điện thoại</label>
                    <asp:TextBox ID="txtSDT" runat="server" CssClass="nd-input" MaxLength="15" />
                </div>
                <div>
                    <label>Chức vụ</label>
                    <asp:DropDownList ID="ddlChucVu" runat="server" CssClass="nd-input">
                        <asp:ListItem Text="Nhân viên" Value="Nhân viên" />
                        <asp:ListItem Text="Quản lý" Value="Quản lý" />
                    </asp:DropDownList>
                </div>
                <div style="grid-column: 1 / -1;">
                    <label>Địa chỉ</label>
                    <asp:TextBox ID="txtDiaChi" runat="server" CssClass="nd-input" MaxLength="255" />
                </div>
            </div>
            <div class="nd-actions">
                <asp:Button ID="btnLuu" runat="server" Text="Lưu" CssClass="nd-btn" OnClick="btnLuu_Click" CausesValidation="false" />
                <asp:Button ID="btnHuy" runat="server" Text="Huỷ" CssClass="nd-btn gray" OnClick="btnHuy_Click" CausesValidation="false" />
            </div>
        </asp:Panel>

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
                            <asp:Button runat="server" Text="Sửa" CssClass="nd-btn amber" CommandName="Sua"
                                CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false" />
                            <asp:Button runat="server" Text="Đặt lại MK" CssClass="nd-btn gray" CommandName="DatLai"
                                CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                OnClientClick="return confirm('Đặt lại mật khẩu về 123456 cho tài khoản này?');" />
                            <asp:Button runat="server" Text="Xoá" CssClass="nd-btn red" CommandName="Xoa"
                                CommandArgument='<%# Eval("MaNhanVien") %>' CausesValidation="false"
                                OnClientClick="return confirm('Bạn có chắc muốn xoá tài khoản này?');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
