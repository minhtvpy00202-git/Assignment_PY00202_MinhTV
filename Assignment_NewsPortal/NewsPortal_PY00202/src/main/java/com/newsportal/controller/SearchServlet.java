package com.newsportal.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.Category;
import com.newsportal.model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // UTF-8
        req.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("text/html; charset=UTF-8");

        String q = trim(req.getParameter("q"));
        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), 5);
        page = Math.max(1, page);
        size = Math.max(1, Math.min(size, 50)); // giới hạn kích thước trang

        req.setAttribute("q", q == null ? "" : q);
        req.setAttribute("page", page);
        req.setAttribute("size", size);

        try {
            // Navbar + sidebar
            req.setAttribute("categories", safe(() -> categoryDAO.findAll(), Collections.<Category>emptyList()));
            req.setAttribute("hotList",    safe(() -> newsDAO.findTopHot(5),  Collections.<News>emptyList()));
            req.setAttribute("newList",    safe(() -> newsDAO.findTopNew(5),  Collections.<News>emptyList()));

            // recent từ cookie
            List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
            req.setAttribute("recentList", findNewsByIdsPreserveOrder(recentIds));

            // Kết quả tìm kiếm (lấy tối đa 400 bản ghi rồi cắt phân trang ở servlet)
            List<News> all = (q == null || q.isEmpty())
                    ? Collections.<News>emptyList()
                    : safe(() -> newsDAO.search(q, 400), Collections.<News>emptyList());

            int total = all.size();
            int totalPages = (int) Math.ceil(total / (double) size);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;

            int from = (page - 1) * size;
            int to   = Math.min(from + size, total);
            List<News> pageResults = total == 0 ? Collections.emptyList() : all.subList(from, to);

            req.setAttribute("results", pageResults);
            req.setAttribute("resultCount", total);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("page", page); // cập nhật nếu bị điều chỉnh

            // Page title
            String pageTitle = (q != null && !q.isEmpty()) ? ("Tìm kiếm: " + q + " - NewsPortal")
                                                           : "Tìm kiếm - NewsPortal";
            req.setAttribute("pageTitle", pageTitle);

            req.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra khi tìm kiếm. Vui lòng thử lại.");
            req.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String q = trim(req.getParameter("q"));
        if (q != null && !q.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/search?q=" +
                    URLEncoder.encode(q, StandardCharsets.UTF_8));
        } else {
            resp.sendRedirect(req.getContextPath() + "/search");
        }
    }

    /* ================= helpers ================= */

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    @FunctionalInterface
    interface DaoCall<T> { T run() throws Exception; }
    private static <T> T safe(DaoCall<T> f, T fallback) {
        try { return f.run(); } catch (Exception e) { return fallback; }
    }

    private List<Integer> readRecentIdsFromCookie(HttpServletRequest req, String name, int limit) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) return Collections.emptyList();
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                String val = c.getValue();
                if (val == null || val.isBlank()) return Collections.emptyList();
                String decoded = java.net.URLDecoder.decode(val, StandardCharsets.UTF_8);
                String[] parts = decoded.split("\\|");
                List<Integer> out = new ArrayList<>();
                for (String p : parts) {
                    if (p.matches("\\d+")) {
                        out.add(Integer.parseInt(p));
                        if (out.size() >= limit) break;
                    }
                }
                return out;
            }
        }
        return Collections.emptyList();
    }

    private List<News> findNewsByIdsPreserveOrder(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyList();
        List<News> out = new ArrayList<>();
        for (Integer id : ids) {
            try {
                News n = newsDAO.findById(id);
                if (n != null) out.add(n);
            } catch (Exception ignored) {}
        }
        return out;
    }
}
