# Requirements Document

## Introduction

Tính năng Reporter Dashboard Statistics cho phép phóng viên xem thống kê tổng quan về các bài viết của họ trên dashboard. Hiện tại dashboard đã có giao diện hiển thị nhưng chưa load được dữ liệu thống kê (tổng bài viết, bài chờ duyệt, đã duyệt) do thiếu controller logic và model để truyền dữ liệu.

## Requirements

### Requirement 1

**User Story:** Là một phóng viên, tôi muốn xem tổng số bài viết mà tôi đã tạo trên dashboard, để có cái nhìn tổng quan về hoạt động viết bài của mình.

#### Acceptance Criteria

1. WHEN phóng viên truy cập dashboard THEN hệ thống SHALL hiển thị tổng số bài viết của phóng viên đó
2. WHEN phóng viên chưa có bài viết nào THEN hệ thống SHALL hiển thị số 0
3. WHEN có lỗi kết nối database THEN hệ thống SHALL hiển thị thông báo lỗi thay vì crash

### Requirement 2

**User Story:** Là một phóng viên, tôi muốn xem số bài viết đang chờ duyệt của mình, để biết có bao nhiêu bài cần chờ editor phê duyệt.

#### Acceptance Criteria

1. WHEN phóng viên truy cập dashboard THEN hệ thống SHALL hiển thị số bài viết có trạng thái Approved = 0 của phóng viên đó
2. WHEN phóng viên không có bài nào chờ duyệt THEN hệ thống SHALL hiển thị số 0
3. WHEN bài viết được duyệt hoặc từ chối THEN số liệu SHALL được cập nhật khi refresh trang

### Requirement 3

**User Story:** Là một phóng viên, tôi muốn xem số bài viết đã được duyệt của mình, để biết hiệu suất công việc và số bài đã publish thành công.

#### Acceptance Criteria

1. WHEN phóng viên truy cập dashboard THEN hệ thống SHALL hiển thị số bài viết có trạng thái Approved = 1 của phóng viên đó
2. WHEN phóng viên chưa có bài nào được duyệt THEN hệ thống SHALL hiển thị số 0
3. WHEN editor duyệt bài mới THEN số liệu SHALL được cập nhật khi phóng viên refresh dashboard

### Requirement 4

**User Story:** Là một phóng viên, tôi muốn dashboard load nhanh và hiển thị chính xác, để có trải nghiệm sử dụng tốt khi kiểm tra thống kê.

#### Acceptance Criteria

1. WHEN phóng viên truy cập dashboard THEN trang SHALL load trong vòng 2 giây
2. WHEN có nhiều phóng viên truy cập cùng lúc THEN mỗi người SHALL chỉ thấy thống kê của riêng mình
3. IF phóng viên chưa đăng nhập THEN hệ thống SHALL redirect về trang login
4. WHEN session hết hạn THEN hệ thống SHALL yêu cầu đăng nhập lại thay vì hiển thị lỗi

### Requirement 5

**User Story:** Là một phóng viên, tôi muốn thống kê được hiển thị với format dễ đọc và giao diện đẹp, để dễ dàng nắm bắt thông tin.

#### Acceptance Criteria

1. WHEN dashboard hiển thị thống kê THEN các số liệu SHALL được format với dấu phẩy phân cách hàng nghìn (nếu cần)
2. WHEN số liệu bằng 0 THEN vẫn SHALL hiển thị "0" thay vì để trống
3. WHEN có lỗi THEN SHALL hiển thị placeholder text thay vì undefined hoặc null
4. WHEN thống kê hiển thị THEN layout SHALL responsive trên mobile và desktop