<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

      <%@ include file="layout/header.jsp" %>

        <div class="home-wrap">
          <div class="home-grid">
            <!-- CỘT TRÁI -->
            <section class="home-main">
              <div class="content">
                <h1>Chuyên mục:
                  <c:out value="${currentCategory.name}" />
                </h1>

                <c:choose>
                  <c:when test="${empty news}">
                    <div class="empty-message">Chưa có bài viết nào trong chuyên mục này.</div>
                  </c:when>
                  <c:otherwise>
                    <div class="news-list">
                      <c:forEach var="n" items="${news}">
                        <!-- Biến tiện ích -->
                        <c:set var="ctx" value="${pageContext.request.contextPath}" />
                        <c:set var="ctxSlash" value="${ctx}/" />
                        <c:set var="img" value="${n.image}" />

                        <!-- Build URL ảnh an toàn -->
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

                        <!-- Rút gọn nội dung -->
                        <c:set var="excerpt" value="${n.content}" />
                        <c:if test="${fn:length(excerpt) > 160}">
                          <c:set var="excerpt" value="${fn:substring(excerpt,0,160)}..." />
                        </c:if>

                        <!-- Item -->
                        <article class="post-row">
                          <a class="thumb" href="${ctx}/news/${n.id}">
                            <img src="${imgUrl}" alt="${fn:escapeXml(n.title)}" loading="lazy">
                          </a>
                          <div class="body">
                            <h3 class="title">
                              <a href="${ctx}/news/${n.id}">
                                <c:out value="${n.title}" />
                              </a>
                            </h3>
                            <p class="excerpt">
                              <c:out value="${excerpt}" escapeXml="false" />
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

                <!-- Phân trang -->
                <c:if test="${not empty page && not empty totalPages && totalPages > 1}">
                  <nav class="pagination">
                    <c:set var="baseUrl" value='${pageContext.request.contextPath}/category?id=${currentCategory.id}' />
                    <a class="page ${page==1 ? 'disabled' : ''}" href="${baseUrl}&page=${page-1}">Trước</a>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                      <a class="page ${i==page ? 'active' : ''}" href="${baseUrl}&page=${i}">${i}</a>
                    </c:forEach>
                    <a class="page ${page==totalPages ? 'disabled' : ''}" href="${baseUrl}&page=${page+1}">Sau</a>
                  </nav>
                </c:if>
              </div>
            </section>

            <!-- CỘT PHẢI -->
            <aside>
              <jsp:include page="layout/sidebar.jsp" />
            </aside>
          </div>
        </div>

        <style>
          /* Category page specific styles */
          .content h1 {
            font-size: 1.8rem;
            color: var(--text);
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 3px solid var(--brand);
            font-weight: 700;
          }

          .empty-message {
            text-align: center;
            padding: 3rem 2rem;
            color: var(--muted);
            font-size: 1.1rem;
            background: var(--surface-2);
            border-radius: var(--radius);
            border: var(--border);
          }

          /* Pagination styles */
          .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: var(--border);
          }

          .pagination .page {
            padding: 0.75rem 1rem;
            background: var(--surface);
            border: var(--border);
            border-radius: 8px;
            text-decoration: none;
            color: var(--text);
            transition: all 0.3s ease;
            min-width: 44px;
            text-align: center;
            font-weight: 500;
          }

          .pagination .page:hover:not(.disabled) {
            background: var(--brand);
            color: white;
            border-color: var(--brand);
            transform: translateY(-1px);
          }

          .pagination .page.active {
            background: var(--brand);
            color: white;
            border-color: var(--brand);
          }

          .pagination .page.disabled {
            opacity: 0.5;
            cursor: not-allowed;
          }

          /* Mobile responsive */
          @media (max-width: 768px) {
            .content h1 {
              font-size: 1.4rem;
              text-align: center;
            }

            .post-row {
              grid-template-columns: 1fr;
              gap: 12px;
            }

            .post-row .thumb img {
              height: 200px;
            }

            .pagination {
              flex-wrap: wrap;
              gap: 0.25rem;
            }

            .pagination .page {
              padding: 0.5rem 0.75rem;
              font-size: 0.875rem;
            }

            .empty-message {
              padding: 2rem 1rem;
              font-size: 1rem;
            }
          }

          @media (max-width: 480px) {
            .home-grid {
              gap: 12px;
            }

            .home-main {
              padding: 16px;
            }

            .content h1 {
              font-size: 1.2rem;
              margin-bottom: 1rem;
            }

            .post-row {
              padding: 12px;
            }

            .post-row .title {
              font-size: 1rem;
            }

            .post-row .excerpt {
              font-size: 0.85rem;
            }
          }
        </style>

        <%@ include file="layout/footer.jsp" %>