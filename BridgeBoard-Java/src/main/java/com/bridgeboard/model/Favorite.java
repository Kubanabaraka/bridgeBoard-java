package com.bridgeboard.model;

import java.sql.Timestamp;

public class Favorite {
    private int id;
    private int userId;
    private int skillPostId;
    private Timestamp createdAt;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getSkillPostId() {
        return skillPostId;
    }

    public void setSkillPostId(int skillPostId) {
        this.skillPostId = skillPostId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
