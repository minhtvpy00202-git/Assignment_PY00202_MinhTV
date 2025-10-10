package com.newsportal.controller;

import java.io.IOException;
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

/**
 * Servlet xử lý chức năng tìm kiếm bài viết
 */
@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private NewsDAO newsDAO = new NewsDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Lấy từ khóa tìm kiếm
            String query = request.getParameter("q");
            if (query != null) {
                query = query.trim();
            }
            
            // Load categories cho header navigation
            List<Category> categories = categoryDAO.findAll();
            request.setAttribute("categories", categories);
            
            // Nếu có từ khóa tìm kiếm
            if (query != null && !query.isEmpty()) {
                // Tìm kiếm bài viết (limit 50 kết quả)
                List<News> results = newsDAO.search(query, 50);
                
                // Set attributes cho JSP
                request.setAttribute("q", query);
                request.setAttribute("results", results);
                request.setAttribute("resultCount", results.size());
                
                // Log search activity (optional)
                System.out.println("Search query: '" + query + "' - Found: " + results.size() + " results");
            }
            
            // Set page title
            String pageTitle = (query != null && !query.isEmpty()) 
                ? "Tìm kiếm: " + query + " - NewsPortal"
                : "Tìm kiếm - NewsPortal";
            request.setAttribute("pageTitle", pageTitle);
            
            // Forward to search.jsp
            request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            
            // Set error message
            request.setAttribute("error", "Có lỗi xảy ra khi tìm kiếm. Vui lòng thử lại.");
            
            // Load categories for header
            try {
                List<Category> categories = categoryDAO.findAll();
                request.setAttribute("categories", categories);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            
            // Forward to search page with error
            request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect POST to GET to maintain RESTful design
        String query = request.getParameter("q");
        if (query != null && !query.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/search?q=" + 
                java.net.URLEncoder.encode(query.trim(), "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/search");
        }
    }
}