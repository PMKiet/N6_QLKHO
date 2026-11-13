using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace N6_QLKHO
{
    public static class DatabaseHelper
    {
        // Lấy chuỗi kết nối từ Web.config (hoặc chuỗi mặc định nếu chưa cấu hình Web.config)
        private static string connectionString = ConfigurationManager.ConnectionStrings["MyDbConnection"]?.ConnectionString
            ?? "Data Source=DESKTOP-UKT66TU;Initial Catalog=N6_QLKHOVATTU;Integrated Security=True;Encrypt=False";

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
}