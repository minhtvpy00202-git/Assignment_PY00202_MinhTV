package com.newsportal.dao;

import com.newsportal.model.Newsletter;
import com.newsportal.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewsletterDAO {

    // Đăng ký: nếu đã tồn tại thì bật Enabled=1 và gỡ IsDelete (IsDelete=0)
	
	
	
	// CŨ (vẫn giữ tương thích)
    public void subscribe(String email) throws Exception { subscribe(email, null); }

    // MỚI: Lưu categoryId (NULL = tất cả)
    public void subscribe(String email, Integer categoryId) throws Exception {
        String sql = """
            MERGE dbo.Newsletters AS t
            USING (SELECT ? AS Email) s ON (t.Email = s.Email)
            WHEN MATCHED THEN
              UPDATE SET Enabled=1, IsDelete=0, CategoryId=?
            WHEN NOT MATCHED THEN
              INSERT (Email, Enabled, IsDelete, CategoryId) VALUES (s.Email, 1, 0, ?);
        """;
        try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            if (categoryId == null) ps.setNull(2, Types.INTEGER); else ps.setInt(2, categoryId);
            if (categoryId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, categoryId);
            ps.executeUpdate();
        }
    }
    
    
    // Hủy theo dõi nhưng không xóa: chỉ tắt Enabled (bản ghi vẫn còn, IsDelete=0)
    public boolean unsubscribe(String email) throws Exception {
        String sql = "UPDATE Newsletter SET Enabled = 0 WHERE Email = ? AND ISNULL(IsDelete,0)=0";
        try (var c = DB.getConnection(); var ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            int n = ps.executeUpdate();
            return n > 0; // true nếu có bản ghi để hủy
        }
    }


    // Soft delete: IsDelete=1 (ẩn hoàn toàn ở các truy vấn mặc định)
    public void softDelete(String email) throws Exception {
        String sql = "UPDATE Newsletters SET IsDelete = 1, Enabled = 0 WHERE Email = ? AND IsDelete = 0";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }

    // Khôi phục một bản ghi đã xóa mềm
    public void restore(String email) throws Exception {
        String sql = "UPDATE Newsletters SET IsDelete = 0, Enabled = 1 WHERE Email = ? AND IsDelete = 1";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }

    // Lấy tất cả đang hoạt động (IsDelete=0) – dùng cho UI mặc định
    public List<Newsletter> findAllActive() throws Exception {
    	String sql = "SELECT Email, Enabled, IsDelete, [CategoryId] " +
                "FROM Newsletters WHERE IsDelete = 0 ORDER BY Email";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Newsletter> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        }
    }

    // Dùng cho trang quản trị hiển thị
    public List<Newsletter> findAll(boolean includeDeleted) throws Exception {
        String base = "SELECT Email, Enabled, IsDelete, [CategoryId] FROM dbo.Newsletters";
        String sql  = includeDeleted? base+" ORDER BY Email" : base+" WHERE IsDelete=0 ORDER BY Email";
        try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            List<Newsletter> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        }
    }


    // Tìm theo email (mặc định chỉ lấy bản ghi active)
    public Newsletter findByEmail(String email) throws Exception {
    	String sql = "SELECT Email, Enabled, IsDelete, [CategoryId] " +
                "FROM Newsletters WHERE Email = ? AND IsDelete = 0";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    // Nếu cần kiểm tra tồn tại, có thể xét cả includeDeleted
    public boolean exists(String email, boolean includeDeleted) throws Exception {
        String sql = includeDeleted
                ? "SELECT 1 FROM Newsletters WHERE Email = ?"
                : "SELECT 1 FROM Newsletters WHERE Email = ? AND IsDelete = 0";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Map 1 dòng ResultSet -> Newsletter
    private Newsletter mapRow(ResultSet rs) throws SQLException {
        Integer cat = (Integer) rs.getObject("CategoryId"); // null-safe
        return new Newsletter(
            rs.getString("Email"),
            rs.getBoolean("Enabled"),
            rs.getBoolean("IsDelete"),
            cat
        );
    }

    
 // Lấy email đang bật (Enabled=1), chưa xóa (IsDelete=0) và:
 // - categoryId IS NULL  => nhận tất cả
 // - HOẶC categoryId = ? => nhận đúng chuyên mục
 public List<String> listActiveEmailsForCategory(Integer categoryId) throws Exception {
     String sql = """
         SELECT Email
         FROM Newsletters
         WHERE Enabled = 1 AND IsDelete = 0
           AND (CategoryId IS NULL OR CategoryId = ?)
     """;
     try (Connection cn = DB.getConnection();
          PreparedStatement ps = cn.prepareStatement(sql)) {
         if (categoryId == null) ps.setNull(1, Types.INTEGER);
         else ps.setInt(1, categoryId);
         try (ResultSet rs = ps.executeQuery()) {
             List<String> emails = new ArrayList<>();
             while (rs.next()) emails.add(rs.getString("Email"));
             return emails;
         }
     }
 }
 
//Lấy subscribers active (Enabled=1, IsDelete=0) để GỬI
 public List<Newsletter> listActiveSubscribers() throws Exception {
     String sql = "SELECT Email, Enabled, IsDelete, [CategoryId] FROM dbo.Newsletters WHERE Enabled=1 AND IsDelete=0";
     try (Connection cn = DB.getConnection(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
         List<Newsletter> list = new ArrayList<>();
         while (rs.next()) list.add(mapRow(rs));
         return list;
     }
 }

 //Tắt bật nhận thư:
 public void updateEnabled(String email, boolean enabled) throws Exception {
	    String sql = "UPDATE Newsletters SET Enabled = ? WHERE Email = ? AND IsDelete = 0";
	    try (Connection cn = DB.getConnection();
	         PreparedStatement ps = cn.prepareStatement(sql)) {
	        ps.setBoolean(1, enabled);
	        ps.setString(2, email);
	        ps.executeUpdate();
	    }
	}

    
}
