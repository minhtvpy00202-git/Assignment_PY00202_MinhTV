<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <%@ include file="../layout/admin-header.jsp" %>


<main class="container admin-main">
  <section class="content">
    <h1>Tin tức của tôi</h1>

    <div class="actions">
      <a class="btn" href="${pageContext.request.contextPath}/reporter/post-create">Đăng bài mới</a>
    </div>

    <c:if test="${empty newsList}">
      <div class="card">Chưa có bài viết nào.</div>
    </c:if>

    <c:forEach var="n" items="${newsList}">
      <div class="card article">
        <h3>
          <a href="${pageContext.request.contextPath}/news-detail?id=${n.id}" target="_blank">${n.title}</a>
        </h3>
        <small>
          Chuyên mục #${n.categoryId}
          • Lượt xem: ${n.viewCount}
          • Trạng thái: <strong>${n.approved ? 'Đã duyệt' : 'Chờ duyệt'}</strong>
          <c:if test="${n.home}"> • Trang chủ</c:if>
        </small>

        <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete" class="actions">
          <input type="hidden" name="id" value="${n.id}">
          <a class="btn" href="${pageContext.request.contextPath}/reporter/post-edit?id=${n.id}">Sửa</a>
          <button class="btn danger" onclick="return confirm('Xoá bài này?')">Xoá</button>
        </form>
      </div>
    </c:forEach>
  </section>
</main>

<%@ include file="../layout/footer.jsp"%>
