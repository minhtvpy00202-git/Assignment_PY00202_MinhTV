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
    private static final Path UPLOAD_DIR = Paths.get(
    	    "C:/FPOLY/JAVA3/Assignment_PY00202_MinhTV/Assignment_NewsPortal/newsportal-uploads"
    	);
    private static final String PUBLIC_URL_PREFIX = "/uploads/";
    
  
 // Dùng MyMemoryTranslate (miễn phí). Có thể đổi endpoint qua ENV LT_ENDPOINT, API key qua LT_API_KEY (thường không cần).
    private final com.newsportal.i18n.TranslationService translator =
    	    new com.newsportal.i18n.MyMemoryTranslateService();

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
    	
    	System.out.println("[DEBUG] AUTO_TRANSLATE=" + AUTO_TRANSLATE 
    		    + ", ENV.AUTO_TRANSLATE=" + System.getenv("AUTO_TRANSLATE"));

    	
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
            n.setReporterId(me.getId());

            // ✅ Auto-approve nếu người viết là admin (Role = true)
            n.setApproved(me.isRole());

            int newId = newsDAO.create(n);

            // (Tùy chọn) Auto-translate vẫn giữ nguyên
            if (AUTO_TRANSLATE) {
                try {
                    String enTitle   = translator.translateViToEn(title, false);
                    String enContent = translator.translateViToEn(content, true);
                    String enExcerpt = com.newsportal.util.TextUtils.ellipsize(
                            com.newsportal.util.TextUtils.stripHtml(enContent), 300);
                    newsDAO.upsertTranslation(newId, "en", enTitle, enExcerpt, enContent);
                } catch (Exception ex) {
                    System.err.println("[TRANSLATE][ERROR] endpoint="
                            + System.getenv().getOrDefault("LT_ENDPOINT", "https://libretranslate.de/translate")
                            + ", hasKey=" + (System.getenv("LT_API_KEY") != null));
                    ex.printStackTrace();
                }
            } else {
                System.out.println("[AUTO_TRANSLATE] Skip: feature off.");
            }

            // Điều hướng: nếu là admin viết thì có thể chuyển thẳng sang list bài viết đã tạo
            resp.sendRedirect(req.getContextPath() + "/reporter/posts?created=" + newId);
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
            News base = newsDAO.findByIdAndReporter(Integer.parseInt(idParam), me.getId());
            if (base == null) { resp.sendError(403, "Không có quyền"); return; }

            // thông báo đã có bản nháp chờ duyệt
            News existingDraft = newsDAO.findPendingDraftOf(base.getId());
            if (existingDraft != null) {
                req.setAttribute("draftExists", true);
                req.setAttribute("draft", existingDraft);
            }

            req.setAttribute("categories", categoryDAO.findAll());
            req.setAttribute("news", base);
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
        int baseId = Integer.parseInt(idParam);

        String title      = req.getParameter("title");
        String content    = req.getParameter("content");
        int categoryId    = Integer.parseInt(param(req, "categoryId", "0"));
        boolean home      = "1".equals(req.getParameter("home"));

        String newImage = saveThumbnailIfAny(req.getPart("thumbnail")); // null nếu không đổi

        try {
            // 1) Lấy bản gốc & kiểm quyền
            News base = newsDAO.findByIdAndReporter(baseId, me.getId());
            if (base == null) { resp.sendError(403, "Không có quyền"); return; }

            
            // chặn tạo nháp mới nếu đã có 1 nháp pending:
            if (newsDAO.hasPendingDraft(baseId)) {
		           resp.sendRedirect(req.getContextPath()+"/reporter/posts?draftExists="+baseId);
		            return;
		           }

            // 2) Chuẩn bị dữ liệu NHÁP
            News edited = new News();
            edited.setTitle(title);
            edited.setContent(content);
            edited.setCategoryId(categoryId);
            edited.setHome(home);
            edited.setApproved(false);            // nháp chờ duyệt
            edited.setAuthor(me.getFullname());
            edited.setReporterId(me.getId());
            edited.setImage(newImage);            // có thể null -> giữ ảnh cũ

            // 3) Tạo bản nháp (clone) – KHÔNG update bản gốc
            int draftId = newsDAO.createDraftClone(base, edited, /*keepOldImage*/ true);

            // 4) Dịch tự động cho bản nháp 
            if (AUTO_TRANSLATE) {
                try {
                    String enTitle   = translator.translateViToEn(edited.getTitle(), false);
                    String enContent = translator.translateViToEn(edited.getContent(), true);
                    String enExcerpt = com.newsportal.util.TextUtils.ellipsize(
                            com.newsportal.util.TextUtils.stripHtml(enContent), 300);
                    newsDAO.upsertTranslation(draftId, "en", enTitle, enExcerpt, enContent);
                } catch (Exception ex) {
                    System.err.println("[TRANSLATE][ERROR] endpoint="
                            + System.getenv().getOrDefault("LT_ENDPOINT", "https://libretranslate.de/translate")
                            + ", hasKey=" + (System.getenv("LT_API_KEY") != null));
                    ex.printStackTrace();
                }
            } else {
                System.out.println("[AUTO_TRANSLATE] Skip: feature off.");
            }

            // 5) Điều hướng: báo tạo nháp thành công
            resp.sendRedirect(req.getContextPath()+"/reporter/posts?draftCreated="+draftId+"&baseId="+baseId);
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
            resp.sendRedirect(req.getContextPath()+"/reporter/posts?deleted=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ---------------- helpers ----------------

    /** Bắt buộc đăng nhập. Trả về null nếu đã redirect. */
    private User requireReporter(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // LẤY ĐÚNG TÊN ATTR
        User me = (User) req.getSession().getAttribute("authUser");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login"); // ĐÚNG URL
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
        if (part.getSize() > 10 * 1024 * 1024) throw new IOException("File quá lớn (>10MB)");

        Files.createDirectories(UPLOAD_DIR); // tạo nếu chưa có

        String newName = System.currentTimeMillis()+"_"+UUID.randomUUID().toString().substring(0,8)+"."+ext;
        Path dest = UPLOAD_DIR.resolve(newName);

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
        }

        // Lưu vào DB đường dẫn URL công khai
        return PUBLIC_URL_PREFIX + newName; // ví dụ: /uploads/1739812345_ab12cd34.jpg
    }
    
 // NewsCRUDServlet: thêm helper
    private boolean hasTranslateKey() {
      String k = System.getenv("GOOGLE_TRANSLATE_API_KEY");
      return k != null && !k.isBlank();
    }
    
    private static boolean boolPropEnv(String key, boolean defVal) {
    	  String v = System.getProperty(key);
    	  if (v == null) v = System.getenv(key);
    	  if (v == null) return defVal;
    	  return "true".equalsIgnoreCase(v) || "1".equals(v);
    	}
    
    
    private final boolean AUTO_TRANSLATE = boolPropEnv("AUTO_TRANSLATE", true);



}
