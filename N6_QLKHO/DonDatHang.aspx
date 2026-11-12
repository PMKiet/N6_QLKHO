<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonDatHang.aspx.cs" Inherits="N6_QLKHO.DonDatHang" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Khung chứa thông báo (toast) - cố định góc phải trên, JS sẽ thêm thông báo vào đây -->
    <div id="khungThongBao" class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 2000;"></div>

    <!-- Tiêu đề trang -->
    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-2 mb-4">
        <div>
            <h1 class="h4 fw-bold mb-1">Đơn đặt hàng</h1>
            <p class="text-body-secondary small mb-0">Tra cứu, xem chi tiết, thêm mới và cập nhật đơn đặt hàng của khách hàng.</p>
        </div>
        <button type="button" class="btn btn-primary" id="btnThemDon" data-bs-toggle="modal" data-bs-target="#modalDonDatHang" onclick="moModalThem()">Thêm đơn đặt hàng</button>
    </div>

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

    <!-- Danh sách đơn đặt hàng -->
    <div class="card border-0 shadow-sm">
        <div class="table-responsive">
            <asp:ListView ID="lvDonHang" runat="server" OnItemCommand="lvDonHang_ItemCommand" OnPagePropertiesChanging="lvDonHang_PagePropertiesChanging" DataKeyNames="MaDonHang">
                <LayoutTemplate>
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
                            <tr id="itemPlaceholder" runat="server"></tr>
                        </tbody>
                    </table>
                </LayoutTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="fw-semibold"><%#: Eval("MaDonHang") %></td>
                        <td><%#: FormatNgay(Eval("NgayDatHang")) %></td>
                        <td><%#: Eval("TenKhachHang") %></td>
                        <td class="d-none d-lg-table-cell"><%#: Eval("SoDienThoai") %></td>
                        <td class="text-end d-none d-md-table-cell"><%#: FormatTien(Eval("TongTien")) %></td>
                        <td class="d-none d-sm-table-cell"><span class="badge <%# LopTrangThai(Eval("TrangThai")) %>"><%#: Eval("TrangThai") %></span></td>
                        <td class="text-end text-nowrap">
                            <!-- Nút xem chi tiết (gắn thêm data-ma để JS nhận diện) -->
                            <button type="button" class="btn btn-sm btn-outline-secondary" 
                                    data-bs-toggle="modal" data-bs-target="#modalChiTiet" 
                                    data-ma="<%#: Eval("MaDonHang") %>">
                                Chi tiết
                            </button>
                            
                            <!-- Nút sửa (gắn thêm data-ma và gọi hàm JS mở modal sửa) -->
                            <button type="button" class="btn btn-sm btn-outline-primary" 
                                    data-bs-toggle="modal" data-bs-target="#modalDonDatHang" 
                                    data-ma="<%#: Eval("MaDonHang") %>"
                                    onclick="moModalSua(this)">
                                Sửa
                            </button>

                            <asp:Button ID="btnXoa" runat="server" CommandName="XoaDon" CommandArgument='<%# Eval("MaDonHang") %>' Text="Xóa" CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa đơn hàng này?');" />
                        </td>
                    </tr>
                </ItemTemplate>
                <EmptyDataTemplate>
                    <div class="text-center text-body-secondary py-5">
                        Không tìm thấy đơn đặt hàng nào.
                    </div>
                </EmptyDataTemplate>
            </asp:ListView>
        </div>

        <div class="card-footer bg-white small text-body-secondary d-flex justify-content-between align-items-center">
            <asp:Label ID="lblSoLuong" runat="server"></asp:Label>
            <asp:DataPager ID="dpDonHang" runat="server" PagedControlID="lvDonHang" PageSize="10">
                <Fields>
                    <asp:NumericPagerField ButtonCount="5" NumericButtonCssClass="btn btn-sm btn-outline-secondary mx-1" CurrentPageLabelCssClass="btn btn-sm btn-secondary mx-1 disabled" />
                </Fields>
            </asp:DataPager>
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
                                    <th scope="col">Tên hàng hóa</th>
                                    <th scope="col" class="text-end">Số lượng</th>
                                    <th scope="col" class="text-end">Đơn giá</th>
                                    <th scope="col" class="text-end">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody id="tbXemChiTiet"></tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="4" class="text-end">Tổng cộng</th>
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

    <!-- Modal thêm / sửa đơn đặt hàng -->
    <div class="modal fade" id="modalDonDatHang" tabindex="-1" aria-labelledby="modalDonDatHangLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable modal-fullscreen-sm-down">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title h5" id="modalDonDatHangLabel">Thêm đơn đặt hàng</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body">
                    <!-- Hidden field để phân biệt chế độ Thêm hay Sửa ở codebehind -->
                    <asp:HiddenField ID="hdCheDo" runat="server" Value="Them" />
                    <div class="row g-3 mb-4">
                        <div class="col-12 col-md-4">
                            <label for="mdMaDon" class="form-label small fw-semibold">Mã đơn</label>
                            <asp:TextBox ID="mdMaDon" runat="server" CssClass="form-control" placeholder="DH04" />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdNgayDat" class="form-label small fw-semibold">Ngày đặt</label>
                            <asp:TextBox ID="mdNgayDat" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdTrangThai" class="form-label small fw-semibold">Trạng thái</label>
                            <asp:DropDownList ID="mdTrangThai" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Đang xử lý" Value="Đang xử lý"></asp:ListItem>
                                <asp:ListItem Text="Đã xuất kho" Value="Đã xuất kho"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-12 col-md-8">
                            <label for="mdTenKhach" class="form-label small fw-semibold">Tên khách hàng</label>
                            <asp:TextBox ID="mdTenKhach" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-12 col-md-4">
                            <label for="mdSdt" class="form-label small fw-semibold">Số điện thoại</label>
                            <asp:TextBox ID="mdSdt" runat="server" CssClass="form-control" TextMode="Number" />
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
                                    <th scope="col" style="min-width: 140px;">Tên hàng hóa</th>
                                    <th scope="col" style="min-width: 90px;">Số lượng</th>
                                    <th scope="col" style="min-width: 120px;">Đơn giá</th>
                                    <th scope="col" class="text-end" style="min-width: 120px;">Thành tiền</th>
                                    <th scope="col"><span class="visually-hidden">Xóa dòng</span></th>
                                </tr>
                            </thead>
                            <tbody id="tbChiTiet">
                                <tr>
                                    <td>
                                        <asp:DropDownList ID="ddlHangHoa" runat="server" CssClass="form-select form-select-sm ddl-hang-hoa">
                                        </asp:DropDownList>
                                    </td>
                                    <td><input type="number" name="SoLuong" min="1"
                                               class="form-control form-control-sm inp-so-luong"
                                               value="1" aria-label="Số lượng" /></td>
                                    <td><input type="number" name="DonGia" min="0" step="any"
                                               class="form-control form-control-sm inp-don-gia"
                                               value="0" aria-label="Đơn giá" /></td>
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
                    <asp:Button ID="btnLuuDon" runat="server" Text="Lưu đơn" OnClick="btnLuuDon_Click" CssClass="btn btn-primary" />
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript xử lý Modal + Thông báo -->
    <script>
        var duLieu = <%= ChiTietJson %>;
        var giaHang = <%= GiaHangJson %>;

        function dinhDangTien(so) {
            return so.toLocaleString('vi-VN') + ' ₫';
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
                var maHang = select.value;

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
                    for (var j = 0; j < select.options.length; j++) {
                        if (select.options[j].value === d.MaHang) {
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
                    tr.querySelector('select').value = d.ma;
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
                    tr.innerHTML = '<td>' + escHtml(d.MaHang) + '</td>' +
                        '<td>' + escHtml(d.TenHang) + '</td>' +
                        '<td class="text-end">' + d.SoLuong.toLocaleString('vi-VN') + '</td>' +
                        '<td class="text-end">' + dinhDangTien(d.DonGia) + '</td>' +
                        '<td class="text-end">' + dinhDangTien(thanhTien) + '</td>';
                    body.appendChild(tr);
                });
                document.getElementById('ctTongCong').textContent = dinhDangTien(tong);
            });
        }
    </script>



</asp:Content>