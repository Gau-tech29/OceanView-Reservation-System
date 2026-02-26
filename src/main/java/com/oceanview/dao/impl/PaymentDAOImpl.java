package com.oceanview.dao.impl;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.model.Payment;
import com.oceanview.model.Reservation;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class PaymentDAOImpl implements PaymentDAO {

    private static PaymentDAOImpl instance;

    private PaymentDAOImpl() {}

    public static synchronized PaymentDAOImpl getInstance() {
        if (instance == null) {
            instance = new PaymentDAOImpl();
        }
        return instance;
    }

    @Override
    public Payment save(Payment payment) throws SQLException {
        String sql = "INSERT INTO payments (payment_number, reservation_id, amount, payment_method, " +
                "payment_status, transaction_id, card_last_four, notes, payment_date, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, payment.getPaymentNumber());
            ps.setLong(2, payment.getReservationId());
            ps.setBigDecimal(3, payment.getAmount());
            ps.setString(4, payment.getPaymentMethod().name());
            ps.setString(5, payment.getPaymentStatus().name());
            ps.setString(6, payment.getTransactionId());
            ps.setString(7, payment.getCardLastFour());
            ps.setString(8, payment.getNotes());
            ps.setTimestamp(9, Timestamp.valueOf(payment.getPaymentDate()));
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating payment failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    payment.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating payment failed, no ID obtained.");
                }
            }
        }
        return payment;
    }

    @Override
    public Payment update(Payment payment) throws SQLException {
        String sql = "UPDATE payments SET amount = ?, payment_method = ?, payment_status = ?, " +
                "transaction_id = ?, card_last_four = ?, notes = ?, updated_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, payment.getAmount());
            ps.setString(2, payment.getPaymentMethod().name());
            ps.setString(3, payment.getPaymentStatus().name());
            ps.setString(4, payment.getTransactionId());
            ps.setString(5, payment.getCardLastFour());
            ps.setString(6, payment.getNotes());
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(8, payment.getId());

            ps.executeUpdate();
        }
        return payment;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM payments WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Payment> findById(Long id) throws SQLException {
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "WHERE p.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToPayment(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Payment> findByPaymentNumber(String paymentNumber) throws SQLException {
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "WHERE p.payment_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, paymentNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToPayment(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Payment> findAll() throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                payments.add(mapResultSetToPayment(rs));
            }
        }
        return payments;
    }

    @Override
    public List<Payment> findAll(int page, int size) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "ORDER BY p.created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }

    @Override
    public List<Payment> findByReservationId(Long reservationId) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments WHERE reservation_id = ? ORDER BY payment_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, reservationId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }

    @Override
    public List<Payment> findByStatus(Payment.PaymentStatus status) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "WHERE p.payment_status = ? ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }

    @Override
    public List<Payment> findByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "WHERE p.payment_date BETWEEN ? AND ? ORDER BY p.payment_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }

    @Override
    public List<Payment> findByMethod(Payment.PaymentMethod method) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.reservation_number, r.guest_id, r.check_in_date, r.check_out_date " +
                "FROM payments p " +
                "LEFT JOIN reservations r ON p.reservation_id = r.id " +
                "WHERE p.payment_method = ? ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, method.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }

    @Override
    public double getTotalPaymentsByDateRange(LocalDateTime start, LocalDateTime end) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total FROM payments " +
                "WHERE payment_date BETWEEN ? AND ? AND payment_status = 'COMPLETED'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total");
                }
            }
        }
        return 0;
    }

    @Override
    public boolean updateStatus(Long id, Payment.PaymentStatus status) throws SQLException {
        String sql = "UPDATE payments SET payment_status = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);

            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM payments";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0;
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        String sql = "SELECT 1 FROM payments WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setId(rs.getLong("id"));
        payment.setPaymentNumber(rs.getString("payment_number"));
        payment.setReservationId(rs.getLong("reservation_id"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setPaymentMethod(Payment.PaymentMethod.valueOf(rs.getString("payment_method")));
        payment.setPaymentStatus(Payment.PaymentStatus.valueOf(rs.getString("payment_status")));
        payment.setTransactionId(rs.getString("transaction_id"));
        payment.setCardLastFour(rs.getString("card_last_four"));
        payment.setNotes(rs.getString("notes"));

        Timestamp paymentDate = rs.getTimestamp("payment_date");
        if (paymentDate != null) {
            payment.setPaymentDate(paymentDate.toLocalDateTime());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            payment.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            payment.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Set reservation info if available
        try {
            if (rs.getObject("reservation_number") != null) {
                Reservation reservation = new Reservation();
                reservation.setId(payment.getReservationId());
                reservation.setReservationNumber(rs.getString("reservation_number"));
                reservation.setGuestId(rs.getLong("guest_id"));

                Date checkInDate = rs.getDate("check_in_date");
                if (checkInDate != null) {
                    reservation.setCheckInDate(checkInDate.toLocalDate());
                }

                Date checkOutDate = rs.getDate("check_out_date");
                if (checkOutDate != null) {
                    reservation.setCheckOutDate(checkOutDate.toLocalDate());
                }

                payment.setReservation(reservation);
            }
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        return payment;
    }
}