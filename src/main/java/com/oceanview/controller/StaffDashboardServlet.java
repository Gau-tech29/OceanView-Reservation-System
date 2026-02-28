package com.oceanview.controller;

import com.oceanview.model.User;
import com.oceanview.service.ReservationService;
import com.oceanview.service.RoomService;
import com.oceanview.service.GuestService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

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

        try {
            // Pass real stats as attributes so JSP can use them
            request.setAttribute("activeReservations", reservationService.getActiveReservationsCount());
            request.setAttribute("availableRooms", roomService.getAvailableRoomsCount());
            request.setAttribute("totalGuests", guestService.getActiveGuestsCount());
            request.setAttribute("todayCheckins", reservationService.getTodaysCheckInsCount());
            request.setAttribute("recentReservations", reservationService.getRecentReservations(8));
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load dashboard data: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp")
                .forward(request, response);
    }
}
