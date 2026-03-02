package com.oceanview.dao.impl;

import com.oceanview.dao.BillDAO;
import com.oceanview.model.Bill;
import com.oceanview.model.Guest;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class BillDAOImpl implements BillDAO {

    private static BillDAOImpl instance;

    private BillDAOImpl() {}

    public static synchronized BillDAOImpl getInstance() {
        if (instance == null) {
            instance = new BillDAOImpl();
        }
        return instance;
    }

    // ─── Helper: convert BillStatus enum → DB string ─────────────────────────────
    private String statusToDb(Bill.BillStatus status) {
        if (status == null) return "DRAFT";
        switch (status) {
            case DRAFT:         return "DRAFT";
            case ISSUED:        return "ISSUED";
            case PAID:          return "PAID";
            case PARTIALLY_PAID:return "PARTIALLY PAID";
            default:            return "DRAFT";
        }
    }

    // ─── Helper: convert DB string → BillStatus enum ─────────────────────────────
    private Bill.BillStatus dbToStatus(String dbStatus) {
        if (dbStatus == null) return Bill.BillStatus.DRAFT;
        switch (dbStatus) {
            case "DRAFT":         return Bill.BillStatus.DRAFT;
            case "ISSUED":        return Bill.BillStatus.ISSUED;
            case "PAID":          return Bill.BillStatus.PAID;
            case "PARTIALLY PAID":return Bill.BillStatus.PARTIALLY_PAID;
            default:              return Bill.BillStatus.DRAFT;
        }
    }

    @Override
    public Bill save(Bill bill) throws SQLException {
        // balance_due is STORED GENERATED — excluded from INSERT
        String sql = "INSERT INTO bills (" +
                "bill_number, reservation_id, guest_id, user_id, issue_date, due_date, " +
                "check_in_date, check_out_date, room_charges, additional_charges, tax_amount, " +
                "discount_amount, total_amount, paid_amount, bill_status, " +
                "payment_method, payment_date, notes, printed_count, created_at, updated_at" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, bill.getBillNumber());
            ps.setLong(2, bill.getReservationId());
            ps.setLong(3, bill.getGuestId());
            ps.setLong(4, bill.getUserId());
            ps.setDate(5, Date.valueOf(bill.getIssueDate()));
            ps.setDate(6, bill.getDueDate() != null ? Date.valueOf(bill.getDueDate()) : null);
            ps.setDate(7, Date.valueOf(bill.getCheckInDate()));
            ps.setDate(8, Date.valueOf(bill.getCheckOutDate()));
            ps.setBigDecimal(9, bill.getRoomCharges());
            ps.setBigDecimal(10, bill.getAdditionalCharges() != null
                    ? bill.getAdditionalCharges() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(11, bill.getTaxAmount());
            ps.setBigDecimal(12, bill.getDiscountAmount() != null
                    ? bill.getDiscountAmount() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(13, bill.getTotalAmount());
            ps.setBigDecimal(14, bill.getPaidAmount() != null
                    ? bill.getPaidAmount() : java.math.BigDecimal.ZERO);
            ps.setString(15, statusToDb(bill.getBillStatus()));
            ps.setString(16, bill.getPaymentMethod() != null ? bill.getPaymentMethod().name() : null);
            ps.setTimestamp(17, bill.getPaymentDate() != null
                    ? Timestamp.valueOf(bill.getPaymentDate()) : null);
            ps.setString(18, bill.getNotes());
            ps.setInt(19, bill.getPrintedCount() != null ? bill.getPrintedCount() : 0);
            ps.setTimestamp(20, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(21, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating bill failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    bill.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating bill failed, no ID obtained.");
                }
            }
        }
        return bill;
    }

    @Override
    public Bill update(Bill bill) throws SQLException {
        // balance_due is STORED GENERATED — excluded from UPDATE
        String sql = "UPDATE bills SET " +
                "room_charges = ?, additional_charges = ?, tax_amount = ?, " +
                "discount_amount = ?, total_amount = ?, paid_amount = ?, " +
                "bill_status = ?, payment_method = ?, payment_date = ?, notes = ?, " +
                "printed_count = ?, updated_at = ? " +
                "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, bill.getRoomCharges());
            ps.setBigDecimal(2, bill.getAdditionalCharges() != null
                    ? bill.getAdditionalCharges() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(3, bill.getTaxAmount());
            ps.setBigDecimal(4, bill.getDiscountAmount() != null
                    ? bill.getDiscountAmount() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(5, bill.getTotalAmount());
            ps.setBigDecimal(6, bill.getPaidAmount() != null
                    ? bill.getPaidAmount() : java.math.BigDecimal.ZERO);
            ps.setString(7, statusToDb(bill.getBillStatus()));
            ps.setString(8, bill.getPaymentMethod() != null ? bill.getPaymentMethod().name() : null);
            ps.setTimestamp(9, bill.getPaymentDate() != null
                    ? Timestamp.valueOf(bill.getPaymentDate()) : null);
            ps.setString(10, bill.getNotes());
            ps.setInt(11, bill.getPrintedCount() != null ? bill.getPrintedCount() : 0);
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(13, bill.getId());

            ps.executeUpdate();
        }
        return bill;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM bills WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Bill> findById(Long id) throws SQLException {
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone, " +
                "u.first_name as user_first_name, u.last_name as user_last_name, " +
                "r.reservation_number, r.check_in_date as res_check_in, r.check_out_date as res_check_out " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "LEFT JOIN users u ON b.user_id = u.id " +
                "LEFT JOIN reservations r ON b.reservation_id = r.id " +
                "WHERE b.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToBill(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Bill> findByBillNumber(String billNumber) throws SQLException {
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone, " +
                "u.first_name as user_first_name, u.last_name as user_last_name, " +
                "r.reservation_number, r.check_in_date as res_check_in, r.check_out_date as res_check_out " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "LEFT JOIN users u ON b.user_id = u.id " +
                "LEFT JOIN reservations r ON b.reservation_id = r.id " +
                "WHERE b.bill_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, billNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToBill(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Bill> findAll() throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "ORDER BY b.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                bills.add(mapResultSetToBill(rs));
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findAll(int page, int size) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "ORDER BY b.issue_date DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findByReservationId(Long reservationId) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "WHERE b.reservation_id = ? " +
                "ORDER BY b.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findByGuestId(Long guestId) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "WHERE b.guest_id = ? " +
                "ORDER BY b.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, guestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findByStatus(Bill.BillStatus status) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "WHERE b.bill_status = ? " +
                "ORDER BY b.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusToDb(status));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findByDateRange(LocalDate start, LocalDate end) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "WHERE b.issue_date BETWEEN ? AND ? " +
                "ORDER BY b.issue_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        }
        return bills;
    }

    @Override
    public List<Bill> findOverdueBills() throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String sql = "SELECT b.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone " +
                "FROM bills b " +
                "LEFT JOIN guests g ON b.guest_id = g.id " +
                "WHERE b.bill_status IN ('ISSUED', 'PARTIALLY PAID') " +
                "AND b.due_date < CURRENT_DATE " +
                "ORDER BY b.due_date ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                bills.add(mapResultSetToBill(rs));
            }
        }
        return bills;
    }

    @Override
    public double getTotalRevenueByDateRange(LocalDate start, LocalDate end) throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) as total FROM bills " +
                "WHERE issue_date BETWEEN ? AND ? AND bill_status = 'PAID'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("total");
            }
        }
        return 0.0;
    }

    @Override
    public boolean updateStatus(Long id, Bill.BillStatus status) throws SQLException {
        String sql = "UPDATE bills SET bill_status = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusToDb(status));
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public void incrementPrintedCount(Long id) throws SQLException {
        String sql = "UPDATE bills SET printed_count = printed_count + 1, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    @Override
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM bills";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0;
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        String sql = "SELECT 1 FROM bills WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ─── ResultSet → Bill ─────────────────────────────────────────────────────────

    private Bill mapResultSetToBill(ResultSet rs) throws SQLException {
        Bill bill = new Bill();
        bill.setId(rs.getLong("id"));
        bill.setBillNumber(rs.getString("bill_number"));
        bill.setReservationId(rs.getLong("reservation_id"));
        bill.setGuestId(rs.getLong("guest_id"));
        bill.setUserId(rs.getLong("user_id"));
        bill.setIssueDate(rs.getDate("issue_date").toLocalDate());

        Date dueDate = rs.getDate("due_date");
        if (dueDate != null) bill.setDueDate(dueDate.toLocalDate());

        bill.setCheckInDate(rs.getDate("check_in_date").toLocalDate());
        bill.setCheckOutDate(rs.getDate("check_out_date").toLocalDate());
        bill.setRoomCharges(rs.getBigDecimal("room_charges"));
        bill.setAdditionalCharges(rs.getBigDecimal("additional_charges"));
        bill.setTaxAmount(rs.getBigDecimal("tax_amount"));
        bill.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        bill.setTotalAmount(rs.getBigDecimal("total_amount"));
        bill.setPaidAmount(rs.getBigDecimal("paid_amount"));

        // balance_due is a STORED GENERATED column — read only, never written
        bill.setBalanceDue(rs.getBigDecimal("balance_due"));

        bill.setBillStatus(dbToStatus(rs.getString("bill_status")));

        String paymentMethod = rs.getString("payment_method");
        if (paymentMethod != null) {
            try {
                bill.setPaymentMethod(Bill.PaymentMethod.valueOf(paymentMethod));
            } catch (IllegalArgumentException ignored) {}
        }

        Timestamp paymentDate = rs.getTimestamp("payment_date");
        if (paymentDate != null) bill.setPaymentDate(paymentDate.toLocalDateTime());

        bill.setNotes(rs.getString("notes"));
        bill.setPrintedCount(rs.getInt("printed_count"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) bill.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) bill.setUpdatedAt(updatedAt.toLocalDateTime());

        // Set guest info (ignore if columns not in result set)
        try {
            Guest guest = new Guest();
            guest.setId(bill.getGuestId());
            guest.setFirstName(rs.getString("guest_first_name"));
            guest.setLastName(rs.getString("guest_last_name"));
            guest.setEmail(rs.getString("guest_email"));
            guest.setPhone(rs.getString("guest_phone"));
            bill.setGuest(guest);
        } catch (SQLException ignored) {}

        // Set user info
        try {
            User user = new User();
            user.setId(bill.getUserId());
            user.setFirstName(rs.getString("user_first_name"));
            user.setLastName(rs.getString("user_last_name"));
            bill.setUser(user);
        } catch (SQLException ignored) {}

        // Set reservation info
        try {
            Reservation reservation = new Reservation();
            reservation.setId(bill.getReservationId());
            reservation.setReservationNumber(rs.getString("reservation_number"));
            try {
                Date resCheckIn = rs.getDate("res_check_in");
                if (resCheckIn != null) reservation.setCheckInDate(resCheckIn.toLocalDate());
            } catch (SQLException ignored) {
                reservation.setCheckInDate(bill.getCheckInDate());
            }
            try {
                Date resCheckOut = rs.getDate("res_check_out");
                if (resCheckOut != null) reservation.setCheckOutDate(resCheckOut.toLocalDate());
            } catch (SQLException ignored) {
                reservation.setCheckOutDate(bill.getCheckOutDate());
            }
            bill.setReservation(reservation);
        } catch (SQLException ignored) {}

        return bill;
    }
}