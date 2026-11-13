<%@ Page Title="Lập Phiếu Xuất Kho" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PhieuXuat.aspx.cs" Inherits="N6_QLKHO.PhieuXuat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-header-card {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid #e2e8f0;
            border-radius: 12px;
        }
        .page-icon {
            width: 52px; height: 52px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .section-title { font-size: 1rem; font-weight: 700; margin: 0; }
        .table-custom th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 12px 16px;
            white-space: nowrap;
        }
        .table-custom td {
            padding: 14px 16px;
            color: #1e293b;
            vertical-align: middle;
        }
        .input-group-text { background: #f8fafc; color: #64748b; }
        .readonly-user { background-color: #f1f5f9 !important; font-weight: 600; }
        .add-row-box { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px; }
        .form-control.is-invalid, .form-select.is-invalid { background-image: none; }
        .btn[disabled] { cursor: not-allowed; }
        @media print {
            body * { visibility: hidden; }
            #vungInPhieuXuat, #vungInPhieuXuat * { visibility: visible; }
            #vungInPhieuXuat {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                box-shadow: none !important;
                border: none !important;
            }
            .no-print { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Tiêu đề trang -->
    <div class="d-flex align-items-center gap-3 mb-4 no-print">
        <div class="page-icon bg-primary bg-opacity-10 text-primary"><i class="fa-solid fa-file-invoice-dollar"></i></div>
        <div>
            <h3 class="fw-bold text-dark mb-1">Lập Phiếu Xuất Kho</h3>
            <p class="text-muted small mb-0">Tạo phiếu xuất hàng hóa theo đơn đặt hàng hoặc xuất kho trực tiếp. Tồn kho được trừ theo lô hết hạn trước - xuất trước.</p>
        </div>
    </div>

    <!-- Thông báo từ server (thành công / lỗi) và từ trình duyệt (kiểm tra nhanh) -->
    <asp:Label ID="lblThongBao" runat="server" CssClass="d-block no-print" EnableViewState="false"></asp:Label>
    <div id="clientErr" class="no-print"></div>

    <!-- ===== BƯỚC 1: NHẬP THÔNG TIN ===== -->
    <asp:Panel ID="pnlNhapLieu" runat="server">

        <!-- KHUNG THÔNG TIN CHUNG -->
        <div class="card page-header-card shadow-sm mb-4">
            <div class="card-header bg-transparent py-3 border-0">
                <h5 class="section-title text-primary"><i class="fa-solid fa-file-invoice-dollar me-2"></i> Thông Tin Chung Phiếu Xuất</h5>
            </div>
            <div class="card-body px-4 pb-4 pt-0">
                <div class="row g-3">
                    <div class="col-12 col-md-4">
                        <label class="form-label fw-semibold small text-secondary">Mã Phiếu Xuất <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-solid fa-hashtag"></i></span>
                            <asp:TextBox ID="txtMaPhieuXuat" runat="server" CssClass="form-control" MaxLength="10" Placeholder="VD: PX01"></asp:TextBox>
                        </div>
                        <div class="form-text">Tối đa 10 ký tự: chữ, số, dấu - hoặc _</div>
                    </div>
                    <div class="col-12 col-md-4">
                        <label class="form-label fw-semibold small text-secondary">Ngày Xuất <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-regular fa-calendar"></i></span>
                            <asp:TextBox ID="txtNgayXuat" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="form-text">Không được chọn ngày trong tương lai</div>
                    </div>
                    <div class="col-12 col-md-4">
                        <label class="form-label fw-semibold small text-secondary">Đơn Đặt Hàng</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-solid fa-clipboard-list"></i></span>
                            <asp:DropDownList ID="ddlDonHang" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Xuất trực tiếp (không theo đơn) --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="form-text">Chỉ hiện các đơn chưa lập phiếu xuất</div>
                    </div>
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small text-secondary">Người Lập Phiếu</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-solid fa-user-check"></i></span>
                            <asp:TextBox ID="txtNhanVien" runat="server" CssClass="form-control readonly-user" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="form-text">Tự động lấy từ tài khoản đang đăng nhập</div>
                    </div>
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small text-secondary">Trạng Thái Thanh Toán <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-solid fa-money-bill-wave"></i></span>
                            <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Đã thanh toán" Value="Đã thanh toán" />
                                <asp:ListItem Text="Chưa thanh toán" Value="Chưa thanh toán" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- KHU VỰC CHI TIẾT HÀNG -->
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
            <div class="card-header bg-white py-3 border-0">
                <h5 class="section-title text-primary"><i class="fa-solid fa-dolly me-2"></i> Chi Tiết Hàng Xuất Kho</h5>
            </div>
            <div class="card-body px-4 pb-4">
                <!-- Dòng nhập nhanh -->
                <div class="row g-3 align-items-end mb-4 p-3 add-row-box mx-0">
                    <div class="col-12 col-md-5">
                        <label class="form-label fw-semibold small text-secondary">Hàng Hóa</label>
                        <asp:DropDownList ID="ddlHangHoa" runat="server" CssClass="form-select" onchange="chonHang()">
                            <asp:ListItem Text="-- Chọn hàng hóa --" Value="" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-6 col-md-2">
                        <label class="form-label fw-semibold small text-secondary">Số Lượng</label>
                        <asp:TextBox ID="txtSoLuongXuat" runat="server" CssClass="form-control" TextMode="Number" min="1" max="1000000" step="1" Placeholder="0"></asp:TextBox>
                    </div>
                    <div class="col-6 col-md-3">
                        <label class="form-label fw-semibold small text-secondary">Đơn Giá Xuất (đ)</label>
                        <asp:TextBox ID="txtDonGiaXuat" runat="server" CssClass="form-control" TextMode="Number" min="0" max="1000000000" step="0.01" Placeholder="0"></asp:TextBox>
                    </div>

                    <div class="col-12 col-md-2">
                        <asp:Button ID="btnThemDong" runat="server" Text="+ Thêm dòng" CssClass="btn btn-primary w-100 fw-semibold" OnClick="btnThemDong_Click" OnClientClick="return kiemTraDong();" />
                    </div>
                </div>

                <!-- Bảng danh sách tạm -->
                <div class="table-responsive">
                    <asp:GridView ID="gvChiTietPhieuXuat" runat="server" CssClass="table table-custom table-hover mb-0 align-middle" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvChiTietPhieuXuat_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="STT">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="MaHangHoa" HeaderText="Mã Hàng" />
                            <asp:TemplateField HeaderText="Tên Hàng Hóa">
                                <ItemTemplate>
                                    <span class="fw-semibold text-dark"><%# Server.HtmlEncode(Convert.ToString(Eval("TenHangHoa"))) %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="SoLuongXuat" HeaderText="Số Lượng" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="DonGiaXuat" HeaderText="Đơn Giá" DataFormatString="{0:N0} đ" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="ThanhTien" HeaderText="Thành Tiền" DataFormatString="{0:N0} đ" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-CssClass="fw-semibold" />
                            <asp:TemplateField HeaderText="Xóa" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnXoaDong" runat="server" CommandName="XoaDong" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-sm btn-light text-danger border" title="Xóa dòng" OnClientClick="return confirm('Xóa dòng hàng này khỏi phiếu?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="text-center py-5 text-muted">
                                <i class="fa-solid fa-basket-shopping fs-1 mb-2 text-secondary opacity-50"></i>
                                <p class="mb-0">Chưa có mặt hàng nào. Chọn hàng ở trên rồi bấm <strong>+ Thêm dòng</strong>.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
                <asp:Literal ID="litTongTamTinh" runat="server"></asp:Literal>
            </div>
        </div>

        <!-- NÚT XEM TRƯỚC -->
        <div class="text-end mb-5">
            <asp:Button ID="btnXemTruoc" runat="server" Text="Xem trước phiếu →" CssClass="btn btn-primary btn-lg px-5 shadow-sm fw-semibold" OnClick="btnXemTruoc_Click" />
        </div>

    </asp:Panel>

    <!-- ===== BƯỚC 2: XEM TRƯỚC VÀ XÁC NHẬN ===== -->
    <asp:Panel ID="pnlXemTruoc" runat="server" Style="display:none">
        <div class="alert alert-info d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4 no-print" role="alert">
            <div class="d-flex align-items-center">
                <i class="fa-solid fa-eye me-2"></i>
                <div>Đây là bản <strong>xem trước</strong>. Bạn có thể xuất file kiểm tra trước hoặc bấm <strong>Xác nhận lập phiếu</strong> để lưu vào hệ thống.</div>
            </div>
            <!-- Nhóm nút xuất file -->
            <div class="d-flex flex-wrap gap-2">
                <button type="button" class="btn btn-outline-danger btn-sm fw-semibold" onclick="window.print();">
                    <i class="fa-solid fa-file-pdf me-1"></i> In / Xuất PDF
                </button>
                <asp:LinkButton ID="btnXuatExcel" runat="server" CssClass="btn btn-outline-success btn-sm fw-semibold" OnClick="btnXuatExcel_Click" CausesValidation="false">
                    <i class="fa-solid fa-file-excel me-1"></i> Xuất Excel
                </asp:LinkButton>
                <asp:LinkButton ID="btnXuatWord" runat="server" CssClass="btn btn-outline-primary btn-sm fw-semibold" OnClick="btnXuatWord_Click" CausesValidation="false">
                    <i class="fa-solid fa-file-word me-1"></i> Xuất Word
                </asp:LinkButton>
            </div>
        </div>

        <!-- Vùng nội dung phiếu chuẩn để xem trước & In/PDF -->
        <div id="vungInPhieuXuat" class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4 bg-white">
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
                            <asp:TemplateField HeaderText="STT" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="MaHangHoa" HeaderText="Mã Hàng" />
                            <asp:BoundField DataField="TenHangHoa" HeaderText="Tên Hàng Hóa" />
                            <asp:BoundField DataField="SoLuongXuat" HeaderText="Số Lượng" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="DonGiaXuat" HeaderText="Đơn Giá" DataFormatString="{0:N0} đ" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="ThanhTien" HeaderText="Thành Tiền" DataFormatString="{0:N0} đ" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-CssClass="fw-semibold" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="d-flex justify-content-end align-items-center gap-3 mt-3 pt-3 border-top">
                    <span class="text-secondary fw-semibold">Tổng tiền thanh toán:</span>
                    <span class="fs-4 fw-bold text-primary"><asp:Literal ID="litTongTienXemTruoc" runat="server"></asp:Literal></span>
                </div>

                <div class="row text-center mt-5 pt-3">
                    <div class="col-4">
                        <div class="fw-bold small">Người lập phiếu</div>
                        <div class="text-muted fst-italic small">(Ký, họ tên)</div>
                        <div class="mt-5 fw-semibold small"><asp:Literal ID="litChuKyNguoiLap" runat="server"></asp:Literal></div>
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

        <div class="text-end mb-5 no-print">
            <asp:Button ID="btnQuayLai" runat="server" Text="← Quay lại chỉnh sửa" CssClass="btn btn-outline-secondary btn-lg px-4 me-2 fw-semibold" OnClick="btnQuayLai_Click" CausesValidation="false" />
            <asp:Button ID="btnLuuPhieuXuat" runat="server" Text="Xác nhận lập phiếu xuất" CssClass="btn btn-primary btn-lg px-5 shadow-sm fw-semibold" OnClick="btnLuuPhieuXuat_Click" UseSubmitBehavior="false" OnClientClick="this.disabled = true; this.value = 'Đang lưu...';" />
        </div>
    </asp:Panel>

    <script>
        (function () {
            var ID_SL = '<%= txtSoLuongXuat.ClientID %>';
            var ID_GIA = '<%= txtDonGiaXuat.ClientID %>';
            var ID_HH = '<%= ddlHangHoa.ClientID %>';

            function $(id) { return document.getElementById(id); }

            // Chặn gõ/dán ký tự không hợp lệ ngay trên ô nhập (số âm, ký hiệu e, dấu phẩy...)
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
            chan($(ID_GIA), ['-', '+', 'e', 'E', ','], /^[0-9]+(\.[0-9]{1,2})?$/);

            function hienLoi(msg, el) {
                var box = $('clientErr');
                box.innerHTML = '';
                [ID_SL, ID_GIA, ID_HH].forEach(function (id) { var x = $(id); if (x) x.classList.remove('is-invalid'); });
                var d = document.createElement('div');
                d.className = 'alert alert-warning d-flex align-items-start';
                d.innerHTML = '<i class="fa-solid fa-triangle-exclamation me-2 mt-1"></i>';
                var s = document.createElement('div');
                s.textContent = msg;
                d.appendChild(s);
                box.appendChild(d);
                if (el) { el.classList.add('is-invalid'); el.focus(); }
                return false;
            }

            // Kiểm tra nhanh phía trình duyệt trước khi gửi lên server (server vẫn kiểm tra lại)
            window.kiemTraDong = function () {
                $('clientErr').innerHTML = '';
                var hh = $(ID_HH), sl = $(ID_SL), gia = $(ID_GIA);
                if (!hh.value) return hienLoi('Vui lòng chọn hàng hóa.', hh);

                var slText = sl.value.trim();
                if (!/^[0-9]+$/.test(slText) || parseInt(slText, 10) < 1)
                    return hienLoi('Số lượng phải là số nguyên dương (từ 1 trở lên).', sl);
                if (parseInt(slText, 10) > 1000000)
                    return hienLoi('Số lượng tối đa mỗi dòng là 1.000.000.', sl);

                var giaText = gia.value.trim();
                if (!/^[0-9]+(\.[0-9]+)?$/.test(giaText) || parseFloat(giaText) <= 0)
                    return hienLoi('Đơn giá phải là số lớn hơn 0.', gia);
                if (parseFloat(giaText) > 1000000000)
                    return hienLoi('Đơn giá tối đa là 1.000.000.000 đ.', gia);

                return true;
            };

            // Chọn hàng thì tự điền đơn giá mặc định (bảng giá được server đưa xuống biến giaMacDinh)
            window.chonHang = function () {
                var ma = $(ID_HH).value;
                if (ma && typeof giaMacDinh !== 'undefined' && giaMacDinh[ma] !== undefined) {
                    $(ID_GIA).value = giaMacDinh[ma];
                }
            };
        })();
    </script>

</asp:Content>
