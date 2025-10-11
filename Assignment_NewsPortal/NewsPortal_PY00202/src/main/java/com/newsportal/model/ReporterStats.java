package com.newsportal.model;

public class ReporterStats {
    private int total;
    private int pending;
    private int approved;
    
    public ReporterStats() {}
    
    public ReporterStats(int total, int pending, int approved) {
        this.total = total;
        this.pending = pending;
        this.approved = approved;
    }
    
    public int getTotal() {
        return total;
    }
    
    public void setTotal(int total) {
        this.total = total;
    }
    
    public int getPending() {
        return pending;
    }
    
    public void setPending(int pending) {
        this.pending = pending;
    }
    
    public int getApproved() {
        return approved;
    }
    
    public void setApproved(int approved) {
        this.approved = approved;
    }
}