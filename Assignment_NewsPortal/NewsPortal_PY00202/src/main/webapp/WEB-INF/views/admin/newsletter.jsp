<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp"%>

<main class="container admin-page">
  <h2><fmt:message key="admin.newsletter.pageTitle"/></h2>

  <!-- Subscribe new email -->
<form method="post" action="${ctx}/admin/newsletter" class="form">
  <input type="hidden" name="action" value="create" />

  <label style="display:block">
    <fmt:message key="admin.newsletter.emailLabel"/>
    <input type="email" name="email" required
           placeholder="<fmt:message key='admin.newsletter.emailPlaceholder'/>" />
  </label>

  <!-- CHỌN CHUYÊN MỤC (giống sidebar, có i18n) -->
<c:set var="lang" value="${sessionScope.lang != null ? sessionScope.lang : 'vi'}"/>

<c:choose>
  <c:when test="${not empty categories}">
    <label for="newsletter-category" style="display:block">
      <fmt:message key="sidebar.newsletter.chooseCategory"/>
    </label>
    <select id="newsletter-category" name="categoryId" class="form-select">
      <!-- value rỗng -> backend hiểu là NULL: nhận mọi chuyên mục -->
      <option value="">
        <fmt:message key="admin.newsletter.category.all"/>
      </option>
      <c:forEach var="cat" items="${categories}">
        <!-- Hiển thị name đã được localize -->
        <option value="${cat.id}">
          <c:out value="${cat.name}"/>
        </option>
      </c:forEach>
    </select>
  </c:when>
  <c:otherwise>
    <p class="sidebar-empty">
      <fmt:message key="sidebar.newsletter.noCategory"/>
    </p>
  </c:otherwise>
</c:choose>


  <button type="submit">
    <fmt:message key="admin.newsletter.addBtn"/>
  </button>
</form>


  <div class="table-wrapper">
    <table class="table">
      <thead>
        <tr>
          <th><fmt:message key="admin.common.col.index"/></th>
          <th><fmt:message key="admin.newsletter.col.email"/></th>
          <th><fmt:message key="admin.newsletter.col.category"/></th>
          <th><fmt:message key="admin.newsletter.col.status"/></th>
          <th><fmt:message key="admin.common.col.actions"/></th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="n" items="${items}" varStatus="status">
          <tr>
            <td class="text-center">${status.index + 1}</td>
            <td>${n.email}</td>

            <td>
              <c:choose>
                <c:when test="${empty n.categoryId}">
                  <fmt:message key="admin.newsletter.category.all"/>
                </c:when>
                <c:when test="${categoryMap[n.categoryId] != null}">
                  ${categoryMap[n.categoryId]}
                </c:when>
                <c:otherwise>
                  <fmt:message key="admin.newsletter.category.deleted">
                    <fmt:param value="${n.categoryId}"/>
                  </fmt:message>
                </c:otherwise>
              </c:choose>
            </td>

            <td>
              
              <c:choose>
                <c:when test="${n.enabled}">
                  <fmt:message key="admin.newsletter.status.enabled"/>
                </c:when>
                <c:otherwise>
                  <fmt:message key="admin.newsletter.status.disabled"/>
                </c:otherwise>
              </c:choose>
            </td>

            <td class="actions">
              <!-- Toggle on/off -->
              <form method="post" action="${ctx}/admin/newsletter">
                <input type="hidden" name="action" value="update" />
                <input type="hidden" name="email" value="${n.email}" />
                <input type="hidden" name="enabled" value="${!n.enabled}" />
                <button type="submit" class="btn ghost">
                  <c:choose>
                    <c:when test="${n.enabled}">
                      <fmt:message key="admin.newsletter.toggle.off"/>
                    </c:when>
                    <c:otherwise>
                      <fmt:message key="admin.newsletter.toggle.on"/>
                    </c:otherwise>
                  </c:choose>
                </button>
              </form>

              <!-- Delete (unsubscribe) -->
              <form method="post" action="${ctx}/admin/newsletter"
                    onsubmit="return confirm('<fmt:message key="admin.newsletter.confirm.delete"/>');">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="email" value="${n.email}" />
                <button type="submit" class="btn danger">
                  <fmt:message key="admin.common.delete"/>
                </button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
