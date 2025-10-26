<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp"%>

<style>
.badge-home{display:inline-block;padding:2px 8px;margin-left:6px;border:1px solid #22c55e;border-radius:999px;font-size:.75rem;color:#166534;background:#dcfce7;font-weight:600;}
.badge-approved{display:inline-block;padding:2px 8px;margin-left:6px;border:1px solid #3b82f6;border-radius:999px;font-size:.75rem;color:#1d4ed8;background:#dbeafe;font-weight:600;}
.btn-xs{padding:.25rem .5rem;font-size:.8rem;}
</style>

<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1><fmt:message key="admin.news.pageTitle"/></h1>
      <p><fmt:message key="admin.news.pageSubtitle"/></p>

      <div class="page-actions" style="flex:0 0 auto;">
        <a class="btn btn-primary" href="${ctx}/reporter/post-create">
          + <fmt:message key="admin.news.newPost"/>
        </a>
      </div>
    </div>

    <div id="list" class="table-section">
      <h2><fmt:message key="admin.news.listTitle"/></h2>

      <!-- Filters -->
      <form class="table-tools" method="get" action="${ctx}/admin/news#list">
        <div class="tools-row">
          <!-- Category -->
          <select class="form-select" name="cat" aria-label="<fmt:message key='admin.news.filter.categoryAria'/>">
            <option value="0"><fmt:message key="admin.news.filter.allCategories"/></option>
            <c:forEach var="c" items="${categories}">
              <option value="${c.id}" ${param.cat == c.id ? 'selected' : (cat==c.id?'selected':'')}>${c.name}</option>
            </c:forEach>
          </select>

          <!-- (Nếu có lọc tác giả thì mở khối dưới; nếu không dùng, có thể xoá) -->
          <%-- 
          <select class="form-select" name="rep" aria-label="<fmt:message key='admin.news.filter.reporterAria'/>">
            <option value="0"><fmt:message key="admin.news.filter.allReporters"/></option>
            <c:forEach var="u" items="${reporters}">
              <option value="${u.id}" ${rep == u.id ? 'selected' : ''}>${u.fullname}</option>
            </c:forEach>
          </select>
          --%>

          <input class="form-control" name="q"
                 placeholder="<fmt:message key='admin.news.filter.searchPlaceholder'/>" value="${q}" />
          <button type="submit" class="btn btn-primary"><fmt:message key="admin.common.search"/></button>
          <a class="btn btn-outline-primary" href="${ctx}/admin/news">
            <fmt:message key="admin.common.clearFilters"/>
          </a>
        </div>
      </form>

      <div class="table-wrapper">
        <table class="table">
          <thead>
            <tr>
              <th><fmt:message key="admin.common.col.index"/></th>
              <th><fmt:message key="admin.news.col.title"/></th>
              <th><fmt:message key="admin.news.col.category"/></th>
              <th><fmt:message key="admin.news.col.postedDate"/></th>
              <th>Home</th>
              <th><fmt:message key="admin.common.col.actions"/></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="n" items="${items}" varStatus="loop">
              <tr>
                <td>${(page - 1) * size + loop.index + 1}</td>
                <td>
                  <a href="${ctx}/admin/news-edit?id=${n.id}">${fn:escapeXml(n.title)}</a>
                  <c:if test="${n.home}"><span class="badge-home"><fmt:message key="admin.news.badge.home"/></span></c:if>
                  <c:if test="${n.approved}"><span class="badge-approved"><fmt:message key="admin.news.badge.approved"/></span></c:if>
                </td>
                <td>${catMap[n.categoryId]}</td>
                <td>${n.postedDateFormatted}</td>
                <td>${n.home ? '1' : '0'}</td>
                <td style="white-space: nowrap">
                  <a class="btn btn-xs" href="${ctx}/admin/news-edit?id=${n.id}">
                    <fmt:message key="admin.common.edit"/>
                  </a>

                  <!-- Toggle Home -->
                  <form method="post" action="${ctx}/admin/news" style="display:inline">
                    <input type="hidden" name="id" value="${n.id}">
                    <input type="hidden" name="page" value="${page}">
                    <c:choose>
                      <c:when test="${n.home}">
                        <button style="border:1px solid red; height:31.5px" class="btn btn-xs ghost"
                                name="action" value="home-off"
                                onclick="return confirm('<fmt:message key="admin.news.confirm.unpin"/>')">
                          <fmt:message key="admin.news.unpin"/>
                        </button>
                      </c:when>
                      <c:otherwise>
                        <button style="border:1px solid blue; height:31.5px" class="btn btn-xs" name="action" value="home-on">
                          <fmt:message key="admin.news.pin"/>
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </form>

                  <!-- Delete -->
                  <form method="post" action="${ctx}/admin/news" style="display:inline">
                    <input type="hidden" name="id" value="${n.id}">
                    <input type="hidden" name="page" value="${page}">
                    <button style="border:1px solid red; height:31.5px" class="btn btn-xs danger"
                            name="action" value="delete"
                            onclick="return confirm('<fmt:message key="admin.news.confirm.delete"/>')">
                      <fmt:message key="admin.common.delete"/>
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
          <c:url var="base" value="/admin/news">
            <c:param name="q" value="${q}" />
            <c:param name="cat" value="${cat}" />
            <c:param name="size" value="${size}" />
          </c:url>

          <nav style="display:flex; gap:.5rem; justify-content:center; margin:12px 0">
            <a class="btn ghost" href="${base}&page=1" ${page==1?'style="pointer-events:none;opacity:.5"':''}>
              <fmt:message key="pager.first"/>
            </a>
            <a class="btn ghost" href="${base}&page=${page-1}" ${page==1?'style="pointer-events:none;opacity:.5"':''}>
              <fmt:message key="pager.prev"/>
            </a>
            <span class="btn" style="pointer-events:none;">
              <fmt:message key="pager.pageOf">
                <fmt:param value="${page}"/>
                <fmt:param value="${totalPages}"/>
                <fmt:param value="${total}"/>
              </fmt:message>
            </span>
            <a class="btn ghost" href="${base}&page=${page+1}" ${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>
              <fmt:message key="pager.next"/>
            </a>
            <a class="btn ghost" href="${base}&page=${totalPages}" ${page==totalPages?'style="pointer-events:none;opacity:.5"':''}>
              <fmt:message key="pager.last"/>
            </a>
          </nav>
        </c:if>

      </div>
    </div>
  </div>
</main>

<script src="https://cdn.ckeditor.com/ckeditor5/41.4.1/classic/ckeditor.js"></script>
<script>
ClassicEditor.create(document.querySelector('#content'), {
  toolbar:['heading','|','bold','italic','underline','link','bulletedList','numberedList','blockQuote','insertTable','|','insertImage','imageUpload','mediaEmbed','|','undo','redo'],
  simpleUpload:{uploadUrl:'${ctx}/upload-image',withCredentials:false},
  image:{toolbar:['imageTextAlternative','|','imageStyle:inline','imageStyle:block','imageStyle:side']}
}).catch(console.error);
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
