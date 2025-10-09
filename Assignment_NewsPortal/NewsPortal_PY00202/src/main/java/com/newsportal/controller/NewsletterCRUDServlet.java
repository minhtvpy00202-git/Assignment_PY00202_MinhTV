package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsletterDAO;
import com.newsportal.model.Newsletter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/newsletter")
public class NewsletterCRUDServlet extends HttpServlet {
    private final NewsletterDAO dao = new NewsletterDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Có thể hỗ trợ edit theo email (load để tick checkbox), còn không thì chỉ list
        list(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = p(req, "action", "list");
        String email  = p(req, "email", "");

        try {
            switch (action) {
                case "create": { // đăng ký mới
                    dao.subscribe(email);
                    break;
                }
                case "update": { // bật/tắt
                    boolean enabled = pBool(req, "enabled");
                    if (enabled) dao.subscribe(email); else dao.unsubscribe(email);
                    break;
                }
                case "delete": { // coi như hủy đăng ký
                    dao.unsubscribe(email);
                    break;
                }
                default: /* no-op */ ;
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý Newsletter", e);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/newsletter");
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Newsletter> items = dao.findAll();
            req.setAttribute("items", items);
            req.setAttribute("categories", new CategoryDAO().findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/newsletter.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách newsletter", e);
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
        return "on".equals(v) || "true".equals(v) || "1".equals(v);
    }
}
