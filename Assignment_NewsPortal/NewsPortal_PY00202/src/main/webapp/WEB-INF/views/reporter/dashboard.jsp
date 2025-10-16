<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Dashboard Phóng viên - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">
    <!-- Page Header (dùng lại .page-header giống admin) -->
    <div class="page-header">
      <h1>DASHBOARD PHÓNG VIÊN</h1>
      <p>Tổng quan hoạt động và quản lý bài viết của bạn</p>
      <a href="${pageContext.request.contextPath}/reporter/post-create" class="btn btn-primary">
        Viết bài mới
      </a>
    </div>

    <!-- Statistics Cards (dùng lại .admin-dashboard + .dashboard-card) -->
    <div class="admin-dashboard">
      <div class="dashboard-card">
        <h3>${stats != null ? stats.total : 0}</h3>
        <p>Tổng bài viết</p>
      </div>

      <div class="dashboard-card">
        <h3>${stats != null ? stats.pending : 0}</h3>
        <p>Chờ duyệt</p>
      </div>

      <div class="dashboard-card">
        <h3>${stats != null ? stats.approved : 0}</h3>
        <p>Đã duyệt</p>
      </div>
    </div>

    <!-- Sections (dùng lại .dashboard-sections + .section) -->
    <div class="dashboard-sections">
      <!-- Hành động nhanh -->
      <div class="section">
        <div class="section-header">
          <h2>Hành động nhanh</h2>
          <a href="${pageContext.request.contextPath}/reporter/posts">Quản lý →</a>
        </div>

        <!-- Tận dụng .categories-list + .category-item để có grid sẵn -->
        <div class="categories-list">
          <div class="category-item">
            <a href="${pageContext.request.contextPath}/reporter/post-create">✏️ Viết bài mới</a>
          </div>
          <div class="category-item">
            <a href="${pageContext.request.contextPath}/reporter/posts">📝 Quản lý bài viết</a>
          </div>
        </div>
      </div>

      <!-- (Tuỳ chọn) Khu “Bài đang chờ duyệt của tôi” nếu bạn muốn show danh sách riêng -->
      <div class="section">
  <div class="section-header">
    <h2>Bài đang chờ duyệt của tôi</h2>
    <a href="${pageContext.request.contextPath}/reporter/posts?status=pending">Xem tất cả →</a>
  </div>

  <c:choose>
    <c:when test="${not empty myPending}">
      <div class="pending-articles">
        <c:forEach var="n" items="${myPending}">
          <div class="pending-article">
            <div class="article-info">
              <h4><c:out value="${n.title}" /></h4>
              <p class="article-meta">
                Chuyên mục: ${catMap[n.categoryId]}
                <c:if test="${n.home}"> | Trang chủ</c:if>
              </p>
            </div>
            <div class="article-actions">
              <a class="btn btn-outline-primary"
                 href="${pageContext.request.contextPath}/reporter/post-edit?id=${n.id}">Sửa</a>
              <form method="post" action="${pageContext.request.contextPath}/reporter/post-delete"
                    onsubmit="return confirm('Xoá bài này?');">
                <input type="hidden" name="id" value="${n.id}" />
                <button type="submit" class="btn btn-danger">Xoá</button>
              </form>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <p>Không có bài chờ duyệt</p>
    </c:otherwise>
  </c:choose>
</div>

    </div>
  </div>
</main>

<%@ include file="../layout/footer.jsp" %>
