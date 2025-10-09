package com.newsportal.controller;

import com.newsportal.dao.NewsletterDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

@WebServlet("/newsletter/*")   // <— đổi: dùng wildcard
public class NewsletterServlet extends HttpServlet {
    private final NewsletterDAO dao = new NewsletterDAO();
    private static final Pattern EMAIL_RE = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // Với url-pattern /newsletter/* thì:
        //   getServletPath() -> "/newsletter"
        //   getPathInfo()    -> "/subscribe" hoặc "/unsubscribe"
        String action = req.getPathInfo();     // "/subscribe" | "/unsubscribe"
        String email  = p(req, "email", "").trim().toLowerCase();

        String back = req.getHeader("Referer");
        if (back == null || back.isBlank()) back = req.getContextPath() + "/home";

        try {
            if (!EMAIL_RE.matcher(email).matches()) {
                redirectWithMsg(resp, back, "sub_msg", "Email không hợp lệ");
                return;
            }

            if ("/subscribe".equals(action)) {
                dao.subscribe(email);
                redirectWithMsg(resp, back, "sub_msg", "Đăng ký newsletter thành công!");
                return;
            }
            if ("/unsubscribe".equals(action)) {
                dao.unsubscribe(email);
                redirectWithMsg(resp, back, "sub_msg", "Đã hủy nhận newsletter.");
                return;
            }

            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception e) {
            throw new ServletException("Không xử lý được newsletter", e);
        }
    }

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/home");
    }

    private String p(HttpServletRequest r, String k, String d) {
        String v = r.getParameter(k);
        return (v == null) ? d : v;
    }
    private void redirectWithMsg(HttpServletResponse resp, String backUrl, String key, String msg)
            throws IOException {
        String sep = backUrl.contains("?") ? "&" : "?";
        String url = backUrl + sep + key + "=" + URLEncoder.encode(msg, StandardCharsets.UTF_8);
        resp.sendRedirect(url);
    }
}
