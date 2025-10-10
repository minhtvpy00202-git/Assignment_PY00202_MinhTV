<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

<main class="container admin-page">
  <h1>Tài khoản chờ duyệt</h1>

  <c:if test="${empty list}">
    <p>Không có tài khoản nào đang chờ duyệt.</p>
  </c:if>

  <c:if test="${not empty list}">
    <div class="table-wrapper">
      <table class="table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Họ tên</th>
          <th>Email</th>
          <th>Mobile</th>
          <th>Giới tính</th>
          <th>Ngày sinh</th>
          <th>Vai trò</th>
          <th>Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="u" items="${list}">
          <tr>
            <td>${u.id}</td>
            <td>${u.fullname}</td>
            <td>${u.email}</td>
            <td>${empty u.mobile ? '-' : u.mobile}</td>
            <td><c:out value="${u.gender ? 'Nam' : 'Nữ'}"/></td>
            <td>
              <c:choose>
                <c:when test="${u.birthday != null}">
                  ${u.birthday}
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>
            <td>
              <span class="badge ${u.role ? 'success' : 'info'}">
                ${u.role ? 'Admin' : 'Reporter'}
              </span>
            </td>
            <td>
              <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline">
                <input type="hidden" name="id" value="${u.id}">
                <input type="hidden" name="action" value="approve">
                <button class="btn small">Duyệt</button>
              </form>

              <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline" onsubmit="return confirm('Xóa tài khoản này?')">
                <input type="hidden" name="id" value="${u.id}">
                <input type="hidden" name="action" value="reject">
                <button class="btn small danger">Từ chối</button>
              </form>

              <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline">
                <input type="hidden" name="id" value="${u.id}">
                <input type="hidden" name="action" value="toggle-role">
                <button class="btn small ghost">Đổi vai trò</button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </tbody>
      </table>
    </div>
  </c:if>
</main>

<%@ include file="../layout/footer.jsp" %>
