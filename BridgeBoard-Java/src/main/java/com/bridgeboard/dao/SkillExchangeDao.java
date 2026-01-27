package com.bridgeboard.dao;

import com.bridgeboard.model.SkillExchange;
import com.bridgeboard.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SkillExchangeDao {
    public int create(SkillExchange exchange) {
        String sql = "INSERT INTO skill_exchanges (requester_id, provider_id, skill_post_id, exchange_type, agreed_price, status, notes) " +
            "VALUES (?, ?, ?, ?::exchange_type, ?, ?::exchange_status, ?)";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, exchange.getRequesterId());
            stmt.setInt(2, exchange.getProviderId());
            stmt.setInt(3, exchange.getSkillPostId());
            stmt.setString(4, exchange.getExchangeType());
            stmt.setBigDecimal(5, exchange.getAgreedPrice());
            stmt.setString(6, exchange.getStatus());
            stmt.setString(7, exchange.getNotes());
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

    public SkillExchange findById(int id) {
        String sql = "SELECT * FROM skill_exchanges WHERE id = ?";
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

    public List<SkillExchange> forUser(int userId) {
        List<SkillExchange> exchanges = new ArrayList<>();
        String sql = "SELECT * FROM skill_exchanges WHERE requester_id = ? OR provider_id = ? ORDER BY requested_at DESC";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    exchanges.add(map(rs));
                }
            }
        } catch (Exception ignored) {
        }
        return exchanges;
    }

    public int countForUser(int userId) {
        String sql = "SELECT COUNT(*) FROM skill_exchanges WHERE requester_id = ? OR provider_id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    public int countPendingForUser(int userId) {
        String sql = "SELECT COUNT(*) FROM skill_exchanges WHERE (requester_id = ? OR provider_id = ?) AND status = 'pending'";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    public boolean update(SkillExchange exchange) {
        String sql = "UPDATE skill_exchanges SET exchange_type = ?::exchange_type, agreed_price = ?, status = ?::exchange_status, notes = ?, responded_at = ?, completed_at = ? WHERE id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, exchange.getExchangeType());
            stmt.setBigDecimal(2, exchange.getAgreedPrice());
            stmt.setString(3, exchange.getStatus());
            stmt.setString(4, exchange.getNotes());
            stmt.setTimestamp(5, exchange.getRespondedAt());
            stmt.setTimestamp(6, exchange.getCompletedAt());
            stmt.setInt(7, exchange.getId());
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM skill_exchanges WHERE id = ?";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    private SkillExchange map(ResultSet rs) throws Exception {
        SkillExchange exchange = new SkillExchange();
        exchange.setId(rs.getInt("id"));
        exchange.setRequesterId(rs.getInt("requester_id"));
        exchange.setProviderId(rs.getInt("provider_id"));
        exchange.setSkillPostId(rs.getInt("skill_post_id"));
        exchange.setExchangeType(rs.getString("exchange_type"));
        exchange.setAgreedPrice(rs.getBigDecimal("agreed_price"));
        exchange.setStatus(rs.getString("status"));
        exchange.setNotes(rs.getString("notes"));
        exchange.setRequestedAt(rs.getTimestamp("requested_at"));
        exchange.setRespondedAt(rs.getTimestamp("responded_at"));
        exchange.setCompletedAt(rs.getTimestamp("completed_at"));
        return exchange;
    }
}
