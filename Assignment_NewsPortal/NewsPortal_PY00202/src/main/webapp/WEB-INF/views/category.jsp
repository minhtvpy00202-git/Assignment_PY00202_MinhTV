<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%@ include file="layout/header.jsp" %>

<div class="container">
  <div class="main-content">
    <!-- CONTENT AREA -->
    <section class="content-area">
      <div class="category-header">
        <!-- Chuyên mục: {name} -->
        <h1>
          <fmt:message key="category.title">
            <fmt:param value="${currentCategory.name}"/>
          </fmt:message>
        </h1>
      </div>

      <c:choose>
        <c:when test="${empty news}">
          <!-- Chưa có bài viết nào trong chuyên mục này. -->
          <div class="alert alert-info">
            <fmt:message key="category.empty"/>
          </div>
        </c:when>
        <c:otherwise>
          <div class="news-list">
            <c:forEach var="n" items="${news}">
              <!-- Biến tiện ích -->
              <c:set var="ctx" value="${pageContext.request.contextPath}" />

              <!-- Chuẩn hoá URL ảnh -->
              <c:set var="img" value="${n.image}" />
              <c:if test="${empty img}">
                <c:set var="img" value="/assets/img/sample.jpg" />
              </c:if>
              <c:choose>
                <c:when test="${fn:startsWith(img,'http://') || fn:startsWith(img,'https://')}">
                  <c:set var="imgUrl" value="${img}" />
                </c:when>
                <c:otherwise>
                  <c:choose>
                    <c:when test="${fn:startsWith(img,'/')}">
                      <c:set var="imgPath" value="${img}" />
                    </c:when>
                    <c:otherwise>
                      <c:set var="imgPath" value="/${img}" />
                    </c:otherwise>
                  </c:choose>
                  <c:url var="imgUrl" value="${imgPath}" />
                </c:otherwise>
              </c:choose>

              <!-- ITEM -->
              <article class="card post-row">
                <div class="post-content">
                  <div class="post-image">
                    <a href="${ctx}/news/${n.id}">
                      <img src="${imgUrl}" alt="<c:out value='${n.title}'/>">
                    </a>
                  </div>
                  <div class="post-text">
                    <h2 class="card-title">
                      <a href="${ctx}/news/${n.id}">
                        <c:out value="${n.title}" />
                      </a>
                    </h2>

                    <p class="card-text small">
                      <c:if test="${n.author != null}">
                        <span>
                          <!-- Đăng bởi: -->
                          | <fmt:message key="news.by"/>:
                          <c:out value="${n.author}"/>
                        </span>
                      </c:if>

                      <c:if test="${n.postedDate != null}">
                        <fmt:parseDate value="${n.postedDate}"
                                       pattern="yyyy-MM-dd'T'HH:mm:ss" var="pd"/>
                        <span>
                          <!-- Đăng ngày: dd/MM/yyyy -->
                          | <fmt:message key="news.published"/>:
                          <fmt:formatDate value="${pd}" pattern="dd/MM/yyyy"/>
                        </span>
                      </c:if>

                      <span>
                        <!-- {0} lượt xem -->
                        | <fmt:message key="news.views">
                            <fmt:param value="${n.viewCount}"/>
                          </fmt:message>
                      </span>
                    </p>

                    <p class="card-text"><c:out value="${n.excerpt}" /></p>
                  </div>
                </div>
              </article>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>

      <!-- PHÂN TRANG -->
      <c:if test="${not empty page && not empty totalPages && totalPages > 1}">
        <c:set var="baseUrl" value='${pageContext.request.contextPath}/category?id=${currentCategory.id}' />
        <div class="pagination-wrapper">
          <div class="pagination">
            <c:if test="${page > 1}">
              <a class="page-link" href="${baseUrl}&page=${page-1}">
                ← <fmt:message key="category.pager.prev"/>
              </a>
            </c:if>

            <c:forEach var="i" begin="1" end="${totalPages}">
              <a class="page-link ${i==page ? 'active' : ''}" href="${baseUrl}&page=${i}">${i}</a>
            </c:forEach>

            <c:if test="${page < totalPages}">
              <a class="page-link" href="${baseUrl}&page=${page+1}">
                <fmt:message key="category.pager.next"/> →
              </a>
            </c:if>
          </div>
        </div>
      </c:if>
    </section>

    <!-- SIDEBAR -->
    <aside class="sidebar-area">
      <jsp:include page="layout/sidebar-home.jsp" />
    </aside>
  </div>
</div>

<%@ include file="layout/footer.jsp" %>
