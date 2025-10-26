<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%@ include file="../layout/admin-header.jsp" %>

<main class="container admin-main">
  <section class="content">
    <h1><fmt:message key="reporter.myNews.title"/></h1>

    <div class="actions">
      <a class="btn" href="${pageContext.request.contextPath}/reporter/post-create">
        <fmt:message key="reporter.common.newPost"/>
      </a>
    </div>

    <c:if test="${empty newsList}">
      <div class="card"><fmt:message key="reporter.common.none"/></div>
    </c:if>

    <c:forEach var="n" items="${newsList}">
      <div class="card article">
        <h3>
          <a href="${pageContext.request.contextPath}/news-detail?id=${n.id}" target="_blank">
            ${n.title}
          </a>
        </h3>
        <small>
          <fmt:message key="reporter.meta.category"/> #${n.categoryId}
          • <fmt:message key="reporter.meta.views"/>: ${n.viewCount}
          • <fmt:message key="reporter.meta.status"/>:
            <strong>${n.approved ? '<fmt:message key="reporter.status.approved"/>' : '<fmt:message key="reporter.status.pending"/>'}</strong>
          <c:if test="${n.home}"> • <fmt:message key="admin.dashboard.homeFlag"/></c:if>
        </small>

        <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete" class="actions"
              onsubmit="return confirm('<fmt:message key="reporter.common.confirmDelete"/>');">
          <input type="hidden" name="id" value="${n.id}">
          <a class="btn" href="${pageContext.request.contextPath}/reporter/post-edit?id=${n.id}">
            <fmt:message key="admin.common.edit"/>
          </a>
          <button class="btn danger"><fmt:message key="admin.common.delete"/></button>
        </form>
      </div>
    </c:forEach>
  </section>
</main>

<%@ include file="../layout/footer.jsp"%>
