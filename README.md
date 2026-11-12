# 📦 HỆ THỐNG QUẢN LÝ KHO VẬT TƯ (N6_QLKHOVATTU)

Hệ thống Quản lý Kho Vật tư giúp quản lý danh mục hàng hóa, nhà cung cấp, quy trình nhập - xuất kho, đơn đặt hàng và báo cáo thống kê cho kho vật tư.

---

## 👥 Phân Công Nhiệm Vụ Thành Viên

| Thành viên | Nhiệm vụ / Module đảm nhận | Chi tiết chức năng |
| :--- | :--- | :--- |
| **Lộc** | • Quản lý Hàng hóa<br>• Loại hàng hóa<br>• Cảnh báo | • Quản lý danh sách, thông tin hàng hóa<br>• Phân loại vật tư, hàng hóa<br>• Cảnh báo hàng tồn kho / sắp hết hạn |
| **Phong** | • Quản lý Nhà cung cấp<br>• Quản lý Tài khoản & Phân quyền | • Quản lý thông tin các nhà cung cấp<br>• Quản lý người dùng, phân quyền hệ thống |
=======
| **Kiệt** | • Báo cáo & Thống kê<br>• Đơn Đặt Hàng<br> | • Quản lý quy trình và chi tiết phiếu nhập kho<br>• Lập báo cáo doanh thu, nhập/xuat kho và thống kê |
| **Đô** |• Phiếu Nhập Kho<br>• Phiếu Xuất Kho<br> • Trang Đăng Nhập<br>• Tồn Kho | • Giao diện và xử lý đăng nhập hệ thống<br>• Quản lý phiếu xuất kho và chi tiết xuất<br>• Quản lý đơn đặt hàng của khách hàng<br>• Theo dõi và kiểm soát số lượng tồn kho |
>>>>>>> origin/master

---

## 🗄️ Cấu Trúc Cơ Sở Dữ Liệu (Database Schema)

Cơ sở dữ liệu `N6_QLKHOVATTU` gồm 11 bảng chính:

1. **`NguoiDung`**: Quản lý tài khoản nhân viên và chức vụ (Quản lý, Nhân viên).
2. **`LoaiHangHoa`**: Danh mục phân loại vật tư, hàng hóa.
3. **`HangHoa`**: Thông tin chi tiết mặt hàng, đơn vị tính, đơn giá, hạn sử dụng.
4. **`NhaCungCap`**: Thông tin đối tác, nhà cung cấp vật tư.
5. **`TonKho`**: Quản lý số lượng tồn kho thực tế và hạn sử dụng theo lô.
6. **`DonDatHang`**: Đơn đặt hàng của khách hàng.
7. **`ChiTietDonDatHang`**: Chi tiết danh sách hàng hóa trong từng đơn đặt hàng.
8. **`PhieuNhap`**: Thông tin phiếu nhập kho từ nhà cung cấp.
9. **`ChiTietPhieuNhap`**: Chi tiết hàng hóa, số lượng và đơn giá nhập.
10. **`PhieuXuat`**: Thông tin phiếu xuất kho.
11. **`ChiTietPhieuXuat`**: Chi tiết hàng hóa và số lượng xuất kho.

---

## 🛠️ Công Nghệ Sử Dụng

* **Database**: Microsoft SQL Server
* **Backend / Frontend**: ASP.NET C# Web Forms / WinForms
* **IDE**: Visual Studio
