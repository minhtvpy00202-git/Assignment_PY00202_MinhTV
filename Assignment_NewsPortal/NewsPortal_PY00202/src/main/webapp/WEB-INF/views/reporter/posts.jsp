<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý Bài viết - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">

    <!-- Header: dùng .page-header -->
    <div class="page-header">
      <h1>Quản lý Bài viết</h1>
      <p>Xem và quản lý tất cả bài viết của bạn</p>
      <a href="${pageContext.request.contextPath}/reporter/post-create" class="btn btn-primary">
        Viết bài mới
      </a>
    </div>

    <!-- Stats: dùng .admin-dashboard + .dashboard-card -->
    <div class="admin-dashboard">
      <div class="dashboard-card">
        <h3>${totalPosts != null ? totalPosts : 0}</h3>
        <p>Tổng bài viết</p>
      </div>
      <div class="dashboard-card">
        <h3>${pendingPosts != null ? pendingPosts : 0}</h3>
        <p>Chờ duyệt</p>
      </div>
      <div class="dashboard-card">
        <h3>${approvedPosts != null ? approvedPosts : 0}</h3>
        <p>Đã duyệt</p>
      </div>
    </div>

    <!-- Danh sách: dùng .table-section + .table -->
    <div class="table-section">
      <h2>Danh sách bài viết</h2>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>

      <c:choose>
        <c:when test="${empty posts}">
          <p>Chưa có bài viết nào. <a href="${pageContext.request.contextPath}/reporter/post-create">Viết bài mới →</a></p>
        </c:when>
        <c:otherwise>
          <div class="table-wrapper">
            <table class="table">
              <thead>
                <tr>
                  <th>STT</th>
                  <th>Tiêu đề</th>
                  <th>Chuyên mục</th>
                  <th>Ngày đăng</th>
                  <th>Lượt xem</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="post" items="${posts}" varStatus="st">
                  <tr>
                    <td class="text-center">${st.index + 1}</td>
                    <td>
                      <strong>${post.title}</strong>
                      <c:if test="${post.home}">
                        <span class="badge">Trang nhất</span>
                      </c:if>
                    </td>
                    <td>
                      ${categoryMap[post.categoryId] != null ? categoryMap[post.categoryId] : 'Chưa phân loại'}
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
                        ${post.approved ? 'Đã duyệt' : 'Chờ duyệt'}
                      </span>
                    </td>
                    <td class="actions">
                      <a class="btn btn-outline-primary" title="Xem"
                         href="${pageContext.request.contextPath}/news/detail?id=${post.id}">Xem</a>
                      <a class="btn btn-outline-primary" title="Sửa"
                         href="${pageContext.request.contextPath}/reporter/post-edit?id=${post.id}">Sửa</a>
                      <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete"
                            onsubmit="return confirm('Xóa bài viết này?');">
                        <input type="hidden" name="id" value="${post.id}">
                        <button type="submit" class="btn btn-danger">Xóa</button>
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
