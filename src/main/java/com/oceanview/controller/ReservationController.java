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
import java.util.List;
import java.util.Optional;

@WebServlet("/reservations/*")
public class ReservationController extends HttpServlet {

    protected ReservationService reservationService;
    protected RoomService roomService;
    protected GuestService guestService;

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

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                listReservations(request, response);
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
            } else if (pathInfo.equals("/print-bill")) {
                printBill(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            String base = getUserBase(request);
            response.sendRedirect(request.getContextPath() + base + "/reservations");
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
            String base = getUserBase(request);
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        List<Room> rooms = roomService.getAvailableRooms();
        List<RoomDTO> roomDTOs = RoomMapper.getInstance().toDTOList(rooms);

        request.setAttribute("rooms", roomDTOs);
        request.setAttribute("pageTitle", "New Reservation");

        String guestId = request.getParameter("guestId");
        if (guestId != null && !guestId.isEmpty()) {
            try {
                Long id = Long.parseLong(guestId);
                guestService.getGuestById(id)
                        .ifPresent(g -> request.setAttribute("selectedGuest", g));
            } catch (NumberFormatException e) {
                // Ignore invalid guestId
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp").forward(request, response);
    }

    protected void listReservations(HttpServletRequest request, HttpServletResponse response)
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
        request.setAttribute("pageTitle", "All Reservations");

        request.getRequestDispatcher("/WEB-INF/views/reservations/list.jsp").forward(request, response);
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
        request.setAttribute("pageTitle", "Edit Reservation");

        // Load all rooms (not just available, since we're editing)
        List<Room> rooms = roomService.getAllRooms();
        List<RoomDTO> roomDTOs = RoomMapper.getInstance().toDTOList(rooms);
        request.setAttribute("rooms", roomDTOs);

        // Load guest info
        if (reservation.getGuestId() != null) {
            guestService.getGuestById(reservation.getGuestId())
                    .ifPresent(g -> request.setAttribute("selectedGuest", g));
        }

        request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp").forward(request, response);
    }

    protected void viewReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        String numberStr = request.getParameter("number");
        ReservationDTO reservation = null;

        if (idStr != null && !idStr.isEmpty()) {
            reservation = reservationService.getReservationById(Long.parseLong(idStr)).orElse(null);
        } else if (numberStr != null && !numberStr.isEmpty()) {
            reservation = reservationService.getReservationByNumber(numberStr).orElse(null);
        }

        if (reservation == null) {
            request.setAttribute("error", "Reservation not found");
            request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp").forward(request, response);
            return;
        }

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle", "Reservation Details");
        request.getRequestDispatcher("/WEB-INF/views/reservations/view.jsp").forward(request, response);
    }

    protected void searchReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        request.setAttribute("pageTitle", "Search Reservations");

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp").forward(request, response);
            return;
        }

        SearchCriteriaDTO criteria = buildSearchCriteria(request);
        List<ReservationDTO> results = reservationService.searchReservations(criteria);
        request.setAttribute("results", results);
        request.setAttribute("criteria", criteria);
        request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp").forward(request, response);
    }

    protected void saveReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String base = user.isAdmin() ? "/admin" : "/staff";

        try {
            String guestMode = request.getParameter("guestMode");
            Long resolvedGuestId;

            if ("new".equals(guestMode)) {
                GuestDTO newGuest = new GuestDTO();
                newGuest.setFirstName(required(request, "firstName", "First name is required"));
                newGuest.setLastName(required(request, "lastName", "Last name is required"));
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

                GuestDTO savedGuest = guestService.createGuest(newGuest);
                resolvedGuestId = savedGuest.getId();

            } else {
                String guestIdStr = request.getParameter("guestId");
                if (guestIdStr == null || guestIdStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Please select an existing guest or choose 'New Guest'.");
                }

                try {
                    resolvedGuestId = Long.parseLong(guestIdStr.trim());
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid guest ID format");
                }

                Optional<GuestDTO> existingGuest = guestService.getGuestById(resolvedGuestId);
                if (!existingGuest.isPresent()) {
                    throw new IllegalArgumentException("Guest not found. Please search again.");
                }
            }

            ReservationDTO reservation = new ReservationDTO();
            reservation.setGuestId(resolvedGuestId);
            reservation.setUserId(user.getId());

            String roomIdStr = request.getParameter("roomId");
            if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Please select a room");
            }
            reservation.setRoomId(Long.parseLong(roomIdStr));

            reservation.setCheckInDate(parseDate(request, "checkInDate"));
            reservation.setCheckOutDate(parseDate(request, "checkOutDate"));

            if (!reservation.getCheckOutDate().isAfter(reservation.getCheckInDate())) {
                throw new IllegalArgumentException("Check-out date must be after check-in date.");
            }

            reservation.setAdults(getIntParam(request, "adults", 1));
            reservation.setChildren(getIntParam(request, "children", 0));

            String discountStr = request.getParameter("discountAmount");
            if (discountStr != null && !discountStr.trim().isEmpty()) {
                try {
                    reservation.setDiscountAmount(new BigDecimal(discountStr));
                } catch (NumberFormatException e) {
                    reservation.setDiscountAmount(BigDecimal.ZERO);
                }
            } else {
                reservation.setDiscountAmount(BigDecimal.ZERO);
            }

            reservation.setSpecialRequests(request.getParameter("specialRequests"));
            reservation.setSource(request.getParameter("source"));

            ReservationDTO saved = reservationService.createReservation(reservation);
            session.setAttribute("success", "Reservation created successfully! Number: " + saved.getReservationNumber());

            response.sendRedirect(request.getContextPath() + base + "/reservations/view?id=" + saved.getId());
            return;

        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
            response.sendRedirect(request.getContextPath() + base + "/reservations/new");
        }
    }

    protected void updateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String base = user.isAdmin() ? "/admin" : "/staff";

        try {
            Long id = Long.parseLong(request.getParameter("id"));
            ReservationDTO reservation = reservationService.getReservationById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

            reservation.setRoomId(Long.parseLong(request.getParameter("roomId")));
            reservation.setCheckInDate(parseDate(request, "checkInDate"));
            reservation.setCheckOutDate(parseDate(request, "checkOutDate"));
            reservation.setAdults(getIntParam(request, "adults", 1));
            reservation.setChildren(getIntParam(request, "children", 0));

            String discountStr = request.getParameter("discountAmount");
            if (discountStr != null && !discountStr.isEmpty()) {
                reservation.setDiscountAmount(new BigDecimal(discountStr));
            }
            reservation.setSpecialRequests(request.getParameter("specialRequests"));
            reservation.setSource(request.getParameter("source"));

            ReservationDTO updated = reservationService.updateReservation(reservation);
            session.setAttribute("success", "Reservation updated successfully!");

            response.sendRedirect(request.getContextPath() + base + "/reservations/view?id=" + updated.getId());
            return;

        } catch (Exception e) {
            session.setAttribute("error", "Update failed: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + base + "/reservations/edit?id=" + request.getParameter("id"));
        }
    }

    protected void deleteReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String idStr = request.getParameter("id");
        String base = user.isAdmin() ? "/admin" : "/staff";

        if (idStr != null && !idStr.isEmpty()) {
            try {
                boolean deleted = reservationService.deleteReservation(Long.parseLong(idStr));
                if (deleted) {
                    session.setAttribute("success", "Reservation deleted successfully.");
                } else {
                    session.setAttribute("error", "Failed to delete reservation.");
                }
            } catch (Exception e) {
                session.setAttribute("error", "Error: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + base + "/reservations");
    }

    protected void checkInReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String idStr = request.getParameter("id");
        String base = user.isAdmin() ? "/admin" : "/staff";

        if (idStr != null && !idStr.isEmpty()) {
            Long id = Long.parseLong(idStr);
            try {
                reservationService.checkIn(id);
                session.setAttribute("success", "Guest checked in successfully!");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void checkOutReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String idStr = request.getParameter("id");
        String base = user.isAdmin() ? "/admin" : "/staff";

        if (idStr != null && !idStr.isEmpty()) {
            Long id = Long.parseLong(idStr);
            try {
                reservationService.checkOut(id);
                session.setAttribute("success", "Guest checked out successfully!");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void cancelReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String idStr = request.getParameter("id");
        String base = user.isAdmin() ? "/admin" : "/staff";

        if (idStr != null && !idStr.isEmpty()) {
            Long id = Long.parseLong(idStr);
            try {
                reservationService.cancelReservation(id);
                session.setAttribute("success", "Reservation cancelled successfully.");
            } catch (IllegalArgumentException e) {
                session.setAttribute("error", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + base + "/reservations/view?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + base + "/reservations");
        }
    }

    protected void printBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Long id = Long.parseLong(idStr);
        ReservationDTO reservation = reservationService.getReservationById(id)
                .orElseThrow(() -> new ServletException("Reservation not found"));

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle", "Bill - " + reservation.getReservationNumber());
        request.getRequestDispatcher("/WEB-INF/views/reservations/bill.jsp").forward(request, response);
    }

    protected int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        try {
            return (val != null && !val.trim().isEmpty()) ? Integer.parseInt(val.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    protected String getUserBase(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                return user.isAdmin() ? "/admin" : "/staff";
            }
        }
        return "";
    }

    private String required(HttpServletRequest request, String name, String errMsg) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) throw new IllegalArgumentException(errMsg);
        return val.trim();
    }

    private LocalDate parseDate(HttpServletRequest request, String name) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty())
            throw new IllegalArgumentException("Date '" + name + "' is required.");
        try {
            return LocalDate.parse(val.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid date: " + name + ". Use YYYY-MM-DD.");
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
        if (ci != null && !ci.isEmpty()) c.setCheckInDate(LocalDate.parse(ci));
        if (co != null && !co.isEmpty()) c.setCheckOutDate(LocalDate.parse(co));
        c.setPage(getIntParam(request, "page", 1));
        c.setSize(10);
        return c;
    }
}