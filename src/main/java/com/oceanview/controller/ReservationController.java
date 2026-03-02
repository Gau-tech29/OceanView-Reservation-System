package com.oceanview.controller;

import com.oceanview.dto.GuestDTO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.RoomDTO;
import com.oceanview.dto.SearchCriteriaDTO;
import com.oceanview.mapper.RoomMapper;
import com.oceanview.model.Room;
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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/reservations/*")
public class ReservationController extends HttpServlet {

    protected ReservationService reservationService;
    protected RoomService        roomService;
    protected GuestService       guestService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationService();
        roomService        = new RoomService();
        guestService       = new GuestService();
    }

    // ─── Dispatch ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireLogin(request, response)) return;

        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listReservations(request, response);
            } else switch (pathInfo) {
                case "/new":        showNewForm(request, response);        break;
                case "/edit":       showEditForm(request, response);       break;
                case "/view":       viewReservation(request, response);    break;
                case "/search":     searchReservations(request, response); break;
                case "/checkin":    checkInReservation(request, response); break;
                case "/checkout":   checkOutReservation(request, response);break;
                case "/cancel":     cancelReservation(request, response);  break;
                case "/delete":     deleteReservation(request, response);  break; // supports GET link
                case "/print-bill": printBill(request, response);          break;
                default:            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            handleDbError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireLogin(request, response)) return;

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
            handleDbError(request, response, e);
        }
    }

    // ─── GET handlers ─────────────────────────────────────────────────────────────

    protected void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        request.setAttribute("pageTitle", "New Reservation");

        String guestId = request.getParameter("guestId");
        if (guestId != null && !guestId.isEmpty()) {
            try {
                guestService.getGuestById(Long.parseLong(guestId))
                        .ifPresent(g -> request.setAttribute("selectedGuest", g));
            } catch (NumberFormatException ignored) {}
        }

        request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp")
                .forward(request, response);
    }

    protected void listReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = getIntParam(request, "page", 1);
        int size = getIntParam(request, "size", 10);

        List<ReservationDTO> reservations = reservationService.getReservations(page, size);
        long totalCount = reservationService.getTotalReservationsCount();
        int  totalPages = (int) Math.ceil((double) totalCount / size);

        request.setAttribute("reservations", reservations);
        request.setAttribute("currentPage",  page);
        request.setAttribute("totalPages",   totalPages);
        request.setAttribute("totalCount",   totalCount);
        request.setAttribute("pageTitle",    "All Reservations");
        request.getRequestDispatcher("/WEB-INF/views/reservations/list.jsp")
                .forward(request, response);
    }

    protected void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID required");
            return;
        }

        Long id = Long.parseLong(idStr);
        ReservationDTO reservation = reservationService.getReservationById(id)
                .orElseThrow(() -> new ServletException("Reservation not found"));

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle",   "Edit Reservation");

        if (reservation.getGuestId() != null) {
            guestService.getGuestById(reservation.getGuestId())
                    .ifPresent(g -> request.setAttribute("selectedGuest", g));
        }

        request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp")
                .forward(request, response);
    }

    protected void viewReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr     = request.getParameter("id");
        String numberStr = request.getParameter("number");
        ReservationDTO reservation = null;

        if (idStr != null && !idStr.isEmpty()) {
            try {
                reservation = reservationService.getReservationById(Long.parseLong(idStr))
                        .orElse(null);
            } catch (NumberFormatException e) {
                reservation = null;
            }
        } else if (numberStr != null && !numberStr.isEmpty()) {
            reservation = reservationService.getReservationByNumber(numberStr).orElse(null);
        }

        if (reservation == null) {
            request.setAttribute("error", "Reservation not found.");
            request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp")
                    .forward(request, response);
            return;
        }

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle",   "Reservation Details");
        request.getRequestDispatcher("/WEB-INF/views/reservations/view.jsp")
                .forward(request, response);
    }

    protected void searchReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        request.setAttribute("pageTitle", "Search Reservations");

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp")
                    .forward(request, response);
            return;
        }

        SearchCriteriaDTO criteria = buildSearchCriteria(request);
        List<ReservationDTO> results = reservationService.searchReservations(criteria);
        request.setAttribute("results",  results);
        request.setAttribute("criteria", criteria);
        request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp")
                .forward(request, response);
    }

    // ─── POST handlers ────────────────────────────────────────────────────────────

    /**
     * Creates ONE reservation for all selected rooms.
     * On validation error, forward back to the form (preserving request attributes)
     * so the user sees the error inline rather than losing all their input.
     */
    protected void saveReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User   user = (User) session.getAttribute("user");
        String base = user.isAdmin() ? "/admin" : "/staff";

        try {
            // ── 1. Resolve guest ─────────────────────────────────────────────────
            String guestMode = request.getParameter("guestMode");
            Long resolvedGuestId;

            if ("new".equals(guestMode)) {
                GuestDTO newGuest = new GuestDTO();
                newGuest.setFirstName(required(request, "firstName", "First name is required."));
                newGuest.setLastName(required(request, "lastName",   "Last name is required."));
                newGuest.setEmail(request.getParameter("guestEmail"));
                newGuest.setPhone(request.getParameter("guestPhone"));
                newGuest.setAddress(request.getParameter("address"));
                newGuest.setCity(request.getParameter("city"));
                newGuest.setCountry(request.getParameter("country"));
                newGuest.setPostalCode(request.getParameter("postalCode"));
                newGuest.setIdCardNumber(request.getParameter("idCardNumber"));
                newGuest.setIdCardType(request.getParameter("idCardType"));
                newGuest.setIsVip(false);
                newGuest.setLoyaltyPoints(0);
                resolvedGuestId = guestService.createGuest(newGuest).getId();

            } else {
                String guestIdStr = request.getParameter("guestId");
                if (guestIdStr == null || guestIdStr.trim().isEmpty())
                    throw new IllegalArgumentException(
                            "Please select an existing guest or choose 'New Guest'.");
                try {
                    resolvedGuestId = Long.parseLong(guestIdStr.trim());
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid guest ID format.");
                }
                if (!guestService.getGuestById(resolvedGuestId).isPresent())
                    throw new IllegalArgumentException("Guest not found. Please search again.");
            }

            // ── 2. Parse stay details ────────────────────────────────────────────
            LocalDate checkIn  = parseDate(request, "checkInDate");
            LocalDate checkOut = parseDate(request, "checkOutDate");

            if (!checkOut.isAfter(checkIn))
                throw new IllegalArgumentException("Check-out date must be after check-in date.");

            int adults   = getIntParam(request, "adults",   1);
            int children = getIntParam(request, "children", 0);

            BigDecimal discount = BigDecimal.ZERO;
            String discStr = request.getParameter("discountAmount");
            if (discStr != null && !discStr.trim().isEmpty()) {
                try { discount = new BigDecimal(discStr.trim()); }
                catch (NumberFormatException ignored) {}
            }

            // ── 3. Collect ALL selected room IDs ─────────────────────────────────
            List<Long> roomIds = collectRoomIds(request);
            if (roomIds.isEmpty())
                throw new IllegalArgumentException("Please select at least one room.");

            // ── 4. Build DTO and call service ONCE ───────────────────────────────
            ReservationDTO dto = new ReservationDTO();
            dto.setGuestId(resolvedGuestId);
            dto.setUserId(user.getId());
            dto.setCheckInDate(checkIn);
            dto.setCheckOutDate(checkOut);
            dto.setAdults(adults);
            dto.setChildren(children);
            dto.setDiscountAmount(discount);
            dto.setSpecialRequests(request.getParameter("specialRequests"));
            dto.setSource(request.getParameter("source"));

            ReservationDTO saved = reservationService.createReservation(dto, roomIds);

            String successMsg = roomIds.size() == 1
                    ? "Reservation " + saved.getReservationNumber() + " created successfully!"
                    : roomIds.size() + " rooms booked under reservation "
                    + saved.getReservationNumber()
                    + ". Guest makes a single payment of $" + saved.getTotalAmount() + ".";

            session.setAttribute("success", successMsg);
            response.sendRedirect(request.getContextPath() + base
                    + "/reservations/view?id=" + saved.getId());

        } catch (IllegalArgumentException e) {
            // Forward back to form with error shown inline — do NOT redirect
            // (redirect loses the POST data; user can't see what they typed)
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pageTitle", "New Reservation");

            // Re-populate selectedGuest if guestId was provided
            String guestIdStr = request.getParameter("guestId");
            if (guestIdStr != null && !guestIdStr.trim().isEmpty()) {
                try {
                    Long gid = Long.parseLong(guestIdStr.trim());
                    guestService.getGuestById(gid)
                            .ifPresent(g -> request.setAttribute("selectedGuest", g));
                } catch (NumberFormatException ignored) {}
            }

            request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp")
                    .forward(request, response);
        }
    }

    /**
     * Updates a reservation. Replaces room list atomically.
     */
    protected void updateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User   user = (User) session.getAttribute("user");
        String base = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        try {
            if (idStr == null || idStr.trim().isEmpty())
                throw new IllegalArgumentException("Reservation ID is missing.");

            Long id = Long.parseLong(idStr.trim());

            ReservationDTO reservation = reservationService.getReservationById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));

            List<Long> roomIds = collectRoomIds(request);
            if (roomIds.isEmpty())
                throw new IllegalArgumentException("Please select at least one room.");

            LocalDate checkIn  = parseDate(request, "checkInDate");
            LocalDate checkOut = parseDate(request, "checkOutDate");
            if (!checkOut.isAfter(checkIn))
                throw new IllegalArgumentException("Check-out date must be after check-in date.");

            reservation.setCheckInDate(checkIn);
            reservation.setCheckOutDate(checkOut);
            reservation.setAdults(getIntParam(request, "adults", 1));
            reservation.setChildren(getIntParam(request, "children", 0));

            String discStr = request.getParameter("discountAmount");
            if (discStr != null && !discStr.trim().isEmpty()) {
                try { reservation.setDiscountAmount(new BigDecimal(discStr.trim())); }
                catch (NumberFormatException ignored) {}
            }

            reservation.setSpecialRequests(request.getParameter("specialRequests"));
            reservation.setSource(request.getParameter("source"));

            ReservationDTO updated = reservationService.updateReservation(reservation, roomIds);

            session.setAttribute("success", "Reservation updated successfully!");
            response.sendRedirect(request.getContextPath() + base
                    + "/reservations/view?id=" + updated.getId());

        } catch (IllegalArgumentException e) {
            // Forward back to edit form with error shown inline
            request.setAttribute("error", "Update failed: " + e.getMessage());
            request.setAttribute("pageTitle", "Edit Reservation");

            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    Long id = Long.parseLong(idStr.trim());
                    reservationService.getReservationById(id)
                            .ifPresent(r -> request.setAttribute("reservation", r));
                } catch (NumberFormatException | SQLException ignored) {}
            }

            request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp")
                    .forward(request, response);
        }
    }

    /**
     * Handles DELETE for both GET (legacy link) and POST (form submit).
     */
    protected void deleteReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                boolean deleted = reservationService.deleteReservation(Long.parseLong(idStr.trim()));
                session.setAttribute(deleted ? "success" : "error",
                        deleted ? "Reservation deleted successfully."
                                : "Failed to delete reservation.");
            } catch (Exception e) {
                session.setAttribute("error", "Error deleting reservation: " + e.getMessage());
            }
        } else {
            session.setAttribute("error", "No reservation ID provided.");
        }
        response.sendRedirect(request.getContextPath() + base + "/reservations");
    }

    protected void checkInReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.trim().isEmpty()) {
            Long id = Long.parseLong(idStr.trim());
            try {
                reservationService.checkIn(id);
                session.setAttribute("success", "Guest checked in successfully!");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base
                    + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void checkOutReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.trim().isEmpty()) {
            Long id = Long.parseLong(idStr.trim());
            try {
                reservationService.checkOut(id);
                session.setAttribute("success", "Guest checked out successfully!");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base
                    + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void cancelReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.trim().isEmpty()) {
            Long id = Long.parseLong(idStr.trim());
            try {
                reservationService.cancelReservation(id);
                session.setAttribute("success", "Reservation cancelled successfully.");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base
                    + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void printBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID required");
            return;
        }

        Long id = Long.parseLong(idStr.trim());
        ReservationDTO reservation = reservationService.getReservationById(id)
                .orElseThrow(() -> new ServletException("Reservation not found"));

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle", "Bill - " + reservation.getReservationNumber());
        request.getRequestDispatcher("/WEB-INF/views/reservations/bill.jsp")
                .forward(request, response);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────────

    /**
     * Collects all room IDs from the multi-room form.
     * Primary param: "roomIds" (multi-value, one per slot).
     * Fallback param: "roomId" (singular, legacy forms).
     * Skips empty strings (unselected slots).
     */
    protected List<Long> collectRoomIds(HttpServletRequest request) {
        List<Long> ids = new ArrayList<>();

        String[] multi = request.getParameterValues("roomIds");
        if (multi != null) {
            for (String val : multi) {
                if (val != null && !val.trim().isEmpty()) {
                    try { ids.add(Long.parseLong(val.trim())); }
                    catch (NumberFormatException ignored) {}
                }
            }
        }

        // Fallback: single roomId param (legacy)
        if (ids.isEmpty()) {
            String single = request.getParameter("roomId");
            if (single != null && !single.trim().isEmpty()) {
                try { ids.add(Long.parseLong(single.trim())); }
                catch (NumberFormatException ignored) {}
            }
        }

        return ids;
    }

    protected int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        try {
            return (val != null && !val.trim().isEmpty())
                    ? Integer.parseInt(val.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    protected String getUserBase(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) return user.isAdmin() ? "/admin" : "/staff";
        }
        return "";
    }

    private boolean requireLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private void handleDbError(HttpServletRequest request, HttpServletResponse response,
                               SQLException e) throws IOException {
        e.printStackTrace();
        HttpSession session = request.getSession(false);
        if (session != null)
            session.setAttribute("error", "Database error: " + e.getMessage());
        response.sendRedirect(
                request.getContextPath() + getUserBase(request) + "/reservations");
    }

    private String required(HttpServletRequest request, String name, String errMsg) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty())
            throw new IllegalArgumentException(errMsg);
        return val.trim();
    }

    private LocalDate parseDate(HttpServletRequest request, String name) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty())
            throw new IllegalArgumentException("Date '" + name + "' is required.");
        try {
            return LocalDate.parse(val.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException(
                    "Invalid date format for '" + name + "'. Use YYYY-MM-DD.");
        }
    }

    private SearchCriteriaDTO buildSearchCriteria(HttpServletRequest request) {
        SearchCriteriaDTO c = new SearchCriteriaDTO();
        c.setSearchType(request.getParameter("searchType"));
        c.setSearchValue(request.getParameter("searchValue"));
        c.setStatus(request.getParameter("status"));
        c.setPaymentStatus(request.getParameter("paymentStatus"));
        String ci = request.getParameter("checkInDate");
        String co = request.getParameter("checkOutDate");
        if (ci != null && !ci.isEmpty()) {
            try { c.setCheckInDate(LocalDate.parse(ci)); } catch (DateTimeParseException ignored) {}
        }
        if (co != null && !co.isEmpty()) {
            try { c.setCheckOutDate(LocalDate.parse(co)); } catch (DateTimeParseException ignored) {}
        }
        c.setPage(getIntParam(request, "page", 1));
        c.setSize(10);
        return c;
    }
}
