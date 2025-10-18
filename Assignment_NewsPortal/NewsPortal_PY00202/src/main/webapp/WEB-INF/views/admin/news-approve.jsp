<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>
<%@ include file="../layout/admin-header.jsp"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />



<main class="container admin-page">
	<h2>DUYỆT BÀI VIẾT</h2>

	<!-- Form lọc / tìm kiếm -->
	<form method="get" action="${ctx}/admin/news-approve"
		class="table-tools"
		style="gap: .5rem; display: flex; flex-wrap: wrap; align-items: center">
		<input type="text" name="q" value="${fn:escapeXml(q)}"
			placeholder="Tìm tiêu đề / nội dung" class="form-control"
			style="min-width: 220px;"> <select name="catId"
			class="form-control">
			<option value="">-- Tất cả chuyên mục --</option>
			<c:forEach var="c" items="${categories}">
				<option value="${c.id}" ${catId == c.id ? 'selected' : ''}>${c.name}</option>
			</c:forEach>
		</select>
		<!-- Bạn có thể thêm lọc theo phóng viên nếu muốn: một select được build từ reporters hoặc 1 ô nhập Id -->
		<input type="date" name="from" value="${from}"
			style="font-family: 'Noto Serif', serif; height: 44.8px;"> <input
			type="date" name="to" value="${to}"
			style="font-family: 'Noto Serif', serif; height: 44.8px;">
		<button class="btn">Lọc</button>
	</form>

	<c:if test="${empty pendingList}">
		<p style="text-align: center; border: 1px solid #ddd; padding: 8px">Không
			có bài viết chờ duyệt.</p>
	</c:if>

	<c:forEach var="n" items="${pendingList}">
		<div class="card article">
			<h3 style="margin: 0 0 4px">
				<!-- Link tiêu đề sang trang xem chi tiết; ref=approve để hiện nút ở trang kia -->
				<a href="${ctx}/admin/news-detail?id=${n.id}&ref=approve">${n.title}</a>
			</h3>
			<small> Đăng bởi: <c:set var="author"
					value="${reporters[n.reporterId]}" /> ${author != null ? author.fullname : '—'}
				&nbsp;—&nbsp;Ngày đăng: ${n.postedDateFormatted}
			</small>


			<!-- Tóm tắt: lấy 200 ký tự đầu -->
			<p>
				<c:choose>
					<c:when test="${not empty n.excerpt}">
            ${n.excerpt}
          </c:when>
					<c:otherwise>
						<c:set var="raw" value="${n.content}" />
            ${fn:length(raw) > 200 ? fn:substring(raw,0,200).concat('...') : raw}
          </c:otherwise>
				</c:choose>
			</p>

			<div class="actions"
				style="display: flex; gap: .5rem; align-items: center;">
				<a class="btn ghost"
					href="${ctx}/admin/news-detail?id=${n.id}&ref=approve">Xem bài</a>

				<form method="post" action="${ctx}/admin/news-approve"
					style="display: inline">
					<input type="hidden" name="id" value="${n.id}">
					<button class="btn" name="action" value="approve">Duyệt</button>
					<button class="btn ghost" name="action" value="home-on">Đưa
						Lên Trang chủ</button>
					<button class="btn danger" name="action" value="reject"
						onclick="return confirm('Xoá bài này?')">Xoá</button>
				</form>
			</div>

		</div>
		<hr>
	</c:forEach>

	<!-- Phân trang -->
	<c:if test="${totalPages > 1}">
  <c:url var="base" value="/admin/news-approve">
    <c:param name="q" value="${q}" />
    <c:if test="${catId != null}"><c:param name="catId" value="${catId}" /></c:if>
    <c:if test="${reporterId != null}"><c:param name="reporterId" value="${reporterId}" /></c:if>
    <c:if test="${from != null}"><c:param name="from" value="${from}" /></c:if>
    <c:if test="${to != null}"><c:param name="to" value="${to}" /></c:if>
  </c:url>

  <nav class="pagination" style="display:flex;gap:.5rem;justify-content:center;margin:12px 0">
    <a class="btn ghost" href="${base}&page=1"         ${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>« Đầu</a>
    <a class="btn ghost" href="${base}&page=${page-1}" ${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>‹ Trước</a>
    <span class="btn" style="pointer-events:none">Trang ${page}/${totalPages} (Tổng ${total})</span>
    <a class="btn ghost" href="${base}&page=${page+1}" ${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>Sau ›</a>
    <a class="btn ghost" href="${base}&page=${totalPages}" ${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>Cuối »</a>
  </nav>
</c:if>

</main>

<%@ include file="../layout/footer.jsp"%>
