package com.oceanview.controller.admin;

import com.oceanview.dto.GuestDTO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.SearchCriteriaDTO;
import com.oceanview.model.User;
import com.oceanview.service.GuestService;
import com.oceanview.service.ReservationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/guests/*")
public class AdminGuestController extends HttpServlet {

    private GuestService guestService;
    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        guestService = new GuestService();
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

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listGuests(request, response);
            } else if (pathInfo.equals("/view")) {
                viewGuest(request, response);
            } else if (pathInfo.equals("/edit")) {
                showEditForm(request, response);
            } else if (pathInfo.equals("/new")) {
                showNewForm(request, response);
            } else if (pathInfo.equals("/search")) {
                searchGuests(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
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
                saveGuest(request, response);
            } else if ("/update".equals(pathInfo)) {
                updateGuest(request, response);
            } else if ("/delete".equals(pathInfo)) {
                deleteGuest(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
        }
    }

    private void listGuests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = getIntParam(request, "page", 1);
        int size = getIntParam(request, "size", 10);

        List<GuestDTO> guests = guestService.getGuests(page, size);
        long totalCount = guestService.getActiveGuestsCount();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        request.setAttribute("guests", guests);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageTitle", "Manage Guests");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/list.jsp")
                .forward(request, response);
    }

    private void viewGuest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Long id = Long.parseLong(idStr);
        GuestDTO guest = guestService.getGuestById(id)
                .orElseThrow(() -> new ServletException("Guest not found"));

        // Get guest's reservation history
        List<ReservationDTO> reservations = reservationService.getReservationsByGuestId(id);

        request.setAttribute("guest", guest);
        request.setAttribute("reservations", reservations);
        request.setAttribute("pageTitle", "Guest Details");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/view.jsp")
                .forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Long id = Long.parseLong(idStr);
        GuestDTO guest = guestService.getGuestById(id)
                .orElseThrow(() -> new ServletException("Guest not found"));

        request.setAttribute("guest", guest);
        request.setAttribute("pageTitle", "Edit Guest");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp")
                .forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("pageTitle", "New Guest");
        request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp")
                .forward(request, response);
    }

    private void searchGuests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        List<GuestDTO> results = guestService.searchGuests(keyword);

        request.setAttribute("results", results);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pageTitle", "Search Guests");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/search.jsp")
                .forward(request, response);
    }

    private void saveGuest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();

        try {
            GuestDTO guest = new GuestDTO();
            guest.setFirstName(required(request, "firstName", "First name is required"));
            guest.setLastName(required(request, "lastName", "Last name is required"));
            guest.setEmail(request.getParameter("email"));
            guest.setPhone(request.getParameter("phone"));
            guest.setAddress(request.getParameter("address"));
            guest.setCity(request.getParameter("city"));
            guest.setCountry(request.getParameter("country"));
            guest.setPostalCode(request.getParameter("postalCode"));
            guest.setIdCardNumber(request.getParameter("idCardNumber"));
            guest.setIdCardType(request.getParameter("idCardType"));
            guest.setIsVip("on".equals(request.getParameter("isVip")));

            String pointsStr = request.getParameter("loyaltyPoints");
            if (pointsStr != null && !pointsStr.isEmpty()) {
                guest.setLoyaltyPoints(Integer.parseInt(pointsStr));
            } else {
                guest.setLoyaltyPoints(0);
            }

            guest.setNotes(request.getParameter("notes"));

            GuestDTO saved = guestService.createGuest(guest);
            session.setAttribute("success", "Guest created successfully!");

            response.sendRedirect(request.getContextPath() + "/admin/guests/view?id=" + saved.getId());

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pageTitle", "New Guest");
            request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp")
                    .forward(request, response);
        }
    }

    private void updateGuest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();

        try {
            Long id = Long.parseLong(request.getParameter("id"));
            GuestDTO guest = guestService.getGuestById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Guest not found"));

            guest.setFirstName(required(request, "firstName", "First name is required"));
            guest.setLastName(required(request, "lastName", "Last name is required"));
            guest.setEmail(request.getParameter("email"));
            guest.setPhone(request.getParameter("phone"));
            guest.setAddress(request.getParameter("address"));
            guest.setCity(request.getParameter("city"));
            guest.setCountry(request.getParameter("country"));
            guest.setPostalCode(request.getParameter("postalCode"));
            guest.setIdCardNumber(request.getParameter("idCardNumber"));
            guest.setIdCardType(request.getParameter("idCardType"));
            guest.setIsVip("on".equals(request.getParameter("isVip")));

            String pointsStr = request.getParameter("loyaltyPoints");
            if (pointsStr != null && !pointsStr.isEmpty()) {
                guest.setLoyaltyPoints(Integer.parseInt(pointsStr));
            }

            guest.setNotes(request.getParameter("notes"));

            GuestDTO updated = guestService.updateGuest(guest);
            session.setAttribute("success", "Guest updated successfully!");

            response.sendRedirect(request.getContextPath() + "/admin/guests/view?id=" + updated.getId());

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("guest", request.getParameterMap());
            request.setAttribute("pageTitle", "Edit Guest");
            request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp")
                    .forward(request, response);
        }
    }

    private void deleteGuest(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            Long id = Long.parseLong(idStr);

            // Get guest's reservations
            List<ReservationDTO> reservations = reservationService.getReservationsByGuestId(id);

            boolean hasActiveReservations = reservations.stream()
                    .anyMatch(r -> !"CANCELLED".equals(r.getReservationStatus()) &&
                            !"CHECKED_OUT".equals(r.getReservationStatus()));

            if (hasActiveReservations) {
                session.setAttribute("error", "Cannot delete guest with active reservations.");
            } else {
                boolean deleted = guestService.deleteGuest(id);
                session.setAttribute(deleted ? "success" : "error",
                        deleted ? "Guest deleted." : "Failed to delete guest.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/guests");
    }

    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        try {
            return (val != null && !val.isEmpty()) ? Integer.parseInt(val) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String required(HttpServletRequest request, String name, String errMsg) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) throw new IllegalArgumentException(errMsg);
        return val.trim();
    }
}