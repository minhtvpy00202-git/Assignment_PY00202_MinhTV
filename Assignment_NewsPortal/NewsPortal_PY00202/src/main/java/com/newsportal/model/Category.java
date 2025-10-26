package com.newsportal.model;

public class Category {
    private int id;
    private String name;
    private boolean isDelete;

    public Category() {}
    

    public Category(int id, String name, boolean isDelete) {
		super();
		this.id = id;
		this.name = name;
		this.isDelete = isDelete;
	}


	public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }


	public boolean isDelete() {
		return isDelete;
	}


	public void setDelete(boolean isDelete) {
		this.isDelete = isDelete;
	}
    
    
}
