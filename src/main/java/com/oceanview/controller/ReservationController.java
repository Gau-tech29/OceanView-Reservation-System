package com.oceanview.controller;

import com.oceanview.dto.GuestDTO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.SearchCriteriaDTO;
import com.oceanview.model.Bill;
import com.oceanview.model.Payment;
import com.oceanview.model.User;
import com.oceanview.service.BillService;
import com.oceanview.service.GuestService;
import com.oceanview.service.PaymentService;
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
import java.util.logging.Logger;

@WebServlet("/reservations/*")
public class ReservationController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReservationController.class.getName());

    protected ReservationService reservationService;
    protected RoomService        roomService;
    protected GuestService       guestService;
    protected BillService        billService;
    protected PaymentService     paymentService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationService();
        roomService        = new RoomService();
        guestService       = new GuestService();
        billService        = new BillService();
        paymentService     = new PaymentService();
    }

    // ─── Dispatch ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireLogin(request, response)) return;

        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                String searchParam = request.getParameter("search");
                if (searchParam != null && !searchParam.trim().isEmpty()) {
                    searchReservationsGet(request, response);
                } else {
                    listReservations(request, response);
                }
            } else switch (pathInfo) {
                case "/new":             showNewForm(request, response);             break;
                case "/edit":            showEditForm(request, response);            break;
                case "/view":            viewReservation(request, response);         break;
                case "/search":          showSearchForm(request, response);          break;
                case "/checkin":         checkInReservation(request, response);      break;
                case "/checkout":        showCheckoutPaymentForm(request, response); break;
                case "/cancel":          cancelReservation(request, response);       break;
                case "/delete":          deleteReservation(request, response);       break;
                case "/print-bill":      printBill(request, response);               break;
                default:                 response.sendError(HttpServletResponse.SC_NOT_FOUND);
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
            } else if ("/search".equals(pathInfo)) {
                searchReservationsPost(request, response);
            } else if ("/process-checkout".equals(pathInfo)) {
                processCheckout(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            handleDbError(request, response, e);
        }
    }

    // ─── Checkout Payment Flow ────────────────────────────────────────────────────

    /**
     * GET /checkout?id=X  — show payment collection form before checking guest out.
     */
    protected void showCheckoutPaymentForm(HttpServletRequest request,
                                           HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID required");
            return;
        }

        Long id = Long.parseLong(idStr.trim());
        ReservationDTO reservation = reservationService.getReservationById(id).orElse(null);

        if (reservation == null) {
            request.getSession().setAttribute("error", "Reservation not found.");
            response.sendRedirect(request.getContextPath()
                    + getUserBase(request) + "/reservations");
            return;
        }

        if (!"CHECKED_IN".equals(reservation.getReservationStatus())) {
            request.getSession().setAttribute("error",
                    "Only CHECKED IN reservations can be checked out. Current status: "
                            + reservation.getReservationStatus());
            response.sendRedirect(request.getContextPath()
                    + getUserBase(request) + "/reservations/view?id=" + id);
            return;
        }

        request.setAttribute("reservation", reservation);
        request.setAttribute("pageTitle", "Checkout & Payment");
        request.getRequestDispatcher("/WEB-INF/views/reservations/checkout.jsp")
                .forward(request, response);
    }

    /**
     * POST /process-checkout — create bill, record payment, check out guest,
     *                          then redirect to the print-bill page.
     */
    protected void processCheckout(HttpServletRequest request,
                                   HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("error", "Reservation ID is missing.");
            response.sendRedirect(request.getContextPath() + base + "/reservations");
            return;
        }

        Long id = Long.parseLong(idStr.trim());

        try {
            // ── 1. Load & validate reservation ───────────────────────────────────
            ReservationDTO reservation = reservationService.getReservationById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));

            if (!"CHECKED_IN".equals(reservation.getReservationStatus())) {
                throw new IllegalArgumentException(
                        "Only CHECKED IN reservations can be checked out.");
            }

            // ── 2. Validate payment method ────────────────────────────────────────
            String payMethodStr = request.getParameter("paymentMethod");
            if (payMethodStr == null || payMethodStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Please select a payment method.");
            }

            // Bill uses CASH / CARD / BANK_TRANSFER
            Bill.PaymentMethod billPayMethod;
            switch (payMethodStr.trim()) {
                case "CASH":          billPayMethod = Bill.PaymentMethod.CASH;          break;
                case "BANK_TRANSFER": billPayMethod = Bill.PaymentMethod.BANK_TRANSFER; break;
                case "CREDIT_CARD":
                case "DEBIT_CARD":    billPayMethod = Bill.PaymentMethod.CARD;          break;
                default:
                    throw new IllegalArgumentException(
                            "Invalid payment method: " + payMethodStr);
            }

            // Payment model uses CASH / CREDIT_CARD / DEBIT_CARD / BANK_TRANSFER
            Payment.PaymentMethod payMethod;
            try {
                payMethod = Payment.PaymentMethod.valueOf(payMethodStr.trim());
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException(
                        "Invalid payment method: " + payMethodStr);
            }

            String cardLastFour  = request.getParameter("cardLastFour");
            String transactionId = request.getParameter("transactionId");
            String notes         = request.getParameter("paymentNotes");

            // ── 3. Create bill (or reuse existing) ───────────────────────────────
            List<Bill> existingBills = billService.getBillsByReservation(id);
            Bill bill;
            if (!existingBills.isEmpty()) {
                bill = existingBills.get(0);
                if (!bill.isPaid()) {
                    bill = billService.markAsPaid(bill.getId(), billPayMethod);
                }
            } else {
                bill = billService.createBill(id, user.getId());
                bill = billService.markAsPaid(bill.getId(), billPayMethod);
            }

            // ── 4. Record payment ─────────────────────────────────────────────────
            Payment payment = new Payment();
            payment.setReservationId(id);
            payment.setAmount(reservation.getTotalAmount());
            payment.setPaymentMethod(payMethod);
            payment.setPaymentStatus(Payment.PaymentStatus.COMPLETED);
            if (cardLastFour != null && !cardLastFour.trim().isEmpty()) {
                payment.setCardLastFour(cardLastFour.trim());
            }
            if (transactionId != null && !transactionId.trim().isEmpty()) {
                payment.setTransactionId(transactionId.trim());
            }
            if (notes != null && !notes.trim().isEmpty()) {
                payment.setNotes(notes.trim());
            }
            paymentService.createPayment(payment);

            // ── 5. Mark reservation payment status = PAID ────────────────────────
            reservationService.markReservationAsPaid(id);

            // ── 6. Set reservation status = CHECKED_OUT ───────────────────────────
            reservationService.checkOut(id);

            // ── 7. Redirect to print-bill page ────────────────────────────────────
            String amtStr = String.format("%.2f", reservation.getTotalAmount().doubleValue());
            session.setAttribute("success",
                    "Payment of $" + amtStr
                            + " received via " + payMethodStr.replace("_", " ")
                            + ". Guest checked out successfully! Please print the bill below.");

            response.sendRedirect(request.getContextPath()
                    + base + "/reservations/print-bill?id=" + id);

        } catch (IllegalArgumentException e) {
            // Re-show checkout form with inline error
            ReservationDTO reservation =
                    reservationService.getReservationById(id).orElse(null);
            request.setAttribute("reservation", reservation);
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pageTitle", "Checkout & Payment");
            request.getRequestDispatcher("/WEB-INF/views/reservations/checkout.jsp")
                    .forward(request, response);
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

    protected void showSearchForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Search Reservations");
        request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp")
                .forward(request, response);
    }

    protected void searchReservationsGet(HttpServletRequest request,
                                         HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        request.setAttribute("pageTitle", "Search Results");
        String searchType  = request.getParameter("searchType");
        String searchValue = request.getParameter("search");
        if (searchType == null || searchType.trim().isEmpty()) searchType = "all";

        SearchCriteriaDTO criteria = new SearchCriteriaDTO();
        criteria.setSearchType(searchType);
        criteria.setSearchValue(searchValue != null ? searchValue : "");
        criteria.setPage(getIntParam(request, "page", 1));
        criteria.setSize(10);

        List<ReservationDTO> results = reservationService.searchReservations(criteria);
        long totalCount = results.size();
        int  totalPages = (int) Math.ceil((double) totalCount / 10);

        request.setAttribute("reservations",  results);
        request.setAttribute("currentPage",   criteria.getPage());
        request.setAttribute("totalPages",    totalPages);
        request.setAttribute("totalCount",    totalCount);
        request.setAttribute("searchKeyword", searchValue);
        request.setAttribute("searchType",    searchType);
        request.getRequestDispatcher("/WEB-INF/views/reservations/list.jsp")
                .forward(request, response);
    }

    protected void searchReservationsPost(HttpServletRequest request,
                                          HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        request.setAttribute("pageTitle", "Search Results");
        SearchCriteriaDTO criteria = buildSearchCriteria(request);
        List<ReservationDTO> results = reservationService.searchReservations(criteria);
        request.setAttribute("results",  results);
        request.setAttribute("criteria", criteria);
        request.getRequestDispatcher("/WEB-INF/views/reservations/search.jsp")
                .forward(request, response);
    }

    // ─── POST handlers ────────────────────────────────────────────────────────────

    protected void saveReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User   user = (User) session.getAttribute("user");
        String base = user.isAdmin() ? "/admin" : "/staff";

        try {
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

            List<Long> roomIds = collectRoomIds(request);
            if (roomIds.isEmpty())
                throw new IllegalArgumentException("Please select at least one room.");

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
            session.setAttribute("success",
                    roomIds.size() == 1
                            ? "Reservation " + saved.getReservationNumber() + " created successfully!"
                            : roomIds.size() + " rooms booked under reservation "
                            + saved.getReservationNumber()
                            + ". Total: $" + saved.getTotalAmount() + ".");

            response.sendRedirect(request.getContextPath()
                    + base + "/reservations/view?id=" + saved.getId());

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pageTitle", "New Reservation");
            String guestIdStr = request.getParameter("guestId");
            if (guestIdStr != null && !guestIdStr.trim().isEmpty()) {
                try {
                    Long gid = Long.parseLong(guestIdStr.trim());
                    guestService.getGuestById(gid)
                            .ifPresent(g -> request.setAttribute("selectedGuest", g));
                } catch (NumberFormatException | SQLException ignored) {}
            }
            request.getRequestDispatcher("/WEB-INF/views/reservations/form.jsp")
                    .forward(request, response);
        }
    }

    protected void updateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
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
            response.sendRedirect(request.getContextPath()
                    + base + "/reservations/view?id=" + updated.getId());

        } catch (IllegalArgumentException e) {
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

    protected void deleteReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession();
        User   user  = (User) session.getAttribute("user");
        String base  = user.isAdmin() ? "/admin" : "/staff";
        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                boolean deleted = reservationService
                        .deleteReservation(Long.parseLong(idStr.trim()));
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
            response.sendRedirect(request.getContextPath()
                    + base + "/reservations/view?id=" + id);
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
            response.sendRedirect(request.getContextPath()
                    + base + "/reservations/view?id=" + id);
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
        response.sendRedirect(request.getContextPath()
                + getUserBase(request) + "/reservations");
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
        String searchType    = request.getParameter("searchType");
        String searchValue   = request.getParameter("searchValue");
        String status        = request.getParameter("status");
        String paymentStatus = request.getParameter("paymentStatus");
        String checkInStr    = request.getParameter("checkInDate");
        String checkOutStr   = request.getParameter("checkOutDate");

        c.setSearchType(searchType != null ? searchType : "all");
        c.setSearchValue(searchValue != null ? searchValue : "");
        c.setStatus(status != null && !status.isEmpty() ? status : null);
        c.setPaymentStatus(paymentStatus != null && !paymentStatus.isEmpty()
                ? paymentStatus : null);

        if (checkInStr != null && !checkInStr.isEmpty()) {
            try { c.setCheckInDate(LocalDate.parse(checkInStr)); }
            catch (DateTimeParseException ignored) {}
        }
        if (checkOutStr != null && !checkOutStr.isEmpty()) {
            try { c.setCheckOutDate(LocalDate.parse(checkOutStr)); }
            catch (DateTimeParseException ignored) {}
        }
        c.setPage(getIntParam(request, "page", 1));
        c.setSize(10);
        return c;
    }
}