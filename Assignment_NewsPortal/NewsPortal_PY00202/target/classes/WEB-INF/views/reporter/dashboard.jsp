<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <c:set var="pageTitle" value="Dashboard Phóng viên - NewsPortal" />

    <%@ include file="../layout/admin-header.jsp" %>

      <!-- Main Content -->
      <main class="modern-main-content">
        <div class="content-container">
          <!-- Page Header -->
          <div class="page-header">
            <div class="page-title-section">
              <h1 class="page-title">Dashboard Phóng viên</h1>
              <p class="page-subtitle">Tổng quan hoạt động và quản lý bài viết của bạn</p>
            </div>
            <div class="page-actions">
              <a href="${pageContext.request.contextPath}/reporter/post-create" class="btn-primary">
                <span class="btn-icon">✏️</span>
                <span class="btn-text">Viết bài mới</span>
              </a>
            </div>
          </div>

          <!-- Statistics Cards -->
          <div class="stats-grid">
            <div class="stat-card total">
              <div class="stat-icon">📊</div>
              <div class="stat-content">
                <div class="stat-number">${stats != null ? stats.total : 0}</div>
                <div class="stat-label">Tổng bài viết</div>
              </div>
              <div class="stat-trend">
                <span class="trend-indicator positive">📈</span>
              </div>
            </div>

            <div class="stat-card pending">
              <div class="stat-icon">⏳</div>
              <div class="stat-content">
                <div class="stat-number">${stats != null ? stats.pending : 0}</div>
                <div class="stat-label">Chờ duyệt</div>
              </div>
              <div class="stat-trend">
                <span class="trend-indicator neutral">⏸️</span>
              </div>
            </div>

            <div class="stat-card approved">
              <div class="stat-icon">✅</div>
              <div class="stat-content">
                <div class="stat-number">${stats != null ? stats.approved : 0}</div>
                <div class="stat-label">Đã duyệt</div>
              </div>
              <div class="stat-trend">
                <span class="trend-indicator positive">🎉</span>
              </div>
            </div>
          </div>

          <!-- Quick Actions Section -->
          <div class="dashboard-sections">
            <div class="dashboard-section">
              <div class="section-header">
                <h2 class="section-title">Hành động nhanh</h2>
                <p class="section-subtitle">Các tác vụ thường dùng để quản lý nội dung</p>
              </div>

              <div class="quick-actions-grid">
                <a href="${pageContext.request.contextPath}/reporter/post-create" class="quick-action-card create">
                  <div class="action-icon">✏️</div>
                  <div class="action-content">
                    <h3 class="action-title">Viết bài mới</h3>
                    <p class="action-description">Tạo bài viết mới và chia sẻ thông tin</p>
                  </div>
                  <div class="action-arrow">→</div>
                </a>

                <a href="${pageContext.request.contextPath}/reporter/posts" class="quick-action-card manage">
                  <div class="action-icon">📝</div>
                  <div class="action-content">
                    <h3 class="action-title">Quản lý bài viết</h3>
                    <p class="action-description">Xem, chỉnh sửa và quản lý các bài viết</p>
                  </div>
                  <div class="action-arrow">→</div>
                </a>

                <a href="${pageContext.request.contextPath}/home" class="quick-action-card view">
                  <div class="action-icon">👁️</div>
                  <div class="action-content">
                    <h3 class="action-title">Xem trang chủ</h3>
                    <p class="action-description">Xem giao diện người dùng cuối</p>
                  </div>
                  <div class="action-arrow">→</div>
                </a>
              </div>
            </div>
          </div>
        </div>
      </main>

      <style>
        /* Modern Dashboard Styles */
        .modern-main-content {
          min-height: calc(100vh - 70px);
          background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
          padding: 2rem 0;
        }

        .content-container {
          max-width: 1400px;
          margin: 0 auto;
          padding: 0 2rem;
        }

        /* Page Header */
        .page-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 3rem;
          background: white;
          padding: 2rem;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        .page-title-section {
          flex: 1;
        }

        .page-title {
          font-size: 2.5rem;
          font-weight: 700;
          color: #2d3748;
          margin: 0 0 0.5rem 0;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
        }

        .page-subtitle {
          color: #718096;
          font-size: 1.1rem;
          margin: 0;
          line-height: 1.5;
        }

        .page-actions {
          display: flex;
          gap: 1rem;
        }

        .btn-primary {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 1rem 2rem;
          border-radius: 12px;
          text-decoration: none;
          font-weight: 600;
          transition: all 0.3s ease;
          box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:hover {
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
        }

        .btn-icon {
          font-size: 1.2rem;
        }

        /* Statistics Grid */
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
          margin-bottom: 3rem;
        }

        .stat-card {
          background: white;
          padding: 2rem;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
          display: flex;
          align-items: center;
          gap: 1.5rem;
          transition: all 0.3s ease;
          position: relative;
          overflow: hidden;
        }

        .stat-card::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 4px;
          background: linear-gradient(90deg, #667eea, #764ba2);
        }

        .stat-card:hover {
          transform: translateY(-4px);
          box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
        }

        .stat-card.total::before {
          background: linear-gradient(90deg, #3182ce, #2c5282);
        }

        .stat-card.pending::before {
          background: linear-gradient(90deg, #ed8936, #dd6b20);
        }

        .stat-card.approved::before {
          background: linear-gradient(90deg, #38a169, #2f855a);
        }

        .stat-icon {
          font-size: 3rem;
          opacity: 0.8;
        }

        .stat-content {
          flex: 1;
        }

        .stat-number {
          font-size: 2.5rem;
          font-weight: 700;
          color: #2d3748;
          line-height: 1;
          margin-bottom: 0.5rem;
        }

        .stat-label {
          color: #718096;
          font-size: 1rem;
          font-weight: 500;
        }

        .stat-trend {
          font-size: 1.5rem;
        }

        .trend-indicator.positive {
          color: #38a169;
        }

        .trend-indicator.neutral {
          color: #ed8936;
        }

        /* Dashboard Sections */
        .dashboard-sections {
          display: grid;
          gap: 2rem;
        }

        .dashboard-section {
          background: white;
          border-radius: 16px;
          padding: 2rem;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        .section-header {
          margin-bottom: 2rem;
        }

        .section-title {
          font-size: 1.5rem;
          font-weight: 600;
          color: #2d3748;
          margin: 0 0 0.5rem 0;
        }

        .section-subtitle {
          color: #718096;
          margin: 0;
          line-height: 1.5;
        }

        /* Quick Actions */
        .quick-actions-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 1.5rem;
        }

        .quick-action-card {
          display: flex;
          align-items: center;
          gap: 1.5rem;
          padding: 1.5rem;
          border: 2px solid #e2e8f0;
          border-radius: 12px;
          text-decoration: none;
          transition: all 0.3s ease;
          background: #f8fafc;
        }

        .quick-action-card:hover {
          border-color: #667eea;
          background: white;
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
        }

        .action-icon {
          font-size: 2.5rem;
          opacity: 0.8;
        }

        .action-content {
          flex: 1;
        }

        .action-title {
          font-size: 1.1rem;
          font-weight: 600;
          color: #2d3748;
          margin: 0 0 0.5rem 0;
        }

        .action-description {
          color: #718096;
          font-size: 0.9rem;
          margin: 0;
          line-height: 1.4;
        }

        .action-arrow {
          font-size: 1.5rem;
          color: #667eea;
          font-weight: bold;
        }

        /* Mobile Responsive */
        @media (max-width: 480px) {
          .modern-main-content {
            padding: 1rem 0;
          }
          
          .content-container {
            padding: 0 0.5rem;
          }

          .page-header {
            flex-direction: column;
            gap: 1rem;
            align-items: stretch;
            padding: 1rem;
            margin-bottom: 1.5rem;
          }
          
          .page-title {
            font-size: 1.75rem;
            text-align: center;
          }
          
          .page-subtitle {
            text-align: center;
            font-size: 1rem;
          }
          
          .btn-primary {
            width: 100%;
            justify-content: center;
            padding: 1rem;
          }
          
          .stats-grid {
            grid-template-columns: 1fr;
            gap: 1rem;
            margin-bottom: 2rem;
          }
          
          .stat-card {
            padding: 1.5rem 1rem;
            flex-direction: column;
            text-align: center;
            gap: 1rem;
          }
          
          .stat-icon {
            font-size: 2.5rem;
          }
          
          .stat-number {
            font-size: 2rem;
          }
          
          .dashboard-section {
            padding: 1.5rem 1rem;
            margin: 0 -0.5rem 1rem -0.5rem;
            border-radius: 0;
          }
          
          .quick-actions-grid {
            grid-template-columns: 1fr;
            gap: 1rem;
          }
          
          .quick-action-card {
            flex-direction: column;
            text-align: center;
            gap: 1rem;
            padding: 1.5rem 1rem;
          }
          
          .action-icon {
            font-size: 3rem;
          }
          
          .action-arrow {
            display: none;
          }
        }

        /* Tablet Responsive */
        @media (min-width: 481px) and (max-width: 768px) {
          .content-container {
            padding: 0 1rem;
          }
          
          .page-header {
            flex-direction: column;
            gap: 1.5rem;
            align-items: center;
            text-align: center;
          }
          
          .stats-grid {
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
          }
          
          .quick-actions-grid {
            grid-template-columns: repeat(2, 1fr);
          }
        }

        /* Large Tablet */
        @media (min-width: 769px) and (max-width: 1024px) {
          .stats-grid {
            grid-template-columns: repeat(3, 1fr);
          }
          
          .quick-actions-grid {
            grid-template-columns: repeat(2, 1fr);
          }
        }
      </style>

      <%@ include file="../layout/footer.jsp" %>