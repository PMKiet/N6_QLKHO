<%@ Page Title="Trang Chủ Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="N6_QLKHO.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Bạn có thể thêm CSS riêng cho Dashboard tại đây nếu cần -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Tiêu đề trang & Breadcrumb -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Tổng Quan Hệ Thống Kho</h3>
            <p class="text-muted small mb-0">Chào mừng bạn trở lại, theo dõi số liệu nhập xuất và tồn kho hôm nay.</p>
        </div>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Trang chủ</a></li>
                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
            </ol>
        </nav>
    </div>

    <!-- HÀNG 1: CÁC THẺ THỐNG KÊ (CARDS) -->
    <div class="row g-3 mb-4">
        <!-- Tổng số mặt hàng -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm text-white" style="background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50 small text-uppercase fw-bold">Tổng Mặt Hàng</h6>
                            <h3 class="fw-bold mb-1">1,248</h3>
                            <p class="mb-0 small text-white-50"><i class="fa-solid fa-box"></i> Trong danh mục kho</p>
                        </div>
                        <div class="fs-1 text-white-50">
                            <i class="fa-solid fa-boxes-stacked"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Phiếu Nhập / Xuất trong ngày -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm text-white" style="background: linear-gradient(135deg, #10b981 0%, #047857 100%);">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50 small text-uppercase fw-bold">Phiếu Nhập Hôm Nay</h6>
                            <h3 class="fw-bold mb-1">24</h3>
                            <p class="mb-0 small text-white-50"><i class="fa-solid fa-file-arrow-down"></i> Đã hoàn tất</p>
                        </div>
                        <div class="fs-1 text-white-50">
                            <i class="fa-solid fa-truck-ramp-box"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Đơn đặt hàng từ khách -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm text-dark" style="background: linear-gradient(135deg, #facc15 0%, #ca8a04 100%);">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-dark-50 small text-uppercase fw-bold">Đơn Đặt Hàng</h6>
                            <h3 class="fw-bold mb-1">12</h3>
                            <p class="mb-0 small text-dark-50"><i class="fa-solid fa-cart-shopping"></i> Đang chờ xử lý xuất</p>
                        </div>
                        <div class="fs-1 text-dark-50">
                            <i class="fa-solid fa-clipboard-list"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cảnh báo hạn sử dụng -->
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm text-white" style="background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%);">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50 small text-uppercase fw-bold">Cảnh Báo Hết Hạn</h6>
                            <h3 class="fw-bold mb-1">5 Lô</h3>
                            <p class="mb-0 small text-white-50"><i class="fa-solid fa-triangle-exclamation"></i> Cần kiểm tra gấp</p>
                        </div>
                        <div class="fs-1 text-white-50">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- HÀNG 2: KHU VỰC THỐNG KÊ CHI TIẾT & BẢNG NHẬP/XUẤT -->
    <div class="row g-4">
        <!-- Biểu đồ / Thống kê biến động kho -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="card-title fw-bold text-primary mb-0">Biểu Đồ Biến Động Nhập - Xuất Kho</h5>
                        <span class="badge bg-light text-dark border">7 ngày gần nhất</span>
                    </div>
                    <div class="p-5 text-center text-muted bg-light rounded d-flex flex-column align-items-center justify-content-center" style="min-height: 300px;">
                        <i class="fa-solid fa-chart-line fs-1 mb-2 text-primary"></i>
                        <p class="mb-0">Khu vực hiển thị biểu đồ phân tích số lượng vật tư / dược phẩm nhập và xuất kho theo thời gian.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tình trạng / Tỷ lệ kho hàng -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title fw-bold text-primary mb-3">Tỷ Lệ Nhóm Hàng Tồn</h5>
                    <div class="p-5 text-center text-muted bg-light rounded d-flex flex-column align-items-center justify-content-center" style="min-height: 300px;">
                        <i class="fa-solid fa-chart-pie fs-1 mb-2 text-success"></i>
                        <p class="mb-0">Biểu đồ tỷ lệ phân bố các loại hàng hóa trong kho.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>