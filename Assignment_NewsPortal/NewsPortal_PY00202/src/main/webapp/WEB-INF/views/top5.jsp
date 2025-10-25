<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- TODO: chỉnh path include cho đúng dự án của bạn --%>
<%@ include file="layout/header.jsp"%>

<div class="container">
<div class="main-content">
<div class="content-area">
  <section class="home-main">
    <div class="content">

      <h1 class="page-title">
        <c:out value="${empty pageTitle ? 'Top 5' : pageTitle}" />
      </h1>

      <c:if test="${empty items}">
        <div class="alert alert-info">Chưa có bài viết để hiển thị.</div>
      </c:if>

      <div class="news-list">
        <c:forEach var="n" items="${items}">
          <%-- XỬ LÝ ẢNH: chấp nhận link tuyệt đối (http...), bắt đầu bằng ctx/, bắt đầu /, hoặc đường dẫn tương đối --%>
          <c:set var="ctxSlash" value="${ctx}/" />
          <c:set var="img" value="${n.image}" />
          <c:choose>
            <c:when test="${empty img}">
              <c:set var="imgUrl" value="${ctx}/assets/img/sample.jpg" />
            </c:when>
            <c:when test="${fn:startsWith(img,'http')}">
              <c:set var="imgUrl" value="${img}" />
            </c:when>
            <c:when test="${fn:startsWith(img, ctxSlash)}">
              <c:set var="imgUrl" value="${img}" />
            </c:when>
            <c:when test="${fn:startsWith(img,'/')}">
              <c:set var="imgUrl" value="${ctx}${img}" />
            </c:when>
            <c:otherwise>
              <c:set var="imgUrl" value="${ctx}/${img}" />
            </c:otherwise>
          </c:choose>

          <%-- MỖI BÀI VIẾT --%>
          <article class="card post-row">
            <div class="post-content">
              <div class="post-image">
                <a href="${ctx}/news/${n.id}">
                  <img src="${imgUrl}" alt="${fn:escapeXml(n.title)}" loading="lazy" />
                </a>
              </div>

              <div class="post-text">
                <h2 class="card-title">
                  <a href="${ctx}/news/${n.id}">
                    <c:out value="${n.title}" />
                  </a>
                </h2>

                <p class="card-text small">
                  <c:choose>
                    <c:when test="${not empty n.postedDateFormatted}">
                      Đăng ngày: <c:out value="${n.postedDateFormatted}" />
                    </c:when>
                    <c:when test="${not empty n.postedDate}">
                      Đăng ngày:
                      <fmt:formatDate value="${n.postedDate}" pattern="dd/MM/yyyy HH:mm" />
                    </c:when>
                  </c:choose>
                  <c:if test="${not empty n.author}">
                    <span> | <c:out value="${n.author}" /></span>
                  </c:if>
                </p>

                <p class="card-text">
                  <c:out value="${n.excerpt}" />
                </p>
              </div>
            </div>
          </article>
        </c:forEach>
      </div>
    </div>
</div>
    <!-- SIDEBAR -->
		<aside class="sidebar-area">
			<jsp:include page="/WEB-INF/views/layout/sidebar-home.jsp" >
			<jsp:param name="mode" value="${mode}" />
			</jsp:include>
		</aside>
  </section>
</div>
</div>

<%@ include file="layout/footer.jsp"%>


