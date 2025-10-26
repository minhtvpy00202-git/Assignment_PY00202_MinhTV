<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Create Post - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<main class="modern-main-content">
  <div class="content-container">
    <div class="page-header">
      <div class="page-title-section">
        <h1 class="page-title"><fmt:message key="reporter.create.title"/></h1>
        <p class="page-subtitle"><fmt:message key="reporter.create.subtitle"/></p>
      </div>
      <div class="page-actions">
        <a href="${pageContext.request.contextPath}/reporter/posts" class="btn-secondary">
          <span class="btn-icon">←</span>
          <span class="btn-text"><fmt:message key="common.back"/></span>
        </a>
      </div>
    </div>

    <div class="dashboard-section">
      <form method="post" action="${pageContext.request.contextPath}/reporter/post-create"
            enctype="multipart/form-data" class="modern-form">
        <div class="form-group">
          <label for="title" class="form-label"><fmt:message key="reporter.form.title"/></label>
          <input type="text" id="title" name="title" class="form-input" required
                 placeholder="<fmt:message key='reporter.form.title.placeholder'/>">
        </div>

        <div class="form-group">
          <label for="categoryId" class="form-label"><fmt:message key="reporter.form.category"/></label>
          <select id="categoryId" name="categoryId" class="form-select" required>
            <option value=""><fmt:message key="reporter.form.category.choose"/></option>
            <c:forEach var="c" items="${categories}">
              <option value="${c.id}">${c.name}</option>
            </c:forEach>
          </select>
        </div>

        <div class="form-group">
          <label for="thumbnail" class="form-label"><fmt:message key="reporter.form.thumbnail"/></label>
          <input type="file" id="thumbnail" name="thumbnail" class="form-file" accept="image/*">
          <small class="form-help"><fmt:message key="reporter.form.thumbnail.help"/></small>
        </div>

        <div class="form-group">
          <label for="content" class="form-label"><fmt:message key="reporter.form.content"/></label>
          <textarea id="content" name="content" class="form-textarea" rows="15"
                    placeholder="<fmt:message key='reporter.form.content.placeholder'/>"></textarea>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-primary">
            <span class="btn-icon">📝</span>
            <span class="btn-text"><fmt:message key="reporter.create.submit"/></span>
          </button>
          <a href="${pageContext.request.contextPath}/reporter/posts" class="btn-secondary">
            <span class="btn-text"><fmt:message key="admin.common.cancel"/></span>
          </a>
        </div>
      </form>
    </div>
  </div>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  toolbar: ['heading','|','bold','italic','underline','link','bulletedList','numberedList',
            'blockQuote','insertTable','|','insertImage','imageUpload','mediaEmbed','|','undo','redo'],
  simpleUpload: { uploadUrl: '${pageContext.request.contextPath}/upload-image', withCredentials: false },
  image: { toolbar: ['imageTextAlternative','|','imageStyle:inline','imageStyle:block','imageStyle:side'] }
}).catch(console.error);
</script>

<%@ include file="../layout/footer.jsp" %>
