package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.UserDAO;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
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
                    User u = bindCreate(req);
                    dao.create(u);
                    break;
                }
                case "update": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    User u = dao.findById(id);
                    if (u == null) throw new ServletException("User không tồn tại");
                    bindUpdate(req, u);
                    dao.update(u);
                    break;
                }
                case "delete": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    dao.delete(id);
                    break;
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

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<User> items = dao.findAll();
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
        if (!pwd.isBlank()) {
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
