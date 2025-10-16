<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Modern Footer -->
<footer class="modern-footer">
    <div class="footer-container">
        <div class="footer-content">
            <div class="footer-section">
                <div class="footer-brand">
                    <span class="footer-logo">📰</span>
                    <span class="footer-title">NewsPortal</span>
                </div>
                <p class="footer-description">
                    Hệ thống quản lý tin tức hiện đại và chuyên nghiệp
                </p>
            </div>
            
            <div class="footer-section">
                <h4 class="footer-heading">Thông tin</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/search">Tìm kiếm</a></li>
                    <li><a href="#" onclick="return false;">Liên hệ</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h4 class="footer-heading">Trạng thái</h4>
                <div class="footer-status">
                    <c:choose>
                        <c:when test="${not empty sessionScope.authUser}">
                            <div class="status-item">
                                <span class="status-label">Đăng nhập:</span>
                                <span class="status-value">
                                    <c:out value="${sessionScope.authUser.fullname != null ? sessionScope.authUser.fullname : sessionScope.authUser.username}"/>
                                </span>
                            </div>
                            <div class="status-item">
                                <span class="status-label">Vai trò:</span>
                                <span class="status-value ${sessionScope.authUser.role ? 'admin' : 'reporter'}">
                                    ${sessionScope.authUser.role ? 'Quản trị viên' : 'Phóng viên'}
                                </span>
                            </div>
                        </c:when>
                        <c:when test="${not empty sessionScope.user}">
                            <div class="status-item">
                                <span class="status-label">Đăng nhập:</span>
                                <span class="status-value">
                                    <c:out value="${sessionScope.user.fullname != null ? sessionScope.user.fullname : sessionScope.user.username}"/>
                                </span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="status-item">
                                <span class="status-label">Trạng thái:</span>
                                <span class="status-value">Khách</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <div class="footer-bottom">
            <div class="footer-copyright">
                <p>&copy; 2024 NewsPortal. All Right Reserved.</p>
            </div>
            <div class="footer-tech">
                <span class="tech-badge">Java</span>
                <span class="tech-badge">JSP</span>
                <span class="tech-badge">SQL Server</span>
            </div>
        </div>
    </div>
</footer>



</body>
</html>
