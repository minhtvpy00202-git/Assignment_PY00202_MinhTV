package com.newsportal.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import com.newsportal.dao.CategoryDAO;
import com.newsportal.dao.NewsDAO;
import com.newsportal.model.Category;
import com.newsportal.model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({"/home", "/most-viewed", "/latest", "/recent" })
public class HomeServlet extends HttpServlet {

    private final NewsDAO newsDAO = new NewsDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    	
    	String path = req.getServletPath();
    	 String mode;
    	 String pageTitle;
    	 
    	 switch (path) {
    	 
    	 case "/home": {
    	 try {
             // 1) Danh mục để render menu
         	List<Category> categories = safeList(() -> categoryDAO.findAll());

             // 2) Tin trang nhất (Home=true)
         	List<News> approvedNews = safeList(() -> newsDAO.findHomeApproved(10));
         	req.setAttribute("approvedNews", approvedNews);

             // 3) Top 5 hot (view cao)
             List<News> hotList = safeList(() -> newsDAO.findTopHot(5));
             req.setAttribute("hotList", hotList);

             // 4) Top 5 mới (ngày đăng mới nhất)
             List<News> newList = safeList(() -> newsDAO.findTopNew(5));
             req.setAttribute("newList", newList);

             // 5) 5 tin xem gần đây (đọc từ cookie "recent" lưu id dạng: 31,22,10,...)
             List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
             List<News> recentList = findNewsByIdsPreserveOrder(recentIds);
             req.setAttribute("recentList", recentList);

             // Forward sang trang chủ
             req.setAttribute("categories", new CategoryDAO().findAll());
             req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
             return;
         } catch (Exception e) {
             // Có lỗi thì log và hiển thị trang rỗng thân thiện
             e.printStackTrace();
             req.setAttribute("error", "Không tải được dữ liệu trang chủ: " + e.getMessage());
             req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);	
             return;
         }
    	 }
    	 
    	 // Bài viết xem nhiều nhất
    	 case "/most-viewed": {
    		 List<News> items = safeList(() -> newsDAO.findTopHot(5));
    		 req.setAttribute("items", items);
    		 req.setAttribute("pageTitle", "Most Viewed");
    		 req.setAttribute("mode", "most");
    		 
    		 //Side bar:
    		 List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
    		 List<News> recentList = findNewsByIdsPreserveOrder(recentIds);
             req.setAttribute("recentList", recentList);
    		
    		 req.setAttribute("newList", safeList(() ->newsDAO.findTopNew(5)));
    		 
    		 req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
             return;
    		
    		 
    	 }
    	 
    	 //Bài viết mới nhất
    	 
    	 case "/latest":{
    		 List<News> items = safeList(() -> newsDAO.findTopNew(5));
             req.setAttribute("items", items);
             req.setAttribute("pageTitle", "Latest News");
             req.setAttribute("mode", "latest");
             //Side bar:
             List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
    		 List<News> recentList = findNewsByIdsPreserveOrder(recentIds);
             req.setAttribute("recentList", recentList);
             req.setAttribute("hotList", safeList(() -> newsDAO.findTopHot(5)));
             
             req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
             return;
             }
    	 
    	 //Bài viết mới đọc:
         case "/recent":{
        	 List<Integer> recentIds = readRecentIdsFromCookie(req, "recent", 5);
             List<News> items = findNewsByIdsPreserveOrder(recentIds);
             req.setAttribute("items", items);
             req.setAttribute("pageTitle", "Recent");
             req.setAttribute("mode", "recent");
             //Side bar:
             req.setAttribute("hotList", safeList(() -> newsDAO.findTopHot(5)));
             req.setAttribute("newList", safeList(() ->newsDAO.findTopNew(5)));
             
             req.getRequestDispatcher("/WEB-INF/views/top5.jsp").forward(req, resp);
             return;
             }
         default:{
             resp.sendError(HttpServletResponse.SC_NOT_FOUND);
             return;}
    	 
    	 }
    	 
    	
    	
        
    }

 // ----- Helpers -----
    @FunctionalInterface
    interface DaoCall<T> { T run() throws Exception; }

    /** Helper dành riêng cho List: nếu DAO ném exception thì trả về list rỗng đúng kiểu. */
    private static <E> java.util.List<E> safeList(DaoCall<java.util.List<E>> call) {
        try {
            return call.run();
        } catch (Exception e) {
            return java.util.Collections.emptyList();
        }
    }


    private List<Integer> readRecentIdsFromCookie(HttpServletRequest req, String name, int limit) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) return java.util.Collections.emptyList();

        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                String val = c.getValue();
                if (val == null || val.isBlank()) return java.util.Collections.emptyList();

                String decoded = java.net.URLDecoder.decode(val, java.nio.charset.StandardCharsets.UTF_8);
                return java.util.Arrays.stream(decoded.split("\\|"))
                        .map(String::trim)
                        .filter(s -> s.matches("\\d+"))
                        .map(Integer::parseInt)
                        .distinct()
                        .limit(limit)
                        .collect(java.util.stream.Collectors.toList());
            }
        }
        return java.util.Collections.emptyList();
    }


    /** Lấy tin theo danh sách id và giữ nguyên thứ tự ids  */
    private List<News> findNewsByIdsPreserveOrder(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyList();
        List<News> out = new ArrayList<>();
        for (Integer id : ids) {
            try {
                News n = newsDAO.findById(id);
                if (n != null) out.add(n);
            } catch (Exception ignored) {}
        }
        return out;
    }
}
