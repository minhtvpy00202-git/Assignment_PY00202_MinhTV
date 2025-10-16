<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>


<jsp:include page="../layout/admin-header.jsp"/>

<main class="container admin-page">
  <h2>Sửa bài viết</h2>

  <form class="form" method="post" action="${pageContext.request.contextPath}/reporter/post-edit" enctype="multipart/form-data">
    <input type="hidden" name="id" value="${news.id}">
    
    <label>Tiêu đề
      <input name="title" required value="${news.title}">
    </label>

    <label>Chuyên mục
      <select name="categoryId" required>
        <c:forEach var="c" items="${categories}">
          <option value="${c.id}" ${c.id == news.categoryId ? 'selected' : ''}>${c.name}</option>
        </c:forEach>
      </select>
    </label>

    <label>Ảnh đại diện (để trống nếu không đổi)
      <input type="file" name="thumbnail" accept="image/*">
      <c:if test="${not empty news.image}">
        <small>Ảnh hiện tại: ${news.image}</small>
      </c:if>
    </label>

    <label>Nội dung
      <textarea id="content" name="content" rows="15"><c:out value="${news.content}" escapeXml="false"/></textarea>
    </label>

    <label>
      <input type="checkbox" name="home" value="1" ${news.home ? 'checked' : ''}> 
      Hiển thị Trang chủ
    </label>

    <button type="submit" class="btn">Lưu</button>
    <a class="btn ghost" href="${pageContext.request.contextPath}/reporter/posts">Hủy</a>
  </form>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  simpleUpload: { uploadUrl: '${pageContext.request.contextPath}/upload-image' }
}).catch(console.error);
</script>

<%@ include file="../layout/footer.jsp"%>
