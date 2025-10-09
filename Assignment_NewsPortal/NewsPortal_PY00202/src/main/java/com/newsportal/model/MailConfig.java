package com.newsportal.model;

import java.time.LocalDateTime;

public class MailConfig {
    private int id;
    private String smtpHost;
    private int smtpPort;
    private String username;
    private String password;
    private boolean useSSL;
    private boolean useTLS;
    private String senderName;
    private String senderEmail;
    private boolean active;
    private java.time.LocalDateTime updatedAt;
	
    
    public MailConfig() {
		super();
	}


	public MailConfig(int id, String smtpHost, int smtpPort, String username, String password, boolean useSSL,
			boolean useTLS, String senderName, String senderEmail, boolean active, LocalDateTime updatedAt) {
		super();
		this.id = id;
		this.smtpHost = smtpHost;
		this.smtpPort = smtpPort;
		this.username = username;
		this.password = password;
		this.useSSL = useSSL;
		this.useTLS = useTLS;
		this.senderName = senderName;
		this.senderEmail = senderEmail;
		this.active = active;
		this.updatedAt = updatedAt;
	}


	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public String getSmtpHost() {
		return smtpHost;
	}


	public void setSmtpHost(String smtpHost) {
		this.smtpHost = smtpHost;
	}


	public int getSmtpPort() {
		return smtpPort;
	}


	public void setSmtpPort(int smtpPort) {
		this.smtpPort = smtpPort;
	}


	public String getUsername() {
		return username;
	}


	public void setUsername(String username) {
		this.username = username;
	}


	public String getPassword() {
		return password;
	}


	public void setPassword(String password) {
		this.password = password;
	}


	public boolean isUseSSL() {
		return useSSL;
	}


	public void setUseSSL(boolean useSSL) {
		this.useSSL = useSSL;
	}


	public boolean isUseTLS() {
		return useTLS;
	}


	public void setUseTLS(boolean useTLS) {
		this.useTLS = useTLS;
	}


	public String getSenderName() {
		return senderName;
	}


	public void setSenderName(String senderName) {
		this.senderName = senderName;
	}


	public String getSenderEmail() {
		return senderEmail;
	}


	public void setSenderEmail(String senderEmail) {
		this.senderEmail = senderEmail;
	}


	public boolean isActive() {
		return active;
	}


	public void setActive(boolean active) {
		this.active = active;
	}


	public java.time.LocalDateTime getUpdatedAt() {
		return updatedAt;
	}


	public void setUpdatedAt(java.time.LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
    
    
    
    
    // getters/setters
    
    
}
