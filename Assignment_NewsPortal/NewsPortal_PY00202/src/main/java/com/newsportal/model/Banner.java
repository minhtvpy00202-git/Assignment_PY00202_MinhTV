package com.newsportal.model;

import java.time.LocalDateTime;

public class Banner {
    private int id;
    private String title;
    private String imageUrl;
    private String linkUrl;
    private boolean active;
    private int sortOrder;
    private java.time.LocalDateTime createdAt;
	
    
    public Banner() {
		super();
	}


	public Banner(int id, String title, String imageUrl, String linkUrl, boolean active, int sortOrder,
			LocalDateTime createdAt) {
		super();
		this.id = id;
		this.title = title;
		this.imageUrl = imageUrl;
		this.linkUrl = linkUrl;
		this.active = active;
		this.sortOrder = sortOrder;
		this.createdAt = createdAt;
	}


	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public String getTitle() {
		return title;
	}


	public void setTitle(String title) {
		this.title = title;
	}


	public String getImageUrl() {
		return imageUrl;
	}


	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}


	public String getLinkUrl() {
		return linkUrl;
	}


	public void setLinkUrl(String linkUrl) {
		this.linkUrl = linkUrl;
	}


	public boolean isActive() {
		return active;
	}


	public void setActive(boolean active) {
		this.active = active;
	}


	public int getSortOrder() {
		return sortOrder;
	}


	public void setSortOrder(int sortOrder) {
		this.sortOrder = sortOrder;
	}


	public java.time.LocalDateTime getCreatedAt() {
		return createdAt;
	}


	public void setCreatedAt(java.time.LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}


    
    
}
