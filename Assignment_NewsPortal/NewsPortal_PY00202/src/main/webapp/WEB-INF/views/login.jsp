<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="layout/header.jsp" %>

<main class="container">
  <div class="auth-container">
    <div class="auth-form">
      <h1><fmt:message key="auth.login.title"/></h1>
      <p><fmt:message key="auth.login.subtitle"/></p>
      
      <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
      </c:if>
      
      <form method="post" action="${pageContext.request.contextPath}/auth/login">
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.email"/></label>
          <input class="form-control" type="email" name="email" required>
        </div>
        
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.password"/></label>
          <input class="form-control" type="password" name="password" required>
        </div>
        
        <div class="form-actions">
          <button class="btn btn-primary" type="submit">
            <fmt:message key="auth.login"/>
          </button>
          <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/auth/register">
            <fmt:message key="auth.createAccount"/>
          </a>
        </div>
      </form>
    </div>
  </div>
</main>

<%@ include file="layout/footer.jsp" %>
