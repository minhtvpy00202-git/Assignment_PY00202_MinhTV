<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<c:set var="mode" value="${empty param.mode ? requestScope.mode : param.mode}" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<aside class="sidebar" aria-label="Tin phụ">
  <!-- 5 bản tin được xem nhiều -->
  <c:if test="${mode ne 'most'}">
  <section class="sidebar-card">
    <h3 class="sidebar-card__title"><a class="sidebar-section-link" href="${ctx}/most-viewed">5 Most Viewed</a></h3>
    <c:choose>
      <c:when test="${not empty hotList}">
        <ol class="sidebar-list">
          <c:forEach var="n" items="${hotList}">
            <li class="sidebar-list__item">
              <a class="sidebar-list__link" href="${ctx}/news/${n.id}">
                ${n.title}
              </a>
            </li>
          </c:forEach>
        </ol>
      </c:when>
      <c:otherwise>
        <p class="sidebar-empty">Chưa có dữ liệu.</p>
      </c:otherwise>
    </c:choose>
  </section>
</c:if>
  <!-- 5 bản tin mới nhất -->
  <c:if test="${mode ne 'latest'}">
  <section class="sidebar-card">
    <h3 class="sidebar-card__title"><a class="sidebar-section-link" href="${ctx}/latest">5 Latest News</a></h3>
    <c:choose>
      <c:when test="${not empty newList}">
        <ol class="sidebar-list">
          <c:forEach var="n" items="${newList}">
            <li class="sidebar-list__item">
              <a class="sidebar-list__link" href="${ctx}/news/${n.id}">
                ${n.title}
              </a>
            </li>
          </c:forEach>
        </ol>
      </c:when>
      <c:otherwise>
        <p class="sidebar-empty">Chưa có dữ liệu.</p>
      </c:otherwise>
    </c:choose>
  </section>
  </c:if>

  <!-- 5 bản tin bạn đã xem -->
  <c:if test="${mode ne 'recent'}">
  <section class="sidebar-card">
    <h3 class="sidebar-card__title"><a class="sidebar-section-link" href="${ctx}/recent">5 Recently Read</a></h3>
    <c:choose>
      <c:when test="${not empty recentList}">
        <ol class="sidebar-list">
          <c:forEach var="n" items="${recentList}">
            <li class="sidebar-list__item">
              <a class="sidebar-list__link" href="${ctx}/news/${n.id}">
                ${n.title}
              </a>
            </li>
          </c:forEach>
        </ol>
      </c:when>
      <c:otherwise>
        <p class="sidebar-empty">Chưa có lịch sử xem.</p>
      </c:otherwise>
    </c:choose>
  </section>
</c:if>
  <!-- Newsletter -->
  <section class="sidebar-card">
    <h3 class="sidebar-card__title">Đăng ký nhận tin</h3>
    <form method="post" action="${ctx}/newsletter/subscribe" class="sidebar-form">
      <input type="email" name="email" placeholder="Nhập email…" required />
      <button type="submit">Đăng ký</button>
    </form>
    <c:if test="${not empty param.sub_msg}">
      <p class="sidebar-success">${param.sub_msg}</p>
    </c:if>
  </section>
</aside>
