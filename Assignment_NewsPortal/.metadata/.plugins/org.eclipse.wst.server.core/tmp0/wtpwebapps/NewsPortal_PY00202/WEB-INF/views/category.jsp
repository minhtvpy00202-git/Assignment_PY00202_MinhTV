<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%@ include file="layout/header.jsp" %>

<main class="container grid">
  <!-- CỘT TRÁI -->
  <section class="content">
    <h1>Chuyên mục: <c:out value="${currentCategory.name}"/></h1>

    <c:choose>
      <c:when test="${empty news}">
        <div class="card" style="padding:16px;">Chưa có bài viết nào trong chuyên mục này.</div>
      </c:when>

      <c:otherwise>
        <div class="list-posts">
          <c:forEach var="n" items="${news}">
            <!-- Biến tiện ích -->
            <c:set var="ctx" value="${pageContext.request.contextPath}"/>
            <c:set var="ctxSlash" value="${ctx}/"/>
            <c:set var="img" value="${n.image}"/>

            <!-- Build URL ảnh an toàn bằng JSTL (không gọi method Java trong EL) -->
            <c:choose>
              
              <c:when test="${empty img}">
                <c:set var="imgUrl" value="${ctx}/assets/img/sample.jpg"/>
              </c:when>
            
              <c:when test="${fn:startsWith(img,'http')}">
                <c:set var="imgUrl" value="${img}"/>
              </c:when>
             
              <c:when test="${fn:startsWith(img, ctxSlash)}">
                <c:set var="imgUrl" value="${img}"/>
              </c:when>
             
              <c:when test="${fn:startsWith(img,'/')}">
                <c:set var="imgUrl" value="${ctx}${img}"/>
              </c:when>
             
              <c:otherwise>
                <c:set var="imgUrl" value="${ctx}/${img}"/>
              </c:otherwise>
            </c:choose>

            <!-- Rút gọn nội dung an toàn -->
            <c:set var="excerpt" value="${n.content}"/>
            <c:if test="${fn:length(excerpt) > 180}">
              <c:set var="excerpt" value="${fn:substring(excerpt,0,180)}..."/>
            </c:if>

            <article class="card post-row">
              <a class="thumb" href="${ctx}/news/${n.id}">
                <img src="${imgUrl}" alt="${fn:escapeXml(n.title)}" loading="lazy">
              </a>

              <div class="body">
                <h3 class="title">
                  <a href="${ctx}/news/${n.id}">
                    <c:out value="${n.title}"/>
                  </a>
                </h3>

                <p class="excerpt">
                  <c:out value="${excerpt}" escapeXml="false"/>
                </p>

                <div class="meta">
                  <span>${n.viewCount} lượt xem</span>
                  <c:if test="${not empty n.postedDate}">
                    <span>• ${n.postedDate}</span>
                  </c:if>
                </div>
              </div>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <!-- Phân trang (nếu controller set page & totalPages) -->
    <c:if test="${not empty page && not empty totalPages && totalPages > 1}">
      <nav class="pagination">
        <c:set var="baseUrl" value='${pageContext.request.contextPath}/category?id=${currentCategory.id}'/>
        <a class="page ${page==1 ? 'disabled' : ''}" href="${baseUrl}&page=${page-1}">Trước</a>

        <c:forEach var="i" begin="1" end="${totalPages}">
          <a class="page ${i==page ? 'active' : ''}" href="${baseUrl}&page=${i}">${i}</a>
        </c:forEach>

        <a class="page ${page==totalPages ? 'disabled' : ''}" href="${baseUrl}&page=${page+1}">Sau</a>
      </nav>
    </c:if>
  </section>

  <!-- CỘT PHẢI -->
  <aside>
    <jsp:include page="layout/sidebar.jsp"/>
  </aside>
</main>

<%@ include file="layout/footer.jsp" %>
