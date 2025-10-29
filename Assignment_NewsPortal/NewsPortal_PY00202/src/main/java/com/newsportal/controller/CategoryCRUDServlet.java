package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/categories")
public class CategoryCRUDServlet extends HttpServlet {
  private final CategoryDAO dao = new CategoryDAO();
  
  
  private final com.newsportal.i18n.TranslationService translator =
		    new com.newsportal.i18n.MyMemoryTranslateService();
  
  private static boolean boolPropEnv(String key, boolean defVal) {
	  String v = System.getProperty(key);
	  if (v == null) v = System.getenv(key);
	  if (v == null) return defVal;
	  return "true".equalsIgnoreCase(v) || "1".equals(v);
	}
	private final boolean AUTO_TRANSLATE = boolPropEnv("AUTO_TRANSLATE", true);

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    String action = p(req, "action", "list");

    try {
      switch (action) {
        case "edit": {
          int id = pInt(req, "id", -1);
          if (id < 0) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid id"); return; }

          req.setAttribute("item",         dao.findById(id));
          req.setAttribute("items",        dao.findAllActive());
          req.setAttribute("deletedItems", dao.findDeleted());

          req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
          return;
        }
        default: {
          list(req, resp);
          return;
        }
      }
    } catch (Exception e) {
      throw new ServletException("Không tải danh mục", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");
    String action = p(req, "action", "list");

    try {
      switch (action) {
      case "create": {
    	  String name = p(req, "name", "");
    	  // 1) Tạo category và nhận id
    	  int id = dao.create(name);

    	  // 2) Lưu bản dịch gốc VI
    	  dao.upsertTranslation(id, "vi", name, null);

    	  // 3) Tự dịch EN (nếu bật)
    	  if (AUTO_TRANSLATE) {
    	    try {
    	      String enName = translator.translateViToEn(name, /*html=*/false);
    	      dao.upsertTranslation(id, "en", enName, null);
    	    } catch (Exception ex) {
    	      System.err.println("[CAT TRANSLATE][create] " + ex.getMessage());
    	    }
    	  }

    	  redirectWithFlag(req, resp, "created=1");
    	  return;
    	}

      case "update": {
    	  int id = pInt(req, "id", -1);
    	  if (id < 0) throw new ServletException("Invalid id");
    	  String name = p(req, "name", "");

    	  // 1) Cập nhật tên gốc
    	  dao.update(id, name);

    	  // 2) Đồng bộ bản dịch VI
    	  dao.upsertTranslation(id, "vi", name, null);

    	  // 3) Làm mới bản dịch EN (nếu bật)
    	  if (AUTO_TRANSLATE) {
    	    try {
    	      String enName = translator.translateViToEn(name, /*html=*/false);
    	      dao.upsertTranslation(id, "en", enName, null);
    	    } catch (Exception ex) {
    	      System.err.println("[CAT TRANSLATE][update] " + ex.getMessage());
    	    }
    	  }

    	  redirectWithFlag(req, resp, "updated=1");
    	  return;
    	}

        case "delete": { // xóa mềm
          int id = pInt(req, "id", -1);
          if (id < 0) throw new ServletException("Invalid id");
          dao.softDelete(id);
          redirectWithFlag(req, resp, "deleted=1");
          return;
        }
        case "restore": { // khôi phục
          int id = pInt(req, "id", -1);
          if (id < 0) throw new ServletException("Invalid id");
          dao.restore(id);
          redirectWithFlag(req, resp, "restored=1");
          return;
        }
        case "purge": { // xóa vĩnh viễn (cần FK ON DELETE CASCADE)
          int id = pInt(req, "id", -1);
          if (id < 0) throw new ServletException("Invalid id");
          dao.hardDelete(id);
          redirectWithFlag(req, resp, "purged=1");
          return;
        }
        default:
          // không action -> quay về list
          redirectWithFlag(req, resp, null);
          return;
      }
    } catch (Exception e) {
      // Forward lại trang với thông báo lỗi + nạp dữ liệu bảng
      try {
        req.setAttribute("error", "Lỗi xử lý CRUD loại tin: " + e.getMessage());
        req.setAttribute("items",        dao.findAllActive());
        req.setAttribute("deletedItems", dao.findDeleted());
      } catch (Exception ignore) {}
      req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
    }
  }

  /* ================= Helpers ================ */

  private void list(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    try {
      req.setAttribute("items",        dao.findAllActive());
      req.setAttribute("deletedItems", dao.findDeleted());
      req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
    } catch (Exception e) {
      throw new ServletException("Không tải danh sách loại tin", e);
    }
  }

  /** Redirect về /admin/categories và gắn cờ thông báo (nếu có). */
  private void redirectWithFlag(HttpServletRequest req, HttpServletResponse resp, String flag)
      throws IOException {
    String url = req.getContextPath() + "/admin/categories";
    if (flag != null && !flag.isBlank()) {
      url += "?" + flag;
    }
    resp.sendRedirect(url);
  }

  private String p(HttpServletRequest r, String k, String d) {
    String v = r.getParameter(k);
    return v == null ? d : v.trim();
  }

  private int pInt(HttpServletRequest r, String k, int d) {
    try { return Integer.parseInt(r.getParameter(k)); }
    catch (Exception e) { return d; }
  }
  
  
  
  
}
