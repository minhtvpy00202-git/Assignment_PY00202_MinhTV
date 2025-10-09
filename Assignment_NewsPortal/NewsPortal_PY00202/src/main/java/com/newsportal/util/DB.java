package com.newsportal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DB {

    // ====== Hằng số cấu hình DB (đổi ở đây khi cần) ======
    private static final String URL  =
            "jdbc:sqlserver://localhost:1433;databaseName=NewsPortal;encrypt=false;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASS = "123456";

    // Nạp driver một lần khi class được load
    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("SQL Server JDBC Driver not found: " + e.getMessage());
        }
    }

    private DB() {} // không cho khởi tạo

    /** Lấy kết nối mới mỗi lần gọi */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /** Thông tin nhanh phục vụ debug (không in password) */
    public static String info() {
        return "url=" + URL + ", user=" + USER;
    }
}
