package com.oceanview.service;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.impl.PaymentDAOImpl;
import com.oceanview.model.Payment;
import com.oceanview.util.ValidationUtils;

import java.sql.SQLException;
import java.time.LocalDateTime;
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

        payment.markAsRefunded();
        payment.setNotes((payment.getNotes() != null ? payment.getNotes() + " | " : "") +
                "Refunded: " + reason);

        return paymentDAO.update(payment);
    }

    private String generatePaymentNumber() {
        return "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}