package com.oceanview.dao.impl;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.ReservationRoomDTO;
import com.oceanview.model.Reservation;
import com.oceanview.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;


public class ReservationDAOImpl implements ReservationDAO {

    private static ReservationDAOImpl instance;

    private ReservationDAOImpl() {}

    public static synchronized ReservationDAOImpl getInstance() {
        if (instance == null) instance = new ReservationDAOImpl();
        return instance;
    }

    private static final String SELECT_DTO =
            "SELECT r.*, " +
                    "  CONCAT(g.first_name, ' ', g.last_name) AS guest_name, " +
                    "  g.email          AS guest_email, " +
                    "  g.phone          AS guest_phone, " +
                    "  g.guest_number   AS guest_number_col " +
                    "FROM reservations r " +
                    "LEFT JOIN guests g ON r.guest_id = g.id ";

    @Override
    public Reservation save(Reservation r) throws SQLException {
        String sql =
                "INSERT INTO reservations " +
                        "  (reservation_number, guest_id, user_id, " +
                        "   check_in_date, check_out_date, adults, children, total_nights, " +
                        "   number_of_rooms, " +
                        "   room_price, tax_amount, discount_amount, subtotal, total_amount, " +
                        "   payment_status, reservation_status, special_requests, source, " +
                        "   created_at, updated_at) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            String resNum = r.getReservationNumber() != null
                    ? r.getReservationNumber() : generateReservationNumber();
            r.setReservationNumber(resNum);

            ps.setString(1, resNum);
            ps.setLong(2, r.getGuestId());

            if (r.getUserId() != null) ps.setLong(3, r.getUserId());
            else                       ps.setNull(3, Types.BIGINT);

            ps.setDate(4, java.sql.Date.valueOf(r.getCheckInDate()));
            ps.setDate(5, java.sql.Date.valueOf(r.getCheckOutDate()));
            ps.setInt(6,  r.getAdults()      != null ? r.getAdults()      : 1);
            ps.setInt(7,  r.getChildren()    != null ? r.getChildren()    : 0);
            ps.setInt(8,  r.getTotalNights() != null ? r.getTotalNights() : 0);
            ps.setInt(9,  r.getNumberOfRooms());                          // <-- number_of_rooms
            ps.setBigDecimal(10, orZero(r.getRoomPrice()));
            ps.setBigDecimal(11, orZero(r.getTaxAmount()));
            ps.setBigDecimal(12, orZero(r.getDiscountAmount()));
            ps.setBigDecimal(13, orZero(r.getSubtotal()));
            ps.setBigDecimal(14, orZero(r.getTotalAmount()));
            ps.setString(15, r.getPaymentStatus()     != null ? r.getPaymentStatus().name()     : "PENDING");
            ps.setString(16, r.getReservationStatus() != null ? r.getReservationStatus().name() : "CONFIRMED");
            ps.setString(17, r.getSpecialRequests());
            ps.setString(18, r.getSource() != null ? r.getSource().name() : "WALK_IN");

            LocalDateTime now = LocalDateTime.now();
            ps.setTimestamp(19, Timestamp.valueOf(now));
            ps.setTimestamp(20, Timestamp.valueOf(now));

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) r.setId(keys.getLong(1));
            }
        }
        return r;
    }

    // ─── Update ───────────────────────────────────────────────────────────────────

    @Override
    public Reservation update(Reservation r) throws SQLException {
        String sql =
                "UPDATE reservations SET " +
                        "  check_in_date=?, check_out_date=?, " +
                        "  adults=?, children=?, total_nights=?, " +
                        "  number_of_rooms=?, " +
                        "  room_price=?, tax_amount=?, discount_amount=?, subtotal=?, total_amount=?, " +
                        "  payment_status=?, reservation_status=?, special_requests=?, source=?, " +
                        "  updated_at=? " +
                        "WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(r.getCheckInDate()));
            ps.setDate(2, java.sql.Date.valueOf(r.getCheckOutDate()));
            ps.setInt(3,  r.getAdults()      != null ? r.getAdults()      : 1);
            ps.setInt(4,  r.getChildren()    != null ? r.getChildren()    : 0);
            ps.setInt(5,  r.getTotalNights() != null ? r.getTotalNights() : 0);
            ps.setInt(6,  r.getNumberOfRooms());                          // <-- number_of_rooms
            ps.setBigDecimal(7,  orZero(r.getRoomPrice()));
            ps.setBigDecimal(8,  orZero(r.getTaxAmount()));
            ps.setBigDecimal(9,  orZero(r.getDiscountAmount()));
            ps.setBigDecimal(10, orZero(r.getSubtotal()));
            ps.setBigDecimal(11, orZero(r.getTotalAmount()));
            ps.setString(12, r.getPaymentStatus()     != null ? r.getPaymentStatus().name()     : "PENDING");
            ps.setString(13, r.getReservationStatus() != null ? r.getReservationStatus().name() : "CONFIRMED");
            ps.setString(14, r.getSpecialRequests());
            ps.setString(15, r.getSource() != null ? r.getSource().name() : "WALK_IN");
            ps.setTimestamp(16, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(17, r.getId());

            ps.executeUpdate();
        }
        return r;
    }

    // ─── Delete ───────────────────────────────────────────────────────────────────

    @Override
    public boolean delete(Long id) throws SQLException {
        // reservation_rooms rows are CASCADE-deleted automatically by FK
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM reservations WHERE id=?")) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── Single lookups ───────────────────────────────────────────────────────────

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
                if (rs.next()) {
                    ReservationDTO dto = mapDTO(rs);
                    // Load ALL rooms for this reservation
                    dto.setRooms(findReservationRooms(id));
                    return Optional.of(dto);
                }
                return Optional.empty();
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
                if (rs.next()) {
                    ReservationDTO dto = mapDTO(rs);
                    dto.setRooms(findReservationRooms(dto.getId()));
                    return Optional.of(dto);
                }
                return Optional.empty();
            }
        }
    }

    // ─── List queries ─────────────────────────────────────────────────────────────

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
        enrichWithRooms(list);
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
        enrichWithRooms(list);
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
        enrichWithRooms(list);
        return list;
    }

    @Override
    public List<ReservationDTO> findByRoomId(Long roomId) throws SQLException {
        // Search via reservation_rooms since reservations has no room_id column
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO +
                "WHERE r.id IN (" +
                "  SELECT reservation_id FROM reservation_rooms WHERE room_id=?" +
                ") ORDER BY r.check_in_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        enrichWithRooms(list);
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
            ps.setDate(1, java.sql.Date.valueOf(start));
            ps.setDate(2, java.sql.Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDTO(rs));
            }
        }
        enrichWithRooms(list);
        return list;
    }

    @Override
    public List<ReservationDTO> searchDTOs(String keyword, String status,
                                           String paymentStatus,
                                           LocalDate checkInDate,
                                           LocalDate checkOutDate) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT r.*, " +
                        "  CONCAT(g.first_name, ' ', g.last_name) AS guest_name, " +
                        "  g.email AS guest_email, g.phone AS guest_phone, " +
                        "  g.guest_number AS guest_number_col " +
                        "FROM reservations r " +
                        "LEFT JOIN guests g ON r.guest_id = g.id " +
                        "LEFT JOIN reservation_rooms rr ON r.id = rr.reservation_id " +
                        "LEFT JOIN rooms rm ON rr.room_id = rm.id " +
                        "WHERE 1=1 ");

        // Add search conditions if keyword is provided
        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchPattern = "%" + keyword.trim() + "%";
            sql.append("AND (r.reservation_number LIKE ? ");
            sql.append("OR g.first_name LIKE ? ");
            sql.append("OR g.last_name LIKE ? ");
            sql.append("OR CONCAT(g.first_name, ' ', g.last_name) LIKE ? ");
            sql.append("OR g.email LIKE ? ");
            sql.append("OR g.phone LIKE ? ");
            sql.append("OR rm.room_number LIKE ?) ");

            // Add 7 parameters for the 7 conditions
            for (int i = 0; i < 7; i++) {
                params.add(searchPattern);
            }
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND r.reservation_status = ? ");
            params.add(status);
        }

        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql.append("AND r.payment_status = ? ");
            params.add(paymentStatus);
        }

        if (checkInDate != null) {
            sql.append("AND r.check_in_date >= ? ");
            params.add(checkInDate);
        }

        if (checkOutDate != null) {
            sql.append("AND r.check_out_date <= ? ");
            params.add(checkOutDate);
        }

        sql.append("ORDER BY r.created_at DESC LIMIT 200");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof LocalDate) {
                    ps.setDate(i + 1, java.sql.Date.valueOf((LocalDate) param));
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                // Use a map to avoid duplicates due to multiple room matches
                Map<Long, ReservationDTO> dtoMap = new LinkedHashMap<>();
                while (rs.next()) {
                    Long id = rs.getLong("id");
                    if (!dtoMap.containsKey(id)) {
                        dtoMap.put(id, mapDTO(rs));
                    }
                }
                list.addAll(dtoMap.values());
            }
        }

        // Enrich all results with their rooms
        enrichWithRooms(list);
        return list;
    }

    // ─── Status lists ─────────────────────────────────────────────────────────────

    @Override
    public List<Reservation> findActiveReservations() throws SQLException {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations " +
                "WHERE reservation_status IN ('CONFIRMED','CHECKED_IN') " +
                "ORDER BY check_in_date";
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
            ps.setDate(1, java.sql.Date.valueOf(date));
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
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapEntity(rs));
            }
        }
        return list;
    }

    // ─── Aggregates ───────────────────────────────────────────────────────────────

    @Override
    public int countOccupiedRoomsByDate(LocalDate date) throws SQLException {
        String sql =
                "SELECT COUNT(DISTINCT rr.room_id) " +
                        "FROM reservation_rooms rr " +
                        "JOIN reservations r ON rr.reservation_id = r.id " +
                        "WHERE r.check_in_date <= ? AND r.check_out_date > ? " +
                        "  AND r.reservation_status = 'CHECKED_IN'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
            ps.setDate(2, java.sql.Date.valueOf(date));
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
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    @Override
    public int countCheckOutsByDate(LocalDate date) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations WHERE check_out_date=? " +
                "AND reservation_status IN ('CHECKED_IN')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
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

    @Override
    public void saveReservationRooms(Long reservationId,
                                     List<Long> roomIds,
                                     Map<Long, BigDecimal> roomPrices) throws SQLException {
        if (roomIds == null || roomIds.isEmpty()) return;

        // Convert Long to int for database compatibility
        int reservationIdInt = reservationId.intValue();

        String sql = "INSERT INTO reservation_rooms (reservation_id, room_id, room_price) " +
                "VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (Long roomId : roomIds) {
                ps.setInt(1, reservationIdInt);           // Convert Long to int
                ps.setInt(2, roomId.intValue());          // Convert Long to int
                ps.setBigDecimal(3, roomPrices.getOrDefault(roomId, BigDecimal.ZERO));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    @Override
    public List<ReservationRoomDTO> findReservationRooms(Long reservationId) throws SQLException {
        List<ReservationRoomDTO> list = new ArrayList<>();

        // Convert Long to int for database compatibility
        int reservationIdInt = reservationId.intValue();

        String sql =
                "SELECT rr.id, rr.reservation_id, rr.room_id, rr.room_price, " +
                        "       rm.room_number, rm.room_type, rm.room_view, " +
                        "       rm.floor_number, rm.capacity " +
                        "FROM reservation_rooms rr " +
                        "JOIN rooms rm ON rr.room_id = rm.id " +
                        "WHERE rr.reservation_id = ? " +
                        "ORDER BY rr.id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationIdInt);  // Use int instead of Long
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRoomRow(rs));
                }
            }
        }
        return list;
    }

    @Override
    public void deleteReservationRooms(Long reservationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM reservation_rooms WHERE reservation_id = ?")) {
            ps.setLong(1, reservationId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<Long> findConflictingReservationIds(Long roomId,
                                                    LocalDate checkIn,
                                                    LocalDate checkOut,
                                                    Long excludeReservationId) throws SQLException {
        List<Long> ids = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT rr.reservation_id " +
                        "FROM reservation_rooms rr " +
                        "JOIN reservations r ON rr.reservation_id = r.id " +
                        "WHERE rr.room_id = ? " +
                        "  AND r.reservation_status IN ('CONFIRMED','CHECKED_IN') " +
                        "  AND r.check_in_date  <  ? " +
                        "  AND r.check_out_date >  ? ");

        if (excludeReservationId != null) {
            sql.append("AND rr.reservation_id <> ? ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, roomId.intValue());  // Convert Long to int
            ps.setDate(2, java.sql.Date.valueOf(checkOut));
            ps.setDate(3, java.sql.Date.valueOf(checkIn));

            if (excludeReservationId != null) {
                ps.setInt(4, excludeReservationId.intValue());  // Convert Long to int
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Return as Long for Java compatibility
                    ids.add(rs.getLong(1));
                }
            }
        }
        return ids;
    }

    @Override
    public List<ReservationDTO> findByCheckInDate(LocalDate date) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO + "WHERE r.check_in_date = ? " +
                "AND r.reservation_status IN ('CONFIRMED', 'CHECKED_IN') " +
                "ORDER BY r.check_in_date, r.created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDTO(rs));
                }
            }
        }
        enrichWithRooms(list);
        return list;
    }

    @Override
    public List<ReservationDTO> findByCheckOutDate(LocalDate date) throws SQLException {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = SELECT_DTO + "WHERE r.check_out_date = ? " +
                "AND r.reservation_status IN ('CHECKED_IN') " +
                "ORDER BY r.check_out_date, r.created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDTO(rs));
                }
            }
        }
        enrichWithRooms(list);
        return list;
    }

    // ─── BaseDAO boilerplate ──────────────────────────────────────────────────────

    @Override
    public List<Reservation> findAll() throws SQLException {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
                     "SELECT * FROM reservations ORDER BY created_at DESC")) {
            while (rs.next()) list.add(mapEntity(rs));
        }
        return list;
    }

    @Override
    public long countActiveReservations() throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations " +
                "WHERE reservation_status IN ('CONFIRMED', 'CHECKED_IN')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getLong(1) : 0;
        }
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

    private void enrichWithRooms(List<ReservationDTO> dtos) throws SQLException {
        if (dtos == null || dtos.isEmpty()) return;

        StringBuilder inClause = new StringBuilder();
        Map<Long, ReservationDTO> byId = new LinkedHashMap<>();
        for (ReservationDTO dto : dtos) {
            if (dto.getId() != null) {
                byId.put(dto.getId(), dto);
                if (inClause.length() > 0) inClause.append(",");
                inClause.append(dto.getId());
            }
        }
        if (byId.isEmpty()) return;

        String sql =
                "SELECT rr.reservation_id, rr.id, rr.room_id, rr.room_price, " +
                        "       rm.room_number, rm.room_type, rm.room_view, " +
                        "       rm.floor_number, rm.capacity " +
                        "FROM reservation_rooms rr " +
                        "JOIN rooms rm ON rr.room_id = rm.id " +
                        "WHERE rr.reservation_id IN (" + inClause + ") " +
                        "ORDER BY rr.reservation_id, rr.id";

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                long resId = rs.getLong("reservation_id");
                ReservationDTO dto = byId.get(resId);
                if (dto == null) continue;
                dto.getRooms().add(mapRoomRow(rs));
            }
        }
    }

    // ─── Row mappers ──────────────────────────────────────────────────────────────

    private Reservation mapEntity(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getLong("id"));
        r.setReservationNumber(rs.getString("reservation_number"));
        r.setGuestId(rs.getLong("guest_id"));
        r.setUserId(rs.getObject("user_id") != null ? rs.getLong("user_id") : null);
        r.setNumberOfRooms(rs.getInt("number_of_rooms"));            // <-- no room_id

        java.sql.Date ci = rs.getDate("check_in_date");
        java.sql.Date co = rs.getDate("check_out_date");
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

        safeSetSource(r,  rs.getString("source"));
        safeSetPayment(r, rs.getString("payment_status"));
        safeSetStatus(r,  rs.getString("reservation_status"));

        Timestamp ca = rs.getTimestamp("created_at");
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ca != null) r.setCreatedAt(ca.toLocalDateTime());
        if (ua != null) r.setUpdatedAt(ua.toLocalDateTime());
        return r;
    }

    private ReservationDTO mapDTO(ResultSet rs) throws SQLException {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(rs.getLong("id"));
        dto.setReservationNumber(rs.getString("reservation_number"));
        dto.setGuestId(rs.getLong("guest_id"));
        dto.setUserId(rs.getObject("user_id") != null ? rs.getLong("user_id") : null);
        dto.setNumberOfRooms(rs.getInt("number_of_rooms"));          // <-- no room_id

        // Guest joined fields
        dto.setGuestName(rs.getString("guest_name"));
        dto.setGuestEmail(rs.getString("guest_email"));
        dto.setGuestPhone(rs.getString("guest_phone"));
        dto.setGuestNumber(rs.getString("guest_number_col"));

        java.sql.Date ci = rs.getDate("check_in_date");
        java.sql.Date co = rs.getDate("check_out_date");
        if (ci != null) dto.setCheckInDate(ci.toLocalDate());
        if (co != null) dto.setCheckOutDate(co.toLocalDate());

        dto.setTotalNights(rs.getInt("total_nights"));
        dto.setAdults(rs.getInt("adults"));
        dto.setChildren(rs.getInt("children"));
        dto.setRoomPrice(rs.getBigDecimal("room_price"));            // combined nightly rate
        dto.setTaxAmount(rs.getBigDecimal("tax_amount"));
        dto.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        dto.setSubtotal(rs.getBigDecimal("subtotal"));
        dto.setTotalAmount(rs.getBigDecimal("total_amount"));
        dto.setPaymentStatus(rs.getString("payment_status"));
        dto.setReservationStatus(rs.getString("reservation_status"));
        dto.setSpecialRequests(rs.getString("special_requests"));
        dto.setSource(rs.getString("source"));

        Timestamp ca = rs.getTimestamp("created_at");
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ca != null) dto.setCreatedAt(ca.toLocalDateTime());
        if (ua != null) dto.setUpdatedAt(ua.toLocalDateTime());

        // rooms list will be populated by enrichWithRooms() or findDTOById()
        dto.setRooms(new ArrayList<>());
        return dto;
    }

    /** Maps a row from reservation_rooms JOIN rooms into a ReservationRoomDTO. */
    private ReservationRoomDTO mapRoomRow(ResultSet rs) throws SQLException {
        ReservationRoomDTO rr = new ReservationRoomDTO();
        rr.setId(rs.getLong("id"));
        rr.setReservationId(rs.getLong("reservation_id"));
        rr.setRoomId(rs.getLong("room_id"));
        rr.setRoomPrice(rs.getBigDecimal("room_price"));
        rr.setRoomNumber(rs.getString("room_number"));
        rr.setRoomType(rs.getString("room_type"));
        rr.setRoomView(rs.getString("room_view"));
        rr.setFloorNumber(rs.getObject("floor_number") != null ? rs.getInt("floor_number") : null);
        rr.setCapacity(rs.getInt("capacity"));
        return rr;
    }

    // ─── Tiny helpers ─────────────────────────────────────────────────────────────

    private BigDecimal orZero(BigDecimal v) { return v != null ? v : BigDecimal.ZERO; }

    private void safeSetSource(Reservation r, String s) {
        if (s != null) {
            try { r.setSource(Reservation.ReservationSource.valueOf(s)); }
            catch (IllegalArgumentException ignored) {}
        }
    }
    private void safeSetPayment(Reservation r, String s) {
        if (s != null) {
            try { r.setPaymentStatus(Reservation.PaymentStatus.valueOf(s)); }
            catch (IllegalArgumentException ignored) {}
        }
    }
    private void safeSetStatus(Reservation r, String s) {
        if (s != null) {
            try { r.setReservationStatus(Reservation.ReservationStatus.valueOf(s)); }
            catch (IllegalArgumentException ignored) {}
        }
    }

    private String generateReservationNumber() {
        return "RES-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}