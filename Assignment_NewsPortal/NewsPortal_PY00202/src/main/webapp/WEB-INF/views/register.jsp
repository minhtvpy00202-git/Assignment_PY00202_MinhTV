<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="layout/header.jsp" %>

<main class="container">
  <div class="auth-container">
    <div class="auth-form register-form">
      <h1><fmt:message key="register.title"/></h1>
      <p><fmt:message key="register.subtitle"/></p>
      
      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>

      <form method="post" action="${pageContext.request.contextPath}/auth/register">
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.fullname"/></label>
            <input class="form-control" type="text" name="fullname" required>
          </div>

          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.email"/></label>
            <input class="form-control" type="email" name="email" required>
          </div>

          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.password"/></label>
            <input class="form-control" type="password" name="password" required>
          </div>

          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.phone"/></label>
            <input class="form-control" type="text" name="mobile" placeholder="090...">
          </div>

          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.birthday"/></label>
            <input class="form-control" type="date" name="birthday">
          </div>

          <div class="form-group">
            <label class="form-label"><fmt:message key="auth.gender"/></label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" name="gender" value="true" checked>
                <fmt:message key="auth.gender.male"/>
              </label>
              <label class="radio-label">
                <input type="radio" name="gender" value="false">
                <fmt:message key="auth.gender.female"/>
              </label>
            </div>
          </div>

          <div class="form-group full-width">
            <label class="form-label"><fmt:message key="auth.role"/></label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" name="role" value="false" checked>
                <fmt:message key="auth.role.reporter"/>
              </label>
              <label class="radio-label">
                <input type="radio" name="role" value="true">
                <fmt:message key="auth.role.admin"/>
              </label>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">
            <fmt:message key="auth.createAccount"/>
          </button>
          <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/auth/login">
            <fmt:message key="auth.alreadyHave"/>
          </a>
        </div>
      </form>
    </div>
  </div>
</main>

<%@ include file="layout/footer.jsp" %>
