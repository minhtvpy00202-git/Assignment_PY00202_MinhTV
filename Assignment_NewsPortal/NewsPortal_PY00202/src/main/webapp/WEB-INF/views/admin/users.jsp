<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core" %>
		<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
			<c:set var="ctx" value="${pageContext.request.contextPath}" />
			<c:set var="isCreate" value="${empty item}" />
			<%@ include file="../layout/admin-header.jsp" %>

				<main class="admin-main">
					<div class="container">
						<div class="page-header">
							<h1>QUẢN LÝ NGƯỜI DÙNG</h1>
							<p>Thêm, sửa, xóa và quản lý tài khoản người dùng</p>
						</div>

						<c:if test="${not empty error}">
						  <div class="alert alert-danger" style="border: 1px solid red">${error}</div>
						</c:if>
						


						<form method="post" action="${ctx}/admin/users" class="admin-form">
							<input type="hidden" name="action" value="${empty item ? 'create' : 'update'}" />
							<input type="hidden" name="id" value="${item.id}" />

							<div class="form-grid">
								<!-- Họ tên -->
								<div class="form-group">
									<label class="form-label">Họ tên</label>
									<input class="form-control" name="fullName"
									       value="${not empty param.fullName ? param.fullName : (not empty item ? item.fullname : '')}"
									       required>
								</div>
								<!-- Email -->
								<div class="form-group">
									<label class="form-label">Email</label>
									<input class="form-control" name="email" type="email"
										       value="${not empty param.email ? param.email : (not empty item ? item.email : '')}"
										       required>
								</div>
								<!-- Số điện thoại -->
								<div class="form-group">
									<label class="form-label">Số điện thoại</label>
									<input placeholder="Nhập số điện thoại có 10 số" class="form-control" name="mobile" type="tel"
								       inputmode="numeric"
								       value="${not empty param.mobile ? param.mobile : (not empty item ? item.mobile : '')}"
								       pattern="[0-9]{10}"
								       title="Số điện thoại phải gồm đúng 10 chữ số"
								       required>
								</div>
								<!-- Ngày sinh -->
								<fmt:formatDate value="${item.birthday}" pattern="yyyy-MM-dd" var="bd" />
								<div class="form-group">
									<label class="form-label">Ngày sinh</label>
									<input class="form-control" name="birthday" type="date"
														       value="${not empty param.birthday ? param.birthday : (not empty item && item.birthday != null ? bd : '')}"
														       required>
								</div>
								<!-- Giới tính -->
								<div class="form-group">
									<label class="form-label">Giới tính</label>
									
										<select class="form-control" name="gender" required>
											  <option value="true"
											    ${not empty param.gender ? (param.gender == 'true' ? 'selected' : '') :
											      (not empty item && item.gender ? 'selected' : '')}>
											    Nam
											  </option>
											  <option value="false"
											    ${not empty param.gender ? (param.gender == 'false' ? 'selected' : '') :
											      (not empty item && !item.gender ? 'selected' : '')}>
											    Nữ
											  </option>
											</select>
									
								</div>
								<!-- Vai trò -->
								<div class="form-group">
									<label class="form-label">Vai trò</label>
									<select class="form-control" name="role">
									  <option value="ADMIN"
									    ${not empty param.role ? (param.role == 'ADMIN' ? 'selected' : '') : (not empty item && item.role ? 'selected' : '')}>Admin</option>
									  <option value="REPORTER"
									    ${not empty param.role ? (param.role == 'REPORTER' ? 'selected' : '') : (not empty item && !item.role ? 'selected' : '')}>Reporter</option>
									</select>
								</div>

								<!-- Mật khẩu -->
								<div class="form-group">
									<label class="form-label" for="password">Mật khẩu</label>
									<input class="form-control" name="password" type="password" autocomplete="new-password"
										<c:if test="${empty item}">required</c:if>
	  									<c:if test="${not empty item}">placeholder="Để trống nếu không đổi"</c:if> >
										</div>
 
								<!-- Nhập lại mật khẩu -->
								<div class="form-group">
									<label class="form-label" for="confirmPassword">Nhập lại mật khẩu</label>
									<input class="form-control" name="confirmPassword" type="password" autocomplete="new-password"
										  <c:if test="${empty item}">required</c:if>
										  <c:if test="${not empty item}">placeholder="Nhập lại mật khẩu (nếu đổi)"</c:if> >
								</div>

								<div class="form-group full-width">
									<div class="checkbox-group">
										<input type="checkbox" name="activated"
  											${not empty param.activated ? 'checked' : (not empty item && item.activated ? 'checked' : '')}>
										<label for="activated">Kích hoạt tài khoản</label>
									</div>
								</div>
							</div>

							<div class="form-actions">
								<button type="submit" class="btn btn-primary">${empty item ?
									'Thêm mới' : 'Cập
									nhật'}</button>
								<c:if test="${not empty item}">
									<a class="btn btn-outline-primary" href="${ctx}/admin/users">Hủy</a>
								</c:if>
							</div>
						</form>

							
							

						<div id="list" class="table-section">
							<h2>Danh sách người dùng</h2>

							<!-- Thanh tìm kiếm có tiêu chí -->
							<form method="get" action="${ctx}/admin/users#list" class="admin-search">
								<div class="search-row">
									<select name="by" id="bySelect" class="form-select">
										<option value="all" ${param.by=='all' ? 'selected' : '' }>Tất cả</option>
										<option value="fullname" ${param.by=='fullname' ? 'selected' : '' }>Họ tên
										</option>
										<option value="email" ${param.by=='email' ? 'selected' : '' }>Email</option>
										<option value="mobile" ${param.by=='mobile' ? 'selected' : '' }>Điện thoại
										</option>
										<option value="role" ${param.by=='role' ? 'selected' : '' }>Vai trò</option>
										<option value="activated" ${param.by=='activated' ? 'selected' : '' }>Trạng thái
											tài khoản</option>
									</select>

									<!-- Ô tìm kiếm text (mặc định) -->
									<div id="qTextWrap" class="q-wrap">
										<input type="text" name="q" id="qText" class="form-control"
											value="${fn:escapeXml(param.q)}" placeholder="Tìm kiếm..." />
									</div>

									<!-- Dropdown vai trò -->
									<div id="qRoleWrap" class="q-wrap">
										<select name="q" id="qRole" class="form-select">
											<option value="ADMIN" ${param.q=='ADMIN' ? 'selected' : '' }>ADMIN</option>
											<option value="REPORTER" ${param.q=='REPORTER' ? 'selected' : '' }>REPORTER
											</option>
										</select>
									</div>

									<!-- Dropdown kích hoạt -->
									<div id="qActWrap" class="q-wrap">
										<select name="q" id="qAct" class="form-select">
											<option value="true" ${param.q=='true' ? 'selected' : '' }>ACTIVATED
											</option>
											<option value="false" ${param.q=='false' ? 'selected' : '' }>INACTIVE
											</option>
										</select>
									</div>

									<button type="submit" class="btn btn-primary btn-search">TÌM</button>
								</div>
							</form>
							
							<c:if test="${param.created == '1'}">
							  <div class="alert alert-success" style="border: 1px solid blue;">Tạo tài khoản thành công!</div>
							</c:if>
							
							<c:if test="${param.updated == '1'}">
							  <div class="alert alert-success" style="border: 1px solid blue;">Cập nhật tài khoản thành công!</div>
							</c:if>
							
							
							
							<c:if test="${not empty info}">
							  <div class="alert alert-info" style="border: 1px solid red;">${info}</div>
							</c:if>
							
							<c:if test="${param.deleted == '1'}">
							  <div class="alert alert-success" style="border: 1px solid red;">Xóa tài khoản thành công!</div>
							</c:if>
							
							<script>
							  (function() {
							    var f = '${focusField}';
							    if (f && f !== '') {
							      var el = document.querySelector('[name="'+ f +'"]');
							      if (el) {
							        // Nếu là tabbed form thì bạn có thể mở tab chứa el (nếu cần)
							        el.focus();
							        try { el.select && el.select(); } catch(e){}
							      }
							    }
							  })();
							</script>

							<script>
								(function () {
								  const bySel = document.getElementById('bySelect');
								  const qTextW = document.getElementById('qTextWrap');
								  const qRoleW = document.getElementById('qRoleWrap');
								  const qActW  = document.getElementById('qActWrap');
								
								  const qText = document.getElementById('qText');
								  const qRole = document.getElementById('qRole');
								  const qAct  = document.getElementById('qAct');
								
								  const wraps = [qTextW, qRoleW, qActW];
								  const inputs = [qText, qRole, qAct];
								
								  function toggleInputs() {
								    const by = bySel.value;
								
								    // 1) Ẩn tất cả, bỏ active, disable inputs
								    wraps.forEach(w => w.classList.remove('active'));
								    inputs.forEach(el => el.disabled = true);
								
								    // 2) Bật đúng ô theo tiêu chí
								    if (by === 'role') {
								      qRoleW.classList.add('active');
								      qRole.disabled = false;
								    } else if (by === 'activated') {
								      qActW.classList.add('active');
								      qAct.disabled = false;
								    } else {
								      qTextW.classList.add('active');
								      qText.disabled = false;
								    }
								  }
								
								  bySel.addEventListener('change', toggleInputs);
								  // Khởi tạo theo giá trị hiện có (từ URL)
								  toggleInputs();
								})();
								</script>


							<script>
								(function () {
									const pwd = document.querySelector('input[name="password"]');
									const cf = document.querySelector('input[name="confirmPassword"]');
									if (!pwd || !cf) return;
									function v() {
										if (cf.value && pwd.value !== cf.value) cf.setCustomValidity("Mật khẩu nhập lại không khớp");
										else cf.setCustomValidity("");
									}
									pwd.addEventListener('input', v);
									cf.addEventListener('input', v);
								})();
							</script>



							<!----------------------------------------------------------------------- TABLE ----------------------------------------->

							<div class="table-wrapper">
								<table class="table">
									<thead>
										<tr>
											<th>STT</th>
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
												<td>${status.index + 1}</td>
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
													<a class="btn btn-outline-primary"
														href="${ctx}/admin/users?action=edit&id=${u.id}">Sửa</a>

													<form method="post" action="${ctx}/admin/users"
														onsubmit="return confirm('Xóa người dùng này?');">
														<input type="hidden" name="action" value="delete" />
														<input type="hidden" name="id" value="${u.id}" />

														<c:choose>
															<c:when test="${u.id eq sessionScope.authUser.id}">
																<button type="button" class="btn btn-disabled" disabled
																	aria-disabled="true"
																	title="Không thể xóa tài khoản đang đăng nhập">
																	Xóa
																</button>
															</c:when>
															<c:otherwise>
																<button type="submit"
																	class="btn btn-danger">Xóa</button>
															</c:otherwise>
														</c:choose>
													</form>
												</td>

											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</main>



				<jsp:include page="/WEB-INF/views/layout/footer.jsp" />