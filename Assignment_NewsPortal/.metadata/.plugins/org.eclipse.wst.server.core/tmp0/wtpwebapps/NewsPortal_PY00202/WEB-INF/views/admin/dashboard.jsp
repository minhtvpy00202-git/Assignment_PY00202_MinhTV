<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="🗞️ Dashboard Admin - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<!-- Main Content -->
<main class="admin-main">
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1>DASHBOARD QUẢN TRỊ</h1>
            <p>Tổng quan hệ thống và quản lý nội dung</p>
            <a href="${pageContext.request.contextPath}/admin/news-approve" class="btn btn-primary">Duyệt bài</a>
        </div>

        <!-- Statistics Cards -->
        <div class="admin-dashboard">
            <div class="dashboard-card">
                <h3>${newsTotal != null ? newsTotal : 0}</h3>
                <p>Tổng bài viết</p>
            </div>
            
            <div class="dashboard-card">
                <h3>${pendingCount != null ? pendingCount : 0}</h3>
                <p>Chờ duyệt</p>
            </div>
            
            <div class="dashboard-card">
                <h3>${usersTotal != null ? usersTotal : 0}</h3>
                <p>Người dùng</p>
            </div>
        </div>

        <!-- Dashboard Sections -->
        <div class="dashboard-sections">
            <!-- Categories Section -->
            <div class="section">
                <div class="section-header">
                    <h2>Chuyên mục</h2>
                    <a href="${pageContext.request.contextPath}/admin/categories">Quản lý →</a>
                </div>
                
                <div class="categories-list">
                    <c:choose>
                        <c:when test="${not empty categories}">
                            <c:forEach var="c" items="${categories}" varStatus="status">
                                <c:if test="${status.index < 6}">
                                    <div class="category-item">
                                        <span>${c.name}</span>
                                    </div>
                                </c:if>
                            </c:forEach>
                            <c:if test="${categories.size() > 6}">
                                <div class="category-item">
                                    <span>+${categories.size() - 6} khác</span>
                                </div>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <p>Chưa có chuyên mục</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Pending Articles Section -->
            <div class="section">
                <div class="section-header">
                    <h2>Bài chờ duyệt</h2>
                    <a href="${pageContext.request.contextPath}/admin/news-approve">Xem tất cả →</a>
                </div>

                <c:choose>
                    <c:when test="${not empty pendingList}">
                        <div class="pending-articles">
                            <c:forEach var="n" items="${pendingList}" varStatus="st">
                                <c:if test="${st.index < 5}">
                                    <div class="pending-article">
                                        <div class="article-info">
                                            <h4><c:out value="${n.title}" /></h4>
                                            <p class="article-meta">
                                                Tác giả: ${n.author} | Chuyên mục: ${catMap[n.categoryId]}
                                                <c:if test="${n.home}"> | Trang chủ</c:if>
                                            </p>
                                        </div>
                                        <div class="article-actions">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/news-approve">
                                                <input type="hidden" name="id" value="${n.id}">
                                                <input type="hidden" name="action" value="approve">
                                                <button type="submit" class="btn btn-success">Duyệt</button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/news-approve" 
                                                  onsubmit="return confirm('Từ chối và xóa bài này?');">
                                                <input type="hidden" name="id" value="${n.id}">
                                                <input type="hidden" name="action" value="reject">
                                                <button type="submit" class="btn btn-danger">Từ chối</button>
                                            </form>
                                        </div>
                                    </div>
                                </c:if>
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