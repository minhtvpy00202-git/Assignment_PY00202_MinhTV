package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.UserDAO;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/admin/users")
public class UserCRUDServlet extends HttpServlet {
    private final UserDAO dao = new UserDAO();
    private final SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = p(req, "action", "list");
        if ("edit".equals(action)) {
            int id = pInt(req, "id", -1);
            if (id < 0) { resp.sendError(400, "Invalid id"); return; }
            try {
                req.setAttribute("item", dao.findById(id));
            } catch (Exception e) {
                throw new ServletException("Không tải người dùng id=" + id, e);
            }
        }
        list(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = p(req, "action", "list");

        try {
            switch (action) {
            case "create": {
                try {
                    String fullname  = p(req, "fullName");
                    String birthday  = p(req, "birthday");
                    String password  = p(req, "password");
                    String gender    = p(req, "gender");
                    String mobile    = p(req, "mobile");
                    String email     = p(req, "email");
                    String role      = p(req, "role");
                    String activated = req.getParameter("activated");
                    String confirm   = p(req, "confirmPassword");

                    // Bắt buộc nhập đủ các trường
                    if (fullname.isBlank() || email.isBlank() || mobile.isBlank()
                            || birthday.isBlank() || password.isBlank() || confirm.isBlank()) {
                        req.setAttribute("error", "Vui lòng nhập đầy đủ các trường bắt buộc.");
                        // focus vào trường đầu tiên bị thiếu
                        String focus = fullname.isBlank() ? "fullName"
                                       : email.isBlank() ? "email"
                                       : mobile.isBlank() ? "mobile"
                                       : birthday.isBlank() ? "birthday"
                                       : password.isBlank() ? "password" : "confirmPassword";
                        req.setAttribute("focusField", focus);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Kiểm tra định dạng email
                    if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                        req.setAttribute("error", "Email không hợp lệ.");
                        req.setAttribute("focusField", "email");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Kiểm tra định dạng số điện thoại: đúng 10 số
                    if (!mobile.matches("^\\d{10}$")) {
                        req.setAttribute("error", "Số điện thoại phải gồm đúng 10 chữ số.");
                        req.setAttribute("focusField", "mobile");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Xác nhận mật khẩu
                    if (!password.equals(confirm)) {
                        req.setAttribute("error", "Mật khẩu nhập lại không khớp.");
                        req.setAttribute("focusField", "confirmPassword");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Kiểm tra trùng Email / Mobile
                    if (dao.existsEmail(email)) {
                        req.setAttribute("error", "Email đã tồn tại trong hệ thống.");
                        req.setAttribute("focusField", "email");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }
                    if (dao.existsMobile(mobile)) {
                        req.setAttribute("error", "Số điện thoại đã tồn tại trong hệ thống.");
                        req.setAttribute("focusField", "mobile");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Build user
                    User u = new User();
                    u.setFullname(fullname);
                    try {
                        u.setBirthday(java.sql.Date.valueOf(birthday)); // yyyy-MM-dd
                    } catch (IllegalArgumentException ex) {
                        req.setAttribute("error", "Ngày sinh không hợp lệ (định dạng yyyy-MM-dd).");
                        req.setAttribute("focusField", "birthday");
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }
                    u.setPassword(password); // TODO: hash nếu dùng băm
                    u.setGender("true".equalsIgnoreCase(gender));
                    u.setMobile(mobile);
                    u.setEmail(email);
                    u.setRole("ADMIN".equalsIgnoreCase(role));

                    boolean activatedBool = "on".equalsIgnoreCase(activated) || "true".equalsIgnoreCase(activated);
                    u.setActivated(activatedBool);

                    dao.createAdminForm(u);

                    // Thành công -> nhảy xuống #list
                    resp.sendRedirect(req.getContextPath() + "/admin/users?created=1#list");
                    return;
                } catch (Exception e) {
                    req.setAttribute("error", "Có lỗi khi tạo người dùng: " + e.getMessage());
                    // Ưu tiên trả user về ô fullName để người dùng tiếp tục sửa
                    req.setAttribute("focusField", "fullName");
                    req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                    return;
                }
            }


            case "update": {
                int id = pInt(req, "id", -1);
                if (id < 0) throw new ServletException("Invalid id");

                try {
                    User u = dao.findById(id);
                    if (u == null) throw new ServletException("User không tồn tại");

                    // Lấy tham số
                    String fullname  = p(req, "fullName");
                    String email     = p(req, "email");
                    String mobile    = p(req, "mobile");
                    String gender    = p(req, "gender");        // "true"/"false"
                    String role      = p(req, "role");          // "ADMIN"/"REPORTER"
                    String birthday  = p(req, "birthday");      // yyyy-MM-dd (yêu cầu không trống)
                    String password  = p(req, "password");      // có thể để trống
                    String confirm   = p(req, "confirmPassword");
                    String activated = req.getParameter("activated"); // checkbox

                    // Không được để trống các trường chính
                    if (fullname.isBlank() || email.isBlank() || mobile.isBlank() || birthday.isBlank()) {
                        req.setAttribute("error", "Không được để trống Họ tên, Email, Số điện thoại, Ngày sinh.");
                        String focus = fullname.isBlank() ? "fullName"
                                       : email.isBlank() ? "email"
                                       : mobile.isBlank() ? "mobile"
                                       : "birthday";
                        req.setAttribute("focusField", focus);
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Định dạng email
                    if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                        req.setAttribute("error", "Email không hợp lệ.");
                        req.setAttribute("focusField", "email");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }
                    // Định dạng SĐT
                    if (!mobile.matches("^\\d{10}$")) {
                        req.setAttribute("error", "Số điện thoại phải gồm đúng 10 chữ số.");
                        req.setAttribute("focusField", "mobile");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Trùng với tài khoản khác
                    if (dao.existsEmailExceptId(email, id)) {
                        req.setAttribute("error", "Email đã thuộc về tài khoản khác.");
                        req.setAttribute("focusField", "email");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }
                    if (dao.existsMobileExceptId(mobile, id)) {
                        req.setAttribute("error", "Số điện thoại đã thuộc về tài khoản khác.");
                        req.setAttribute("focusField", "mobile");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    boolean activatedBool = "on".equalsIgnoreCase(activated) || "true".equalsIgnoreCase(activated);

                    // Không thay đổi gì (pass trống coi như giữ nguyên)
                    boolean same =
                            fullname.equals(u.getFullname()) &&
                            email.equals(u.getEmail()) &&
                            mobile.equals(u.getMobile()) &&
                            (u.isGender() == ("true".equalsIgnoreCase(gender))) &&
                            (u.isRole()   == ("ADMIN".equalsIgnoreCase(role))) &&
                            ((u.getBirthday() != null ? u.getBirthday().toString() : "").equals(birthday)) &&
                            (activatedBool == u.isActivated()) &&
                            password.isBlank();

                    if (same) {
                        req.setAttribute("info", "Bạn chưa chỉnh sửa bất cứ thông tin nào.");
                        req.setAttribute("focusField", "fullName");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Áp dụng thay đổi
                    u.setFullname(fullname);
                    u.setEmail(email);
                    u.setMobile(mobile);
                    u.setGender("true".equalsIgnoreCase(gender));
                    u.setRole("ADMIN".equalsIgnoreCase(role));
                    try {
                        u.setBirthday(java.sql.Date.valueOf(birthday));
                    } catch (IllegalArgumentException ex) {
                        req.setAttribute("error", "Ngày sinh không hợp lệ (định dạng yyyy-MM-dd).");
                        req.setAttribute("focusField", "birthday");
                        req.setAttribute("item", u);
                        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                        return;
                    }

                    // Password: nếu để trống -> giữ nguyên; nếu có -> phải khớp confirm
                    if (!password.isBlank()) {
                        if (!password.equals(confirm)) {
                            req.setAttribute("error", "Mật khẩu nhập lại không khớp.");
                            req.setAttribute("focusField", "confirmPassword");
                            req.setAttribute("item", u);
                            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                            return;
                        }
                        u.setPassword(password); // TODO: hash nếu dùng băm
                    }

                    // Update chính
                    dao.update(u);
                    // Update Activated riêng
                    dao.setActivated(id, activatedBool);

                    // Thành công -> nhảy xuống #list
                    resp.sendRedirect(req.getContextPath() + "/admin/users?updated=1#list");
                    return;
                } catch (Exception e) {
                    req.setAttribute("error", "Lỗi cập nhật người dùng: " + e.getMessage());
                    req.setAttribute("focusField", "fullName");
                    req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                    return;
                }
            }


		            case "delete": {
		                int id = pInt(req, "id", -1);
		                if (id < 0) throw new ServletException("Invalid id");
		                dao.delete(id);
		
		                // Thông báo xóa thành công qua query param
		                resp.sendRedirect(req.getContextPath() + "/admin/users?deleted=1#list");
		                return;
		            }
                case "activate": { // bật/tắt Activated (nếu bạn dùng nút riêng)
                    int id = pInt(req, "id", -1);
                    boolean on = "on".equals(req.getParameter("activated")) || "true".equalsIgnoreCase(req.getParameter("activated"));
                    dao.setActivated(id, on);
                    break;
                }
                case "setRole": {  // đổi role nhanh (Admin/Reporter)
                    int id = pInt(req, "id", -1);
                    boolean admin = "ADMIN".equalsIgnoreCase(p(req, "role", ""));
                    dao.setRole(id, admin);
                    break;
                }
                default: /* no-op */ ;
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý CRUD người dùng", e);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    /* ====== helpers ====== */
    
    private String p(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? "" : v.trim();
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String by = p(req, "by", "");          // all/fullname/email/mobile
            String q  = p(req, "q", "");           // từ khóa
            List<User> items;

            if (q != null && !q.isBlank()) {
                items = dao.search(by, q);
            } else {
                items = dao.findAll();
            }

            req.setAttribute("items", items);
            req.setAttribute("categories", new CategoryDAO().findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách người dùng", e);
        }
    }


    /** Bind khi tạo mới: password là bắt buộc. */
    private User bindCreate(HttpServletRequest req) throws ParseException {
        User u = new User();
        u.setFullname(p(req, "fullName", ""));
        u.setEmail(p(req, "email", ""));
        u.setPassword(p(req, "password", "")); // TODO: hash nếu bạn dùng hash

        String bd = p(req, "birthday", null);
        if (bd != null && !bd.isBlank()) {
            df.setLenient(false);
            u.setBirthday(df.parse(bd));
        } else u.setBirthday(null);

        u.setGender(pBool(req, "gender"));           // checkbox hoặc "true/false"
        u.setMobile(p(req, "mobile", ""));
        u.setRole("ADMIN".equalsIgnoreCase(p(req, "role", ""))); // true=Admin
        u.setActivated(pBool(req, "activated"));
        return u;
    }

    /** Bind khi cập nhật: nếu password trống thì giữ nguyên. */
    private void bindUpdate(HttpServletRequest req, User u) throws ParseException {
        u.setFullname(p(req, "fullName", u.getFullname()));
        u.setEmail(p(req, "email", u.getEmail()));

        String pwd = p(req, "password", "");
        String confirm = p(req, "confirmPassword", "");

        if (!pwd.isBlank()) {
            if (!pwd.equals(confirm)) {
                throw new ParseException("Mật khẩu nhập lại không khớp", 0);
            }
            u.setPassword(pwd); // TODO: hash nếu cần
        }

        String bd = p(req, "birthday", null);
        if (bd != null && !bd.isBlank()) {
            df.setLenient(false);
            u.setBirthday(df.parse(bd));
        } else {
            u.setBirthday(null);
        }

        u.setGender(pBool(req, "gender"));
        u.setMobile(p(req, "mobile", u.getMobile()));
        u.setRole("ADMIN".equalsIgnoreCase(p(req, "role", u.isRole() ? "ADMIN" : "REPORTER")));
        u.setActivated(pBool(req, "activated"));
    }

    private String p(HttpServletRequest r, String k, String d) {
        String v = r.getParameter(k);
        return (v == null) ? d : v.trim();
    }

    private int pInt(HttpServletRequest r, String k, int def) {
        try { return Integer.parseInt(r.getParameter(k)); }
        catch (Exception e) { return def; }
    }

    /** Hỗ trợ cả checkbox ("on") lẫn "true/false". */
    private boolean pBool(HttpServletRequest r, String k) {
        String v = r.getParameter(k);
        if (v == null) return false;
        v = v.trim().toLowerCase();
        return "on".equals(v) || "true".equals(v) || "1".equals(v) || "male".equals(v);
    }
}
