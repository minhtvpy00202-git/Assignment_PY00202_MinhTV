<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="sidebar">
  <div class="sidebar-panel">
    <h3>Chuyên mục</h3>
    <div class="content">
      <ul>
        <c:forEach var="cata" items="${categories}">
          <li><a href="${pageContext.request.contextPath}/category?id=${cata.id}">${cata.name}</a></li>
        </c:forEach>
      </ul>
    </div>
  </div>
  
  <div class="sidebar-panel">
    <h3>Liên hệ</h3>
    <div class="content">
      <div class="meta">
        <strong>Email:</strong> contact@newsportal.local<br>
        <strong>Hotline:</strong> 1900-xxxx
      </div>
    </div>
  </div>
</aside>
