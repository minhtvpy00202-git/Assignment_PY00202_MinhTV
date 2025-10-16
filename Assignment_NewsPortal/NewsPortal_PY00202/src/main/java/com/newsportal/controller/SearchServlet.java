package com.newsportal.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.Category;
import com.newsportal.model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // UTF-8 cho request/response + Content-Type
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("text/html; charset=UTF-8");

        String query = request.getParameter("q");
        if (query != null) query = query.trim();
        // luôn set lại q để input trên JSP giữ giá trị
        request.setAttribute("q", query == null ? "" : query);

        try {
            // Navbar cần categories
            List<Category> categories = categoryDAO.findAll();
            request.setAttribute("categories", categories);

            List<News> results = Collections.emptyList();
            int resultCount = 0;

            if (query != null && !query.isEmpty()) {
                // có thể chặn query quá dài / ký tự lạ tùy nhu cầu
                results = newsDAO.search(query, 50);
                if (results != null) resultCount = results.size();
                System.out.println("Search query: '" + query + "' - Found: " + resultCount + " results");
            }

            request.setAttribute("results", results);
            request.setAttribute("resultCount", resultCount);

            // Page title
            String pageTitle = (query != null && !query.isEmpty())
                    ? "Tìm kiếm: " + query + " - NewsPortal"
                    : "Tìm kiếm - NewsPortal";
            request.setAttribute("pageTitle", pageTitle);

            request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tìm kiếm. Vui lòng thử lại.");

            // cố gắng nạp categories nếu lỗi
            try {
                List<Category> categories = categoryDAO.findAll();
                request.setAttribute("categories", categories);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String query = request.getParameter("q");
        if (query != null) query = query.trim();

        if (query != null && !query.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/search?q=" +
                    java.net.URLEncoder.encode(query, StandardCharsets.UTF_8));
        } else {
            response.sendRedirect(request.getContextPath() + "/search");
        }
    }
}
