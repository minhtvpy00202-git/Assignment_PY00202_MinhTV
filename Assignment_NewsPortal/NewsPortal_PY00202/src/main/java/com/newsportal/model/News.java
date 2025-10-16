package com.newsportal.model;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.jsoup.Jsoup;

public class News {
    private int id;
    private String title;
    private String content;      // NVARCHAR(MAX)
    private String image;        // đường dẫn ảnh (có thể null)
    private LocalDateTime postedDate; // DATETIME2
    private String author;       // có thể null
    private int viewCount;
    private int categoryId;      // FK NOT NULL
    private boolean home;        // hiển thị trang chủ
    private boolean approved;    // đã duyệt
    private Integer reporterId;  // FK Users, có thể null

    public News() {}

    public News(int id, String title, String content, String image,
                LocalDateTime postedDate, String author, int viewCount,
                int categoryId, boolean home, boolean approved, Integer reporterId) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.image = image;
        this.postedDate = postedDate;
        this.author = author;
        this.viewCount = viewCount;
        this.categoryId = categoryId;
        this.home = home;
        this.approved = approved;
        this.reporterId = reporterId;
    }

    // --- Getters/Setters ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public LocalDateTime getPostedDate() { return postedDate; }
    public void setPostedDate(LocalDateTime postedDate) { this.postedDate = postedDate; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public boolean isHome() { return home; }
    public void setHome(boolean home) { this.home = home; }

    public boolean isApproved() { return approved; }
    public void setApproved(boolean approved) { this.approved = approved; }

    public Integer getReporterId() { return reporterId; }
    public void setReporterId(Integer reporterId) { this.reporterId = reporterId; }
    
    public String getPostedDateFormatted() {
        if (postedDate == null) return "";

        // Định dạng ngày giờ kèm giờ phút và múi giờ
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy - HH:mm '(GMT+7)'");

        // Nếu muốn chính xác theo múi giờ Việt Nam
        ZonedDateTime vnTime = postedDate.atZone(ZoneId.of("Asia/Ho_Chi_Minh"));
        
        return vnTime.format(formatter);
    }
    
    public String getExcerpt() {
        if (content == null) return "";
        String text = Jsoup.parse(content).text();   // bỏ toàn bộ thẻ HTML
        text = text.trim().replaceAll("\\s+", " ");
        return text.length() > 300 ? text.substring(0, 300) + "..." : text;
    }

}
