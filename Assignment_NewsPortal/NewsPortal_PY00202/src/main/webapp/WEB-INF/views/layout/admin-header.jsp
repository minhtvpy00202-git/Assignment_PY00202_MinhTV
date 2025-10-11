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
        <title>
          <c:out value="${pageTitle != null ? pageTitle : '🗞️ NewsPortal Admin'}" />
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-modern.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-table-fix.css">
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
              </a>

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
                <a href="${ctx}/admin/news-approve" class="nav-item" data-page="/admin/news-approve">
                  <span class="nav-icon">✅</span>
                  <span class="nav-text">Duyệt bài</span>
                </a>

                <a href="${ctx}/admin/categories" class="nav-item" data-page="/admin/categories">
                  <span class="nav-icon">📂</span>
                  <span class="nav-text">Chuyên mục</span>
                </a>

                <a href="${ctx}/admin/users" class="nav-item" data-page="/admin/users">
                  <span class="nav-icon">👥</span>
                  <span class="nav-text">Users</span>
                </a>

                <a href="${ctx}/admin/users-pending" class="nav-item" data-page="/admin/users-pending">
                  <span class="nav-icon">⏳</span>
                  <span class="nav-text">Duyệt TK</span>
                  <c:if test="${not empty requestScope.pendingUsers and requestScope.pendingUsers > 0}">
                    <span class="nav-badge">${pendingUsers}</span>
                  </c:if>
                </a>

                <a href="${ctx}/admin/newsletter" class="nav-item" data-page="/admin/newsletter">
                  <span class="nav-icon">📧</span>
                  <span class="nav-text">Newsletter</span>
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

        <style>
          /* Modern Admin Header Styles */
          .modern-admin-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
          }

          .header-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            min-height: 70px;
            gap: 1rem;
          }

          /* Brand Section */
          .brand-section .brand-link {
            display: flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
            color: white;
          }

          .brand-icon {
            font-size: 1.75rem;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.4rem;
            border-radius: 10px;
          }

          .brand-text {
            display: flex;
            flex-direction: column;
          }

          .brand-name {
            font-size: 1.3rem;
            font-weight: 700;
            line-height: 1;
          }

          .brand-subtitle {
            font-size: 0.8rem;
            opacity: 0.8;
            font-weight: 400;
          }

          /* Navigation */
          .main-navigation {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            flex: 1;
            justify-content: center;
            max-width: 900px;
            overflow-x: auto;
            scrollbar-width: none; /* Firefox */
            -ms-overflow-style: none; /* IE/Edge */
          }
          
          .main-navigation::-webkit-scrollbar {
            display: none; /* Chrome/Safari */
          }

          .nav-item {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.6rem 0.75rem;
            border-radius: 8px;
            text-decoration: none;
            color: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
            position: relative;
            white-space: nowrap;
            flex-shrink: 0; /* Prevent shrinking */
          }

          .nav-item:hover {
            background: rgba(255, 255, 255, 0.15);
            color: white;
            transform: translateY(-1px);
          }

          .nav-item.active {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
          }

          .nav-icon {
            font-size: 1rem;
            flex-shrink: 0;
          }

          .nav-text {
            font-weight: 500;
            font-size: 0.85rem;
          }

          .nav-badge {
            background: #ff4757;
            color: white;
            font-size: 0.75rem;
            padding: 0.2rem 0.5rem;
            border-radius: 10px;
            font-weight: 600;
            min-width: 20px;
            text-align: center;
          }

          /* User Section */
          .user-section {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-shrink: 0;
          }

          .user-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: white;
          }

          .user-avatar {
            width: 35px;
            height: 35px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 1rem;
            text-transform: uppercase;
          }

          .user-details {
            display: flex;
            flex-direction: column;
          }

          .user-name {
            font-weight: 600;
            font-size: 0.9rem;
            line-height: 1;
          }

          .user-role {
            font-size: 0.75rem;
            opacity: 0.8;
            margin-top: 0.2rem;
          }

          .user-role.admin {
            color: #ffd700;
          }

          .user-role.reporter {
            color: #87ceeb;
          }

          .logout-btn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
          }

          .logout-btn:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-1px);
          }

          .logout-text {
            font-size: 0.9rem;
            font-weight: 500;
          }

          /* Responsive */
          @media (max-width: 1200px) {
            .brand-name {
              font-size: 1.1rem;
            }
            
            .brand-subtitle {
              font-size: 0.75rem;
            }
            
            .nav-text {
              font-size: 0.8rem;
            }
            
            .user-details {
              display: none;
            }
          }
          
          @media (max-width: 1024px) {
            .header-container {
              padding: 0 0.75rem;
              gap: 0.75rem;
            }
            
            .brand-text {
              display: none; /* Hide brand text on tablets */
            }
            
            .nav-item {
              padding: 0.5rem 0.6rem;
              gap: 0.3rem;
            }
            
            .nav-text {
              font-size: 0.75rem;
            }
          }

          @media (max-width: 768px) {
            .header-container {
              padding: 0 0.5rem;
              flex-wrap: wrap;
              min-height: auto;
              gap: 0.5rem;
            }

            .main-navigation {
              order: 3;
              width: 100%;
              justify-content: flex-start;
              gap: 0.25rem;
              padding: 0.75rem 0;
              border-top: 1px solid rgba(255, 255, 255, 0.1);
              overflow-x: auto;
            }

            .nav-item {
              padding: 0.5rem;
              min-width: auto;
            }

            .nav-text {
              display: none; /* Show only icons on mobile */
            }
            
            .nav-icon {
              font-size: 1.1rem;
            }

            .user-details {
              display: none;
            }
            
            .logout-text {
              display: none;
            }
            
            .brand-icon {
              font-size: 1.5rem;
              padding: 0.3rem;
            }
          }
        </style>

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