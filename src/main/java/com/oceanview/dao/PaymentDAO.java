package com.oceanview.dao;

import com.oceanview.model.Payment;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface PaymentDAO extends BaseDAO<Payment, Long> {
    Optional<Payment> findByPaymentNumber(String paymentNumber) throws SQLException;
    List<Payment> findByReservationId(Long reservationId) throws SQLException;
    List<Payment> findByStatus(Payment.PaymentStatus status) throws SQLException;
    List<Payment> findByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException;
    List<Payment> findByMethod(Payment.PaymentMethod method) throws SQLException;
    double getTotalPaymentsByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException;
    boolean updateStatus(Long id, Payment.PaymentStatus status) throws SQLException;
}