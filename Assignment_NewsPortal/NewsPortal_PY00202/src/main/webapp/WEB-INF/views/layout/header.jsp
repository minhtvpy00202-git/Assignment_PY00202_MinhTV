<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<fmt:setLocale value="${sessionScope.lang != null ? sessionScope.lang : 'vi'}" scope="session"/>
<fmt:setBundle basename="i18n.global" scope="session"/>


<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><c:out value="${pageTitle != null ? pageTitle : 'NewsPortal'}" /></title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,100..1000;1,9..40,100..1000&family=Lora:wght@400;500;600;700&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="${ctx}/assets/css/main.css">

  <style>
    /* Bố cục menu + nút VI/EN trong cùng thanh */
    .desktop-nav .container.desktop-nav-inner { display:flex; align-items:center; gap:16px; }
    .desktop-nav .nav-links { display:flex; align-items:center; gap:22px; flex-wrap:nowrap; }
    .desktop-nav .nav-actions { margin-left:auto; display:flex; align-items:center; gap:12px; }
    .lang-switch { display:flex; align-items:center; gap:8px; }
    .lang-switch .sep { opacity:.5; }
    .lang-switch a,
    .lang-switch button {
      display:inline-block; text-decoration:none; background:transparent;
      border:1px solid #d9d9d9; padding:4px 8px; border-radius:8px; cursor:pointer;
      font-weight:500; line-height:1;
    }
    .lang-switch .active { border-color:#000; font-weight:700; }
    /* Co gọn input tìm kiếm cho vừa hàng */
    .desktop-nav .search-form { display:flex; align-items:center; gap:8px; }
    .desktop-nav .search-form .form-control { width:260px; }
    @media (max-width: 992px){
      .desktop-nav .search-form .form-control { width:200px; }
    }
  </style>
</head>

<body>
  <!-- Header -->
  <header class="main-header">
    <!-- Logo Section (Desktop) -->
    <div class="logo-section">
      <div class="container">
        <h1 class="main-logo">
          <a href="${ctx}/home">NewsPortal</a>
          <h5><fmt:message key="tagline"/></h5>
        </h1>
      </div>
    </div>

    <div class="container">
      <div class="header-content">
        <!-- Mobile Menu Button -->
        <button class="mobile-menu-btn" onclick="toggleMobileMenu()" aria-label="Menu">
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
        </button>

        <!-- Mobile Logo -->
        <div class="mobile-logo-section">
          <h1 class="mobile-logo">
            <a href="${ctx}/home"><fmt:message key="brand"/></a>
          </h1>
        </div>

        <!-- User Account Button (Mobile) -->
        <c:choose>
          <c:when test="${not empty sessionScope.user}">
            <c:choose>
              <c:when test="${sessionScope.user.role}">
                <a class="mobile-account-btn" href="${ctx}/admin/dashboard" aria-label="Admin Dashboard">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </a>
              </c:when>
              <c:otherwise>
                <a class="mobile-account-btn" href="${ctx}/reporter/dashboard" aria-label="Reporter Dashboard">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </a>
              </c:otherwise>
            </c:choose>
          </c:when>

          <c:when test="${not empty sessionScope.authUser}">
            <c:choose>
              <c:when test="${sessionScope.authUser.role}">
                <a class="mobile-account-btn" href="${ctx}/admin/dashboard" aria-label="Admin Dashboard">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </a>
              </c:when>
              <c:otherwise>
                <a class="mobile-account-btn" href="${ctx}/reporter/dashboard" aria-label="Reporter Dashboard">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </a>
              </c:otherwise>
            </c:choose>
          </c:when>

          <c:otherwise>
            <a class="mobile-account-btn" href="${ctx}/auth/login" aria-label="Login">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
            </a>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- Desktop Navigation -->
    <nav class="desktop-nav">
      <div class="container desktop-nav-inner">

        <!-- Trái: các link menu -->
        <div class="nav-links">
          <a class="nav-link" data-page="/home" href="${ctx}/home"><fmt:message key="nav.home"/></a>

          <div class="nav-item dropdown">
            <a class="nav-link" data-page="/category" href="#"><fmt:message key="nav.categories"/></a>
            <div class="dropdown-menu">
              <c:forEach var="cata" items="${categories}">
                <a class="dropdown-item" href="${ctx}/category?id=${cata.id}">${cata.name}</a>
              </c:forEach>
            </div>
          </div>

          <a class="nav-link" data-page="/search" href="${ctx}/search"><fmt:message key="nav.search"/></a>

          <c:choose>
            <c:when test="${not empty sessionScope.user}">
              <c:choose>
                <c:when test="${sessionScope.user.role}">
                  <a class="nav-link" href="${ctx}/admin/dashboard"><fmt:message key="nav.dashboard"/></a>
                </c:when>
                <c:otherwise>
                  <a class="nav-link" href="${ctx}/reporter/dashboard"><fmt:message key="nav.dashboard"/></a>
                </c:otherwise>
              </c:choose>
              <a class="nav-link" href="${ctx}/auth/logout"><fmt:message key="auth.logout"/></a>
            </c:when>

            <c:when test="${not empty sessionScope.authUser}">
              <c:choose>
                <c:when test="${sessionScope.authUser.role}">
                  <a class="nav-link" style="color:red;" href="${ctx}/admin/dashboard"><fmt:message key="nav.dashboard"/></a>
                </c:when>
                <c:otherwise>
                  <a class="nav-link" style="color:red;" href="${ctx}/reporter/dashboard"><fmt:message key="nav.dashboard"/></a>
                </c:otherwise>
              </c:choose>
              <a class="nav-link" style="color:red;" href="${ctx}/auth/logout"><fmt:message key="auth.logout"/></a>
            </c:when>

            <c:otherwise>
              <a class="nav-link" style="color:red;" href="${ctx}/auth/login"><fmt:message key="auth.login"/></a>
              <a class="nav-link" style="color:red;" href="${ctx}/auth/register"><fmt:message key="auth.register"/></a>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Phải: VI/EN + ô tìm kiếm -->
        <div class="nav-actions">
          <div class="lang-switch">
            <button type="button"
                    onclick="setLang('vi')"
                    class="${sessionScope.lang == 'vi' || sessionScope.lang == null ? 'active' : ''}">VI</button>
            <span class="sep">|</span>
            <button type="button"
                    onclick="setLang('en')"
                    class="${sessionScope.lang == 'en' ? 'active' : ''}">EN</button>
          </div>

          <form class="search-form" action="${ctx}/search" method="get">
            <input class="form-control" name="q" type="search"
                   value="<c:out value='${q}'/>"
                   placeholder="<fmt:message key='nav.search.placeholder'/>">
            <button class="btn btn-primary" type="submit"><fmt:message key="nav.search.button"/></button>
          </form>
        </div>
      </div>
    </nav>
  </header>

  <!-- Mobile Menu Overlay -->
  <div class="mobile-menu-overlay" onclick="closeMobileMenu()"></div>

  <!-- Mobile Menu -->
  <nav class="mobile-menu">
    <div class="mobile-menu-header">
      <h2><fmt:message key="mobile.menu"/></h2>
      <button class="close-btn" onclick="closeMobileMenu()" aria-label="Close">×</button>
    </div>

    <div class="mobile-menu-content">
      <div class="mobile-nav-section">
        <a class="mobile-nav-link" href="${ctx}/home"><fmt:message key="nav.home"/></a>
        <a class="mobile-nav-link" href="${ctx}/search"><fmt:message key="nav.search"/></a>

        <div class="mobile-nav-group">
          <h3><fmt:message key="nav.categories"/></h3>
          <c:forEach var="cata" items="${categories}">
            <a class="mobile-nav-sublink" href="${ctx}/category?id=${cata.id}">${cata.name}</a>
          </c:forEach>
        </div>
      </div>

      <div class="mobile-nav-section">
        <c:choose>
          <c:when test="${not empty sessionScope.user}">
            <c:choose>
              <c:when test="${sessionScope.user.role}">
                <a class="mobile-nav-link" href="${ctx}/admin/dashboard">Dashboard</a>
              </c:when>
              <c:otherwise>
                <a class="mobile-nav-link" href="${ctx}/reporter/dashboard">Dashboard</a>
              </c:otherwise>
            </c:choose>
            <a class="mobile-nav-link logout" href="${ctx}/auth/logout"><fmt:message key="auth.logout"/></a>
          </c:when>

          <c:when test="${not empty sessionScope.authUser}">
            <c:choose>
              <c:when test="${sessionScope.authUser.role}">
                <a class="mobile-nav-link" href="${ctx}/admin/dashboard">Dashboard</a>
              </c:when>
              <c:otherwise>
                <a class="mobile-nav-link" href="${ctx}/reporter/dashboard">Dashboard</a>
              </c:otherwise>
            </c:choose>
            <a class="mobile-nav-link logout" href="${ctx}/auth/logout"><fmt:message key="auth.logout"/></a>
          </c:when>

          <c:otherwise>
            <a class="mobile-nav-link" href="${ctx}/auth/login"><fmt:message key="auth.login"/></a>
            <a class="mobile-nav-link" href="${ctx}/auth/register"><fmt:message key="auth.register"/></a>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- Nút chuyển ngôn ngữ trong mobile -->
      <div style="margin-top:12px; display:flex; gap:8px;">
        <button type="button" onclick="setLang('vi')"
                class="chip ${sessionScope.lang == 'vi' || sessionScope.lang == null ? 'active':''}">VI</button>
        <button type="button" onclick="setLang('en')"
                class="chip ${sessionScope.lang == 'en' ? 'active':''}">EN</button>
      </div>

      <div class="mobile-search-section">
        <form action="${ctx}/search" method="get">
          <div class="mobile-search-group">
            <input class="mobile-search-input" name="q" type="search"
                   value="<c:out value='${q}'/>"
                   placeholder="<fmt:message key='nav.search.placeholder'/>">
            <button class="mobile-search-btn" type="submit"><fmt:message key="nav.search.button"/></button>
          </div>
        </form>
      </div>
    </div>
  </nav>

  <!-- Scripts -->
  <script>
    // Mobile Menu Functions
    function toggleMobileMenu() {
      const mobileMenu = document.querySelector('.mobile-menu');
      const overlay = document.querySelector('.mobile-menu-overlay');
      const body = document.body;
      const menuBtn = document.querySelector('.mobile-menu-btn');
      mobileMenu.classList.add('active');
      overlay.classList.add('active');
      body.classList.add('menu-open');
      menuBtn.classList.add('active');
    }
    function closeMobileMenu() {
      const mobileMenu = document.querySelector('.mobile-menu');
      const overlay = document.querySelector('.mobile-menu-overlay');
      const body = document.body;
      const menuBtn = document.querySelector('.mobile-menu-btn');
      mobileMenu.classList.remove('active');
      overlay.classList.remove('active');
      body.classList.remove('menu-open');
      menuBtn.classList.remove('active');
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
      if (!event.target.closest('.dropdown')) {
        document.querySelectorAll('.dropdown-menu').forEach(menu => menu.classList.remove('show'));
      }
    });

    // Close mobile menu when clicking nav links
    document.querySelectorAll('.mobile-nav-link, .mobile-nav-sublink').forEach(link => {
      link.addEventListener('click', closeMobileMenu);
    });

    // Handle window resize
    window.addEventListener('resize', function() {
      if (window.innerWidth > 768) closeMobileMenu();
    });

    // Active nav
    document.addEventListener('DOMContentLoaded', function () {
      const ctx = '${ctx}';
      const normalize = p => {
        p = p.replace(ctx, '');
        if (!p) return '/home';
        if (p.length > 1 && p.endsWith('/')) p = p.slice(0, -1);
        return p;
      };
      const path = normalize(window.location.pathname);
      const items = Array.from(document.querySelectorAll('.desktop-nav .nav-link[data-page]'));
      items.forEach(a => a.classList.remove('active'));
      let best = null, bestLen = -1;
      items.forEach(a => {
        const dp = a.getAttribute('data-page');
        if (path === dp || path.startsWith(dp)) {
          if (dp.length > bestLen) { best = a; bestLen = dp.length; }
        }
      });
      if (!best) best = document.querySelector('.desktop-nav .nav-link[data-page="/home"]');
      if (best) best.classList.add('active');
    });

    // Đổi ngôn ngữ: thêm/đổi ?lang=vi|en giữ nguyên URL hiện tại
    function setLang(lang) {
      const url = new URL(window.location.href);
      url.searchParams.set('lang', lang);
      window.location.href = url.toString();
    }
  </script>
</body>
</html>
