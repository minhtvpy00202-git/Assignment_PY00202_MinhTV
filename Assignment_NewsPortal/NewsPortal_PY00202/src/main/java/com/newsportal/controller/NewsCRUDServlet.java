package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Toàn bộ CRUD tin tức của phóng viên.
 *
 * URL:
 *  - GET  /reporter/news            : list bài của tôi
 *  - GET  /reporter/post-create     : form tạo
 *  - POST /reporter/post-create     : tạo
 *  - GET  /reporter/post-edit       : form sửa (?id=)
 *  - POST /reporter/post-edit       : cập nhật
 *  - POST /reporter/post-delete     : xoá
 */
@WebServlet(urlPatterns = {
        "/reporter/news",
        "/reporter/post-create",
        "/reporter/post-edit",
        "/reporter/post-delete"
})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class NewsCRUDServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    private static final Set<String> ALLOW_EXT = Set.of("jpg","jpeg","png","gif","webp");

    // ---------------- entry points ----------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/reporter/news"        -> handleList(req, resp);
            case "/reporter/post-create" -> handleCreateGet(req, resp);
            case "/reporter/post-edit"   -> handleEditGet(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/reporter/post-create" -> handleCreatePost(req, resp);
            case "/reporter/post-edit"   -> handleEditPost(req, resp);
            case "/reporter/post-delete" -> handleDeletePost(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ---------------- handlers ----------------

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = requireReporter(req, resp);
        if (me == null) return;

        try {
            req.setAttribute("categories", categoryDAO.findAll());
            List<News> list = newsDAO.listByReporter(me.getId());
            req.setAttribute("newsList", list);
            req.getRequestDispatcher("/WEB-INF/views/reporter/news-list.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleCreateGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = requireReporter(req, resp);
        if (me == null) return;

        try {
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/reporter/post-create.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleCreatePost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = requireReporter(req, resp);
        if (me == null) return;

        String title = req.getParameter("title");
        String content = req.getParameter("content"); // CKEditor HTML
        int categoryId = Integer.parseInt(param(req, "categoryId", "0"));
        boolean home = "1".equals(req.getParameter("home"));

        String thumbnailPath = saveThumbnailIfAny(req.getPart("thumbnail"));

        try {
            News n = new News();
            n.setTitle(title);
            n.setContent(content);
            n.setImage(thumbnailPath);
            n.setPostedDate(LocalDateTime.now());
            n.setAuthor(me.getFullname());
            n.setViewCount(0);
            n.setCategoryId(categoryId);
            n.setHome(home);
            n.setApproved(false);         // chờ duyệt
            n.setReporterId(me.getId());

            int newId = newsDAO.create(n);
            resp.sendRedirect(req.getContextPath() + "/reporter/news?created=" + newId);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleEditGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = requireReporter(req, resp);
        if (me == null) return;

        String idParam = req.getParameter("id");
        if (idParam == null || !idParam.matches("\\d+")) {
            resp.sendError(400, "Thiếu/ sai id"); return;
        }

        try {
            News n = newsDAO.findByIdAndReporter(Integer.parseInt(idParam), me.getId());
            if (n == null) { resp.sendError(403, "Không có quyền"); return; }

            req.setAttribute("categories", categoryDAO.findAll());
            req.setAttribute("news", n);
            req.getRequestDispatcher("/WEB-INF/views/reporter/post-edit.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleEditPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = requireReporter(req, resp);
        if (me == null) return;

        String idParam = req.getParameter("id");
        if (idParam == null || !idParam.matches("\\d+")) {
            resp.sendError(400, "Thiếu/ sai id"); return;
        }
        int id = Integer.parseInt(idParam);

        String title      = req.getParameter("title");
        String content    = req.getParameter("content");
        int categoryId    = Integer.parseInt(param(req, "categoryId", "0"));
        boolean home      = "1".equals(req.getParameter("home"));

        String newImage = saveThumbnailIfAny(req.getPart("thumbnail")); // null nếu không đổi

        try {
            News n = newsDAO.findByIdAndReporter(id, me.getId());
            if (n == null) { resp.sendError(403, "Không có quyền"); return; }

            n.setTitle(title);
            n.setContent(content);
            n.setCategoryId(categoryId);
            n.setHome(home);
            n.setApproved(false);    // sửa xong quay lại chờ duyệt
            n.setAuthor(me.getFullname());
            if (newImage != null) n.setImage(newImage);

            newsDAO.update(n, newImage != null);
            resp.sendRedirect(req.getContextPath()+"/reporter/news?updated="+id);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleDeletePost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = requireReporter(req, resp);
        if (me == null) return;

        String idParam = req.getParameter("id");
        if (idParam == null || !idParam.matches("\\d+")) {
            resp.sendError(400, "Thiếu/ sai id"); return;
        }

        try {
            News n = newsDAO.findByIdAndReporter(Integer.parseInt(idParam), me.getId());
            if (n == null) { resp.sendError(403, "Không có quyền"); return; }

            newsDAO.delete(n.getId());
            resp.sendRedirect(req.getContextPath()+"/reporter/news?deleted=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ---------------- helpers ----------------

    /** Bắt buộc đăng nhập & là phóng viên (role=false). Trả về null nếu đã redirect. */
    private User requireReporter(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // LẤY ĐÚNG TÊN ATTR
        User me = (User) req.getSession().getAttribute("authUser");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login"); // ĐÚNG URL
            return null;
        }
        // Admin (role=true) không dùng giao diện phóng viên
        if (me.isRole()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return null;
        }
        return me;
    }

    private String param(HttpServletRequest req, String name, String def) {
        String v = req.getParameter(name);
        return (v == null || v.isBlank()) ? def : v.trim();
    }

    /** Lưu file ảnh (nếu có) và trả về đường dẫn tương đối để lưu DB; null nếu không upload. */
    private String saveThumbnailIfAny(Part part) throws IOException {
        if (part == null || part.getSize() <= 0) return null;

        String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf('.')+1).toLowerCase() : "";
        String mime = part.getContentType() == null ? "" : part.getContentType().toLowerCase();
        if (!mime.startsWith("image/") || !ALLOW_EXT.contains(ext)) return null;

        String newName = System.currentTimeMillis()+"_"+ UUID.randomUUID().toString().substring(0,8)+"."+ext;
        Path dir = Path.of(getServletContext().getRealPath("/assets/uploads"));
        Files.createDirectories(dir);
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, dir.resolve(newName), StandardCopyOption.REPLACE_EXISTING);
        }
        return "assets/uploads/" + newName;
    }
}
