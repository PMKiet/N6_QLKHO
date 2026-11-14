<%@ Page Title="Cảnh Báo Hạn Sử Dụng" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CanhBao.aspx.cs" Inherits="N6_QLKHO.CanhBao" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Thanh tiêu đề trang -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <div>
                    <h1 class="page-title mb-1">Cảnh Báo Hạn Sử Dụng</h1>
                    <p class="page-subtitle">Giám sát các lô hàng sắp hết hạn hoặc đã quá hạn sử dụng để ưu tiên xuất kho theo nguyên tắc FEFO</p>
                </div>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <a href="PhieuNhap.aspx" class="btn btn-outline-primary btn-icon fw-semibold px-3 py-2">
                    <i class="fa-solid fa-file-arrow-down"></i>
                    <span>Lập phiếu nhập lô</span>
                </a>
                <a href="HangHoa.aspx" class="btn btn-primary btn-icon fw-semibold px-3 py-2 shadow-sm">
                    <i class="fa-solid fa-box"></i>
                    <span>Quản lý hàng hóa</span>
                </a>
            </div>
        </div>

        <!-- 3 Thẻ KPI thống kê trạng thái hạn dùng -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-md-4">
                <div class="stat-card stat-danger">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Đã Hết Hạn</div>
                            <div class="stat-value text-danger">0</div>
                            <div class="stat-sub">
                                <span class="badge badge-soft-danger me-1"><i class="fa-solid fa-circle-xmark me-1"></i>Khẩn cấp</span>
                                Cần khoanh vùng &amp; xử lý hủy
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-calendar-xmark"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-md-4">
                <div class="stat-card stat-warning">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Sắp Hết Hạn (&lt; 30 Ngày)</div>
                            <div class="stat-value text-warning">0</div>
                            <div class="stat-sub">
                                <span class="badge badge-soft-warning me-1"><i class="fa-solid fa-clock me-1"></i>Ưu tiên FEFO</span>
                                Cần ưu tiên xuất kho trước
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-hourglass-half"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-md-4">
                <div class="stat-card stat-success">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Còn Hạn An Toàn</div>
                            <div class="stat-value text-success">100%</div>
                            <div class="stat-sub">
                                <span class="badge badge-soft-success me-1"><i class="fa-solid fa-shield-check me-1"></i>Ổn định</span>
                                Đạt tiêu chuẩn lưu kho
                            </div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-calendar-check"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bộ lọc cảnh báo -->
        <div class="filter-card p-4">
            <div class="row g-3 align-items-end">
                <div class="col-12 col-md-5 col-lg-4">
                    <label for="txtTimLo" class="form-label-wms">Từ khóa tìm kiếm</label>
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="txtTimLo" class="form-control" placeholder="Tìm theo mã hàng, tên hàng hoặc mã phiếu nhập..." />
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-md-4 col-lg-3">
                    <label for="selMucDoCanhBao" class="form-label-wms">Mức độ cảnh báo</label>
                    <select id="selMucDoCanhBao" class="form-select">
                        <option value="">Tất cả mức độ cảnh báo</option>
                        <option value="expired">Đã hết hạn sử dụng</option>
                        <option value="expiring30">Sắp hết hạn (dưới 30 ngày)</option>
                        <option value="expiring60">Cần theo dõi (30 - 60 ngày)</option>
                        <option value="safe">Còn hạn an toàn (&gt; 60 ngày)</option>
                    </select>
                </div>
                <div class="col-12 col-sm-6 col-md-3 col-lg-3">
                    <label for="selNhomHang" class="form-label-wms">Nhóm hàng hóa</label>
                    <select id="selNhomHang" class="form-select">
                        <option value="">Tất cả nhóm hàng</option>
                        <option value="fast">Hàng tiêu dùng nhanh (FMCG)</option>
                        <option value="material">Vật tư &amp; nguyên phụ liệu</option>
                        <option value="chemical">Hóa chất &amp; chế phẩm</option>
                    </select>
                </div>
                <div class="col-12 col-lg-2 d-grid">
                    <button type="button" class="btn btn-primary btn-search fw-semibold shadow-sm" onclick="window.location.href='LichSuKho.aspx';">
                        <i class="fa-solid fa-sliders me-1"></i> Tra cứu lô
                    </button>
                </div>
            </div>
        </div>

        <!-- Bảng danh sách lô hàng cảnh báo -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-bell"></i>
                    <span>Danh Sách Lô Hàng Cảnh Báo Hạn Dùng</span>
                </h2>
                <span class="badge badge-soft-success px-3 py-2 rounded-pill">
                    <i class="fa-solid fa-circle-check me-1"></i>Không phát sinh lô quá hạn
                </span>
            </div>

            <div class="table-responsive">
                <table class="table table-custom align-middle mb-0">
                    <thead>
                        <tr>
                            <th scope="col" class="col-nowrap">Mã Phiếu Nhập</th>
                            <th scope="col" class="col-nowrap">Mã Hàng</th>
                            <th scope="col">Tên Hàng Hóa</th>
                            <th scope="col" class="col-nowrap">ĐVT</th>
                            <th scope="col" class="text-end col-nowrap">Số Lượng Lô</th>
                            <th scope="col" class="text-center col-nowrap">Ngày Nhập</th>
                            <th scope="col" class="text-center col-nowrap">Hạn Sử Dụng Lô</th>
                            <th scope="col" class="text-center col-nowrap">Mức Cảnh Báo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="8" class="p-0 border-0">
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="fa-solid fa-shield-heart text-success"></i>
                                    </div>
                                    <h6 class="fw-bold text-dark mb-1">Hiện không có lô hàng nào sắp hết hạn hoặc quá hạn</h6>
                                    <p class="small text-muted mb-3">Tất cả các lô hàng trong kho đều đang nằm trong ngưỡng hạn sử dụng an toàn. Để kiểm tra chi tiết hạn dùng từng lô nhập, vui lòng xem tại Lịch Sử Giao Dịch Kho.</p>
                                    <div class="d-inline-flex flex-wrap justify-content-center gap-2">
                                        <a href="LichSuKho.aspx" class="btn btn-sm btn-outline-primary fw-semibold px-3">
                                            <i class="fa-solid fa-clock-rotate-left me-1"></i> Xem lịch sử lô nhập
                                        </a>
                                        <a href="PhieuXuat.aspx" class="btn btn-sm btn-primary fw-semibold px-3">
                                            <i class="fa-solid fa-file-arrow-up me-1"></i> Lập phiếu xuất kho
                                        </a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</asp:Content>
