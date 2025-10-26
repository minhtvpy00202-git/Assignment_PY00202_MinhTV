<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="isCreate" value="${empty item}" />
<%@ include file="../layout/admin-header.jsp"%>
<c:set var="genderMaleLabel"><fmt:message key="auth.gender.male"/></c:set>
<c:set var="genderFemaleLabel"><fmt:message key="auth.gender.female"/></c:set>


<main class="admin-main">
  <div class="container">
    <div class="page-header">
      <h1><fmt:message key="admin.users.pageTitle"/></h1>
      <p><fmt:message key="admin.users.pageSubtitle"/></p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger" style="border: 1px solid red">${error}</div>
    </c:if>

    <form method="post" action="${ctx}/admin/users" class="admin-form">
      <input type="hidden" name="action" value="${empty item ? 'create' : 'update'}" />
      <input type="hidden" name="id" value="${item.id}" />

      <div class="form-grid">
        <!-- Họ tên -->
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.fullname"/></label>
          <input class="form-control" name="fullName"
                 value="${not empty param.fullName ? param.fullName : (not empty item ? item.fullname : '')}"
                 required>
        </div>

        <!-- Email -->
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.email"/></label>
          <input class="form-control" name="email" type="email"
                 value="${not empty param.email ? param.email : (not empty item ? item.email : '')}"
                 required>
        </div>

        <!-- Số điện thoại -->
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.phone"/></label>
          <input placeholder="<fmt:message key='admin.users.phonePlaceholder'/>"
                 class="form-control" name="mobile" type="tel" inputmode="numeric"
                 value="${not empty param.mobile ? param.mobile : (not empty item ? item.mobile : '')}"
                 pattern="[0-9]{10}" title="<fmt:message key='admin.users.phoneTitle'/>" required>
        </div>

        <!-- Ngày sinh -->
        <fmt:formatDate value="${item.birthday}" pattern="yyyy-MM-dd" var="bd" />
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.birthday"/></label>
          <input class="form-control" name="birthday" type="date"
                 value="${not empty param.birthday ? param.birthday : (not empty item && item.birthday != null ? bd : '')}"
                 required>
        </div>

        <!-- Giới tính -->
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.gender"/></label>
          <select class="form-control" name="gender" required>
            <option value="true"
              ${not empty param.gender ? (param.gender == 'true' ? 'selected' : '') :
                 (not empty item && item.gender ? 'selected' : '')}>
              <fmt:message key="auth.gender.male"/>
            </option>
            <option value="false"
              ${not empty param.gender ? (param.gender == 'false' ? 'selected' : '') :
                 (not empty item && !item.gender ? 'selected' : '')}>
              <fmt:message key="auth.gender.female"/>
            </option>
          </select>
        </div>

        <!-- Vai trò -->
        <div class="form-group">
          <label class="form-label"><fmt:message key="auth.role"/></label>
          <select class="form-control" name="role">
            <option value="ADMIN"
              ${not empty param.role ? (param.role == 'ADMIN' ? 'selected' : '') : (not empty item && item.role ? 'selected' : '')}>
              <fmt:message key="auth.role.admin"/>
            </option>
            <option value="REPORTER"
              ${not empty param.role ? (param.role == 'REPORTER' ? 'selected' : '') : (not empty item && !item.role ? 'selected' : '')}>
              <fmt:message key="auth.role.reporter"/>
            </option>
          </select>
        </div>

        <!-- Mật khẩu -->
        <div class="form-group">
          <label class="form-label" for="password"><fmt:message key="profile.newPassword"/></label>
          <input class="form-control" name="password" type="password" autocomplete="new-password"
                 <c:if test="${empty item}">required</c:if>
                 <c:if test="${not empty item}">placeholder="<fmt:message key='admin.users.password.placeholder'/>"</c:if>>
        </div>

        <!-- Nhập lại mật khẩu -->
        <div class="form-group">
          <label class="form-label" for="confirmPassword"><fmt:message key="admin.users.confirmPassword"/></label>
          <input class="form-control" name="confirmPassword" type="password" autocomplete="new-password"
                 <c:if test="${empty item}">required</c:if>
                 <c:if test="${not empty item}">placeholder="<fmt:message key='admin.users.confirmPassword.placeholder'/>"</c:if>>
        </div>

        <div class="form-group full-width">
          <div class="checkbox-group">
            <input type="checkbox" name="activated"
                   ${not empty param.activated ? 'checked' : (not empty item && item.activated ? 'checked' : '')}>
            <label for="activated"><fmt:message key="admin.users.activateAccount"/></label>
          </div>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <c:choose>
            <c:when test="${empty item}">
              <fmt:message key="admin.users.btn.create"/>
            </c:when>
            <c:otherwise>
              <fmt:message key="admin.users.btn.update"/>
            </c:otherwise>
          </c:choose>
        </button>
        <c:if test="${not empty item}">
          <a class="btn btn-outline-primary" href="${ctx}/admin/users">
            <fmt:message key="admin.common.cancel"/>
          </a>
        </c:if>
      </div>
    </form>

    <div id="list" class="table-section">
      <h2><fmt:message key="admin.users.listTitle"/></h2>

      <!-- Thanh tìm kiếm có tiêu chí -->
      <form method="get" action="${ctx}/admin/users#list" class="admin-search">
        <div class="search-row">
          <select name="by" id="bySelect" class="form-select">
            <option value="all" ${param.by=='all' ? 'selected' : '' }><fmt:message key="admin.users.filter.all"/></option>
            <option value="fullname" ${param.by=='fullname' ? 'selected' : '' }><fmt:message key="auth.fullname"/></option>
            <option value="email" ${param.by=='email' ? 'selected' : '' }><fmt:message key="auth.email"/></option>
            <option value="mobile" ${param.by=='mobile' ? 'selected' : '' }><fmt:message key="auth.phone"/></option>
            <option value="role" ${param.by=='role' ? 'selected' : '' }><fmt:message key="auth.role"/></option>
            <option value="activated" ${param.by=='activated' ? 'selected' : '' }><fmt:message key="admin.users.accountStatus"/></option>
          </select>

          <!-- Ô tìm kiếm text (mặc định) -->
          <div id="qTextWrap" class="q-wrap">
            <input type="text" name="q" id="qText" class="form-control"
                   value="${fn:escapeXml(param.q)}"
                   placeholder="<fmt:message key='nav.search.placeholder'/>" />
          </div>

          <!-- Dropdown vai trò -->
          <div id="qRoleWrap" class="q-wrap">
            <select name="q" id="qRole" class="form-select">
              <option value="ADMIN" ${param.q=='ADMIN' ? 'selected' : '' }><fmt:message key="auth.role.admin"/></option>
              <option value="REPORTER" ${param.q=='REPORTER' ? 'selected' : '' }><fmt:message key="auth.role.reporter"/></option>
            </select>
          </div>

          <!-- Dropdown kích hoạt -->
          <div id="qActWrap" class="q-wrap">
            <select name="q" id="qAct" class="form-select">
              <option value="true" ${param.q=='true' ? 'selected' : '' }><fmt:message key="admin.users.status.activated"/></option>
              <option value="false" ${param.q=='false' ? 'selected' : '' }><fmt:message key="admin.users.status.inactive"/></option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary btn-search">
            <fmt:message key="admin.common.search"/>
          </button>
        </div>
      </form>

      <c:if test="${param.created == '1'}">
        <div class="alert alert-success" style="border: 1px solid blue;">
          <fmt:message key="admin.users.alert.created"/>
        </div>
      </c:if>

      <c:if test="${param.updated == '1'}">
        <div class="alert alert-success" style="border: 1px solid blue;">
          <fmt:message key="admin.users.alert.updated"/>
        </div>
      </c:if>

      <c:if test="${not empty info}">
        <div class="alert alert-info" style="border: 1px solid red;">${info}</div>
      </c:if>

      <c:if test="${param.deleted == '1'}">
        <div class="alert alert-success" style="border: 1px solid red;">
          <fmt:message key="admin.users.alert.deleted"/>
        </div>
      </c:if>

      <script>
        (function() {
          var f = '${focusField}';
          if (f && f !== '') {
            var el = document.querySelector('[name="'+ f +'"]');
            if (el) { el.focus(); try { el.select && el.select(); } catch(e){} }
          }
        })();
      </script>

      <script>
        (function () {
          const bySel = document.getElementById('bySelect');
          const qTextW = document.getElementById('qTextWrap');
          const qRoleW = document.getElementById('qRoleWrap');
          const qActW  = document.getElementById('qActWrap');

          const qText = document.getElementById('qText');
          const qRole = document.getElementById('qRole');
          const qAct  = document.getElementById('qAct');

          const wraps = [qTextW, qRoleW, qActW];
          const inputs = [qText, qRole, qAct];

          function toggleInputs() {
            const by = bySel.value;
            wraps.forEach(w => w.classList.remove('active'));
            inputs.forEach(el => el.disabled = true);
            if (by === 'role') {
              qRoleW.classList.add('active'); qRole.disabled = false;
            } else if (by === 'activated') {
              qActW.classList.add('active'); qAct.disabled = false;
            } else {
              qTextW.classList.add('active'); qText.disabled = false;
            }
          }
          bySel.addEventListener('change', toggleInputs);
          toggleInputs();
        })();
      </script>

      <script>
        (function () {
          const pwd = document.querySelector('input[name="password"]');
          const cf = document.querySelector('input[name="confirmPassword"]');
          if (!pwd || !cf) return;
          function v() {
            if (cf.value && pwd.value !== cf.value) cf.setCustomValidity("<fmt:message key='admin.users.password.mismatch'/>");
            else cf.setCustomValidity("");
          }
          pwd.addEventListener('input', v);
          cf.addEventListener('input', v);
        })();
      </script>

      <div class="table-wrapper">
        <table class="table">
          <thead>
            <tr>
              <th><fmt:message key="admin.common.col.index"/></th>
              <th><fmt:message key="auth.fullname"/></th>
              <th><fmt:message key="auth.email"/></th>
              <th><fmt:message key="auth.phone"/></th>
              <th><fmt:message key="auth.gender"/></th>
              <th><fmt:message key="auth.role"/></th>
              <th><fmt:message key="admin.users.activated"/></th>
              <th><fmt:message key="admin.common.col.actions"/></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="u" items="${items}" varStatus="status">
              <tr>
                <td>${status.index + 1}</td>
                <td>${u.fullname}</td>
                <td>${u.email}</td>
                <td>${u.mobile}</td>
                <td><c:out value="${u.gender ? genderMaleLabel : genderFemaleLabel}"/></td>
              
                <td><c:out value="${u.role ? 'ADMIN' : 'REPORTER'}" /></td>
                <td><c:out value="${u.activated ? '✔' : '✘'}" /></td>
                <td class="actions">
                  <a class="btn btn-outline-primary" href="${ctx}/admin/users?action=edit&id=${u.id}">
                    <fmt:message key="admin.common.edit"/>
                  </a>

                  <form method="post" action="${ctx}/admin/users"
                        onsubmit="return confirm('<fmt:message key="admin.users.confirm.delete"/>');">
                    <input type="hidden" name="action" value="delete" />
                    <input type="hidden" name="id" value="${u.id}" />
                    <c:choose>
                      <c:when test="${u.id eq sessionScope.authUser.id}">
                        <button type="button" class="btn btn-disabled" disabled
                                aria-disabled="true"
                                title="<fmt:message key='admin.users.cannotDeleteSelfTitle'/>">
                          <fmt:message key="admin.common.delete"/>
                        </button>
                      </c:when>
                      <c:otherwise>
                        <button type="submit" class="btn btn-danger">
                          <fmt:message key="admin.common.delete"/>
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <!-- ============ THÙNG RÁC ============ -->
      <div id="trash" class="table-section" style="margin-top: 24px;">
        <h2><fmt:message key="admin.common.trash"/></h2>

        <c:choose>
          <c:when test="${empty deletedItems}">
            <p style="opacity: .7; text-align: center;">
              <fmt:message key="admin.common.trashEmpty"/>
            </p>
          </c:when>
          <c:otherwise>
            <div class="table-wrapper">
              <table class="table">
                <thead>
                  <tr>
                    <th><fmt:message key="admin.common.col.index"/></th>
                    <th><fmt:message key="auth.fullname"/></th>
                    <th><fmt:message key="auth.email"/></th>
                    <th><fmt:message key="auth.phone"/></th>
                    <th><fmt:message key="auth.gender"/></th>
                    <th><fmt:message key="auth.role"/></th>
                    <th><fmt:message key="admin.users.accountStatus"/></th>
                    <th><fmt:message key="admin.common.col.actions"/></th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="u" items="${deletedItems}" varStatus="st">
                    <tr>
                      <td>${st.index + 1}</td>
                      <td>${u.fullname}</td>
                      <td>${u.email}</td>
                      <td>${u.mobile}</td>
                      <td><c:out value="${u.gender ? genderMaleLabel : genderFemaleLabel}"/></td>

                      <td><c:out value="${u.role ? 'ADMIN' : 'REPORTER'}" /></td>
                      <td><c:out value="${u.activated ? '✔' : '✘'}" /></td>
                      <td class="actions" style="white-space: nowrap">
                        <!-- Khôi phục -->
                        <form method="post" action="${ctx}/admin/users" style="display: inline">
                          <input type="hidden" name="action" value="restore" />
                          <input type="hidden" name="id" value="${u.id}" />
                          <button type="submit" class="btn btn-outline-primary"
                                  onclick="return confirm('<fmt:message key="admin.users.confirm.restore"/>')">
                            <fmt:message key="admin.common.restore"/>
                          </button>
                        </form>
                        <!-- Xóa vĩnh viễn -->
                        <form method="post" action="${ctx}/admin/users" style="display: inline">
                          <input type="hidden" name="action" value="purge" />
                          <input type="hidden" name="id" value="${u.id}" />
                          <button type="submit" class="btn btn-danger"
                                  onclick="return confirm('<fmt:message key="admin.users.confirm.purge"/>')">
                            <fmt:message key="admin.common.deleteForever"/>
                          </button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- THÔNG BÁO ACTION -->
      <c:if test="${param.restored == '1'}">
        <div class="alert alert-success">
          <fmt:message key="admin.users.alert.restored"/>
        </div>
      </c:if>
      <c:if test="${param.purged == '1'}">
        <div class="alert alert-success">
          <fmt:message key="admin.users.alert.purged"/>
        </div>
      </c:if>

    </div>
  </div>
</main>

<%-- Nhãn giới tính động cho bảng (tránh lặp) --%>
<c:set var="genderMaleLabel"><fmt:message key="auth.gender.male"/></c:set>
<c:set var="genderFemaleLabel"><fmt:message key="auth.gender.female"/></c:set>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
