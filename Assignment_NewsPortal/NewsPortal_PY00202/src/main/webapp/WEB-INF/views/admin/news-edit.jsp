<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="container admin-page">
  <h2><fmt:message key="admin.news.edit.pageTitle"/></h2>

  <form class="form" method="post" action="${ctx}/admin/news-edit" enctype="multipart/form-data">
    <input type="hidden" name="id" value="${news.id}">

    <label>
      <fmt:message key="admin.news.edit.titleLabel"/>
      <input name="title" required value="${news.title}">
    </label>

    <label>
      <fmt:message key="admin.news.edit.categoryLabel"/>
      <select name="categoryId" required>
        <c:forEach var="c" items="${categories}">
          <option value="${c.id}" ${c.id == news.categoryId ? 'selected' : ''}>${c.name}</option>
        </c:forEach>
      </select>
    </label>

    <label>
      <fmt:message key="admin.news.edit.thumbnailLabel"/>
      <input type="file" name="thumbnail" accept="image/*">
      <c:if test="${not empty news.image}">
        <small>
          <fmt:message key="admin.news.edit.currentImage"/>: ${news.image}
        </small>
      </c:if>
    </label>

    <label>
      <fmt:message key="admin.news.edit.contentLabel"/>
      <textarea id="content" name="content" rows="15"><c:out value="${news.content}" escapeXml="false"/></textarea>
    </label>

    <button type="submit" class="btn"><fmt:message key="admin.news.edit.save"/></button>
    <a class="btn ghost" href="${ctx}/admin/news"><fmt:message key="admin.common.cancel"/></a>
  </form>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  simpleUpload: { uploadUrl: '${ctx}/upload-image' }
}).catch(console.error);
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
