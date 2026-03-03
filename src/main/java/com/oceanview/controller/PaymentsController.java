package com.oceanview.controller;

import com.oceanview.dto.PaymentDTO;
import com.oceanview.model.Payment;
import com.oceanview.model.User;
import com.oceanview.service.PaymentService;
import com.oceanview.service.BillService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet({"/staff/payments/*", "/admin/payments/*"})
public class PaymentsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentsController.class.getName());

    private PaymentService paymentService;
    private BillService    billService;

    @Override
    public void init() throws ServletException {
        paymentService = new PaymentService();
        billService    = new BillService();
    }

    // ─── GET ──────────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireLogin(request, response)) return;

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Check if any filter/search params are present
                if (hasSearchParams(request)) {
                    searchPayments(request, response);
                } else {
                    listPayments(request, response);
                }
            } else {
                switch (pathInfo) {
                    case "/view":
                        viewPayment(request, response);
                        break;
                    case "/refund":
                        showRefundForm(request, response);
                        break;
                    case "/search":
                        searchPayments(request, response);
                        break;
                    case "/by-guest":
                        listPaymentsByGuest(request, response);
                        break;
                    case "/by-reservation":
                        listPaymentsByReservation(request, response);
                        break;
                    default:
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            }
        } catch (SQLException e) {
            handleDbError(request, response, e);
        }
    }

    // ─── POST ─────────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireLogin(request, response)) return;

        String pathInfo = request.getPathInfo();

        try {
            if ("/refund".equals(pathInfo)) {
                processRefund(request, response);
            } else if ("/search".equals(pathInfo)) {
                searchPayments(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            handleDbError(request, response, e);
        }
    }

    // ─── List ─────────────────────────────────────────────────────────────────────

    private void listPayments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = getIntParam(request, "page", 1);
        int size = getIntParam(request, "size", 10);

        List<PaymentDTO> payments   = paymentService.getAllPaymentDTOs(page, size);
        long             totalCount = paymentService.getTotalPaymentsCount();
        int              totalPages = (int) Math.ceil((double) totalCount / size);

        setRevenueStats(request);

        request.setAttribute("payments",    payments);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages",  totalPages);
        request.setAttribute("totalCount",  totalCount);
        request.setAttribute("pageTitle",   "Payments & Bills");

        request.getRequestDispatcher("/WEB-INF/views/payments/list.jsp")
                .forward(request, response);
    }

    // ─── View ─────────────────────────────────────────────────────────────────────

    private void viewPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr     = request.getParameter("id");
        String numberStr = request.getParameter("number");

        PaymentDTO payment = null;

        if (idStr != null && !idStr.isEmpty()) {
            try {
                payment = paymentService.getPaymentDTOById(Long.parseLong(idStr)).orElse(null);
            } catch (NumberFormatException e) {
                payment = null;
            }
        } else if (numberStr != null && !numberStr.isEmpty()) {
            payment = paymentService.getPaymentDTOByNumber(numberStr).orElse(null);
        }

        if (payment == null) {
            request.setAttribute("error", "Payment not found.");
            request.getRequestDispatcher("/WEB-INF/views/payments/list.jsp")
                    .forward(request, response);
            return;
        }

        // ── FIX: getBillId() returns 0L (not null) when the SQL LEFT JOIN yields NULL.
        // We must check > 0 to avoid a useless lookup for id=0.
        if (payment.getBillId() != null && payment.getBillId() > 0) {
            try {
                billService.getBillById(payment.getBillId())
                        .ifPresent(b -> request.setAttribute("bill", b));
            } catch (SQLException e) {
                LOGGER.warning("Could not load bill (id=" + payment.getBillId()
                        + ") for payment " + payment.getPaymentNumber() + ": " + e.getMessage());
            }
        } else if (payment.getReservationId() != null && payment.getReservationId() > 0) {
            // Fallback: look up bill by reservation_id in case the DTO join missed it
            try {
                java.util.List<com.oceanview.model.Bill> bills =
                        billService.getBillsByReservation(payment.getReservationId());
                if (!bills.isEmpty()) {
                    com.oceanview.model.Bill b = bills.get(0);
                    request.setAttribute("bill", b);
                    // Also back-fill billNumber onto the DTO so the JSP can show it
                    if (payment.getBillNumber() == null || payment.getBillNumber().isEmpty()) {
                        payment.setBillNumber(b.getBillNumber());
                        payment.setBillId(b.getId());
                        payment.setBillTotalAmount(b.getTotalAmount());
                        payment.setBillStatus(b.getBillStatus() != null
                                ? b.getBillStatus().name() : null);
                    }
                }
            } catch (SQLException e) {
                LOGGER.warning("Could not load bill by reservationId="
                        + payment.getReservationId() + ": " + e.getMessage());
            }
        }

        request.setAttribute("payment",   payment);
        request.setAttribute("pageTitle", "Payment Details - " + payment.getPaymentNumber());
        request.getRequestDispatcher("/WEB-INF/views/payments/view.jsp")
                .forward(request, response);
    }

    // ─── Refund form ──────────────────────────────────────────────────────────────

    private void showRefundForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Payment ID required");
            return;
        }

        Long id = Long.parseLong(idStr);
        PaymentDTO payment = paymentService.getPaymentDTOById(id)
                .orElseThrow(() -> new ServletException("Payment not found"));

        if (!payment.isRefundable()) {
            request.getSession().setAttribute("error",
                    "This payment cannot be refunded. Current status: "
                            + payment.getPaymentStatusDisplay());
            response.sendRedirect(request.getContextPath()
                    + getUserBase(request) + "/payments/view?id=" + id);
            return;
        }

        request.setAttribute("payment",   payment);
        request.setAttribute("pageTitle", "Refund Payment");
        request.getRequestDispatcher("/WEB-INF/views/payments/refund.jsp")
                .forward(request, response);
    }

    // ─── Process Refund ───────────────────────────────────────────────────────────

    private void processRefund(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session  = request.getSession();
        String      basePath = getUserBase(request);

        String idStr  = request.getParameter("id");
        String reason = request.getParameter("reason");

        if (idStr == null || idStr.isEmpty()) {
            session.setAttribute("error", "Payment ID is required");
            response.sendRedirect(request.getContextPath() + basePath + "/payments");
            return;
        }

        try {
            Long id = Long.parseLong(idStr);

            PaymentDTO paymentDTO = paymentService.getPaymentDTOById(id).orElse(null);
            if (paymentDTO == null) {
                session.setAttribute("error", "Payment not found");
                response.sendRedirect(request.getContextPath() + basePath + "/payments");
                return;
            }

            Payment payment = paymentService.processRefund(
                    id, reason != null && !reason.trim().isEmpty() ? reason.trim() : "Refund requested");

            session.setAttribute("success",
                    "Payment " + payment.getPaymentNumber()
                            + " has been successfully refunded.");

            response.sendRedirect(request.getContextPath()
                    + basePath + "/payments/view?id=" + id);

        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
            response.sendRedirect(request.getContextPath()
                    + basePath + "/payments/view?id=" + idStr);
        }
    }

    // ─── Search ───────────────────────────────────────────────────────────────────

    private void searchPayments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword     = request.getParameter("keyword");
        String status      = request.getParameter("status");
        String method      = request.getParameter("method");
        String startDateStr = request.getParameter("startDate");
        String endDateStr   = request.getParameter("endDate");

        // Also accept plain 'search' param from simple search boxes
        String searchParam = request.getParameter("search");
        if (searchParam != null && !searchParam.trim().isEmpty()
                && (keyword == null || keyword.isEmpty())) {
            keyword = searchParam;
        }

        LocalDate startDate = null;
        LocalDate endDate   = null;
        try {
            if (startDateStr != null && !startDateStr.isEmpty())
                startDate = LocalDate.parse(startDateStr);
            if (endDateStr != null && !endDateStr.isEmpty())
                endDate = LocalDate.parse(endDateStr);
        } catch (DateTimeParseException e) {
            request.setAttribute("error", "Invalid date format. Please use YYYY-MM-DD.");
        }

        List<PaymentDTO> results = paymentService.searchPayments(
                keyword, status, method, startDate, endDate);

        setRevenueStats(request);

        request.setAttribute("payments",       results);
        request.setAttribute("searchKeyword",  keyword);
        request.setAttribute("searchStatus",   status);
        request.setAttribute("searchMethod",   method);
        request.setAttribute("searchStartDate", startDateStr);
        request.setAttribute("searchEndDate",   endDateStr);
        request.setAttribute("totalCount",      results.size());
        request.setAttribute("pageTitle",       keyword != null && !keyword.isEmpty()
                ? "Search: \"" + keyword + "\"" : "Payments & Bills");

        request.getRequestDispatcher("/WEB-INF/views/payments/list.jsp")
                .forward(request, response);
    }

    // ─── By Guest ─────────────────────────────────────────────────────────────────

    private void listPaymentsByGuest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String guestIdStr = request.getParameter("guestId");
        if (guestIdStr == null || guestIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Guest ID required");
            return;
        }

        Long guestId = Long.parseLong(guestIdStr);
        List<PaymentDTO> payments = paymentService.getPaymentsByGuest(guestId);

        setRevenueStats(request);
        request.setAttribute("payments",   payments);
        request.setAttribute("guestId",    guestId);
        request.setAttribute("totalCount", payments.size());
        request.setAttribute("pageTitle",  "Payments for Guest");
        request.getRequestDispatcher("/WEB-INF/views/payments/list.jsp")
                .forward(request, response);
    }

    // ─── By Reservation ───────────────────────────────────────────────────────────

    private void listPaymentsByReservation(HttpServletRequest request,
                                           HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String reservationIdStr = request.getParameter("reservationId");
        if (reservationIdStr == null || reservationIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID required");
            return;
        }

        Long reservationId = Long.parseLong(reservationIdStr);
        List<PaymentDTO> payments = paymentService.getPaymentsByReservationDTO(reservationId);

        setRevenueStats(request);
        request.setAttribute("payments",       payments);
        request.setAttribute("reservationId",  reservationId);
        request.setAttribute("totalCount",     payments.size());
        request.setAttribute("pageTitle",      "Payments for Reservation");
        request.getRequestDispatcher("/WEB-INF/views/payments/list.jsp")
                .forward(request, response);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────────

    /**
     * Returns true when the request contains any filter/search parameters.
     */
    private boolean hasSearchParams(HttpServletRequest request) {
        String keyword   = request.getParameter("keyword");
        String search    = request.getParameter("search");
        String status    = request.getParameter("status");
        String method    = request.getParameter("method");
        String startDate = request.getParameter("startDate");
        String endDate   = request.getParameter("endDate");
        return (keyword   != null && !keyword.trim().isEmpty())
                || (search    != null && !search.trim().isEmpty())
                || (status    != null && !status.trim().isEmpty())
                || (method    != null && !method.trim().isEmpty())
                || (startDate != null && !startDate.trim().isEmpty())
                || (endDate   != null && !endDate.trim().isEmpty());
    }

    /**
     * Sets weekly/monthly revenue stats as request attributes.
     */
    private void setRevenueStats(HttpServletRequest request) {
        try {
            LocalDate today    = LocalDate.now();
            LocalDate weekAgo  = today.minusDays(7);
            LocalDate monthAgo = today.minusMonths(1);

            double weeklyRevenue  = paymentService.getTotalRevenue(
                    weekAgo.atStartOfDay(), today.atTime(23, 59, 59));
            double monthlyRevenue = paymentService.getTotalRevenue(
                    monthAgo.atStartOfDay(), today.atTime(23, 59, 59));
            double weeklyRefunds  = paymentService.getTotalRefundedAmount(
                    weekAgo.atStartOfDay(), today.atTime(23, 59, 59));

            request.setAttribute("weeklyRevenue",  weeklyRevenue);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("weeklyRefunds",  weeklyRefunds);
        } catch (SQLException e) {
            LOGGER.warning("Could not load revenue stats: " + e.getMessage());
            request.setAttribute("weeklyRevenue",  0.0);
            request.setAttribute("monthlyRevenue", 0.0);
            request.setAttribute("weeklyRefunds",  0.0);
        }
    }

    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        try {
            return (val != null && !val.trim().isEmpty())
                    ? Integer.parseInt(val.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("user") : null;
    }

    private String getUserBase(HttpServletRequest request) {
        User user = getUser(request);
        return (user != null && user.isAdmin()) ? "/admin" : "/staff";
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
        if (session != null) {
            session.setAttribute("error", "Database error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + getUserBase(request) + "/payments");
    }
}