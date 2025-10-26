<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<%@ include file="../layout/admin-header.jsp"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<main class="container admin-page">
  <h2><fmt:message key="admin.approve.pageTitle"/></h2>

  <!-- Bulk send queue -->
  <c:if test="${not empty sessionScope.bulkSendQueue}">
    <form method="post" action="${ctx}/admin/news-bulk-send" class="table-tools" style="margin: 8px 0">
      <c:forEach var="id" items="${sessionScope.bulkSendQueue}">
        <input type="hidden" name="newsId" value="${id}" />
      </c:forEach>
      <button class="btn success">
        <fmt:message key="admin.approve.bulkSendBtn">
          <fmt:param value="${fn:length(sessionScope.bulkSendQueue)}"/>
        </fmt:message>
      </button>
      <small style="margin-left: .5rem; opacity: .8">
        <fmt:message key="admin.approve.bulkSendHelp"/>
      </small>
      <button class="btn ghost"
              formaction="${ctx}/admin/news-bulk-send?clear=1"
              formmethod="post">
        <fmt:message key="admin.approve.bulkClear"/>
      </button>
    </form>
  </c:if>

  <!-- After sent -->
  <c:if test="${not empty param.msg}">
    <p class="sidebar-success" style="text-align: center">${param.msg}</p>
  </c:if>

  <!-- Filters -->
  <form method="get" action="${ctx}/admin/news-approve" class="table-tools"
        style="gap: .5rem; display: flex; flex-wrap: wrap; align-items: center">
    <input type="text" name="q" value="${fn:escapeXml(q)}"
           placeholder="<fmt:message key='admin.approve.filter.searchPlaceholder'/>"
           class="form-control" style="min-width: 220px;">
    <select name="catId" class="form-control" aria-label="<fmt:message key='admin.approve.filter.categoryAria'/>">
      <option value=""><fmt:message key="admin.approve.filter.allCategories"/></option>
      <c:forEach var="c" items="${categories}">
        <option value="${c.id}" ${catId == c.id ? 'selected' : ''}>${c.name}</option>
      </c:forEach>
    </select>

    <input type="date" name="from" value="${from}" style="font-family: 'Noto Serif', serif; height: 44.8px;">
    <input type="date" name="to" value="${to}" style="font-family: 'Noto Serif', serif; height: 44.8px;">

    <button class="btn"><fmt:message key="admin.common.search"/></button>
  </form>

  <c:if test="${empty pendingList}">
    <p style="text-align: center; border: 1px solid #ddd; padding: 8px">
      <fmt:message key="admin.dashboard.noPending"/>
    </p>
  </c:if>

  <c:forEach var="n" items="${pendingList}">
    <div class="card article">
      <h3 style="margin: 0 0 4px">
        <a href="${ctx}/admin/news-detail?id=${n.id}&ref=approve">${n.title}</a>
      </h3>
      <small>
        <fmt:message key="news.by"/>: 
        <c:set var="author" value="${reporters[n.reporterId]}" />
        ${author != null ? author.fullname : '—'}
        &nbsp;—&nbsp;<fmt:message key="news.published"/>: ${n.postedDateFormatted}
      </small>

      <p>
        <c:choose>
          <c:when test="${not empty n.excerpt}">
            ${n.excerpt}
          </c:when>
          <c:otherwise>
            <c:set var="raw" value="${n.content}" />
            ${fn:length(raw) > 200 ? fn:substring(raw,0,200).concat('...') : raw}
          </c:otherwise>
        </c:choose>
      </p>

      <div class="actions" style="display: flex; gap: .5rem; align-items: center;">
        <a class="btn ghost" href="${ctx}/admin/news-detail?id=${n.id}&ref=approve">
          <fmt:message key="admin.approve.viewPost"/>
        </a>

        <form method="post" action="${ctx}/admin/news-approve" style="display: inline">
          <input type="hidden" name="id" value="${n.id}">
          <button class="btn" name="action" value="approve">
            <fmt:message key="admin.dashboard.approve"/>
          </button>
          <button class="btn ghost" name="action" value="home-on">
            <fmt:message key="admin.approve.pinHome"/>
          </button>
          <button class="btn danger" name="action" value="reject"
                  onclick="return confirm('<fmt:message key="admin.dashboard.rejectConfirm"/>')">
            <fmt:message key="admin.dashboard.reject"/>
          </button>
        </form>

        <form method="post" action="${ctx}/admin/news-send" style="display: inline">
          <input type="hidden" name="id" value="${n.id}">
          <button class="btn success" name="action" value="send">
            <fmt:message key="admin.approve.sendEmail"/>
          </button>
        </form>
      </div>
    </div>
    <hr>
  </c:forEach>

  <!-- Pagination -->
  <c:if test="${totalPages > 1}">
    <c:url var="base" value="/admin/news-approve">
      <c:param name="q" value="${q}" />
      <c:if test="${catId != null}"><c:param name="catId" value="${catId}" /></c:if>
      <c:if test="${reporterId != null}"><c:param name="reporterId" value="${reporterId}" /></c:if>
      <c:if test="${from != null}"><c:param name="from" value="${from}" /></c:if>
      <c:if test="${to != null}"><c:param name="to" value="${to}" /></c:if>
    </c:url>

    <nav class="pagination" style="display: flex; gap: .5rem; justify-content: center; margin: 12px 0">
      <a class="btn ghost" href="${base}&page=1" ${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>
        <fmt:message key="pager.first"/>
      </a>
      <a class="btn ghost" href="${base}&page=${page-1}" ${page==1 ? 'style="pointer-events:none;opacity:.5"' : ''}>
        <fmt:message key="pager.prev"/>
      </a>
      <span class="btn" style="pointer-events: none">
        <fmt:message key="pager.pageOf">
          <fmt:param value="${page}"/>
          <fmt:param value="${totalPages}"/>
          <fmt:param value="${total}"/>
        </fmt:message>
      </span>
      <a class="btn ghost" href="${base}&page=${page+1}" ${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>
        <fmt:message key="pager.next"/>
      </a>
      <a class="btn ghost" href="${base}&page=${totalPages}" ${page==totalPages ? 'style="pointer-events:none;opacity:.5"' : ''}>
        <fmt:message key="pager.last"/>
      </a>
    </nav>
  </c:if>
</main>

<%@ include file="../layout/footer.jsp"%>
