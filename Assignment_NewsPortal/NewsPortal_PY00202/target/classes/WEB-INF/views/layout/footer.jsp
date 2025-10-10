<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<footer>
  <div class="container">
    <p>&copy; 2024 NewsPortal. All rights reserved.</p>
    
    <!-- Hiển thị thông tin người dùng đã đăng nhập -->
    <c:choose>
      <c:when test="${not empty sessionScope.authUser}">
        <p>Chào mừng, <strong><c:out value="${sessionScope.authUser.fullname}"/></strong></p>
      </c:when>
      <c:when test="${not empty sessionScope.user}">
        <p>Chào mừng, <strong><c:out value="${sessionScope.user.fullname}"/></strong></p>
      </c:when>
      <c:otherwise>
        <p>Chào mừng bạn đến với NewsPortal</p>
      </c:otherwise>
    </c:choose>
  </div>
</footer>
