package com.newsportal.controller;

import com.newsportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/reporter/dashboard")
public class ReporterDashboardServlet extends HttpServlet {
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

        req.getRequestDispatcher("/WEB-INF/views/reporter/dashboard.jsp").forward(req, resp);
    }
}
