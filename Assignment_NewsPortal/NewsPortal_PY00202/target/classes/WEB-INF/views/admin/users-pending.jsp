<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../layout/admin-header.jsp"%>


<main class="container admin-page">

	<c:if test="${not empty sessionScope.flashMsg}">
	  <div class="alert ${sessionScope.flashType}">
	    ${sessionScope.flashMsg}
	  </div>
	  <c:remove var="flashMsg" scope="session"/>
	  <c:remove var="flashType" scope="session"/>
	</c:if>
	
	
	<c:if test="${empty list}">
		<p style="text-align: center; border: 1px solid #ddd;">Không có tài khoản nào đang chờ duyệt.</p>
	</c:if>

	<c:if test="${not empty list}">
		<body class="admin-layout">
			<main class="admin-main">
				<div class="container">
					<div class="table-section">
						<h2>TÀI KHOẢN CHỜ DUYỆT</h2>
						<div class="table-wrapper">
							<table class="table">
								<thead>
									<tr>
										<th>STT</th>
										<th>ID</th>
										<th>Họ tên</th>
										<th>Email</th>
										<th>Mobile</th>
										<th>Giới tính</th>
										<th>Ngày sinh</th>
										<th>Vai trò</th>
										<th>Thao tác</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach var="u" items="${list}" varStatus="status">
										<tr>
											<td class="text-center">${status.index + 1}</td>
											<td>${u.id}</td>
											<td>${u.fullname}</td>
											<td>${u.email}</td>
											<td>${empty u.mobile ? '-' : u.mobile}</td>
											<td><c:out value="${u.gender ? 'Nam' : 'Nữ'}" /></td>
											<td><c:choose>
													<c:when test="${u.birthday != null}">
														<fmt:formatDate value="${u.birthday}" pattern="dd/MM/yyyy" />
													</c:when>
													<c:otherwise>-</c:otherwise>
												</c:choose></td>
											<td><span class="badge ${u.role ? 'success' : 'info'}">
													${u.role ? 'Admin' : 'Reporter'} </span></td>
											<td class="actions">
												<div class="action-buttons-compact">
													<form method="post"
														action="${pageContext.request.contextPath}/admin/users-pending">
														<input type="hidden" name="id" value="${u.id}"> <input
															type="hidden" name="action" value="approve">
														<button type="submit" class="btn btn-approve"
															title="Duyệt tài khoản">✓</button>
													</form>

													<form method="post"
														action="${pageContext.request.contextPath}/admin/users-pending"
														onsubmit="return confirm('Từ chối tài khoản này?')">
														<input type="hidden" name="id" value="${u.id}"> <input
															type="hidden" name="action" value="reject">
														<button type="submit" class="btn btn-reject"
															title="Từ chối tài khoản">✗</button>
													</form>

													<form method="post"
														action="${pageContext.request.contextPath}/admin/users-pending">
														<input type="hidden" name="id" value="${u.id}"> <input
															type="hidden" name="action" value="toggle-role">
														<button type="submit" class="btn btn-toggle"
															title="Đổi vai trò">🔁</button>
													</form>
												</div>
											</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</c:if>
</main>

<script>
  setTimeout(()=> {
    const el = document.querySelector('.alert');
    if (el) el.style.display = 'none';
  }, 3000);
</script>


<%@ include file="../layout/footer.jsp"%>
