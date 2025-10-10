<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">
<jsp:include page="../layout/reporter-sidebar.jsp"/>

<main class="container admin-page">
  <h2>Đăng bài mới</h2>

  <form method="post" action="${pageContext.request.contextPath}/reporter/post-create" enctype="multipart/form-data" class="form">
    <label>Tiêu đề
      <input type="text" name="title" required>
    </label>

    <label>Chuyên mục
      <select name="categoryId" required>
        <c:forEach var="c" items="${categories}">
          <option value="${c.id}">${c.name}</option>
        </c:forEach>
      </select>
    </label>

    <label>Ảnh đại diện (tùy chọn)
      <input type="file" name="thumbnail" accept="image/*">
    </label>

    <label>Nội dung
      <textarea id="content" name="content" rows="15"></textarea>
    </label>

    <label style="display: flex; align-items: center; gap: 8px;">
      <input type="checkbox" name="home" value="1" style="width: auto;"> 
      Đưa lên mục Trang chủ
    </label>

    <button type="submit" class="btn">Đăng bài</button>
    <a class="btn ghost" href="${pageContext.request.contextPath}/reporter/posts">Hủy</a>
  </form>
</main>

<!-- CKEditor5 classic build -->
<style>
  .ck-editor__editable[role="textbox"]{ min-height:560px; }
</style>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  toolbar: [
    'heading','|',
    'bold','italic','underline','link',
    'bulletedList','numberedList','blockQuote','insertTable','|',
    'insertImage','imageUpload','mediaEmbed','|',
    'undo','redo'
  ],

  /* DÙNG simpleUpload adapter */
  simpleUpload: {
    uploadUrl: '${pageContext.request.contextPath}/upload-image',
    withCredentials: false
    // headers: { 'X-Requested-With':'XMLHttpRequest' }  // nếu cần
  },

  image: {
    toolbar: [
      'imageTextAlternative', '|',
      'imageStyle:inline', 'imageStyle:block', 'imageStyle:side'
    ]
  }
}).catch(console.error);
</script>

<%@ include file="../layout/footer.jsp" %>

