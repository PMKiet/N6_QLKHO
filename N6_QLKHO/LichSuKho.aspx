<<<<<<< HEAD
﻿<%@ Page Title="Lịch Sử Giao Dịch Kho" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LichSuKho.aspx.cs" Inherits="N6_QLKHO.LichSuKho" %>
=======
<%@ Page Title="Lịch Sử Giao Dịch Kho" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LichSuKho.aspx.cs" Inherits="N6_QLKHO.LichSuKho" %>
>>>>>>> 2f494f6126390a3afe0f0cdd07a1230de99fe24d

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="wms-shell">

        <!-- Thanh tiêu đề + công cụ xuất danh sách -->
        <div class="wms-topbar d-flex flex-wrap justify-content-between align-items-center gap-3 no-print">
            <div class="d-flex align-items-center gap-3">
                <div class="page-icon">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
                <div>
                    <h1 class="page-title mb-1">Lịch Sử Giao Dịch Kho</h1>
                    <p class="page-subtitle">Tra cứu, quản lý trạng thái thanh toán, in và xuất file phiếu nhập / xuất kho</p>
                </div>
            </div>

            <asp:Panel ID="pnlCongCu" runat="server" CssClass="d-flex flex-wrap align-items-center gap-2">
                <span id="selCount" class="small text-muted me-1">Chưa chọn phiếu (xuất tất cả)</span>
                <asp:LinkButton ID="btnXuatExcel" runat="server" CssClass="btn btn-outline-success btn-sm fw-semibold bg-white px-3 py-2 shadow-xs" OnClick="btnXuatExcel_Click" CausesValidation="false" ToolTip="Xuất các phiếu đã chọn (hoặc toàn bộ kết quả lọc nếu chưa chọn)">
                    <i class="fa-solid fa-file-excel me-1"></i> Excel
                </asp:LinkButton>
                <asp:LinkButton ID="btnXuatWord" runat="server" CssClass="btn btn-outline-primary btn-sm fw-semibold bg-white px-3 py-2 shadow-xs" OnClick="btnXuatWord_Click" CausesValidation="false" ToolTip="Xuất các phiếu đã chọn (hoặc toàn bộ kết quả lọc nếu chưa chọn)">
                    <i class="fa-solid fa-file-word me-1"></i> Word
                </asp:LinkButton>
                <button type="button" class="btn btn-outline-danger btn-sm fw-semibold bg-white px-3 py-2 shadow-xs" onclick="inDanhSach();" title="In / lưu PDF danh sách đang xem (chỉ các phiếu đã chọn nếu có chọn)">
                    <i class="fa-solid fa-print me-1"></i> In danh sách
                </button>
            </asp:Panel>
        </div>

        <!-- Thông báo -->
        <asp:Label ID="lblThongBao" runat="server" CssClass="d-block no-print" EnableViewState="false"></asp:Label>

        <!-- ================= CHẾ ĐỘ DANH SÁCH ================= -->
        <asp:Panel ID="pnlDanhSach" runat="server">

            <!-- Bộ lọc -->
            <div class="wms-card no-print">
                <div class="wms-card-header">
                    <h2 class="section-title">
                        <i class="fa-solid fa-filter"></i>
                        <span>Bộ Lọc Tra Cứu Dữ Liệu</span>
                    </h2>
                    <span class="text-muted small">Lọc theo thời gian &amp; từ khóa</span>
                </div>
                <div class="p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-md-6 col-lg-5">
                            <label for="txtTuKhoa" class="form-label-wms">Từ khóa tìm kiếm</label>
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                <asp:TextBox ID="txtTuKhoa" runat="server" CssClass="form-control" placeholder="Mã phiếu, nhà cung cấp, khách hàng, nhân viên..."></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-6 col-md-3 col-lg-2">
                            <label for="txtTuNgay" class="form-label-wms">Từ ngày</label>
                            <asp:TextBox ID="txtTuNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-6 col-md-3 col-lg-2">
                            <label for="txtDenNgay" class="form-label-wms">Đến ngày</label>
                            <asp:TextBox ID="txtDenNgay" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-12 col-lg-3 d-grid">
                            <asp:Button ID="btnTimKiem" runat="server" Text="Tìm kiếm dữ liệu" CssClass="btn btn-primary btn-search fw-semibold shadow-sm" OnClick="btnTimKiem_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs + bảng dữ liệu (vùng này cũng là vùng "In danh sách") -->
            <div class="wms-card print-zone mb-0">
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
                            <asp:GridView ID="gvPhieuNhap" runat="server" CssClass="table table-custom align-middle mb-0" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvPhieuNhap_RowCommand">
                                <Columns>
                                    <asp:TemplateField ItemStyle-CssClass="chk-cell text-center no-print" HeaderStyle-CssClass="chk-cell text-center no-print">
                                        <HeaderTemplate>
                                            <input type="checkbox" class="form-check-input" onclick="chonTatCa(this);" title="Chọn / bỏ chọn tất cả" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <input type="checkbox" class="form-check-input chk-row" name="chkNhap" value='<%# HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("MaPhieu"))) %>' title="Chọn phiếu này" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MaPhieu" HeaderText="Mã Phiếu" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="fw-semibold col-nowrap" />
                                    <asp:BoundField DataField="Ngay" HeaderText="Ngày Nhập" DataFormatString="{0:dd/MM/yyyy HH:mm}" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap text-secondary tabular-nums" />
                                    <asp:BoundField DataField="DoiTac" HeaderText="Nhà Cung Cấp" ItemStyle-CssClass="fw-medium" />
                                    <asp:BoundField DataField="NhanVien" HeaderText="Nhân Viên Lập" />
                                    <asp:TemplateField HeaderText="Thanh Toán" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                        <ItemTemplate>
                                            <span class='pay-badge <%# Convert.ToString(Eval("TrangThaiThanhToan")) == "Đã thanh toán" ? "paid" : "unpaid" %>'><%# Server.HtmlEncode(Convert.ToString(Eval("TrangThaiThanhToan"))) %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end fw-bold text-success col-nowrap tabular-nums" />
                                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-CssClass="text-center col-nowrap no-print" HeaderStyle-CssClass="text-center col-nowrap no-print">
                                        <ItemTemplate>
                                            <div class="row-actions">
                                                <asp:LinkButton ID="btnInNhap" runat="server" CssClass="btn btn-light text-primary border shadow-xs" CommandName="InPhieuNhap" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Xem chi tiết &amp; in phiếu">
                                                    <i class="fa-solid fa-print"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDoiTrangThaiNhap" runat="server" CssClass="btn btn-light text-warning border shadow-xs" CommandName="DoiTrangThaiNhap" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Đổi trạng thái thanh toán">
                                                    <i class="fa-solid fa-rotate"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnXoaNhap" runat="server" CssClass="btn btn-light text-danger border shadow-xs" CommandName="XoaPhieuNhap" CommandArgument='<%# Eval("MaPhieu") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa phiếu nhập này?');" ToolTip="Xóa phiếu">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fa-solid fa-file-circle-xmark"></i>
                                        </div>
                                        <h6 class="fw-bold text-dark mb-1">Không tìm thấy phiếu nhập kho phù hợp</h6>
                                        <p class="small text-muted mb-0">Hãy thử thay đổi từ khóa hoặc khoảng thời gian lọc.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- Tab 2: Xuất kho -->
                    <div class="tab-pane fade" id="xuat-content" role="tabpanel" aria-labelledby="xuat-tab">
                        <div class="table-responsive">
                            <asp:GridView ID="gvPhieuXuat" runat="server" CssClass="table table-custom align-middle mb-0" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvPhieuXuat_RowCommand">
                                <Columns>
                                    <asp:TemplateField ItemStyle-CssClass="chk-cell text-center no-print" HeaderStyle-CssClass="chk-cell text-center no-print">
                                        <HeaderTemplate>
                                            <input type="checkbox" class="form-check-input" onclick="chonTatCa(this);" title="Chọn / bỏ chọn tất cả" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <input type="checkbox" class="form-check-input chk-row" name="chkXuat" value='<%# HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("MaPhieu"))) %>' title="Chọn phiếu này" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MaPhieu" HeaderText="Mã Phiếu" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="fw-semibold col-nowrap" />
                                    <asp:BoundField DataField="Ngay" HeaderText="Ngày Xuất" DataFormatString="{0:dd/MM/yyyy HH:mm}" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap text-secondary tabular-nums" />
                                    <asp:BoundField DataField="DoiTac" HeaderText="Khách Hàng / Đơn Hàng" ItemStyle-CssClass="fw-medium" />
                                    <asp:BoundField DataField="NhanVien" HeaderText="Nhân Viên Lập" />
                                    <asp:TemplateField HeaderText="Thanh Toán" HeaderStyle-CssClass="col-nowrap" ItemStyle-CssClass="col-nowrap">
                                        <ItemTemplate>
                                            <span class='pay-badge <%# Convert.ToString(Eval("TrangThaiThanhToan")) == "Đã thanh toán" ? "paid" : "unpaid" %>'><%# Server.HtmlEncode(Convert.ToString(Eval("TrangThaiThanhToan"))) %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} VND" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-end col-nowrap" ItemStyle-CssClass="text-end fw-bold text-primary col-nowrap tabular-nums" />
                                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-CssClass="text-center col-nowrap no-print" HeaderStyle-CssClass="text-center col-nowrap no-print">
                                        <ItemTemplate>
                                            <div class="row-actions">
                                                <asp:LinkButton ID="btnInXuat" runat="server" CssClass="btn btn-light text-primary border shadow-xs" CommandName="InPhieuXuat" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Xem chi tiết &amp; in phiếu">
                                                    <i class="fa-solid fa-print"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDoiTrangThaiXuat" runat="server" CssClass="btn btn-light text-warning border shadow-xs" CommandName="DoiTrangThaiXuat" CommandArgument='<%# Eval("MaPhieu") %>' ToolTip="Đổi trạng thái thanh toán">
                                                    <i class="fa-solid fa-rotate"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnXoaXuat" runat="server" CssClass="btn btn-light text-danger border shadow-xs" CommandName="XoaPhieuXuat" CommandArgument='<%# Eval("MaPhieu") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa phiếu xuất này?');" ToolTip="Xóa phiếu">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fa-solid fa-file-circle-xmark"></i>
                                        </div>
                                        <h6 class="fw-bold text-dark mb-1">Không tìm thấy phiếu xuất kho phù hợp</h6>
                                        <p class="small text-muted mb-0">Hãy thử thay đổi từ khóa hoặc khoảng thời gian lọc.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                </div>
            </div>
        </asp:Panel>

        <!-- ================= CHẾ ĐỘ CHI TIẾT PHIẾU (xem + in + xuất file) ================= -->
        <asp:Panel ID="pnlChiTiet" runat="server" Style="display:none">
            <div class="wms-card p-3 mb-3 d-flex flex-wrap justify-content-between align-items-center gap-2 no-print">
                <asp:LinkButton ID="btnQuayLai" runat="server" CssClass="btn btn-outline-secondary fw-semibold" OnClick="btnQuayLai_Click" CausesValidation="false">
                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách
                </asp:LinkButton>
                <div class="d-flex flex-wrap gap-2">
                    <asp:LinkButton ID="btnXuatExcelPhieu" runat="server" CssClass="btn btn-outline-success fw-semibold" OnClick="btnXuatExcelPhieu_Click" CausesValidation="false">
                        <i class="fa-solid fa-file-excel me-1"></i> Xuất Excel
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnXuatWordPhieu" runat="server" CssClass="btn btn-outline-primary fw-semibold" OnClick="btnXuatWordPhieu_Click" CausesValidation="false">
                        <i class="fa-solid fa-file-word me-1"></i> Xuất Word
                    </asp:LinkButton>
                    <button type="button" class="btn btn-danger fw-semibold shadow-sm" onclick="window.print();">
                        <i class="fa-solid fa-print me-1"></i> In / Lưu PDF
                    </button>
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
