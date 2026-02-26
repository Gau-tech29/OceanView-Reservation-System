package com.oceanview.dao;

import com.oceanview.model.ActivityLog;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ActivityLogDAO extends BaseDAO<ActivityLog, Long> {
    List<ActivityLog> findByUserId(Long userId) throws SQLException;
    List<ActivityLog> findByActionType(String actionType) throws SQLException;
    List<ActivityLog> findByEntityType(String entityType, Long entityId) throws SQLException;
    List<ActivityLog> findByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException;
    List<ActivityLog> findRecentActivities(int limit) throws SQLException;
    void logActivity(ActivityLog log) throws SQLException;
    void deleteOldLogs(LocalDateTime before) throws SQLException;
}