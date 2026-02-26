package com.oceanview.service;

import com.oceanview.dao.MaintenanceDAO;
import com.oceanview.dao.impl.MaintenanceDAOImpl;
import com.oceanview.model.Maintenance;
import com.oceanview.util.ValidationUtils;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class MaintenanceService {

    private final MaintenanceDAO maintenanceDAO;

    public MaintenanceService() {
        this.maintenanceDAO = MaintenanceDAOImpl.getInstance();
    }

    public MaintenanceService(MaintenanceDAO maintenanceDAO) {
        this.maintenanceDAO = maintenanceDAO;
    }

    public Maintenance createMaintenanceRequest(Maintenance maintenance) throws SQLException, IllegalArgumentException {
        // Validate
        if (maintenance.getRoomId() == null) {
            throw new IllegalArgumentException("Room ID is required");
        }

        if (maintenance.getIssueType() == null) {
            throw new IllegalArgumentException("Issue type is required");
        }

        if (!ValidationUtils.isNotEmpty(maintenance.getDescription())) {
            throw new IllegalArgumentException("Description is required");
        }

        // Generate maintenance number if not provided
        if (maintenance.getMaintenanceNumber() == null || maintenance.getMaintenanceNumber().trim().isEmpty()) {
            maintenance.setMaintenanceNumber(generateMaintenanceNumber());
        }

        return maintenanceDAO.save(maintenance);
    }

    public Optional<Maintenance> getMaintenanceById(Long id) throws SQLException {
        return maintenanceDAO.findById(id);
    }

    public Optional<Maintenance> getMaintenanceByNumber(String maintenanceNumber) throws SQLException {
        return maintenanceDAO.findByMaintenanceNumber(maintenanceNumber);
    }

    public List<Maintenance> getMaintenanceByRoom(Long roomId) throws SQLException {
        return maintenanceDAO.findByRoomId(roomId);
    }

    public List<Maintenance> getAllMaintenance() throws SQLException {
        return maintenanceDAO.findAll();
    }

    public List<Maintenance> getMaintenanceByStatus(Maintenance.MaintenanceStatus status) throws SQLException {
        return maintenanceDAO.findByStatus(status);
    }

    public List<Maintenance> getMaintenanceByPriority(Maintenance.Priority priority) throws SQLException {
        return maintenanceDAO.findByPriority(priority);
    }

    public List<Maintenance> getMaintenanceByIssueType(Maintenance.IssueType issueType) throws SQLException {
        return maintenanceDAO.findByIssueType(issueType);
    }

    public List<Maintenance> getMaintenanceByDateRange(LocalDate start, LocalDate end) throws SQLException {
        return maintenanceDAO.findByDateRange(start, end);
    }

    public List<Maintenance> getPendingMaintenance() throws SQLException {
        return maintenanceDAO.findPendingMaintenance();
    }

    public List<Maintenance> getUrgentMaintenance() throws SQLException {
        return maintenanceDAO.findUrgentMaintenance();
    }

    public Maintenance updateMaintenance(Maintenance maintenance) throws SQLException, IllegalArgumentException {
        if (maintenance.getId() == null) {
            throw new IllegalArgumentException("Maintenance ID is required for update");
        }

        return maintenanceDAO.update(maintenance);
    }

    public Maintenance updateStatus(Long id, Maintenance.MaintenanceStatus status)
            throws SQLException, IllegalArgumentException {

        Optional<Maintenance> maintenanceOpt = maintenanceDAO.findById(id);

        if (!maintenanceOpt.isPresent()) {
            throw new IllegalArgumentException("Maintenance record not found");
        }

        Maintenance maintenance = maintenanceOpt.get();
        maintenance.setStatus(status);

        if (status == Maintenance.MaintenanceStatus.COMPLETED && maintenance.getCompletedDate() == null) {
            maintenance.setCompletedDate(LocalDate.now());
        }

        return maintenanceDAO.update(maintenance);
    }

    public Maintenance assignToStaff(Long id, Long staffId) throws SQLException, IllegalArgumentException {
        Optional<Maintenance> maintenanceOpt = maintenanceDAO.findById(id);

        if (!maintenanceOpt.isPresent()) {
            throw new IllegalArgumentException("Maintenance record not found");
        }

        Maintenance maintenance = maintenanceOpt.get();
        maintenance.setAssignedTo(staffId);

        return maintenanceDAO.update(maintenance);
    }

    public Maintenance startMaintenance(Long id) throws SQLException, IllegalArgumentException {
        Optional<Maintenance> maintenanceOpt = maintenanceDAO.findById(id);

        if (!maintenanceOpt.isPresent()) {
            throw new IllegalArgumentException("Maintenance record not found");
        }

        Maintenance maintenance = maintenanceOpt.get();
        maintenance.startMaintenance();

        return maintenanceDAO.update(maintenance);
    }

    public Maintenance completeMaintenance(Long id, BigDecimal cost, String notes)
            throws SQLException, IllegalArgumentException {

        Optional<Maintenance> maintenanceOpt = maintenanceDAO.findById(id);

        if (!maintenanceOpt.isPresent()) {
            throw new IllegalArgumentException("Maintenance record not found");
        }

        Maintenance maintenance = maintenanceOpt.get();
        maintenance.completeMaintenance();
        maintenance.setCost(cost);

        if (notes != null && !notes.trim().isEmpty()) {
            maintenance.setNotes((maintenance.getNotes() != null ? maintenance.getNotes() + " | " : "") + notes);
        }

        return maintenanceDAO.update(maintenance);
    }

    public Maintenance cancelMaintenance(Long id, String reason) throws SQLException, IllegalArgumentException {
        Optional<Maintenance> maintenanceOpt = maintenanceDAO.findById(id);

        if (!maintenanceOpt.isPresent()) {
            throw new IllegalArgumentException("Maintenance record not found");
        }

        Maintenance maintenance = maintenanceOpt.get();
        maintenance.cancelMaintenance();

        if (reason != null && !reason.trim().isEmpty()) {
            maintenance.setNotes((maintenance.getNotes() != null ? maintenance.getNotes() + " | " : "") +
                    "Cancelled: " + reason);
        }

        return maintenanceDAO.update(maintenance);
    }

    private String generateMaintenanceNumber() {
        return "MNT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}