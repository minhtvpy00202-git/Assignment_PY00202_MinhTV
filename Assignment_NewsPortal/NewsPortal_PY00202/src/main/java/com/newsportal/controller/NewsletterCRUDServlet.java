package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsletterDAO;
import com.newsportal.model.Newsletter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/admin/newsletter")
public class NewsletterCRUDServlet extends HttpServlet {
    private final NewsletterDAO dao = new NewsletterDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        boolean includeDeleted = pBool(req, "includeDeleted"); // ?includeDeleted=1 để xem cả xóa mềm
        list(req, resp, includeDeleted);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = p(req, "action", "list");
        String email  = p(req, "email", "");
        boolean includeDeleted = pBool(req, "includeDeleted"); // giữ lại trạng thái lọc khi redirect
        
        Integer categoryId = parseNullableInt(p(req, "categoryId", null));

        try {
            switch (action) {
                case "create": { // đăng ký mới / hoặc revive nếu tồn tại
                    requireEmail(email);
                    dao.subscribe(email, categoryId);
                    break;
                }
                case "update": { // bật/tắt nhận thư
                	requireEmail(email);
                    boolean enabled = pBool(req, "enabled");
                    dao.updateEnabled(email, enabled);
                    break;
                }
                case "delete": { // xóa mềm (ẩn hoàn toàn)
                    requireEmail(email);
                    dao.softDelete(email);
                    break;
                }
                case "restore": { // khôi phục bản ghi đã xóa mềm
                    requireEmail(email);
                    dao.restore(email);
                    break;
                }
                default: /* no-op */ ;
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý Newsletter: " + e.getMessage(), e);
        }

        // giữ tham số includeDeleted khi quay lại trang
        String qs = includeDeleted ? "?includeDeleted=1" : "";
        resp.sendRedirect(req.getContextPath() + "/admin/newsletter" + qs);
    }

    private void list(HttpServletRequest req, HttpServletResponse resp, boolean includeDeleted)
            throws ServletException, IOException {
        try {
            List<Newsletter> items = includeDeleted ? dao.findAll(true) : dao.findAllActive();
            req.setAttribute("items", items);
            req.setAttribute("includeDeleted", includeDeleted);

            String lang = (String) req.getSession().getAttribute("lang");
            if (lang == null || lang.isBlank()) lang = "vi";

            CategoryDAO categoryDAO = new CategoryDAO();
            // Dùng dữ liệu đã địa phương hoá
            req.setAttribute("categories", categoryDAO.findAllLocalized(lang));
            req.setAttribute("categoryMap", categoryDAO.toIdNameMapLocalized(lang));

            req.getRequestDispatcher("/WEB-INF/views/admin/newsletter.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách newsletter: " + e.getMessage(), e);
        }
    }



    private static void requireEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
    }

    private String p(HttpServletRequest r, String k, String d) {
        String v = r.getParameter(k);
        return (v == null) ? d : v.trim();
    }

    private boolean pBool(HttpServletRequest r, String k) {
        String v = r.getParameter(k);
        if (v == null) return false;
        v = v.trim().toLowerCase();
        return "on".equals(v) || "true".equals(v) || "1".equals(v) || "yes".equals(v);
    }
    
    private Integer parseNullableInt(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.isEmpty()) return null;
        try { return Integer.valueOf(s); } catch (Exception e) { return null; }
    }
}
