package com.newsportal.controller;

import com.newsportal.dao.UserDAO;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class UserCRUDServlet extends HttpServlet {
    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = p(req, "action", "list");

        try {
            if ("edit".equals(action)) {
                int id = pInt(req, "id", -1);
                if (id < 0) { resp.sendError(400, "Invalid id"); return; }
                req.setAttribute("item", dao.findById(id));
            }

            // Luôn nạp cả danh sách đang hoạt động & thùng rác
            list(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách người dùng", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = p(req, "action", "list");

        try {
            switch (action) {

                /* ================== CREATE ================== */
                case "create": {
                    String fullname  = p(req, "fullName");
                    String birthday  = p(req, "birthday");      // yyyy-MM-dd (bắt buộc)
                    String password  = p(req, "password");
                    String confirm   = p(req, "confirmPassword");
                    String gender    = p(req, "gender");        // "true"/"false"
                    String mobile    = p(req, "mobile");
                    String email     = p(req, "email");
                    String role      = p(req, "role");          // "ADMIN"/"REPORTER"
                    boolean activated = pBool(req, "activated"); // checkbox

                    // Bắt buộc nhập đủ các trường
                    if (fullname.isBlank() || email.isBlank() || mobile.isBlank()
                            || birthday.isBlank() || password.isBlank() || confirm.isBlank()) {
                        fail(req, resp, "Vui lòng nhập đầy đủ các trường bắt buộc.",
                                firstMissing(fullname, email, mobile, birthday, password, confirm));
                        return;
                    }

                    // Email
                    if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                        fail(req, resp, "Email không hợp lệ.", "email");
                        return;
                    }

                    // Số điện thoại: đúng 10 số
                    if (!mobile.matches("^\\d{10}$")) {
                        fail(req, resp, "Số điện thoại phải gồm đúng 10 chữ số.", "mobile");
                        return;
                    }

                    // Xác nhận mật khẩu
                    if (!password.equals(confirm)) {
                        fail(req, resp, "Mật khẩu nhập lại không khớp.", "confirmPassword");
                        return;
                    }

                    // Trùng email/mobile
                    if (dao.existsEmail(email)) {
                        fail(req, resp, "Email đã tồn tại trong hệ thống.", "email");
                        return;
                    }
                    if (dao.existsMobile(mobile)) {
                        fail(req, resp, "Số điện thoại đã tồn tại trong hệ thống.", "mobile");
                        return;
                    }

                    // Build user
                    User u = new User();
                    u.setFullname(fullname);
                    try {
                        u.setBirthday(java.sql.Date.valueOf(birthday));
                    } catch (IllegalArgumentException ex) {
                        fail(req, resp, "Ngày sinh không hợp lệ (định dạng yyyy-MM-dd).", "birthday");
                        return;
                    }
                    u.setPassword(password); // TODO: hash nếu dùng băm
                    u.setGender("true".equalsIgnoreCase(gender));
                    u.setMobile(mobile);
                    u.setEmail(email);
                    u.setRole("ADMIN".equalsIgnoreCase(role));
                    u.setActivated(activated);

                    dao.createAdminForm(u);
                    resp.sendRedirect(req.getContextPath() + "/admin/users?created=1#list");
                    return;
                }

                /* ================== UPDATE ================== */
                case "update": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");

                    User u = dao.findById(id);
                    if (u == null) throw new ServletException("User không tồn tại");

                    String fullname  = p(req, "fullName");
                    String email     = p(req, "email");
                    String mobile    = p(req, "mobile");
                    String birthday  = p(req, "birthday");
                    String gender    = p(req, "gender");      // "true"/"false"
                    String role      = p(req, "role");        // "ADMIN"/"REPORTER"
                    String password  = p(req, "password");    // có thể trống
                    String confirm   = p(req, "confirmPassword");
                    boolean activated = pBool(req, "activated");

                    // Không được trống các trường chính
                    if (fullname.isBlank() || email.isBlank() || mobile.isBlank() || birthday.isBlank()) {
                        fail(req, resp, "Không được để trống Họ tên, Email, Số điện thoại, Ngày sinh.",
                                fullname.isBlank() ? "fullName" : email.isBlank() ? "email" :
                                mobile.isBlank() ? "mobile" : "birthday", u);
                        return;
                    }

                    // Email & SĐT hợp lệ
                    if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                        fail(req, resp, "Email không hợp lệ.", "email", u);
                        return;
                    }
                    if (!mobile.matches("^\\d{10}$")) {
                        fail(req, resp, "Số điện thoại phải gồm đúng 10 chữ số.", "mobile", u);
                        return;
                    }

                    // Trùng với tài khoản khác
                    if (dao.existsEmailExceptId(email, id)) {
                        fail(req, resp, "Email đã thuộc về tài khoản khác.", "email", u);
                        return;
                    }
                    if (dao.existsMobileExceptId(mobile, id)) {
                        fail(req, resp, "Số điện thoại đã thuộc về tài khoản khác.", "mobile", u);
                        return;
                    }

                    // Nếu không đổi mật khẩu → bỏ qua; nếu đổi → phải khớp confirm
                    if (!password.isBlank() && !password.equals(confirm)) {
                        fail(req, resp, "Mật khẩu nhập lại không khớp.", "confirmPassword", u);
                        return;
                    }

                    // Áp thay đổi
                    u.setFullname(fullname);
                    u.setEmail(email);
                    u.setMobile(mobile);
                    u.setGender("true".equalsIgnoreCase(gender));
                    u.setRole("ADMIN".equalsIgnoreCase(role));
                    try {
                        u.setBirthday(java.sql.Date.valueOf(birthday));
                    } catch (IllegalArgumentException ex) {
                        fail(req, resp, "Ngày sinh không hợp lệ (định dạng yyyy-MM-dd).", "birthday", u);
                        return;
                    }
                    if (!password.isBlank()) u.setPassword(password); // TODO: hash

                    dao.update(u);
                    dao.setActivated(id, activated);

                    resp.sendRedirect(req.getContextPath() + "/admin/users?updated=1#list");
                    return;
                }

                /* ================== SOFT DELETE ================== */
                case "delete": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");

                    // Không cho tự xóa chính mình (tuỳ chính sách)
                    User me = (User) req.getSession().getAttribute("authUser");
                    if (me != null && me.getId() == id)
                        throw new ServletException("Không thể xóa tài khoản đang đăng nhập");

                    dao.delete(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/users?deleted=1#list");
                    return;
                }

                /* ================== RESTORE ================== */
                case "restore": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    dao.restore(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/users?restored=1#trash");
                    return;
                }

                /* ================== HARD DELETE ================== */
                case "purge": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");

                    User me = (User) req.getSession().getAttribute("authUser");
                    if (me != null && me.getId() == id)
                        throw new ServletException("Không thể xóa vĩnh viễn tài khoản đang đăng nhập");

                    // Chú ý FK: nếu News.ReporterId FK -> khuyến nghị ON DELETE SET NULL
                    dao.hardDelete(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/users?purged=1#trash");
                    return;
                }

                /* ================== QUICK TOGGLES (nếu cần) ================== */
                case "activate": {
                    int id = pInt(req, "id", -1);
                    boolean on = pBool(req, "activated");
                    dao.setActivated(id, on);
                    break;
                }
                case "setRole": {
                    int id = pInt(req, "id", -1);
                    boolean admin = "ADMIN".equalsIgnoreCase(p(req, "role", ""));
                    dao.setRole(id, admin);
                    break;
                }

                default: /* no-op */ ;
            }
        } catch (Exception e) {
            // Trường hợp lỗi không mong muốn, hiện trên trang
            req.setAttribute("error", e.getMessage());
            // Nạp lại bảng trước khi forward
            try {
                req.setAttribute("items", dao.findAllActive());
                req.setAttribute("deletedItems", dao.findDeleted());
            } catch (Exception ignore) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
            return;
        }

        // Mặc định quay lại trang
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    /* ================== Helpers ================== */

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String by = p(req, "by", "all");
        String q  = p(req, "q", "");
        try {
            List<User> items = (q != null && !q.isBlank())
                    ? dao.search(by, q)
                    : dao.findAllActive();
            req.setAttribute("items", items);
            req.setAttribute("deletedItems", dao.findDeleted());
            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách người dùng", e);
        }
    }

    private String p(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? "" : v.trim();
    }

    private String p(HttpServletRequest r, String k, String d) {
        String v = r.getParameter(k);
        return (v == null) ? d : v.trim();
    }

    private int pInt(HttpServletRequest r, String k, int def) {
        try { return Integer.parseInt(r.getParameter(k)); }
        catch (Exception e) { return def; }
    }

    /** Hỗ trợ cả checkbox ("on") lẫn "true/false"/"1". */
    private boolean pBool(HttpServletRequest r, String k) {
        String v = r.getParameter(k);
        if (v == null) return false;
        v = v.trim().toLowerCase();
        return "on".equals(v) || "true".equals(v) || "1".equals(v) || "yes".equals(v);
    }

    private String firstMissing(String fullname, String email, String mobile,
                                String birthday, String password, String confirm) {
        if (fullname.isBlank()) return "fullName";
        if (email.isBlank())    return "email";
        if (mobile.isBlank())   return "mobile";
        if (birthday.isBlank()) return "birthday";
        if (password.isBlank()) return "password";
        return "confirmPassword";
    }

    /** Hiển thị lỗi + focus và forward về trang, đồng thời nạp 2 bảng. */
    private void fail(HttpServletRequest req, HttpServletResponse resp, String msg, String focus)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.setAttribute("focusField", focus);
        try {
            req.setAttribute("items", dao.findAllActive());
            req.setAttribute("deletedItems", dao.findDeleted());
        } catch (Exception ignore) {}
        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    /** Overload: khi update, cần giữ lại `item` đã load. */
    private void fail(HttpServletRequest req, HttpServletResponse resp, String msg, String focus, User item)
            throws ServletException, IOException {
        req.setAttribute("item", item);
        fail(req, resp, msg, focus);
    }
}
