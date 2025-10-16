package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;
import com.newsportal.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@WebServlet({"/admin/news", "/admin/news-edit"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class AdminNewsCRUDServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    /* ====== GET ====== */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String servletPath = req.getServletPath();

        // --- Trang sửa riêng ---
        if ("/admin/news-edit".equals(servletPath)) {
            int id = pInt(req, "id", -1);
            if (id < 0) { resp.sendError(400, "Thiếu hoặc sai id"); return; }

            try {
                News n = newsDAO.findById(id);
                if (n == null) { resp.sendError(404, "Không tìm thấy tin id=" + id); return; }

                req.setAttribute("news", n);                       // <-- JSP news-edit.jsp đang dùng biến 'news'
                req.setAttribute("categories", categoryDAO.findAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/news-edit.jsp").forward(req, resp);
                return;
            } catch (Exception e) {
                throw new ServletException("Không tải tin id=" + id, e);
            }
        }

        // --- Trang danh sách /admin/news (mặc định) ---
        list(req, resp);
    }

    /* ====== POST ====== */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();

        try {
            if ("/admin/news-edit".equals(servletPath)) {
                // Cập nhật từ form news-edit.jsp
                int id = pInt(req, "id", -1);
                if (id < 0) throw new ServletException("Invalid id");
                News n = newsDAO.findById(id);
                if (n == null) throw new ServletException("Không tìm thấy tin id=" + id);

                News after = bind(req, n, /* whenCreate = */ false);
                boolean updateImage = (after.getImage() != null && !after.getImage().isBlank());
                newsDAO.update(after, updateImage);

                resp.sendRedirect(req.getContextPath() + "/admin/news?updated=1");
                return;
            }

            // Các thao tác trên /admin/news (create/delete)
            String action = p(req, "action", "list");
            switch (action) {
                case "create": {
                    News n = bind(req, new News(), true);
                    newsDAO.create(n);
                    resp.sendRedirect(req.getContextPath() + "/admin/news?created=1");
                    return;
                }
                case "delete": {
                    int id = pInt(req, "id", -1);
                    if (id < 0) throw new ServletException("Invalid id");
                    newsDAO.delete(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/news?deleted=1");
                    return;
                }
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/news");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Lỗi xử lý CRUD tin tức", e);
        }
    }

    /* ====== VIEWS ====== */
    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String q = p(req, "q", "");      // tiêu đề cần tìm
            int cat = pInt(req, "cat", 0);   // 0 = tất cả

            List<News> items = ( (q == null || q.isBlank()) && cat <= 0 )
                    ? newsDAO.findAll()
                    : newsDAO.searchAdvanced(q, cat, 500);

            req.setAttribute("items", items);
            req.setAttribute("categories", categoryDAO.findAll());
            req.setAttribute("q", q);
            req.setAttribute("cat", cat);

            req.getRequestDispatcher("/WEB-INF/views/admin/news.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải danh sách tin tức", e);
        }
    }

    /* ====== BIND + UPLOAD ====== */

    /**
     * Gán dữ liệu từ form vào News.
     * @param whenCreate true nếu thao tác tạo mới (set postedDate/viewCount/approved)
     */
    private News bind(HttpServletRequest req, News n, boolean whenCreate)
            throws IOException, ServletException {

        // Tiêu đề
        String title = p(req, "title", "");
        if (title.isBlank()) throw new ServletException("Thiếu tiêu đề");
        n.setTitle(title);

        // Nội dung (HTML)
        n.setContent(p(req, "content", ""));

        // Chuyên mục
        int catId = pInt(req, "categoryId", 0);
        if (catId <= 0) throw new ServletException("categoryId không hợp lệ");
        n.setCategoryId(catId);

        // Cờ Trang chủ
        boolean home = "1".equals(req.getParameter("home")) || "true".equalsIgnoreCase(req.getParameter("home"));
        n.setHome(home);

        // Gán thông tin tác giả (nếu có)
        User u = (User) req.getSession().getAttribute("authUser");
        if (u != null) {
            n.setReporterId(u.getId());
            n.setAuthor(u.getFullname());
        }

        if (whenCreate) {
            n.setPostedDate(LocalDateTime.now());
            n.setViewCount(0);
            n.setApproved(true);
        }

        // Ảnh đại diện (tùy chọn)
        Part thumb = null;
        try { thumb = req.getPart("thumbnail"); } catch (Exception ignore) {}
        if (thumb != null && thumb.getSize() > 0) {
            String path = saveThumbnailIfAny(req, thumb); // "assets/uploads/xxx.jpg"
            if (path != null) n.setImage(path);
        }

        return n;
    }

    /* ====== Upload helper ====== */

    private static final Set<String> ALLOW_EXT = Set.of("jpg","jpeg","png","gif","webp");

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

        // Lưu DB: đường dẫn tương đối để public
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
