package com.oceanview.controller;

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

@WebServlet("/staff/dashboard")
public class StaffDashboardServlet extends HttpServlet {

    private ReservationService reservationService;
    private RoomService roomService;
    private GuestService guestService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationService();
        roomService = new RoomService();
        guestService = new GuestService();
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

        try {
            int activeReservations = (int) reservationService.getActiveReservationsCount();
            int availableRooms = (int) roomService.getAvailableRoomsCount();
            long totalGuests = guestService.getActiveGuestsCount();
            int todayCheckins = reservationService.getTodaysCheckInsCount();
            int todayCheckouts = reservationService.getTodaysCheckOutsCount();
            List<ReservationDTO> recentReservations = reservationService.getRecentReservations(8);

            request.setAttribute("activeReservations", activeReservations);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("totalGuests", totalGuests);
            request.setAttribute("todayCheckins", todayCheckins);
            request.setAttribute("todayCheckouts", todayCheckouts);
            request.setAttribute("recentReservations", recentReservations);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load dashboard data: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp").forward(request, response);
    }
}