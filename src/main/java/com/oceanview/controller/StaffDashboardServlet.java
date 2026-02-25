package com.oceanview.controller;

import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff/dashboard")
public class StaffDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Pass data to dashboard
        request.setAttribute("activeReservations", 15);
        request.setAttribute("availableRooms", 8);
        request.setAttribute("totalGuests", 24);
        request.setAttribute("todayCheckins", 5);

        request.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp")
                .forward(request, response);
    }
}