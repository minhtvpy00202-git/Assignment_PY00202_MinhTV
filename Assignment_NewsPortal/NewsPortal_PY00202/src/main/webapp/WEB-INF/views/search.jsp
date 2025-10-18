<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ include file="layout/header.jsp"%>

<main class="container">
	<div class="main-content">
		<section class="content-area">
			<div class="search-header">
				<h1>Tìm kiếm</h1>
				<p>Tìm kiếm bài viết theo từ khóa</p>
			</div>

			<!-- Search Form -->
			<form class="search-form-main"
				action="${pageContext.request.contextPath}/search" method="get">
				<div class="search-input-group">
					<input class="form-control" type="text" name="q"
						value="<c:out value='${q}'/>"
						placeholder="Nhập từ khóa tìm kiếm..." autofocus>
					<button class="btn btn-primary" type="submit">Tìm kiếm</button>
				</div>
			</form>

			<!-- Search Results -->
			<c:if test="${not empty q}">
				<div class="search-info" >
					<h2>
						Kết quả tìm kiếm cho: "<strong><c:out value="${q}" /></strong>"
					</h2>
					<p class="result-count">
						<c:choose>
							<c:when test="${resultCount == 0}">
              Không tìm thấy kết quả nào
            </c:when>
							<c:when test="${resultCount == 1}">
              Tìm thấy 1 kết quả
            </c:when>
							<c:otherwise>
              Tìm thấy ${resultCount} kết quả
            </c:otherwise>
						</c:choose>
					</p>
				</div>
				
				<hr style="margin-top: 0">

				<div class="search-results">
					<c:choose>
						<c:when test="${not empty results}">
							<c:forEach var="news" items="${results}">
								<article class="search-result">
									<h3 class="result-title">
										<a href="${pageContext.request.contextPath}/news/${news.id}">
											<c:out value="${news.title}" />
										</a>
									</h3>

									<div class="result-meta">
										<span>Đăng ngày: <c:out
												value="${news.postedDateFormatted}" /></span>
										<c:if test="${not empty news.author}">
											<span> • Tác giả: <c:out value="${news.author}" /></span>
										</c:if>
										<span> • <c:out value="${news.viewCount}" /> lượt xem
										</span>
									</div>

									<div class="result-excerpt">
										<c:out value="${news.excerpt}" />
									</div>
								</article>

							</c:forEach>

							<!-- PHÂN TRANG -->
							<c:if test="${totalPages > 1}">
								<c:url var="base" value="/search">
									<c:param name="q" value="${q}" />
									<c:param name="size" value="${size}" />
								</c:url>
								<nav class="pager"
									style="margin-top: 20px; display: flex; gap: 8px; justify-content: center;">
									<a class="btn ghost"
										href="${base}&page=1"
										${page==1?'style="pointer-events:none;opacity:.5"':''}>«
										Đầu</a> <a class="btn ghost"
										href="${base}&page=${page-1}"
										${page==1?'style="pointer-events:none;opacity:.5"':''}>‹
										Trước</a> <span class="btn" style="pointer-events: none;">Trang
										${page}/${totalPages} — Tổng ${resultCount}</span> <a
										class="btn ghost"
										href="${base}&page=${page+1}"
										${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>Sau
										›</a> <a class="btn ghost"
										href="${base}&page=${totalPages}"
										${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>Cuối
										»</a>
								</nav>
							</c:if>

						</c:when>
						<c:otherwise>
							<div class="no-results">
								<h3>Không tìm thấy kết quả</h3>
								<p>
									Không có bài viết nào phù hợp với từ khóa "<strong><c:out
											value="${q}" /></strong>"
								</p>
								<div class="search-suggestions">
									<h4>Gợi ý:</h4>
									<ul>
										<li>Kiểm tra lại chính tả từ khóa</li>
										<li>Thử sử dụng từ khóa khác</li>
										<li>Sử dụng từ khóa ngắn gọn hơn</li>
										<li>Tìm kiếm theo chuyên mục cụ thể</li>
									</ul>
								</div>
							</div>
						</c:otherwise>
					</c:choose>
				</div>
			</c:if>

			<!-- Display error if any -->
			<c:if test="${not empty error}">
				<div class="alert error">
					<c:out value="${error}" />
				</div>
			</c:if>
		</section>

		<aside class="sidebar-area">
			<jsp:include page="/WEB-INF/views/layout/sidebar-home.jsp" />
			<jsp:include page="layout/sidebar.jsp" />

		</aside>


	</div>
</main>

<%@ include file="layout/footer.jsp"%>
