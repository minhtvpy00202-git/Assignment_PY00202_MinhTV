<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="layout/header.jsp"%>

<main class="container">
  <div class="main-content">
    <section class="content-area">
      <div class="search-header">
        <h1><fmt:message key="search.page.title"/></h1>
        <p><fmt:message key="search.page.subtitle"/></p>
      </div>

      <!-- Search Form -->
      <form class="search-form-main" action="${pageContext.request.contextPath}/search" method="get">
        <div class="search-input-group">
          <input class="form-control" type="text" name="q"
                 value="<c:out value='${q}'/>"
                 placeholder="<fmt:message key='search.placeholder'/>" autofocus>
          <button class="btn btn-primary" type="submit">
            <fmt:message key="search.button"/>
          </button>
        </div>
      </form>

      <!-- Search Results -->
      <c:if test="${not empty q}">
        <div class="search-info">
          <c:if test="${resultCount > 0}">
            <h2>
              <fmt:message key="search.resultsFor">
                <fmt:param value="${q}"/>
              </fmt:message>
            </h2>
            <p class="result-count">
              <c:choose>
                <c:when test="${resultCount == 1}">
                  <fmt:message key="search.found.one"/>
                </c:when>
                <c:otherwise>
                  <fmt:message key="search.found.many">
                    <fmt:param value="${resultCount}"/>
                  </fmt:message>
                </c:otherwise>
              </c:choose>
            </p>
          </c:if>
        </div>

        <hr style="margin-top:0">

        <div class="search-results">
          <c:choose>
            <c:when test="${not empty results}">
              <c:forEach var="news" items="${results}">
                <article class="search-result">
                  <h3 class="result-title">
                    <a href="${pageContext.request.contextPath}/news/${news.id}">
                      <c:out value="${news.title}" />
                    </a>
                  </h3>

                  <div class="result-meta">
                    <span>
                      <fmt:message key="news.published"/>:
                      <c:out value="${news.postedDateFormatted}" />
                    </span>
                    <c:if test="${not empty news.author}">
                      <span> • <fmt:message key="news.by"/>:
                        <c:out value="${news.author}" />
                      </span>
                    </c:if>
                    <span> •
                      <fmt:message key="news.views">
                        <fmt:param value="${news.viewCount}"/>
                      </fmt:message>
                    </span>
                  </div>

                  <div class="result-excerpt">
                    <c:out value="${news.excerpt}" />
                  </div>
                </article>
              </c:forEach>

              <!-- PHÂN TRANG -->
              <c:if test="${totalPages > 1}">
                <c:url var="base" value="/search">
                  <c:param name="q" value="${q}" />
                  <c:param name="size" value="${size}" />
                </c:url>
                <nav class="pager" style="margin-top:20px;display:flex;gap:8px;justify-content:center;">
                  <a class="btn ghost" href="${base}&page=1"
                     ${page==1?'style="pointer-events:none;opacity:.5"':''}>
                    <fmt:message key="pager.first"/>
                  </a>
                  <a class="btn ghost" href="${base}&page=${page-1}"
                     ${page==1?'style="pointer-events:none;opacity:.5"':''}>
                    <fmt:message key="pager.prev"/>
                  </a>
                  <span class="btn" style="pointer-events:none;">
                    <fmt:message key="pager.pageOf">
                      <fmt:param value="${page}"/>
                      <fmt:param value="${totalPages}"/>
                      <fmt:param value="${resultCount}"/>
                    </fmt:message>
                  </span>
                  <a class="btn ghost" href="${base}&page=${page+1}"
                     ${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>
                    <fmt:message key="pager.next"/>
                  </a>
                  <a class="btn ghost" href="${base}&page=${totalPages}"
                     ${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>
                    <fmt:message key="pager.last"/>
                  </a>
                </nav>
              </c:if>
            </c:when>

            <c:otherwise>
              <div class="no-results">
                <h3><fmt:message key="search.noResults.title"/></h3>
                <p>
                  <fmt:message key="search.noResults.desc">
                    <fmt:param value="${q}"/>
                  </fmt:message>
                </p>
                <div class="search-suggestions"></div>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </c:if>

      <!-- Display error if any -->
      <c:if test="${not empty error}">
        <div class="alert error"><c:out value="${error}" /></div>
      </c:if>
    </section>

    <aside class="sidebar-area">
      <jsp:include page="/WEB-INF/views/layout/sidebar-home.jsp" />
   
    </aside>
  </div>
</main>

<%@ include file="layout/footer.jsp"%>
