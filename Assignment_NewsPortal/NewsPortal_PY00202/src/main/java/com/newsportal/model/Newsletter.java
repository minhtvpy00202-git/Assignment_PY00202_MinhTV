package com.newsportal.model;

public class Newsletter {
    private String email;   // PK
    private boolean enabled;
    private boolean isDelete;
    private Integer categoryId;

    public Newsletter() {}

    

    


    public Newsletter(String email, boolean enabled, boolean isDelete, Integer categoryId) {
        this.email = email;
        this.enabled = enabled;
        this.isDelete = isDelete;
        this.categoryId = categoryId;
    }






	public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }



	public boolean isDelete() {
		return isDelete;
	}



	public void setDelete(boolean isDelete) {
		this.isDelete = isDelete;
	}






	public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
	
    
    
}
