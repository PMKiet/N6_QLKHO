<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="N6_QLKHO.Login" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Nhập - Hệ Thống Quản Lý Kho</title>
    <!-- Sử dụng file Bootstrap CSS cục bộ trong dự án -->
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --primary-color: #4f46e5;
            --primary-hover: #4338ca;
        }
        body {
            background-color: #f8fafc;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
        }
        .login-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04), 0 1px 3px rgba(0, 0, 0, 0.02);
            width: 100%;
            max-width: 420px;
            border: 1px solid #e2e8f0;
        }
        .form-control {
            padding: 0.7rem 1rem;
            font-size: 0.95rem;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
        }
        .form-control:focus {
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.12);
            border-color: var(--primary-color);
        }
        .input-group-text {
            background: transparent;
            border-right: none;
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
            color: #94a3b8;
            padding-left: 1rem;
        }
        .form-control.border-start-0 {
            border-left: none;
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
        }
        .btn-primary {
            background-color: var(--primary-color);
            border: none;
            border-radius: 10px;
            padding: 0.75rem;
            font-weight: 600;
            transition: all 0.2s ease;
        }
        .btn-primary:hover {
            background-color: var(--primary-hover);
            transform: translateY(-1px);
        }
        .brand-icon {
            width: 56px;
            height: 56px;
            background-color: #e0e7ff;
            color: var(--primary-color);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 16px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="w-100 px-3">
        <div class="d-flex justify-content-center">
            <div class="login-card p-4 p-md-5">
                
                <!-- Logo & Tiêu đề -->
                <div class="text-center mb-4">
                    <div class="brand-icon mb-3 shadow-sm">
                        <i class="fa-solid fa-boxes-stacked fs-4"></i>
                    </div>
                    <h4 class="fw-bold text-dark mb-1">Quản Lý Kho</h4>
                    <p class="text-muted small">Đăng nhập vào hệ thống quản trị nội bộ</p>
                </div>
                
                <!-- Thông báo lỗi -->
                <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-secondary">Tên Đăng Nhập</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-user"></i></span>
                        <asp:TextBox ID="txtTenDangNhap" runat="server" CssClass="form-control border-start-0 ps-0" Placeholder="Nhập tài khoản..."></asp:TextBox>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-semibold text-secondary">Mật Khẩu</label>
                    <div class="input-group">
                        <!-- Đã đổi sang icon chìa khóa fa-solid fa-key -->
                        <span class="input-group-text"><i class="fa-solid fa-key"></i></span>
                        <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control border-start-0 ps-0" TextMode="Password" Placeholder="Nhập mật khẩu..."></asp:TextBox>
                    </div>
                </div>

                <div class="d-grid mb-4">
                    <asp:Button ID="btnLogin" runat="server" Text="Đăng Nhập" CssClass="btn btn-primary shadow-sm" OnClick="btnLogin_Click" />
                </div>

                <div class="text-center border-top pt-3">
                    <span class="text-muted" style="font-size: 0.8rem;">Hệ thống nội bộ N6-QLKHOVATTU</span>
                </div>
            </div>
        </div>
    </form>

    <!-- Sử dụng file Bootstrap JS cục bộ trong dự án -->
    <script src='<%= ResolveUrl("~/Scripts/bootstrap.bundle.min.js") %>'></script>
</body>
</html>
