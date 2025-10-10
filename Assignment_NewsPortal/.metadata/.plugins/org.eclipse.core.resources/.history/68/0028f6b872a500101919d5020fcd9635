package com.newsportal.controller;

import com.newsportal.dao.UserDAO;
import com.newsportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet({"/auth/login", "/auth/logout", "/auth/register"})
public class AuthServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/auth/login":
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            case "/auth/register":
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            case "/auth/logout":
                HttpSession ss = req.getSession(false);
                if (ss != null) ss.invalidate();
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            default:
                resp.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            if ("/auth/login".equals(path)) {
                String email = req.getParameter("email");
                String pw    = req.getParameter("password");

                User u = userDAO.login(email, pw); // chỉ trả về Activated=1
                if (u == null) {
                    req.setAttribute("error", "Sai email hoặc mật khẩu");
                    req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                    return;
                }

                HttpSession ss = req.getSession(true);
                ss.setAttribute("authUser", u);
                ss.setAttribute("isAdmin", u.isRole()); // role=true => admin

                String target = u.isRole() ? "/admin/dashboard" : "/reporter/dashboard";
                resp.sendRedirect(req.getContextPath() + target);
                return;
            }

            if ("/auth/register".equals(path)) {
                resp.sendError(501); // TODO
                return;
            }

            resp.sendError(404);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}

