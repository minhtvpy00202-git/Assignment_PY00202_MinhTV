<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <c:set var="ctx" value="${pageContext.request.contextPath}" />
      <c:set var="uri" value="${pageContext.request.requestURI}" />
      <c:set var="currentPage" value="${fn:substringAfter(uri, ctx)}" />

      <!DOCTYPE html>
      <html lang="vi">

      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=Honk&display=swap" rel="stylesheet">
        <title>
          <c:out value="${pageTitle != null ? pageTitle : '🗞️ NewsPortal Admin'}" />
        </title>
        <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
      </head>

      <body class="admin-layout">

        <!-- Modern Admin Header -->
        <header class="modern-admin-header">
          <div class="header-container">
            <!-- Brand Section -->
            <div class="brand-section">
              <c:choose>
                <c:when test="${not empty sessionScope.authUser and sessionScope.authUser.role}">
                  <a href="${ctx}/admin/dashboard" class="brand-link">
                    <div class="brand-icon">📰</div>
                    <div class="brand-text">
                      <span class="brand-name">NewsPortal</span>
                      <span class="brand-subtitle">Admin Panel</span>
                    </div>
                  </a>
                </c:when>
                <c:otherwise>
                  <a href="${ctx}/reporter/dashboard" class="brand-link">
                    <div class="brand-icon">✏️</div>
                    <div class="brand-text">
                      <span class="brand-name">NewsPortal</span>
                      <span class="brand-subtitle">Reporter Panel</span>
                    </div>
                  </a>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- Navigation -->
            <nav class="main-navigation">
              <a href="${ctx}/home" class="nav-item" data-page="/home">
                <span class="nav-icon">🏠</span>
                <span class="nav-text">Trang chủ</span>
              </a	>

              <!-- Smart News Navigation -->
              <c:choose>
                <c:when test="${sessionScope.authUser != null && sessionScope.authUser.role}">
                  <a href="${ctx}/admin/news" class="nav-item" data-page="/admin/news">
                    <span class="nav-icon">📄</span>
                    <span class="nav-text">Tin tức</span>
                  </a>
                </c:when>
                <c:otherwise>
                  <a href="${ctx}/reporter/posts" class="nav-item" data-page="/reporter/posts">
                    <span class="nav-icon">📝</span>
                    <span class="nav-text">Bài viết</span>
                  </a>
                </c:otherwise>
              </c:choose>

              <!-- Admin Only Navigation -->
              <c:if test="${sessionScope.authUser != null && sessionScope.authUser.role}">
                

                <a href="${ctx}/admin/categories" class="nav-item" data-page="/admin/categories">
                  <span class="nav-icon">📂</span>
                  <span class="nav-text">Chuyên mục</span>
                </a>

                <a href="${ctx}/admin/users" class="nav-item" data-page="/admin/users">
                  <span class="nav-icon">👥</span>
                  <span class="nav-text">Users</span>
                </a>
                
                

                <a href="${ctx}/admin/newsletter" class="nav-item" data-page="/admin/newsletter">
                  <span class="nav-icon">📧</span>
                  <span class="nav-text">Newsletter</span>
                </a>
                
                <a href="${ctx}/admin/news-approve" class="nav-item" data-page="/admin/news-approve">
                  <span class="nav-icon">✅</span>
                  <span class="nav-text">Duyệt bài</span>
                </a>

                <a href="${ctx}/admin/users-pending" class="nav-item" data-page="/admin/users-pending">
                  <span class="nav-icon">⏳</span>
                  <span class="nav-text">Duyệt TK</span>
                  <c:if test="${not empty requestScope.pendingUsers and requestScope.pendingUsers > 0}">
                    <span class="nav-badge">${pendingUsers}</span>
                  </c:if>
                </a>
              </c:if>
            </nav>

            <!-- User Section -->
            <div class="user-section">
              <c:if test="${not empty sessionScope.authUser}">
                <div class="user-info">
                  <div class="user-avatar">
                    ${fn:substring(sessionScope.authUser.fullname != null ? sessionScope.authUser.fullname :
                    sessionScope.authUser.username, 0, 1)}
                  </div>
                  <div class="user-details">
                    <span class="user-name">
                      ${sessionScope.authUser.fullname != null ? sessionScope.authUser.fullname :
                      sessionScope.authUser.username}
                    </span>
                    <span class="user-role ${sessionScope.authUser.role ? 'admin' : 'reporter'}">
                      ${sessionScope.authUser.role ? 'Quản trị viên' : 'Phóng viên'}
                    </span>
                  </div>
                </div>
              </c:if>

              <a href="${ctx}/auth/logout" class="logout-btn">
                <span class="logout-icon">🚪</span>
                <span class="logout-text">Đăng xuất</span>
              </a>
            </div>
          </div>
        </header>



        <script>
          document.addEventListener('DOMContentLoaded', function () {
            const currentPath = window.location.pathname;
            const contextPath = '${ctx}';
            const currentPage = currentPath.replace(contextPath, '');

            // Remove active class from all nav items
            const navItems = document.querySelectorAll('.nav-item[data-page]');
            navItems.forEach(item => {
              item.classList.remove('active');
              item.removeAttribute('aria-current');
            });

            // Add active class to matching item
            const activeItem = document.querySelector('.nav-item[data-page="' + currentPage + '"]');
            if (activeItem) {
              activeItem.classList.add('active');
              activeItem.setAttribute('aria-current', 'page');
            }
          });
        </script>