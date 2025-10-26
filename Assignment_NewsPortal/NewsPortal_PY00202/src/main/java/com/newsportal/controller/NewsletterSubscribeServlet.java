package com.newsportal.controller;

import java.io.IOException;

import com.newsportal.dao.NewsletterDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/newsletter/subscribe")
public class NewsletterSubscribeServlet extends HttpServlet {
	private final NewsletterDAO dao = new NewsletterDAO();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		String email = p(req, "email", "").trim().toLowerCase();
		String catRaw = p(req, "categoryId", "").trim();
		Integer categoryId = catRaw.isEmpty() ? null : parseIntOrNull(catRaw);

		try {
			dao.subscribe(email, categoryId); // <— LƯU CHUYÊN MỤC (NULL = tất cả)
			redirect(resp, back(req), "sub_msg", "Đăng ký thành công!");
		} catch (Exception e) {
			throw new ServletException("Đăng ký newsletter lỗi", e);
		}
	}

	/* helpers */
	private static String p(HttpServletRequest r, String k, String d) {
		String v = r.getParameter(k);
		return v == null ? d : v;
	}

	private static Integer parseIntOrNull(String s) {
		try {
			return Integer.valueOf(s);
		} catch (Exception e) {
			return null;
		}
	}

	private static String back(HttpServletRequest r) {
		String b = r.getHeader("Referer");
		return (b == null || b.isBlank()) ? r.getContextPath() + "/home" : b;
	}

	private static void redirect(HttpServletResponse resp, String url, String key, String msg) throws IOException {
		String sep = url.contains("?") ? "&" : "?";
		resp.sendRedirect(
				url + sep + key + "=" + java.net.URLEncoder.encode(msg, java.nio.charset.StandardCharsets.UTF_8));
	}
}
