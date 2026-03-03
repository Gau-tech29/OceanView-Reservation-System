package com.oceanview.controller;

import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.User;
import com.oceanview.service.ReservationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet({"/staff/today-checkins", "/admin/today-checkins"})
public class TodayCheckInsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(TodayCheckInsServlet.class.getName());
    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
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
        String servletPath = request.getServletPath();
        boolean isAdmin = servletPath.contains("/admin/");

        // Redirect if wrong dashboard
        if (isAdmin && !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }
        if (!isAdmin && user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            LocalDate today = LocalDate.now();
            LOGGER.info("Fetching check-ins for date: " + today);

            // Get all check-ins for today
            List<ReservationDTO> allCheckIns = reservationService.getReservationsByCheckInDate(today);
            LOGGER.info("Found " + allCheckIns.size() + " check-ins for today");

            // Apply filters if provided
            List<ReservationDTO> filteredCheckIns = applyFilters(allCheckIns, request);

            request.setAttribute("reservations", filteredCheckIns);
            request.setAttribute("allReservationsCount", allCheckIns.size());
            request.setAttribute("filteredCount", filteredCheckIns.size());
            request.setAttribute("pageTitle", "Today's Check-ins - " + today.toString());
            request.setAttribute("isCheckIns", true);
            request.setAttribute("isAdmin", isAdmin);
            request.setAttribute("currentDate", today);

            // Preserve filter parameters for the form
            request.setAttribute("selectedStatus", request.getParameter("status"));
            request.setAttribute("searchGuestName", request.getParameter("guestName"));

            request.getRequestDispatcher("/WEB-INF/views/todays-list.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error loading today's check-ins", e);
            session.setAttribute("error", "Failed to load today's check-ins: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + (isAdmin ? "/admin/dashboard" : "/staff/dashboard"));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error loading today's check-ins", e);
            session.setAttribute("error", "Unexpected error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + (isAdmin ? "/admin/dashboard" : "/staff/dashboard"));
        }
    }

    private List<ReservationDTO> applyFilters(List<ReservationDTO> reservations, HttpServletRequest request) {
        String statusFilter = request.getParameter("status");
        String guestNameFilter = request.getParameter("guestName");

        if ((statusFilter == null || statusFilter.isEmpty()) &&
                (guestNameFilter == null || guestNameFilter.isEmpty())) {
            return reservations; // No filters applied
        }

        return reservations.stream()
                .filter(r -> {
                    // Filter by status
                    if (statusFilter != null && !statusFilter.isEmpty()) {
                        if (!statusFilter.equals(r.getReservationStatus())) {
                            return false;
                        }
                    }

                    // Filter by guest name
                    if (guestNameFilter != null && !guestNameFilter.isEmpty()) {
                        String guestName = r.getGuestName();
                        if (guestName == null || !guestName.toLowerCase().contains(guestNameFilter.toLowerCase())) {
                            return false;
                        }
                    }

                    return true;
                })
                .collect(Collectors.toList());
    }
}