package com.oceanview.service;

import com.oceanview.dao.*;
import com.oceanview.dao.impl.*;
import com.oceanview.dto.DashboardStatsDTO;
import com.oceanview.model.*;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportService {

    private final ReservationDAO reservationDAO;
    private final RoomDAO roomDAO;
    private final GuestDAO guestDAO;
    private final BillDAO billDAO;
    private final PaymentDAO paymentDAO;
    private final UserDAO userDAO;

    public ReportService() {
        this.reservationDAO = ReservationDAOImpl.getInstance();
        this.roomDAO = RoomDAOImpl.getInstance();
        this.guestDAO = GuestDAOImpl.getInstance();
        this.billDAO = BillDAOImpl.getInstance();
        this.paymentDAO = PaymentDAOImpl.getInstance();
        this.userDAO = UserDAOImpl.getInstance();
    }

    public DashboardStatsDTO getDashboardStats() throws SQLException {
        DashboardStatsDTO stats = new DashboardStatsDTO();

        LocalDate today = LocalDate.now();
        LocalDate startOfMonth = today.withDayOfMonth(1);
        LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());

        // Basic counts
        stats.setTotalReservations((int) reservationDAO.count());
        stats.setActiveReservations(reservationDAO.findActiveReservations().size());
        stats.setTotalRooms((int) roomDAO.count());
        stats.setAvailableRooms(roomDAO.findAvailableRooms().size());
        stats.setTotalGuests((int) guestDAO.count());
        stats.setTotalStaff((int) userDAO.count() - 1); // Exclude admin maybe

        // Today's stats
        stats.setTodayCheckIns(reservationDAO.findCheckInsByDate(today).size());
        stats.setTodayCheckOuts(reservationDAO.findCheckOutsByDate(today).size());

        // Monthly revenue
        stats.setMonthlyRevenue(billDAO.getTotalRevenueByDateRange(startOfMonth, endOfMonth));

        // Occupancy rate
        int totalRooms = stats.getTotalRooms();
        if (totalRooms > 0) {
            int occupiedRooms = roomDAO.findOccupiedRooms().size();
            stats.setOccupancyRate((occupiedRooms * 100.0) / totalRooms);
        }

        // Pending maintenance
        stats.setPendingMaintenance(MaintenanceDAOImpl.getInstance().findPendingMaintenance().size());

        return stats;
    }

    public Map<String, Object> getMonthlyReport(YearMonth yearMonth) throws SQLException {
        Map<String, Object> report = new HashMap<>();

        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();

        // Revenue data
        double totalRevenue = billDAO.getTotalRevenueByDateRange(startDate, endDate);
        double totalPayments = paymentDAO.getTotalPaymentsByDateRange(
                startDate.atStartOfDay(),
                endDate.plusDays(1).atStartOfDay()
        );

        report.put("totalRevenue", totalRevenue);
        report.put("totalPayments", totalPayments);
        report.put("outstandingBalance", totalRevenue - totalPayments);

        // Reservation stats
        List<Reservation> monthReservations = reservationDAO.findByDateRange(startDate, endDate);
        long confirmedCount = monthReservations.stream()
                .filter(r -> r.getReservationStatus() == Reservation.ReservationStatus.CONFIRMED).count();
        long checkedInCount = monthReservations.stream()
                .filter(r -> r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_IN).count();
        long cancelledCount = monthReservations.stream()
                .filter(r -> r.getReservationStatus() == Reservation.ReservationStatus.CANCELLED).count();

        report.put("totalReservations", monthReservations.size());
        report.put("confirmedReservations", confirmedCount);
        report.put("checkedInReservations", checkedInCount);
        report.put("cancelledReservations", cancelledCount);

        // Room type distribution
        Map<String, Long> roomTypeDistribution = new HashMap<>();
        List<Room> allRooms = roomDAO.findAll();
        for (Room.RoomType type : Room.RoomType.values()) {
            long count = allRooms.stream()
                    .filter(r -> r.getRoomType() == type && r.isActive())
                    .count();
            roomTypeDistribution.put(type.name(), count);
        }
        report.put("roomTypeDistribution", roomTypeDistribution);

        // Top guests (by number of stays)
        List<Guest> topGuests = guestDAO.findTopGuests(10);
        report.put("topGuests", topGuests);

        return report;
    }

    public Map<String, Object> getOccupancyReport(LocalDate startDate, LocalDate endDate) throws SQLException {
        Map<String, Object> report = new HashMap<>();

        List<Room> allRooms = roomDAO.findAll();
        int totalRooms = allRooms.size();

        // Daily occupancy for the period
        Map<LocalDate, Integer> dailyOccupancy = new HashMap<>();
        Map<LocalDate, Double> dailyOccupancyRate = new HashMap<>();

        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            int occupiedRooms = reservationDAO.countOccupiedRoomsByDate(currentDate);
            dailyOccupancy.put(currentDate, occupiedRooms);

            double occupancyRate = totalRooms > 0 ? (occupiedRooms * 100.0) / totalRooms : 0;
            dailyOccupancyRate.put(currentDate, occupancyRate);

            currentDate = currentDate.plusDays(1);
        }

        report.put("dailyOccupancy", dailyOccupancy);
        report.put("dailyOccupancyRate", dailyOccupancyRate);

        // Average occupancy rate
        double avgOccupancyRate = dailyOccupancyRate.values().stream()
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0);
        report.put("avgOccupancyRate", avgOccupancyRate);

        // Peak occupancy day
        Map.Entry<LocalDate, Integer> peakDay = dailyOccupancy.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .orElse(null);
        report.put("peakOccupancyDay", peakDay != null ? peakDay.getKey() : null);
        report.put("peakOccupancy", peakDay != null ? peakDay.getValue() : 0);

        return report;
    }

    public Map<String, Object> getRevenueReport(LocalDate startDate, LocalDate endDate) throws SQLException {
        Map<String, Object> report = new HashMap<>();

        List<Bill> bills = billDAO.findByDateRange(startDate, endDate);

        // Total revenue
        double totalRevenue = bills.stream()
                .filter(b -> b.getBillStatus() == Bill.BillStatus.PAID)
                .mapToDouble(b -> b.getTotalAmount().doubleValue())
                .sum();

        // Revenue by payment method
        Map<Bill.PaymentMethod, Double> revenueByMethod = new HashMap<>();
        for (Bill bill : bills) {
            if (bill.getBillStatus() == Bill.BillStatus.PAID && bill.getPaymentMethod() != null) {
                revenueByMethod.merge(
                        bill.getPaymentMethod(),
                        bill.getTotalAmount().doubleValue(),
                        Double::sum
                );
            }
        }

        // Daily revenue
        Map<LocalDate, Double> dailyRevenue = new HashMap<>();
        for (Bill bill : bills) {
            if (bill.getBillStatus() == Bill.BillStatus.PAID) {
                dailyRevenue.merge(
                        bill.getIssueDate(),
                        bill.getTotalAmount().doubleValue(),
                        Double::sum
                );
            }
        }

        report.put("totalRevenue", totalRevenue);
        report.put("revenueByMethod", revenueByMethod);
        report.put("dailyRevenue", dailyRevenue);
        report.put("totalBillsIssued", bills.size());
        report.put("paidBills", bills.stream().filter(b -> b.getBillStatus() == Bill.BillStatus.PAID).count());
        report.put("pendingBills", bills.stream().filter(b -> b.getBillStatus() == Bill.BillStatus.ISSUED).count());

        return report;
    }

    public byte[] generateExcelReport(String reportType, LocalDate startDate, LocalDate endDate) throws SQLException {
        // Implementation for Excel report generation
        // You can use Apache POI library here
        return new byte[0];
    }

    public byte[] generatePdfReport(String reportType, LocalDate startDate, LocalDate endDate) throws SQLException {
        // Implementation for PDF report generation
        // You can use iText or JasperReports library here
        return new byte[0];
    }
}