<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="layout/header.jsp" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>


<main class="container">
  <div class="main-content">
    <article class="content-area">
      <header class="article-header">
        <h1 class="article-title">${news.title}</h1>
        <div class="article-meta">
          <span>Tác giả: <c:out value="${news.author}"/></span>
          <span>${news.viewCount} lượt xem</span>
          <span>Ngày đăng: ${news.postedDate}</span>
        </div>
      </header>
      
      

      <div class="article-content">
        <c:out value="${news.content}" escapeXml="false"/>
      </div>

      <div class="related-articles">
        <h2>Bài viết liên quan</h2>
        <ul class="related-list">
          <c:forEach var="rel" items="${related}">
            <li><a href="${pageContext.request.contextPath}/news/${rel.id}">${rel.title}</a></li>
          </c:forEach>
        </ul>
      </div>
    </article>

    <aside class="sidebar-area">
      <jsp:include page="layout/sidebar.jsp"/>
    </aside>
  </div>
</main>

<%@ include file="layout/footer.jsp" %>
