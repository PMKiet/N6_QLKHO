<<<<<<< HEAD
﻿<%@ Page Title="Tổng quan hệ thống" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="N6_QLKHO.Dashboard" %>
=======
<%@ Page Title="Tổng quan hệ thống" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="N6_QLKHO.Dashboard" %>
>>>>>>> 2f494f6126390a3afe0f0cdd07a1230de99fe24d

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">
        <!-- Page Header -->
        <div class="wms-topbar d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-chart-pie"></i>
                </div>
                <div>
                    <h1 class="page-title">Tổng Quan Hệ Thống Kho</h1>
                    <p class="page-subtitle">Theo dõi chỉ số tồn kho, luồng nhập xuất và truy cập nhanh các phân hệ nghiệp vụ</p>
                </div>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <a href="PhieuNhap.aspx" class="btn btn-primary btn-icon fw-semibold shadow-sm">
                    <i class="fa-solid fa-file-import me-1"></i> Lập Phiếu Nhập
                </a>
                <a href="PhieuXuat.aspx" class="btn btn-success btn-icon fw-semibold shadow-sm">
                    <i class="fa-solid fa-file-export me-1"></i> Lập Phiếu Xuất
                </a>
                <a href="TonKho.aspx" class="btn btn-outline-secondary btn-icon fw-semibold">
                    <i class="fa-solid fa-boxes-stacked me-1"></i> Kiểm Kê Tồn Kho
                </a>
            </div>
        </div>

        <!-- 4 KPI Stat Cards -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3">
                <div class="stat-card stat-primary">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Tổng mặt hàng</div>
                            <div class="stat-value">1,250</div>
                            <div class="stat-sub text-primary fw-medium">
                                <i class="fa-solid fa-layer-group me-1"></i> Đang quản lý trong danh mục
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-box-open"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="stat-card stat-success">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Phiếu nhập tháng này</div>
                            <div class="stat-value">48</div>
                            <div class="stat-sub text-success fw-medium">
                                <i class="fa-solid fa-arrow-trend-up me-1"></i> +12.5% so với kỳ trước
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-cart-flatbed"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="stat-card stat-warning">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Phiếu xuất tháng này</div>
                            <div class="stat-value">115</div>
                            <div class="stat-sub text-warning fw-medium">
                                <i class="fa-solid fa-truck-fast me-1"></i> Đã hoàn tất giao nhận
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-truck-ramp-box"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="stat-card stat-danger">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Cảnh báo tồn kho</div>
                            <div class="stat-value">05</div>
                            <div class="stat-sub text-danger fw-medium">
                                <i class="fa-solid fa-triangle-exclamation me-1"></i> Chạm ngưỡng tối thiểu / cận hạn
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-bell"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Warehouse Movement Overview & Category Structure -->
        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="wms-card h-100 mb-0">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-chart-column"></i>
                            Biểu Đồ Luồng Nhập - Xuất Kho (6 Tháng Gần Nhất)
                        </h2>
                        <div class="d-flex align-items-center gap-3 small fw-semibold text-secondary">
                            <span class="d-inline-flex align-items-center gap-2">
                                <span class="dash-legend-dot dot-import"></span> Nhập kho
                            </span>
                            <span class="d-inline-flex align-items-center gap-2">
                                <span class="dash-legend-dot dot-export"></span> Xuất kho
                            </span>
                        </div>
                    </div>
                    <div class="p-4">
                        <div class="dash-chart-grid mb-3">
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h55" title="Nhập kho T1: 32 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h45" title="Xuất kho T1: 64 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 1</span>
                            </div>
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h68" title="Nhập kho T2: 38 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h62" title="Xuất kho T2: 79 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 2</span>
                            </div>
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h62" title="Nhập kho T3: 35 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h74" title="Xuất kho T3: 92 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 3</span>
                            </div>
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h78" title="Nhập kho T4: 42 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h68" title="Xuất kho T4: 85 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 4</span>
                            </div>
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h82" title="Nhập kho T5: 44 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h88" title="Xuất kho T5: 108 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 5</span>
                            </div>
                            <div class="dash-bar-col">
                                <div class="dash-bar-pair">
                                    <div class="dash-bar bar-import bar-h88" title="Nhập kho T6: 48 phiếu"></div>
                                    <div class="dash-bar bar-export bar-h94" title="Xuất kho T6: 115 phiếu"></div>
                                </div>
                                <span class="dash-bar-label">Tháng 6</span>
                            </div>
                        </div>

                        <div class="row g-3 pt-2">
                            <div class="col-sm-4">
                                <div class="p-3 rounded-3 bg-light border">
                                    <div class="text-secondary small fw-semibold">Tỷ lệ hoàn thành đơn</div>
                                    <div class="fs-5 fw-bold text-dark mt-1">98.4%</div>
                                    <div class="text-success small mt-1"><i class="fa-solid fa-circle-check me-1"></i>Đạt chuẩn SLA kho</div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="p-3 rounded-3 bg-light border">
                                    <div class="text-secondary small fw-semibold">Vòng quay hàng tồn</div>
                                    <div class="fs-5 fw-bold text-dark mt-1">4.2 lần/quý</div>
                                    <div class="text-primary small mt-1"><i class="fa-solid fa-rotate me-1"></i>Lưu chuyển ổn định</div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="p-3 rounded-3 bg-light border">
                                    <div class="text-secondary small fw-semibold">Sức chứa kho hiện tại</div>
                                    <div class="fs-5 fw-bold text-dark mt-1">76.5%</div>
                                    <div class="text-warning small mt-1"><i class="fa-solid fa-warehouse me-1"></i>Còn 23.5% dung lượng trống</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="wms-card h-100 mb-0">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-layer-group"></i>
                            Cơ Cấu Nhóm Hàng Tồn Kho
                        </h2>
                        <span class="badge badge-soft-primary">Theo tỷ trọng</span>
                    </div>
                    <div class="p-4">
                        <div class="mb-4">
                            <div class="d-flex justify-content-between small mb-2">
                                <span class="fw-semibold text-dark">Thực phẩm khô &amp; Đóng gói</span>
                                <span class="fw-bold text-primary">45%</span>
                            </div>
                            <div class="dash-progress-track">
                                <div class="dash-progress-fill fill-p45"></div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between small mb-2">
                                <span class="fw-semibold text-dark">Đồ uống &amp; Giải khát</span>
                                <span class="fw-bold text-success">30%</span>
                            </div>
                            <div class="dash-progress-track">
                                <div class="dash-progress-fill fill-p30"></div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between small mb-2">
                                <span class="fw-semibold text-dark">Hóa mỹ phẩm &amp; Gia dụng</span>
                                <span class="fw-bold text-warning">15%</span>
                            </div>
                            <div class="dash-progress-track">
                                <div class="dash-progress-fill fill-p15"></div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between small mb-2">
                                <span class="fw-semibold text-dark">Vật tư &amp; Phụ kiện khác</span>
                                <span class="fw-bold text-info">10%</span>
                            </div>
                            <div class="dash-progress-track">
                                <div class="dash-progress-fill fill-p10"></div>
                            </div>
                        </div>

                        <div class="p-3 rounded-3 bg-light border d-flex align-items-center justify-content-between">
                            <div>
                                <div class="fw-semibold text-dark small">Cảnh báo tồn kho &amp; hạn dùng</div>
                                <div class="text-secondary small">Kiểm tra ngay các lô hàng cần xử lý</div>
                            </div>
                            <a href="CanhBao.aspx" class="btn btn-sm btn-outline-primary fw-semibold">
                                Xem ngay <i class="fa-solid fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Operations Shortcuts -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-bolt"></i>
                    Lối Tắt Nghiệp Vụ Kho Hàng
                </h2>
                <span class="text-secondary small">Truy cập nhanh các phân hệ quản lý cốt lõi</span>
            </div>
            <div class="p-4">
                <div class="row g-3">
                    <div class="col-md-6 col-xl-4">
                        <a href="HangHoa.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-blue">
                                <i class="fa-solid fa-box-archive"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Quản Lý Hàng Hóa</div>
                                <div class="text-secondary small">Tra cứu, thêm mới và cập nhật thông tin sản phẩm</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>

                    <div class="col-md-6 col-xl-4">
                        <a href="PhieuNhap.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-green">
                                <i class="fa-solid fa-file-import"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Nghiệp Vụ Nhập Kho</div>
                                <div class="text-secondary small">Tạo phiếu nhập mới, theo dõi công nợ nhà cung cấp</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>

                    <div class="col-md-6 col-xl-4">
                        <a href="PhieuXuat.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-amber">
                                <i class="fa-solid fa-file-export"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Nghiệp Vụ Xuất Kho</div>
                                <div class="text-secondary small">Lập phiếu xuất hàng và đối soát số lượng thực xuất</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>

                    <div class="col-md-6 col-xl-4">
                        <a href="DonDatHang.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-purple">
                                <i class="fa-solid fa-clipboard-list"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Đơn Đặt Hàng (PO)</div>
                                <div class="text-secondary small">Quản lý đơn đặt hàng mua và trạng thái giao nhận</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>

                    <div class="col-md-6 col-xl-4">
                        <a href="LichSuKho.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-cyan">
                                <i class="fa-solid fa-clock-rotate-left"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Lịch Sử Giao Dịch Kho</div>
                                <div class="text-secondary small">Nhật ký chi tiết biến động nhập - xuất theo thời gian</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>

                    <div class="col-md-6 col-xl-4">
                        <a href="CanhBao.aspx" class="dash-quick-card">
                            <div class="dash-quick-icon icon-red">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <div class="flex-grow-1">
                                <div class="fw-bold">Cảnh Báo &amp; Hạn Sử Dụng</div>
                                <div class="text-secondary small">Theo dõi mặt hàng dưới định mức hoặc sắp hết hạn</div>
                            </div>
                            <i class="fa-solid fa-chevron-right text-secondary small"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
