package com.oceanview.dao.impl;

import com.oceanview.dao.MaintenanceDAO;
import com.oceanview.model.Maintenance;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class MaintenanceDAOImpl implements MaintenanceDAO {

    private static MaintenanceDAOImpl instance;

    private MaintenanceDAOImpl() {}

    public static synchronized MaintenanceDAOImpl getInstance() {
        if (instance == null) {
            instance = new MaintenanceDAOImpl();
        }
        return instance;
    }

    @Override
    public Maintenance save(Maintenance maintenance) throws SQLException {
        String sql = "INSERT INTO maintenance (room_id, maintenance_number, issue_type, description, " +
                "priority, status, scheduled_date, completed_date, cost, assigned_to, notes, " +
                "created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, maintenance.getRoomId());
            ps.setString(2, maintenance.getMaintenanceNumber());
            ps.setString(3, maintenance.getIssueType().name());
            ps.setString(4, maintenance.getDescription());
            ps.setString(5, maintenance.getPriority().name());
            ps.setString(6, maintenance.getStatus().name());
            ps.setDate(7, maintenance.getScheduledDate() != null ? Date.valueOf(maintenance.getScheduledDate()) : null);
            ps.setDate(8, maintenance.getCompletedDate() != null ? Date.valueOf(maintenance.getCompletedDate()) : null);
            ps.setBigDecimal(9, maintenance.getCost());
            ps.setLong(10, maintenance.getAssignedTo());
            ps.setString(11, maintenance.getNotes());
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(13, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating maintenance record failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    maintenance.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating maintenance record failed, no ID obtained.");
                }
            }
        }
        return maintenance;
    }

    @Override
    public Maintenance update(Maintenance maintenance) throws SQLException {
        String sql = "UPDATE maintenance SET issue_type = ?, description = ?, priority = ?, " +
                "status = ?, scheduled_date = ?, completed_date = ?, cost = ?, assigned_to = ?, " +
                "notes = ?, updated_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maintenance.getIssueType().name());
            ps.setString(2, maintenance.getDescription());
            ps.setString(3, maintenance.getPriority().name());
            ps.setString(4, maintenance.getStatus().name());
            ps.setDate(5, maintenance.getScheduledDate() != null ? Date.valueOf(maintenance.getScheduledDate()) : null);
            ps.setDate(6, maintenance.getCompletedDate() != null ? Date.valueOf(maintenance.getCompletedDate()) : null);
            ps.setBigDecimal(7, maintenance.getCost());
            ps.setLong(8, maintenance.getAssignedTo());
            ps.setString(9, maintenance.getNotes());
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(11, maintenance.getId());

            ps.executeUpdate();
        }
        return maintenance;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM maintenance WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Maintenance> findById(Long id) throws SQLException {
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number, " +
                "u.first_name as staff_first_name, u.last_name as staff_last_name " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "LEFT JOIN users u ON m.assigned_to = u.id " +
                "WHERE m.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToMaintenance(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Maintenance> findByMaintenanceNumber(String maintenanceNumber) throws SQLException {
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number, " +
                "u.first_name as staff_first_name, u.last_name as staff_last_name " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "LEFT JOIN users u ON m.assigned_to = u.id " +
                "WHERE m.maintenance_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maintenanceNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToMaintenance(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Maintenance> findAll() throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "ORDER BY m.priority DESC, m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                maintenanceList.add(mapResultSetToMaintenance(rs));
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findAll(int page, int size) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "ORDER BY m.priority DESC, m.created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findByRoomId(Long roomId) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.room_id = ? " +
                "ORDER BY m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findByStatus(Maintenance.MaintenanceStatus status) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.status = ? " +
                "ORDER BY m.priority DESC, m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findByPriority(Maintenance.Priority priority) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.priority = ? " +
                "ORDER BY m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, priority.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findByIssueType(Maintenance.IssueType issueType) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.issue_type = ? " +
                "ORDER BY m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, issueType.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findByDateRange(LocalDate start, LocalDate end) throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.scheduled_date BETWEEN ? AND ? " +
                "ORDER BY m.scheduled_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    maintenanceList.add(mapResultSetToMaintenance(rs));
                }
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findPendingMaintenance() throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.status IN ('PENDING', 'IN_PROGRESS') " +
                "ORDER BY m.priority DESC, m.scheduled_date ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                maintenanceList.add(mapResultSetToMaintenance(rs));
            }
        }
        return maintenanceList;
    }

    @Override
    public List<Maintenance> findUrgentMaintenance() throws SQLException {
        List<Maintenance> maintenanceList = new ArrayList<>();
        String sql = "SELECT m.*, r.room_number, r.room_type, r.floor_number " +
                "FROM maintenance m " +
                "LEFT JOIN rooms r ON m.room_id = r.id " +
                "WHERE m.priority = 'URGENT' AND m.status != 'COMPLETED' " +
                "ORDER BY m.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                maintenanceList.add(mapResultSetToMaintenance(rs));
            }
        }
        return maintenanceList;
    }

    @Override
    public boolean updateStatus(Long id, Maintenance.MaintenanceStatus status) throws SQLException {
        String sql = "UPDATE maintenance SET status = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);

            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean assignToStaff(Long id, Long staffId) throws SQLException {
        String sql = "UPDATE maintenance SET assigned_to = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, staffId);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);

            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM maintenance";
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
        String sql = "SELECT 1 FROM maintenance WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Maintenance mapResultSetToMaintenance(ResultSet rs) throws SQLException {
        Maintenance maintenance = new Maintenance();
        maintenance.setId(rs.getLong("id"));
        maintenance.setRoomId(rs.getLong("room_id"));
        maintenance.setMaintenanceNumber(rs.getString("maintenance_number"));
        maintenance.setIssueType(Maintenance.IssueType.valueOf(rs.getString("issue_type")));
        maintenance.setDescription(rs.getString("description"));
        maintenance.setPriority(Maintenance.Priority.valueOf(rs.getString("priority")));
        maintenance.setStatus(Maintenance.MaintenanceStatus.valueOf(rs.getString("status")));

        Date scheduledDate = rs.getDate("scheduled_date");
        if (scheduledDate != null) {
            maintenance.setScheduledDate(scheduledDate.toLocalDate());
        }

        Date completedDate = rs.getDate("completed_date");
        if (completedDate != null) {
            maintenance.setCompletedDate(completedDate.toLocalDate());
        }

        maintenance.setCost(rs.getBigDecimal("cost"));
        maintenance.setAssignedTo(rs.getLong("assigned_to"));
        maintenance.setNotes(rs.getString("notes"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            maintenance.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            maintenance.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Set room info
        try {
            Room room = new Room();
            room.setId(maintenance.getRoomId());
            room.setRoomNumber(rs.getString("room_number"));
            room.setRoomType(Room.RoomType.valueOf(rs.getString("room_type")));
            room.setFloorNumber(rs.getInt("floor_number"));
            maintenance.setRoom(room);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        // Set assigned staff info
        try {
            User staff = new User();
            staff.setId(maintenance.getAssignedTo());
            staff.setFirstName(rs.getString("staff_first_name"));
            staff.setLastName(rs.getString("staff_last_name"));
            maintenance.setAssignedStaff(staff);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        return maintenance;
    }
}