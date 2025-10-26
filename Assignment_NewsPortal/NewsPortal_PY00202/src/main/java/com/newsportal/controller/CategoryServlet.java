package com.newsportal.controller;

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

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/category")
public class CategoryServlet extends HttpServlet {
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final NewsDAO newsDAO = new NewsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- i18n: lấy lang từ session, mặc định "vi" và dùng biến final ---
        String sessLang = (String) req.getSession().getAttribute("lang");
        final String finalLang = (sessLang == null || sessLang.isBlank()) ? "vi" : sessLang;

        // --- lấy id chuyên mục ---
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        final int categoryId;
        try {
            categoryId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid category id");
            return;
        }

        try {
            // 1) Chuyên mục hiện tại (đã dịch theo lang)
            Category current = categoryDAO.findByIdLocalized(categoryId, finalLang);
            if (current == null) {
                // fallback: thử lấy bản gốc nếu chưa có bản dịch
                current = categoryDAO.findById(categoryId);
            }
            if (current == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Category not found");
                return;
            }
            req.setAttribute("currentCategory", current);

            // 2) Danh sách tin theo chuyên mục (đã dịch), mới nhất trước
            List<News> news = safeList(() -> newsDAO.findByCategoryLocalized(categoryId, finalLang));
            if (news.isEmpty()) {
                // fallback sang bản gốc nếu chưa có bản dịch
                news = safeList(() -> newsDAO.findByCategory(categoryId));
            }
            req.setAttribute("news", news);

            // 3) Menu chuyên mục (đã dịch)
            List<Category> categories = safeList(() -> categoryDAO.findAllLocalized(finalLang));
            if (categories.isEmpty()) {
                categories = safeList(categoryDAO::findAll);
            }
            req.setAttribute("categories", categories);

            // ===== Sidebar =====
            // a) 5 xem nhiều nhất
            List<News> hotList = safeList(() -> newsDAO.findTopHotLocalized(finalLang, 5));
            if (hotList.isEmpty()) hotList = safeList(() -> newsDAO.findTopHot(5));
            req.setAttribute("hotList", hotList);

            // b) 5 mới nhất
            List<News> newList = safeList(() -> newsDAO.findTopNewLocalized(finalLang, 5));
            if (newList.isEmpty()) newList = safeList(() -> newsDAO.findTopNew(5));
            req.setAttribute("newList", newList);

            // c) 5 bài đã xem gần đây (cookie "recent")
            List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
            List<News> recentList = findNewsByIdsPreserveOrderLocalized(recentIds, finalLang);
            req.setAttribute("recentList", recentList);
            // ====================

            // Forward
            req.getRequestDispatcher("/WEB-INF/views/category.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /* ================= Helpers ================= */

    @FunctionalInterface
    interface DaoCall<T> { T run() throws Exception; }

    private static <E> List<E> safeList(DaoCall<List<E>> call) {
        try {
            return call.run();
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /** Đọc danh sách id từ cookie, giữ tối đa limit phần tử */
    private List<Integer> readRecentIdsFromCookie(HttpServletRequest req, String name, int limit) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) return Collections.emptyList();

        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                String val = c.getValue();
                if (val == null || val.isBlank()) return Collections.emptyList();

                String decoded = URLDecoder.decode(val, StandardCharsets.UTF_8);
                return Arrays.stream(decoded.split("\\|"))
                        .map(String::trim)
                        .filter(s -> s.matches("\\d+"))
                        .map(Integer::parseInt)
                        .distinct()
                        .limit(limit)
                        .collect(Collectors.toList());
            }
        }
        return Collections.emptyList();
    }

    /** Lấy tin theo danh sách id và GIỮ nguyên thứ tự id (bản dịch nếu có) */
    private List<News> findNewsByIdsPreserveOrderLocalized(List<Integer> ids, String lang) {
        if (ids == null || ids.isEmpty()) return Collections.emptyList();
        List<News> out = new ArrayList<>();
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
