package com.oceanview.controller;

import com.oceanview.dto.DashboardStatsDTO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.User;
import com.oceanview.service.GuestService;
import com.oceanview.service.ReservationService;
import com.oceanview.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private ReservationService reservationService;
    private RoomService        roomService;
    private GuestService       guestService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationService();
        roomService        = new RoomService();
        guestService       = new GuestService();
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
            DashboardStatsDTO stats = new DashboardStatsDTO();

            // ── Room stats ───────────────────────────────────────────────────────
            int totalRooms       = (int) roomService.getTotalRooms();
            int availableRooms   = (int) roomService.getAvailableRoomsCount();
            int occupiedRooms    = (int) roomService.getOccupiedRoomsCount();
            int maintenanceRooms = (int) roomService.getMaintenanceRoomsCount();

            stats.setTotalRooms(totalRooms);
            stats.setAvailableRooms(availableRooms);
            stats.setOccupiedRooms(occupiedRooms);
            stats.setMaintenanceRooms(maintenanceRooms);

            // ── Reservation stats ────────────────────────────────────────────────
            stats.setTotalReservations((int) reservationService.getTotalReservationsCount());
            stats.setActiveReservations((int) reservationService.getActiveReservationsCount());
            stats.setTodayCheckIns(reservationService.getTodaysCheckInsCount());
            stats.setTodayCheckOuts(reservationService.getTodaysCheckOutsCount());
            stats.setMonthlyRevenue(reservationService.getCurrentMonthRevenue());

            // ── Guest stats ──────────────────────────────────────────────────────
            stats.setTotalGuests(guestService.getActiveGuestsCount());

            // ── Occupancy rate ───────────────────────────────────────────────────
            double occupancyRate = totalRooms > 0
                    ? ((double) (totalRooms - availableRooms) / totalRooms) * 100.0
                    : 0.0;
            stats.setOccupancyRate(occupancyRate);

            request.setAttribute("stats", stats);

            // ── Recent reservations ──────────────────────────────────────────────
            List<ReservationDTO> recentReservations =
                    reservationService.getRecentReservations(8);
            request.setAttribute("recentReservations", recentReservations);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load dashboard data: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")
                .forward(request, response);
    }
}