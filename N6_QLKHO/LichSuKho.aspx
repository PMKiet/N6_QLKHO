<%@ Page Title="Lịch Sử Kho" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="LichSuKho.aspx.cs" Inherits="N6_QLKHO.LichSuKho" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .wms-shell {
            --wms-accent: #0284c7;
            --wms-accent-dark: #0369a1;
            --wms-accent-soft: #f0f9ff;
            --wms-slate-900: #0f172a;
            --wms-border: #e2e8f0;
        }
        .wms-topbar {
            background: #ffffff;
            border: 1px solid var(--wms-border);
            border-radius: 16px;
            padding: 20px 24px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        }
        .page-icon {
            width: 48px; height: 48px; border-radius: 12px;
            background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
            color: #ffffff;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.25rem; flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(2, 132, 199, 0.2);
        }
        .wms-card {
            background: #ffffff;
            border: 1px solid var(--wms-border);
            border-radius: 16px;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .wms-card-header {
            background: #ffffff;
            border-bottom: 1px solid #f1f5f9;
            padding: 16px 24px;
            display: flex; align-items: center; justify-content: space-between;
            gap: 12px; flex-wrap: wrap;
        }
        .section-title {
            font-size: 0.95rem; font-weight: 700; color: var(--wms-slate-900);
            margin: 0; display: flex; align-items: center; gap: 10px;
        }
        .section-title i {
            width: 28px; height: 28px; border-radius: 8px;
            background: var(--wms-accent-soft); color: var(--wms-accent);
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.8rem;
        }
        .form-label-wms {
            display: block;
            font-size: 0.76rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.4px; color: #475569; margin-bottom: 6px;
        }
        .wms-card .form-control {
            border-color: #cbd5e1;
            font-size: 0.9rem;
            height: 40px;
            padding: 0.4rem 0.75rem;
            border-radius: 8px;
        }
        .wms-card .form-control:focus {
            border-color: var(--wms-accent);
            box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.12);
        }
        .wms-card .btn-search { height: 40px; }

        /* ===== Bảng: GridView KHÔNG sinh <thead> nên style phải đặt trên th/td ===== */
        .table-custom { margin-bottom: 0; width: 100%; }
        .table-custom th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.72rem;
            letter-spacing: 0.5px;
            padding: 12px 16px;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
            vertical-align: middle;
        }
        .table-custom td {
            padding: 12px 16px;
            color: #1e293b;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }
        .table-custom td.col-nowrap { white-space: nowrap; }
        .table-custom tr:hover td { background-color: #f8fafc; }
        .chk-cell { width: 44px; text-align: center; }
        .chk-cell .form-check-input { margin: 0; cursor: pointer; width: 1.1rem; height: 1.1rem; }
        .row-actions { display: inline-flex; gap: 6px; justify-content: center; }
        .row-actions .btn { width: 34px; height: 34px; padding: 0; display: inline-flex; align-items: center; justify-content: center; }

        /* ===== Tabs: tab thường và tab đang chọn cùng chiều cao (không bị nhảy lệch) ===== */
        .wms-tabs { border-bottom: 0; background: #f8fafc; border-bottom: 1px solid var(--wms-border); flex-wrap: nowrap; overflow-x: auto; }
        .wms-tabs .nav-link {
            font-weight: 600; color: #64748b; border: 0;
            border-bottom: 3px solid transparent;
            margin-bottom: 0;
            padding: 12px 24px;
            border-radius: 0;
            white-space: nowrap;
        }
        .wms-tabs .nav-link:hover { color: var(--wms-accent-dark); }
        .wms-tabs .nav-link.active {
            color: var(--wms-accent-dark); background-color: #ffffff;
            border-bottom-color: var(--wms-accent);
        }

        .pay-badge { display: inline-block; padding: 4px 10px; border-radius: 999px; font-size: 0.75rem; font-weight: 600; white-space: nowrap; }
        .pay-badge.paid { background: #dcfce7; color: #166534; }
        .pay-badge.unpaid { background: #fef3c7; color: #92400e; }

        /* ===== IN PHIẾU (dùng chung: Phiếu nhập / Phiếu xuất / Lịch sử kho) ===== */
        @page { size: A4 portrait; margin: 0; } /* margin 0 => trình duyệt không chèn ngày giờ + URL ở đầu/cuối trang */
        @media print {
            html, body { height: auto !important; min-height: 0 !important; overflow: visible !important; margin: 0 !important; background: #fff !important; }
            /* Bỏ hẳn mọi thứ ngoài phiếu khỏi luồng in => không còn trang trắng thừa */
            body *:not(.phieu-in):not(.phieu-in *):not(:has(.phieu-in)):not(.print-zone):not(.print-zone *):not(:has(.print-zone)) { display: none !important; }
            .no-print { display: none !important; }

            .phieu-in {
                position: absolute; left: 0; top: 0; width: 100%; box-sizing: border-box;
                margin: 0 !important; padding: 14mm 14mm 12mm !important;
                background: #fff !important; border: 0 !important; border-radius: 0 !important; box-shadow: none !important;
                color: #111827 !important; font-size: 11pt;
                -webkit-print-color-adjust: exact; print-color-adjust: exact;
            }
            .phieu-in .card-body { padding: 0 !important; }
            .phieu-in .text-primary, .phieu-in .text-success { color: #111827 !important; }
            .phieu-in .bg-light { background: #fff !important; border: 1px solid #94a3b8 !important; border-radius: 6px !important; }
            .phieu-in .badge, .phieu-in .pay-badge { background: #fff !important; color: #111827 !important; border: 1px solid #475569 !important; }

            /* Bảng: không cuộn ngang, có viền rõ, tự xuống dòng */
            .phieu-in .table-responsive { overflow: visible !important; }
            .phieu-in table { width: 100% !important; border-collapse: collapse !important; font-size: 10pt; }
            .phieu-in th, .phieu-in td { border: 1px solid #475569 !important; padding: 5px 7px !important; background: transparent !important; color: #111827 !important; vertical-align: middle; }
            .phieu-in th { background: #e5e7eb !important; font-weight: 700; text-transform: none; }
            .phieu-in tr, .phieu-in .row.text-center { page-break-inside: avoid; break-inside: avoid; }
            .phieu-in .col-nowrap { white-space: nowrap; }
        }
        .phieu-in .sig-space { height: 80px; }

        /* ===== In DANH SÁCH (tab đang xem) ===== */
        .print-only { display: none; }
        @media print {
            .print-zone { position: absolute; left: 0; top: 0; width: 100%; margin: 0 !important; padding: 12mm !important; box-sizing: border-box; box-shadow: none !important; border: 0 !important; }
            .print-only { display: block !important; }
            .table-custom th { background: #e5e7eb !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .print-zone .pay-badge { border: 1px solid #475569; background: #fff !important; color: #111827 !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Thanh tiêu đề + công cụ xuất danh sách -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4 no-print">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
                <div>
                    <h4 class="fw-bold text-dark mb-0">Lịch Sử Giao Dịch Kho</h4>
                    <p class="text-muted small mb-0 mt-1">Tra cứu, quản lý trạng thái thanh toán, in và xuất file phiếu kho</p>
                </div>
            </div>

            <asp:Panel ID="pnlCongCu" runat="server" CssClass="d-flex flex-wrap align-items-center gap-2">
                <span id="selCount" class="small text-muted me-1">Chưa chọn phiếu (xuất tất cả)</span>
                <asp:LinkButton ID="btnXuatExcel" runat="server" CssClass="btn btn-outline-success btn-sm fw-semibold bg-white px-3 py-2 shadow-sm" OnClick="btnXuatExcel_Click" CausesValidation="false" ToolTip="Xuất các phiếu đã chọn (hoặc toàn bộ kết quả lọc nếu chưa chọn)"><i class="fa-solid fa-file-excel me-1"></i> Excel</asp:LinkButton>
                <asp:LinkButton ID="btnXuatWord" runat="server" CssClass="btn btn-outline-primary btn-sm fw-semibold bg-white px-3 py-2 shadow-sm" OnClick="btnXuatWord_Click" CausesValidation="false" ToolTip="Xuất các phiếu đã chọn (hoặc toàn bộ kết quả lọc nếu chưa chọn)"><i class="fa-solid fa-file-word me-1"></i> Word</asp:LinkButton>
                <button type="button" class="btn btn-outline-danger btn-sm fw-semibold bg-white px-3 py-2 shadow-sm" onclick="inDanhSach();" title="In / lưu PDF danh sách đang xem (chỉ các phiếu đã chọn nếu có chọn)"><i class="fa-solid fa-print me-1"></i> In danh sách</button>
            </asp:Panel>
        </div>

        <!-- Thông báo -->
        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block no-print" EnableViewState="false"></asp:Label>

        <!-- ================= CHẾ ĐỘ DANH SÁCH ================= -->
        <asp:Panel ID="pnlDanhSach" runat="server">

            <!-- Bộ lọc -->
            <div class="wms-card no-print">
                <div class="wms-card-header">
                    <h5 class="section-title">
                        <i class="fa-solid fa-filter"></i>
                        <span>Bộ Lọc Tra Cứu Dữ Liệu</span>
                    </h5>
                    <span class="text-muted small">Lọc theo thời gian &amp; từ khóa</span>
                </div>
                <div class="p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-md-6 col-lg-4">
                            <label class="form-label-wms">Từ khóa tìm kiếm</label>
                            <asp:TextBox ID="txtTuKhoa" runat="server" CssClass="form-control" placeholder="Mã phiếu, NCC, khách hàng, nhân viên..."></asp:TextBox>
                        </div>
                        <div class="col-6 col-md-3 col-lg-2">
                            <label class="form-label-wms">Từ ngày</label>
                            <asp:TextBox ID="txtTuNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-6 col-md-3 col-lg-2">
                            <label class="form-label-wms">Đến ngày</label>
                            <asp:TextBox ID="txtDenNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-12 col-lg-4 d-grid">
                            <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary btn-search fw-bold shadow-sm" OnClick="btnTimKiem_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs + bảng dữ liệu (vùng này cũng là vùng "In danh sách") -->
            <div class="wms-card print-zone">
                <div class="print-only text-center p-3">
                    <h3 class="fw-bold mb-1">LỊCH SỬ GIAO DỊCH KHO</h3>
                    <div class="small fst-italic">In lúc <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                </div>

                <ul class="nav nav-tabs wms-tabs m-0 no-print" id="khoTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="nhap-tab" data-bs-toggle="tab" data-bs-target="#nhap-content" type="button" role="tab" aria-controls="nhap-content" aria-selected="true">
                            <i class="fa-solid fa-file-arrow-down text-success me-2"></i>Lịch Sử Nhập Kho
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="xuat-tab" data-bs-toggle="tab" data-bs-target="#xuat-content" type="button" role="tab" aria-controls="xuat-content" aria-selected="false">
                            <i class="fa-solid fa-file-arrow-up text-primary me-2"></i>Lịch Sử Xuất Kho
                        </button>
                    </li>
                </ul>
                <asp:HiddenField ID="hfTab" runat="server" Value="nhap" />

                <div class="tab-content" id="khoTabsContent">

                    <!-- Tab 1: Nhập kho -->
                    <div class="tab-pane fade show active" id="nhap-content" role="tabpanel" aria-labelledby="nhap-tab">
                        <div class="table-responsive">
                            <asp:GridView ID="gvPhieuNhap" runat="server" CssClass="table table-custom align-middle" AutoGenerateColumns="false" GridLines="None" EmptyDataText="Không tìm thấy phiếu nhập kho phù hợp." OnRowCommand="gvPhieuNhap_RowCommand">
                                <EmptyDataRowStyle CssClass="text-center text-muted py-5" />
                                <Columns>
                                    <asp:TemplateField ItemStyle-CssClass="chk-cell no-print" HeaderStyle-CssClass="chk-cell no-print">
                                        <HeaderTemplate>
                                            <input type="checkbox" class="form-check-input" onclick="chonTatCa(this);" title="Chọn / bỏ chọn tất cả" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <input type="checkbox" class="form-check-input chk-row" name="chkNhap" value='<%# HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("MaPhieu"))) %>' title="Chọn phiếu này" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MaPhieu" HeaderText="Mã Phiếu" ItemStyle-CssClass="fw-semibold col-nowrap" />
                                    <asp:BoundField DataField="Ngay" HeaderText="Ngày Nhập" DataFormatString="{0:dd/MM/yyyy HH:mm}" ItemStyle-CssClass="col-nowrap" />
                                    <asp:BoundField DataField="DoiTac" HeaderText="Nhà Cung Cấp" />
                                    <asp:BoundField DataField="NhanVien" HeaderText="Nhân Viên Lập" />
                                    <asp:TemplateField HeaderText="Thanh Toán">
                                        <ItemTemplate>
                                            <span class='pay-badge <%# Convert.ToString(Eval("TrangThaiThanhToan")) == "Đã thanh toán" ? "paid" : "unpaid" %>'><%# Server.HtmlEncode(Convert.ToString(Eval("TrangThaiThanhToan"))) %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-CssClass="fw-bold text-success col-nowrap" />
                                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-CssClass="no-print" HeaderStyle-CssClass="no-print">
                                        <ItemTemplate>
                                            <div class="row-actions">
                                                <asp:LinkButton ID="btnInNhap" runat="server" CssClass="btn btn-light text-primary border shadow-sm" CommandName="InPhieuNhap" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Xem chi tiết &amp; in phiếu">
                                                    <i class="fa-solid fa-print"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDoiTrangThaiNhap" runat="server" CssClass="btn btn-light text-warning border shadow-sm" CommandName="DoiTrangThaiNhap" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Đổi trạng thái thanh toán">
                                                    <i class="fa-solid fa-rotate"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnXoaNhap" runat="server" CssClass="btn btn-light text-danger border shadow-sm" CommandName="XoaPhieuNhap" CommandArgument='<%# Eval("MaPhieu") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa phiếu nhập này?');" ToolTip="Xóa phiếu">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- Tab 2: Xuất kho -->
                    <div class="tab-pane fade" id="xuat-content" role="tabpanel" aria-labelledby="xuat-tab">
                        <div class="table-responsive">
                            <asp:GridView ID="gvPhieuXuat" runat="server" CssClass="table table-custom align-middle" AutoGenerateColumns="false" GridLines="None" EmptyDataText="Không tìm thấy phiếu xuất kho phù hợp." OnRowCommand="gvPhieuXuat_RowCommand">
                                <EmptyDataRowStyle CssClass="text-center text-muted py-5" />
                                <Columns>
                                    <asp:TemplateField ItemStyle-CssClass="chk-cell no-print" HeaderStyle-CssClass="chk-cell no-print">
                                        <HeaderTemplate>
                                            <input type="checkbox" class="form-check-input" onclick="chonTatCa(this);" title="Chọn / bỏ chọn tất cả" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <input type="checkbox" class="form-check-input chk-row" name="chkXuat" value='<%# HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("MaPhieu"))) %>' title="Chọn phiếu này" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MaPhieu" HeaderText="Mã Phiếu" ItemStyle-CssClass="fw-semibold col-nowrap" />
                                    <asp:BoundField DataField="Ngay" HeaderText="Ngày Xuất" DataFormatString="{0:dd/MM/yyyy HH:mm}" ItemStyle-CssClass="col-nowrap" />
                                    <asp:BoundField DataField="DoiTac" HeaderText="Khách Hàng / Đơn Hàng" />
                                    <asp:BoundField DataField="NhanVien" HeaderText="Nhân Viên Lập" />
                                    <asp:TemplateField HeaderText="Thanh Toán">
                                        <ItemTemplate>
                                            <span class='pay-badge <%# Convert.ToString(Eval("TrangThaiThanhToan")) == "Đã thanh toán" ? "paid" : "unpaid" %>'><%# Server.HtmlEncode(Convert.ToString(Eval("TrangThaiThanhToan"))) %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-CssClass="fw-bold text-primary col-nowrap" />
                                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-CssClass="no-print" HeaderStyle-CssClass="no-print">
                                        <ItemTemplate>
                                            <div class="row-actions">
                                                <asp:LinkButton ID="btnInXuat" runat="server" CssClass="btn btn-light text-primary border shadow-sm" CommandName="InPhieuXuat" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Xem chi tiết &amp; in phiếu">
                                                    <i class="fa-solid fa-print"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDoiTrangThaiXuat" runat="server" CssClass="btn btn-light text-warning border shadow-sm" CommandName="DoiTrangThaiXuat" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Đổi trạng thái thanh toán">
                                                    <i class="fa-solid fa-rotate"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnXoaXuat" runat="server" CssClass="btn btn-light text-danger border shadow-sm" CommandName="XoaPhieuXuat" CommandArgument='<%# Eval("MaPhieu") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa phiếu xuất này?');" ToolTip="Xóa phiếu">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                </div>
            </div>
        </asp:Panel>

        <!-- ================= CHẾ ĐỘ CHI TIẾT PHIẾU (xem + in + xuất file) ================= -->
        <asp:Panel ID="pnlChiTiet" runat="server" Style="display:none">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3 no-print">
                <asp:LinkButton ID="btnQuayLai" runat="server" CssClass="btn btn-outline-secondary fw-semibold" OnClick="btnQuayLai_Click" CausesValidation="false"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách</asp:LinkButton>
                <div class="d-flex flex-wrap gap-2">
                    <asp:LinkButton ID="btnXuatExcelPhieu" runat="server" CssClass="btn btn-outline-success fw-semibold" OnClick="btnXuatExcelPhieu_Click" CausesValidation="false"><i class="fa-solid fa-file-excel me-1"></i> Excel</asp:LinkButton>
                    <asp:LinkButton ID="btnXuatWordPhieu" runat="server" CssClass="btn btn-outline-primary fw-semibold" OnClick="btnXuatWordPhieu_Click" CausesValidation="false"><i class="fa-solid fa-file-word me-1"></i> Word</asp:LinkButton>
                    <button type="button" class="btn btn-danger fw-semibold" onclick="window.print();"><i class="fa-solid fa-print me-1"></i> In / Lưu PDF</button>
                </div>
            </div>

            <asp:Literal ID="litPhieu" runat="server"></asp:Literal>
        </asp:Panel>

    </div>

    <script>
        (function () {
            var hfTab = document.getElementById('<%= hfTab.ClientID %>');

            // Đếm số phiếu đã tick (cả hai tab)
            function capNhatSoChon() {
                var n = document.querySelectorAll('.chk-row:checked').length;
                var el = document.getElementById('selCount');
                if (!el) return;
                el.textContent = n > 0 ? ('Đã chọn ' + n + ' phiếu') : 'Chưa chọn phiếu (xuất tất cả)';
                el.className = 'small me-1 ' + (n > 0 ? 'text-primary fw-semibold' : 'text-muted');
            }

            window.chonTatCa = function (header) {
                var table = header.closest('table');
                if (!table) return;
                table.querySelectorAll('.chk-row').forEach(function (c) { c.checked = header.checked; });
                capNhatSoChon();
            };

            document.addEventListener('change', function (e) {
                if (e.target.classList && e.target.classList.contains('chk-row')) capNhatSoChon();
            });

            // In danh sách của tab đang xem; nếu có tick phiếu thì chỉ in các phiếu đã tick
            window.inDanhSach = function () {
                var pane = document.querySelector('#khoTabsContent .tab-pane.active');
                var daAn = [];
                if (pane && pane.querySelectorAll('.chk-row:checked').length > 0) {
                    pane.querySelectorAll('.chk-row').forEach(function (c) {
                        if (!c.checked) { var tr = c.closest('tr'); tr.classList.add('d-none'); daAn.push(tr); }
                    });
                }
                window.onafterprint = function () {
                    daAn.forEach(function (tr) { tr.classList.remove('d-none'); });
                    window.onafterprint = null;
                };
                window.print();
            };

            // Nhớ tab đang xem qua các lần postback (tránh tự nhảy về tab Nhập)
            document.querySelectorAll('#khoTabs button[data-bs-toggle="tab"]').forEach(function (b) {
                b.addEventListener('shown.bs.tab', function () {
                    hfTab.value = (b.id === 'xuat-tab') ? 'xuat' : 'nhap';
                });
            });
            window.addEventListener('load', function () {
                if (hfTab.value === 'xuat' && window.bootstrap) {
                    var b = document.getElementById('xuat-tab');
                    if (b) bootstrap.Tab.getOrCreateInstance(b).show();
                }
                capNhatSoChon();
            });
        })();
    </script>
</asp:Content>
