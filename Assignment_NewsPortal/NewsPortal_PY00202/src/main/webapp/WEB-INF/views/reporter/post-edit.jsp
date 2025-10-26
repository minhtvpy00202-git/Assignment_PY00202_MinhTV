<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<jsp:include page="../layout/admin-header.jsp"/>

<main class="container admin-page">
  <h2><fmt:message key="reporter.edit.title"/></h2>

  <form class="form" method="post"
        action="${pageContext.request.contextPath}/reporter/post-edit"
        enctype="multipart/form-data">
    <input type="hidden" name="id" value="${news.id}">

    <label><fmt:message key="reporter.form.title"/>
      <input name="title" required value="${news.title}">
    </label>

    <label><fmt:message key="reporter.form.category"/>
      <select name="categoryId" required>
        <c:forEach var="c" items="${categories}">
          <option value="${c.id}" ${c.id == news.categoryId ? 'selected' : ''}>${c.name}</option>
        </c:forEach>
      </select>
    </label>

    <label><fmt:message key="reporter.form.thumbnail.editNote"/>
      <input type="file" name="thumbnail" accept="image/*">
      <c:if test="${not empty news.image}">
        <small><fmt:message key="reporter.form.thumbnail.current"/>: ${news.image}</small>
      </c:if>
    </label>

    <label><fmt:message key="reporter.form.content"/>
      <textarea id="content" name="content" rows="15">
        <c:out value="${news.content}" escapeXml="false"/>
      </textarea>
    </label>

    <button type="submit" class="btn"><fmt:message key="reporter.edit.save"/></button>
    <a class="btn ghost" href="${pageContext.request.contextPath}/reporter/posts">
      <fmt:message key="admin.common.cancel"/>
    </a>
  </form>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  simpleUpload: { uploadUrl: '${pageContext.request.contextPath}/upload-image' }
}).catch(console.error);
</script>

<%@ include file="../layout/footer.jsp"%>
