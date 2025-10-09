package com.newsportal.model;

public class SocialLink {
    private int id;
    private String name;
    private String url;
    private String icon;
    private boolean active;
    private int sortOrder;
    
    
    // getters/setters/constructor
	public SocialLink() {
		super();
	}


	public SocialLink(int id, String name, String url, String icon, boolean active, int sortOrder) {
		super();
		this.id = id;
		this.name = name;
		this.url = url;
		this.icon = icon;
		this.active = active;
		this.sortOrder = sortOrder;
	}


	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public String getUrl() {
		return url;
	}


	public void setUrl(String url) {
		this.url = url;
	}


	public String getIcon() {
		return icon;
	}


	public void setIcon(String icon) {
		this.icon = icon;
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
	
	
}
