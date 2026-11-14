<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="N6_QLKHO.Login" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng nhập hệ thống - Quản Lý Kho N6</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="~/assets/css/main.css" rel="stylesheet" />
    <link href="~/assets/css/components.css" rel="stylesheet" />
    <link href="~/assets/css/responsive.css" rel="stylesheet" />
    <link href="~/Content/site.css" rel="stylesheet" />
</head>
<body class="login-page">
    <form id="form1" runat="server" class="w-100 d-flex justify-content-center">
        <div class="login-wrapper">
            <div class="row g-0">
                <!-- Left Branding Panel -->
                <div class="col-lg-6 brand-panel d-none d-lg-flex">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="brand-logo-box">
                                    <i class="fa-solid fa-boxes-stacked"></i>
                                </div>
                                <div>
                                    <h5 class="mb-0 fw-bold">N6 WMS</h5>
                                    <small class="text-white-50">Warehouse Management</small>
                                </div>
                            </div>
                            <span class="status-pill">
                                <span class="status-dot"></span> Hệ thống sẵn sàng
                            </span>
                        </div>

                        <h3 class="fw-bold mb-3 mt-2">Hệ Thống Quản Lý Kho Hàng Tập Trung</h3>
                        <p class="text-white-50 mb-4 brand-subtitle">
                            Nền tảng vận hành kho thông minh giúp kiểm soát chính xác luồng nhập - xuất - tồn kho và cảnh báo hạn mức theo thời gian thực.
                        </p>

                        <div class="mt-2">
                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fa-solid fa-dolly"></i>
                                </div>
                                <div>
                                    <div class="fw-semibold small text-white">Điều phối Nhập - Xuất chính xác</div>
                                    <div class="text-white-50 small">Tự động đối chiếu chứng từ, công nợ và cập nhật số lượng tồn kho tức thì.</div>
                                </div>
                            </div>
                            <div class="feature-item">
                                <div class="feature-icon">
                                    <i class="fa-solid fa-bell"></i>
                                </div>
                                <div>
                                    <div class="fw-semibold small text-white">Cảnh báo tồn kho &amp; hạn sử dụng</div>
                                    <div class="text-white-50 small">Phát hiện sớm mặt hàng chạm ngưỡng tối thiểu hoặc sắp hết hạn sử dụng.</div>
                                </div>
                            </div>
                            <div class="feature-item mb-0">
                                <div class="feature-icon">
                                    <i class="fa-solid fa-shield-halved"></i>
                                </div>
                                <div>
                                    <div class="fw-semibold small text-white">Phân quyền &amp; nhật ký minh bạch</div>
                                    <div class="text-white-50 small">Lưu vết chi tiết lịch sử giao dịch theo từng tài khoản và vai trò nghiệp vụ.</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="pt-4 mt-4 d-flex justify-content-between align-items-center text-white-50 small brand-panel-footer">
                        <span>&copy; <%: DateTime.Now.Year %> Nhóm 6 - QLKHO</span>
                        <span>Phiên bản Enterprise 2.0</span>
                    </div>
                </div>

                <!-- Right Login Form Panel -->
                <div class="col-lg-6 form-panel d-flex flex-column justify-content-center">
                    <div class="d-flex d-lg-none align-items-center gap-3 mb-4">
                        <div class="brand-logo-box">
                            <i class="fa-solid fa-boxes-stacked"></i>
                        </div>
                        <div>
                            <h5 class="mb-0 fw-bold text-dark">QUẢN LÝ KHO N6</h5>
                            <small class="text-muted">Hệ thống quản trị kho hàng</small>
                        </div>
                    </div>

                    <div class="mb-4">
                        <span class="badge bg-primary bg-opacity-10 text-primary fw-semibold px-3 py-2 rounded-pill mb-2">
                            <i class="fa-solid fa-lock me-1"></i> Cổng xác thực nội bộ
                        </span>
                        <h3 class="fw-bold text-dark mb-1 form-panel-title">Đăng nhập tài khoản</h3>
                        <p class="text-secondary small mb-0">Vui lòng nhập thông tin tài khoản được cấp để truy cập hệ thống.</p>
                    </div>

                    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block mb-3" EnableViewState="false"></asp:Label>

                    <div class="mb-3">
                        <label class="form-label-wms" for="<%= txtTenDangNhap.ClientID %>">Tên đăng nhập</label>
                        <div class="input-group input-group-wms">
                            <span class="input-group-text"><i class="fa-regular fa-user"></i></span>
                            <asp:TextBox ID="txtTenDangNhap" runat="server" CssClass="form-control" placeholder="Nhập tài khoản của bạn..." autocomplete="username"></asp:TextBox>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <label class="form-label-wms" for="<%= txtMatKhau.ClientID %>">Mật khẩu</label>
                        </div>
                        <div class="input-group input-group-wms">
                            <span class="input-group-text"><i class="fa-solid fa-key"></i></span>
                            <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control with-toggle" TextMode="Password" placeholder="Nhập mật khẩu..." autocomplete="current-password"></asp:TextBox>
                            <button type="button" class="btn btn-toggle-pw" onclick="batTatMatKhau(this)" title="Hiện/Ẩn mật khẩu">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="d-grid mb-4">
                        <asp:Button ID="btnLogin" runat="server" Text="ĐĂNG NHẬP HỆ THỐNG" CssClass="btn btn-primary btn-login-submit text-white" OnClick="btnLogin_Click" />
                    </div>

                    <div class="p-3 rounded-3 d-flex align-items-center gap-3 login-help-box">
                        <div class="login-help-icon">
                            <i class="fa-solid fa-headset"></i>
                        </div>
                        <div class="small text-secondary">
                            Cần cấp quyền hoặc đặt lại mật khẩu? Vui lòng liên hệ <strong class="text-dark">Quản trị viên hệ thống (Admin)</strong>.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src='<%= ResolveUrl("~/Scripts/bootstrap.bundle.min.js") %>'></script>
    <script>
        function batTatMatKhau(btn) {
            var input = document.getElementById('<%= txtMatKhau.ClientID %>');
            var icon = btn.querySelector('i');
            if (!input) return;
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fa-regular fa-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'fa-regular fa-eye';
            }
        }
    </script>
</body>
</html>
