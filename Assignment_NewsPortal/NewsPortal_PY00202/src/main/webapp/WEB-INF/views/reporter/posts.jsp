<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Manage Posts - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">

    <div class="page-header">
      <h1><fmt:message key="reporter.posts.title"/></h1>
      <p><fmt:message key="reporter.posts.subtitle"/></p>
      <a href="${pageContext.request.contextPath}/reporter/post-create" class="btn btn-primary">
        <fmt:message key="reporter.common.newPost"/>
      </a>
    </div>

    <div class="admin-dashboard">
      <div class="dashboard-card">
        <h3>${totalPosts != null ? totalPosts : 0}</h3>
        <p><fmt:message key="reporter.stats.total"/></p>
      </div>
      <div class="dashboard-card">
        <h3>${pendingPosts != null ? pendingPosts : 0}</h3>
        <p><fmt:message key="reporter.stats.pending"/></p>
      </div>
      <div class="dashboard-card">
        <h3>${approvedPosts != null ? approvedPosts : 0}</h3>
        <p><fmt:message key="reporter.stats.approved"/></p>
      </div>
    </div>

    <div class="table-section">
      <h2><fmt:message key="reporter.posts.listTitle"/></h2>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>

      <c:choose>
        <c:when test="${empty posts}">
          <p>
            <fmt:message key="reporter.common.none"/>
            <a href="${pageContext.request.contextPath}/reporter/post-create">
              <fmt:message key="reporter.common.newPost"/> →
            </a>
          </p>
        </c:when>
        <c:otherwise>
          <div class="table-wrapper">
            <table class="table">
              <thead>
                <tr>
                  <th><fmt:message key="admin.common.col.index"/></th>
                  <th><fmt:message key="admin.news.col.title"/></th>
                  <th><fmt:message key="admin.news.col.category"/></th>
                  <th><fmt:message key="admin.news.col.postedDate"/></th>
                  <th><fmt:message key="reporter.meta.views"/></th>
                  <th><fmt:message key="reporter.meta.status"/></th>
                  <th><fmt:message key="admin.common.col.actions"/></th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="post" items="${posts}" varStatus="st">
                  <tr>
                    <td class="text-center">${st.index + 1}</td>
                    <td>
                      <strong>${post.title}</strong>
                      <c:if test="${post.home}">
                        <span class="badge"><fmt:message key="admin.dashboard.homeFlag"/></span>
                      </c:if>
                    </td>
                    <td>
                      ${categoryMap[post.categoryId] != null ? categoryMap[post.categoryId] : '—'}
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${post.postedDate != null}">
                          ${post.postedDate.toString().substring(0,16).replace('T',' ')}
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-center"><strong>${post.viewCount}</strong></td>
                    <td>
                      <span class="badge ${post.approved ? '' : 'alert-warning'}">
                        ${post.approved ? '<fmt:message key="reporter.status.approved"/>' :
                                          '<fmt:message key="reporter.status.pending"/>'}
                      </span>
                    </td>
                    <td class="actions">
                      <a class="btn btn-outline-primary" title="<fmt:message key='reporter.action.view'/>"
                         href="${pageContext.request.contextPath}/news-detail?id=${post.id}">
                        <fmt:message key="reporter.action.view"/>
                      </a>
                      <a class="btn btn-outline-primary" title="<fmt:message key='admin.common.edit'/>"
                         href="${pageContext.request.contextPath}/reporter/post-edit?id=${post.id}">
                        <fmt:message key="admin.common.edit"/>
                      </a>
                      <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete"
                            onsubmit="return confirm('<fmt:message key="reporter.common.confirmDelete"/>');">
                        <input type="hidden" name="id" value="${post.id}">
                        <button type="submit" class="btn btn-danger">
                          <fmt:message key="admin.common.delete"/>
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</main>

<%@ include file="../layout/footer.jsp" %>
