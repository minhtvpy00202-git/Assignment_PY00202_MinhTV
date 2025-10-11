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
                <p>&copy; 2024 NewsPortal. Tất cả quyền được bảo lưu.</p>
            </div>
            <div class="footer-tech">
                <span class="tech-badge">Java</span>
                <span class="tech-badge">JSP</span>
                <span class="tech-badge">SQL Server</span>
            </div>
        </div>
    </div>
</footer>

<style>
/* Modern Footer Styles */
.modern-footer {
    background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
    color: #ecf0f1;
    margin-top: auto;
}

.footer-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 3rem 2rem 1rem;
}

.footer-content {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr;
    gap: 3rem;
    margin-bottom: 2rem;
}

.footer-section {
    display: flex;
    flex-direction: column;
}

.footer-brand {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
}

.footer-logo {
    font-size: 2rem;
    background: linear-gradient(135deg, #3498db, #2980b9);
    padding: 0.5rem;
    border-radius: 8px;
}

.footer-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #3498db;
}

.footer-description {
    color: #bdc3c7;
    line-height: 1.6;
    margin: 0;
}

.footer-heading {
    color: #3498db;
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 1rem;
    border-bottom: 2px solid #3498db;
    padding-bottom: 0.5rem;
}

.footer-links {
    list-style: none;
    padding: 0;
    margin: 0;
}

.footer-links li {
    margin-bottom: 0.5rem;
}

.footer-links a {
    color: #bdc3c7;
    text-decoration: none;
    transition: color 0.3s ease;
}

.footer-links a:hover {
    color: #3498db;
}

.footer-status {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}

.status-item {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
}

.status-label {
    font-size: 0.875rem;
    color: #95a5a6;
    font-weight: 500;
}

.status-value {
    font-weight: 600;
    color: #ecf0f1;
}

.status-value.admin {
    color: #f39c12;
}

.status-value.reporter {
    color: #2ecc71;
}

.footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 2rem;
    border-top: 1px solid #34495e;
}

.footer-copyright p {
    margin: 0;
    color: #95a5a6;
    font-size: 0.9rem;
}

.footer-tech {
    display: flex;
    gap: 0.5rem;
}

.tech-badge {
    background: #3498db;
    color: white;
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 600;
}

/* Mobile Responsive */
@media (max-width: 480px) {
    .footer-container {
        padding: 1.5rem 0.5rem 1rem;
    }
    
    .footer-content {
        grid-template-columns: 1fr;
        gap: 1.5rem;
        margin-bottom: 1.5rem;
    }
    
    .footer-brand {
        justify-content: center;
        text-align: center;
    }
    
    .footer-description {
        text-align: center;
        font-size: 0.9rem;
    }
    
    .footer-heading {
        text-align: center;
        font-size: 1rem;
    }
    
    .footer-links {
        text-align: center;
    }
    
    .footer-status {
        align-items: center;
    }
    
    .footer-bottom {
        flex-direction: column;
        gap: 1rem;
        text-align: center;
    }
    
    .footer-copyright p {
        font-size: 0.8rem;
    }
    
    .tech-badge {
        font-size: 0.7rem;
        padding: 0.2rem 0.6rem;
    }
}

/* Tablet Responsive */
@media (min-width: 481px) and (max-width: 768px) {
    .footer-container {
        padding: 2rem 1rem 1rem;
    }
    
    .footer-content {
        grid-template-columns: 2fr 1fr;
        gap: 2rem;
    }
    
    .footer-bottom {
        flex-direction: column;
        gap: 1rem;
        text-align: center;
    }
}

/* Large Tablet */
@media (min-width: 769px) and (max-width: 1024px) {
    .footer-content {
        grid-template-columns: 2fr 1fr 1fr;
    }
}
</style>

</body>
</html>
