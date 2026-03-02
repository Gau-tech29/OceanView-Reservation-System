package com.oceanview.dto;

/**
 * DTO for admin dashboard statistics.
 * Populated by AdminDashboardServlet and read by admin/dashboard.jsp.
 */
public class DashboardStatsDTO {

    private int    totalReservations;
    private int    activeReservations;
    private int    availableRooms;
    private int    totalRooms;
    private int    occupiedRooms;
    private int    maintenanceRooms;
    private long   totalGuests;
    private int    todayCheckIns;
    private int    todayCheckOuts;
    private double monthlyRevenue;
    private double occupancyRate;

    // ── Fields used by ReportService ─────────────────────────────────────────────
    private int    totalStaff;
    private int    pendingMaintenance;

    public DashboardStatsDTO() {}

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    public int getTotalReservations()               { return totalReservations; }
    public void setTotalReservations(int v)         { this.totalReservations = v; }

    public int getActiveReservations()              { return activeReservations; }
    public void setActiveReservations(int v)        { this.activeReservations = v; }

    public int getAvailableRooms()                  { return availableRooms; }
    public void setAvailableRooms(int v)            { this.availableRooms = v; }

    public int getTotalRooms()                      { return totalRooms; }
    public void setTotalRooms(int v)                { this.totalRooms = v; }

    public int getOccupiedRooms()                   { return occupiedRooms; }
    public void setOccupiedRooms(int v)             { this.occupiedRooms = v; }

    public int getMaintenanceRooms()                { return maintenanceRooms; }
    public void setMaintenanceRooms(int v)          { this.maintenanceRooms = v; }

    public long getTotalGuests()                    { return totalGuests; }
    public void setTotalGuests(long v)              { this.totalGuests = v; }

    public int getTodayCheckIns()                   { return todayCheckIns; }
    public void setTodayCheckIns(int v)             { this.todayCheckIns = v; }

    public int getTodayCheckOuts()                  { return todayCheckOuts; }
    public void setTodayCheckOuts(int v)            { this.todayCheckOuts = v; }

    public double getMonthlyRevenue()               { return monthlyRevenue; }
    public void setMonthlyRevenue(double v)         { this.monthlyRevenue = v; }

    public double getOccupancyRate()                { return occupancyRate; }
    public void setOccupancyRate(double v)          { this.occupancyRate = v; }

    /** Total staff users (used by ReportService). */
    public int getTotalStaff()                      { return totalStaff; }
    public void setTotalStaff(int v)                { this.totalStaff = v; }

    /** Number of pending maintenance requests (used by ReportService). */
    public int getPendingMaintenance()              { return pendingMaintenance; }
    public void setPendingMaintenance(int v)        { this.pendingMaintenance = v; }
}