package com.oceanview.service;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.impl.PaymentDAOImpl;
import com.oceanview.dto.PaymentDTO;
import com.oceanview.model.Payment;
import com.oceanview.util.ValidationUtils;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class PaymentService {

    private final PaymentDAO paymentDAO;

    public PaymentService() {
        this.paymentDAO = PaymentDAOImpl.getInstance();
    }

    public PaymentService(PaymentDAO paymentDAO) {
        this.paymentDAO = paymentDAO;
    }

    public Payment createPayment(Payment payment) throws SQLException, IllegalArgumentException {
        // Validate payment
        if (payment.getAmount() == null || payment.getAmount().compareTo(java.math.BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Payment amount must be greater than zero");
        }

        if (payment.getPaymentMethod() == null) {
            throw new IllegalArgumentException("Payment method is required");
        }

        // Generate payment number if not provided
        if (payment.getPaymentNumber() == null || payment.getPaymentNumber().trim().isEmpty()) {
            payment.setPaymentNumber(generatePaymentNumber());
        }

        return paymentDAO.save(payment);
    }

    public Optional<Payment> getPaymentById(Long id) throws SQLException {
        return paymentDAO.findById(id);
    }

    public Optional<Payment> getPaymentByNumber(String paymentNumber) throws SQLException {
        return paymentDAO.findByPaymentNumber(paymentNumber);
    }

    public List<Payment> getPaymentsByReservation(Long reservationId) throws SQLException {
        return paymentDAO.findByReservationId(reservationId);
    }

    public List<Payment> getAllPayments() throws SQLException {
        return paymentDAO.findAll();
    }

    public List<Payment> getPaymentsByStatus(Payment.PaymentStatus status) throws SQLException {
        return paymentDAO.findByStatus(status);
    }

    public List<Payment> getPaymentsByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException {
        return paymentDAO.findByDateRange(start, end);
    }

    public List<Payment> getPaymentsByMethod(Payment.PaymentMethod method) throws SQLException {
        return paymentDAO.findByMethod(method);
    }

    public double getTotalRevenue(LocalDateTime start, LocalDateTime end) throws SQLException {
        return paymentDAO.getTotalPaymentsByDateRange(start, end);
    }

    public double getTotalRefundedAmount(LocalDateTime start, LocalDateTime end) throws SQLException {
        return paymentDAO.getTotalRefundedAmount(start, end);
    }

    public boolean updatePaymentStatus(Long id, Payment.PaymentStatus status) throws SQLException {
        return paymentDAO.updateStatus(id, status);
    }

    public Payment processRefund(Long paymentId, String reason) throws SQLException, IllegalArgumentException {
        Optional<Payment> paymentOpt = paymentDAO.findById(paymentId);

        if (!paymentOpt.isPresent()) {
            throw new IllegalArgumentException("Payment not found");
        }

        Payment payment = paymentOpt.get();

        if (payment.isRefunded()) {
            throw new IllegalArgumentException("Payment has already been refunded");
        }

        if (!payment.isCompleted()) {
            throw new IllegalArgumentException("Only completed payments can be refunded");
        }

        payment.markAsRefunded();
        payment.setNotes((payment.getNotes() != null ? payment.getNotes() + " | " : "") +
                "Refunded: " + reason + " on " + LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));

        return paymentDAO.update(payment);
    }

    public Payment processRefundByNumber(String paymentNumber, String reason) throws SQLException, IllegalArgumentException {
        Optional<Payment> paymentOpt = paymentDAO.findByPaymentNumber(paymentNumber);

        if (!paymentOpt.isPresent()) {
            throw new IllegalArgumentException("Payment not found");
        }

        return processRefund(paymentOpt.get().getId(), reason);
    }

    // New DTO methods
    public List<PaymentDTO> getAllPaymentDTOs(int page, int size) throws SQLException {
        return paymentDAO.findAllPaymentDTOs(page, size);
    }

    public List<PaymentDTO> getRecentPaymentDTOs(int limit) throws SQLException {
        return paymentDAO.findRecentPaymentDTOs(limit);
    }

    public Optional<PaymentDTO> getPaymentDTOById(Long id) throws SQLException {
        return paymentDAO.findPaymentDTOById(id);
    }

    public Optional<PaymentDTO> getPaymentDTOByNumber(String paymentNumber) throws SQLException {
        return paymentDAO.findPaymentDTOByNumber(paymentNumber);
    }


    public List<PaymentDTO> searchPayments(String keyword, String status, String method,
                                           LocalDate startDate, LocalDate endDate) throws SQLException {
        LocalDateTime start = startDate != null ? startDate.atStartOfDay() : null;
        LocalDateTime end = endDate != null ? endDate.atTime(LocalTime.MAX) : null;
        return paymentDAO.searchPaymentDTOs(keyword, status, method, start, end);
    }

    public List<PaymentDTO> getPaymentsByGuest(Long guestId) throws SQLException {
        return paymentDAO.findPaymentDTOsByGuestId(guestId);
    }

    public List<PaymentDTO> getPaymentsByReservationDTO(Long reservationId) throws SQLException {
        return paymentDAO.findPaymentDTOsByReservationId(reservationId);
    }

    public long getTotalPaymentsCount() throws SQLException {
        return paymentDAO.countPayments();
    }

    public List<PaymentDTO> getRecentPayments(int limit) throws SQLException {
        return paymentDAO.findRecentPaymentDTOs(limit);
    }

    private String generatePaymentNumber() {
        return "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}