<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng bài mới - NewsPortal" />

<%@ include file="../layout/admin-header.jsp" %>

<!-- Main Content -->
<main class="modern-main-content">
    <div class="content-container">
        <!-- Page Header -->
        <div class="page-header">
            <div class="page-title-section">
                <h1 class="page-title">TRANG ĐĂNG BÀI MỚI</h1>
                <p class="page-subtitle">Tạo bài viết mới và chia sẻ thông tin</p>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/reporter/posts" class="btn-secondary">
                    <span class="btn-icon">←</span>
                    <span class="btn-text">Quay lại</span>
                </a>
            </div>
        </div>

        <!-- Form Section -->
        <div class="dashboard-section">
            <form method="post" action="${pageContext.request.contextPath}/reporter/post-create" enctype="multipart/form-data" class="modern-form">
                <div class="form-group">
                    <label for="title" class="form-label">Tiêu đề bài viết</label>
                    <input type="text" id="title" name="title" class="form-input" required 
                           placeholder="Nhập tiêu đề bài viết...">
                </div>

                <div class="form-group">
                    <label for="categoryId" class="form-label">Chuyên mục</label>
                    <select id="categoryId" name="categoryId" class="form-select" required>
                        <option value="">-- Chọn chuyên mục --</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.id}">${c.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="thumbnail" class="form-label">Ảnh đại diện (tùy chọn)</label>
                    <input type="file" id="thumbnail" name="thumbnail" class="form-file" accept="image/*">
                    <small class="form-help">Chọn ảnh JPG, PNG hoặc GIF (tối đa 10MB)</small>
                </div>

                <div class="form-group">
                    <label for="content" class="form-label">Nội dung bài viết</label>
                    <textarea id="content" name="content" class="form-textarea" rows="15" 
                              placeholder="Nhập nội dung bài viết..."></textarea>
                </div>

                <div class="form-group">
                    <div class="checkbox-wrapper">
                        <input type="checkbox" id="home" name="home" value="1">
                        <label for="home" class="checkbox-label">Đưa lên mục Trang chủ</label>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary">
                        <span class="btn-icon">📝</span>
                        <span class="btn-text">Đăng bài</span>
                    </button>
                    <a href="${pageContext.request.contextPath}/reporter/posts" class="btn-secondary">
                        <span class="btn-text">Hủy</span>
                    </a>
                </div>
            </form>
        </div>
    </div>
</main>



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

