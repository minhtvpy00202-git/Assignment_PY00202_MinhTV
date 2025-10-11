<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

<main class="container admin-page">
  <h2>Quản lý Newsletter</h2>

        <!-- Đăng ký email mới (subscribe) -->
        <form method="post" action="${ctx}/admin/newsletter" class="form">
          <input type="hidden" name="action" value="create" />
          <label>Email
            <input type="email" name="email" required placeholder="email@domain.com" />
          </label>
          <button type="submit">Thêm (Subscribe)</button>
        </form>

        <div class="table-wrapper">
          <table class="table">
            <thead>
              <tr>
                <th>STT</th>
                <th>Email</th>
                <th>Trạng thái</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="n" items="${items}" varStatus="status">
                <tr>
                  <td class="text-center">${status.index + 1}</td>
                  <td>${n.email}</td>
                  <td>
                    <c:out value="${n.enabled ? 'Đang nhận' : 'Đã hủy'}" />
                  </td>
                  <td class="actions">
                    <!-- Toggle bật/tắt -->
                    <form method="post" action="${ctx}/admin/newsletter" style="display:inline">
                      <input type="hidden" name="action" value="update" />
                      <input type="hidden" name="email" value="${n.email}" />
                      <input type="hidden" name="enabled" value="${!n.enabled}" />
                      <button type="submit" class="btn ghost">
                        <c:out value="${n.enabled ? 'Tắt' : 'Bật'}" />
                      </button>
                    </form>

                    <!-- Hủy đăng ký (delete) -->
                    <form method="post" action="${ctx}/admin/newsletter" style="display:inline"
                      onsubmit="return confirm('Hủy nhận tin email này?');">
                      <input type="hidden" name="action" value="delete" />
                      <input type="hidden" name="email" value="${n.email}" />
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