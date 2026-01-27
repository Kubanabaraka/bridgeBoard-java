package com.bridgeboard.dao;

import com.bridgeboard.model.SkillPost;
import com.bridgeboard.util.DbUtil;
import com.bridgeboard.util.JsonUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SkillPostDao {
    public int create(SkillPost post, String imagesJson) {
        String sql = "INSERT INTO skill_posts (user_id, category_id, title, description, location, price_min, price_max, images, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?::jsonb, ?::post_status)";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, post.getUserId());
            if (post.getCategoryId() == null) {
                stmt.setObject(2, null);
            } else {
                stmt.setInt(2, post.getCategoryId());
            }
            stmt.setString(3, post.getTitle());
            stmt.setString(4, post.getDescription());
            stmt.setString(5, post.getLocation());
            stmt.setBigDecimal(6, post.getPriceMin());
            stmt.setBigDecimal(7, post.getPriceMax());
            stmt.setString(8, imagesJson);
            stmt.setString(9, post.getStatus());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    public boolean update(int id, SkillPost post, String imagesJson) {
        String sql = "UPDATE skill_posts SET category_id = ?, title = ?, description = ?, location = ?, price_min = ?, price_max = ?, images = ?::jsonb, status = ?::post_status WHERE id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (post.getCategoryId() == null) {
                stmt.setObject(1, null);
            } else {
                stmt.setInt(1, post.getCategoryId());
            }
            stmt.setString(2, post.getTitle());
            stmt.setString(3, post.getDescription());
            stmt.setString(4, post.getLocation());
            stmt.setBigDecimal(5, post.getPriceMin());
            stmt.setBigDecimal(6, post.getPriceMax());
            stmt.setString(7, imagesJson);
            stmt.setString(8, post.getStatus());
            stmt.setInt(9, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM skill_posts WHERE id = ? AND user_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    public SkillPost findById(int id) {
        String sql = "SELECT sp.*, u.name AS user_name, u.avatar_path, c.name AS category_name " +
            "FROM skill_posts sp LEFT JOIN users u ON u.id = sp.user_id " +
            "LEFT JOIN categories c ON c.id = sp.category_id WHERE sp.id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    public List<SkillPost> forUser(int userId) {
        List<SkillPost> posts = new ArrayList<>();
        String sql = "SELECT * FROM skill_posts WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return posts;
    }

    public List<SkillPost> latest(int limit) {
        List<SkillPost> posts = new ArrayList<>();
        String sql = "SELECT sp.*, u.name AS user_name, c.name AS category_name " +
            "FROM skill_posts sp LEFT JOIN users u ON u.id = sp.user_id " +
            "LEFT JOIN categories c ON c.id = sp.category_id " +
            "ORDER BY sp.created_at DESC LIMIT ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return posts;
    }

    public List<SkillPost> search(String term, Integer categoryId, String location) {
        List<SkillPost> posts = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT sp.*, u.name AS user_name, c.name AS category_name FROM skill_posts sp LEFT JOIN users u ON u.id = sp.user_id LEFT JOIN categories c ON c.id = sp.category_id WHERE sp.status = 'active'");
        List<Object> params = new ArrayList<>();

        if (term != null && !term.isBlank()) {
            sql.append(" AND (sp.title LIKE ? OR sp.description LIKE ?)");
            String like = "%" + term + "%";
            params.add(like);
            params.add(like);
        }
        if (categoryId != null) {
            sql.append(" AND sp.category_id = ?");
            params.add(categoryId);
        }
        if (location != null && !location.isBlank()) {
            sql.append(" AND sp.location LIKE ?");
            params.add("%" + location + "%");
        }
        sql.append(" ORDER BY sp.created_at DESC");

        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return posts;
    }

    private SkillPost map(ResultSet rs) throws Exception {
        SkillPost post = new SkillPost();
        post.setId(rs.getInt("id"));
        post.setUserId(rs.getInt("user_id"));
        int categoryId = rs.getInt("category_id");
        post.setCategoryId(rs.wasNull() ? null : categoryId);
        post.setTitle(rs.getString("title"));
        post.setDescription(rs.getString("description"));
        post.setLocation(rs.getString("location"));
        BigDecimal priceMin = rs.getBigDecimal("price_min");
        BigDecimal priceMax = rs.getBigDecimal("price_max");
        post.setPriceMin(priceMin);
        post.setPriceMax(priceMax);
        post.setImages(JsonUtil.parseImages(rs.getString("images")));
        post.setStatus(rs.getString("status"));
        post.setCreatedAt(rs.getTimestamp("created_at"));
        post.setUpdatedAt(rs.getTimestamp("updated_at"));
        post.setUserName(getOptionalString(rs, "user_name"));
        post.setUserAvatar(getOptionalString(rs, "avatar_path"));
        post.setCategoryName(getOptionalString(rs, "category_name"));
        return post;
    }

    private String getOptionalString(ResultSet rs, String column) {
        try {
            rs.findColumn(column);
            return rs.getString(column);
        } catch (Exception ex) {
            return null;
        }
    }
}
