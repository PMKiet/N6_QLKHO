<%@ Page Language="C#" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="N6_QLKHO.Login" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Nhập - Hệ Thống Quản Lý Kho Vật Tư (N6_QLKHO)</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --wms-primary: #2563eb;
            --wms-primary-dark: #1d4ed8;
            --wms-emerald: #10b981;
            --wms-slate-900: #0f172a;
            --wms-slate-800: #1e293b;
            --wms-slate-500: #64748b;
        }
        body {
            background: radial-gradient(circle at 15% 20%, #1e3a8a 0%, #0f172a 55%, #020617 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            padding: 24px 16px;
            position: relative;
            overflow-x: hidden;
        }
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background-image: radial-gradient(rgba(255, 255, 255, 0.06) 1px, transparent 1px);
            background-size: 28px 28px;
            pointer-events: none;
        }
        .login-wrapper {
            width: 100%;
            max-width: 960px;
            background: #ffffff;
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(2, 6, 23, 0.65);
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.12);
            position: relative;
            z-index: 1;
        }
        .brand-panel {
            background: linear-gradient(155deg, #0f172a 0%, #1e293b 60%, #1e3a8a 100%);
            color: #ffffff;
            padding: 44px 40px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
        }
        .brand-panel::after {
            content: "";
            position: absolute;
            width: 280px;
            height: 280px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(37, 99, 235, 0.32) 0%, transparent 70%);
            bottom: -90px;
            right: -80px;
            pointer-events: none;
        }
        .brand-logo-box {
            width: 54px;
            height: 54px;
            border-radius: 16px;
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #ffffff;
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.35);
        }
        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 14px;
            padding: 12px 14px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            margin-bottom: 12px;
        }
        .feature-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: rgba(59, 130, 246, 0.2);
            color: #60a5fa;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 0.95rem;
        }
        .form-panel {
            padding: 48px 44px;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .form-label-wms {
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #475569;
            margin-bottom: 8px;
        }
        .input-group-wms .input-group-text {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: #64748b;
            padding-left: 16px;
            padding-right: 14px;
            border-top-left-radius: 12px;
            border-bottom-left-radius: 12px;
        }
        .input-group-wms .form-control {
            background: #f8fafc;
            border-color: #cbd5e1;
            padding: 12px 14px;
            font-size: 0.95rem;
            color: #0f172a;
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }
        .input-group-wms .form-control.with-toggle {
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
            border-right: 0;
        }
        .input-group-wms .btn-toggle-pw {
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-left: 0;
            color: #64748b;
            padding: 0 16px;
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }
        .input-group-wms .btn-toggle-pw:hover {
            color: #0f172a;
        }
        .input-group-wms:focus-within .input-group-text,
        .input-group-wms:focus-within .form-control,
        .input-group-wms:focus-within .btn-toggle-pw {
            background: #ffffff;
            border-color: var(--wms-primary);
        }
        .input-group-wms:focus-within {
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.12);
            border-radius: 12px;
        }
        .form-control:focus {
            box-shadow: none;
        }
        .btn-login-submit {
            background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
            border: none;
            border-radius: 12px;
            padding: 13px 20px;
            font-size: 0.98rem;
            letter-spacing: 0.3px;
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .btn-login-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.45);
        }
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 5px 12px;
            border-radius: 999px;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.76rem;
            font-weight: 600;
            border: 1px solid #a7f3d0;
        }
        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
        }
        @media (max-width: 767.98px) {
            .form-panel {
                padding: 32px 24px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="w-100 d-flex justify-content-center">
        <div class="login-wrapper">
            <div class="row g-0">
                <!-- Cột trái: Nhận diện hệ thống ERP Kho Vật Tư -->
                <div class="col-lg-6 d-none d-lg-flex brand-panel">
                    <div>
                        <div class="d-flex align-items-center gap-3 mb-4">
                            <div class="brand-logo-box">
                                <i class="fa-solid fa-boxes-stacked"></i>
                            </div>
                            <div>
                                <div class="badge bg-primary bg-opacity-25 text-info border border-info border-opacity-25 mb-1">ERP WAREHOUSE</div>
                                <h5 class="fw-bold mb-0 text-white">N6_QLKHO</h5>
                            </div>
                        </div>

                        <h3 class="fw-bold mb-3 lh-sm">Hệ Thống Quản Lý<br />Kho Vật Tư Nội Bộ</h3>
                        <p class="text-white-50 small mb-4">
                            Nền tảng kiểm soát nhập - xuất - tồn kho theo lô và hạn sử dụng (FEFO), đồng bộ chứng từ theo thời gian thực.
                        </p>

                        <div class="feature-item">
                            <div class="feature-icon"><i class="fa-solid fa-file-arrow-down"></i></div>
                            <div>
                                <div class="fw-semibold small text-white">Lập Phiếu Nhập &amp; Xuất Chuẩn Hóa</div>
                                <div class="text-white-50" style="font-size: 0.78rem;">Kiểm tra đơn giá VND, xem trước và xuất chứng từ Mẫu 01-VT / 02-VT.</div>
                            </div>
                        </div>

                        <div class="feature-item mb-0">
                            <div class="feature-icon"><i class="fa-solid fa-shield-halved"></i></div>
                            <div>
                                <div class="fw-semibold small text-white">Kiểm Soát Tồn Kho Theo Lô (FEFO)</div>
                                <div class="text-white-50" style="font-size: 0.78rem;">Tự động ưu tiên xuất lô sắp hết hạn và cảnh báo số lượng khả dụng.</div>
                            </div>
                        </div>
                    </div>

                    <div class="pt-4 border-top border-secondary border-opacity-25 d-flex justify-content-between align-items-center small text-white-50">
                        <span><i class="fa-solid fa-building-user me-1"></i> Bộ phận Kho vận &amp; Cung ứng</span>
                        <span>Phiên bản 2.0</span>
                    </div>
                </div>

                <!-- Cột phải: Khung đăng nhập -->
                <div class="col-12 col-lg-6 form-panel">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="d-flex align-items-center gap-2 d-lg-none">
                            <i class="fa-solid fa-boxes-stacked fs-4 text-primary"></i>
                            <span class="fw-bold text-dark">N6_QLKHO</span>
                        </div>
                        <span class="status-pill">
                            <span class="status-dot"></span>
                            Hệ thống sẵn sàng
                        </span>
                    </div>

                    <div class="mb-4">
                        <h3 class="fw-bold text-dark mb-1">Đăng nhập hệ thống</h3>
                        <p class="text-muted small mb-0">Nhập thông tin tài khoản nhân viên hoặc quản trị viên để tiếp tục.</p>
                    </div>

                    <!-- Thông báo lỗi từ Server -->
                    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

                    <div class="mb-3">
                        <label class="form-label-wms" for="<%= txtTenDangNhap.ClientID %>">Tên Đăng Nhập</label>
                        <div class="input-group input-group-wms">
                            <span class="input-group-text"><i class="fa-regular fa-user"></i></span>
                            <asp:TextBox ID="txtTenDangNhap" runat="server" CssClass="form-control" Placeholder="Nhập mã hoặc tên tài khoản..."></asp:TextBox>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <label class="form-label-wms" for="<%= txtMatKhau.ClientID %>">Mật Khẩu</label>
                        </div>
                        <div class="input-group input-group-wms">
                            <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                            <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control with-toggle" TextMode="Password" Placeholder="Nhập mật khẩu..."></asp:TextBox>
                            <button type="button" class="btn btn-toggle-pw" onclick="batTatMatKhau(this)" title="Hiện / ẩn mật khẩu" tabindex="-1">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="d-grid mb-4">
                        <asp:Button ID="btnLogin" runat="server" Text="Đăng Nhập Hệ Thống →" CssClass="btn btn-primary btn-login-submit fw-bold text-white shadow-sm" OnClick="btnLogin_Click" />
                    </div>

                    <div class="text-center pt-3 border-top">
                        <span class="text-muted small"><i class="fa-solid fa-lock me-1 text-secondary"></i>Hệ thống quản lý nội bộ <strong>N6_QLKHO</strong> &bull; Bảo mật phiên làm việc</span>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src='<%= ResolveUrl("~/Scripts/bootstrap.bundle.min.js") %>'></script>
    <script>
        function batTatMatKhau(btn) {
            var txt = document.getElementById('<%= txtMatKhau.ClientID %>');
            if (!txt) return;
            var icon = btn.querySelector('i');
            if (txt.type === 'password') {
                txt.type = 'text';
                if (icon) { icon.className = 'fa-regular fa-eye-slash'; }
            } else {
                txt.type = 'password';
                if (icon) { icon.className = 'fa-regular fa-eye'; }
            }
        }
    </script>
</body>
</html>
