<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<c:set var="mode" value="${empty param.mode ? requestScope.mode : param.mode}" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<aside class="sidebar" aria-label="<fmt:message key='sidebar.aria'/>">

  <!-- 5 bản tin được xem nhiều -->
  <c:if test="${mode ne 'most'}">
    <section class="sidebar-card">
      <h3 class="sidebar-card__title">
        <a class="sidebar-section-link" href="${ctx}/most-viewed">
          <fmt:message key="sidebar.mostViewed"/>
        </a>
      </h3>
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
          <p class="sidebar-empty"><fmt:message key="common.noData"/></p>
        </c:otherwise>
      </c:choose>
    </section>
  </c:if>

  <!-- 5 bản tin mới nhất -->
  <c:if test="${mode ne 'latest'}">
    <section class="sidebar-card">
      <h3 class="sidebar-card__title">
        <a class="sidebar-section-link" href="${ctx}/latest">
          <fmt:message key="sidebar.latest"/>
        </a>
      </h3>
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
          <p class="sidebar-empty"><fmt:message key="common.noData"/></p>
        </c:otherwise>
      </c:choose>
    </section>
  </c:if>

  <!-- 5 bản tin bạn đã xem -->
  <c:if test="${mode ne 'recent'}">
    <section class="sidebar-card">
      <h3 class="sidebar-card__title">
        <a class="sidebar-section-link" href="${ctx}/recent">
          <fmt:message key="sidebar.recent"/>
        </a>
      </h3>
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
          <p class="sidebar-empty"><fmt:message key="sidebar.noHistory"/></p>
        </c:otherwise>
      </c:choose>
    </section>
  </c:if>

  <!-- Newsletter -->
  <section class="sidebar-card">
    <h3 class="sidebar-card__title"><fmt:message key="sidebar.newsletter.title"/></h3>

    <form method="post" action="${ctx}/newsletter/subscribe" class="sidebar-form">
      <input type="email" name="email"
             placeholder="<fmt:message key='sidebar.newsletter.placeholder'/>" required />

      <!-- Danh sách chuyên mục -->
      <c:choose>
        <c:when test="${not empty categories}">
          <label for="newsletter-category" class="sr-only">
            <fmt:message key="sidebar.newsletter.chooseCategory"/>
          </label>
          <select class="form-select" id="newsletter-category" name="categoryId" class="sidebar-select">
            <!-- value="" => backend hiểu là NULL: nhận mọi chuyên mục -->
            <option value="">
              <fmt:message key="sidebar.newsletter.allCategories"/>
            </option>
            <c:forEach var="cat" items="${categories}">
              <option value="${cat.id}">${cat.name}</option>
            </c:forEach>
          </select>
        </c:when>
        <c:otherwise>
          <p class="sidebar-empty"><fmt:message key="sidebar.newsletter.noCategory"/></p>
        </c:otherwise>
      </c:choose>

      <button type="submit"><fmt:message key="sidebar.newsletter.submit"/></button>
    </form>

    <c:if test="${not empty param.sub_msg}">
      <p class="sidebar-success">${param.sub_msg}</p>
    </c:if>
  </section>

</aside>
