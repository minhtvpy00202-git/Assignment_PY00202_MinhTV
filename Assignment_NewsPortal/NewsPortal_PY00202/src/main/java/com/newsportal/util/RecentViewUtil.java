package com.newsportal.util;

import jakarta.servlet.http.HttpSession;
import java.util.ArrayDeque;
import java.util.Deque;

public final class RecentViewUtil {
    private RecentViewUtil(){}

    @SuppressWarnings("unchecked")
    public static void push(HttpSession session, int newsId) {
        Deque<Integer> dq = (Deque<Integer>) session.getAttribute("recentViews");
        if (dq == null) {
            dq = new ArrayDeque<>();
            session.setAttribute("recentViews", dq);
        }
        // bỏ bản ghi trùng, đẩy lên đầu
        dq.remove(newsId);
        dq.addFirst(newsId);
        // giữ tối đa 50 id (để sau này còn analytics), cột phải chỉ lấy 5
        while (dq.size() > 50) dq.removeLast();
    }
}
