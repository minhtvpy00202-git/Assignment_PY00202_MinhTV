package com.newsportal.controller;

import com.newsportal.dao.UserDAO;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet({"/admin/users-pending"})
public class AdminUserApprovalServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private boolean isAdmin(HttpServletRequest req) {
        Object o = req.getSession().getAttribute("authUser");
        return (o instanceof User) && ((User) o).isRole();
    }
    private void deny(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/auth/login");
    }

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { deny(req, resp); return; }
        try {
            List<User> list = userDAO.findPending();
            req.setAttribute("list", list);
            req.getRequestDispatcher("/WEB-INF/views/admin/users-pending.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { deny(req, resp); return; }

        String action = req.getParameter("action");
        int id = Integer.parseInt(req.getParameter("id"));
        try {
            switch (action == null ? "" : action) {
                case "approve": {
                    userDAO.setActivated(id, true);     // bật Activated=1
                    break;
                }
                case "reject": {
                    userDAO.delete(id);                 // xóa tài khoản
                    break;
                }
                case "toggle-role": {
                    // lấy hiện trạng rồi đảo
                    User u = userDAO.findById(id);
                    if (u != null) userDAO.setRole(id, !u.isRole());
                    break;
                }
                default: /* no-op */ ;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users-pending");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
