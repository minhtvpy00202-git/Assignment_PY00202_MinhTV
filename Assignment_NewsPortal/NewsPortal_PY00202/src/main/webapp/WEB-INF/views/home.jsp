<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ include file="layout/header.jsp"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="container">
	<div class="main-content">

		<!-- NỘI DUNG CHÍNH -->
		<div class="content-area">
			<section class="home-main">
				<div class="content">
					<c:if test="${empty approvedNews}">
						<div class="alert alert-info">Chưa có bài viết nào được
							duyệt.</div>
					</c:if>

					<div class="news-list">
						<c:forEach var="n" items="${approvedNews}">
							<!-- Xử lý ảnh -->
							<c:set var="ctx" value="${pageContext.request.contextPath}" />
							<c:set var="ctxSlash" value="${ctx}/" />
							<c:set var="img" value="${n.image}" />

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



							<!-- Mỗi bài viết -->
							<article class="card post-row">
								<div class="post-content">
									<div class="post-image">
										<a href="${ctx}/news/${n.id}"> <img src="${imgUrl}"
											alt="${fn:escapeXml(n.title)}" loading="lazy">
										</a>
									</div>
									<div class="post-text">
										<h2 class="card-title">
											<a href="${ctx}/news/${n.id}"> <c:out value="${n.title}" />
											</a>
										</h2>
										<p class="card-text small">
											<c:if test="${n.postedDate != null}">
												<!-- Nếu đã có getter formatted thì dùng cho gọn: -->
          Đăng ngày: ${n.postedDateFormatted}
        </c:if>
											<c:if test="${not empty n.author}">
												<span> | ${n.author}</span>
											</c:if>
										</p>
										<p class="card-text">
											<c:out value="${n.excerpt}" />
										</p>
									</div>
								</div>
							</article>

						</c:forEach>
					</div>
				</div>
			</section>
		</div>

		<!-- SIDEBAR -->
		<aside class="sidebar-area">
			<jsp:include page="/WEB-INF/views/layout/sidebar-home.jsp" />
		</aside>

	</div>
</div>

<%@ include file="layout/footer.jsp"%>
