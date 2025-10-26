<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<main class="container">
  <section class="content">
    <h1>
      <fmt:message key="reporter.preview.title">
        <fmt:param value="${news.title}"/>
      </fmt:message>
    </h1>
    <div class="meta">
      <fmt:message key="news.by"/>: ${news.author}
      · <fmt:message key="news.category"/>: ${news.categoryId}
    </div>

    <c:if test="${not empty news.image}">
      <img class="mt-24" src="${pageContext.request.contextPath}/assets/img/${news.image}">
    </c:if>

    <div class="mt-24">${news.content}</div>

    <div class="actions mt-24">
      <a class="btn" href="${pageContext.request.contextPath}/reporter/post-edit?id=${news.id}">
        <fmt:message key="admin.common.edit"/>
      </a>
      <a class="btn ghost" href="${pageContext.request.contextPath}/reporter/posts">
        <fmt:message key="common.back"/>
      </a>
    </div>
  </section>
</main>

<%@ include file="../layout/footer.jsp" %>
