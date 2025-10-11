package com.newsportal.controller;

import com.newsportal.dao.NewsDAO;
import com.newsportal.model.ReporterStats;
import com.newsportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/reporter/dashboard")
public class ReporterDashboardServlet extends HttpServlet {
    private NewsDAO newsDAO = new NewsDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy đúng attr đã set khi login
        User u = (User) req.getSession().getAttribute("authUser");

        // Chỉ cho phép ROLE=false (reporter). Admin (true) đẩy về admin dashboard
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        if (u.isRole()) { // true = admin
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            // Lấy thống kê bài viết của reporter hiện tại
            int reporterId = u.getId();
            int total = newsDAO.countByReporter(reporterId);
            int pending = newsDAO.countPendingByReporter(reporterId);
            int approved = newsDAO.countApprovedByReporter(reporterId);
            
            ReporterStats stats = new ReporterStats(total, pending, approved);
            req.setAttribute("stats", stats);
            
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, tạo stats mặc định với giá trị 0
            ReporterStats stats = new ReporterStats(0, 0, 0);
            req.setAttribute("stats", stats);
        }

        req.getRequestDispatcher("/WEB-INF/views/reporter/dashboard.jsp").forward(req, resp);
    }
}
