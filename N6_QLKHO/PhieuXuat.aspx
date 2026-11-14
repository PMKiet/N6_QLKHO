<%@ Page Title="Lập Phiếu Xuất Kho" Language="C#" MasterPageFile="~/Site.Master" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" AutoEventWireup="true" CodeBehind="PhieuXuat.aspx.cs" Inherits="N6_QLKHO.PhieuXuat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Thanh tiêu đề kiểu ERP hiện đại -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4 no-print">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon"><i class="fa-solid fa-file-invoice-dollar"></i></div>
                <div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h4 class="page-title mb-0">Lập Phiếu Xuất Kho</h4>
                        <span class="badge badge-soft-primary">Mẫu 02-VT</span>
                    </div>
                    <p class="page-subtitle mt-1">Tạo phiếu xuất theo đơn hàng hoặc xuất trực tiếp &bull; Trừ tồn kho tự động theo nguyên tắc FEFO</p>
                </div>
            </div>
            <div class="wms-stepper">
                <span class="wms-step-dot wms-step-active">1</span>
                <span class="text-dark">Kê khai hàng xuất</span>
                <i class="fa-solid fa-chevron-right text-muted small"></i>
                <span class="wms-step-dot wms-step-muted">2</span>
                <span class="text-muted">Xem trước &amp; Xuất kho</span>
            </div>
        </div>

        <!-- Thông báo từ server và trình duyệt -->
        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block no-print" EnableViewState="false"></asp:Label>
        <div id="clientErr" class="no-print"></div>

        <!-- ===== BƯỚC 1: NHẬP THÔNG TIN ===== -->
        <asp:Panel ID="pnlNhapLieu" runat="server">

            <!-- KHUNG THÔNG TIN CHUNG -->
            <div class="wms-card mb-4">
                <div class="wms-card-header">
                    <h5 class="section-title">
                        <i class="fa-solid fa-file-invoice-dollar"></i>
                        <span>Thông Tin Chứng Từ Xuất Kho</span>
                    </h5>
                    <span class="text-muted small"><span class="text-danger">*</span> Trường bắt buộc</span>
                </div>
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label-wms">Mã Phiếu Xuất <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-barcode"></i></span>
                                <asp:TextBox ID="txtMaPhieuXuat" runat="server" CssClass="form-control fw-bold" MaxLength="10" Placeholder="VD: PX01"></asp:TextBox>
                            </div>
                            <div class="form-text small">Tối đa 10 ký tự: chữ, số, dấu - hoặc _</div>
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label-wms">Ngày Xuất Kho <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-regular fa-calendar-check"></i></span>
                                <asp:TextBox ID="txtNgayXuat" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                            <div class="form-text small">Không được chọn ngày trong tương lai</div>
                        </div>
                        <div class="col-12 col-md-4">
                            <label class="form-label-wms">Đơn Đặt Hàng Liên Kết</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-clipboard-list"></i></span>
                                <asp:DropDownList ID="ddlDonHang" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="-- Xuất trực tiếp (không theo đơn) --" Value="" />
                                </asp:DropDownList>
                            </div>
                            <div class="form-text small">Chỉ hiện các đơn chưa lập phiếu xuất</div>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label-wms">Nhân Viên Lập Phiếu</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-user-shield"></i></span>
                                <asp:TextBox ID="txtNhanVien" runat="server" CssClass="form-control readonly-user" ReadOnly="true"></asp:TextBox>
                            </div>
                            <div class="form-text small">Tự động ghi nhận theo tài khoản phiên làm việc</div>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label-wms">Trạng Thái Thanh Toán <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fa-solid fa-credit-card"></i></span>
                                <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Đã thanh toán" Value="Đã thanh toán" />
                                    <asp:ListItem Text="Chưa thanh toán" Value="Chưa thanh toán" />
                                </asp:DropDownList>
                            </div>
                            <div class="form-text small">Xác nhận tình trạng thu tiền đơn xuất</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- KHU VỰC CHI TIẾT HÀNG XUẤT -->
            <div class="wms-card mb-4">
                <div class="wms-card-header">
                    <h5 class="section-title">
                        <i class="fa-solid fa-dolly"></i>
                        <span>Bảng Kê Chi Tiết Hàng Xuất Kho</span>
                    </h5>
                    <span class="badge badge-soft-secondary">Đơn giá tối thiểu: 1.000 VND</span>
                </div>
                <div class="card-body p-4">
                    <!-- Thanh thêm nhanh dòng hàng -->
                    <div class="entry-toolbar mb-4">
                        <div class="row g-3 align-items-start">
                            <div class="col-12 col-lg-5">
                                <label class="form-label-wms">Mặt Hàng Xuất <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlHangHoa" runat="server" CssClass="form-select" onchange="chonHang()">
                                    <asp:ListItem Text="-- Chọn hàng hóa cần xuất --" Value="" />
                                </asp:DropDownList>
                                <div class="form-text small">Hiển thị tồn khả dụng chưa hết hạn</div>
                            </div>
                            <div class="col-6 col-lg-2">
                                <label class="form-label-wms">Số Lượng <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtSoLuongXuat" runat="server" CssClass="form-control text-end fw-semibold" TextMode="Number" min="1" max="1000000" step="1" Placeholder="VD: 5"></asp:TextBox>
                                    <span class="input-group-text">SP</span>
                                </div>
                                <div class="form-text small">Số nguyên &ge; 1</div>
                            </div>
                            <div class="col-6 col-lg-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <label class="form-label-wms mb-1">Đơn Giá Xuất <span class="text-danger">*</span></label>
                                    <div class="d-flex gap-1 mb-1">
                                        <button type="button" class="quick-price-pill" onclick="nhanNhanhGia(1000)" title="Nhân 1.000 VND">&times;1k</button>
                                        <button type="button" class="quick-price-pill" onclick="nhanNhanhGia(10000)" title="Nhân 10.000 VND">&times;10k</button>
                                    </div>
                                </div>
                                <div class="input-group">
                                    <asp:TextBox ID="txtDonGiaXuat" runat="server" CssClass="form-control text-end fw-semibold" TextMode="Number" min="1000" max="1000000000" step="500" Placeholder="VD: 30000"></asp:TextBox>
                                    <span class="input-group-text currency-suffix">VND</span>
                                </div>
                                <div id="lblGiaPreview" class="form-text small text-primary fw-semibold">Tối thiểu 1.000 VND (tự điền khi chọn hàng)</div>
                            </div>
                            <div class="col-12 col-lg-2 d-grid">
                                <label class="form-label-wms d-none d-lg-block">&nbsp;</label>
                                <asp:Button ID="btnThemDong" runat="server" Text="+ Thêm dòng" CssClass="btn btn-primary fw-bold py-2 shadow-sm" OnClick="btnThemDong_Click" OnClientClick="return kiemTraDong();" />
                            </div>
                        </div>
                    </div>

                    <!-- Bảng danh sách tạm -->
                    <div class="table-responsive border rounded-3">
                        <asp:GridView ID="gvChiTietPhieuXuat" runat="server" CssClass="table table-custom table-hover align-middle mb-0" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvChiTietPhieuXuat_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="STT" ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap tabular-nums">
                                    <ItemTemplate>
                                        <span class="text-muted fw-semibold tabular-nums"><%# Container.DataItemIndex + 1 %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Mã Hàng" ItemStyle-Width="130px" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                    <ItemTemplate>
                                        <span class="sku-badge"><%# Server.HtmlEncode(Convert.ToString(Eval("MaHangHoa"))) %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tên Hàng Hóa">
                                    <ItemTemplate>
                                        <span class="fw-semibold text-dark"><%# Server.HtmlEncode(Convert.ToString(Eval("TenHangHoa"))) %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="SoLuongXuat" HeaderText="Số Lượng" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end fw-semibold col-nowrap tabular-nums" />
                                <asp:BoundField DataField="DonGiaXuat" HeaderText="Đơn Giá (VND)" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end col-nowrap tabular-nums" />
                                <asp:BoundField DataField="ThanhTien" HeaderText="Thành Tiền (VND)" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end fw-bold text-primary col-nowrap tabular-nums" />
                                <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnXoaDong" runat="server" CommandName="XoaDong" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn-action-icon delete" title="Xóa dòng" OnClientClick="return confirm('Xóa dòng hàng này khỏi phiếu xuất?');">
                                            <i class="fa-regular fa-trash-can"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="empty-state">
                                    <div class="empty-state-icon"><i class="fa-solid fa-basket-shopping"></i></div>
                                    <div class="fw-semibold text-dark">Chưa có dòng hàng hóa nào trong phiếu</div>
                                    <p class="small mb-0 mt-1">Chọn mặt hàng, nhập số lượng và đơn giá (tối thiểu 1.000 VND) rồi bấm <strong>+ Thêm dòng</strong>.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>

                    <asp:Literal ID="litTongTamTinh" runat="server"></asp:Literal>
                </div>
            </div>

            <!-- NÚT XEM TRƯỚC -->
            <div class="d-flex justify-content-end mb-4">
                <asp:Button ID="btnXemTruoc" runat="server" Text="Tiếp tục: Xem trước phiếu xuất →" CssClass="btn btn-primary btn-lg px-5 shadow-sm fw-bold" OnClick="btnXemTruoc_Click" />
            </div>

        </asp:Panel>

        <!-- ===== BƯỚC 2: XEM TRƯỚC VÀ XÁC NHẬN ===== -->
        <asp:Panel ID="pnlXemTruoc" runat="server" Style="display:none">
            <div class="alert alert-primary border-primary border-opacity-25 d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4 no-print" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fa-solid fa-eye fs-5 me-2"></i>
                    <div>Chế độ <strong>Xem trước chứng từ</strong>. Kiểm tra kỹ đơn giá (VND) và số lượng trước khi bấm <strong>Xác nhận lập phiếu xuất</strong>.</div>
                </div>
                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="btn btn-outline-danger btn-sm fw-semibold bg-white" onclick="window.print();">
                        <i class="fa-solid fa-file-pdf me-1"></i> In / Xuất PDF
                    </button>
                    <asp:LinkButton ID="btnXuatExcel" runat="server" CssClass="btn btn-outline-success btn-sm fw-semibold bg-white" OnClick="btnXuatExcel_Click" CausesValidation="false">
                        <i class="fa-solid fa-file-excel me-1"></i> Xuất Excel
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnXuatWord" runat="server" CssClass="btn btn-outline-primary btn-sm fw-semibold bg-white" OnClick="btnXuatWord_Click" CausesValidation="false">
                        <i class="fa-solid fa-file-word me-1"></i> Xuất Word
                    </asp:LinkButton>
                </div>
            </div>

            <!-- Vùng nội dung phiếu chuẩn để xem trước & In/PDF -->
            <div id="vungInPhieuXuat" class="phieu-in wms-card mb-4 bg-white">
                <div class="card-body p-4 p-md-5">
                    <div class="row border-bottom pb-3 mb-4 align-items-center">
                        <div class="col-7">
                            <div class="fw-bold text-uppercase text-primary fs-6">HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHO)</div>
                            <div class="text-muted small">Bộ phận Kho vận &amp; Xuất hàng</div>
                        </div>
                        <div class="col-5 text-end">
                            <div class="fw-bold small">Mẫu số: 02 - VT</div>
                            <div class="text-muted small">Ngày in: <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                        </div>
                    </div>

                    <div class="text-center mb-4">
                        <h4 class="fw-bold text-uppercase text-dark mb-1">PHIẾU XUẤT KHO</h4>
                        <div class="text-muted small">Số phiếu: <strong><asp:Literal ID="litMaPhieuHeader" runat="server"></asp:Literal></strong></div>
                    </div>

                    <div class="bg-light rounded-3 p-3 mb-4 border">
                        <asp:Literal ID="litThongTinXemTruoc" runat="server"></asp:Literal>
                    </div>

                    <div class="table-responsive">
                        <asp:GridView ID="gvXemTruoc" runat="server" CssClass="table table-bordered table-custom mb-0 align-middle" AutoGenerateColumns="false" GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="STT" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-nowrap" ItemStyle-CssClass="text-center col-nowrap tabular-nums">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="MaHangHoa" HeaderText="Mã Hàng" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap fw-semibold" />
                                <asp:BoundField DataField="TenHangHoa" HeaderText="Tên Hàng Hóa" />
                                <asp:BoundField DataField="SoLuongXuat" HeaderText="Số Lượng" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end col-nowrap tabular-nums" />
                                <asp:BoundField DataField="DonGiaXuat" HeaderText="Đơn Giá (VND)" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end col-nowrap tabular-nums" />
                                <asp:BoundField DataField="ThanhTien" HeaderText="Thành Tiền (VND)" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end fw-semibold col-nowrap tabular-nums" />
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="d-flex justify-content-end align-items-center gap-3 mt-3 pt-3 border-top">
                        <span class="text-secondary fw-semibold">Tổng tiền thanh toán:</span>
                        <span class="fs-4 fw-bold text-primary tabular-nums"><asp:Literal ID="litTongTienXemTruoc" runat="server"></asp:Literal></span>
                    </div>

                    <div class="row text-center mt-5 pt-3">
                        <div class="col-4">
                            <div class="fw-bold small">Người lập phiếu</div>
                            <div class="text-muted fst-italic small">(Ký, họ tên)</div>
                            <div class="sig-space"></div>
                            <div class="fw-semibold small"><asp:Literal ID="litChuKyNguoiLap" runat="server"></asp:Literal></div>
                        </div>
                        <div class="col-4">
                            <div class="fw-bold small">Người nhận hàng</div>
                            <div class="text-muted fst-italic small">(Ký, họ tên)</div>
                        </div>
                        <div class="col-4">
                            <div class="fw-bold small">Thủ kho / Kế toán</div>
                            <div class="text-muted fst-italic small">(Ký, họ tên)</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mb-4 no-print">
                <asp:Button ID="btnQuayLai" runat="server" Text="← Quay lại chỉnh sửa" CssClass="btn btn-outline-secondary btn-lg px-4 fw-semibold" OnClick="btnQuayLai_Click" CausesValidation="false" />
                <asp:Button ID="btnLuuPhieuXuat" runat="server" Text="Xác nhận lập phiếu xuất" CssClass="btn btn-primary btn-lg px-5 shadow-sm fw-bold" OnClick="btnLuuPhieuXuat_Click" UseSubmitBehavior="false" OnClientClick="this.disabled = true; this.value = 'Đang lưu...';" />
            </div>
        </asp:Panel>

    </div>

    <script>
        (function () {
            var ID_SL = '<%= txtSoLuongXuat.ClientID %>';
            var ID_GIA = '<%= txtDonGiaXuat.ClientID %>';
            var ID_HH = '<%= ddlHangHoa.ClientID %>';
            var DON_GIA_TOI_THIEU = 1000;
            var DON_GIA_TOI_DA = 1000000000;

            function $(id) { return document.getElementById(id); }

            function dinhDangVND(n) {
                return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' VND';
            }

            function capNhatPreviewGia() {
                var elGia = $(ID_GIA);
                var lbl = $('lblGiaPreview');
                if (!elGia || !lbl) return;
                var val = parseFloat(elGia.value);
                if (isNaN(val) || val <= 0) {
                    lbl.className = 'form-text small text-muted';
                    lbl.textContent = 'Tối thiểu 1.000 VND (tự điền khi chọn hàng)';
                } else if (val < DON_GIA_TOI_THIEU) {
                    lbl.className = 'form-text small text-danger fw-semibold';
                    lbl.textContent = 'Chưa hợp lệ (< 1.000 VND). Bấm ×1k nếu muốn nhập ' + dinhDangVND(val * 1000);
                } else {
                    lbl.className = 'form-text small text-primary fw-semibold';
                    lbl.textContent = 'Đơn giá: ' + dinhDangVND(val);
                }
            }

            function chan(el, bannedKeys, pasteRegex) {
                if (!el) return;
                el.addEventListener('keydown', function (e) {
                    if (bannedKeys.indexOf(e.key) >= 0) e.preventDefault();
                });
                el.addEventListener('paste', function (e) {
                    var t = (e.clipboardData || window.clipboardData).getData('text');
                    if (!pasteRegex.test(t.trim())) e.preventDefault();
                });
                el.addEventListener('wheel', function () { el.blur(); });
            }

            chan($(ID_SL), ['-', '+', 'e', 'E', '.', ','], /^[0-9]+$/);
            chan($(ID_GIA), ['-', '+', 'e', 'E', '.', ','], /^[0-9]+$/);

            if ($(ID_GIA)) {
                $(ID_GIA).addEventListener('input', capNhatPreviewGia);
            }

            window.nhanNhanhGia = function (heSo) {
                var elGia = $(ID_GIA);
                if (!elGia) return;
                var v = parseInt(elGia.value, 10);
                if (isNaN(v) || v <= 0) v = 1;
                var kq = v * heSo;
                if (kq > DON_GIA_TOI_DA) kq = DON_GIA_TOI_DA;
                elGia.value = kq;
                capNhatPreviewGia();
            };

            function hienLoi(msg, el) {
                var box = $('clientErr');
                box.innerHTML = '';
                [ID_SL, ID_GIA, ID_HH].forEach(function (id) {
                    var x = $(id);
                    if (x) x.classList.remove('is-invalid');
                });
                var d = document.createElement('div');
                d.className = 'alert alert-warning d-flex align-items-start shadow-sm';
                d.innerHTML = '<i class="fa-solid fa-triangle-exclamation me-2 mt-1"></i>';
                var s = document.createElement('div');
                s.textContent = msg;
                d.appendChild(s);
                box.appendChild(d);
                if (el) { el.classList.add('is-invalid'); el.focus(); }
                return false;
            }

            window.kiemTraDong = function () {
                $('clientErr').innerHTML = '';
                var hh = $(ID_HH), sl = $(ID_SL), gia = $(ID_GIA);
                if (!hh.value) return hienLoi('Vui lòng chọn hàng hóa cần xuất kho.', hh);

                var slText = sl.value.trim();
                if (!/^[0-9]+$/.test(slText) || parseInt(slText, 10) < 1)
                    return hienLoi('Số lượng phải là số nguyên dương (từ 1 trở lên).', sl);
                if (parseInt(slText, 10) > 1000000)
                    return hienLoi('Số lượng tối đa mỗi dòng là 1.000.000.', sl);

                var giaText = gia.value.trim();
                if (!/^[0-9]+$/.test(giaText) || parseInt(giaText, 10) < DON_GIA_TOI_THIEU)
                    return hienLoi('Đơn giá xuất không hợp lệ! Vui lòng nhập số nguyên từ 1.000 VND trở lên (không nhập 1, 2...).', gia);
                if (parseInt(giaText, 10) > DON_GIA_TOI_DA)
                    return hienLoi('Đơn giá tối đa là 1.000.000.000 VND.', gia);

                return true;
            };

            window.chonHang = function () {
                var ma = $(ID_HH).value ? $(ID_HH).value.trim() : '';
                if (ma && typeof giaMacDinh !== 'undefined' && giaMacDinh[ma] !== undefined) {
                    $(ID_GIA).value = giaMacDinh[ma];
                    capNhatPreviewGia();
                } else if (!ma) {
                    $(ID_GIA).value = '';
                    capNhatPreviewGia();
                }
            };
        })();
    </script>

</asp:Content>
