<<<<<<< HEAD
﻿<%@ Page Title="Quản Lý Đơn Đặt Hàng" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonDatHang.aspx.cs" Inherits="N6_QLKHO.DonDatHang" %>
=======
<%@ Page Title="Quản Lý Đơn Đặt Hàng" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonDatHang.aspx.cs" Inherits="N6_QLKHO.DonDatHang" %>
>>>>>>> 2f494f6126390a3afe0f0cdd07a1230de99fe24d
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Khung chứa thông báo (toast) - cố định góc phải trên, JS sẽ thêm thông báo vào đây -->
        <div id="khungThongBao" class="toast-container position-fixed top-0 end-0 p-3 toast-container-wms"></div>

        <!-- Tiêu đề trang -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>
                <div>
                    <h1 class="page-title mb-1">Quản Lý Đơn Đặt Hàng</h1>
                    <p class="page-subtitle">Tra cứu, xem chi tiết, thêm mới và cập nhật đơn đặt hàng của khách hàng</p>
                </div>
            </div>
            <div>
                <button type="button" class="btn btn-primary btn-icon fw-semibold px-3 py-2 shadow-sm" id="btnThemDon" data-bs-toggle="modal" data-bs-target="#modalDonDatHang" onclick="moModalThem()">
                    <i class="fa-solid fa-plus"></i>
                    <span>Thêm đơn đặt hàng</span>
                </button>
            </div>
        </div>

        <!-- Bộ lọc tra cứu theo mã / ngày -->
        <div class="wms-card">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-filter"></i>
                    <span>Bộ Lọc &amp; Tra Cứu Đơn Hàng</span>
                </h2>
                <span class="text-muted small">Tìm theo mã đơn, khách hàng, ngày đặt hoặc trạng thái</span>
            </div>
            <div class="p-4">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-md-6 col-xl-3">
                        <label for="txtMaDon" class="form-label-wms">Mã đơn hoặc tên khách hàng</label>
                        <div class="search-box">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <asp:TextBox ID="txtMaDon" runat="server" CssClass="form-control" placeholder="Ví dụ: DH01, Nguyễn Văn A..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-6 col-md-3 col-xl-2">
                        <label for="txtTuNgay" class="form-label-wms">Từ ngày</label>
                        <asp:TextBox ID="txtTuNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="col-6 col-md-3 col-xl-2">
                        <label for="txtDenNgay" class="form-label-wms">Đến ngày</label>
                        <asp:TextBox ID="txtDenNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="col-12 col-md-6 col-xl-2">
                        <label for="ddlTrangThai" class="form-label-wms">Trạng thái</label>
                        <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Tất cả trạng thái" Value=""></asp:ListItem>
                            <asp:ListItem Text="Đang xử lý" Value="Đang xử lý"></asp:ListItem>
                            <asp:ListItem Text="Đã xuất kho" Value="Đã xuất kho"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-12 col-md-6 col-xl-3 d-flex gap-2">
                        <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" OnClick="btnTimKiem_Click" CssClass="btn btn-primary btn-search fw-semibold flex-fill" />
                        <asp:Button ID="btnDatLai" runat="server" Text="Đặt lại" OnClick="btnDatLai_Click" CssClass="btn btn-outline-secondary btn-search fw-semibold flex-fill" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Danh sách đơn đặt hàng -->
        <div class="wms-card mb-0">
            <div class="wms-card-header">
                <h2 class="section-title">
                    <i class="fa-solid fa-rectangle-list"></i>
                    <span>Danh Sách Đơn Đặt Hàng</span>
                </h2>
                <span class="badge badge-soft-primary px-3 py-2 rounded-pill">
                    <i class="fa-solid fa-layer-group me-1"></i>Dữ liệu đơn hàng
                </span>
            </div>

            <div class="table-responsive">
                <asp:ListView ID="lvDonHang" runat="server" OnItemCommand="lvDonHang_ItemCommand" OnPagePropertiesChanging="lvDonHang_PagePropertiesChanging" DataKeyNames="MaDonHang">
                    <LayoutTemplate>
                        <table class="table table-custom align-middle mb-0">
                            <thead>
                                <tr>
                                    <th scope="col" class="col-nowrap">Mã Đơn</th>
                                    <th scope="col" class="col-nowrap">Ngày Đặt</th>
                                    <th scope="col">Khách Hàng</th>
                                    <th scope="col" class="col-nowrap">Số Điện Thoại</th>
                                    <th scope="col" class="text-end col-nowrap">Tổng Tiền</th>
                                    <th scope="col" class="text-center col-nowrap">Trạng Thái</th>
                                    <th scope="col" class="text-center col-nowrap">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr id="itemPlaceholder" runat="server"></tr>
                            </tbody>
                        </table>
                    </LayoutTemplate>
                    <ItemTemplate>
                        <tr>
                            <td class="col-nowrap">
                                <span class="sku-badge"><%#: Eval("MaDonHang") %></span>
                            </td>
                            <td class="col-nowrap text-secondary tabular-nums">
                                <i class="fa-regular fa-calendar me-1 text-muted"></i><%#: FormatNgay(Eval("NgayDatHang")) %>
                            </td>
                            <td class="fw-semibold text-dark"><%#: Eval("TenKhachHang") %></td>
                            <td class="col-nowrap tabular-nums">
                                <i class="fa-solid fa-phone-volume me-1 text-muted small"></i><%#: Eval("SoDienThoai") %>
                            </td>
                            <td class="text-end fw-bold text-primary col-nowrap tabular-nums"><%#: FormatTien(Eval("TongTien")) %></td>
                            <td class="text-center col-nowrap">
                                <span class="badge rounded-pill px-3 py-2 <%# LopTrangThai(Eval("TrangThai")) %>"><%#: Eval("TrangThai") %></span>
                            </td>
                            <td class="text-center col-nowrap">
                                <div class="d-inline-flex align-items-center gap-1">
                                    <!-- Nút xem chi tiết (gắn thêm data-ma để JS nhận diện) -->
                                    <button type="button" class="btn btn-sm btn-light border text-secondary shadow-xs"
                                            data-bs-toggle="modal" data-bs-target="#modalChiTiet"
                                            data-ma="<%#: Eval("MaDonHang") %>"
                                            title="Xem chi tiết đơn hàng">
                                        <i class="fa-regular fa-eye me-1 text-info"></i>Chi tiết
                                    </button>

                                    <!-- Nút sửa (gắn thêm data-ma và gọi hàm JS mở modal sửa) -->
                                    <button type="button" class="btn btn-sm btn-light border text-primary shadow-xs"
                                            data-bs-toggle="modal" data-bs-target="#modalDonDatHang"
                                            data-ma="<%#: Eval("MaDonHang") %>"
                                            onclick="moModalSua(this)"
                                            title="Chỉnh sửa đơn hàng">
                                        <i class="fa-regular fa-pen-to-square me-1"></i>Sửa
                                    </button>

                                    <asp:Button ID="btnXoa" runat="server" CommandName="XoaDon" CommandArgument='<%# Eval("MaDonHang") %>' Text="Xóa" CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa đơn hàng này?');" />
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <div class="empty-state-icon">
                                <i class="fa-solid fa-cart-flatbed"></i>
                            </div>
                            <h6 class="fw-bold text-dark mb-1">Không tìm thấy đơn đặt hàng nào</h6>
                            <p class="small text-muted mb-0">Hãy thử thay đổi bộ lọc tìm kiếm hoặc bấm "Thêm đơn đặt hàng" để tạo mới.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>
            </div>

            <div class="card-footer bg-white border-top px-4 py-3 small text-secondary d-flex flex-wrap justify-content-between align-items-center gap-2">
                <asp:Label ID="lblSoLuong" runat="server" CssClass="fw-semibold"></asp:Label>
                <asp:DataPager ID="dpDonHang" runat="server" PagedControlID="lvDonHang" PageSize="10">
                    <Fields>
                        <asp:NumericPagerField ButtonCount="5" NumericButtonCssClass="btn btn-sm btn-outline-secondary mx-1" CurrentPageLabelCssClass="btn btn-sm btn-primary mx-1 disabled" />
                    </Fields>
                </asp:DataPager>
            </div>
        </div>

        <!-- Modal xem chi tiết đơn đặt hàng -->
        <div class="modal fade" id="modalChiTiet" tabindex="-1" aria-labelledby="modalChiTietLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable modal-dialog-centered modal-fullscreen-sm-down">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h2 class="modal-title h5 fw-bold mb-0" id="modalChiTietLabel">
                            <i class="fa-solid fa-file-invoice me-2 text-info"></i>Chi tiết đơn hàng <span id="ctMaDon" class="badge bg-primary ms-1"></span>
                        </h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="bg-light border rounded-3 p-3 mb-4">
                            <dl class="row mb-0 g-2">
                                <dt class="col-5 col-md-3 text-secondary small text-uppercase fw-bold">Khách hàng</dt>
                                <dd class="col-7 col-md-9 fw-semibold text-dark mb-1" id="ctKhachHang"></dd>
                                <dt class="col-5 col-md-3 text-secondary small text-uppercase fw-bold">Số điện thoại</dt>
                                <dd class="col-7 col-md-9 mb-1 tabular-nums" id="ctSdt"></dd>
                                <dt class="col-5 col-md-3 text-secondary small text-uppercase fw-bold">Ngày đặt</dt>
                                <dd class="col-7 col-md-9 mb-1 tabular-nums" id="ctNgayDat"></dd>
                                <dt class="col-5 col-md-3 text-secondary small text-uppercase fw-bold">Trạng thái</dt>
                                <dd class="col-7 col-md-9 mb-0 fw-semibold text-primary" id="ctTrangThai"></dd>
                            </dl>
                        </div>

                        <h3 class="section-title mb-3">
                            <i class="fa-solid fa-boxes-stacked"></i>
                            <span>Danh sách hàng hóa trong đơn</span>
                        </h3>
                        <div class="table-responsive border rounded-3">
                            <table class="table table-custom align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th scope="col" class="col-nowrap">Mã Hàng Hóa</th>
                                        <th scope="col">Tên Hàng Hóa</th>
                                        <th scope="col" class="text-end col-nowrap">Số Lượng</th>
                                        <th scope="col" class="text-end col-nowrap">Đơn Giá</th>
                                        <th scope="col" class="text-end col-nowrap">Thành Tiền</th>
                                    </tr>
                                </thead>
                                <tbody id="tbXemChiTiet"></tbody>
                                <tfoot class="table-light">
                                    <tr>
                                        <th colspan="4" class="text-end fw-bold">Tổng cộng thanh toán</th>
                                        <th class="text-end fw-bold text-primary fs-6 col-nowrap tabular-nums" id="ctTongCong">0 VND</th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal thêm / sửa đơn đặt hàng -->
        <div class="modal fade" id="modalDonDatHang" tabindex="-1" aria-labelledby="modalDonDatHangLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable modal-dialog-centered modal-fullscreen-sm-down">
                <div class="modal-content overflow-hidden">
                    <div class="modal-header modal-header-modern">
                        <h2 class="modal-title h5 fw-bold mb-0" id="modalDonDatHangLabel">Thêm đơn đặt hàng</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                    </div>
                    <div class="modal-body p-4">
                        <!-- Hidden field để phân biệt chế độ Thêm hay Sửa ở codebehind -->
                        <asp:HiddenField ID="hdCheDo" runat="server" Value="Them" />
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-4">
                                <label for="mdMaDon" class="form-label-wms">Mã đơn <span class="text-danger">*</span></label>
                                <asp:TextBox ID="mdMaDon" runat="server" CssClass="form-control" placeholder="VD: DH04" />
                            </div>
                            <div class="col-12 col-md-4">
                                <label for="mdNgayDat" class="form-label-wms">Ngày đặt <span class="text-danger">*</span></label>
                                <asp:TextBox ID="mdNgayDat" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                            </div>
                            <div class="col-12 col-md-4">
                                <label for="mdTrangThai" class="form-label-wms">Trạng thái</label>
                                <asp:DropDownList ID="mdTrangThai" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Đang xử lý" Value="Đang xử lý"></asp:ListItem>
                                    <asp:ListItem Text="Đã xuất kho" Value="Đã xuất kho"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-12 col-md-8">
                                <label for="mdTenKhach" class="form-label-wms">Tên khách hàng <span class="text-danger">*</span></label>
                                <asp:TextBox ID="mdTenKhach" runat="server" CssClass="form-control" placeholder="Nhập họ tên hoặc tên đơn vị khách hàng" />
                            </div>
                            <div class="col-12 col-md-4">
                                <label for="mdSdt" class="form-label-wms">Số điện thoại <span class="text-danger">*</span></label>
                                <asp:TextBox ID="mdSdt" runat="server" CssClass="form-control" TextMode="Number" placeholder="09xxxxxxxx" />
                            </div>
                        </div>

                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <h3 class="section-title">
                                <i class="fa-solid fa-list-check"></i>
                                <span>Hàng Hóa Đặt</span>
                            </h3>
                            <button type="button" class="btn btn-sm btn-outline-primary btn-icon fw-semibold" id="btnThemDong">
                                <i class="fa-solid fa-plus"></i>
                                <span>Thêm dòng</span>
                            </button>
                        </div>
                        <div class="table-responsive border rounded-3">
                            <table class="table table-custom align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th scope="col">Tên Hàng Hóa</th>
                                        <th scope="col" class="text-end col-nowrap">Số Lượng</th>
                                        <th scope="col" class="text-end col-nowrap">Đơn Giá</th>
                                        <th scope="col" class="text-end col-nowrap">Thành Tiền</th>
                                        <th scope="col" class="text-center col-nowrap">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody id="tbChiTiet">
                                    <tr>
                                        <td>
                                            <asp:DropDownList ID="ddlHangHoa" runat="server" CssClass="form-select form-select-sm ddl-hang-hoa">
                                            </asp:DropDownList>
                                        </td>
                                        <td><input type="number" name="SoLuong" min="1"
                                                   class="form-control form-control-sm text-end inp-so-luong tabular-nums"
                                                   value="1" aria-label="Số lượng" /></td>
                                        <td><input type="number" name="DonGia" min="0" step="any"
                                                   class="form-control form-control-sm text-end inp-don-gia tabular-nums"
                                                   value="0" aria-label="Đơn giá" /></td>
                                        <td class="text-end fw-semibold thanh-tien col-nowrap tabular-nums">0 VND</td>
                                        <td class="text-center col-nowrap"><button type="button" class="btn btn-sm btn-outline-danger btn-xoa-dong">Xóa</button></td>
                                    </tr>
                                </tbody>
                                <tfoot class="table-light">
                                    <tr>
                                        <th colspan="3" class="text-end fw-bold">Tổng cộng</th>
                                        <th class="text-end fw-bold text-primary fs-6 col-nowrap tabular-nums" id="tdTongCong">0 VND</th>
                                        <th></th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-modern">
                        <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">Hủy</button>
                        <asp:Button ID="btnLuuDon" runat="server" Text="Lưu đơn" OnClick="btnLuuDon_Click" CssClass="btn btn-primary px-4 fw-semibold shadow-sm" />
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- JavaScript xử lý Modal + Thông báo -->
    <script>
        var duLieu = <%= ChiTietJson %>;
        var giaHang = <%= GiaHangJson %>;

        function dinhDangTien(so) {
            return Math.round(Number(so) || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' VND';
        }

        function escHtml(s) {
            return String(s).replace(/[&<>"']/g, function (c) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
            });
        }

        /* =====================================================
           THÔNG BÁO (toast): thành công = xanh, thất bại = đỏ
           - Tự ẩn sau 4 giây (rê chuột vào thì tạm dừng đếm)
           - Bấm nút X để tắt ngay
           ===================================================== */
        function hienThongBao(noiDung, thanhCong) {
            var khung = document.getElementById('khungThongBao');
            if (!khung) return;

            var el = document.createElement('div');
            el.className = 'toast align-items-center border-0 text-bg-' + (thanhCong ? 'success' : 'danger');
            el.setAttribute('role', thanhCong ? 'status' : 'alert');
            el.setAttribute('aria-live', thanhCong ? 'polite' : 'assertive');
            el.setAttribute('aria-atomic', 'true');

            var wrap = document.createElement('div');
            wrap.className = 'd-flex';

            var body = document.createElement('div');
            body.className = 'toast-body';
            body.textContent = noiDung;          // textContent -> an toàn, không chạy HTML

            var nut = document.createElement('button');
            nut.type = 'button';
            nut.className = 'btn-close btn-close-white me-2 m-auto';
            nut.setAttribute('data-bs-dismiss', 'toast');
            nut.setAttribute('aria-label', 'Đóng');

            wrap.appendChild(body);
            wrap.appendChild(nut);
            el.appendChild(wrap);
            khung.appendChild(el);

            el.addEventListener('hidden.bs.toast', function () { el.remove(); });

            var toast = new bootstrap.Toast(el, { autohide: true, delay: 4000 });
            toast.show();
        }

        /* --- Xử lý tính tiền trong modal Thêm/Sửa --- */
        var tbody = document.getElementById('tbChiTiet');
        var tongCong = document.getElementById('tdTongCong');
        var btnThemDong = document.getElementById('btnThemDong');
        var dongMau = tbody ? tbody.rows[0].cloneNode(true) : null;

        function tinhTien() {
            if (!tbody || !tongCong) return;
            var tong = 0;
            Array.prototype.forEach.call(tbody.rows, function (tr) {
                var sl = parseFloat(tr.querySelector('.inp-so-luong').value) || 0;
                var gia = parseFloat(tr.querySelector('.inp-don-gia').value) || 0;
                var thanhTien = sl * gia;
                tr.querySelector('.thanh-tien').textContent = dinhDangTien(thanhTien);
                tong += thanhTien;
            });
            tongCong.textContent = dinhDangTien(tong);
        }

        if (btnThemDong && tbody) {

            // Khi chọn hàng hóa -> tự điền đơn giá tương ứng 
            tbody.addEventListener('change', function (e) {
                var select = e.target.closest('.ddl-hang-hoa');
                if (!select) return;

                var tr = select.closest('tr');
                var maHang = (select.value || '').trim();

                if (maHang && giaHang[maHang] !== undefined) {
                    tr.querySelector('.inp-don-gia').value = giaHang[maHang];
                } else {
                    tr.querySelector('.inp-don-gia').value = 0;
                }

                tinhTien();
            });

            btnThemDong.addEventListener('click', function () {
                var tr = dongMau.cloneNode(true);
                tr.querySelector('select').selectedIndex = 0;
                tr.querySelector('.inp-so-luong').value = 1;
                tr.querySelector('.inp-don-gia').value = 0;
                tbody.appendChild(tr);
                tinhTien();
            });

            tbody.addEventListener('click', function (e) {
                var nut = e.target.closest('.btn-xoa-dong');
                if (!nut) return;
                var tr = nut.closest('tr');
                if (tbody.rows.length > 1) {
                    tr.remove();
                } else {
                    tr.querySelector('select').selectedIndex = 0;
                    tr.querySelector('.inp-so-luong').value = 1;
                    tr.querySelector('.inp-don-gia').value = 0;
                }
                tinhTien();
            });

            tbody.addEventListener('input', tinhTien);
        }

        /* --- Mở Modal Thêm mới --- */
        function moModalThem() {
            document.getElementById('modalDonDatHangLabel').textContent = 'Thêm đơn đặt hàng';
            document.getElementById('<%= hdCheDo.ClientID %>').value = 'Them';
            document.getElementById('<%= mdMaDon.ClientID %>').value = '';
            document.getElementById('<%= mdMaDon.ClientID %>').readOnly = false;
            document.getElementById('<%= mdNgayDat.ClientID %>').value = '';
            document.getElementById('<%= mdTenKhach.ClientID %>').value = '';
            document.getElementById('<%= mdSdt.ClientID %>').value = '';

            // Reset bảng chi tiết về 1 dòng mặc định
            if (tbody && dongMau) {
                tbody.innerHTML = '';
                var tr = dongMau.cloneNode(true);
                tr.querySelector('select').selectedIndex = 0;
                tr.querySelector('.inp-so-luong').value = 1;
                tr.querySelector('.inp-don-gia').value = 0;
                tbody.appendChild(tr);
                tinhTien();
            }
        }

        /* --- Mở Modal Sửa (Đổ dữ liệu cũ lên form) --- */
        function moModalSua(btn) {
            var ma = btn.getAttribute('data-ma');
            var don = duLieu[ma];
            if (!don) return;

            document.getElementById('modalDonDatHangLabel').textContent = 'Sửa đơn đặt hàng: ' + ma;
            document.getElementById('<%= hdCheDo.ClientID %>').value = 'Sua';

            var txtMa = document.getElementById('<%= mdMaDon.ClientID %>');
            txtMa.value = ma;
            txtMa.readOnly = true; // Khóa mã đơn không cho sửa khóa chính

            if (don.ngayRaw) {
                document.getElementById('<%= mdNgayDat.ClientID %>').value = don.ngayRaw;
            }
            document.getElementById('<%= mdTenKhach.ClientID %>').value = don.khach;
            document.getElementById('<%= mdSdt.ClientID %>').value = don.sdt;

            var ddlTrangThai = document.getElementById('<%= mdTrangThai.ClientID %>');
            for (var i = 0; i < ddlTrangThai.options.length; i++) {
                if (ddlTrangThai.options[i].value === don.trangThai) {
                    ddlTrangThai.selectedIndex = i;
                    break;
                }
            }

            // Đổ danh sách sản phẩm vào bảng chi tiết
            if (tbody && dongMau) {
                tbody.innerHTML = '';
                don.dong.forEach(function (d) {
                    var tr = dongMau.cloneNode(true);
                    var select = tr.querySelector('select');
                    var maHangCanChon = (d.MaHang || '').trim();
                    for (var j = 0; j < select.options.length; j++) {
                        if (select.options[j].value.trim() === maHangCanChon) {
                            select.selectedIndex = j;
                            break;
                        }
                    }
                    tr.querySelector('.inp-so-luong').value = d.SoLuong;
                    tr.querySelector('.inp-don-gia').value = d.DonGia;
                    tbody.appendChild(tr);
                });
                tinhTien();
            }
        }

        /* --- Khi lưu thất bại: mở lại modal và dựng lại các dòng đã nhập --- */
        function khoiPhucForm(cheDo, dong) {
            var txtMa = document.getElementById('<%= mdMaDon.ClientID %>');
            txtMa.readOnly = (cheDo === 'Sua');
            document.getElementById('modalDonDatHangLabel').textContent =
                cheDo === 'Sua' ? 'Sửa đơn đặt hàng: ' + txtMa.value : 'Thêm đơn đặt hàng';

            if (tbody && dongMau && dong && dong.length) {
                tbody.innerHTML = '';
                dong.forEach(function (d) {
                    var tr = dongMau.cloneNode(true);
                    var select = tr.querySelector('select');
                    var maHangCanChon = (d.ma || '').trim();
                    for (var j = 0; j < select.options.length; j++) {
                        if (select.options[j].value.trim() === maHangCanChon) {
                            select.selectedIndex = j;
                            break;
                        }
                    }
                    tr.querySelector('.inp-so-luong').value = d.sl;
                    tr.querySelector('.inp-don-gia').value = d.gia;
                    tbody.appendChild(tr);
                });
                tinhTien();
            }

            bootstrap.Modal.getOrCreateInstance(document.getElementById('modalDonDatHang')).show();
        }

        /* --- Đổ dữ liệu vào Modal Chi Tiết --- */
        var modalChiTiet = document.getElementById('modalChiTiet');
        if (modalChiTiet) {
            modalChiTiet.addEventListener('show.bs.modal', function (e) {
                var nut = e.relatedTarget;
                var ma = nut ? nut.getAttribute('data-ma') : null;
                var don = ma ? duLieu[ma] : null;
                if (!don) return;

                document.getElementById('ctMaDon').textContent = ma;
                document.getElementById('ctKhachHang').textContent = don.khach;
                document.getElementById('ctSdt').textContent = don.sdt;
                document.getElementById('ctNgayDat').textContent = don.ngay;
                document.getElementById('ctTrangThai').textContent = don.trangThai;

                var body = document.getElementById('tbXemChiTiet');
                body.innerHTML = '';
                var tong = 0;
                don.dong.forEach(function (d) {
                    var thanhTien = d.SoLuong * d.DonGia;
                    tong += thanhTien;
                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td class="fw-semibold col-nowrap">' + escHtml(d.MaHang) + '</td>' +
                        '<td>' + escHtml(d.TenHang) + '</td>' +
                        '<td class="text-end col-nowrap tabular-nums">' + d.SoLuong.toLocaleString('vi-VN') + '</td>' +
                        '<td class="text-end col-nowrap tabular-nums">' + dinhDangTien(d.DonGia) + '</td>' +
                        '<td class="text-end fw-semibold col-nowrap tabular-nums">' + dinhDangTien(thanhTien) + '</td>';
                    body.appendChild(tr);
                });
                document.getElementById('ctTongCong').textContent = dinhDangTien(tong);
            });
        }

        /* --- Kiểm tra bắt buộc nhập trước khi gửi form --- */
        function kiemTraForm() {
            function loi(noiDung, el) {
                hienThongBao(noiDung, false);
                if (el) el.focus();
                return false;
            }

            var maDon = document.getElementById('<%= mdMaDon.ClientID %>');
            var ngay = document.getElementById('<%= mdNgayDat.ClientID %>');
            var khach = document.getElementById('<%= mdTenKhach.ClientID %>');
            var sdt = document.getElementById('<%= mdSdt.ClientID %>');

            if (!maDon.value.trim()) return loi('Mã đơn hàng không được để trống!', maDon);
            if (!ngay.value) return loi('Ngày đặt không được để trống!', ngay);
            if (!khach.value.trim()) return loi('Tên khách hàng không được để trống!', khach);
            if (!sdt.value.trim()) return loi('Số điện thoại không được để trống!', sdt);
            if (!/^\d{9,11}$/.test(sdt.value.trim())) return loi('Số điện thoại không hợp lệ (chỉ gồm 9–11 chữ số)!', sdt);

            for (var i = 0; i < tbody.rows.length; i++) {
                var tr = tbody.rows[i];
                var select = tr.querySelector('select');
                var sl = tr.querySelector('.inp-so-luong');
                var gia = tr.querySelector('.inp-don-gia');
                var dong = ' ở dòng ' + (i + 1) + '!';

                if (!select.value) return loi('Vui lòng chọn hàng hóa' + dong, select);
                if (!sl.value || parseInt(sl.value, 10) < 1) return loi('Số lượng phải từ 1 trở lên' + dong, sl);
                if (gia.value === '' || parseFloat(gia.value) < 0) return loi('Đơn giá không được để trống' + dong, gia);
            }
            return true;
        }
    </script>
</asp:Content>
