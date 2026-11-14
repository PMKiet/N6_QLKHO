using System;
using System.Web;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace N6_QLKHO
{
    public static class DatabaseHelper
    {
        // Lấy chuỗi kết nối từ Web.config (hoặc chuỗi mặc định nếu chưa cấu hình Web.config)
        private static string connectionString = ConfigurationManager.ConnectionStrings["MyDbConnection"]?.ConnectionString
            ?? "Data Source=.\\SQLEXPRESS;Initial Catalog=N6_QLKHOVATTU;Integrated Security=True;Encrypt=False";

        /// <summary>
        /// Thực thi câu lệnh SELECT và trả về DataTable (Dùng để nạp dữ liệu lên GridView, DropDownList...)
        /// </summary>
        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        conn.Open();
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        /// <summary>
        /// Thực thi các câu lệnh INSERT, UPDATE, DELETE (Trả về số dòng bị ảnh hưởng)
        /// </summary>
        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            int rowsAffected = 0;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    rowsAffected = cmd.ExecuteNonQuery();
                }
            }
            return rowsAffected;
        }

        /// <summary>
        /// Thực thi câu lệnh trả về một giá trị duy nhất (Ví dụ: COUNT(*), SUM(), MAX()...)
        /// </summary>
        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            object result = null;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    result = cmd.ExecuteScalar();
                }
            }
            return result;
        }

        /// <summary>
        /// Tạo SqlCommand gắn với một transaction đang mở.
        /// </summary>
        public static SqlCommand TaoLenh(SqlConnection conn, SqlTransaction tran, string query, params SqlParameter[] parameters)
        {
            SqlCommand cmd = new SqlCommand(query, conn, tran);
            if (parameters != null && parameters.Length > 0)
            {
                cmd.Parameters.AddRange(parameters);
            }
            return cmd;
        }

        /// <summary>
        /// Chạy nhiều thao tác trong MỘT transaction: tất cả cùng thành công (Commit),
        /// hoặc có lỗi ở bất kỳ bước nào thì hoàn tác toàn bộ (Rollback) rồi ném lại lỗi.
        /// </summary>
        public static void ExecuteTransaction(Action<SqlConnection, SqlTransaction> work)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlTransaction tran = conn.BeginTransaction(IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        work(conn, tran);
                        tran.Commit();
                    }
                    catch
                    {
                        try { tran.Rollback(); } catch { /* kết nối đã đứt, không còn gì để hoàn tác */ }
                        throw;
                    }
                }
            }
        }

        /// <summary>
        /// Đổi ngoại lệ thành thông báo thân thiện cho người dùng (không lộ chi tiết kỹ thuật).
        /// Chi tiết lỗi thật được ghi vào Trace để quản trị viên xem.
        /// </summary>
        public static string LayThongBaoLoi(Exception ex)
        {
            if (ex is NghiepVuException)
            {
                return ex.Message;
            }

            System.Diagnostics.Trace.TraceError(ex.ToString());

            SqlException sql = ex as SqlException;
            if (sql != null)
            {
                switch (sql.Number)
                {
                    case 2627:
                    case 2601:
                        return "Dữ liệu bị trùng (mã đã tồn tại). Vui lòng kiểm tra lại.";
                    case 547:
                        return "Dữ liệu tham chiếu không hợp lệ (nhà cung cấp, nhân viên, đơn hàng hoặc hàng hóa không còn tồn tại).";
                    case 1205:
                        return "Hệ thống đang bận, vui lòng thử lại sau ít giây.";
                    case -2:
                        return "Hết thời gian chờ cơ sở dữ liệu. Vui lòng thử lại.";
                    case 2628:
                    case 8152:
                        return "Có thông tin nhập quá dài so với quy định.";
                    case 8115:
                    case 220:
                        return "Có giá trị số vượt quá giới hạn cho phép.";
                    case 53:
                    case 4060:
                    case 18456:
                        return "Không kết nối được cơ sở dữ liệu. Vui lòng liên hệ quản trị viên.";
                }
                return "Lỗi cơ sở dữ liệu. Vui lòng thử lại hoặc liên hệ quản trị viên.";
            }

            return "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.";
        }

        public static SqlConnection TaoKetNoi()
        {
            return new SqlConnection(connectionString);
        }

        
        /// <summary>
        /// Tạo SqlConnection mới (chưa mở) để các trang tự dùng khi cần transaction
        /// </summary>

    }

    public class NghiepVuException : Exception
    {
        public NghiepVuException(string message) : base(message) { }
    }


    /// <summary>
    /// Hỗ trợ xuất bản xem trước phiếu ra file Excel (.xls) / Word (.doc).
    /// Tạo tài liệu HTML mà Excel và Word đều mở được, không cần cài thêm thư viện.
    /// </summary>
    public static class XuatFileHelper
    {
        public const string KetThuc = "</body></html>";

        public static string Mh(string s)
        {
            return HttpUtility.HtmlEncode(s ?? "");
        }

        // Excel: số thô để Excel hiểu là số; Word: số có dấu phân cách hàng nghìn
        public static string So(bool excel, decimal v)
        {
            return excel ? v.ToString("0.##") : v.ToString("N0");
        }

        public static string O(string cls, string html, int colspan = 1, string style = "")
        {
            return "<td" +
                   (colspan > 1 ? " colspan=\"" + colspan + "\"" : "") +
                   (string.IsNullOrEmpty(cls) ? "" : " class=\"" + cls + "\"") +
                   (string.IsNullOrEmpty(style) ? "" : " style=\"" + style + "\"") +
                   ">" + html + "</td>";
        }

        public static string DongTrong(int cols)
        {
            return "<tr>" + O("", "&nbsp;", cols) + "</tr>";
        }

        public static string DongTin(string nhan, string giaTri, int cols)
        {
            return "<tr>" + O("lbl", Mh(nhan), 2) + O("txt val", Mh(giaTri), cols - 2) + "</tr>";
        }

        public static string ChuKy(int[] doRong, string[] tieuDe, string tenNguoiLap)
        {
            string style = "mso-data-placement:same-cell";
            string dong1 = "<tr>";
            string dong2 = "<tr>";
            for (int i = 0; i < tieuDe.Length; i++)
            {
                dong1 += O("c", "<b>" + Mh(tieuDe[i]) + "</b><br/><i>(Ký, ghi rõ họ tên)</i>", doRong[i], style);
                dong2 += O("c", "<br/><br/><br/>" + (i == 0 ? "<b>" + Mh(tenNguoiLap) + "</b>" : "&nbsp;"), doRong[i], style);
            }
            return dong1 + "</tr>" + dong2 + "</tr>";
        }

        public static string BatDau()
        {
            return "<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" " +
                   "xmlns:x=\"urn:schemas-microsoft-com:office:excel\" " +
                   "xmlns=\"http://www.w3.org/TR/REC-html40\">" +
                   "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>" +
                   "<style>" +
                   "table{border-collapse:collapse;font-family:'Times New Roman',serif;font-size:13px}" +
                   "td{padding:4px 6px;vertical-align:middle}" +
                   ".title{font-size:20px;font-weight:bold;text-align:center}" +
                   ".sub{text-align:center;font-style:italic}" +
                   ".lbl{font-weight:bold}" +
                   ".val{text-align:left}" +
                   ".th{background:#D9E2F3;border:1px solid #000;font-weight:bold;text-align:center}" +
                   ".b{border:1px solid #000}" +
                   ".tot{border:1px solid #000;font-weight:bold;background:#F2F2F2}" +
                   ".c{text-align:center}" +
                   ".r{text-align:right}" +
                   ".txt{mso-number-format:'\\@'}" +
                   ".num{mso-number-format:'#,##0'}" +
                   "</style></head><body>";
        }

        /// <summary>
        /// Gửi file về trình duyệt dưới dạng tải xuống (UTF-8 có BOM để Excel/Word hiển thị đúng tiếng Việt).
        /// </summary>
        public static void GuiFile(HttpResponse res, string html, string contentType, string tenFile)
        {
            res.Clear();
            res.Buffer = true;
            res.Charset = "utf-8";
            res.ContentEncoding = new UTF8Encoding(false);
            res.ContentType = contentType;
            res.AddHeader("Content-Disposition", "attachment; filename=\"" + tenFile + "\"");
            res.Write("\uFEFF" + html);
            res.Flush();
            res.SuppressContent = true;
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
    }
}
