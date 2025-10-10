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
                String fullname = nvl(req.getParameter("fullname"));
                String email    = nvl(req.getParameter("email"));
                String password = req.getParameter("password");
                String mobile   = nvl(req.getParameter("mobile"));
                String birthday = nvl(req.getParameter("birthday")); // yyyy-MM-dd
                String gender   = req.getParameter("gender");        // "true"/"false"
                String role     = req.getParameter("role");          // "true" (Admin) / "false" (Reporter)

                if (fullname.isEmpty() || email.isEmpty() || password == null || password.isEmpty()) {
                    req.setAttribute("error", "Vui lòng nhập đủ Họ tên, Email và Mật khẩu.");
                    req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                    return;
                }

                if (userDAO.existsEmail(email)) {
                    req.setAttribute("error", "Email đã được đăng ký.");
                    req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                    return;
                }

                java.util.Date dob = null;
                if (!birthday.isBlank()) {
                    java.time.LocalDate ld = java.time.LocalDate.parse(birthday);
                    dob = java.util.Date.from(ld.atStartOfDay(java.time.ZoneId.systemDefault()).toInstant());
                }

                User u = new User();
                u.setFullname(fullname);
                u.setEmail(email);
                u.setPassword(password);     // (sau này thay bằng hash)
                u.setMobile(mobile);
                u.setBirthday(dob);
                u.setGender("true".equalsIgnoreCase(gender));
                u.setRole("true".equalsIgnoreCase(role)); // chọn từ form
                u.setActivated(false); // lưu trạng thái KHÓA

                int id = userDAO.create(u, false); // <--- Activated=0
                u.setId(id);

                // Không tự đăng nhập. Thông báo chờ duyệt
                req.setAttribute("error", "Đăng ký thành công. Tài khoản đang chờ quản trị viên duyệt.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }



            resp.sendError(404);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
    
    private String nvl(String s) { return s == null ? "" : s.trim(); }

    
}

