<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="layout/header.jsp" %>

<main class="container grid">
  <section class="content">
    <h1>Tìm kiếm</h1>
    
    <!-- Search Form -->
    <form class="searchbar" action="${pageContext.request.contextPath}/search" method="get">
      <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Nhập từ khóa tìm kiếm..." autofocus>
      <button class="btn" type="submit">
        <i class="icon-search"></i> Tìm kiếm
      </button>
    </form>

    <!-- Search Results -->
    <c:if test="${not empty q}">
      <div class="search-info">
        <h2>Kết quả tìm kiếm cho: "<strong><c:out value="${q}"/></strong>"</h2>
        <p class="result-count">
          <c:choose>
            <c:when test="${resultCount == 0}">
              Không tìm thấy kết quả nào
            </c:when>
            <c:when test="${resultCount == 1}">
              Tìm thấy 1 kết quả
            </c:when>
            <c:otherwise>
              Tìm thấy ${resultCount} kết quả
            </c:otherwise>
          </c:choose>
        </p>
      </div>

      <div class="search-results">
        <c:choose>
          <c:when test="${not empty results}">
            <c:forEach var="news" items="${results}">
              <article class="search-result-item">
                <h3 class="result-title">
                  <a href="${pageContext.request.contextPath}/news/${news.id}">
                    <c:out value="${news.title}"/>
                  </a>
                </h3>
                
                <div class="result-meta">
                  <span class="result-date">${news.postedDate}</span>
                  <span class="result-author">Tác giả: ${news.author}</span>
                  <span class="result-views">${news.viewCount} lượt xem</span>
                </div>
                
                <div class="result-excerpt">
                  <c:set var="content" value="${fn:replace(news.content, '<[^>]*>', '')}" />
                  <c:choose>
                    <c:when test="${fn:length(content) > 200}">
                      <c:out value="${fn:substring(content, 0, 200)}"/>...
                    </c:when>
                    <c:otherwise>
                      <c:out value="${content}"/>
                    </c:otherwise>
                  </c:choose>
                </div>
                
                <div class="result-link">
                  <a href="${pageContext.request.contextPath}/news/${news.id}" class="read-more">
                    Đọc tiếp →
                  </a>
                </div>
              </article>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div class="no-results">
              <h3>Không tìm thấy kết quả</h3>
              <p>Không có bài viết nào phù hợp với từ khóa "<strong><c:out value="${q}"/></strong>"</p>
              <div class="search-suggestions">
                <h4>Gợi ý:</h4>
                <ul>
                  <li>Kiểm tra lại chính tả từ khóa</li>
                  <li>Thử sử dụng từ khóa khác</li>
                  <li>Sử dụng từ khóa ngắn gọn hơn</li>
                  <li>Tìm kiếm theo chuyên mục cụ thể</li>
                </ul>
              </div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <!-- Show message if no search query -->
    <c:if test="${empty q}">
      <div class="search-welcome">
        <h2>Tìm kiếm bài viết</h2>
        <p>Nhập từ khóa vào ô tìm kiếm để tìm các bài viết phù hợp.</p>
        
        <div class="search-tips">
          <h3>Mẹo tìm kiếm:</h3>
          <ul>
            <li>Sử dụng từ khóa cụ thể để có kết quả chính xác hơn</li>
            <li>Có thể tìm kiếm theo tiêu đề hoặc nội dung bài viết</li>
            <li>Thử các từ đồng nghĩa nếu không tìm thấy kết quả</li>
          </ul>
        </div>
      </div>
    </c:if>

    <!-- Display error if any -->
    <c:if test="${not empty error}">
      <div class="alert error">
        <c:out value="${error}"/>
      </div>
    </c:if>
  </section>

  <aside><jsp:include page="layout/sidebar.jsp"/></aside>
</main>

<%@ include file="layout/footer.jsp" %>
