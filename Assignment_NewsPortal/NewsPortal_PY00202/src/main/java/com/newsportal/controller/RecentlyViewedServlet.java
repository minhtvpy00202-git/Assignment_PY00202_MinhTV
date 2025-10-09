package com.newsportal.controller;



import com.newsportal.dao.NewsDAO;
import com.newsportal.model.News;
import com.newsportal.util.Jdbc;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/recently-viewed")
public class RecentlyViewedServlet extends HttpServlet {
    private final NewsDAO newsDAO = new NewsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ss = req.getSession(false);
        List<Integer> ids = new ArrayList<>();
        if (ss != null) {
            @SuppressWarnings("unchecked")
            Deque<Integer> dq = (Deque<Integer>) ss.getAttribute("recentViews");
            if (dq != null) ids.addAll(dq);
        }

        // Lấy 5 id đầu tiên (đã sắp theo thứ tự mới nhất -> cũ)
        ids = ids.stream().distinct().limit(5).collect(Collectors.toList());

        List<News> ordered = Collections.emptyList();
        if (!ids.isEmpty()) {
            try {
                // Lấy tất cả bài theo IN (...)
                String placeholders = ids.stream().map(i -> "?").collect(Collectors.joining(","));
                String sql = """
                    SELECT Id, Title, [Content] AS Content, Image, PostedDate, Author,
                           ViewCount, CategoryId, Home, Approved, ReporterId
                    FROM News
                    WHERE Id IN (%s)
                    """.formatted(placeholders);

                List<News> fetched = Jdbc.query(sql, rs -> {
                    News n = new News();
                    n.setId(rs.getInt("Id"));
                    n.setTitle(rs.getString("Title"));
                    return n; // chỉ cần Title + Id cho sidebar
                }, ids.toArray());

                // Map theo Id rồi sắp lại đúng thứ tự ids
                Map<Integer, News> byId = new HashMap<>();
                for (News n : fetched) byId.put(n.getId(), n);

                List<News> tmp = new ArrayList<>();
                for (Integer id : ids) {
                    News n = byId.get(id);
                    if (n != null) tmp.add(n);
                }
                ordered = tmp;
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        req.setAttribute("recentNews", ordered);
        // forward tới partial JSP để render danh sách ở cột phải
        req.getRequestDispatcher("/WEB-INF/views/partials/recently-viewed.jsp")
           .forward(req, resp);
    }
}
