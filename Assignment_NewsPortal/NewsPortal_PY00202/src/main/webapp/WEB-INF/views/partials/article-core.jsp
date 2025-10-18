<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<h1><c:out value="${news.title}"/></h1>


<p class="meta" style="margin: 25px 0px; color: #666;">
  <span >Người đăng:
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
  <span> • Ngày đăng: <c:out value="${news.postedDateFormatted}"/></span>
</p>

<article class="content">
  ${news.content}
</article>

<hr>

