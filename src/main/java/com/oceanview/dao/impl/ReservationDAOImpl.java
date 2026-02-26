package com.oceanview.dao.impl;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.Guest;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ReservationDAOImpl implements ReservationDAO {

    private static ReservationDAOImpl instance;

    private ReservationDAOImpl() {}

    public static synchronized ReservationDAOImpl getInstance() {
        if (instance == null) {
            instance = new ReservationDAOImpl();
        }
        return instance;
    }

    @Override
    public Reservation save(Reservation reservation) throws SQLException {
        String sql = "INSERT INTO reservations (reservation_number, guest_id, user_id, room_id, " +
                "check_in_date, check_out_date, adults, children, room_price, tax_amount, " +
                "discount_amount, subtotal, total_amount, payment_status, reservation_status, " +
                "special_requests, source, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, reservation.getReservationNumber());
            ps.setLong(2, reservation.getGuestId());
            ps.setLong(3, reservation.getUserId());
            ps.setLong(4, reservation.getRoomId());
            ps.setDate(5, Date.valueOf(reservation.getCheckInDate()));
            ps.setDate(6, Date.valueOf(reservation.getCheckOutDate()));
            ps.setInt(7, reservation.getAdults());
            ps.setInt(8, reservation.getChildren());
            ps.setBigDecimal(9, reservation.getRoomPrice());
            ps.setBigDecimal(10, reservation.getTaxAmount());
            ps.setBigDecimal(11, reservation.getDiscountAmount());
            ps.setBigDecimal(12, reservation.getSubtotal());
            ps.setBigDecimal(13, reservation.getTotalAmount());
            ps.setString(14, reservation.getPaymentStatus().name());
            ps.setString(15, reservation.getReservationStatus().name());
            ps.setString(16, reservation.getSpecialRequests());
            ps.setString(17, reservation.getSource().name());
            ps.setTimestamp(18, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(19, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating reservation failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    reservation.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating reservation failed, no ID obtained.");
                }
            }
        }
        return reservation;
    }

    @Override
    public Reservation update(Reservation reservation) throws SQLException {
        String sql = "UPDATE reservations SET check_in_date = ?, check_out_date = ?, adults = ?, " +
                "children = ?, room_price = ?, tax_amount = ?, discount_amount = ?, subtotal = ?, " +
                "total_amount = ?, payment_status = ?, reservation_status = ?, special_requests = ?, " +
                "source = ?, updated_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(reservation.getCheckInDate()));
            ps.setDate(2, Date.valueOf(reservation.getCheckOutDate()));
            ps.setInt(3, reservation.getAdults());
            ps.setInt(4, reservation.getChildren());
            ps.setBigDecimal(5, reservation.getRoomPrice());
            ps.setBigDecimal(6, reservation.getTaxAmount());
            ps.setBigDecimal(7, reservation.getDiscountAmount());
            ps.setBigDecimal(8, reservation.getSubtotal());
            ps.setBigDecimal(9, reservation.getTotalAmount());
            ps.setString(10, reservation.getPaymentStatus().name());
            ps.setString(11, reservation.getReservationStatus().name());
            ps.setString(12, reservation.getSpecialRequests());
            ps.setString(13, reservation.getSource().name());
            ps.setTimestamp(14, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(15, reservation.getId());

            ps.executeUpdate();
        }
        return reservation;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM reservations WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Reservation> findById(Long id) throws SQLException {
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone, " +
                "rm.room_number, rm.room_type, rm.floor_number, " +
                "u.first_name as user_first_name, u.last_name as user_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "LEFT JOIN rooms rm ON r.room_id = rm.id " +
                "LEFT JOIN users u ON r.user_id = u.id " +
                "WHERE r.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToReservation(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Reservation> findByReservationNumber(String reservationNumber) throws SQLException {
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name, " +
                "g.email as guest_email, g.phone as guest_phone, " +
                "rm.room_number, rm.room_type, rm.floor_number " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "LEFT JOIN rooms rm ON r.room_id = rm.id " +
                "WHERE r.reservation_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reservationNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToReservation(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Reservation> findAll() throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findAll(int page, int size) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "ORDER BY r.created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findByGuestId(Long guestId) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.guest_id = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, guestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findByRoomId(Long roomId) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.room_id = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findByDateRange(LocalDate startDate, LocalDate endDate) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE (r.check_in_date BETWEEN ? AND ?) OR (r.check_out_date BETWEEN ? AND ?) " +
                "ORDER BY r.check_in_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            ps.setDate(3, Date.valueOf(startDate));
            ps.setDate(4, Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findByStatus(Reservation.ReservationStatus status) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.reservation_status = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findByPaymentStatus(Reservation.PaymentStatus status) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.payment_status = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findActiveReservations() throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.reservation_status IN ('CONFIRMED', 'CHECKED_IN') " +
                "ORDER BY r.check_in_date ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findCheckInsByDate(LocalDate date) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.check_in_date = ? AND r.reservation_status = 'CONFIRMED'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public List<Reservation> findCheckOutsByDate(LocalDate date) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, g.first_name as guest_first_name, g.last_name as guest_last_name " +
                "FROM reservations r " +
                "LEFT JOIN guests g ON r.guest_id = g.id " +
                "WHERE r.check_out_date = ? AND r.reservation_status IN ('CHECKED_IN', 'CONFIRMED')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }

    @Override
    public int countOccupiedRoomsByDate(LocalDate date) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT room_id) FROM reservations " +
                "WHERE ? BETWEEN check_in_date AND DATE_SUB(check_out_date, INTERVAL 1 DAY) " +
                "AND reservation_status IN ('CONFIRMED', 'CHECKED_IN')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    @Override
    public boolean updateStatus(Long id, Reservation.ReservationStatus status) throws SQLException {
        String sql = "UPDATE reservations SET reservation_status = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name());
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);

            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updatePaymentStatus(Long id, Reservation.PaymentStatus status) throws SQLException {
        String sql = "UPDATE reservations SET payment_status = ?, updated_at = ? WHERE id = ?";
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
        String sql = "SELECT COUNT(*) FROM reservations";
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
        String sql = "SELECT 1 FROM reservations WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setId(rs.getLong("id"));
        reservation.setReservationNumber(rs.getString("reservation_number"));
        reservation.setGuestId(rs.getLong("guest_id"));
        reservation.setUserId(rs.getLong("user_id"));
        reservation.setRoomId(rs.getLong("room_id"));
        reservation.setCheckInDate(rs.getDate("check_in_date").toLocalDate());
        reservation.setCheckOutDate(rs.getDate("check_out_date").toLocalDate());
        reservation.setAdults(rs.getInt("adults"));
        reservation.setChildren(rs.getInt("children"));
        reservation.setRoomPrice(rs.getBigDecimal("room_price"));
        reservation.setTaxAmount(rs.getBigDecimal("tax_amount"));
        reservation.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        reservation.setSubtotal(rs.getBigDecimal("subtotal"));
        reservation.setTotalAmount(rs.getBigDecimal("total_amount"));
        reservation.setPaymentStatus(Reservation.PaymentStatus.valueOf(rs.getString("payment_status")));
        reservation.setReservationStatus(Reservation.ReservationStatus.valueOf(rs.getString("reservation_status")));
        reservation.setSpecialRequests(rs.getString("special_requests"));
        reservation.setSource(Reservation.ReservationSource.valueOf(rs.getString("source")));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            reservation.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            reservation.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Set guest info
        try {
            Guest guest = new Guest();
            guest.setId(reservation.getGuestId());
            guest.setFirstName(rs.getString("guest_first_name"));
            guest.setLastName(rs.getString("guest_last_name"));
            guest.setEmail(rs.getString("guest_email"));
            guest.setPhone(rs.getString("guest_phone"));
            reservation.setGuest(guest);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        // Set room info
        try {
            Room room = new Room();
            room.setId(reservation.getRoomId());
            room.setRoomNumber(rs.getString("room_number"));
            room.setRoomType(Room.RoomType.valueOf(rs.getString("room_type")));
            room.setFloorNumber(rs.getInt("floor_number"));
            reservation.setRoom(room);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        // Set user info
        try {
            User user = new User();
            user.setId(reservation.getUserId());
            user.setFirstName(rs.getString("user_first_name"));
            user.setLastName(rs.getString("user_last_name"));
            reservation.setUser(user);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }

        return reservation;
    }
}