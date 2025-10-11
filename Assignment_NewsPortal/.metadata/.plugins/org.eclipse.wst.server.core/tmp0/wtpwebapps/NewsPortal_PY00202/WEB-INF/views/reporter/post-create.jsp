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
                <h1 class="page-title">Đăng bài mới</h1>
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

<style>
/* Modern Form Styles */
.modern-main-content {
    min-height: calc(100vh - 70px);
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    padding: 2rem 0;
}

.content-container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 0 2rem;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 3rem;
    background: white;
    padding: 2rem;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

.page-title {
    font-size: 2.5rem;
    font-weight: 700;
    color: #2d3748;
    margin: 0 0 0.5rem 0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.page-subtitle {
    color: #718096;
    font-size: 1.1rem;
    margin: 0;
}

.btn-secondary {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    background: #f8fafc;
    color: #4a5568;
    padding: 1rem 2rem;
    border-radius: 12px;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.3s ease;
    border: 1px solid #e2e8f0;
}

.btn-secondary:hover {
    background: #e2e8f0;
    transform: translateY(-1px);
}

.dashboard-section {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

.modern-form {
    display: flex;
    flex-direction: column;
    gap: 2rem;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.form-label {
    font-weight: 600;
    color: #2d3748;
    font-size: 1rem;
}

.form-input, .form-select, .form-textarea {
    padding: 1rem;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #f8fafc;
}

.form-input:focus, .form-select:focus, .form-textarea:focus {
    outline: none;
    border-color: #667eea;
    background: white;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-file {
    padding: 0.75rem;
    border: 2px dashed #e2e8f0;
    border-radius: 8px;
    background: #f8fafc;
    cursor: pointer;
    transition: all 0.3s ease;
}

.form-file:hover {
    border-color: #667eea;
    background: white;
}

.form-help {
    color: #718096;
    font-size: 0.875rem;
    margin-top: 0.25rem;
}

.checkbox-wrapper {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem;
    background: #f8fafc;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
}

.checkbox-wrapper input[type="checkbox"] {
    width: 20px;
    height: 20px;
    margin: 0;
    cursor: pointer;
    accent-color: #667eea;
}

.checkbox-wrapper .checkbox-label {
    margin: 0;
    cursor: pointer;
    font-weight: 500;
    color: #2d3748;
    user-select: none;
}

.form-actions {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
    padding-top: 1rem;
    border-top: 1px solid #e2e8f0;
}

.btn-primary {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem 2rem;
    border-radius: 12px;
    border: none;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
}

/* CKEditor5 styling */
.ck-editor__editable[role="textbox"] { 
    min-height: 400px;
    border-radius: 8px;
}

.ck-editor {
    border-radius: 8px;
    overflow: hidden;
}

/* Mobile responsive */
@media (max-width: 768px) {
    .content-container {
        padding: 0 1rem;
    }
    
    .page-header {
        flex-direction: column;
        gap: 1.5rem;
        align-items: stretch;
        padding: 1.5rem;
    }
    
    .page-title {
        font-size: 2rem;
        text-align: center;
    }
    
    .page-subtitle {
        text-align: center;
    }
    
    .dashboard-section {
        padding: 1.5rem;
    }
    
    .form-actions {
        flex-direction: column;
    }
    
    .btn-primary, .btn-secondary {
        justify-content: center;
        width: 100%;
    }
}
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

