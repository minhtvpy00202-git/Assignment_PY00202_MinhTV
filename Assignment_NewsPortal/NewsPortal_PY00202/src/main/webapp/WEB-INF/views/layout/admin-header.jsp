<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="uri" value="${pageContext.request.requestURI}" />
<c:set var="currentPage" value="${fn:substringAfter(uri, ctx)}" />

<fmt:setLocale value="${sessionScope.lang != null ? sessionScope.lang : 'vi'}" scope="session"/>
<fmt:setBundle basename="i18n.global" scope="session"/>

<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
  <title><c:out value="${pageTitle != null ? pageTitle : '🗞️ NewsPortal Admin'}" /></title>
  <link rel="stylesheet" href="${ctx}/assets/css/main.css">
</head>
<body class="admin-layout">

<header class="modern-admin-header">
  <div class="header-container">
    <!-- Brand -->
    <div class="brand-section">
      <c:choose>
        <c:when test="${not empty sessionScope.authUser and sessionScope.authUser.role}">
          <a href="${ctx}/admin/dashboard" class="brand-link">
            <div class="brand-icon">📰</div>
            <div class="brand-text">
              <span class="brand-name"><fmt:message key="brand"/></span>
              <span class="brand-subtitle"><fmt:message key="admin.panel"/></span>
            </div>
          </a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/reporter/dashboard" class="brand-link">
            <div class="brand-icon">✏️</div>
            <div class="brand-text">
              <span class="brand-name"><fmt:message key="brand"/></span>
              <span class="brand-subtitle"><fmt:message key="reporter.panel"/></span>
            </div>
          </a>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Language Switch -->
    <div class="lang-switch" style="margin-left:auto; margin-right:12px;">
      <button type="button" onclick="setLang('vi')" class="${sessionScope.lang == 'vi' || sessionScope.lang == null ? 'active' : ''}">VI</button>
      <span> | </span>
      <button type="button" onclick="setLang('en')" class="${sessionScope.lang == 'en' ? 'active' : ''}">EN</button>
    </div>

    <!-- Navigation -->
    <nav class="main-navigation">
      <a href="${ctx}/home" class="nav-item" data-page="/home">
        <span class="nav-icon">🏠</span>
        <span class="nav-text"><fmt:message key="admin.home"/></span>
      </a>

      <c:choose>
        <c:when test="${sessionScope.authUser != null && sessionScope.authUser.role}">
          <a href="${ctx}/admin/news" class="nav-item" data-page="/admin/news">
            <span class="nav-icon">📄</span>
            <span class="nav-text"><fmt:message key="admin.news"/></span>
          </a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/reporter/posts" class="nav-item" data-page="/reporter/posts">
            <span class="nav-icon">📝</span>
            <span class="nav-text"><fmt:message key="admin.posts"/></span>
          </a>
        </c:otherwise>
      </c:choose>

      <c:if test="${sessionScope.authUser != null && sessionScope.authUser.role}">
        <a href="${ctx}/admin/categories" class="nav-item" data-page="/admin/categories">
          <span class="nav-icon">📂</span>
          <span class="nav-text"><fmt:message key="admin.categories"/></span>
        </a>

        <a href="${ctx}/admin/users" class="nav-item" data-page="/admin/users">
          <span class="nav-icon">👥</span>
          <span class="nav-text"><fmt:message key="admin.users"/></span>
        </a>

        <a href="${ctx}/admin/newsletter" class="nav-item" data-page="/admin/newsletter">
          <span class="nav-icon">📧</span>
          <span class="nav-text"><fmt:message key="admin.newsletter"/></span>
        </a>

        <a href="${ctx}/admin/news-approve" class="nav-item" data-page="/admin/news-approve">
          <span class="nav-icon">✅</span>
          <span class="nav-text"><fmt:message key="admin.approve"/></span>
        </a>

        <a href="${ctx}/admin/users-pending" class="nav-item" data-page="/admin/users-pending">
          <span class="nav-icon">⏳</span>
          <span class="nav-text"><fmt:message key="admin.pendingUsers"/></span>
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
            ${fn:substring(sessionScope.authUser.fullname != null ? sessionScope.authUser.fullname : sessionScope.authUser.username, 0, 1)}
          </div>
          <div class="user-details">
            <span class="user-name">
              ${sessionScope.authUser.fullname != null ? sessionScope.authUser.fullname : sessionScope.authUser.username}
            </span>
            <span class="user-role ${sessionScope.authUser.role ? 'admin' : 'reporter'}">
			  <c:choose>
			    <c:when test="${sessionScope.authUser.role}">
			      <fmt:message key="role.admin"/>
			    </c:when>
			    <c:otherwise>
			      <fmt:message key="role.reporter"/>
			    </c:otherwise>
			  </c:choose>
			</span>
          </div>
        </div>
      </c:if>

      <a href="${ctx}/auth/logout" class="logout-btn">
        <span class="logout-icon">🚪</span>
        <span class="logout-text"><fmt:message key="logout"/></span>
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
        <script>
		  function setLang(lang) {
		    const url = new URL(window.location.href);
		    url.searchParams.set('lang', lang);
		    window.location.href = url.toString();
		  }
		</script>
        
        </body>