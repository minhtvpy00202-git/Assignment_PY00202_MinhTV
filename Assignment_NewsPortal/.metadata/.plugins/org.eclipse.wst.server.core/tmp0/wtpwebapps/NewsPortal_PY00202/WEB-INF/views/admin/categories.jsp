<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%@ include file="../layout/admin-header.jsp" %>


<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1>QUẢN LÝ LOẠI TIN</h1>
      <p>Thêm, sửa, xóa và quản lý các chuyên mục tin tức</p>
    </div>

    <div class="admin-layout-grid">
      <!-- Form Section -->
      <div class="form-section">
        <div class="admin-form-section">
          <h2>${empty item ? 'THÊM LOẠI TIN MỚI' : 'CHỈNH SỬA LOẠI TIN'}</h2>
          <form method="post" action="${ctx}/admin/categories" class="admin-form">
            <input type="hidden" name="action" value="${empty item ? 'create' : 'update'}"/>
            <input type="hidden" name="id" value="${item.id}"/>

            <div class="form-group">
              <label class="form-label">Tên loại tin</label>
              <input class="form-control" name="name" value="${item.name}" required placeholder="Ví dụ: Công nghệ, Thể thao, Giải trí..."/>
            </div>

            <div class="form-actions">
              <button type="submit" class="btn btn-primary">${empty item ? 'Thêm mới' : 'Cập nhật'}</button>
              <c:if test="${not empty item}">
                <a class="btn btn-outline-primary" href="${ctx}/admin/categories">Hủy</a>
              </c:if>
            </div>
          </form>
        </div>
      </div>

      <!-- Table Section -->
      <div class="table-section">
        <h2>DANH SÁCH LOẠI TIN</h2>
        <div class="table-wrapper">
          <table class="table">
            <thead>
              <tr>
                <th>STT</th>
                <th>ID</th>
                <th>Tên loại tin</th>
                <th style="width: 40px;">Hành động</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="c" items="${items}" varStatus="status">
                <tr>
                  <td>${status.index + 1}</td>
                  <td>${c.id}</td>
                  <td class="category-name">${c.name}</td>
                  <td class="actions">
                    <a class="btn btn-outline-primary" href="${ctx}/admin/categories?action=edit&id=${c.id}">Sửa</a>
                    <form method="post" action="${ctx}/admin/categories"
                          onsubmit="return confirm('Xóa loại tin này? Tất cả bài viết thuộc loại này sẽ bị ảnh hưởng.');">
                      <input type="hidden" name="action" value="delete"/>
                      <input type="hidden" name="id" value="${c.id}"/>
                      <button type="submit" class="btn btn-danger">Xóa</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
