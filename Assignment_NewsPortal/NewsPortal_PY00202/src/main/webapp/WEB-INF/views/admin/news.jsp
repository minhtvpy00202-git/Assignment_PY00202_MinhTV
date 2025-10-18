<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<%@ include file="../layout/admin-header.jsp"%>

<style>
.badge-home {
	display: inline-block;
	padding: 2px 8px;
	margin-left: 6px;
	border: 1px solid #22c55e;
	border-radius: 999px;
	font-size: .75rem;
	color: #166534;
	background: #dcfce7;
	font-weight: 600;
}

.badge-approved {
	display: inline-block;
	padding: 2px 8px;
	margin-left: 6px;
	border: 1px solid #3b82f6;
	border-radius: 999px;
	font-size: .75rem;
	color: #1d4ed8;
	background: #dbeafe;
	font-weight: 600;
}

.btn-xs {
	padding: .25rem .5rem;
	font-size: .8rem;
}
</style>

<main class="admin-main">
	<div class="container">
		<div class="page-header">
			<h1>QUẢN LÝ TIN TỨC</h1>
			<p>Thêm, sửa, xóa và quản lý các bài tin tức</p>
		</div>



		<!-- Danh sách tin tức -->
		<div id="list" class="table-section">
			<h2>DANH SÁCH TIN</h2>

			<!-- Bộ lọc / Tìm kiếm -->
			<form class="table-tools" method="get"
				action="${ctx}/admin/news#list">
				<div class="tools-row">
					<select class="form-select" name="cat"
						aria-label="Lọc theo loại tin">
						<option value="0">Tất cả loại tin</option>
						<c:forEach var="c" items="${categories}">
							<option value="${c.id}"
								${param.cat == c.id ? 'selected' : (cat==c.id?'selected':'')}>
								${c.name}</option>
						</c:forEach>
					</select> <input class="form-control" name="q"
						placeholder="Tìm theo tiêu đề…" value="${q}" />

					<button type="submit" class="btn btn-primary">Tìm</button>
					<a class="btn btn-outline-primary" href="${ctx}/admin/news">Xóa
						lọc</a>
				</div>
			</form>


			<div class="table-wrapper">
				<table class="table">
					<thead>
						<tr>
							<th>STT</th>
							<th>Tiêu đề</th>
							<th>Chuyên mục</th>
							<th>Ngày đăng</th>
							<th>Home</th>
							<th>Hành động</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="n" items="${items}" varStatus="loop">
							<tr>
								<td>${(page - 1) * size + loop.index + 1}</td>
								<td><a href="${ctx}/admin/news-edit?id=${n.id}">${fn:escapeXml(n.title)}</a>
									<c:if test="${n.home}">
										<span class="badge-home">Home</span>
									</c:if> <c:if test="${n.approved}">
										<span class="badge-approved">Approved</span>
									</c:if></td>
								<td>${n.categoryId}</td>
								<td>${n.postedDateFormatted}</td>
								<td>${n.home ? '1' : '0'}</td>
								<td style="white-space: nowrap"><a class="btn btn-xs"
									href="${ctx}/admin/news-edit?id=${n.id}">Sửa</a> <!-- Toggle Home -->
									<form method="post" action="${ctx}/admin/news"
										style="display: inline">
										<input type="hidden" name="id" value="${n.id}"> <input
											type="hidden" name="page" value="${page}">
										<c:choose>
											<c:when test="${n.home}">
												<button style="border: 1px solid red; height: 31.5px" class="btn btn-xs ghost" name="action"
													value="home-off"
													onclick="return confirm('Gỡ khỏi Trang chủ?')">Unpin</button>
											</c:when>
											<c:otherwise>
												<button style="border: 1px solid blue; height: 31.5px" class="btn btn-xs" name="action" value="home-on">
													Pin</button>
											</c:otherwise>
										</c:choose>
									</form> <!-- Delete (nếu cần) -->
									<form method="post" action="${ctx}/admin/news"
										style="display: inline">
										<input type="hidden" name="id" value="${n.id}"> <input
											type="hidden" name="page" value="${page}">
										<button style="border: 1px solid red; height: 31.5px" class="btn btn-xs danger" name="action" value="delete"
											onclick="return confirm('Xoá bài này?')">Xoá</button>
									</form></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>

				<!-- PHÂN TRANG -->
				<c:if test="${totalPages > 1}">
					<c:url var="base" value="/admin/news">
						<c:param name="q" value="${q}" />
						<c:param name="cat" value="${cat}" />
						<c:param name="size" value="${size}" />
					</c:url>

					<nav
						style="display: flex; gap: .5rem; justify-content: center; margin: 12px 0">
						<a class="btn ghost" href="${base}&page=1"
							${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>«
							Đầu</a> <a class="btn ghost" href="${base}&page=${page-1}"
							${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>‹
							Trước</a> <span class="btn" style="pointer-events: none">Trang
							${page}/${totalPages} — Tổng ${total}</span> <a class="btn ghost"
							href="${base}&page=${page+1}"
							${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>Sau
							›</a> <a class="btn ghost" href="${base}&page=${totalPages}"
							${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>Cuối
							»</a>
					</nav>
				</c:if>


			</div>
		</div>


	</div>
</main>



<script
	src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  toolbar: [
    'heading','|',
    'bold','italic','underline','link',
    'bulletedList','numberedList','blockQuote','insertTable','|',
    'insertImage','imageUpload','mediaEmbed','|',
    'undo','redo'
  ],
  simpleUpload: {
    uploadUrl: '${ctx}/upload-image',
    withCredentials: false
  },
  image: {
    toolbar: [
      'imageTextAlternative', '|',
      'imageStyle:inline', 'imageStyle:block', 'imageStyle:side'
    ]
  }
}).catch(console.error);
</script>



<jsp:include page="/WEB-INF/views/layout/footer.jsp" />