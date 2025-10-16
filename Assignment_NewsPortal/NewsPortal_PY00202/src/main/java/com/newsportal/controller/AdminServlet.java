package com.newsportal.controller;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.dao.UserDAO;
import com.newsportal.model.News;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({
    "/admin/dashboard",
    "/admin/news-approve",
    "/admin/settings"
})
public class AdminServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    /* ---------- Helpers ---------- */
    private boolean isAdmin(HttpServletRequest req) {
        Object o = req.getSession().getAttribute("authUser"); // <-- dùng đúng tên
        return (o instanceof User) && ((User) o).isRole();     // Role=true => admin
    }
    private void deny(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/auth/login"); // <-- đúng URL
    }

    /* ---------- GET ---------- */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { deny(req, resp); return; }

        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/dashboard": {
                    req.setAttribute("pendingCount", newsDAO.countPending());
                    req.setAttribute("newsTotal",    newsDAO.countAll());
                    req.setAttribute("usersTotal",   userDAO.countAll());
                    req.setAttribute("categories",   categoryDAO.findAll());
                    req.setAttribute("pendingList",  newsDAO.findPending());
                    Map<Integer, String> catMap = categoryDAO.toIdNameMap();
                    req.setAttribute("catMap", catMap);

                    req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
                    return;
                }
                case "/admin/news-approve": {
                	// Danh sách bài chờ
                    var pending = newsDAO.findPending();
                    req.setAttribute("pendingList", pending);
                    req.setAttribute("categories", categoryDAO.findAll());

                    // Lấy tất cả reporterId xuất hiện
                    Set<Integer> ids = pending.stream()
                                              .map(News::getReporterId)
                                              .filter(Objects::nonNull)
                                              .collect(Collectors.toSet());
                    // Map<id, User>
                    Map<Integer, User> reporters = userDAO.findByIds(ids);
                    req.setAttribute("reporters", reporters);

                    // Nếu có id cụ thể (ví dụ xem chi tiết 1 bài), thì mới load author riêng
                    String idParam = req.getParameter("id");
                    if (idParam != null && !idParam.isBlank()) {
                        int newsId = Integer.parseInt(idParam);
                        News news = newsDAO.findById(newsId);
                        req.setAttribute("news", news);
                        req.setAttribute("newsAuthor", reporters.get(news.getReporterId()));
                    }

                    req.getRequestDispatcher("/WEB-INF/views/admin/news-approve.jsp").forward(req, resp);
                    return;
                }
                case "/admin/settings": {
                    req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
                    return;
                }
                default:
                    resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /* ---------- POST ---------- */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { deny(req, resp); return; }

        String path = req.getServletPath();
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (path) {
                case "/admin/news-approve": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    switch (action) {
                        case "approve":  newsDAO.setApproved(id, true);  break;
                        case "reject":   newsDAO.delete(id);             break; // hoặc setApproved=false
                        case "home-on":  newsDAO.setHome(id, true);      break;
                        case "home-off": newsDAO.setHome(id, false);     break;
                        default: /* no-op */ ;
                    }
                    resp.sendRedirect(req.getContextPath() + "/admin/news-approve");
                    return;
                }
                case "/admin/settings": {
                    // Xử lý lưu cấu hình nếu có...
                    resp.sendRedirect(req.getContextPath() + "/admin/settings?ok=1");
                    return;
                }
                default:
                    resp.sendError(404);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
