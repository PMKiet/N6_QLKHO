<<<<<<< HEAD
﻿<%@ Page Title="Quản Lý Tồn Kho Theo Lô" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TonKho.aspx.cs" Inherits="N6_QLKHO.TonKho" %>
=======
<%@ Page Title="Quản Lý Tồn Kho Theo Lô" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TonKho.aspx.cs" Inherits="N6_QLKHO.TonKho" %>
>>>>>>> 2f494f6126390a3afe0f0cdd07a1230de99fe24d

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- THANH TIÊU ĐỀ TRANG & NÚT ĐIỀU HƯỚNG NHANH -->
        <div class="wms-topbar d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-warehouse"></i>
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h4 class="page-title mb-0">Quản Lý Tồn Kho Theo Lô</h4>
                        <span class="badge badge-soft-primary">Kiểm soát FEFO</span>
                    </div>
                    <p class="page-subtitle mt-1">Theo dõi số lượng tồn khả dụng theo từng lô hạn sử dụng, tự động ưu tiên xuất lô hết hạn trước (FEFO).</p>
                </div>
            </div>
            <div class="d-flex flex-wrap align-items-center gap-2">
                <a href="LichSuKho.aspx" class="btn btn-outline-secondary btn-icon px-3 py-2 fw-semibold">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>Lịch Sử Kho</span>
                </a>
                <a href="PhieuXuat.aspx" class="btn btn-outline-primary btn-icon px-3 py-2 fw-semibold">
                    <i class="fa-solid fa-file-arrow-up"></i>
                    <span>Lập Phiếu Xuất</span>
                </a>
                <a href="PhieuNhap.aspx" class="btn btn-primary btn-icon px-4 py-2 fw-semibold shadow-sm">
                    <i class="fa-solid fa-file-arrow-down"></i>
                    <span>Lập Phiếu Nhập Lô Mới</span>
                </a>
            </div>
        </div>

        <!-- 4 THẺ KPI TỔNG QUAN TỒN KHO -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card stat-primary">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Cơ chế quản lý lô</div>
                            <div class="stat-value">FEFO</div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-layer-group"></i>
                        </div>
                    </div>
                    <div class="stat-sub">
                        <i class="fa-solid fa-circle-check text-primary me-1"></i>Tách lô tự động theo hạn dùng
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card stat-success">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Lô Còn Hạn An Toàn</div>
                            <div class="stat-value">Sẵn sàng</div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-shield-check"></i>
                        </div>
                    </div>
                    <div class="stat-sub">
                        <i class="fa-solid fa-boxes-stacked text-success me-1"></i>Đủ điều kiện xuất kho tự động
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card stat-warning">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Ngưỡng Cảnh Báo Hạn</div>
                            <div class="stat-value">&le; 30 ngày</div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-clock"></i>
                        </div>
                    </div>
                    <div class="stat-sub">
                        <a href="CanhBao.aspx" class="text-decoration-none fw-semibold text-warning">
                            <i class="fa-solid fa-arrow-up-right-from-square me-1"></i>Xem trang Cảnh báo hạn
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card stat-danger">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-label">Chặn Xuất Hàng Quá Hạn</div>
                            <div class="stat-value">Bật 100%</div>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-ban"></i>
                        </div>
                    </div>
                    <div class="stat-sub">
                        <i class="fa-solid fa-lock text-danger me-1"></i>Không tính vào tồn khả dụng
                    </div>
                </div>
            </div>
        </div>

        <!-- KHUNG BỘ LỌC & TÌM KIẾM LÔ TỒN KHO -->
        <div class="wms-card filter-card">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-filter"></i>
                    <span>Bộ Lọc Tra Cứu Lô Hàng Tồn Kho</span>
                </h5>
                <span class="text-muted small">Tra cứu nhanh theo mã SKU, tên vật tư hoặc tình trạng hạn dùng</span>
            </div>
            <div class="card-body p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-5">
                        <label class="form-label-wms">Tìm kiếm mặt hàng / mã SKU</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                            <input type="text" id="txtFilterTonKho" class="form-control border-start-0 ps-0" placeholder="Nhập mã hàng hóa (VD: HH01) hoặc tên vật tư..." />
                        </div>
                    </div>
                    <div class="col-12 col-md-4">
                        <label class="form-label-wms">Trạng thái lô hạn dùng</label>
                        <select id="ddlTrangThaiLo" class="form-select">
                            <option value="">-- Tất cả trạng thái lô --</option>
                            <option value="safe">Còn hạn an toàn (&gt; 30 ngày)</option>
                            <option value="warning">Sắp hết hạn (&le; 30 ngày)</option>
                            <option value="expired">Đã hết hạn sử dụng</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-3 d-flex align-items-end gap-2">
                        <button type="button" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm" onclick="document.getElementById('txtFilterTonKho').focus();">
                            <i class="fa-solid fa-magnifying-glass me-1"></i> Lọc dữ liệu
                        </button>
                        <button type="button" class="btn btn-outline-secondary py-2 px-3 fw-semibold" onclick="document.getElementById('txtFilterTonKho').value=''; document.getElementById('ddlTrangThaiLo').selectedIndex=0;" title="Đặt lại bộ lọc">
                            Làm mới
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG HIỂN THỊ DANH SÁCH LÔ TỒN KHO -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h5 class="section-title">
                    <i class="fa-solid fa-boxes-packing"></i>
                    <span>Bảng Chi Tiết Lô Tồn Kho Hiện Hành</span>
                </h5>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge badge-soft-success"><i class="fa-solid fa-circle-dot me-1"></i>Đồng bộ tự động từ Phiếu Nhập / Xuất</span>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom table-hover mb-0 align-middle">
                        <thead>
                            <tr>
                                <th class="text-center col-nowrap">STT</th>
                                <th class="col-nowrap">Mã Hàng</th>
                                <th>Tên Hàng Hóa &amp; Vật Tư</th>
                                <th class="text-center col-nowrap">Hạn Sử Dụng Lô</th>
                                <th class="text-end col-nowrap">Số Lượng Tồn</th>
                                <th class="text-center col-nowrap">Trạng Thái Lô</th>
                                <th class="text-center col-nowrap">Thao Tác Nhanh</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td colspan="7" class="p-0 border-0">
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fa-solid fa-warehouse"></i>
                                        </div>
                                        <div class="fw-semibold text-dark mb-1">Tra cứu và điều phối tồn kho theo từng lô hạn dùng</div>
                                        <p class="small text-muted mb-3">
                                            Số lượng tồn kho theo lô được cộng tự động khi lập <strong>Phiếu Nhập Kho</strong> và trừ tự động theo nguyên tắc FEFO khi lập <strong>Phiếu Xuất Kho</strong>.
                                        </p>
                                        <div class="d-flex flex-wrap justify-content-center gap-2">
                                            <a href="PhieuNhap.aspx" class="btn btn-primary btn-sm px-3 fw-semibold shadow-sm">
                                                <i class="fa-solid fa-plus me-1"></i> Nhập lô hàng mới
                                            </a>
                                            <a href="HangHoa.aspx" class="btn btn-outline-secondary btn-sm px-3 fw-semibold">
                                                <i class="fa-solid fa-box me-1"></i> Xem danh mục hàng hóa
                                            </a>
                                            <a href="CanhBao.aspx" class="btn btn-outline-warning btn-sm px-3 fw-semibold">
                                                <i class="fa-solid fa-triangle-exclamation me-1"></i> Kiểm tra cảnh báo hạn dùng
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

    </div>
</asp:Content>
