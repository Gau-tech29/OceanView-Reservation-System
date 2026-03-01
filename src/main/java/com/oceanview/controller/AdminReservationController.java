package com.oceanview.controller;

import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/reservations/*")
public class AdminReservationController extends ReservationController {

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
            response.sendRedirect(request.getContextPath() + "/staff/reservations");
            return;
        }

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listAdminReservations(request, response);
            } else if (pathInfo.equals("/new")) {
                showNewForm(request, response);
            } else if (pathInfo.equals("/edit")) {
                showEditForm(request, response);
            } else if (pathInfo.equals("/view")) {
                viewReservation(request, response);
            } else if (pathInfo.equals("/search")) {
                searchReservations(request, response);
            } else if (pathInfo.equals("/checkin")) {
                checkInReservation(request, response);
            } else if (pathInfo.equals("/checkout")) {
                checkOutReservation(request, response);
            } else if (pathInfo.equals("/cancel")) {
                cancelReservation(request, response);
            } else if (pathInfo.equals("/delete")) {
                deleteReservation(request, response);
            } else if (pathInfo.equals("/print-bill")) {
                printBill(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String pathInfo = request.getPathInfo();

        try {
            if ("/save".equals(pathInfo)) {
                saveReservation(request, response);
            } else if ("/update".equals(pathInfo)) {
                updateReservation(request, response);
            } else if ("/delete".equals(pathInfo)) {
                deleteReservation(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        }
    }

    private void listAdminReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = getIntParam(request, "page", 1);
        int size = getIntParam(request, "size", 10);

        List<ReservationDTO> reservations = reservationService.getReservations(page, size);
        long totalCount = reservationService.getTotalReservationsCount();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        request.setAttribute("reservations", reservations);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageTitle", "Manage Reservations");
        request.setAttribute("isAdmin", true);

        request.getRequestDispatcher("/WEB-INF/views/reservations/list.jsp")
                .forward(request, response);
    }
}
