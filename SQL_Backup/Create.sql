/* ============================================
   TẠO DATABASE & CẤU HÌNH
============================================ */
CREATE DATABASE NewsPortal;
GO

USE NewsPortal;
GO

ALTER DATABASE NewsPortal SET RECOVERY SIMPLE;
GO

/* ============================================
   1) BẢNG NGƯỜI DÙNG
============================================ */
CREATE TABLE dbo.Users
(
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Password  NVARCHAR(255)   NOT NULL,        -- tạm plaintext cho ASM; sau có thể hash
    Fullname  NVARCHAR(100)   NOT NULL,
    Birthday  DATE            NULL,
    Gender    BIT             NULL,            -- 1=Nam, 0=Nữ
    Mobile    VARCHAR(20)     NULL,
    Email     VARCHAR(100)    NOT NULL,
    Role      VARCHAR(20)     NOT NULL
        CONSTRAINT CK_Users_Role CHECK (Role IN ('ADMIN','REPORTER','READER')),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

/* ============================================
   2) BẢNG CHUYÊN MỤC
============================================ */
CREATE TABLE dbo.Categories
(
    Id    INT IDENTITY(1,1) PRIMARY KEY,
    Name  NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Categories_Name UNIQUE (Name)
);
GO

/* ============================================
   3) BẢNG BÀI VIẾT
============================================ */
CREATE TABLE dbo.News
(
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    Title       NVARCHAR(255)   NOT NULL,
    [Content]   NVARCHAR(MAX)   NULL,
    Image       NVARCHAR(255)   NULL,
    PostedDate  DATETIME2       NOT NULL CONSTRAINT DF_News_PostedDate DEFAULT (SYSUTCDATETIME()),
    Author      NVARCHAR(100)   NULL,
    ViewCount   INT             NOT NULL CONSTRAINT DF_News_ViewCount DEFAULT (0),
    CategoryId  INT             NOT NULL,
    Home        BIT             NOT NULL CONSTRAINT DF_News_Home DEFAULT (0),
    Approved    BIT             NOT NULL CONSTRAINT DF_News_Approved DEFAULT (0),
    ReporterId  INT             NULL,

    CONSTRAINT FK_News_Categories FOREIGN KEY (CategoryId)
        REFERENCES dbo.Categories(Id),
    CONSTRAINT FK_News_Users FOREIGN KEY (ReporterId)
        REFERENCES dbo.Users(Id)
);
GO

/* ============================================
   4) BẢNG NEWSLETTERS
============================================ */
CREATE TABLE dbo.Newsletters
(
    Email    VARCHAR(100) PRIMARY KEY,
    Enabled  BIT NOT NULL CONSTRAINT DF_Newsletters_Enabled DEFAULT (1)
);
GO

/* ============================================
   5) INDEX HỖ TRỢ TÌM KIẾM / SẮP XẾP
============================================ */
CREATE INDEX IX_News_Title       ON dbo.News(Title);
CREATE INDEX IX_News_PostedDate  ON dbo.News(PostedDate DESC);
CREATE INDEX IX_News_Category    ON dbo.News(CategoryId);
GO

/* ============================================
   6) DỮ LIỆU MẪU BAN ĐẦU
============================================ */
-- Users
INSERT INTO dbo.Users (Password, Fullname, Birthday, Gender, Mobile, Email, Role) VALUES
('123456', N'Quản trị viên',  '1990-01-01', 1, '0900000000', 'admin@example.com',    'ADMIN'),
('123456', N'Phóng viên A',   '1995-05-05', 1, '0900000001', 'reporter@example.com', 'REPORTER'),
('123456', N'Bạn đọc B',      '2000-10-10', 0, '0900000002', 'reader@example.com',   'READER');

-- Categories
INSERT INTO dbo.Categories (Name) VALUES
(N'Tin tức'), (N'Thể thao'), (N'Công nghệ');

-- News
INSERT INTO dbo.News (Title, [Content], Image, Author, CategoryId, Home, Approved, ReporterId)
VALUES
(N'Tiêu đề bài viết mẫu 1',
 N'Mô tả/ Nội dung bài viết 1...',
 N'assets/img/sample1.jpg', N'Phóng viên A', 1, 1, 1, 2),
(N'Tiêu đề bài viết mẫu 2',
 N'Nội dung bài viết 2 (chờ duyệt)...',
 N'assets/img/sample2.jpg', N'Phóng viên A', 2, 0, 0, 2);
GO

/* ============================================
   7) THAY ĐỔI CẤU TRÚC CỘT ROLE & THÊM ACTIVATED
============================================ */
-- Xoá constraint CHECK cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Users_Role')
BEGIN
    ALTER TABLE Users DROP CONSTRAINT CK_Users_Role;
END
GO

-- Xoá cột Role kiểu cũ nếu tồn tại
IF EXISTS (SELECT * FROM sys.columns WHERE Name = N'Role' AND Object_ID = Object_ID(N'Users'))
BEGIN
    ALTER TABLE Users DROP COLUMN Role;
END
GO

-- Thêm lại cột Role dạng BIT
ALTER TABLE Users ADD Role BIT NOT NULL DEFAULT 0;
GO

-- Thêm cột Activated
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Activated' AND Object_ID = Object_ID(N'Users'))
BEGIN
    ALTER TABLE Users ADD Activated BIT NOT NULL DEFAULT 0;
END
GO

/* ============================================
   8) THÊM NGƯỜI DÙNG MẪU MỚI
============================================ */
INSERT INTO Users (Fullname, Email, [Password], Mobile, Birthday, Gender, Role, Activated)
VALUES
(N'Nguyễn Phóng Viên', 'reporter@test.com', '123456', '0900000000', NULL, 1, 0, 1);

INSERT INTO Users (Fullname, Email, [Password], Mobile, Birthday, Gender, Role, Activated)
VALUES
(N'Nguyễn Admin', 'admin@test.com', '123456', '0900000000', NULL, 1, 1, 1);
GO
