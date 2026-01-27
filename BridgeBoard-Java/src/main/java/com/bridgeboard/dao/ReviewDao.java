package com.bridgeboard.dao;

import com.bridgeboard.model.Review;
import com.bridgeboard.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ReviewDao {
    public int create(Review review) {
        String sql = "INSERT INTO reviews (exchange_id, reviewer_id, reviewee_id, rating, comment) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, review.getExchangeId());
            stmt.setInt(2, review.getReviewerId());
            stmt.setInt(3, review.getRevieweeId());
            stmt.setInt(4, review.getRating());
            stmt.setString(5, review.getComment());
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

    public Review findById(int id) {
        String sql = "SELECT * FROM reviews WHERE id = ?";
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

    public List<Review> forUser(int userId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT * FROM reviews WHERE reviewee_id = ? ORDER BY created_at DESC";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return reviews;
    }

    public Review forExchangeAndReviewer(int exchangeId, int reviewerId) {
        String sql = "SELECT * FROM reviews WHERE exchange_id = ? AND reviewer_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, exchangeId);
            stmt.setInt(2, reviewerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM reviews WHERE id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    private Review map(ResultSet rs) throws Exception {
        Review review = new Review();
        review.setId(rs.getInt("id"));
        review.setExchangeId(rs.getInt("exchange_id"));
        review.setReviewerId(rs.getInt("reviewer_id"));
        review.setRevieweeId(rs.getInt("reviewee_id"));
        review.setRating(rs.getInt("rating"));
        review.setComment(rs.getString("comment"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        return review;
    }
}
