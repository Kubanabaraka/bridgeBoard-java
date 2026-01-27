package com.bridgeboard.dao;

import com.bridgeboard.model.Favorite;
import com.bridgeboard.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDao {
    public boolean add(int userId, int skillPostId) {
        String sql = "INSERT INTO favorites (user_id, skill_post_id) VALUES (?, ?) ON CONFLICT (user_id, skill_post_id) DO NOTHING";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, skillPostId);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    public boolean remove(int userId, int skillPostId) {
        String sql = "DELETE FROM favorites WHERE user_id = ? AND skill_post_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, skillPostId);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    public boolean exists(int userId, int skillPostId) {
        String sql = "SELECT 1 FROM favorites WHERE user_id = ? AND skill_post_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, skillPostId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception ignored) {
        }
        return false;
    }

    public List<Favorite> forUser(int userId) {
        List<Favorite> favorites = new ArrayList<>();
        String sql = "SELECT * FROM favorites WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    favorites.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return favorites;
    }

    public int countForUser(int userId) {
        String sql = "SELECT COUNT(*) FROM favorites WHERE user_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    public int create(Favorite favorite) {
        String sql = "INSERT INTO favorites (user_id, skill_post_id) VALUES (?, ?)";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, favorite.getUserId());
            stmt.setInt(2, favorite.getSkillPostId());
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

    private Favorite map(ResultSet rs) throws Exception {
        Favorite favorite = new Favorite();
        favorite.setId(rs.getInt("id"));
        favorite.setUserId(rs.getInt("user_id"));
        favorite.setSkillPostId(rs.getInt("skill_post_id"));
        favorite.setCreatedAt(rs.getTimestamp("created_at"));
        return favorite;
    }
}
