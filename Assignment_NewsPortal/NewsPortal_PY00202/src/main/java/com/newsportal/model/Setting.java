package com.newsportal.model;

import java.time.LocalDateTime;

public class Setting {
    private String key;
    private String value;
    private String type;      // string|int|bool|json
    private String groupName; // site|seo|mail|...
    private java.time.LocalDateTime updatedAt;
	public Setting(String key, String value, String type, String groupName, LocalDateTime updatedAt) {
		super();
		this.key = key;
		this.value = value;
		this.type = type;
		this.groupName = groupName;
		this.updatedAt = updatedAt;
	}
	public Setting() {
		super();
	}
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getGroupName() {
		return groupName;
	}
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}
	public java.time.LocalDateTime getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(java.time.LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
    
    
    
    
}
