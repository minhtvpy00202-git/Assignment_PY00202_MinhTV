package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@WebServlet("/admin/news")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class AdminNewsCRUDServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    /* ====== GET ====== */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = p(req, "action", "list");

        if ("edit".equals(action)) {
            int id = pInt(req, "id", -1);
            if (id < 0) { resp.sendError(400, "Invalid id"); return; }
            try {
                req.setAttribute("item", newsDAO.findById(id));
            } catch (Exception e) {
                throw new ServletException("Không tải bản ghi id=" + id, e);
            }
        }

        list(req, resp);
    }

    /* ====== POST ====== */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = p(req, "action", "list");

        try {
            switch (action) {
                case "create": {
                    News n = bind(req, new News(), true);
                    newsDAO.create(n);
                    break;
                }
                case "update": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    News n = newsDAO.findById(id);
                    if (n == null) throw new ServletException("Không tìm thấy tin id=" + id);

                    News after = bind(req, n, false);
                    boolean updateImage = (after.getImage() != null && !after.getImage().isBlank());
                    newsDAO.update(after, updateImage);
                    break;
                }
                case "delete": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    newsDAO.delete(id);
                    break;
                }
                default:
                    /* no-op */
            }
            resp.sendRedirect(req.getContextPath() + "/admin/news");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Lỗi xử lý CRUD tin tức", e);
        }
    }

    /* ====== VIEWS ====== */
    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<News> items = newsDAO.findAll();
            req.setAttribute("items", items);
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/news.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách tin tức", e);
        }
    }

    /* ====== BIND + UPLOAD ====== */

    /**
     * Gán dữ liệu từ form vào News.
     * @param whenCreate true nếu thao tác tạo mới (set mặc định postedDate/viewCount/approved)
     */
    private News bind(HttpServletRequest req, News n, boolean whenCreate)
            throws IOException, ServletException {

        // tiêu đề
        String title = p(req, "title", "");
        if (title.isBlank()) throw new ServletException("Thiếu tiêu đề");
        n.setTitle(title);

        // nội dung
        n.setContent(p(req, "content", ""));

        // category
        int catId = pInt(req, "categoryId", 0);
        if (catId <= 0) throw new ServletException("categoryId không hợp lệ");
        n.setCategoryId(catId);

        // home (nếu có)
        boolean home = "1".equals(req.getParameter("home")) || "true".equalsIgnoreCase(req.getParameter("home"));
        n.setHome(home);

        // reporter/author từ session
        User u = (User) req.getSession().getAttribute("authUser");
        if (u != null) {
            n.setReporterId(u.getId());      // nếu bảng News có cột này
            n.setAuthor(u.getFullname());    // nếu News lưu tên tác giả
        }

        if (whenCreate) {
            n.setPostedDate(LocalDateTime.now());
            n.setViewCount(0);
            n.setApproved(true);             // admin tạo => duyệt luôn
        }

        // upload ảnh (tùy chọn)
        Part thumb = null;
        try { thumb = req.getPart("thumbnail"); } catch (Exception ignore) {}
        if (thumb != null && thumb.getSize() > 0) {
            String path = saveThumbnailIfAny(req, thumb); // "assets/uploads/xxx.jpg"
            if (path != null) n.setImage(path);
        }

        return n;
    }

    /* ====== Upload helper ====== */

    private static final Set<String> ALLOW_EXT = Set.of("jpg", "jpeg", "png", "gif", "webp");

    /** Lưu ảnh nếu có và trả về đường dẫn tương đối để lưu DB; null nếu không lưu. */
    private String saveThumbnailIfAny(HttpServletRequest req, Part part) throws IOException {
        if (part == null || part.getSize() <= 0) return null;

        String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        int dot = submitted.lastIndexOf('.');
        String ext = dot > -1 ? submitted.substring(dot + 1).toLowerCase() : "";
        String mime = part.getContentType() == null ? "" : part.getContentType().toLowerCase();

        if (!mime.startsWith("image/") || !ALLOW_EXT.contains(ext)) return null;

        String newName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;

        // Thư mục đích: /assets/uploads
        Path dir = Path.of(getServletContext().getRealPath("/assets/uploads"));
        Files.createDirectories(dir);

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, dir.resolve(newName), StandardCopyOption.REPLACE_EXISTING);
        }

        // lưu DB/hiển thị: dùng đường dẫn tương đối
        return "assets/uploads/" + newName;
    }

    /* ====== small helpers ====== */
    private String p(HttpServletRequest r, String k, String d) {
        String v = r.getParameter(k);
        return (v == null || v.isBlank()) ? d : v.trim();
    }
    private int pInt(HttpServletRequest r, String k, int def) {
        try { return Integer.parseInt(r.getParameter(k)); }
        catch (Exception e) { return def; }
    }
}
