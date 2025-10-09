<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ include file="../layout/header.jsp"%>
<jsp:include page="../layout/reporter-sidebar.jsp"/>

<main class="container admin-main">
  <section class="content">
    <h1>Sửa bài viết</h1>

    <form class="card" method="post" action="${pageContext.request.contextPath}/reporter/post-edit" enctype="multipart/form-data">
      <input type="hidden" name="id" value="${news.id}">
      <label>Tiêu đề</label>
      <input class="input" name="title" required value="${news.title}">

      <label>Chuyên mục</label>
      <select class="input" name="categoryId" required>
        <c:forEach var="c" items="${categories}">
          <option value="${c.id}" ${c.id == news.categoryId ? 'selected' : ''}>${c.name}</option>
        </c:forEach>
      </select>

      <label>Ảnh đại diện (để trống nếu không đổi)</label>
      <input class="input" type="file" name="thumbnail" accept="image/*">
      <c:if test="${not empty news.image}">
        <small>Ảnh hiện tại: ${news.image}</small>
      </c:if>

      <label>Nội dung</label>
      <textarea id="content" class="input" name="content" rows="15"><c:out value="${news.content}" escapeXml="false"/></textarea>

      <label class="row mt-12">
        <input type="checkbox" name="home" value="1" ${news.home ? 'checked' : ''}> Hiển thị Trang chủ
      </label>

      <div class="actions">
        <button class="btn" type="submit">Lưu</button>
        <a class="btn ghost" href="${pageContext.request.contextPath}/reporter/news">Huỷ</a>
      </div>
    </form>
  </section>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  simpleUpload: { uploadUrl: '${pageContext.request.contextPath}/upload-image' }
}).catch(console.error);
</script>

<%@ include file="../layout/footer.jsp"%>
