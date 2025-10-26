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

@WebServlet({ "/home", "/most-viewed", "/latest", "/recent" })
public class HomeServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        final String lang = getLang(req); // "vi" mặc định
        final String path = req.getServletPath();

        switch (path) {
            case "/home": {
                try {
                    // Menu (localized)
                    List<Category> categories = safeList(() -> categoryDAO.findAllLocalized(lang));
                    if (categories.isEmpty()) categories = safeList(categoryDAO::findAll); // fallback
                    req.setAttribute("categories", categories);

                    // Tin trang nhất (localized)
                    List<News> approvedNews = safeList(() -> newsDAO.findHomeApprovedLocalized(lang, 10));
                    if (approvedNews.isEmpty()) approvedNews = safeList(() -> newsDAO.findHome(10)); // fallback
                    req.setAttribute("approvedNews", approvedNews);

                    // Sidebar
                    List<News> hotList = safeList(() -> newsDAO.findTopHotLocalized(lang, 5));
                    if (hotList.isEmpty()) hotList = safeList(() -> newsDAO.findTopHot(5));
                    req.setAttribute("hotList", hotList);

                    List<News> newList = safeList(() -> newsDAO.findTopNewLocalized(lang, 5));
                    if (newList.isEmpty()) newList = safeList(() -> newsDAO.findTopNew(5));
                    req.setAttribute("newList", newList);

                    // Recent
                    List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
                    req.setAttribute("recentList", findNewsByIdsPreserveOrderLocalized(recentIds, lang));

                    req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
                } catch (Exception e) {
                    e.printStackTrace();
                    req.setAttribute("error", "Không tải được dữ liệu trang chủ: " + e.getMessage());
                    req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
                }
                return;
            }

            case "/most-viewed": {
                req.setAttribute("items", safeList(() -> newsDAO.findTopHotLocalized(lang, 5)));
                req.setAttribute("pageTitle", "Most Viewed");
                req.setAttribute("mode", "most");

                List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
                req.setAttribute("recentList", findNewsByIdsPreserveOrderLocalized(recentIds, lang));
                req.setAttribute("newList", safeList(() -> newsDAO.findTopNewLocalized(lang, 5)));

                req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
                return;
            }

            case "/latest": {
                req.setAttribute("items", safeList(() -> newsDAO.findTopNewLocalized(lang, 5)));
                req.setAttribute("pageTitle", "Latest News");
                req.setAttribute("mode", "latest");

                List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
                req.setAttribute("recentList", findNewsByIdsPreserveOrderLocalized(recentIds, lang));
                req.setAttribute("hotList", safeList(() -> newsDAO.findTopHotLocalized(lang, 5)));

                req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
                return;
            }

            case "/recent": {
                List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
                req.setAttribute("items", findNewsByIdsPreserveOrderLocalized(recentIds, lang));
                req.setAttribute("pageTitle", "Recent");
                req.setAttribute("mode", "recent");

                req.setAttribute("hotList", safeList(() -> newsDAO.findTopHotLocalized(lang, 5)));
                req.setAttribute("newList", safeList(() -> newsDAO.findTopNewLocalized(lang, 5)));

                req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
                return;
            }

            default: {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

    /* ================= Helpers ================= */

    private String getLang(HttpServletRequest req) {
        String l = (String) req.getSession().getAttribute("lang");
        return (l == null || l.isBlank()) ? "vi" : l;
    }

    @FunctionalInterface
    interface DaoCall<T> { T run() throws Exception; }

    private static <E> List<E> safeList(DaoCall<List<E>> call) {
        try {
            return call.run();
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

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

    /** Lấy tin theo danh sách id và giữ nguyên thứ tự; ưu tiên bản dịch theo lang */
    private List<News> findNewsByIdsPreserveOrderLocalized(List<Integer> ids, String lang) {
        if (ids == null || ids.isEmpty()) return Collections.emptyList();
        List<News> out = new ArrayList<>();
        for (Integer id : ids) {
            try {
                News n = newsDAO.findByIdLocalized(id, lang);
                if (n == null) n = newsDAO.findById(id); // fallback khi chưa có bản dịch
                if (n != null) out.add(n);
            } catch (Exception ignored) {}
        }
        return out;
    }
}
