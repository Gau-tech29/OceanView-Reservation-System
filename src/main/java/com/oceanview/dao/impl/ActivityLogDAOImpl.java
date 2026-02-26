package com.oceanview.dao.impl;

import com.oceanview.dao.ActivityLogDAO;
import com.oceanview.model.ActivityLog;
import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ActivityLogDAOImpl implements ActivityLogDAO {

    private static ActivityLogDAOImpl instance;

    private ActivityLogDAOImpl() {}

    public static synchronized ActivityLogDAOImpl getInstance() {
        if (instance == null) {
            instance = new ActivityLogDAOImpl();
        }
        return instance;
    }

    @Override
    public ActivityLog save(ActivityLog log) throws SQLException {
        String sql = "INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, " +
                "description, ip_address, user_agent, old_value, new_value, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, log.getUserId());
            ps.setString(2, log.getActionType());
            ps.setString(3, log.getEntityType());
            ps.setLong(4, log.getEntityId());
            ps.setString(5, log.getDescription());
            ps.setString(6, log.getIpAddress());
            ps.setString(7, log.getUserAgent());
            ps.setString(8, log.getOldValue());
            ps.setString(9, log.getNewValue());
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating activity log failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    log.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating activity log failed, no ID obtained.");
                }
            }
        }
        return log;
    }

    @Override
    public ActivityLog update(ActivityLog log) throws SQLException {
        // Activity logs are typically immutable, so update might not be needed
        throw new UnsupportedOperationException("Activity logs cannot be updated");
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM activity_logs WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<ActivityLog> findById(Long id) throws SQLException {
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "WHERE l.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToLog(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<ActivityLog> findAll() throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "ORDER BY l.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                logs.add(mapResultSetToLog(rs));
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findAll(int page, int size) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "ORDER BY l.created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findByUserId(Long userId) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "WHERE l.user_id = ? " +
                "ORDER BY l.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findByActionType(String actionType) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "WHERE l.action_type = ? " +
                "ORDER BY l.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, actionType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findByEntityType(String entityType, Long entityId) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "WHERE l.entity_type = ? AND l.entity_id = ? " +
                "ORDER BY l.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, entityType);
            ps.setLong(2, entityId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "WHERE l.created_at BETWEEN ? AND ? " +
                "ORDER BY l.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public List<ActivityLog> findRecentActivities(int limit) throws SQLException {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.username, u.first_name, u.last_name " +
                "FROM activity_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "ORDER BY l.created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToLog(rs));
                }
            }
        }
        return logs;
    }

    @Override
    public void logActivity(ActivityLog log) throws SQLException {
        save(log);
    }

    @Override
    public void deleteOldLogs(LocalDateTime before) throws SQLException {
        String sql = "DELETE FROM activity_logs WHERE created_at < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(before));
            ps.executeUpdate();
        }
    }

    @Override
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM activity_logs";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0;
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        String sql = "SELECT 1 FROM activity_logs WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private ActivityLog mapResultSetToLog(ResultSet rs) throws SQLException {
        ActivityLog log = new ActivityLog();
        log.setId(rs.getLong("id"));
        log.setUserId(rs.getLong("user_id"));
        log.setActionType(rs.getString("action_type"));
        log.setEntityType(rs.getString("entity_type"));
        log.setEntityId(rs.getLong("entity_id"));
        log.setDescription(rs.getString("description"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setOldValue(rs.getString("old_value"));
        log.setNewValue(rs.getString("new_value"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            log.setCreatedAt(createdAt.toLocalDateTime());
        }

        // Set user info
        try {
            User user = new User();
            user.setId(log.getUserId());
            user.setUsername(rs.getString("username"));
            user.setFirstName(rs.getString("first_name"));
            user.setLastName(rs.getString("last_name"));
            log.setUser(user);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        return log;
    }
}