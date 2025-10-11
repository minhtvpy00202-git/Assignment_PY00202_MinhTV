<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core" %>
		<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
			<c:set var="ctx" value="${pageContext.request.contextPath}" />

			<%@ include file="../layout/admin-header.jsp" %>
				<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

				<main class="container admin-page">
					<h2>Quản lý Người dùng</h2>

					<form method="post" action="${ctx}/admin/users" class="form">
						<input type="hidden" name="action" value="${empty item ? 'create' : 'update'}" /> <input
							type="hidden" name="id" value="${item.id}" /> <label>Họ tên <input name="fullName"
								value="${item.fullname}" required />
						</label> <label>Email <input type="email" name="email" value="${item.email}" required />
						</label> <label>Số điện thoại <input name="mobile" value="${item.mobile}" />
						</label>

						<%-- format yyyy-MM-dd cho input[type=date] --%>
							<fmt:formatDate value="${item.birthday}" pattern="yyyy-MM-dd" var="bd" />
							<label>Ngày sinh <input type="date" name="birthday" value="${bd}" />
							</label> <label>Giới tính <select name="gender">
									<option value="true" ${item.gender ? 'selected' : '' }>Nam</option>
									<option value="false" ${!item.gender ? 'selected' : '' }>Nữ</option>
								</select>
							</label> <label>Vai trò <select name="role" required>
									<option value="ADMIN" ${item.role ? 'selected' : '' }>ADMIN</option>
									<option value="REPORTER" ${!item.role ? 'selected' : '' }>REPORTER</option>
								</select>
							</label> <label>Mật khẩu (để trống nếu không đổi) <input type="password" name="password" />
							</label>

							<div class="checkbox-wrapper">
								<input type="checkbox" id="activated" name="activated" ${item.activated ? 'checked' : ''
									} />
								<label for="activated" class="checkbox-label">Kích hoạt</label>
							</div>

							<button type="submit">${empty item ? 'Thêm mới' : 'Cập nhật'}</button>
							<c:if test="${not empty item}">
								<a class="btn" href="${ctx}/admin/users">Hủy</a>
							</c:if>
					</form>

					<div class="table-wrapper">
						<table class="table">
							<thead>
								<tr>
									<th>STT</th>
									<th>ID</th>
									<th>Họ tên</th>
									<th>Email</th>
									<th>Điện thoại</th>
									<th>Giới tính</th>
									<th>Vai trò</th>
									<th>Kích hoạt</th>
									<th>Hành động</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="u" items="${items}" varStatus="status">
									<tr>
										<td class="text-center">${status.index + 1}</td>
										<td>${u.id}</td>
										<td>${u.fullname}</td>
										<td>${u.email}</td>
										<td>${u.mobile}</td>
										<td>
											<c:out value="${u.gender ? 'Nam' : 'Nữ'}" />
										</td>
										<td>
											<c:out value="${u.role ? 'ADMIN' : 'REPORTER'}" />
										</td>
										<td>
											<c:out value="${u.activated ? '✔' : '✘'}" />
										</td>
										<td class="actions">
											<a class="btn ghost" href="${ctx}/admin/users?action=edit&id=${u.id}">Sửa</a>
											<form method="post" action="${ctx}/admin/users" style="display: inline"
												onsubmit="return confirm('Xóa người dùng này?');">
												<input type="hidden" name="action" value="delete" />
												<input type="hidden" name="id" value="${u.id}" />
												<button type="submit" class="btn danger">Xóa</button>
											</form>
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</main>

				<style>
					/* Checkbox styling */
					.checkbox-wrapper {
						display: flex;
						align-items: center;
						gap: 0.5rem;
						margin: 1rem 0;
					}

					.checkbox-wrapper input[type="checkbox"] {
						width: 18px;
						height: 18px;
						margin: 0;
						cursor: pointer;
						accent-color: #667eea;
					}

					.checkbox-wrapper .checkbox-label {
						margin: 0;
						cursor: pointer;
						font-weight: 500;
						color: #2d3748;
						user-select: none;
					}

					.checkbox-wrapper .checkbox-label:hover {
						color: #667eea;
					}

					/* Override default form label styles for checkbox */
					.form .checkbox-wrapper .checkbox-label {
						display: inline;
						font-size: 1rem;
						line-height: 1;
					}

					/* Table header styling fix */
					.table thead th {
						background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
						color: white !important;
						font-weight: 600 !important;
						text-align: center !important;
						padding: 1rem 0.75rem !important;
						font-size: 0.9rem !important;
						letter-spacing: 0.5px !important;
						text-transform: uppercase !important;
						border-bottom: 2px solid #5a67d8 !important;
					}

					.table th {
						background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
						color: white !important;
					}

					/* Table body styling */
					.table tbody tr:nth-child(even) {
						background: #f8fafc !important;
					}

					.table tbody tr:hover {
						background: #e2e8f0 !important;
						transform: scale(1.01);
						transition: all 0.2s ease;
					}

					.table td {
						padding: 0.875rem 0.75rem !important;
						vertical-align: middle !important;
						border-bottom: 1px solid #e2e8f0 !important;
					}

					/* Action buttons styling */
					.table .actions {
						display: flex;
						gap: 0.25rem;
						justify-content: center;
						align-items: center;
						white-space: nowrap;
					}

					.table .actions .btn {
						padding: 0.25rem 0.5rem;
						font-size: 0.75rem;
						border-radius: 4px;
						font-weight: 500;
						min-width: 40px;
						text-align: center;
						height: 24px;
					}

					.table .actions .btn.ghost {
						background: #f1f5f9 !important;
						color: #475569 !important;
						border: 1px solid #cbd5e1 !important;
					}

					.table .actions .btn.ghost:hover {
						background: #e2e8f0 !important;
						color: #334155 !important;
					}

					.table .actions .btn.danger {
						background: linear-gradient(135deg, #ef4444, #dc2626) !important;
						color: white !important;
						border: 1px solid #b91c1c !important;
					}

					.table .actions .btn.danger:hover {
						background: linear-gradient(135deg, #dc2626, #b91c1c) !important;
						transform: translateY(-1px);
					}

					/* Responsive */
					@media (max-width: 768px) {
						.checkbox-wrapper {
							gap: 0.75rem;
						}

						.checkbox-wrapper input[type="checkbox"] {
							width: 20px;
							height: 20px;
						}

						.table thead th {
							padding: 0.75rem 0.5rem !important;
							font-size: 0.8rem !important;
						}

						.table td {
							padding: 0.75rem 0.5rem !important;
							font-size: 0.9rem;
						}

						.table .actions {
							flex-direction: column;
							gap: 0.25rem;
						}

						.table .actions .btn {
							width: 100%;
							padding: 0.375rem 0.75rem;
							font-size: 0.8rem;
						}
					}
				</style>

				<jsp:include page="/WEB-INF/views/layout/footer.jsp" />