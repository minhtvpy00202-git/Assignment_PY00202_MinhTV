<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="layout/header.jsp" %>

<main class="container">
  <div class="auth-container">
    <div class="auth-form register-form">
      <h1>Đăng ký</h1>
      <p>Tạo tài khoản NewsPortal mới</p>
      
      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>

      <form method="post" action="${pageContext.request.contextPath}/auth/register">
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label">Họ tên</label>
            <input class="form-control" type="text" name="fullname" required>
          </div>

          <div class="form-group">
            <label class="form-label">Email</label>
            <input class="form-control" type="email" name="email" required>
          </div>

          <div class="form-group">
            <label class="form-label">Mật khẩu</label>
            <input class="form-control" type="password" name="password" required>
          </div>

          <div class="form-group">
            <label class="form-label">Số điện thoại</label>
            <input class="form-control" type="text" name="mobile" placeholder="090...">
          </div>

          <div class="form-group">
            <label class="form-label">Ngày sinh</label>
            <input class="form-control" type="date" name="birthday">
          </div>

          <div class="form-group">
            <label class="form-label">Giới tính</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" name="gender" value="true" checked> Nam
              </label>
              <label class="radio-label">
                <input type="radio" name="gender" value="false"> Nữ
              </label>
            </div>
          </div>

          <div class="form-group full-width">
            <label class="form-label">Vai trò</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" name="role" value="false" checked> Phóng viên (Reporter)
              </label>
              <label class="radio-label">
                <input type="radio" name="role" value="true"> Quản trị (Admin)
              </label>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">Tạo tài khoản</button>
          <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/auth/login">Đã có tài khoản</a>
        </div>
      </form>
    </div>
  </div>
</main>

<%@ include file="layout/footer.jsp" %>
