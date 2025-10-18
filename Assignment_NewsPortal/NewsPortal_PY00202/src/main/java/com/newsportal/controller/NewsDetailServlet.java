package com.newsportal.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

import com.newsportal.dao.CategoryDAO;  // <-- NHỚ import
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({"/news-detail", "/news/*"})
public class NewsDetailServlet extends HttpServlet {

    private static final String RECENT_COOKIE = "recent";
    private static final int RECENT_KEEP = 50;

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO(); // <-- THÊM field

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int id = parseId(req);
            if (id <= 0) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
                return;
            }

            News news = newsDAO.findById(id);
            if (news == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bài viết");
                return;
            }

            // Xác định ngữ cảnh: public hay approve (admin)
            // - /news/*  => servletPath = "/news"  => public
            // - /news-detail => servletPath = "/news-detail" => admin xem/duyệt
            String sp = req.getServletPath();
            boolean isPublic = "/news".equals(sp);
            req.setAttribute("isPublic", isPublic);

            // tăng view + cookie (vẫn giữ như cũ)
            newsDAO.increaseViewCount(id);
            pushRecentCookie(req, resp, id);

            // Danh mục cho header
            try {
                req.setAttribute("categories", categoryDAO.findAll());
            } catch (Exception ignore) {
                req.setAttribute("categories", java.util.Collections.emptyList());
            }

            // Chỉ public mới cần “tin cùng chuyên mục”
            if (isPublic) {
                try {
                    List<News> related = newsDAO.findRelated(news.getCategoryId(), news.getId(), 5);
                    if (related == null) related = java.util.Collections.emptyList();
                    req.setAttribute("related", related);
                } catch (Exception ignore) {
                    req.setAttribute("related", java.util.Collections.emptyList());
                }
            } else {
                // chế độ approve: không hiển thị list liên quan
                req.setAttribute("related", java.util.Collections.emptyList());
            }

            req.setAttribute("news", news);
            // truyền param ref (nếu có) để JSP hiện nút duyệt/từ chối
            req.setAttribute("ref", req.getParameter("ref"));

            req.getRequestDispatcher("/WEB-INF/views/news-detail.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }


    // ---------- Helpers giữ nguyên ----------
    private int parseId(HttpServletRequest req) {
        String qid = req.getParameter("id");
        if (qid != null && qid.matches("\\d+")) return Integer.parseInt(qid);
        String path = req.getPathInfo();
        if (path != null && path.length() > 1) {
            String s = path.substring(1);
            if (s.matches("\\d+")) return Integer.parseInt(s);
        }
        return -1;
    }

    private void pushRecentCookie(HttpServletRequest req, HttpServletResponse resp, int newsId) {
        String cur = null;
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if (RECENT_COOKIE.equals(c.getName())) { cur = c.getValue(); break; }
            }
        }

        LinkedHashSet<Integer> set = new LinkedHashSet<>();
        if (cur != null && !cur.isBlank()) {
            String decoded = java.net.URLDecoder.decode(cur, StandardCharsets.UTF_8);
            for (String s : decoded.split("\\|")) {
                if (s.matches("\\d+")) set.add(Integer.parseInt(s));
            }
        }

        set.remove(newsId);
        LinkedList<Integer> list = new LinkedList<>(set);
        list.addFirst(newsId);
        while (list.size() > RECENT_KEEP) list.removeLast();

        String raw = list.stream().map(String::valueOf).collect(Collectors.joining("|"));
        String encoded = URLEncoder.encode(raw, StandardCharsets.UTF_8);

        Cookie cookie = new Cookie(RECENT_COOKIE, encoded);
        String ctx = req.getContextPath();
        cookie.setPath((ctx == null || ctx.isEmpty()) ? "/" : ctx);
        cookie.setHttpOnly(true);
        cookie.setMaxAge(60 * 60 * 24 * 30);
        resp.addCookie(cookie);
    }
}
