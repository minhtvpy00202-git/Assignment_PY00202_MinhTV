<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Reporter Dashboard - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1><fmt:message key="reporter.dashboard.title"/></h1>
      <p><fmt:message key="reporter.dashboard.subtitle"/></p>
      <a href="${pageContext.request.contextPath}/reporter/post-create" class="btn btn-primary">
        <fmt:message key="reporter.common.newPost"/>
      </a>
    </div>

    <div class="admin-dashboard">
      <div class="dashboard-card">
        <h3>${stats != null ? stats.total : 0}</h3>
        <p><fmt:message key="reporter.stats.total"/></p>
      </div>
      <div class="dashboard-card">
        <h3>${stats != null ? stats.pending : 0}</h3>
        <p><fmt:message key="reporter.stats.pending"/></p>
      </div>
      <div class="dashboard-card">
        <h3>${stats != null ? stats.approved : 0}</h3>
        <p><fmt:message key="reporter.stats.approved"/></p>
      </div>
    </div>

    <div class="dashboard-sections">
      <div class="section">
        <div class="section-header">
          <h2><fmt:message key="reporter.quick.title"/></h2>
          <a href="${pageContext.request.contextPath}/reporter/posts">
            <fmt:message key="admin.dashboard.manageArrow"/>
          </a>
        </div>

        <div class="categories-list">
          <div class="category-item">
            <a href="${pageContext.request.contextPath}/reporter/post-create">
              ✏️ <fmt:message key="reporter.quick.write"/>
            </a>
          </div>
          <div class="category-item">
            <a href="${pageContext.request.contextPath}/reporter/posts">
              📝 <fmt:message key="reporter.quick.manage"/>
            </a>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-header">
          <h2><fmt:message key="reporter.pending.title"/></h2>
          <a href="${pageContext.request.contextPath}/reporter/posts?status=pending">
            <fmt:message key="admin.dashboard.viewAllArrow"/>
          </a>
        </div>

        <c:choose>
          <c:when test="${not empty myPending}">
            <div class="pending-articles">
              <c:forEach var="n" items="${myPending}">
                <div class="pending-article">
                  <div class="article-info">
                    <h4><c:out value="${n.title}" /></h4>
                    <p class="article-meta">
                      <fmt:message key="reporter.meta.category"/>: ${catMap[n.categoryId]}
                      <c:if test="${n.home}"> | <fmt:message key="admin.dashboard.homeFlag"/></c:if>
                    </p>
                  </div>
                  <div class="article-actions">
                    <a class="btn btn-outline-primary"
                       href="${pageContext.request.contextPath}/reporter/post-edit?id=${n.id}">
                      <fmt:message key="admin.common.edit"/>
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete"
                          onsubmit="return confirm('<fmt:message key="reporter.common.confirmDelete"/>');">
                      <input type="hidden" name="id" value="${n.id}" />
                      <button type="submit" class="btn btn-danger">
                        <fmt:message key="admin.common.delete"/>
                      </button>
                    </form>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:when>
          <c:otherwise>
            <p><fmt:message key="admin.dashboard.noPending"/></p>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</main>

<%@ include file="../layout/footer.jsp" %>
