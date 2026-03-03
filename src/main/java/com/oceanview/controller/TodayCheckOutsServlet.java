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

@WebServlet({"/staff/today-checkouts", "/admin/today-checkouts"})
public class TodayCheckOutsServlet extends HttpServlet {

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
            List<ReservationDTO> todayCheckOuts = reservationService.getReservationsByCheckOutDate(today);

            request.setAttribute("reservations", todayCheckOuts);
            request.setAttribute("pageTitle", "Today's Check-outs - " + today.toString());
            request.setAttribute("isCheckIns", false);
            request.setAttribute("isAdmin", isAdmin);
            request.setAttribute("currentDate", today);

            request.getRequestDispatcher("/WEB-INF/views/todays-list.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Failed to load today's check-outs: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + (isAdmin ? "/admin/dashboard" : "/staff/dashboard"));
        }
    }
}