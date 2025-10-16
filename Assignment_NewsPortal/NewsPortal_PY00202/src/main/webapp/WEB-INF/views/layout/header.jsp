<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
<link href="https://fonts.googleapis.com/css2?family=Playwrite+DE+Grund+Guides&display=swap" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,100..1000;1,9..40,100..1000&display=swap" rel="stylesheet">
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><c:out value="${pageTitle != null ? pageTitle : 'NewsPortal'}" /></title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body>
	<!-- Header -->
	<header class="main-header">
		<!-- Logo Section (Desktop) -->
		<div class="logo-section">
			<div class="container">
				<h1 class="main-logo">
					<a href="${pageContext.request.contextPath}/home">NewsPortal</a>
					<h5>Cổng tin tức hiện đại - chuyên nghiệp</h5>
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
						<a href="${pageContext.request.contextPath}/home">NewsPortal</a>
					</h1>
				</div>
				
				<!-- User Account Button (Mobile) -->
				<c:choose>
					<c:when test="${not empty sessionScope.user}">
						<c:choose>
							<c:when test="${sessionScope.user.role}">
								<a class="mobile-account-btn" href="${pageContext.request.contextPath}/admin/dashboard" aria-label="Admin Dashboard">
									<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
										<path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
									</svg>
								</a>
							</c:when>
							<c:otherwise>
								<a class="mobile-account-btn" href="${pageContext.request.contextPath}/reporter/dashboard" aria-label="Reporter Dashboard">
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
								<a class="mobile-account-btn" href="${pageContext.request.contextPath}/admin/dashboard" aria-label="Admin Dashboard">
									<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
										<path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
									</svg>
								</a>
							</c:when>
							<c:otherwise>
								<a class="mobile-account-btn" href="${pageContext.request.contextPath}/reporter/dashboard" aria-label="Reporter Dashboard">
									<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
										<path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
									</svg>
								</a>
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<a class="mobile-account-btn" href="${pageContext.request.contextPath}/auth/login" aria-label="Login">
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
			<div class="container">
				<div class="nav-links">
					<a class="nav-link" data-page="/home" href="${ctx}/home">Trang chủ</a>
					
					<div class="nav-item dropdown">
						<a class="nav-link" data-page="/category" href="#">Chuyên mục</a>
						<div class="dropdown-menu">
							<c:forEach var="cata" items="${categories}">
								<a class="dropdown-item" href="${ctx}/category?id=${cata.id}">${cata.name}</a>
							</c:forEach>
						</div>
					</div>
					
					<a class="nav-link" data-page="/search"   href="${ctx}/search">Tìm kiếm</a>
					
					<c:choose>
						<c:when test="${not empty sessionScope.user}">
							<c:choose>
								<c:when test="${sessionScope.user.role}">
									<a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
								</c:when>
								<c:otherwise>
									<a class="nav-link" href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
								</c:otherwise>
							</c:choose>
							<a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
						</c:when>
						<c:when test="${not empty sessionScope.authUser}">
							<c:choose>
								<c:when test="${sessionScope.authUser.role}">
									<a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
								</c:when>
								<c:otherwise>
									<a class="nav-link" href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
								</c:otherwise>
							</c:choose>
							<a class="nav-link" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
						</c:when>
						<c:otherwise>
							<a class="nav-link" href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
							<a class="nav-link" href="${pageContext.request.contextPath}/auth/register">Đăng ký</a>
						</c:otherwise>
					</c:choose>
				</div>
				
				<form class="search-form" action="${pageContext.request.contextPath}/search" method="get">
					<input class="form-control" name="q" type="search" value="<c:out value='${q}'/>" placeholder="Tìm kiếm...">
					<button class="btn btn-primary" type="submit">Tìm</button>
				</form>
			</div>
		</nav>
	</header>
	
	<!-- Mobile Menu Overlay -->
	<div class="mobile-menu-overlay" onclick="closeMobileMenu()"></div>
	
	<!-- Mobile Menu -->
	<nav class="mobile-menu">
		<div class="mobile-menu-header">
			<h2>Menu</h2>
			<button class="close-btn" onclick="closeMobileMenu()" aria-label="Close">×</button>
		</div>
		
		<div class="mobile-menu-content">
			<div class="mobile-nav-section">
				<a class="mobile-nav-link" href="${pageContext.request.contextPath}/home">Trang chủ</a>
				<a class="mobile-nav-link" href="${pageContext.request.contextPath}/search">Tìm kiếm</a>
				
				<div class="mobile-nav-group">
					<h3>Chuyên mục</h3>
					<c:forEach var="cata" items="${categories}">
						<a class="mobile-nav-sublink" href="${pageContext.request.contextPath}/category?id=${cata.id}">
							${cata.name}
						</a>
					</c:forEach>
				</div>
			</div>
			
			<div class="mobile-nav-section">
				<c:choose>
					<c:when test="${not empty sessionScope.user}">
						<c:choose>
							<c:when test="${sessionScope.user.role}">
								<a class="mobile-nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
							</c:when>
							<c:otherwise>
								<a class="mobile-nav-link" href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
							</c:otherwise>
						</c:choose>
						<a class="mobile-nav-link logout" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
					</c:when>
					<c:when test="${not empty sessionScope.authUser}">
						<c:choose>
							<c:when test="${sessionScope.authUser.role}">
								<a class="mobile-nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
							</c:when>
							<c:otherwise>
								<a class="mobile-nav-link" href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
							</c:otherwise>
						</c:choose>
						<a class="mobile-nav-link logout" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
					</c:when>
					<c:otherwise>
						<a class="mobile-nav-link" href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
						<a class="mobile-nav-link" href="${pageContext.request.contextPath}/auth/register">Đăng ký</a>
					</c:otherwise>
				</c:choose>
			</div>
			
			<div class="mobile-search-section">
				<form action="${pageContext.request.contextPath}/search" method="get">
					<div class="mobile-search-group">
						<input class="mobile-search-input" name="q" type="search" value="<c:out value='${q}'/>" placeholder="Tìm kiếm bài viết...">
						<button class="mobile-search-btn" type="submit">Tìm</button>
					</div>
				</form>
			</div>
		</div>
	</nav>
	

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

