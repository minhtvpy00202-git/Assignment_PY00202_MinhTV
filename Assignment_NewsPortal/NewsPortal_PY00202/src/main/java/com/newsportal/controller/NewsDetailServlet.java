package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet({"/news-detail", "/news/*"})
public class NewsDetailServlet extends HttpServlet {
    private static final String RECENT_COOKIE = "recent";
    private static final int RECENT_KEEP = 50;

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        final String lang = (String) req.getSession().getAttribute("lang") == null
                ? "vi"
                : (String) req.getSession().getAttribute("lang");

        try {
            int id = parseId(req);
            if (id <= 0) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
                return;
            }

            // Lấy bài viết theo ngôn ngữ
            News news = newsDAO.findByIdLocalized(id, lang);
            if (news == null) {
                // fallback: thử lấy bản gốc (phòng trường hợp chưa có bản dịch)
                news = newsDAO.findById(id);
            }
            if (news == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bài viết");
                return;
            }

            // Public hay trang duyệt?
            String sp = req.getServletPath(); // "/news-detail" hoặc "/news"
            boolean isPublic = "/news".equals(sp);
            req.setAttribute("isPublic", isPublic);

            // tăng view + ghi cookie recent (không phụ thuộc ngôn ngữ)
            newsDAO.increaseViewCount(news.getId());
            pushRecentCookie(req, resp, news.getId());

            // Danh mục cho header (localized)
            try {
                req.setAttribute("categories", categoryDAO.findAllLocalized(lang));
            } catch (Exception ignore) {
                req.setAttribute("categories", java.util.Collections.emptyList());
            }

            // Tin liên quan (localized, chỉ public)
            if (isPublic) {
                try {
                    List<News> related = newsDAO.findRelatedLocalized(lang, news.getCategoryId(), news.getId(), 5);
                    req.setAttribute("related", related != null ? related : java.util.Collections.emptyList());
                } catch (Exception ignore) {
                    req.setAttribute("related", java.util.Collections.emptyList());
                }
            } else {
                req.setAttribute("related", java.util.Collections.emptyList());
            }

            // ====== DỮ LIỆU SIDEBAR (localized, giống Home) ======
            req.setAttribute("hotList", safeList(() -> newsDAO.findTopHotLocalized(lang, 5)));
            req.setAttribute("newList", safeList(() -> newsDAO.findTopNewLocalized(lang, 5)));
            List<Integer> recentIds = readRecentIdsFromCookie(req, RECENT_COOKIE, 5);
            req.setAttribute("recentList", findNewsByIdsPreserveOrderLocalized(recentIds, lang));
            // =====================================================

            req.setAttribute("news", news);
            req.setAttribute("ref", req.getParameter("ref"));

            req.getRequestDispatcher("/WEB-INF/views/news-detail.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    // ---------- Helpers ----------
    @FunctionalInterface
    interface DaoCall<T> { T run() throws Exception; }

    private static <E> java.util.List<E> safeList(DaoCall<java.util.List<E>> call) {
        try { return call.run(); } catch (Exception e) { return java.util.Collections.emptyList(); }
    }

    private int parseId(HttpServletRequest req) {
        String qid = req.getParameter("id");
        if (qid != null && qid.matches("\\d+")) return Integer.parseInt(qid);
        String path = req.getPathInfo(); // với mapping "/news/*" sẽ là "/{id}"
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
            for (Cookie c : cookies) if (RECENT_COOKIE.equals(c.getName())) { cur = c.getValue(); break; }
        }

        java.util.LinkedHashSet<Integer> set = new java.util.LinkedHashSet<>();
        if (cur != null && !cur.isBlank()) {
            String decoded = java.net.URLDecoder.decode(cur, java.nio.charset.StandardCharsets.UTF_8);
            for (String s : decoded.split("\\|")) if (s.matches("\\d+")) set.add(Integer.parseInt(s));
        }

        set.remove(newsId);
        java.util.LinkedList<Integer> list = new java.util.LinkedList<>(set);
        list.addFirst(newsId);
        while (list.size() > RECENT_KEEP) list.removeLast();

        String raw = list.stream().map(String::valueOf).collect(java.util.stream.Collectors.joining("|"));
        String encoded = java.net.URLEncoder.encode(raw, java.nio.charset.StandardCharsets.UTF_8);

        Cookie cookie = new Cookie(RECENT_COOKIE, encoded);
        String ctx = req.getContextPath();
        cookie.setPath((ctx == null || ctx.isEmpty()) ? "/" : ctx);
        cookie.setHttpOnly(true);
        cookie.setMaxAge(60 * 60 * 24 * 30); // 30 ngày
        resp.addCookie(cookie);
    }

    private java.util.List<Integer> readRecentIdsFromCookie(HttpServletRequest req, String name, int limit) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) return java.util.Collections.emptyList();
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                String val = c.getValue();
                if (val == null || val.isBlank()) return java.util.Collections.emptyList();
                String decoded = java.net.URLDecoder.decode(val, java.nio.charset.StandardCharsets.UTF_8);
                return java.util.Arrays.stream(decoded.split("\\|"))
                        .map(String::trim).filter(s -> s.matches("\\d+"))
                        .map(Integer::parseInt).distinct().limit(limit)
                        .collect(java.util.stream.Collectors.toList());
            }
        }
        return java.util.Collections.emptyList();
    }

    // Lấy theo danh sách id và GIỮ nguyên thứ tự, dùng bản dịch theo lang
    private java.util.List<News> findNewsByIdsPreserveOrderLocalized(java.util.List<Integer> ids, String lang) {
        if (ids == null || ids.isEmpty()) return java.util.Collections.emptyList();
        java.util.List<News> out = new java.util.ArrayList<>();
        for (Integer id : ids) {
            try {
                News n = newsDAO.findByIdLocalized(id, lang);
                if (n == null) n = newsDAO.findById(id); // fallback
                if (n != null) out.add(n);
            } catch (Exception ignored) {}
        }
        return out;
    }
}
