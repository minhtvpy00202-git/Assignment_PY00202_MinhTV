package com.newsportal.controller;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.dao.NewsletterDAO;
import com.newsportal.model.News;
import com.newsportal.model.Newsletter;
import com.newsportal.util.Mailer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Gộp 2 tuyến:
 *  - /admin/news-send       : gửi email cho 1 bài
 *  - /admin/news-bulk-send  : gửi email hàng loạt các bài
 */
@WebServlet({"/admin/news-send", "/admin/news-bulk-send"})
public class AdminNewsSendServlet extends HttpServlet {
    private final NewsletterDAO newsletterDAO = new NewsletterDAO();
    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();
        switch (path) {
            case "/admin/news-send" -> handleSendSingle(req, resp);
            case "/admin/news-bulk-send" -> handleSendBulk(req, resp);
            default -> resp.sendError(404);
        }
    }

    /* ================== /admin/news-send (1 bài) ================== */
    private void handleSendSingle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int newsId = pInt(req, "id", -1);
        if (newsId < 0) { resp.sendError(400, "Thiếu id bài viết"); return; }

        try {
            News n = newsDAO.findById(newsId);
            if (n == null) { resp.sendError(404, "Không tìm thấy bài viết"); return; }

            Integer catId = getCategoryId(n);
            // chỉ trả về email Enabled=1, IsDelete=0 và (CategoryId IS NULL hoặc = catId)
            List<String> emails = newsletterDAO.listActiveEmailsForCategory(catId);

            if (emails.isEmpty()) {
                redirectBack(req, resp, "Không có độc giả phù hợp để gửi.");
                return;
            }

            String link = buildNewsLink(req, n.getId());
            String subject = "Tin mới: " + n.getTitle();
            String preview = n.getExcerpt();
            String html = """
                <div style="font-family:Arial,sans-serif">
                  <h2>%s</h2>
                  <p>%s</p>
                  <p><a href="%s">Đọc bài đầy đủ »</a></p>
                  <hr>
                  <p style="font-size:12px;color:#999">
                    Bạn nhận được email này vì đã đăng ký nhận tin tại NewsPortal.
                    <br/>Nếu không muốn nhận nữa, bấm <a href="%s">hủy đăng ký</a>.
                  </p>
                </div>
            """.formatted(escape(n.getTitle()), escape(preview), link, buildUnsubLink(req));

            Mailer.sendBcc(emails, subject, html);
            redirectBack(req, resp, "Đã gửi email đến " + emails.size() + " độc giả.");
        } catch (Exception e) {
            throw new ServletException("Gửi email thất bại", e);
        }
    }

    /* ============== /admin/news-bulk-send (nhiều bài) ============== */
    private void handleSendBulk(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Cho phép xóa queue thủ công
        if ("1".equals(req.getParameter("clear"))) {
            var ss = req.getSession(false);
            if (ss != null) ss.removeAttribute("bulkSendQueue");
            back(resp, req, "Đã xóa danh sách gửi.");
            return;
        }

        // Lấy danh sách id từ form hoặc từ session queue
        List<Integer> newsIds = new ArrayList<>();
        String[] ids = req.getParameterValues("newsId");
        if (ids != null && ids.length > 0) {
            for (String s : ids) try { newsIds.add(Integer.parseInt(s)); } catch (Exception ignore) {}
        } else {
            var ss = req.getSession(false);
            if (ss != null) {
                @SuppressWarnings("unchecked")
                var q = (List<Integer>) ss.getAttribute("bulkSendQueue");
                if (q != null) newsIds.addAll(q);
            }
        }
        newsIds = newsIds.stream().distinct().collect(Collectors.toList());
        if (newsIds.isEmpty()) { back(resp, req, "Không có bài để gửi."); return; }

        try {
            // 1) Lấy bài & nhóm theo category
            List<News> newsList = newsDAO.findByIds(newsIds);
            if (newsList.isEmpty()) { back(resp, req, "Không tìm thấy bài hợp lệ để gửi."); return; }

            Map<Integer, List<News>> newsByCat = new HashMap<>();
            for (News n : newsList) {
                Integer c = n.getCategoryId();
                newsByCat.computeIfAbsent(c, k -> new ArrayList<>()).add(n);
            }
            Map<Integer, String> catMap = categoryDAO.toIdNameMap();

            // 2) Lấy subscribers đang bật (Enabled=1, IsDelete=0)
            List<Newsletter> subs = newsletterDAO.listActiveSubscribers();

            int totalRecipients = 0;

            // 3a) Nhóm “Tất cả chuyên mục” (CategoryId NULL)
            List<String> emailsAll = subs.stream()
                    .filter(s -> s.getCategoryId() == null)
                    .map(Newsletter::getEmail)
                    .collect(Collectors.toList());
            if (!emailsAll.isEmpty()) {
                String subjectAll = "[NewsPortal] Bản tin mới";
                Mailer.sendBcc(emailsAll, subjectAll, buildEmailHtml(newsList, req, "Bản tin mới"));
                totalRecipients += emailsAll.size();
            }

            // 3b) Từng chuyên mục cụ thể
            for (var e : newsByCat.entrySet()) {
                Integer catId = e.getKey();
                if (catId == null) continue; // đã bao phủ ở nhóm “Tất cả”
                List<String> emails = subs.stream()
                        .filter(s -> catId.equals(s.getCategoryId()))
                        .map(Newsletter::getEmail)
                        .collect(Collectors.toList());
                if (!emails.isEmpty()) {
                    String catName = catMap.getOrDefault(catId, "Chuyên mục");
                    String subject = "[NewsPortal] " + "Chuyên mục " + catName + " - Bản tin mới";
                    Mailer.sendBcc(emails, subject, buildEmailHtml(e.getValue(), req, catName));
                    totalRecipients += emails.size();
                }
            }

            // 4) Clear queue sau khi gửi
            var ss = req.getSession(false);
            if (ss != null) ss.removeAttribute("bulkSendQueue");

            if (totalRecipients == 0) back(resp, req, "Không có độc giả phù hợp để gửi (kiểm tra đăng ký & chuyên mục).");
            else back(resp, req, "Đã gửi email cho " + totalRecipients + " độc giả.");
        } catch (Exception ex) {
            throw new ServletException("Không gửi được email", ex);
        }
    }

    /* =========================== Helpers =========================== */

    private Integer getCategoryId(News n) {
        try { return (Integer) News.class.getMethod("getCategoryId").invoke(n); }
        catch (Exception ignore) { return null; }
    }

    private String buildNewsLink(HttpServletRequest req, int newsId) {
        String ctx = req.getContextPath();
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String base = scheme + "://" + host + ((port==80||port==443) ? "" : ":"+port) + ctx;
        return base + "/news/" + newsId;
    }

    private String buildUnsubLink(HttpServletRequest req) {
        String ctx = req.getContextPath();
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String base = scheme + "://" + host + ((port==80||port==443) ? "" : ":"+port) + ctx;
        return base + "/newsletter/unsubscribe";
    }

    private String buildEmailHtml(List<News> items, HttpServletRequest req, String heading) {
        String base = req.getScheme() + "://" + req.getServerName()
                + ((req.getServerPort()==80||req.getServerPort()==443)?"":":"+req.getServerPort())
                + req.getContextPath();

        String unsub = base + "/newsletter/unsubscribe";

        StringBuilder sb = new StringBuilder();
        sb.append("<div style='font-family:Arial,Helvetica,sans-serif;max-width:680px;margin:0 auto;color:#111'>");
        sb.append("<h2 style='margin:16px 0 8px;font-size:22px'>").append(escape(heading)).append("</h2>");
        sb.append("<p style='margin:0 0 16px;font-size:14px;color:#333'>")
          .append("Bạn nhận được email này vì đã đăng ký nhận tin của NewsPortal.")
          .append(" Bên dưới là các bài viết mới nhất phù hợp đăng ký của bạn.</p>");

        for (News n : items) {
            String link = base + "/news/" + n.getId();
            String title = escape(n.getTitle());
            String excerpt = excerptFrom(n);
            String img = fullImageUrl(base, getImageField(n));

            sb.append("<table role='presentation' width='100%' cellspacing='0' cellpadding='0' ")
              .append("style='border:1px solid #eee;border-radius:8px;margin:14px 0;padding:0'>")
              .append("<tr>");

            if (img != null) {
                sb.append("<td style='width:180px;padding:0'>")
                  .append("<a href='").append(link).append("'>")
                  .append("<img src='").append(img).append("' alt='' ")
                  .append("style='display:block;width:180px;height:120px;object-fit:cover;border-top-left-radius:8px;border-bottom-left-radius:8px;border-right:1px solid #eee'/>")
                  .append("</a></td>");
            }

            sb.append("<td style='padding:12px 16px'>")
              .append("<h3 style='margin:0 0 6px;font-size:16px;line-height:1.35'>")
              .append("<a href='").append(link).append("' style='color:#0b5bd3;text-decoration:none'>")
              .append(title).append("</a></h3>")
              .append("<p style='margin:0 0 10px;font-size:14px;color:#444;line-height:1.5'>")
              .append(excerpt).append("</p>")
              .append("<a href='").append(link).append("' ")
              .append("style='display:inline-block;background:#0b5bd3;color:#fff;text-decoration:none;padding:8px 12px;border-radius:6px;font-size:14px'>Đọc bài</a>")
              .append("</td>");

            sb.append("</tr></table>");
        }

        sb.append("<hr style='border:none;border-top:1px solid #eee;margin:16px 0'>")
          .append("<p style='font-size:12px;color:#777;margin:0 0 6px'>")
          .append("Nếu bạn không muốn nhận nữa, hãy <a href='").append(unsub).append("' style='color:#0b5bd3'>hủy đăng ký</a>.")
          .append("</p>")
          .append("<p style='font-size:12px;color:#aaa;margin:0'>© ")
          .append(java.time.Year.now()).append(" NewsPortal</p>")
          .append("</div>");

        return sb.toString();
    }

    private String excerptFrom(News n) {
        try {
            var m = News.class.getMethod("getExcerpt");
            Object ex = m.invoke(n);
            if (ex != null) {
                String s = ex.toString();
                if (!s.isBlank()) return escape(s);
            }
        } catch (NoSuchMethodException ignore) {
        } catch (Exception e) { /* ignore */ }

        String raw = "";
        try {
            var m = News.class.getMethod("getContent");
            Object c = m.invoke(n);
            if (c != null) raw = c.toString();
        } catch (Exception ignore) {}

        String plain = raw.replaceAll("(?s)<[^>]*>", "").trim();
        if (plain.length() > 160) plain = plain.substring(0, 160) + "...";
        return escape(plain);
    }

    private Object getImageField(News n) {
        try { return News.class.getMethod("getImage").invoke(n); }
        catch (Exception e) { return null; }
    }

    private String fullImageUrl(String base, Object imageField) {
        if (imageField == null) return null;
        String img = imageField.toString().trim();
        if (img.isEmpty()) return null;
        if (img.startsWith("http://") || img.startsWith("https://")) return img;
        return base + "/uploads/" + img;
    }

    private static String escape(String s){ return s==null? "" : s.replace("<","&lt;").replace(">","&gt;"); }

    private void back(HttpServletResponse resp, HttpServletRequest req, String msg) throws IOException {
        String referer = req.getHeader("Referer");
        if (referer == null || referer.isBlank()) referer = req.getContextPath()+"/admin/news-approve";
        String sep = referer.contains("?")?"&":"?";
        resp.sendRedirect(referer + sep + "msg=" + java.net.URLEncoder.encode(msg, java.nio.charset.StandardCharsets.UTF_8));
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        String back = req.getHeader("Referer");
        if (back == null || back.isBlank()) back = req.getContextPath() + "/admin/news-approve";
        String sep = back.contains("?") ? "&" : "?";
        resp.sendRedirect(back + sep + "msg=" + java.net.URLEncoder.encode(msg, java.nio.charset.StandardCharsets.UTF_8));
    }

    private int pInt(HttpServletRequest r, String k, int def) {
        try { return Integer.parseInt(r.getParameter(k)); }
        catch (Exception e) { return def; }
    }
}
