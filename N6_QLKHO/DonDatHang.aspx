<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonDatHang.aspx.cs" Inherits="N6_QLKHO.DonDatHang" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <!-- Tiêu đề trang -->
    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-2 mb-4">
        <div>
            <h1 class="h4 fw-bold mb-1">Đơn đặt hàng</h1>
            <p class="text-body-secondary small mb-0">Tra cứu, xem chi tiết, thêm mới và cập nhật đơn đặt hàng của khách hàng.</p>
        </div>
        <button type="button" class="btn btn-primary" id="btnThemDon" data-bs-toggle="modal" data-bs-target="#modalDonDatHang">Thêm đơn đặt hàng</button>
    </div>

    <asp:Label ID="lblLoi" runat="server" Visible="false" CssClass="alert alert-danger d-block" role="alert"></asp:Label>

    <!-- Bộ lọc tra cứu theo mã / ngày -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-12 col-md-6 col-xl-3">
                    <label for="txtMaDon" class="form-label small fw-semibold">Mã đơn hoặc tên khách hàng</label>
                    <asp:TextBox ID="txtMaDon" runat="server" CssClass="form-control" placeholder="Ví dụ: DH01"></asp:TextBox>
                </div>
                <div class="col-6 col-md-3 col-xl-2">
                    <label for="txtTuNgay" class="form-label small fw-semibold">Từ ngày</label>
                    <asp:TextBox ID="txtTuNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-6 col-md-3 col-xl-2">
                    <label for="txtDenNgay" class="form-label small fw-semibold">Đến ngày</label>
                    <asp:TextBox ID="txtDenNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-12 col-md-6 col-xl-2">
                    <label for="ddlTrangThai" class="form-label small fw-semibold">Trạng thái</label>
                    <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Tất cả" Value=""></asp:ListItem>
                        <asp:ListItem Text="Đang xử lý" Value="Đang xử lý"></asp:ListItem>
                        <asp:ListItem Text="Đã xuất kho" Value="Đã xuất kho"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-12 col-md-6 col-xl-3 d-flex gap-2">
                    <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" OnClick="btnTimKiem_Click" CssClass="btn btn-primary flex-fill flex-xl-grow-0" />
                    <asp:Button ID="btnDatLai" runat="server" Text="Đặt lại" OnClick="btnDatLai_Click" CssClass="btn btn-outline-secondary flex-fill flex-xl-grow-0" />
                </div>
            </div>
        </div>
    </div>

    <!-- Danh sách đơn đặt hàng (đổ từ SQL Server bằng Repeater) -->
    <div class="card border-0 shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th scope="col">Mã đơn</th>
                        <th scope="col">Ngày đặt</th>
                        <th scope="col">Khách hàng</th>
                        <th scope="col" class="d-none d-lg-table-cell">Số điện thoại</th>
                        <th scope="col" class="text-end d-none d-md-table-cell">Tổng tiền</th>
                        <th scope="col" class="d-none d-sm-table-cell">Trạng thái</th>
                        <th scope="col" class="text-end">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptDonHang" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="fw-semibold"><%#: Eval("MaDonHang") %></td>
                                <td><%#: FormatNgay(Eval("NgayDatHang")) %></td>
                                <td><%#: Eval("TenKhachHang") %></td>
                                <td class="d-none d-lg-table-cell"><%#: Eval("SoDienThoai") %></td>
                                <td class="text-end d-none d-md-table-cell"><%#: FormatTien(Eval("TongTien")) %></td>
                                <td class="d-none d-sm-table-cell"><span class="badge <%# LopTrangThai(Eval("TrangThai")) %>"><%#: Eval("TrangThai") %></span></td>
                                <td class="text-end text-nowrap">
                                    <button type="button" class="btn btn-sm btn-outline-secondary btn-chi-tiet" data-ma="<%#: Eval("MaDonHang") %>" data-bs-toggle="modal" data-bs-target="#modalChiTiet">Chi tiết</button>
                                    <button type="button" class="btn btn-sm btn-outline-primary">Sửa</button>
                                    <button type="button" class="btn btn-sm btn-outline-danger">Xóa</button>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Panel ID="pnlTrong" runat="server" Visible="false" CssClass="text-center text-body-secondary py-5">
            Không tìm thấy đơn đặt hàng nào.
        </asp:Panel>

        <div class="card-footer bg-white small text-body-secondary">
            <asp:Label ID="lblSoLuong" runat="server"></asp:Label>
        </div>
    </div>

    <!-- Modal xem chi tiết đơn đặt hàng -->
    <div class="modal fade" id="modalChiTiet" tabindex="-1" aria-labelledby="modalChiTietLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable modal-fullscreen-sm-down">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title h5" id="modalChiTietLabel">Chi tiết đơn <span id="ctMaDon"></span></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body">
                    <dl class="row mb-4">
                        <dt class="col-5 col-md-3 fw-semibold">Khách hàng</dt>
                        <dd class="col-7 col-md-9" id="ctKhachHang"></dd>
                        <dt class="col-5 col-md-3 fw-semibold">Số điện thoại</dt>
                        <dd class="col-7 col-md-9" id="ctSdt"></dd>
                        <dt class="col-5 col-md-3 fw-semibold">Ngày đặt</dt>
                        <dd class="col-7 col-md-9" id="ctNgayDat"></dd>
                        <dt class="col-5 col-md-3 fw-semibold">Trạng thái</dt>
                        <dd class="col-7 col-md-9 mb-0" id="ctTrangThai"></dd>
                    </dl>

                    <h3 class="h6 fw-bold mb-2">Hàng hóa trong đơn</h3>
                    <div class="table-responsive">
                        <table class="table table-sm align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col">Mã hàng hóa</th>
                                    <th scope="col" class="text-end">Số lượng</th>
                                    <th scope="col" class="text-end">Đơn giá</th>
                                    <th scope="col" class="text-end">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody id="tbXemChiTiet"></tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="3" class="text-end">Tổng cộng</th>
                                    <th class="text-end" id="ctTongCong">0 ₫</th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal thêm đơn đặt hàng (chỉ giao diện, chưa lưu dữ liệu) -->
    <div class="modal fade" id="modalDonDatHang" tabindex="-1" aria-labelledby="modalDonDatHangLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable modal-fullscreen-sm-down">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title h5" id="modalDonDatHangLabel">Thêm đơn đặt hàng</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3 mb-4">
                        <div class="col-12 col-md-4">
                            <label for="mdMaDon" class="form-label small fw-semibold">Mã đơn</label>
                            <input type="text" id="mdMaDon" class="form-control" value="DH04" readonly />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdNgayDat" class="form-label small fw-semibold">Ngày đặt</label>
                            <input type="datetime-local" id="mdNgayDat" class="form-control" />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdTrangThai" class="form-label small fw-semibold">Trạng thái</label>
                            <select id="mdTrangThai" class="form-select">
                                <option>Đang xử lý</option>
                                <option>Đã xuất kho</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-8">
                            <label for="mdTenKhach" class="form-label small fw-semibold">Tên khách hàng</label>
                            <input type="text" id="mdTenKhach" class="form-control" />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdSdt" class="form-label small fw-semibold">Số điện thoại</label>
                            <input type="tel" id="mdSdt" class="form-control" />
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <h3 class="h6 fw-bold mb-0">Hàng hóa đặt</h3>
                        <button type="button" class="btn btn-sm btn-outline-primary" id="btnThemDong">Thêm dòng</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-sm align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="min-width: 140px;">Mã hàng hóa</th>
                                    <th scope="col" style="min-width: 90px;">Số lượng</th>
                                    <th scope="col" style="min-width: 120px;">Đơn giá</th>
                                    <th scope="col" class="text-end" style="min-width: 120px;">Thành tiền</th>
                                    <th scope="col"><span class="visually-hidden">Xóa dòng</span></th>
                                </tr>
                            </thead>
                            <tbody id="tbChiTiet">
                                <tr>
                                    <td>
                                        <select class="form-select form-select-sm" aria-label="Mã hàng hóa">
                                            <option value="">Chọn hàng hóa</option>
                                            <option>HH01</option>
                                            <option>HH02</option>
                                            <option>HH03</option>
                                            <option>HH04</option>
                                            <option>HH05</option>
                                        </select>
                                    </td>
                                    <td><input type="number" min="1" class="form-control form-control-sm inp-so-luong" value="1" aria-label="Số lượng" /></td>
                                    <td><input type="number" min="0" class="form-control form-control-sm inp-don-gia" value="0" aria-label="Đơn giá" /></td>
                                    <td class="text-end thanh-tien">0 ₫</td>
                                    <td class="text-end"><button type="button" class="btn btn-sm btn-outline-danger btn-xoa-dong">Xóa</button></td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="3" class="text-end">Tổng cộng</th>
                                    <th class="text-end" id="tdTongCong">0 ₫</th>
                                    <th></th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary">Lưu đơn</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function () {
            function dinhDangTien(so) {
                return so.toLocaleString('vi-VN') + ' ₫';
            }

            /* ---------- Modal thêm đơn: thêm/xóa dòng, tính tiền ---------- */
            var tbody = document.getElementById('tbChiTiet');
            var tongCong = document.getElementById('tdTongCong');
            var btnThemDong = document.getElementById('btnThemDong');

            if (tbody && tongCong && btnThemDong) {
                var dongMau = tbody.rows[0].cloneNode(true);

                function tinhTien() {
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

                function datLaiDong(tr) {
                    tr.querySelector('select').selectedIndex = 0;
                    tr.querySelector('.inp-so-luong').value = 1;
                    tr.querySelector('.inp-don-gia').value = 0;
                }

                btnThemDong.addEventListener('click', function () {
                    var tr = dongMau.cloneNode(true);
                    datLaiDong(tr);
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
                        datLaiDong(tr); // giữ lại ít nhất một dòng
                    }
                    tinhTien();
                });

                tbody.addEventListener('input', tinhTien);
                tinhTien();
            }

            /* ---------- Modal xem chi tiết đơn (dữ liệu từ SQL Server) ---------- */
            var duLieu = <%= ChiTietJson %>;

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
                        var thanhTien = d[1] * d[2];
                        tong += thanhTien;
                        var tr = document.createElement('tr');
                        [d[0], d[1].toLocaleString('vi-VN'), dinhDangTien(d[2]), dinhDangTien(thanhTien)].forEach(function (text, i) {
                            var td = document.createElement('td');
                            td.textContent = text;
                            if (i > 0) td.className = 'text-end';
                            tr.appendChild(td);
                        });
                        body.appendChild(tr);
                    });
                    document.getElementById('ctTongCong').textContent = dinhDangTien(tong);
                });
            }
        })();
    </script>



</asp:Content>
