-- Lọc nhanh theo trạng thái chờ duyệt và ngày đăng
CREATE INDEX IX_News_Approved_PostedDate
ON dbo.News (Approved, PostedDate DESC)
INCLUDE (Title, Image, CategoryId, ReporterId, ViewCount, Home);

-- Lọc theo chuyên mục + trạng thái duyệt
CREATE INDEX IX_News_Category_Approved
ON dbo.News (CategoryId, Approved)
INCLUDE (Title, PostedDate, ReporterId);

-- Lọc theo phóng viên + trạng thái duyệt
CREATE INDEX IX_News_Reporter_Approved
ON dbo.News (ReporterId, Approved)
INCLUDE (Title, PostedDate, CategoryId);
