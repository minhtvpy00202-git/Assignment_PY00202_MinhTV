package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;
import com.newsportal.model.ReporterStats;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/reporter/dashboard")
public class ReporterDashboardServlet extends HttpServlet {
    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1) Kiểm tra đăng nhập + phân quyền
        User me = (User) req.getSession().getAttribute("authUser");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        if (me.isRole()) { // true = admin
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

     // 2) Lấy dữ liệu hiển thị (tách try/catch để biết lỗi ở đâu)
        int reporterId = me.getId();
        System.out.println("[ReporterDashboard] authUser id = " + reporterId + ", name = " + me.getFullname());

        int total = 0, pending = 0, approved = 0;
        List<News> myPending = java.util.Collections.emptyList();

        try {
            total = newsDAO.countByReporter(reporterId);
            System.out.println("[ReporterDashboard] total = " + total);
        } catch (Exception e) {
            System.err.println("[ReporterDashboard] countByReporter ERROR");
            e.printStackTrace();
        }
        try {
            pending = newsDAO.countPendingByReporter(reporterId);
            System.out.println("[ReporterDashboard] pending = " + pending);
        } catch (Exception e) {
            System.err.println("[ReporterDashboard] countPendingByReporter ERROR");
            e.printStackTrace();
        }
        try {
            approved = newsDAO.countApprovedByReporter(reporterId);
            System.out.println("[ReporterDashboard] approved = " + approved);
        } catch (Exception e) {
            System.err.println("[ReporterDashboard] countApprovedByReporter ERROR");
            e.printStackTrace();
        }
        try {
            myPending = newsDAO.findByReporterPending(reporterId, 5);
            System.out.println("[ReporterDashboard] myPending size = " + (myPending == null ? -1 : myPending.size()));
        } catch (Exception e) {
            System.err.println("[ReporterDashboard] findByReporterPending ERROR");
            e.printStackTrace();
        }

        req.setAttribute("stats", new ReporterStats(total, pending, approved));
        req.setAttribute("myPending", myPending);
        req.setAttribute("catMap", categoryDAO.toIdNameMap());

        // 4) Forward
        req.getRequestDispatcher("/WEB-INF/views/reporter/dashboard.jsp").forward(req, resp);
    }
}
