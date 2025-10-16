package com.newsportal.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.newsportal.model.User;
import com.newsportal.util.DB;

public class UserDAO {

    /* ======================== CRUD & Auth ======================== */

    public User findById(int id) throws Exception {
        String sql = "SELECT * FROM Users WHERE Id=?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<User> findAll() throws Exception {
        String sql = "SELECT * FROM Users ORDER BY Id DESC";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<User> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    /** Tạo user mới. Role: true=Admin, false=Reporter */
    public int create(User u) throws Exception {
        String sql = "INSERT INTO Users(Fullname, Email, [Password], Mobile, Birthday, Gender, Role, Activated) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getFullname());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getMobile());

            // birthday: java.util.Date -> java.sql.Date
            if (u.getBirthday() != null) {
                ps.setDate(5, new java.sql.Date(u.getBirthday().getTime()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            // gender: primitive boolean (nếu bạn dùng Boolean, đổi sang setObject với Types.BIT)
            ps.setBoolean(6, u.isGender());

            // role: BIT
            ps.setBoolean(7, u.isRole());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
    
    /*Tạo user mới từ form quản lý người dùng tại Admin:
     * 
     */
    public int createAdminForm(User u) throws Exception {
        String sql = "INSERT INTO Users (Fullname, Email, [Password], Mobile, Birthday, Gender, Role, Activated) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getFullname());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getMobile());

            // Birthday
            if (u.getBirthday() != null) {
                ps.setDate(5, new java.sql.Date(u.getBirthday().getTime()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            // Gender (BIT)
            ps.setBoolean(6, u.isGender());

            // Role (BIT)
            ps.setBoolean(7, u.isRole());

            // Activated (BIT) - LẤY TỪ OBJECT
            ps.setBoolean(8, u.isActivated());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }


    /** Đăng nhập (Activated=1) */
    public User login(String email, String password) throws Exception {
        String sql = "SELECT * FROM Users WHERE Email=? AND [Password]=? AND Activated=1";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** Cập nhật thông tin người dùng (bao gồm role & gender) */
    public void update(User u) throws Exception {
        String sql = """
            UPDATE Users
               SET [Password]=?, Fullname=?, Birthday=?, Gender=?, Mobile=?, Email=?, [Role]=?
             WHERE Id=?
            """;
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, u.getPassword());
            ps.setString(2, u.getFullname());

            if (u.getBirthday() != null) {
                ps.setDate(3, new java.sql.Date(u.getBirthday().getTime()));
            } else {
                ps.setNull(3, Types.DATE);
            }

            // gender
            ps.setBoolean(4, u.isGender());
            // Nếu model của bạn là Boolean có thể null:
            // if (u.getGender() == null) ps.setNull(4, Types.BIT); else ps.setBoolean(4, u.getGender());

            ps.setString(5, u.getMobile());
            ps.setString(6, u.getEmail());

            // role
            ps.setBoolean(7, u.isRole());

            ps.setInt(8, u.getId());

            ps.executeUpdate();
        }
    }

    public void delete(int id) throws Exception {
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement("DELETE FROM Users WHERE Id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public boolean existsEmail(String email) throws Exception {
        String sql = "SELECT 1 FROM Users WHERE Email=?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
    
    public boolean existsMobile(String mobile) throws Exception {
        String sql = "SELECT 1 FROM Users WHERE Mobile=?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, mobile);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /* ======================== Helpers ======================== */

    /** Map 1 dòng ResultSet -> User (birthday java.util.Date, gender/role boolean) */
    private User map(ResultSet rs) throws Exception {
        User u = new User();

        u.setId(rs.getInt("Id"));
        u.setPassword(rs.getString("Password"));
        u.setFullname(rs.getString("Fullname"));

        java.sql.Date bd = rs.getDate("Birthday");
        if (bd != null) {
            u.setBirthday(new java.util.Date(bd.getTime())); // model dùng java.util.Date
        } else {
            u.setBirthday(null);
        }

        // gender & role: BIT -> boolean
        u.setGender(rs.getBoolean("Gender"));
        // Nếu Gender trong DB có thể NULL mà bạn muốn giữ null trong model:
        // Object g = rs.getObject("Gender");
        // if (u.getClass().getMethod("setGender", Boolean.class) != null) {
        //     u.setGender(g == null ? null : rs.getBoolean("Gender"));
        // } else {
        //     u.setGender(g != null && rs.getBoolean("Gender"));
        // }

        u.setMobile(rs.getString("Mobile"));
        u.setEmail(rs.getString("Email"));
        u.setRole(rs.getBoolean("Role")); // true=Admin, false=Reporter
        u.setActivated(rs.getBoolean("Activated"));

        return u;
    }
    
    public int countAll() throws Exception {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM Users");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    public void setActivated(int id, boolean on) throws Exception {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE Users SET Activated=? WHERE Id=?")) {
            ps.setBoolean(1, on); ps.setInt(2, id); ps.executeUpdate();
        }
    }
    public void setRole(int id, boolean admin) throws Exception { // true=admin,false=reporter
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE Users SET Role=? WHERE Id=?")) {
            ps.setBoolean(1, admin); ps.setInt(2, id); ps.executeUpdate();
        }
    }
    
 // 
    public int create(User u, boolean activated) throws Exception {
        String sql = "INSERT INTO Users(Fullname, Email, [Password], Mobile, Birthday, Gender, Role, Activated) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getFullname());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getMobile());

            if (u.getBirthday() != null) {
                ps.setDate(5, new java.sql.Date(u.getBirthday().getTime()));
            } else {
                ps.setNull(5, Types.DATE);
            }
            ps.setBoolean(6, u.isGender());
            ps.setBoolean(7, u.isRole());
            ps.setBoolean(8, activated); // <--- khác biệt

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Lấy danh sách tài khoản chờ duyệt (Activated=0) */
    public List<User> findPending() throws Exception {
        String sql = "SELECT * FROM Users WHERE Activated=0 ORDER BY Id DESC";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<User> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }
    
    public List<User> search(String by, String q) throws Exception {
        String kw = (q == null) ? "" : q.trim();
        boolean isAll = by == null || by.isBlank() || "all".equalsIgnoreCase(by);

        try (Connection cn = DB.getConnection()) {
            if (isAll) {
                String like = "%" + kw + "%";
                String sql = """
                    SELECT * FROM Users
                     WHERE Fullname LIKE ? OR Email LIKE ? 
                        OR REPLACE(REPLACE(REPLACE(Mobile,' ',''),'-',''),'.','') LIKE ?
                     ORDER BY Id DESC
                    """;
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    ps.setString(1, like);
                    ps.setString(2, like);
                    ps.setString(3, "%" + kw.replaceAll("\\D+", "") + "%");
                    try (ResultSet rs = ps.executeQuery()) {
                        List<User> list = new ArrayList<>();
                        while (rs.next()) list.add(map(rs));
                        return list;
                    }
                }
            } else {
                switch (by.toLowerCase()) {
                    case "mobile": { // contains + bỏ ký tự định dạng
                        String likeDigits = "%" + kw.replaceAll("\\D+", "") + "%";
                        String sql = """
                            SELECT * FROM Users
                             WHERE REPLACE(REPLACE(REPLACE(Mobile,' ',''),'-',''),'.','') LIKE ?
                             ORDER BY Id DESC
                            """;
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setString(1, likeDigits);
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                    case "fullname": {
                        String sql = "SELECT * FROM Users WHERE Fullname LIKE ? ORDER BY Id DESC";
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setString(1, "%" + kw + "%");
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                    case "email": {
                        String sql = "SELECT * FROM Users WHERE Email LIKE ? ORDER BY Id DESC";
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setString(1, "%" + kw + "%");
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                    case "role": { // true=ADMIN, false=REPORTER
                        boolean isAdmin = parseRoleToBoolean(kw);
                        String sql = "SELECT * FROM Users WHERE Role=? ORDER BY Id DESC";
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setBoolean(1, isAdmin);
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                    case "activated": { // true=đã kích hoạt, false=chưa
                        boolean on = parseYesNo(kw);
                        String sql = "SELECT * FROM Users WHERE Activated=? ORDER BY Id DESC";
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setBoolean(1, on);
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                    default: { // fallback theo họ tên
                        String sql = "SELECT * FROM Users WHERE Fullname LIKE ? ORDER BY Id DESC";
                        try (PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setString(1, "%" + kw + "%");
                            try (ResultSet rs = ps.executeQuery()) {
                                List<User> list = new ArrayList<>();
                                while (rs.next()) list.add(map(rs));
                                return list;
                            }
                        }
                    }
                }
            }
        }
    }

    /* ======= helpers cho search ======= */
    private boolean parseRoleToBoolean(String in) {
        if (in == null) return false;
        String s = in.trim().toLowerCase();
        // true = ADMIN
        return s.startsWith("a") || s.equals("admin") || s.equals("1") || s.equals("true");
    }

    private boolean parseYesNo(String in) {
        if (in == null) return true; // mặc định coi là “có”
        String s = in.trim().toLowerCase();
        // on/yes/true/1/✓
        if (s.matches("^(1|true|yes|y|on|co|có|active|activated|enable|enabled|✓|✔)$")) return true;
        // off/no/false/0/✗
        if (s.matches("^(0|false|no|n|off|khong|không|inactive|disabled|✗|x)$")) return false;
        // không rõ -> so khớp “có” nếu người dùng gõ “có/kích hoạt/đã”
        return s.contains("co") || s.contains("kic") || s.contains("da");
    }
    
    
    public User findAuthorById(int id) {
        String sql = "SELECT Id, Password, Fullname, Birthday, Gender, Mobile, Email, Role, Activated FROM [User] WHERE id = ?";
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setPassword(rs.getString("Password"));
                    u.setFullname(rs.getString("Fullname"));
                    u.setBirthday(rs.getDate("Birthday"));
                    u.setGender(rs.getBoolean("Gender"));
                    u.setMobile(rs.getString("Mobile"));
                    u.setEmail(rs.getString("Email"));
                    u.setRole(rs.getBoolean("Role"));
                    u.setActivated(rs.getBoolean("Activated"));
                    return u;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }
    
    public Map<Integer, User> findByIds(Collection<Integer> ids) {
        Map<Integer, User> map = new HashMap<>();
        if (ids == null || ids.isEmpty()) return map;

        // tạo "?, ?, ?, ..." theo số lượng ids
        String placeholders = ids.stream().map(i -> "?").collect(Collectors.joining(","));
        String sql = "SELECT Id, Password, Fullname, Birthday, Gender, Mobile, Email, Role, Activated " +
                     "FROM Users WHERE Id IN (" + placeholders + ")";

        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            for (Integer id : ids) ps.setInt(i++, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Id"));
                    u.setPassword(rs.getString("Password"));
                    u.setFullname(rs.getString("Fullname"));
                    u.setBirthday(rs.getDate("Birthday"));
                    u.setGender(rs.getBoolean("Gender"));
                    u.setMobile(rs.getString("Mobile"));
                    u.setEmail(rs.getString("Email"));
                    u.setRole(rs.getBoolean("Role"));
                    u.setActivated(rs.getBoolean("Activated"));
                    map.put(u.getId(), u);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return map;
    }
    
    
    //=========================================================================================================
    
    /** Kiểm tra email đã tồn tại cho user KHÁC id cho trước */
    public boolean existsEmailExceptId(String email, int excludeId) throws Exception {
        String sql = "SELECT 1 FROM Users WHERE Email=? AND Id<>?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Kiểm tra số điện thoại đã tồn tại cho user KHÁC id cho trước */
    public boolean existsMobileExceptId(String mobile, int excludeId) throws Exception {
        String sql = "SELECT 1 FROM Users WHERE Mobile=? AND Id<>?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, mobile);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }







}
