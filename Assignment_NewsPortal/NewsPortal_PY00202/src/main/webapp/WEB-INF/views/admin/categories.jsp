<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

<main class="container admin-page">
  <h2>Quản lý Loại tin</h2>

  <form method="post" action="${ctx}/admin/categories" class="form">
    <input type="hidden" name="action" value="${empty item ? 'create' : 'update'}"/>
    <input type="hidden" name="id" value="${item.id}"/>

    <label>Tên loại
      <input name="name" value="${item.name}" required/>
    </label>

    <button type="submit">${empty item ? 'Thêm mới' : 'Cập nhật'}</button>
    <c:if test="${not empty item}">
      <a class="btn" href="${ctx}/admin/categories">Hủy</a>
    </c:if>
  </form>

  <div class="table-wrapper">
    <table class="table">
    <thead><tr><th>ID</th><th>Tên</th><th>Hành động</th></tr></thead>
    <tbody>
      <c:forEach var="c" items="${items}">
        <tr>
          <td>${c.id}</td>
          <td>${c.name}</td>
          <td class="actions">
            <a class="btn ghost" href="${ctx}/admin/categories?action=edit&id=${c.id}">Sửa</a>
            <form method="post" action="${ctx}/admin/categories" style="display:inline"
                  onsubmit="return confirm('Xóa loại này?');">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" name="id" value="${c.id}"/>
              <button type="submit" class="btn danger">Xóa</button>
            </form>
          </td>
        </tr>
      </c:forEach>
    </tbody>
    </table>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
