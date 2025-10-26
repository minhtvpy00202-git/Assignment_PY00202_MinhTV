<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>

<h1><c:out value="${news.title}"/></h1>

<p class="meta" style="margin:25px 0; color:#666;">
  <span>
    <fmt:message key="news.by"/>:
    <c:choose>
      <c:when test="${not empty newsAuthor}">
        <c:out value="${newsAuthor.fullname}"/>
      </c:when>
      <c:when test="${not empty news.author}">
        <c:out value="${news.author}"/>
      </c:when>
      <c:otherwise>—</c:otherwise>
    </c:choose>
  </span>
  <span> • <fmt:message key="news.published"/>:
    <c:out value="${news.postedDateFormatted}"/>
  </span>
  <span> •
    <fmt:message key="news.views">
      <fmt:param value="${news.viewCount}"/>
    </fmt:message>
  </span>
</p>

<article class="content">
  ${news.content}
</article>

<hr>
