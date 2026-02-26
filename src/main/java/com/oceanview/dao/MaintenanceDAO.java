package com.oceanview.dao;

import com.oceanview.model.Maintenance;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface MaintenanceDAO extends BaseDAO<Maintenance, Long> {
    Optional<Maintenance> findByMaintenanceNumber(String maintenanceNumber) throws SQLException;
    List<Maintenance> findByRoomId(Long roomId) throws SQLException;
    List<Maintenance> findByStatus(Maintenance.MaintenanceStatus status) throws SQLException;
    List<Maintenance> findByPriority(Maintenance.Priority priority) throws SQLException;
    List<Maintenance> findByIssueType(Maintenance.IssueType issueType) throws SQLException;
    List<Maintenance> findByDateRange(LocalDate start, LocalDate end) throws SQLException;
    List<Maintenance> findPendingMaintenance() throws SQLException;
    List<Maintenance> findUrgentMaintenance() throws SQLException;
    boolean updateStatus(Long id, Maintenance.MaintenanceStatus status) throws SQLException;
    boolean assignToStaff(Long id, Long staffId) throws SQLException;
}