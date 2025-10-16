<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ include file="../layout/admin-header.jsp" %>

<main class="container admin-page">
  <h2>DUYỆT BÀI VIẾT</h2>

  <c:if test="${empty pendingList}">
    <p style="text-align: center; border: 1px solid #ddd;">Không có bài viết chờ duyệt.</p>
  </c:if>

  <c:forEach var="n" items="${pendingList}">
    <div class="card article">
      <h3>${n.title}</h3>
      <small>
        Đăng bởi:
        <c:set var="author" value="${reporters[n.reporterId]}" />
        ${author != null ? author.fullname : '—'} - Ngày đăng: ${n.postedDateFormatted}
      </small>
      
      <!-- Đoạn hiển thị nội dung tóm tắt -->
    <p>${n.excerpt}</p>

      <form method="post" action="${pageContext.request.contextPath}/admin/news-approve" class="actions">
      <div class="con">
        <input type="hidden" name="id" value="${n.id}">
        <button class="btn" name="action" value="approve">Duyệt</button>
        <button class="btn ghost" name="action" value="home-on">Đưa Lên Trang chủ</button>
        <button class="btn danger" name="action" value="reject" onclick="return confirm('Xoá bài này?')">Xoá</button>
      </div>
      </form>
      
    </div>
  </c:forEach>
</main>

<%@ include file="../layout/footer.jsp" %>
