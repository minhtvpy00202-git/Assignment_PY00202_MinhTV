<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ include file="layout/header.jsp" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  /* layout 2 cột chỉ dùng khi public */
  .article-detail .layout {
    display: grid;
    grid-template-columns: 4fr 1fr;
    gap: 24px;
  }
  @media (max-width: 992px) { .article-detail .layout { grid-template-columns: 1fr; } }
  .related-box h3 { margin: 1.25rem 0 .5rem; }
  .related-list { list-style: none; padding: 0; margin: .25rem 0 0; }
  .related-list li { padding: 8px 0; border-bottom: 1px dashed #eee; }
  .related-list li:last-child { border-bottom: none; }
  .related-list a { text-decoration: none; color: #111; }
  .related-list a:hover { color: #2563eb; }
</style>

<main class="container article-detail">

  <!-- Nếu là public: dùng layout 2 cột; nếu duyệt: chỉ 1 cột như hiện tại -->
  <c:choose>
    <c:when test="${isPublic}">
      <div class="layout">
        <div class="news-content" style="border-right: 1px solid #e2e2e2; padding: 40px 40px 40px 0px; ">
          <%-- Nội dung bài --%>
          <jsp:include page="/WEB-INF/views/partials/article-core.jsp" />
          <%-- Tin cùng chuyên mục --%>
          <section class="related-box">
            <h3>Tin cùng chuyên mục</h3>
            <ul class="related-list">
              <c:forEach var="r" items="${related}">
                <li><a href="${ctx}/news/${r.id}">${r.title}</a></li>
              </c:forEach>
              <c:if test="${empty related}"><li>Chưa có bài liên quan.</li></c:if>
            </ul>
          </section>
        </div>
        <aside><jsp:include page="/WEB-INF/views/layout/sidebar.jsp" /></aside>
      </div>
    </c:when>

    <c:otherwise>
      <%-- Chế độ duyệt: giao diện giữ nguyên như hiện tại --%>
      <jsp:include page="/WEB-INF/views/partials/article-core.jsp" />
      <c:if test="${ref == 'approve'}">
        <div style="display:flex;gap:.5rem;justify-content:flex-end;margin-top:1rem">
          <form method="post" action="${ctx}/admin/news-approve">
            <input type="hidden" name="id" value="${news.id}">
            <button class="btn" name="action" value="approve">Duyệt</button>
            <button class="btn danger" name="action" value="reject"
                    onclick="return confirm('Xoá bài này?')">Từ chối</button>
          </form>
        </div>
      </c:if>
    </c:otherwise>
  </c:choose>

</main>

<%@ include file="layout/footer.jsp" %>
