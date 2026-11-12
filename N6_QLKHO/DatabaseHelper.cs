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
        /// Tạo SqlConnection mới (chưa mở) để các trang tự dùng khi cần transaction
        /// </summary>
        public static SqlConnection TaoKetNoi()
        {
            return new SqlConnection(connectionString);
        }
    }
}
