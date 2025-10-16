<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="layout/header.jsp" %>

<div class="container">
  <div class="main-content">
    <!-- CONTENT AREA -->
    <section class="content-area">
      <div class="category-header">
        <h1>Chuyên mục: <c:out value="${currentCategory.name}" /></h1>
      </div>

      <c:choose>
        <c:when test="${empty news}">
          <div class="alert alert-info">Chưa có bài viết nào trong chuyên mục này.</div>
        </c:when>
        <c:otherwise>
          <div class="news-list">
            <c:forEach var="n" items="${news}">
              <!-- Biến tiện ích -->
              <c:set var="ctx" value="${pageContext.request.contextPath}" />
              <c:set var="ctxSlash" value="${ctx}/" />
              <c:set var="img" value="${n.image}" />

              <!-- Build URL ảnh an toàn -->
              <c:choose>
                <c:when test="${empty img}">
                  <c:set var="imgUrl" value="${ctx}/assets/img/sample.jpg" />
                </c:when>
                <c:when test="${fn:startsWith(img,'http')}">
                  <c:set var="imgUrl" value="${img}" />
                </c:when>
                <c:when test="${fn:startsWith(img, ctxSlash)}">
                  <c:set var="imgUrl" value="${img}" />
                </c:when>
                <c:when test="${fn:startsWith(img,'/')}">
                  <c:set var="imgUrl" value="${ctx}${img}" />
                </c:when>
                <c:otherwise>
                  <c:set var="imgUrl" value="${ctx}/${img}" />
                </c:otherwise>
              </c:choose>

              <!-- Rút gọn nội dung -->
              <c:set var="excerpt" value="${n.content}" />
              <c:if test="${fn:length(excerpt) > 160}">
                <c:set var="excerpt" value="${fn:substring(excerpt,0,160)}..." />
              </c:if>

              <!-- ITEM -->
              <article class="card post-row">
                <div class="post-content">
                  <div class="post-image">
                    <a href="${ctx}/news/${n.id}">
                      <img src="${imgUrl}" alt="${fn:escapeXml(n.title)}">
                    </a>
                  </div>
                  <div class="post-text">
                    <h2 class="card-title">
                      <a href="${ctx}/news/${n.id}">
                        <c:out value="${n.title}" />
                      </a>
                    </h2>
                    <p class="card-text small">
                      <span>${n.viewCount} lượt xem</span>
                      <c:if test="${n.postedDate != null}">
						  <fmt:parseDate value="${n.postedDate}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="pd"/>
						  <span> | Đăng ngày: <fmt:formatDate value="${pd}" pattern="dd/MM/yyyy"/></span>
						</c:if>
                    </p>
                    <p class="card-text"><c:out value="${n.excerpt}" /></p>
                  </div>
                </div>
              </article>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>

      <!-- PHÂN TRANG -->
      <c:if test="${not empty page && not empty totalPages && totalPages > 1}">
        <c:set var="baseUrl" value='${pageContext.request.contextPath}/category?id=${currentCategory.id}' />
        <div class="pagination-wrapper">
          <div class="pagination">
            <c:if test="${page > 1}">
              <a class="page-link" href="${baseUrl}&page=${page-1}">← Trước</a>
            </c:if>
            <c:forEach var="i" begin="1" end="${totalPages}">
              <a class="page-link ${i==page ? 'active' : ''}" href="${baseUrl}&page=${i}">${i}</a>
            </c:forEach>
            <c:if test="${page < totalPages}">
              <a class="page-link" href="${baseUrl}&page=${page+1}">Sau →</a>
            </c:if>
          </div>
        </div>
      </c:if>
    </section>

    <!-- SIDEBAR -->
    <aside class="sidebar-area">
      <jsp:include page="layout/sidebar.jsp" />
    </aside>
  </div>
</div>

<%@ include file="layout/footer.jsp" %>
