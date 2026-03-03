package com.oceanview.controller.admin;

import com.oceanview.dto.GuestDTO;
import com.oceanview.dto.ReservationDTO;
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
            response.sendRedirect(request.getContextPath() + "/staff/guests");
            return;
        }

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                String search = request.getParameter("search");
                if (search != null && !search.trim().isEmpty()) {
                    searchGuests(request, response);
                } else {
                    listGuests(request, response);
                }
            } else if (pathInfo.equals("/new")) {
                showNewForm(request, response);
            } else if (pathInfo.equals("/edit")) {
                showEditForm(request, response);
            } else if (pathInfo.equals("/view")) {
                viewGuest(request, response);
            } else if (pathInfo.equals("/search")) {
                showSearchForm(request, response);
            } else if (pathInfo.equals("/delete")) {
                deleteGuest(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/guests");
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
            } else if ("/search".equals(pathInfo)) {
                searchGuests(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/guests");
        }
    }

    private void listGuests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = getIntParam(request, "page", 1);
        int size = 12;

        List<GuestDTO> guests = guestService.getGuests(page, size);
        long totalCount = guestService.getTotalGuestsCount();
        int totalPages = (int) Math.ceil((double) totalCount / size);

        request.setAttribute("guests", guests);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageTitle", "Guest Management");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/list.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("guest", null);
        request.setAttribute("pageTitle", "Add New Guest");
        request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Guest ID required");
            return;
        }

        Long id = Long.parseLong(idStr);
        GuestDTO guest = guestService.getGuestById(id)
                .orElseThrow(() -> new ServletException("Guest not found"));

        request.setAttribute("guest", guest);
        request.setAttribute("pageTitle", "Edit Guest - " + guest.getFullName());
        request.getRequestDispatcher("/WEB-INF/views/admin/guests/form.jsp").forward(request, response);
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

        List<ReservationDTO> reservations = reservationService.getReservationsByGuest(id);

        int totalStays = reservations.size();
        int completedStays = (int) reservations.stream()
                .filter(r -> "CHECKED_OUT".equals(r.getReservationStatus())).count();
        int cancelledStays = (int) reservations.stream()
                .filter(r -> "CANCELLED".equals(r.getReservationStatus())).count();
        double totalSpent = reservations.stream()
                .filter(r -> "CHECKED_OUT".equals(r.getReservationStatus()) || "PAID".equals(r.getPaymentStatus()))
                .mapToDouble(r -> r.getTotalAmount() != null ? r.getTotalAmount().doubleValue() : 0).sum();

        request.setAttribute("guest", guest);
        request.setAttribute("reservations", reservations);
        request.setAttribute("totalStays", totalStays);
        request.setAttribute("completedStays", completedStays);
        request.setAttribute("cancelledStays", cancelledStays);
        request.setAttribute("totalSpent", totalSpent);
        request.setAttribute("pageTitle", "Guest Profile - " + guest.getFullName());

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/view.jsp").forward(request, response);
    }

    private void showSearchForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Search Guests");
        request.getRequestDispatcher("/WEB-INF/views/admin/guests/search.jsp").forward(request, response);
    }

    private void searchGuests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = request.getParameter("search");

        List<GuestDTO> results = guestService.searchGuests(keyword);

        request.setAttribute("guests", results);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("totalCount", results.size());
        request.setAttribute("pageTitle", "Search Results");

        request.getRequestDispatcher("/WEB-INF/views/admin/guests/list.jsp").forward(request, response);
    }

    private void saveGuest(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();

        try {
            GuestDTO guest = buildGuestDTO(request, null);
            GuestDTO saved = guestService.createGuest(guest);
            session.setAttribute("success", "Guest " + saved.getFullName() + " created successfully!");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/guests");
    }

    private void updateGuest(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();

        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                throw new IllegalArgumentException("Guest ID is required");
            }

            Long id = Long.parseLong(idStr);
            GuestDTO existing = guestService.getGuestById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Guest not found"));

            GuestDTO updated = buildGuestDTO(request, existing);
            updated.setId(id);

            guestService.updateGuest(updated);
            session.setAttribute("success", "Guest " + updated.getFullName() + " updated successfully!");

        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/guests");
    }

    private void deleteGuest(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                boolean deleted = guestService.deleteGuest(Long.parseLong(idStr));
                if (deleted) {
                    session.setAttribute("success", "Guest deleted successfully.");
                } else {
                    session.setAttribute("error", "Failed to delete guest.");
                }
            } catch (Exception e) {
                session.setAttribute("error", "Delete failed: " + e.getMessage());
            }
        } else {
            session.setAttribute("error", "Invalid guest ID.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/guests");
    }

    private GuestDTO buildGuestDTO(HttpServletRequest request, GuestDTO existing) {
        GuestDTO guest = (existing != null) ? existing : new GuestDTO();
        guest.setFirstName(required(request, "firstName"));
        guest.setLastName(required(request, "lastName"));
        guest.setEmail(request.getParameter("email"));
        guest.setPhone(request.getParameter("phone"));
        guest.setAddress(request.getParameter("address"));
        guest.setCity(request.getParameter("city"));
        guest.setCountry(request.getParameter("country"));
        guest.setPostalCode(request.getParameter("postalCode"));
        guest.setIdCardType(request.getParameter("idCardType"));
        guest.setIdCardNumber(request.getParameter("idCardNumber"));
        guest.setLoyaltyPoints(getIntParam(request, "loyaltyPoints", 0));
        guest.setIsVip("on".equals(request.getParameter("isVip")));
        guest.setNotes(request.getParameter("notes"));
        return guest;
    }

    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        try {
            return (val != null && !val.trim().isEmpty()) ? Integer.parseInt(val.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String required(HttpServletRequest request, String name) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) {
            throw new IllegalArgumentException(name + " is required");
        }
        return val.trim();
    }
}