
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="../layout/admin-header.jsp" %>


<main class="container admin-page">
  <section class="content">
    <h1>CÀI ĐẶT HỆ THỐNG</h1>
    <form class="form" method="post" action="${pageContext.request.contextPath}/admin/settings/save">
      <label>Tiêu đề site</label>
      <input name="siteTitle" value="${settings.siteTitle}">
      <label>Email gửi newsletter</label>
      <input name="newsletterFrom" value="${settings.newsletterFrom}">
      <div class="actions">
        <button class="btn" type="submit">Lưu</button>
      </div>
    </form>
  </section>
</main>

<%@ include file="../layout/footer.jsp" %>
