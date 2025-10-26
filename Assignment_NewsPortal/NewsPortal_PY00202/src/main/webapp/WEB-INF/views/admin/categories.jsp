<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@ include file="../layout/admin-header.jsp"%>

<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1><fmt:message key="admin.categories.pageTitle"/></h1>
      <p><fmt:message key="admin.categories.pageSubtitle"/></p>
    </div>

    <div class="admin-layout-grid">
      <!-- Form -->
      <div class="form-section">
        <div class="admin-form-section">
          <h2>
            <c:choose>
              <c:when test="${empty item}">
                <fmt:message key="admin.categories.form.createTitle"/>
              </c:when>
              <c:otherwise>
                <fmt:message key="admin.categories.form.editTitle"/>
              </c:otherwise>
            </c:choose>
          </h2>

          <form method="post" action="${ctx}/admin/categories" class="admin-form">
            <input type="hidden" name="action" value="${empty item ? 'create' : 'update'}" />
            <input type="hidden" name="id" value="${item.id}" />

            <div class="form-group">
              <label class="form-label"><fmt:message key="admin.categories.nameLabel"/></label>
              <input class="form-control" name="name" value="${item.name}" required
                     placeholder="<fmt:message key='admin.categories.namePlaceholder'/>" />
            </div>

            <div class="form-actions">
              <button type="submit" class="btn btn-primary">
                <c:choose>
                  <c:when test="${empty item}"><fmt:message key="admin.categories.btn.create"/></c:when>
                  <c:otherwise><fmt:message key="admin.categories.btn.update"/></c:otherwise>
                </c:choose>
              </button>
              <c:if test="${not empty item}">
                <a class="btn btn-outline-primary" href="${ctx}/admin/categories">
                  <fmt:message key="admin.common.cancel"/>
                </a>
              </c:if>
            </div>
          </form>
        </div>
      </div>

      <!-- Alerts -->
      <c:if test="${param.created == '1'}">
        <div class="alert alert-success">✅ <fmt:message key="admin.categories.alert.created"/></div>
      </c:if>
      <c:if test="${param.updated == '1'}">
        <div class="alert alert-info">✏️ <fmt:message key="admin.categories.alert.updated"/></div>
      </c:if>
      <c:if test="${param.deleted == '1'}">
        <div class="alert alert-warning">🗑️ <fmt:message key="admin.categories.alert.deleted"/></div>
      </c:if>
      <c:if test="${param.restored == '1'}">
        <div class="alert alert-success">♻️ <fmt:message key="admin.categories.alert.restored"/></div>
      </c:if>
      <c:if test="${param.purged == '1'}">
        <div class="alert alert-danger">⚠️ <fmt:message key="admin.categories.alert.purged"/></div>
      </c:if>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">❌ ${error}</div>
      </c:if>
      <c:if test="${not empty info}">
        <div class="alert alert-info">ℹ️ ${info}</div>
      </c:if>

      <!-- List -->
      <div class="table-section">
        <h2><fmt:message key="admin.categories.listTitle"/></h2>
        <div class="table-wrapper">
          <table class="table">
            <thead>
              <tr>
                <th><fmt:message key="admin.common.col.index"/></th>
                <th>ID</th>
                <th><fmt:message key="admin.categories.col.name"/></th>
                <th style="width: 40px;"><fmt:message key="admin.common.col.actions"/></th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="c" items="${items}" varStatus="status">
                <tr>
                  <td>${status.index + 1}</td>
                  <td>${c.id}</td>
                  <td class="category-name">${c.name}</td>
                  <td class="actions">
                    <a class="btn btn-outline-primary"
                       href="${ctx}/admin/categories?action=edit&id=${c.id}">
                      <fmt:message key="admin.common.edit"/>
                    </a>
                    <form method="post" action="${ctx}/admin/categories"
                          onsubmit="return confirm('<fmt:message key="admin.categories.confirm.delete"/>');">
                      <input type="hidden" name="action" value="delete" />
                      <input type="hidden" name="id" value="${c.id}" />
                      <button type="submit" class="btn btn-danger">
                        <fmt:message key="admin.common.delete"/>
                      </button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Trash -->
      <div class="table-section" style="margin-top: 32px;">
        <h2><fmt:message key="admin.common.trash"/></h2>
        <div class="table-wrapper">
          <table class="table">
            <thead>
              <tr>
                <th><fmt:message key="admin.common.col.index"/></th>
                <th>ID</th>
                <th><fmt:message key="admin.categories.col.name"/></th>
                <th style="width: 160px;"><fmt:message key="admin.common.col.actions"/></th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="c" items="${deletedItems}" varStatus="st">
                <tr>
                  <td>${st.index + 1}</td>
                  <td>${c.id}</td>
                  <td class="category-name">${c.name}</td>
                  <td class="actions" style="display: flex; gap: 8px;">
                    <form method="post" action="${ctx}/admin/categories"
                          onsubmit="return confirm('<fmt:message key="admin.categories.confirm.restore"/>');">
                      <input type="hidden" name="action" value="restore" />
                      <input type="hidden" name="id" value="${c.id}" />
                      <button type="submit" class="btn btn-outline-primary">
                        <fmt:message key="admin.common.restore"/>
                      </button>
                    </form>
                    <form method="post" action="${ctx}/admin/categories"
                          onsubmit="return confirm('<fmt:message key="admin.categories.confirm.purge"/>');">
                      <input type="hidden" name="action" value="purge" />
                      <input type="hidden" name="id" value="${c.id}" />
                      <button type="submit" class="btn btn-danger">
                        <fmt:message key="admin.common.deleteForever"/>
                      </button>
                    </form>
                  </td>
                </tr>
              </c:forEach>

              <c:if test="${empty deletedItems}">
                <tr>
                  <td colspan="4" style="text-align: center; color: #777;">
                    (<fmt:message key="admin.common.trashEmpty"/>)
                  </td>
                </tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>

    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
