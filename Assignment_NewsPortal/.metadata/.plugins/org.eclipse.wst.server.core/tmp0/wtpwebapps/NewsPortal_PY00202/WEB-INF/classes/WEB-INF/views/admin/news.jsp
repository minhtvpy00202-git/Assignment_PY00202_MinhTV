<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">
<main class="container admin-page">
          <h2>Quản lý Tin tức</h2>

          <!-- Form Create/Update -->
          <form method="post" action="${ctx}/admin/news" enctype="multipart/form-data" class="form">
            <input type="hidden" name="action" value="${empty item ? 'create' : 'update'}" />
            <input type="hidden" name="id" value="${item.id}" />

            <label>Tiêu đề
              <input name="title" value="${item.title}" required />
            </label>

            <label>Loại tin
              <select name="categoryId" required>
                <c:forEach var="c" items="${categories}">
                  <option value="${c.id}" ${item.categoryId==c.id ? 'selected' : '' }>${c.name}</option>
                </c:forEach>
              </select>
            </label>

            <label>Ảnh đại diện (tùy chọn)
              <input type="file" name="thumbnail" />
            </label>

            <label>Nội dung
              <textarea name="content" rows="6">${item.content}</textarea>
            </label>

            <button type="submit">${empty item ? 'Thêm mới' : 'Cập nhật'}</button>
            <c:if test="${not empty item}">
              <a class="btn" href="${ctx}/admin/news">Hủy</a>
            </c:if>
          </form>

          <!-- Danh sách -->
          <div class="table-wrapper">
            <table class="table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tiêu đề</th>
                  <th>Loại</th>
                  <th>Hành động</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="n" items="${items}">
                  <tr>
                    <td>${n.id}</td>
                    <td>
                      <c:out value="${n.title}" />
                    </td>
                    <td>
                      <c:forEach var="c" items="${categories}">
                        <c:if test="${c.id == n.categoryId}">${c.name}</c:if>
                      </c:forEach>
                    </td>
                    <td class="actions">
                      <a class="btn ghost" href="${ctx}/admin/news?action=edit&id=${n.id}">Sửa</a>
                      <form method="post" action="${ctx}/admin/news" style="display:inline"
                        onsubmit="return confirm('Xóa mục này?');">
                        <input type="hidden" name="action" value="delete" />
                        <input type="hidden" name="id" value="${n.id}" />
                        <button type="submit" class="btn danger">Xóa</button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />