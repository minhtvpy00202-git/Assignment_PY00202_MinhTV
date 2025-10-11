<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

<main class="container admin-page">
  <h2>Tài khoản chờ duyệt</h2>

  <c:if test="${empty list}">
    <p>Không có tài khoản nào đang chờ duyệt.</p>
  </c:if>

  <c:if test="${not empty list}">
    <div class="table-wrapper">
      <table class="table">
      <thead>
        <tr>
          <th>STT</th>
          <th>ID</th>
          <th>Họ tên</th>
          <th>Email</th>
          <th>Mobile</th>
          <th>Giới tính</th>
          <th>Ngày sinh</th>
          <th>Vai trò</th>
          <th>Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="u" items="${list}" varStatus="status">
          <tr>
            <td class="text-center">${status.index + 1}</td>
            <td>${u.id}</td>
            <td>${u.fullname}</td>
            <td>${u.email}</td>
            <td>${empty u.mobile ? '-' : u.mobile}</td>
            <td><c:out value="${u.gender ? 'Nam' : 'Nữ'}"/></td>
            <td>
              <c:choose>
                <c:when test="${u.birthday != null}">
                  <fmt:formatDate value="${u.birthday}" pattern="dd/MM/yyyy" />
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>
            <td>
              <span class="badge ${u.role ? 'success' : 'info'}">
                ${u.role ? 'Admin' : 'Reporter'}
              </span>
            </td>
            <td class="actions">
              <div class="action-buttons-compact">
                <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="action" value="approve">
                  <button type="submit" class="btn btn-approve" title="Duyệt tài khoản">✓</button>
                </form>

                <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline" onsubmit="return confirm('Từ chối tài khoản này?')">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="action" value="reject">
                  <button type="submit" class="btn btn-reject" title="Từ chối tài khoản">✗</button>
                </form>

                <form method="post" action="${pageContext.request.contextPath}/admin/users-pending" style="display:inline">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="action" value="toggle-role">
                  <button type="submit" class="btn btn-toggle" title="Đổi vai trò">⚡</button>
                </form>
              </div>
            </td>
          </tr>
        </c:forEach>
      </tbody>
      </table>
    </div>
  </c:if>
</main>

<style>
/* Users Pending Page Specific Styles */
.badge {
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.badge.success {
    background: linear-gradient(135deg, #10b981, #059669);
    color: white;
}

.badge.info {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: white;
}

/* Compact action buttons */
.action-buttons-compact {
    display: flex;
    gap: 0.15rem;
    justify-content: center;
    align-items: center;
    flex-wrap: nowrap;
    width: 100%;
    max-width: 65px;
}

.action-buttons-compact form {
    display: inline;
    margin: 0;
    flex: 1;
}

.action-buttons-compact .btn {
    padding: 0.15rem;
    font-size: 0.7rem;
    border: none;
    border-radius: 3px;
    cursor: pointer;
    transition: all 0.3s ease;
    width: 18px;
    height: 18px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    text-decoration: none;
    line-height: 1;
}

.btn-approve {
    background: linear-gradient(135deg, #10b981, #059669);
    color: white;
}

.btn-approve:hover {
    background: linear-gradient(135deg, #059669, #047857);
    transform: translateY(-1px);
}

.btn-reject {
    background: linear-gradient(135deg, #ef4444, #dc2626);
    color: white;
}

.btn-reject:hover {
    background: linear-gradient(135deg, #dc2626, #b91c1c);
    transform: translateY(-1px);
}

.btn-toggle {
    background: linear-gradient(135deg, #f59e0b, #d97706);
    color: white;
}

.btn-toggle:hover {
    background: linear-gradient(135deg, #d97706, #b45309);
    transform: translateY(-1px);
}

/* Table column widths */
.table th:nth-child(1) { width: 6%; }  /* STT */
.table th:nth-child(2) { width: 8%; }  /* ID */
.table th:nth-child(3) { width: 16%; } /* Họ tên */
.table th:nth-child(4) { width: 18%; } /* Email */
.table th:nth-child(5) { width: 10%; } /* Mobile */
.table th:nth-child(6) { width: 8%; }  /* Giới tính */
.table th:nth-child(7) { width: 10%; } /* Ngày sinh */
.table th:nth-child(8) { width: 8%; }  /* Vai trò */
.table th:nth-child(9) { width: 16%; } /* Thao tác */

.table td:nth-child(1) { width: 6%; }
.table td:nth-child(2) { width: 8%; }
.table td:nth-child(3) { width: 16%; }
.table td:nth-child(4) { width: 18%; }
.table td:nth-child(5) { width: 10%; }
.table td:nth-child(6) { width: 8%; }
.table td:nth-child(7) { width: 10%; }
.table td:nth-child(8) { width: 8%; }
.table td:nth-child(9) { width: 16%; }

/* Prevent text wrapping in action column */
.table td.actions {
    white-space: nowrap;
    text-align: center;
}

/* Date formatting */
.table td:nth-child(6) {
    font-family: 'Courier New', monospace;
    font-size: 0.9rem;
    text-align: center;
}

/* Mobile responsive */
@media (max-width: 768px) {
    .action-buttons-compact {
        flex-direction: row;
        gap: 0.1rem;
        max-width: 55px;
    }
    
    .action-buttons-compact .btn {
        width: 16px;
        height: 16px;
        padding: 0.1rem;
        font-size: 0.6rem;
    }
    
    /* Hide some columns on mobile */
    .table th:nth-child(5),
    .table td:nth-child(5),
    .table th:nth-child(6),
    .table td:nth-child(6) {
        display: none;
    }
    
    /* Adjust column widths for mobile */
    .table th:nth-child(1), .table td:nth-child(1) { width: 8%; }  /* STT */
    .table th:nth-child(2), .table td:nth-child(2) { width: 10%; } /* ID */
    .table th:nth-child(3), .table td:nth-child(3) { width: 25%; } /* Họ tên */
    .table th:nth-child(4), .table td:nth-child(4) { width: 30%; } /* Email */
    .table th:nth-child(7), .table td:nth-child(7) { width: 12%; } /* Ngày sinh */
    .table th:nth-child(8), .table td:nth-child(8) { width: 15%; } /* Vai trò */
}

@media (max-width: 480px) {
    .table th:nth-child(6),
    .table td:nth-child(6) {
        display: none;
    }
    
    .action-buttons-compact .btn {
        padding: 0.5rem;
        min-width: 36px;
    }
    
    .btn-approve::after,
    .btn-reject::after,
    .btn-toggle::after {
        content: "";
    }
}
</style>

<%@ include file="../layout/footer.jsp" %>
