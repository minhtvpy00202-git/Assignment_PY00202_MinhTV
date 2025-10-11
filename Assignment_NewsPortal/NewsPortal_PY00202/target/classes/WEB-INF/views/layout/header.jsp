<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title><c:out
		value="${pageTitle != null ? pageTitle : '🗞️ NewsPortal'}" /></title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/assets/css/style.css">

</head>
<body>
	<!-- Logo Section -->
	<div class="logo-section">
		<h1 class="main-logo">
			<a href="${pageContext.request.contextPath}/home">
				🗞️ NewsPortal
			</a>
		</h1>
	</div>

	<!-- Navigation Header -->
	<header class="main-header">
		<div class="nav-container">
			<nav class="main-nav">
				
				<a href="${pageContext.request.contextPath}/home">
				Trang Chủ
			</a>
				
				<c:forEach var="cata" items="${categories}">
					<a href="${pageContext.request.contextPath}/category?id=${cata.id}">
						${cata.name}
					</a>
				</c:forEach>
				<a href="${pageContext.request.contextPath}/search">Tìm kiếm</a>
				<c:choose>
					<c:when test="${not empty sessionScope.user}">
						<!-- Dashboard link based on user role -->
						<c:choose>
							<c:when test="${sessionScope.user.role}">
								<a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
							</c:when>
							<c:otherwise>
								<a href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
							</c:otherwise>
						</c:choose>
						<a href="${pageContext.request.contextPath}/auth/logout" class="logout-btn">Đăng xuất</a>
					</c:when>
					<c:when test="${not empty sessionScope.authUser}">
						<!-- Dashboard link for admin users -->
						<c:choose>
							<c:when test="${sessionScope.authUser.role}">
								<a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
							</c:when>
							<c:otherwise>
								<a href="${pageContext.request.contextPath}/reporter/dashboard">Dashboard</a>
							</c:otherwise>
						</c:choose>
						<a href="${pageContext.request.contextPath}/auth/logout" class="logout-btn">Đăng xuất</a>
					</c:when>
					<c:otherwise>
						<a href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
						<a href="${pageContext.request.contextPath}/auth/register">Đăng ký</a>
					</c:otherwise>
				</c:choose>
			</nav>
		</div>
	</header>