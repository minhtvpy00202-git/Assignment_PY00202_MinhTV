package com.newsportal.controller;

import java.io.IOException;
import java.time.LocalDate;
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

@WebServlet({ "/admin/dashboard", "/admin/news-approve", "/admin/news-detail", "/admin/settings" })
public class AdminServlet extends HttpServlet {

	private final NewsDAO newsDAO = new NewsDAO();
	private final UserDAO userDAO = new UserDAO();
	private final CategoryDAO categoryDAO = new CategoryDAO();

	/* ---------- Helpers ---------- */
	private boolean isAdmin(HttpServletRequest req) {
		Object o = req.getSession().getAttribute("authUser"); // <-- dùng đúng tên
		return (o instanceof User) && ((User) o).isRole(); // Role=true => admin
	}

	private void deny(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		resp.sendRedirect(req.getContextPath() + "/auth/login"); // <-- đúng URL
	}

	/* ---------- GET ---------- */
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		if (!isAdmin(req)) {
			deny(req, resp);
			return;
		}

		String path = req.getServletPath();
		try {
			switch (path) {
			case "/admin/dashboard": {
				req.setAttribute("pendingCount", newsDAO.countPending());
				req.setAttribute("newsTotal", newsDAO.countAll());
				req.setAttribute("usersTotal", userDAO.countAll());
				req.setAttribute("categories", categoryDAO.findAll());
				req.setAttribute("pendingList", newsDAO.findPending());
				Map<Integer, String> catMap = categoryDAO.toIdNameMap();
				req.setAttribute("catMap", catMap);

				req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
				return;
			}
			case "/admin/news-approve": {
				// --- đọc params lọc/tìm ---
				String q = trimOrNull(req.getParameter("q"));
				Integer catId = parseIntOrNull(req.getParameter("catId"));
				Integer reporterId = parseIntOrNull(req.getParameter("reporterId"));
				LocalDate from = parseDateOrNull(req.getParameter("from")); // yyyy-MM-dd
				LocalDate to = parseDateOrNull(req.getParameter("to"));

				// --- phân trang ---
				int pageSize = 5;
				int page = parseIntOrDefault(req.getParameter("page"), 1);
				if (page < 1)
					page = 1;
				int total = newsDAO.countPending(q, catId, reporterId, from, to);
				int totalPages = (int) Math.ceil(total / (double) pageSize);
				if (totalPages == 0)
					totalPages = 1;
				if (page > totalPages)
					page = totalPages;
				int offset = (page - 1) * pageSize;

				var pending = newsDAO.findPendingPaged(q, catId, reporterId, from, to, offset, pageSize);
				req.setAttribute("pendingList", pending);
				req.setAttribute("categories", categoryDAO.findAll());

				// build map<reporterId, User> cho trang
				Set<Integer> ids = pending.stream().map(News::getReporterId).filter(Objects::nonNull)
						.collect(Collectors.toSet());
				Map<Integer, User> reporters = userDAO.findByIds(ids);
				req.setAttribute("reporters", reporters);

				// data phân trang & giữ bộ lọc
				req.setAttribute("page", page);
				req.setAttribute("totalPages", totalPages);
				req.setAttribute("total", total);
				req.setAttribute("q", q);
				req.setAttribute("catId", catId);
				req.setAttribute("reporterId", reporterId);
				req.setAttribute("from", from);
				req.setAttribute("to", to);

				req.getRequestDispatcher("/WEB-INF/views/admin/news-approve.jsp").forward(req, resp);
				return;
			}

			case "/admin/news-detail": {
				int id = Integer.parseInt(req.getParameter("id"));
				News news = newsDAO.findById(id);
				if (news == null) {
					resp.sendError(404);
					return;
				}

				// Nếu vào từ trang duyệt sẽ có ref=approve => JSP sẽ hiển thị nút
				String ref = req.getParameter("ref");
				req.setAttribute("news", news);
				req.setAttribute("ref", ref);
				// gán phóng viên (nếu có)
				if (news.getReporterId() != null) {
					var map = userDAO.findByIds(Set.of(news.getReporterId()));
					req.setAttribute("newsAuthor", map.get(news.getReporterId()));
				}
				req.getRequestDispatcher("/WEB-INF/views/news-detail.jsp").forward(req, resp);
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
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		if (!isAdmin(req)) {
			deny(req, resp);
			return;
		}

		String path = req.getServletPath();
		String action = req.getParameter("action");
		if (action == null)
			action = "";

		try {
			switch (path) {
			case "/admin/news-approve": {
				int id = Integer.parseInt(req.getParameter("id"));
				switch (action) {
				case "approve":
					newsDAO.setApproved(id, true);
					break;
				case "reject":
					newsDAO.delete(id);
					break;
				case "home-on":
					newsDAO.setApproved(id, true); 
					newsDAO.setHome(id, true);
					break;
				case "home-off":
					newsDAO.setHome(id, false);
					break;
				default:
					;
				}
				resp.sendRedirect(req.getContextPath() + "/admin/news-approve");
				return;
			}

			case "/admin/news-detail": {
				// xử lý duyệt/từ chối ở trang chi tiết (nếu hiển thị)
				int id = Integer.parseInt(req.getParameter("id"));
				switch (action) {
				case "approve":
					newsDAO.setApproved(id, true);
					break;
				case "reject":
					newsDAO.delete(id);
					break;
				default:
					;
				}
				// quay lại trang duyệt
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

	/* --------- helpers nhỏ --------- */
	private static String trimOrNull(String s) {
		return (s == null || s.isBlank()) ? null : s.trim();
	}

	private static Integer parseIntOrNull(String s) {
		try {
			return (s == null || s.isBlank()) ? null : Integer.valueOf(s);
		} catch (Exception e) {
			return null;
		}
	}

	private static int parseIntOrDefault(String s, int d) {
		try {
			return (s == null || s.isBlank()) ? d : Integer.parseInt(s);
		} catch (Exception e) {
			return d;
		}
	}

	private static LocalDate parseDateOrNull(String s) {
		try {
			return (s == null || s.isBlank()) ? null : LocalDate.parse(s);
		} catch (Exception e) {
			return null;
		}
	}
}