// Desktop Dropdown Functions
function toggleDropdown(event) {
    event.preventDefault();
    const dropdown = event.target.parentNode.querySelector('.dropdown-menu');
    const isVisible = dropdown.classList.contains('show');
    
    // Close all dropdowns
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show');
    });
    
    // Toggle current dropdown
    if (!isVisible) {
        dropdown.classList.add('show');
    }
}

// Close dropdown when clicking outside
document.addEventListener('click', function(event) {
    if (!event.target.closest('.dropdown')) {
        document.querySelectorAll('.dropdown-menu').forEach(menu => {
            menu.classList.remove('show');
        });
    }
});

// Close mobile menu when clicking nav links
document.querySelectorAll('.mobile-nav-link, .mobile-nav-sublink').forEach(link => {
    link.addEventListener('click', closeMobileMenu);
});

// Handle window resize
window.addEventListener('resize', function() {
    if (window.innerWidth > 768) {
        closeMobileMenu();
    }
});


</script>
<script>
document.addEventListener('DOMContentLoaded', function () {
  const ctx = '${ctx}';

  // Chuẩn hoá path: bỏ contextPath, bỏ query, bỏ dấu / cuối
  const normalize = p => {
    p = p.replace(ctx, '');
    if (!p) return '/home';
    if (p.length > 1 && p.endsWith('/')) p = p.slice(0, -1);
    return p;
  };

  const path = normalize(window.location.pathname);

  // Bỏ active cũ
  const items = Array.from(document.querySelectorAll('.desktop-nav .nav-link[data-page]'));
  items.forEach(a => a.classList.remove('active'));

  // Chọn item có data-page là prefix dài nhất của path
  let best = null;
  let bestLen = -1;
  items.forEach(a => {
    const dp = a.getAttribute('data-page');
    if (path === dp || path.startsWith(dp)) {
      if (dp.length > bestLen) {
        best = a;
        bestLen = dp.length;
      }
    }
  });

  // Fallback: vẫn không thấy thì gắn Trang chủ
  if (!best) {
    best = document.querySelector('.desktop-nav .nav-link[data-page="/home"]');
  }

  if (best) best.classList.add('active');
});
</script>

</body>

	