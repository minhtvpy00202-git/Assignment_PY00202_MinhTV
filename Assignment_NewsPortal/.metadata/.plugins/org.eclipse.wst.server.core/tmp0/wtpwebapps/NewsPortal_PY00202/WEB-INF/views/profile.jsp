<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
      <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
        <%@ include file="layout/admin-header.jsp" %>
          <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css">

          <main class="container profile-page">
            <c:choose>
              <c:when test="${empty sessionScope.user && empty sessionScope.authUser}">
                <!-- Not logged in -->
                <div class="profile-error">
                  <div class="error-icon">🔒</div>
                  <h2>Yêu cầu đăng nhập</h2>
                  <p>Bạn cần đăng nhập để xem và chỉnh sửa hồ sơ cá nhân.</p>
                  <div class="error-actions">
                    <a href="${pageContext.request.contextPath}/auth/login" class="btn">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/auth/register" class="btn ghost">Đăng ký</a>
                  </div>
                </div>
              </c:when>
              <c:otherwise>
                <!-- User is logged in -->
                <c:set var="currentUser"
                  value="${not empty sessionScope.user ? sessionScope.user : sessionScope.authUser}" />

                <div class="profile-header">
                  <div class="profile-avatar">
                    <div class="avatar-circle">
                      <span class="avatar-initial">
                        <c:out value="${fn:substring(currentUser.fullname, 0, 1)}" />
                      </span>
                    </div>
                    <div class="avatar-info">
                      <h1>
                        <c:out value="${currentUser.fullname}" />
                      </h1>
                      <p class="user-role">
                        <c:choose>
                          <c:when test="${currentUser.role}">
                            <span class="role-badge admin">👑 Quản trị viên</span>
                          </c:when>
                          <c:otherwise>
                            <span class="role-badge reporter">📝 Phóng viên</span>
                          </c:otherwise>
                        </c:choose>
                      </p>
                    </div>
                  </div>
                </div>

                <!-- Profile Tabs -->
                <div class="profile-tabs">
                  <button class="tab-btn active" data-tab="info">📋 Thông tin cá nhân</button>
                  <button class="tab-btn" data-tab="security">🔐 Bảo mật</button>
                  <button class="tab-btn" data-tab="activity">📊 Hoạt động</button>
                </div>

                <!-- Tab Content -->
                <div class="tab-content">
                  <!-- Personal Info Tab -->
                  <div class="tab-pane active" id="info">
                    <div class="profile-card">
                      <div class="card-header">
                        <h3>Thông tin cá nhân</h3>
                        <p>Cập nhật thông tin cá nhân của bạn</p>
                      </div>

                      <c:if test="${not empty message}">
                        <div class="alert success">
                          <c:out value="${message}" />
                        </div>
                      </c:if>

                      <c:if test="${not empty error}">
                        <div class="alert error">
                          <c:out value="${error}" />
                        </div>
                      </c:if>

                      <form class="profile-form" method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="updateInfo" />

                        <div class="form-grid">
                          <div class="form-group">
                            <label for="fullname">Họ và tên *</label>
                            <input type="text" id="fullname" name="fullname"
                              value="<c:out value='${currentUser.fullname}'/>" required>
                          </div>

                          <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" value="<c:out value='${currentUser.email}'/>"
                              readonly>
                            <small>Email không thể thay đổi</small>
                          </div>

                          <div class="form-group">
                            <label for="mobile">Số điện thoại</label>
                            <input type="tel" id="mobile" name="mobile" value="<c:out value='${currentUser.mobile}'/>"
                              placeholder="Nhập số điện thoại">
                          </div>

                          <div class="form-group">
                            <label for="birthday">Ngày sinh</label>
                            <fmt:formatDate value="${currentUser.birthday}" pattern="yyyy-MM-dd"
                              var="birthdayFormatted" />
                            <input type="date" id="birthday" name="birthday" value="${birthdayFormatted}">
                          </div>

                          <div class="form-group">
                            <label for="gender">Giới tính</label>
                            <select id="gender" name="gender">
                              <option value="true" ${currentUser.gender ? 'selected' : '' }>Nam</option>
                              <option value="false" ${!currentUser.gender ? 'selected' : '' }>Nữ</option>
                            </select>
                          </div>

                          <div class="form-group full-width">
                            <label for="bio">Giới thiệu bản thân</label>
                            <textarea id="bio" name="bio" rows="4"
                              placeholder="Viết vài dòng giới thiệu về bản thân..."></textarea>
                          </div>
                        </div>

                        <div class="form-actions">
                          <button type="submit" class="btn primary">
                            💾 Lưu thay đổi
                          </button>
                          <button type="reset" class="btn ghost">
                            🔄 Khôi phục
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>

                  <!-- Security Tab -->
                  <div class="tab-pane" id="security">
                    <div class="profile-card">
                      <div class="card-header">
                        <h3>Bảo mật tài khoản</h3>
                        <p>Quản lý mật khẩu và bảo mật tài khoản</p>
                      </div>

                      <form class="profile-form" method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="changePassword" />

                        <div class="form-group">
                          <label for="currentPassword">Mật khẩu hiện tại *</label>
                          <input type="password" id="currentPassword" name="currentPassword" required>
                        </div>

                        <div class="form-group">
                          <label for="newPassword">Mật khẩu mới *</label>
                          <input type="password" id="newPassword" name="newPassword" required>
                          <small>Mật khẩu phải có ít nhất 6 ký tự</small>
                        </div>

                        <div class="form-group">
                          <label for="confirmPassword">Xác nhận mật khẩu mới *</label>
                          <input type="password" id="confirmPassword" name="confirmPassword" required>
                        </div>

                        <div class="form-actions">
                          <button type="submit" class="btn primary">
                            🔐 Đổi mật khẩu
                          </button>
                        </div>
                      </form>

                      <div class="security-info">
                        <h4>Thông tin bảo mật</h4>
                        <div class="security-item">
                          <span class="security-label">Trạng thái tài khoản:</span>
                          <span class="security-value ${currentUser.activated ? 'active' : 'inactive'}">
                            ${currentUser.activated ? '✅ Đã kích hoạt' : '❌ Chưa kích hoạt'}
                          </span>
                        </div>
                        <div class="security-item">
                          <span class="security-label">Vai trò:</span>
                          <span class="security-value">
                            ${currentUser.role ? 'Quản trị viên' : 'Phóng viên'}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Activity Tab -->
                  <div class="tab-pane" id="activity">
                    <div class="profile-card">
                      <div class="card-header">
                        <h3>Hoạt động gần đây</h3>
                        <p>Theo dõi các hoạt động của bạn trên hệ thống</p>
                      </div>

                      <div class="activity-stats">
                        <div class="stat-item">
                          <div class="stat-number">0</div>
                          <div class="stat-label">Bài viết đã đăng</div>
                        </div>
                        <div class="stat-item">
                          <div class="stat-number">0</div>
                          <div class="stat-label">Bài viết đã duyệt</div>
                        </div>
                        <div class="stat-item">
                          <div class="stat-number">0</div>
                          <div class="stat-label">Lượt xem</div>
                        </div>
                      </div>

                      <div class="activity-list">
                        <div class="activity-item">
                          <div class="activity-icon">🔑</div>
                          <div class="activity-content">
                            <div class="activity-title">Đăng nhập hệ thống</div>
                            <div class="activity-time">Hôm nay</div>
                          </div>
                        </div>
                        <!-- More activity items would be loaded from backend -->
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Quick Actions -->
                <div class="profile-actions">
                  <a href="${pageContext.request.contextPath}/auth/logout" class="btn danger">
                    🚪 Đăng xuất
                  </a>
                  <c:if test="${currentUser.role}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn">
                      ⚙️ Quản trị
                    </a>
                  </c:if>
                  <c:if test="${!currentUser.role}">
                    <a href="${pageContext.request.contextPath}/reporter/dashboard" class="btn">
                      📝 Dashboard
                    </a>
                  </c:if>
                </div>
              </c:otherwise>
            </c:choose>
          </main>

          <script>
            // Tab switching functionality
            document.addEventListener('DOMContentLoaded', function () {
              const tabButtons = document.querySelectorAll('.tab-btn');
              const tabPanes = document.querySelectorAll('.tab-pane');

              tabButtons.forEach(button => {
                button.addEventListener('click', function () {
                  const targetTab = this.getAttribute('data-tab');

                  // Remove active class from all buttons and panes
                  tabButtons.forEach(btn => btn.classList.remove('active'));
                  tabPanes.forEach(pane => pane.classList.remove('active'));

                  // Add active class to clicked button and corresponding pane
                  this.classList.add('active');
                  document.getElementById(targetTab).classList.add('active');
                });
              });

              // Password confirmation validation
              const newPasswordInput = document.getElementById('newPassword');
              const confirmPasswordInput = document.getElementById('confirmPassword');

              if (newPasswordInput && confirmPasswordInput) {
                function validatePasswordMatch() {
                  if (confirmPasswordInput.value && newPasswordInput.value !== confirmPasswordInput.value) {
                    confirmPasswordInput.setCustomValidity('Mật khẩu xác nhận không khớp');
                  } else {
                    confirmPasswordInput.setCustomValidity('');
                  }
                }

                newPasswordInput.addEventListener('input', validatePasswordMatch);
                confirmPasswordInput.addEventListener('input', validatePasswordMatch);
              }

              // Form validation
              const forms = document.querySelectorAll('.profile-form');
              forms.forEach(form => {
                form.addEventListener('submit', function (e) {
                  const requiredFields = form.querySelectorAll('[required]');
                  let isValid = true;

                  requiredFields.forEach(field => {
                    if (!field.value.trim()) {
                      field.classList.add('error');
                      isValid = false;
                    } else {
                      field.classList.remove('error');
                    }
                  });

                  if (!isValid) {
                    e.preventDefault();
                    alert('Vui lòng điền đầy đủ thông tin bắt buộc');
                  }
                });
              });
            });
          </script>

          <%@ include file="layout/footer.jsp" %>