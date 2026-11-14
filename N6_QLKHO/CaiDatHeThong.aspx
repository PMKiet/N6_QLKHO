<<<<<<< HEAD
﻿<%@ Page Title="Cài Đặt Hệ Thống" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CaiDatHeThong.aspx.cs" Inherits="N6_QLKHO.CaiDatHeThong" %>
=======
<%@ Page Title="Cài Đặt Hệ Thống" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CaiDatHeThong.aspx.cs" Inherits="N6_QLKHO.CaiDatHeThong" %>
>>>>>>> 2f494f6126390a3afe0f0cdd07a1230de99fe24d
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Khung chứa thông báo (toast) -->
        <div id="khungThongBaoCaiDat" class="toast-container position-fixed top-0 end-0 p-3 toast-container-wms"></div>

        <!-- Thanh tiêu đề trang -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-sliders"></i>
                </div>
                <div>
                    <h1 class="page-title mb-1">Cài Đặt Hệ Thống</h1>
                    <p class="page-subtitle">Thiết lập thông tin đơn vị kho vận, quy tắc đánh mã chứng từ, ngưỡng cảnh báo và thông số vận hành</p>
                </div>
            </div>
            <div class="d-flex flex-wrap gap-2">
                <a href="QuanLyTaiKhoan.aspx" class="btn btn-outline-secondary btn-icon fw-semibold px-3 py-2">
                    <i class="fa-solid fa-users-gear"></i>
                    <span>Quản lý tài khoản</span>
                </a>
                <button type="button" class="btn btn-primary btn-icon fw-semibold px-3 py-2 shadow-sm" onclick="luuCaiDatDemo()">
                    <i class="fa-solid fa-floppy-disk"></i>
                    <span>Lưu cấu hình</span>
                </button>
            </div>
        </div>

        <div class="row g-4">
            <!-- CỘT TRÁI: THÔNG TIN ĐƠN VỊ & QUY TẮC VẬN HÀNH KHO -->
            <div class="col-12 col-xl-7">

                <!-- Card 1: Thông tin đơn vị & kho hàng -->
                <div class="wms-card">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-building-shield"></i>
                            <span>Thông Tin Đơn Vị &amp; Kho Hàng</span>
                        </h2>
                        <span class="badge badge-soft-primary px-3 py-1 rounded-pill">Hiển thị trên phiếu in</span>
                    </div>
                    <div class="p-4">
                        <div class="row g-3">
                            <div class="col-12 col-md-8">
                                <label for="cfgTenDonVi" class="form-label-wms">Tên hệ thống / Đơn vị chủ quản</label>
                                <input type="text" id="cfgTenDonVi" class="form-control" value="HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHO)" />
                            </div>
                            <div class="col-12 col-md-4">
                                <label for="cfgMaKho" class="form-label-wms">Mã kho trung tâm</label>
                                <input type="text" id="cfgMaKho" class="form-control readonly-user" value="KHO-TT-N6" readonly="readonly" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="cfgBoPhan" class="form-label-wms">Bộ phận phụ trách</label>
                                <input type="text" id="cfgBoPhan" class="form-control" value="Bộ phận Kho vận &amp; Cung ứng vật tư" />
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="cfgHotline" class="form-label-wms">Số điện thoại liên hệ</label>
                                <input type="text" id="cfgHotline" class="form-control" value="0939 686 868" />
                            </div>
                            <div class="col-12">
                                <label for="cfgDiaChiKho" class="form-label-wms">Địa chỉ kho lưu trữ</label>
                                <input type="text" id="cfgDiaChiKho" class="form-control" value="Khu Công Nghiệp &amp; Kho Vận N6, TP. Cần Thơ" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Cấu hình quy tắc mã chứng từ & cảnh báo -->
                <div class="wms-card mb-0">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-gears"></i>
                            <span>Quy Tắc Chứng Từ &amp; Ngưỡng Cảnh Báo</span>
                        </h2>
                        <span class="badge badge-soft-info px-3 py-1 rounded-pill">Chuẩn nghiệp vụ WMS</span>
                    </div>
                    <div class="p-4">
                        <div class="row g-3">
                            <div class="col-6 col-md-4">
                                <label for="cfgPrefixPN" class="form-label-wms">Tiền tố Phiếu Nhập</label>
                                <div class="input-group">
                                    <span class="input-group-text">Mã</span>
                                    <input type="text" id="cfgPrefixPN" class="form-control fw-semibold" value="PN" />
                                </div>
                            </div>
                            <div class="col-6 col-md-4">
                                <label for="cfgPrefixPX" class="form-label-wms">Tiền tố Phiếu Xuất</label>
                                <div class="input-group">
                                    <span class="input-group-text">Mã</span>
                                    <input type="text" id="cfgPrefixPX" class="form-control fw-semibold" value="PX" />
                                </div>
                            </div>
                            <div class="col-12 col-md-4">
                                <label for="cfgPrefixDH" class="form-label-wms">Tiền tố Đơn Hàng</label>
                                <div class="input-group">
                                    <span class="input-group-text">Mã</span>
                                    <input type="text" id="cfgPrefixDH" class="form-control fw-semibold" value="DH" />
                                </div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="cfgNguongTonToiThieu" class="form-label-wms">Ngưỡng cảnh báo tồn kho thấp</label>
                                <div class="input-group">
                                    <input type="number" id="cfgNguongTonToiThieu" class="form-control" value="10" min="1" />
                                    <span class="input-group-text">Đơn vị</span>
                                </div>
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="cfgCanhBaoHanDung" class="form-label-wms">Cảnh báo trước khi hết hạn</label>
                                <div class="input-group">
                                    <input type="number" id="cfgCanhBaoHanDung" class="form-control" value="30" min="1" />
                                    <span class="input-group-text">Ngày</span>
                                </div>
                            </div>

                            <div class="col-12 pt-2">
                                <div class="bg-light border rounded-3 p-3 d-flex flex-column gap-2">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" id="swChongAmKho" checked="checked" />
                                        <label class="form-check-label fw-semibold text-dark" for="swChongAmKho">
                                            Chặn xuất kho vượt quá tồn thực tế (Chống âm kho tự động)
                                        </label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" id="swAutoUpdateOrder" checked="checked" />
                                        <label class="form-check-label fw-semibold text-dark" for="swAutoUpdateOrder">
                                            Tự động chuyển trạng thái Đơn Đặt Hàng sang "Đã xuất kho" khi lập Phiếu Xuất
                                        </label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" id="swPrintA4" checked="checked" />
                                        <label class="form-check-label fw-semibold text-dark" for="swPrintA4">
                                            Định dạng in chứng từ khổ A4 chuẩn Mẫu 01-VT / 02-VT và hỗ trợ xuất Excel / Word
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- CỘT PHẢI: THÔNG TIN PHIÊN BẢN & TRẠNG THÁI HỆ THỐNG -->
            <div class="col-12 col-xl-5">

                <!-- Card 3: Thông tin phiên bản & môi trường -->
                <div class="wms-card">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-server"></i>
                            <span>Thông Tin Phiên Bản &amp; Cơ Sở Dữ Liệu</span>
                        </h2>
                        <span class="badge badge-soft-success px-3 py-1 rounded-pill">
                            <i class="fa-solid fa-circle-check me-1"></i>Đang hoạt động
                        </span>
                    </div>
                    <div class="p-4">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-secondary small fw-semibold text-uppercase">Tên phân hệ</span>
                                <span class="fw-bold text-dark">N6_QLKHO Enterprise WMS</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-secondary small fw-semibold text-uppercase">Phiên bản giao diện</span>
                                <span class="badge badge-soft-primary px-3 py-1">v2.4 PRO (Bootstrap 5.3.8)</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-secondary small fw-semibold text-uppercase">Nền tảng máy chủ</span>
                                <span class="fw-semibold text-dark">ASP.NET WebForms (.NET 4.7.2)</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-secondary small fw-semibold text-uppercase">Cơ sở dữ liệu</span>
                                <span class="sku-badge">SQL Server (N6_QLKHOVATTU)</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-secondary small fw-semibold text-uppercase">Cơ chế bảo mật mật khẩu</span>
                                <span class="fw-semibold text-success"><i class="fa-solid fa-lock me-1"></i>Mã hóa MD5 + Ràng buộc Admin</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Card 4: Lối tắt quản trị nhanh -->
                <div class="wms-card mb-0">
                    <div class="wms-card-header">
                        <h2 class="section-title">
                            <i class="fa-solid fa-bolt"></i>
                            <span>Lối Tắt Quản Trị Hệ Thống</span>
                        </h2>
                    </div>
                    <div class="p-4">
                        <div class="d-grid gap-2">
                            <a href="QuanLyTaiKhoan.aspx" class="btn btn-light border text-start p-3 d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-3">
                                    <span class="badge badge-soft-primary p-2 rounded-3"><i class="fa-solid fa-users-gear fs-6"></i></span>
                                    <span>
                                        <span class="d-block fw-bold text-dark">Quản Lý Tài Khoản &amp; Phân Quyền</span>
                                        <small class="text-muted">Thêm mới nhân sự, cấp quyền Quản lý / Nhân viên</small>
                                    </span>
                                </span>
                                <i class="fa-solid fa-chevron-right text-muted"></i>
                            </a>

                            <a href="LichSuKho.aspx" class="btn btn-light border text-start p-3 d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-3">
                                    <span class="badge badge-soft-info p-2 rounded-3"><i class="fa-solid fa-file-export fs-6"></i></span>
                                    <span>
                                        <span class="d-block fw-bold text-dark">Trích Xuất Báo Cáo Giao Dịch Kho</span>
                                        <small class="text-muted">Xuất danh sách phiếu nhập / xuất ra Excel, Word, PDF</small>
                                    </span>
                                </span>
                                <i class="fa-solid fa-chevron-right text-muted"></i>
                            </a>

                            <a href="CanhBao.aspx" class="btn btn-light border text-start p-3 d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-3">
                                    <span class="badge badge-soft-warning p-2 rounded-3"><i class="fa-solid fa-triangle-exclamation fs-6"></i></span>
                                    <span>
                                        <span class="d-block fw-bold text-dark">Kiểm Tra Cảnh Báo Hạn Dùng</span>
                                        <small class="text-muted">Rà soát các lô hàng sắp hết hạn sử dụng trong kho</small>
                                    </span>
                                </span>
                                <i class="fa-solid fa-chevron-right text-muted"></i>
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </div>

    <script>
        function luuCaiDatDemo() {
            var khung = document.getElementById('khungThongBaoCaiDat');
            if (!khung) return;

            var el = document.createElement('div');
            el.className = 'toast align-items-center border-0 text-bg-success';
            el.setAttribute('role', 'status');
            el.setAttribute('aria-live', 'polite');
            el.setAttribute('aria-atomic', 'true');
            el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="fa-solid fa-circle-check me-2"></i>Đã lưu thông số cấu hình hệ thống thành công!</div>' +
                '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Đóng"></button></div>';
            khung.appendChild(el);
            el.addEventListener('hidden.bs.toast', function () { el.remove(); });
            if (window.bootstrap) {
                new bootstrap.Toast(el, { autohide: true, delay: 3500 }).show();
            }
        }
    </script>
</asp:Content>
