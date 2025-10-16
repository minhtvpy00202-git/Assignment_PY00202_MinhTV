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
    
  //================GET===================================
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

    //================POST===================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { deny(req, resp); return; }
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String idRaw  = req.getParameter("id");

        String msg = "Hành động không hợp lệ.";
        String type = "danger";

        try {
            int id = Integer.parseInt(idRaw);
            String a = (action == null ? "" : action.trim().toLowerCase());

            switch (a) {
                case "approve": {
                    userDAO.setActivated(id, true);
                    User u = userDAO.findById(id);
                    msg = "Đã duyệt tài khoản " + "#" +id +". " + (u!=null? u.getFullname() : ("#" + id)) + ".";
                    type = "success";
                    break;
                }
                case "reject": {
                    // Nếu muốn soft-delete: userDAO.setActivated(id, false);
                    userDAO.delete(id);
                    User u = userDAO.findById(id);
                    msg = "Đã từ chối tài khoản "+ "#" +id +". " + (u!=null? u.getFullname() : ("#" + id)) + ".";
                    type = "warning";
                    break;
                }
                case "toggle-role": {
                    User u = userDAO.findById(id);
                    if (u != null) {
                        boolean newRole = !u.isRole();
                        userDAO.setRole(id, newRole);
                        msg = "Đã đổi vai trò cho tài khoản #" + id  +" "+ (u!=null? u.getFullname(): ("#" + id)) +" "+ " thành " + (newRole ? "Admin" : "Reporter") + ".";
                        type = "info";
                    } else {
                        msg = "Không tìm thấy tài khoản #" + id + ".";
                        type = "danger";
                    }
                    break;
                }
                default: {
                    msg = "Hành động không hợp lệ.";
                    type = "danger";
                }
            }
        } catch (NumberFormatException nfe) {
            msg = "ID không hợp lệ.";
            type = "danger";
        } catch (Exception e) {
            msg = "Có lỗi xảy ra: " + e.getMessage();
            type = "danger";
        }

        // Flash message
        HttpSession session = req.getSession();
        session.setAttribute("flashMsg", msg);
        session.setAttribute("flashType", type);

        // PRG
        resp.sendRedirect(req.getContextPath() + "/admin/users-pending");
    }
 

}
