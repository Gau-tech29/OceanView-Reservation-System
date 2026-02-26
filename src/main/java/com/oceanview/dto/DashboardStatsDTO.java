package com.oceanview.dto;

public class DashboardStatsDTO {
    private int totalReservations;
    private int activeReservations;
    private int totalRooms;
    private int availableRooms;
    private int totalGuests;
    private int totalStaff;
    private int todayCheckIns;
    private int todayCheckOuts;
    private double monthlyRevenue;
    private double occupancyRate;
    private int pendingMaintenance;

    // Getters and Setters
    public int getTotalReservations() { return totalReservations; }
    public void setTotalReservations(int totalReservations) { this.totalReservations = totalReservations; }

    public int getActiveReservations() { return activeReservations; }
    public void setActiveReservations(int activeReservations) { this.activeReservations = activeReservations; }

    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }

    public int getAvailableRooms() { return availableRooms; }
    public void setAvailableRooms(int availableRooms) { this.availableRooms = availableRooms; }

    public int getTotalGuests() { return totalGuests; }
    public void setTotalGuests(int totalGuests) { this.totalGuests = totalGuests; }

    public int getTotalStaff() { return totalStaff; }
    public void setTotalStaff(int totalStaff) { this.totalStaff = totalStaff; }

    public int getTodayCheckIns() { return todayCheckIns; }
    public void setTodayCheckIns(int todayCheckIns) { this.todayCheckIns = todayCheckIns; }

    public int getTodayCheckOuts() { return todayCheckOuts; }
    public void setTodayCheckOuts(int todayCheckOuts) { this.todayCheckOuts = todayCheckOuts; }

    public double getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(double monthlyRevenue) { this.monthlyRevenue = monthlyRevenue; }

    public double getOccupancyRate() { return occupancyRate; }
    public void setOccupancyRate(double occupancyRate) { this.occupancyRate = occupancyRate; }

    public int getPendingMaintenance() { return pendingMaintenance; }
    public void setPendingMaintenance(int pendingMaintenance) { this.pendingMaintenance = pendingMaintenance; }
}