<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../layout/admin-header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-clean.css">

      <main class="container admin-main">
        <h2>Dashboard</h2>

        <div class="grid-3 stats">
          <div class="card">
            <h3>${newsTotal}</h3>
            <p>Tổng số bài viết</p>
          </div>
          <div class="card">
            <h3>${pendingCount}</h3>
            <p>Bài chờ duyệt</p>
          </div>
          <div class="card">
            <h3>${usersTotal}</h3>
            <p>Người dùng</p>
          </div>
        </div>

        <section class="card">
          <h3>Chuyên mục</h3>
          <ul class="list">
            <c:forEach var="c" items="${categories}">
              <li>${c.name}</li>
            </c:forEach>
          </ul>
        </section>

        <!-- ====== BÀI CHỜ DUYỆT (quick approve) ====== -->
        <section class="card">
          <div style="display:flex;align-items:center;justify-content:space-between;">
            <h3 style="margin:0;">Bài chờ duyệt</h3>
            <a class="btn ghost" href="${pageContext.request.contextPath}/admin/news-approve">Xem tất cả</a>
          </div>

          <c:choose>
            <c:when test="${empty pendingList}">
              <p style="color:#6b7280;margin-top:10px;">Hiện không có bài chờ duyệt.</p>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table"></table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Tiêu đề</th>
                    <th>Tác giả</th>
                    <th>Loại</th>
                    <th>Trang chủ</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="n" items="${pendingList}" varStatus="st">
                    <c:if test="${st.index < 5}">
                      <tr>
                        <td>${n.id}</td>
                        <td>
                          <c:out value="${n.title}" />
                        </td>
                        <td>${n.author}</td>
                        <td>${catMap[n.categoryId]}</td>
                        <td>
                          <c:out value="${n.home ? '✔' : '✘'}" />
                        </td>
                        <td class="actions">
                          <!-- Duyệt -->
                          <form method="post" action="${pageContext.request.contextPath}/admin/news-approve"
                            style="display:inline;">
                            <input type="hidden" name="id" value="${n.id}">
                            <input type="hidden" name="action" value="approve">
                            <button type="submit" class="btn">Duyệt</button>
                          </form>
                          <!-- Từ chối -->
                          <form method="post" action="${pageContext.request.contextPath}/admin/news-approve"
                            style="display:inline;" onsubmit="return confirm('Từ chối và xóa bài này?');">
                            <input type="hidden" name="id" value="${n.id}">
                            <input type="hidden" name="action" value="reject">
                            <button type="submit" class="btn danger">Từ chối</button>
                          </form>
                          <!-- Toggle Trang chủ -->
                          <form method="post" action="${pageContext.request.contextPath}/admin/news-approve"
                            style="display:inline;">
                            <input type="hidden" name="id" value="${n.id}">
                            <input type="hidden" name="action" value="${n.home ? 'home-off' : 'home-on'}">
                            <button type="submit" class="btn ghost">
                              ${n.home ? 'Bỏ Trang chủ' : 'Đưa Trang chủ'}
                            </button>
                          </form>
                        </td>
                      </tr>
                    </c:if>
                  </c:forEach>
                </tbody>
                </table>
              </div>
            </c:otherwise>
          </c:choose>

      </main>
      <%@ include file="../layout/footer.jsp" %>