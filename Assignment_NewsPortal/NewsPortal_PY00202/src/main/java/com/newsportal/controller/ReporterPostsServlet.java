package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.Category;
import com.newsportal.model.News;
import com.newsportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/reporter/posts")
public class ReporterPostsServlet extends HttpServlet {
    private NewsDAO newsDAO = new NewsDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập và quyền reporter
        User user = (User) req.getSession().getAttribute("authUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        if (user.isRole()) { // true = admin, chuyển về admin dashboard
            resp.sendRedirect(req.getContextPath() + "/admin/news");
            return;
        }

        try {
            // Lấy danh sách bài viết của reporter hiện tại
            int reporterId = user.getId();
            List<News> posts = newsDAO.listByReporter(reporterId);
            
            // Lấy danh sách categories để hiển thị tên thay vì ID
            List<Category> categories = categoryDAO.findAll();
            Map<Integer, String> categoryMap = categories.stream()
                .collect(Collectors.toMap(Category::getId, Category::getName));
            
            // Truyền dữ liệu cho JSP
            req.setAttribute("posts", posts);
            req.setAttribute("categoryMap", categoryMap);
            req.setAttribute("user", user);
            
            // Thống kê nhanh
            long totalPosts = posts.size();
            long pendingPosts = posts.stream().filter(p -> !p.isApproved()).count();
            long approvedPosts = posts.stream().filter(News::isApproved).count();
            
            req.setAttribute("totalPosts", totalPosts);
            req.setAttribute("pendingPosts", pendingPosts);
            req.setAttribute("approvedPosts", approvedPosts);
            
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra khi tải danh sách bài viết");
        }

        req.getRequestDispatcher("/WEB-INF/views/reporter/posts.jsp").forward(req, resp);
    }
}