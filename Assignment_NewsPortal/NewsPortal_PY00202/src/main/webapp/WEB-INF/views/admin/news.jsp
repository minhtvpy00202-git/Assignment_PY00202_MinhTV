<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%@ include file="../layout/admin-header.jsp" %>

<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1>QUẢN LÝ TIN TỨC</h1>
      <p>Thêm, sửa, xóa và quản lý các bài tin tức</p>
    </div>

    

    <!-- Danh sách tin tức -->
    <div id="list" class="table-section">
      <h2>DANH SÁCH TIN</h2>
      
      <!-- Bộ lọc / Tìm kiếm -->
		<form class="table-tools" method="get" action="${ctx}/admin/news#list">
		  <div class="tools-row">
		    <select class="form-select" name="cat" aria-label="Lọc theo loại tin">
		      <option value="0">Tất cả loại tin</option>
		      <c:forEach var="c" items="${categories}">
		        <option value="${c.id}" ${param.cat == c.id ? 'selected' : (cat==c.id?'selected':'')}>
		          ${c.name}
		        </option>
		      </c:forEach>
		    </select>
		
		    <input class="form-control" name="q" placeholder="Tìm theo tiêu đề…"
		           value="${q}" />
		
		    <button type="submit" class="btn btn-primary">Tìm</button>
		    <a class="btn btn-outline-primary" href="${ctx}/admin/news">Xóa lọc</a>
		  </div>
		</form>
      
      
      <div class="table-wrapper">
        <table class="table">
          <thead>
            <tr>
              <th>STT</th>
              
              <th>Ngày đăng</th>
              <th>Tiêu đề</th>
              <th>Loại tin</th>
              <th>Số lượt xem</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="n" items="${items}" varStatus="status">
              <tr>
                <td>${status.index + 1}</td>
                
                <td class="date-cell">
				  <c:choose>
				    <c:when test="${not empty n.postedDate}">
				      <fmt:parseDate
				        value="${fn:contains(n.postedDate, '.') ? fn:split(n.postedDate, '.')[0] : n.postedDate}"
				        pattern="yyyy-MM-dd'T'HH:mm:ss"
				        var="pd" />
				      <fmt:formatDate value="${pd}" pattern="dd/MM/yyyy" />
				    </c:when>
				    <c:otherwise>-</c:otherwise>
				  </c:choose>
				</td>

                
                <td class="title-cell">
                  <c:out value="${n.title}" />
                </td>
                <td>
                  <c:forEach var="c" items="${categories}">
                    <c:if test="${c.id == n.categoryId}">
                      <span class="category-badge">${c.name}</span>
                    </c:if>
                  </c:forEach>
                </td>
                <td>
                	<c:out value="${n.viewCount}" />
                </td>
                <td class="actions">
                  <a class="btn btn-outline-primary" href="${ctx}/admin/news-edit?id=${n.id}">Sửa</a>
                  <form method="post" action="${ctx}/admin/news"
                    onsubmit="return confirm('Xóa tin tức này?');">
                    <input type="hidden" name="action" value="delete" />
                    <input type="hidden" name="id" value="${n.id}" />
                    <button type="submit" class="btn btn-danger">Xóa</button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
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
  simpleUpload: {
    uploadUrl: '${ctx}/upload-image',
    withCredentials: false
  },
  image: {
    toolbar: [
      'imageTextAlternative', '|',
      'imageStyle:inline', 'imageStyle:block', 'imageStyle:side'
    ]
  }
}).catch(console.error);
</script>



<jsp:include page="/WEB-INF/views/layout/footer.jsp" />