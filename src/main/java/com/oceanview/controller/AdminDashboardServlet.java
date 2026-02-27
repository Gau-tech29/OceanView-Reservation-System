package com.oceanview.controller;

import com.oceanview.model.User;
import com.oceanview.service.ReportService;
import com.oceanview.service.RoomService;
import com.oceanview.service.ReservationService;
import com.oceanview.dto.DashboardStatsDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private ReportService reportService;
    private RoomService roomService;
    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        reportService = new ReportService();
        roomService = new RoomService();
        reservationService = new ReservationService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        try {
            // Get dashboard statistics
            DashboardStatsDTO stats = getDashboardStats();
            request.setAttribute("stats", stats);

            // Get monthly revenue data for chart
            Map<String, Double> monthlyRevenue = getMonthlyRevenue();
            request.setAttribute("monthlyRevenue", monthlyRevenue);

            // Get room status distribution
            Map<String, Integer> roomStatus = getRoomStatusDistribution();
            request.setAttribute("roomStatus", roomStatus);

            // Get recent reservations
            request.setAttribute("recentReservations", reservationService.getRecentReservations(10));

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load dashboard data: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")
                .forward(request, response);
    }

    private DashboardStatsDTO getDashboardStats() throws SQLException {
        DashboardStatsDTO stats = new DashboardStatsDTO();

        // Get real data from services
        stats.setTotalRooms((int) roomService.getTotalRooms());
        stats.setAvailableRooms((int) roomService.getAvailableRoomsCount());
        stats.setActiveReservations(reservationService.getActiveReservationsCount());
        stats.setTotalReservations((int) reservationService.getTotalReservationsCount());
        stats.setTodayCheckIns(reservationService.getTodaysCheckInsCount());
        stats.setTodayCheckOuts(reservationService.getTodaysCheckOutsCount());
        stats.setMonthlyRevenue(reservationService.getCurrentMonthRevenue());
        stats.setOccupancyRate(calculateOccupancyRate());
        stats.setTotalGuests(reservationService.getTotalGuestsCount());

        return stats;
    }

    private Map<String, Double> getMonthlyRevenue() throws SQLException {
        Map<String, Double> revenue = new HashMap<>();
        String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        for (int i = 0; i < 12; i++) {
            double amount = reservationService.getMonthlyRevenue(i + 1, LocalDate.now().getYear());
            revenue.put(months[i], amount);
        }
        return revenue;
    }

    private Map<String, Integer> getRoomStatusDistribution() throws SQLException {
        Map<String, Integer> distribution = new HashMap<>();
        distribution.put("Available", (int) roomService.getAvailableRoomsCount());
        distribution.put("Occupied", roomService.getOccupiedRoomsCount());
        distribution.put("Maintenance", roomService.getMaintenanceRoomsCount());
        distribution.put("Reserved", roomService.getReservedRoomsCount());
        return distribution;
    }

    private double calculateOccupancyRate() throws SQLException {
        long totalRooms = roomService.getTotalRooms();
        long occupiedRooms = roomService.getOccupiedRoomsCount();

        if (totalRooms == 0) return 0.0;
        return (double) occupiedRooms / totalRooms * 100;
    }
}