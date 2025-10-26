<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../layout/admin-header.jsp"%>
<c:set var="genderMaleLabel"><fmt:message key="auth.gender.male"/></c:set>
<c:set var="genderFemaleLabel"><fmt:message key="auth.gender.female"/></c:set>


<main class="container admin-page">

  <c:if test="${not empty sessionScope.flashMsg}">
    <div class="alert ${sessionScope.flashType}">
      ${sessionScope.flashMsg}
    </div>
    <c:remove var="flashMsg" scope="session"/>
    <c:remove var="flashType" scope="session"/>
  </c:if>

  <c:if test="${empty list}">
    <p style="text-align: center; border: 1px solid #ddd;">
      <fmt:message key="admin.usersPending.empty"/>
    </p>
  </c:if>

  <c:if test="${not empty list}">
    <body class="admin-layout">
      <main class="admin-main">
        <div class="container">
          <div class="table-section">
            <h2><fmt:message key="admin.usersPending.title"/></h2>
            <div class="table-wrapper">
              <table class="table">
                <thead>
                  <tr>
                    <th><fmt:message key="admin.common.col.index"/></th>
                    <th>ID</th>
                    <th><fmt:message key="auth.fullname"/></th>
                    <th><fmt:message key="auth.email"/></th>
                    <th><fmt:message key="auth.phone"/></th>
                    <th><fmt:message key="auth.gender"/></th>
                    <th><fmt:message key="auth.birthday"/></th>
                    <th><fmt:message key="auth.role"/></th>
                    <th><fmt:message key="admin.common.col.actions"/></th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="u" items="${list}" varStatus="status">
                    <tr>
                      <td class="text-center">${status.index + 1}</td>
                      <td>${u.id}</td>
                      <td>${u.fullname}</td>
                      <td>${u.email}</td>
                      <td>${empty u.mobile ? '-' : u.mobile}</td>
                      <td><c:out value="${u.gender ? genderMaleLabel : genderFemaleLabel}"/></td>

                      <td>
                        <c:choose>
                          <c:when test="${u.birthday != null}">
                            <fmt:formatDate value="${u.birthday}" pattern="dd/MM/yyyy" />
                          </c:when>
                          <c:otherwise>-</c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <span class="badge ${u.role ? 'success' : 'info'}">
                          ${u.role ? 'Admin' : 'Reporter'}
                        </span>
                      </td>
                      <td class="actions">
                        <div class="action-buttons-compact">
                          <form method="post" action="${pageContext.request.contextPath}/admin/users-pending">
                            <input type="hidden" name="id" value="${u.id}">
                            <input type="hidden" name="action" value="approve">
                            <button type="submit" class="btn btn-approve"
                                    title="<fmt:message key='admin.usersPending.approveTitle'/>">✓</button>
                          </form>

                          <form method="post" action="${pageContext.request.contextPath}/admin/users-pending"
                                onsubmit="return confirm('<fmt:message key="admin.usersPending.confirm.reject"/>')">
                            <input type="hidden" name="id" value="${u.id}">
                            <input type="hidden" name="action" value="reject">
                            <button type="submit" class="btn btn-reject"
                                    title="<fmt:message key='admin.usersPending.rejectTitle'/>">✗</button>
                          </form>

                          <form method="post" action="${pageContext.request.contextPath}/admin/users-pending">
                            <input type="hidden" name="id" value="${u.id}">
                            <input type="hidden" name="action" value="toggle-role">
                            <button type="submit" class="btn btn-toggle"
                                    title="<fmt:message key='admin.usersPending.toggleRole'/>">🔁</button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </body>
  </c:if>
</main>

<script>
  setTimeout(()=> {
    const el = document.querySelector('.alert');
    if (el) el.style.display = 'none';
  }, 3000);
</script>

<%-- Nhãn giới tính động --%>
<c:set var="genderMaleLabel"><fmt:message key="auth.gender.male"/></c:set>
<c:set var="genderFemaleLabel"><fmt:message key="auth.gender.female"/></c:set>

<%@ include file="../layout/footer.jsp"%>
