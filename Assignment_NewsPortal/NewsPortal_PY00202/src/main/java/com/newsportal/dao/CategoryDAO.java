package com.newsportal.dao;

import java.sql.*;
import java.util.*;
import com.newsportal.model.Category;
import com.newsportal.util.DB;

public class CategoryDAO {
	private static final String ND = "ISNULL(IsDelete,0)=0";

    /** Danh sách active (IsDelete = 0) */
    public List<Category> findAll() throws Exception {
        return findAll(false);
    }

    /** Danh sách; includeDeleted=true để lấy cả IsDelete=1 */
    public List<Category> findAll(boolean includeDeleted) throws Exception {
        String base = "SELECT Id, Name, IsDelete FROM Categories";
        String sql = includeDeleted ? base + " ORDER BY Name"
                                    : base + " WHERE IsDelete = 0 ORDER BY Name";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Category> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    /** Lấy theo id (chỉ active) */
    public Category findById(int id) throws Exception {
        String sql = "SELECT Id, Name, IsDelete FROM Categories WHERE Id = ? AND IsDelete = 0";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** Lấy theo id (kể cả đã xóa mềm) – dùng cho trang quản trị khi cần */
    public Category findByIdAny(int id) throws Exception {
        String sql = "SELECT Id, Name, IsDelete FROM Categories WHERE Id = ?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public void create(String name) throws Exception {
        String sql = "INSERT INTO Categories(Name, IsDelete) VALUES (?, 0)";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.executeUpdate();
        }
    }

    /** Chỉ cho phép cập nhật tên với bản ghi active */
    public void update(int id, String name) throws Exception {
        String sql = "UPDATE Categories SET Name = ? WHERE Id = ? AND IsDelete = 0";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, id);
            int n = ps.executeUpdate();
            if (n == 0) throw new SQLException("Không thể cập nhật: id không tồn tại hoặc đã xóa mềm.");
        }
    }
    
    //Tìm danh sách chưa xóa:
    public List<Category> findAllActive() throws Exception {
        String sql = "SELECT Id, Name, IsDelete FROM Categories WHERE " + ND + " ORDER BY Id DESC";
        try (var c = DB.getConnection(); var ps = c.prepareStatement(sql); var rs = ps.executeQuery()) {
          var list = new ArrayList<Category>();
          while (rs.next()) {
            Category cat = new Category();
            cat.setId(rs.getInt("Id"));
            cat.setName(rs.getString("Name"));
            // cat.setIsDelete(rs.getBoolean("IsDelete")); // nếu model có
            list.add(cat);
          }
          return list;
        }
      }
    
    //Tìm danh sách đã xóa mềm
    public List<Category> findDeleted() throws Exception {
        String sql = "SELECT Id, Name, IsDelete FROM Categories WHERE ISNULL(IsDelete,0)=1 ORDER BY Id DESC";
        try (var c = DB.getConnection(); var ps = c.prepareStatement(sql); var rs = ps.executeQuery()) {
          var list = new ArrayList<Category>();
          while (rs.next()) {
            Category cat = new Category();
            cat.setId(rs.getInt("Id"));
            cat.setName(rs.getString("Name"));
            list.add(cat);
          }
          return list;
        }
      }

    /** Soft delete - xóa mềm */
    public int softDelete(int id) throws Exception {
        try (var c = DB.getConnection();
             var ps = c.prepareStatement("UPDATE Categories SET IsDelete=1 WHERE Id=?")) {
          ps.setInt(1, id);
          return ps.executeUpdate();
        }
      }

    /** Khôi phục từ xóa mềm */
    public void restore(int id) throws Exception {
        String sql = "UPDATE Categories SET IsDelete = 0 WHERE Id = ? AND IsDelete = 1";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    /** Map id->name cho UI: chỉ active */
    public Map<Integer, String> toIdNameMap() {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT Id, Name FROM Categories WHERE IsDelete = 0 ORDER BY Name";
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                map.put(rs.getInt("Id"), rs.getString("Name"));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return map;
    }

    private Category map(ResultSet rs) throws Exception {
        Category c = new Category();
        c.setId(rs.getInt("Id"));
        c.setName(rs.getString("Name"));
        // Nếu model có trường isDelete thì set vào
        try {
            boolean isDel = rs.getBoolean("IsDelete");
            // giả sử Category có setDelete(boolean)
            c.getClass().getMethod("setDelete", boolean.class).invoke(c, isDel);
        } catch (NoSuchMethodException ignore) {
            // nếu chưa thêm field isDelete vào model thì bỏ qua
        }
        return c;
    }
    
    
    /** Xóa cứng – nhờ ON DELETE CASCADE ở FK News(CategoryId) */
    public int hardDelete(int id) throws Exception {
      try (var c = DB.getConnection();
           var ps = c.prepareStatement("DELETE FROM Categories WHERE Id=?")) {
        ps.setInt(1, id);
        return ps.executeUpdate();
      }
    }
    
 // CategoryDAO.java  (thêm vào class)
    private static final String CAT_SELECT_L10N = """
      SELECT c.Id,
             COALESCE(ct_req.[Name], ct_vi.[Name], c.[Name]) AS [Name],
             c.IsDelete
      FROM Categories c
      LEFT JOIN CategoryTranslations ct_req
             ON ct_req.CategoryId = c.Id AND ct_req.[Lang] = ?
      LEFT JOIN CategoryTranslations ct_vi
             ON ct_vi.CategoryId = c.Id AND ct_vi.[Lang] = 'vi'
    """;

    private static String normalizeLang(String lang) {
      return (lang == null || lang.isBlank()) ? "vi" : lang.trim();
    }

    public List<Category> findAllLocalized(String lang) throws Exception {
      String sql = CAT_SELECT_L10N + "WHERE ISNULL(c.IsDelete,0)=0 ORDER BY [Name]";
      try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
        ps.setString(1, normalizeLang(lang));
        try (var rs = ps.executeQuery()) {
          List<Category> list = new ArrayList<>();
          while (rs.next()) list.add(map(rs));
          return list;
        }
      }
    }

    public Category findByIdLocalized(int id, String lang) throws Exception {
      String sql = CAT_SELECT_L10N + "WHERE c.Id = ? AND ISNULL(c.IsDelete,0)=0";
      try (var cn = DB.getConnection(); var ps = cn.prepareStatement(sql)) {
        ps.setString(1, normalizeLang(lang));
        ps.setInt(2, id);
        try (var rs = ps.executeQuery()) {
          return rs.next() ? map(rs) : null;
        }
      }
    }


}
