package com.oceanview.dao.impl;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.Reservation;
import com.oceanview.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class ReservationDAOImpl implements ReservationDAO {

    private static ReservationDAOImpl instance;

    private ReservationDAOImpl() {}

    public static synchronized ReservationDAOImpl getInstance() {
        if (instance == null) instance = new ReservationDAOImpl();
        return instance;
    }

    // ─── Base SQL fragments ─────────────────────────────────────────

    /** SELECT with JOINs to guest + room tables so DTOs are fully populated */
    private static final String SELECT_DTO =
            "SELECT r.*, " +
                    "  CONCAT(g.first_name, ' ', g.last_name) AS guest_name, " +
                    "  g.email AS guest_email, g.phone AS guest_phone, " +
                    "  g.guest_number AS guest_number_col, " +
                    "  rm.room_number, rm.room_type, rm.room_view, rm.floor_number, rm.base_price, rm.tax_rate " +
                    "FROM reservations r " +
                    "LEFT JOIN guests g ON r.guest_id = g.id " +
                    "LEFT JOIN rooms rm ON r.room_id = rm.id ";

    // ─── Save ───────────────────────────────────────────────────────

    @Override
    public Reservation save(Reservation r) throws SQLException {
        String sql =
                "INSERT INTO reservations (reservation_number, guest_id, user_id, room_id, " +
                        "  check_in_date, check_out_date, adults, children, total_nights, " +
                        "  room_price, tax_amount, discount_amount, subtotal, total_amount, " +
                        "  payment_status, reservation_status, special_requests, source, " +
                        "  created_at, updated_at) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            // Generate reservation number if not provided
            String reservationNumber = r.getReservationNumber() != null
                    ? r.getReservationNumber() : generateReservationNumber();
            r.setReservationNumber(reservationNumber);

            ps.setString(1, reservationNumber);

            // Guest ID (required)
            ps.setLong(2, r.getGuestId());

            // User ID (optional)
            if (r.getUserId() != null) {
                ps.setLong(3, r.getUserId());
            } else {
                ps.setNull(3, Types.BIGINT);
            }

            // Room ID
            ps.setLong(4, r.getRoomId());

            // Dates
            ps.setDate(5, Date.valueOf(r.getCheckInDate()));
            ps.setDate(6, Date.valueOf(r.getCheckOutDate()));

            // Guest counts
            ps.setInt(7, r.getAdults() != null ? r.getAdults() : 1);
            ps.setInt(8, r.getChildren() != null ? r.getChildren() : 0);

            // Nights
            ps.setInt(9, r.getTotalNights() != null ? r.getTotalNights() : 0);

            // Pricing
            ps.setBigDecimal(10, r.getRoomPrice() != null ? r.getRoomPrice() : BigDecimal.ZERO);
            ps.setBigDecimal(11, r.getTaxAmount() != null ? r.getTaxAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(12, r.getDiscountAmount() != null ? r.getDiscountAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(13, r.getSubtotal() != null ? r.getSubtotal() : BigDecimal.ZERO);
            ps.setBigDecimal(14, r.getTotalAmount() != null ? r.getTotalAmount() : BigDecimal.ZERO);

            // Status
            ps.setString(15, r.getPaymentStatus() != null ? r.getPaymentStatus().name() : "PENDING");
            ps.setString(16, r.getReservationStatus() != null ? r.getReservationStatus().name() : "CONFIRMED");

            // Other
            ps.setString(17, r.getSpecialRequests());
            ps.setString(18, r.getSource() != null ? r.getSource().name() : "WALK_IN");

            // Timestamps
            LocalDateTime now = LocalDateTime.now();
            ps.setTimestamp(19, Timestamp.valueOf(now));
            ps.setTimestamp(20, Timestamp.valueOf(now));

            int affectedRows = ps.executeUpdate();
            System.out.println("Reservation insert affected rows: " + affectedRows); // Debug log

            if (affectedRows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        r.setId(keys.getLong(1));
                        System.out.println("Generated reservation ID: " + r.getId()); // Debug log
                    }
                }
            }
        }
        return r;
    }

    // ─── Update ─────────────────────────────────────────────────────

    @Override
    public Reservation update(Reservation r) throws SQLException {
        String sql =
                "UPDATE reservations SET room_id=?, check_in_date=?, check_out_date=?, " +
                        "  adults=?, children=?, total_nights=?, room_price=?, tax_amount=?, " +
                        "  discount_amount=?, subtotal=?, total_amount=?, payment_status=?, " +
                        "  reservation_status=?, special_requests=?, source=?, updated_at=? " +
                        "WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, r.getRoomId());
            ps.setDate(2, Date.valueOf(r.getCheckInDate()));
            ps.setDate(3, Date.valueOf(r.getCheckOutDate()));
            ps.setInt(4, r.getAdults() != null ? r.getAdults() : 1);
            ps.setInt(5, r.getChildren() != null ? r.getChildren() : 0);
            ps.setInt(6, r.getTotalNights() != null ? r.getTotalNights() : 0);
            ps.setBigDecimal(7, r.getRoomPrice() != null ? r.getRoomPrice() : BigDecimal.ZERO);
            ps.setBigDecimal(8, r.getTaxAmount() != null ? r.getTaxAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(9, r.getDiscountAmount() != null ? r.getDiscountAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(10, r.getSubtotal() != null ? r.getSubtotal() : BigDecimal.ZERO);
            ps.setBigDecimal(11, r.getTotalAmount() != null ? r.getTotalAmount() : BigDecimal.ZERO);
            ps.setString(12, r.getPaymentStatus() != null ? r.getPaymentStatus().name() : "PENDING");
            ps.setString(13, r.getReservationStatus() != null ? r.getReservationStatus().name() : "CONFIRMED");
            ps.setString(14, r.getSpecialRequests());
            ps.setString(15, r.getSource() != null ? r.getSource().name() : "WALK_IN");
            ps.setTimestamp(16, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(17, r.getId());

            int affectedRows = ps.executeUpdate();
            System.out.println("Reservation update affected rows: " + affectedRows); // Debug log
        }
        return r;
    }

    // ─── Delete ─────────────────────────────────────────────────────

    @Override
    public boolean delete(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM reservations WHERE id=?")) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── Single lookups ─────────────────────────────────────────────

    @Override
    public Optional<Reservation> findById(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM reservations WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(mapEntity(rs)) : Optional.empty();
            }
        }
    }

    @Override
    public Optional<ReservationDTO> findDTOById(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_DTO + "WHERE r.id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(mapDTO(rs)) : Optional.empty();
            }
        }
    }

    @Override
    public Optional<ReservationDTO> findDTOByNumber(String number) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     SELECT_DTO + "WHERE r.reservation_number=?")) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(mapDTO(rs)) : Optional.empty();
            }
        }
    }

    // ─── List queries ───────────────────────────────────────────────

    @Override
    public List<ReservationDTO> findAllDTOs(int page, int size) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO + "ORDER BY r.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    @Override
    public List<ReservationDTO> findRecentDTOs(int limit) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO + "ORDER BY r.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    @Override
    public List<ReservationDTO> findByGuestId(Long guestId) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     SELECT_DTO + "WHERE r.guest_id=? ORDER BY r.check_in_date DESC")) {
            ps.setLong(1, guestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    @Override
    public List<ReservationDTO> findByRoomId(Long roomId) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     SELECT_DTO + "WHERE r.room_id=? ORDER BY r.check_in_date DESC")) {
            ps.setLong(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    @Override
    public List<ReservationDTO> findByDateRange(LocalDate start, LocalDate end) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO +
                "WHERE r.check_in_date >= ? AND r.check_out_date <= ? " +
                "ORDER BY r.check_in_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    @Override
    public List<ReservationDTO> searchDTOs(String keyword, String status,
                                           String paymentStatus,
                                           LocalDate checkInDate,
                                           LocalDate checkOutDate) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_DTO + "WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (r.reservation_number LIKE ? " +
                    "OR g.first_name LIKE ? OR g.last_name LIKE ? " +
                    "OR g.email LIKE ? OR g.phone LIKE ? OR rm.room_number LIKE ?) ");
        }
        if (status != null && !status.isEmpty())         sql.append("AND r.reservation_status=? ");
        if (paymentStatus != null && !paymentStatus.isEmpty()) sql.append("AND r.payment_status=? ");
        if (checkInDate != null)  sql.append("AND r.check_in_date >= ? ");
        if (checkOutDate != null) sql.append("AND r.check_out_date <= ? ");
        sql.append("ORDER BY r.created_at DESC LIMIT 100");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
            }
            if (status != null && !status.isEmpty())           ps.setString(idx++, status);
            if (paymentStatus != null && !paymentStatus.isEmpty()) ps.setString(idx++, paymentStatus);
            if (checkInDate != null)  ps.setDate(idx++, Date.valueOf(checkInDate));
            if (checkOutDate != null) ps.setDate(idx++, Date.valueOf(checkOutDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        return list;
    }

    // ─── Status lists ────────────────────────────────────────────────

    @Override
    public List<Reservation> findActiveReservations() throws SQLException {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE reservation_status IN " +
                "('CONFIRMED','CHECKED_IN') ORDER BY check_in_date";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapEntity(rs));
        }
        return list;
    }

    @Override
    public List<Reservation> findCheckInsByDate(LocalDate date) throws SQLException {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM reservations WHERE check_in_date=? " +
                             "AND reservation_status IN ('CONFIRMED','CHECKED_IN')")) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapEntity(rs));
            }
        }
        return list;
    }

    @Override
    public List<Reservation> findCheckOutsByDate(LocalDate date) throws SQLException {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM reservations WHERE check_out_date=? " +
                             "AND reservation_status='CHECKED_IN'")) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapEntity(rs));
            }
        }
        return list;
    }

    // ─── Aggregates ─────────────────────────────────────────────────

    @Override
    public int countOccupiedRoomsByDate(LocalDate date) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT room_id) FROM reservations " +
                "WHERE check_in_date <= ? AND check_out_date > ? " +
                "AND reservation_status='CHECKED_IN'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public int countCheckInsByDate(LocalDate date) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT COUNT(*) FROM reservations WHERE check_in_date=? " +
                             "AND reservation_status IN ('CONFIRMED','CHECKED_IN')")) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public int countCheckOutsByDate(LocalDate date) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT COUNT(*) FROM reservations WHERE check_out_date=? " +
                             "AND reservation_status='CHECKED_IN'")) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public double getTotalRevenueByMonth(int year, int month) throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount),0) FROM reservations " +
                "WHERE YEAR(check_in_date)=? AND MONTH(check_in_date)=? " +
                "AND reservation_status NOT IN ('CANCELLED','NO_SHOW')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        }
    }

    // ─── BaseDAO methods ────────────────────────────────────────────

    @Override
    public List<Reservation> findAll() throws SQLException {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM reservations ORDER BY created_at DESC")) {
            while (rs.next()) list.add(mapEntity(rs));
        }
        return list;
    }

    @Override
    public List<Reservation> findAll(int page, int size) throws SQLException {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM reservations ORDER BY created_at DESC LIMIT ? OFFSET ?")) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapEntity(rs));
            }
        }
        return list;
    }

    @Override
    public long count() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM reservations")) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM reservations WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // ─── Mappers ────────────────────────────────────────────────────

    private Reservation mapEntity(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getLong("id"));
        r.setReservationNumber(rs.getString("reservation_number"));
        r.setGuestId(rs.getLong("guest_id"));
        r.setUserId(rs.getObject("user_id") != null ? rs.getLong("user_id") : null);
        r.setRoomId(rs.getLong("room_id"));

        Date ci = rs.getDate("check_in_date");
        Date co = rs.getDate("check_out_date");
        if (ci != null) r.setCheckInDate(ci.toLocalDate());
        if (co != null) r.setCheckOutDate(co.toLocalDate());

        r.setAdults(rs.getInt("adults"));
        r.setChildren(rs.getInt("children"));
        r.setTotalNights(rs.getInt("total_nights"));
        r.setRoomPrice(rs.getBigDecimal("room_price"));
        r.setTaxAmount(rs.getBigDecimal("tax_amount"));
        r.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        r.setSubtotal(rs.getBigDecimal("subtotal"));
        r.setTotalAmount(rs.getBigDecimal("total_amount"));
        r.setSpecialRequests(rs.getString("special_requests"));

        String src = rs.getString("source");
        if (src != null) try { r.setSource(Reservation.ReservationSource.valueOf(src)); } catch (Exception ignored) {}

        String ps2 = rs.getString("payment_status");
        if (ps2 != null) try { r.setPaymentStatus(Reservation.PaymentStatus.valueOf(ps2)); } catch (Exception ignored) {}

        String rs2 = rs.getString("reservation_status");
        if (rs2 != null) try { r.setReservationStatus(Reservation.ReservationStatus.valueOf(rs2)); } catch (Exception ignored) {}

        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (createdAt != null) r.setCreatedAt(createdAt.toLocalDateTime());
        if (updatedAt != null) r.setUpdatedAt(updatedAt.toLocalDateTime());

        return r;
    }

    private ReservationDTO mapDTO(ResultSet rs) throws SQLException {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(rs.getLong("id"));
        dto.setReservationNumber(rs.getString("reservation_number"));
        dto.setGuestId(rs.getLong("guest_id"));
        dto.setUserId(rs.getObject("user_id") != null ? rs.getLong("user_id") : null);
        dto.setRoomId(rs.getLong("room_id"));

        // ── Guest joined fields ──
        dto.setGuestName(rs.getString("guest_name"));
        dto.setGuestEmail(rs.getString("guest_email"));
        dto.setGuestPhone(rs.getString("guest_phone"));
        dto.setGuestNumber(rs.getString("guest_number_col"));

        // ── Room joined fields ──
        dto.setRoomNumber(rs.getString("room_number"));
        dto.setRoomType(rs.getString("room_type"));
        dto.setRoomView(rs.getString("room_view"));

        // Use room_price from reservation if available, otherwise base_price from room
        BigDecimal roomPrice = rs.getBigDecimal("room_price");
        if (roomPrice == null || roomPrice.compareTo(BigDecimal.ZERO) == 0) {
            roomPrice = rs.getBigDecimal("base_price");
        }
        dto.setRoomPrice(roomPrice);

        Integer fn = rs.getObject("floor_number") != null ? rs.getInt("floor_number") : null;
        dto.setFloorNumber(fn);

        // ── Stay details ──
        Date ci = rs.getDate("check_in_date");
        Date co = rs.getDate("check_out_date");
        if (ci != null) dto.setCheckInDate(ci.toLocalDate());
        if (co != null) dto.setCheckOutDate(co.toLocalDate());
        dto.setTotalNights(rs.getInt("total_nights"));
        dto.setAdults(rs.getInt("adults"));
        dto.setChildren(rs.getInt("children"));

        // ── Pricing ──
        dto.setTaxAmount(rs.getBigDecimal("tax_amount"));
        dto.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        dto.setSubtotal(rs.getBigDecimal("subtotal"));
        dto.setTotalAmount(rs.getBigDecimal("total_amount"));

        // ── Status ──
        dto.setPaymentStatus(rs.getString("payment_status"));
        dto.setReservationStatus(rs.getString("reservation_status"));
        dto.setSpecialRequests(rs.getString("special_requests"));
        dto.setSource(rs.getString("source"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (createdAt != null) dto.setCreatedAt(createdAt.toLocalDateTime());
        if (updatedAt != null) dto.setUpdatedAt(updatedAt.toLocalDateTime());

        return dto;
    }

    private String generateReservationNumber() {
        return "RES-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}