package com.oceanview.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Objects;

public class Maintenance {
    private Long id;
    private Long roomId;
    private String maintenanceNumber;
    private IssueType issueType;
    private String description;
    private Priority priority;
    private MaintenanceStatus status;
    private LocalDate scheduledDate;
    private LocalDate completedDate;
    private BigDecimal cost;
    private Long assignedTo;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Room room;
    private User assignedStaff;

    public enum IssueType {
        CLEANING, REPAIR, RENOVATION, INSPECTION, PLUMBING, ELECTRICAL, HVAC, OTHER
    }

    public enum Priority {
        LOW, MEDIUM, HIGH, URGENT
    }

    public enum MaintenanceStatus {
        PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    }

    public Maintenance() {
        this.priority = Priority.MEDIUM;
        this.status = MaintenanceStatus.PENDING;
    }

    public Maintenance(String maintenanceNumber, Long roomId, IssueType issueType, String description) {
        this.maintenanceNumber = maintenanceNumber;
        this.roomId = roomId;
        this.issueType = issueType;
        this.description = description;
        this.priority = Priority.MEDIUM;
        this.status = MaintenanceStatus.PENDING;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public String getMaintenanceNumber() { return maintenanceNumber; }
    public void setMaintenanceNumber(String maintenanceNumber) { this.maintenanceNumber = maintenanceNumber; }

    public IssueType getIssueType() { return issueType; }
    public void setIssueType(IssueType issueType) { this.issueType = issueType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Priority getPriority() { return priority; }
    public void setPriority(Priority priority) { this.priority = priority; }

    public MaintenanceStatus getStatus() { return status; }
    public void setStatus(MaintenanceStatus status) { this.status = status; }

    public LocalDate getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(LocalDate scheduledDate) { this.scheduledDate = scheduledDate; }

    public LocalDate getCompletedDate() { return completedDate; }
    public void setCompletedDate(LocalDate completedDate) { this.completedDate = completedDate; }

    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }

    public Long getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Long assignedTo) { this.assignedTo = assignedTo; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }

    public User getAssignedStaff() { return assignedStaff; }
    public void setAssignedStaff(User assignedStaff) { this.assignedStaff = assignedStaff; }

    // Business methods
    public boolean isUrgent() {
        return priority == Priority.URGENT;
    }

    public boolean isHighPriority() {
        return priority == Priority.HIGH || priority == Priority.URGENT;
    }

    public boolean isCompleted() {
        return status == MaintenanceStatus.COMPLETED;
    }

    public boolean isInProgress() {
        return status == MaintenanceStatus.IN_PROGRESS;
    }

    public void startMaintenance() {
        this.status = MaintenanceStatus.IN_PROGRESS;
    }

    public void completeMaintenance() {
        this.status = MaintenanceStatus.COMPLETED;
        this.completedDate = LocalDate.now();
    }

    public void cancelMaintenance() {
        this.status = MaintenanceStatus.CANCELLED;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Maintenance that = (Maintenance) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Maintenance{" +
                "id=" + id +
                ", maintenanceNumber='" + maintenanceNumber + '\'' +
                ", issueType=" + issueType +
                ", priority=" + priority +
                ", status=" + status +
                '}';
    }
}