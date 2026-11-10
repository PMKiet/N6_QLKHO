<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="N6_QLKHO.Login" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Nhập - Hệ Thống Quản Lý Kho</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        body {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            width: 100%;
            max-width: 420px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .login-header {
            background: #0f172a;
            color: white;
            padding: 30px 20px;
            text-align: center;
        }
        .form-control:focus {
            box-shadow: none;
            border-color: #2563eb;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="w-100 px-3">
        <div class="d-flex justify-content-center">
            <div class="login-card">
                <div class="login-header">
                    <div class="mb-2">
                        <i class="fa-solid fa-boxes-stacked fs-1 text-primary"></i>
                    </div>
                    <h4 class="fw-bold mb-1">QUẢN LÝ KHO VẬT TƯ</h4>
                    <p class="text-muted small mb-0">Vui lòng đăng nhập để tiếp tục hệ thống</p>
                </div>
                
                <div class="p-4">
                    <!-- Thông báo lỗi -->
                    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">Tên Đăng Nhập</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-solid fa-user"></i></span>
                            <asp:TextBox ID="txtTenDangNhap" runat="server" CssClass="form-control border-start-0 ps-0 bg-light" Placeholder="Nhập tên đăng nhập..."></asp:TextBox>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold small text-secondary">Mật Khẩu</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-solid fa-lock"></i></span>
                            <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control border-start-0 ps-0 bg-light" TextMode="Password" Placeholder="Nhập mật khẩu..."></asp:TextBox>
                        </div>
                    </div>

                    <div class="d-grid">
                        <asp:Button ID="btnLogin" runat="server" Text="Đăng Nhập" CssClass="py-2 btn btn-primary fw-semibold shadow-sm" OnClick="btnLogin_Click" />
                    </div>
                </div>

                <div class="card-footer bg-light text-center py-3 border-0">
                    <span class="text-muted small">Hệ thống quản lý nội bộ N6-QLKHO</span>
                </div>
            </div>
        </div>
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src='<%= ResolveUrl("~/Scripts/bootstrap.bundle.min.js") %>'></script>
</body>
</html>