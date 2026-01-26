package com.bridgeboard.dao;

import com.bridgeboard.model.Message;
import com.bridgeboard.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MessageDao {
    public int create(Message message) {
        String sql = "INSERT INTO messages (sender_id, recipient_id, skill_post_id, content, is_read) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, message.getSenderId());
            stmt.setInt(2, message.getRecipientId());
            if (message.getSkillPostId() == null) {
                stmt.setObject(3, null);
            } else {
                stmt.setInt(3, message.getSkillPostId());
            }
            stmt.setString(4, message.getContent());
            stmt.setBoolean(5, message.isRead());
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

    public List<Message> forUser(int userId, int limit) {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT m.*, u.name AS sender_name, sp.title AS skill_title FROM messages m " +
            "LEFT JOIN users u ON u.id = m.sender_id " +
            "LEFT JOIN skill_posts sp ON sp.id = m.skill_post_id " +
            "WHERE m.recipient_id = ? ORDER BY m.created_at DESC LIMIT ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    messages.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return messages;
    }

    private Message map(ResultSet rs) throws Exception {
        Message message = new Message();
        message.setId(rs.getInt("id"));
        message.setSenderId(rs.getInt("sender_id"));
        message.setRecipientId(rs.getInt("recipient_id"));
        int skillPostId = rs.getInt("skill_post_id");
        message.setSkillPostId(rs.wasNull() ? null : skillPostId);
        message.setContent(rs.getString("content"));
        message.setRead(rs.getBoolean("is_read"));
        message.setCreatedAt(rs.getTimestamp("created_at"));
        message.setSenderName(rs.getString("sender_name"));
        message.setSkillTitle(rs.getString("skill_title"));
        return message;
    }
}
