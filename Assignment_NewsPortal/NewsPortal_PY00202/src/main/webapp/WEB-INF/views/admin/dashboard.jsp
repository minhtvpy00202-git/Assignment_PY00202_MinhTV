<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="🗞️ Dashboard Admin - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1><fmt:message key="admin.dashboard.title"/></h1>
      <p><fmt:message key="admin.dashboard.subtitle"/></p>
      <a href="${pageContext.request.contextPath}/admin/news-approve" class="btn btn-primary">
        <fmt:message key="admin.dashboard.reviewBtn"/>
      </a>
    </div>

    <div class="admin-dashboard">
      <div class="dashboard-card">
        <h3>${newsTotal != null ? newsTotal : 0}</h3>
        <p><fmt:message key="admin.dashboard.totalNews"/></p>
      </div>

      <div class="dashboard-card">
        <h3>${pendingCount != null ? pendingCount : 0}</h3>
        <p><fmt:message key="admin.dashboard.pending"/></p>
      </div>

      <div class="dashboard-card">
        <h3>${usersTotal != null ? usersTotal : 0}</h3>
        <p><fmt:message key="admin.dashboard.users"/></p>
      </div>
    </div>

    <div class="dashboard-sections">
      <!-- Categories -->
      <div class="section">
        <div class="section-header">
          <h2><fmt:message key="admin.dashboard.categories"/></h2>
          <a href="${pageContext.request.contextPath}/admin/categories">
            <fmt:message key="admin.dashboard.manageArrow"/>
          </a>
        </div>

        <div class="categories-list">
          <c:choose>
            <c:when test="${not empty categories}">
              <c:forEach var="c" items="${categories}" varStatus="status">
                <c:if test="${status.index < 6}">
                  <div class="category-item"><span>${c.name}</span></div>
                </c:if>
              </c:forEach>
              <c:if test="${categories.size() > 6}">
                <div class="category-item">
                  <span>+${categories.size() - 6} <fmt:message key="admin.dashboard.more"/></span>
                </div>
              </c:if>
            </c:when>
            <c:otherwise>
              <p><fmt:message key="admin.dashboard.noCategory"/></p>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- Pending posts -->
      <div class="section">
        <div class="section-header">
          <h2><fmt:message key="admin.dashboard.pendingArticles"/></h2>
          <a href="${pageContext.request.contextPath}/admin/news-approve">
            <fmt:message key="admin.dashboard.viewAllArrow"/>
          </a>
        </div>

        <c:choose>
          <c:when test="${not empty pendingList}">
            <div class="pending-articles">
              <c:forEach var="n" items="${pendingList}" varStatus="st">
                <c:if test="${st.index < 5}">
                  <div class="pending-article">
                    <div class="article-info">
                      <h4><c:out value="${n.title}" /></h4>
                      <p class="article-meta">
                        <fmt:message key="news.by"/>: ${n.author}
                        | <fmt:message key="news.category"/>: ${catMap[n.categoryId]}
                        <c:if test="${n.home}"> | <fmt:message key="admin.dashboard.homeFlag"/></c:if>
                      </p>
                    </div>
                    <div class="article-actions">
                      <form method="post" action="${pageContext.request.contextPath}/admin/news-approve">
                        <input type="hidden" name="id" value="${n.id}">
                        <input type="hidden" name="action" value="approve">
                        <button type="submit" class="btn btn-success">
                          <fmt:message key="admin.dashboard.approve"/>
                        </button>
                      </form>
                      <form method="post" action="${pageContext.request.contextPath}/admin/news-approve"
                            onsubmit="return confirm('<fmt:message key="admin.dashboard.rejectConfirm"/>');">
                        <input type="hidden" name="id" value="${n.id}">
                        <input type="hidden" name="action" value="reject">
                        <button type="submit" class="btn btn-danger">
                          <fmt:message key="admin.dashboard.reject"/>
                        </button>
                      </form>
                    </div>
                  </div>
                </c:if>
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
