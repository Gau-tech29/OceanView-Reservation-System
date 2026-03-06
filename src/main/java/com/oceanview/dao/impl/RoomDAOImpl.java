package com.oceanview.dao.impl;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * JDBC implementation of RoomDAO.
 * All queries target the `rooms` table in oceanview_db.
 *
 * Key method: findAvailableRoomsForDates — returns rooms with no
 * overlapping CONFIRMED/CHECKED_IN reservation for the requested window.
 */
public class RoomDAOImpl implements RoomDAO {

    private static RoomDAOImpl instance;

    private RoomDAOImpl() {}

    public static synchronized RoomDAOImpl getInstance() {
        if (instance == null) instance = new RoomDAOImpl();
        return instance;
    }

    @Override
    public Room save(Room room) throws SQLException {
        String sql =
                "INSERT INTO rooms " +
                        "(room_number, room_type, room_view, floor_number, capacity, " +
                        " base_price, tax_rate, amenities, description, status, is_active, " +
                        " created_at, updated_at) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            LocalDateTime now = LocalDateTime.now();

            ps.setString(1,  room.getRoomNumber());
            ps.setString(2,  room.getRoomType()  != null ? room.getRoomType().name()  : null);
            ps.setString(3,  room.getRoomView()  != null ? room.getRoomView().name()  : null);
            ps.setObject(4,  room.getFloorNumber());
            ps.setObject(5,  room.getCapacity());
            ps.setBigDecimal(6, room.getBasePrice()  != null ? room.getBasePrice()  : BigDecimal.ZERO);
            ps.setBigDecimal(7, room.getTaxRate()    != null ? room.getTaxRate()    : new BigDecimal("12.00"));
            ps.setString(8,  room.getAmenities());
            ps.setString(9,  room.getDescription());
            ps.setString(10, room.getStatus() != null ? room.getStatus().name() : Room.RoomStatus.AVAILABLE.name());
            ps.setBoolean(11, room.isActive());
            ps.setTimestamp(12, Timestamp.valueOf(now));
            ps.setTimestamp(13, Timestamp.valueOf(now));

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) room.setId(keys.getLong(1));
            }
        }
        return room;
    }

    @Override
    public Room update(Room room) throws SQLException {
        String sql =
                "UPDATE rooms SET " +
                        "room_number=?, room_type=?, room_view=?, floor_number=?, capacity=?, " +
                        "base_price=?, tax_rate=?, amenities=?, description=?, status=?, " +
                        "is_active=?, updated_at=? " +
                        "WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1,  room.getRoomNumber());
            ps.setString(2,  room.getRoomType()  != null ? room.getRoomType().name()  : null);
            ps.setString(3,  room.getRoomView()  != null ? room.getRoomView().name()  : null);
            ps.setObject(4,  room.getFloorNumber());
            ps.setObject(5,  room.getCapacity());
            ps.setBigDecimal(6, room.getBasePrice()  != null ? room.getBasePrice()  : BigDecimal.ZERO);
            ps.setBigDecimal(7, room.getTaxRate()    != null ? room.getTaxRate()    : new BigDecimal("12.00"));
            ps.setString(8,  room.getAmenities());
            ps.setString(9,  room.getDescription());
            ps.setString(10, room.getStatus() != null ? room.getStatus().name() : Room.RoomStatus.AVAILABLE.name());
            ps.setBoolean(11, room.isActive());
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(13,   room.getId());

            ps.executeUpdate();
        }
        return room;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM rooms WHERE id=?")) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Room> findById(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM rooms WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        }
    }

    @Override
    public Optional<Room> findByRoomNumber(String roomNumber) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE room_number=? LIMIT 1")) {
            ps.setString(1, roomNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        }
    }

    // ── LIST READS ────────────────────────────────────────────────────────────────

    @Override
    public List<Room> findAll() throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM rooms ORDER BY room_number")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    @Override
    public List<Room> findAll(int page, int size) throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms ORDER BY room_number LIMIT ? OFFSET ?")) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findByType(Room.RoomType type) throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE room_type=? ORDER BY room_number")) {
            ps.setString(1, type.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findByStatus(Room.RoomStatus status) throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE status=? ORDER BY room_number")) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findByFloor(int floorNumber) throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE floor_number=? ORDER BY room_number")) {
            ps.setInt(1, floorNumber);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findAvailableRooms() throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE status='AVAILABLE' AND is_active=TRUE " +
                             "ORDER BY room_number")) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findOccupiedRooms() throws SQLException {
        return findByStatus(Room.RoomStatus.OCCUPIED);
    }

    @Override
    public List<Room> findRoomsByCapacity(int capacity) throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE capacity >= ? AND is_active=TRUE " +
                             "ORDER BY capacity, room_number")) {
            ps.setInt(1, capacity);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Room> findRoomsByPriceRange(double minPrice, double maxPrice)
            throws SQLException {
        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE base_price >= ? AND base_price <= ? " +
                             "AND is_active=TRUE ORDER BY base_price")) {
            ps.setBigDecimal(1, BigDecimal.valueOf(minPrice));
            ps.setBigDecimal(2, BigDecimal.valueOf(maxPrice));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /**
     * Returns all active rooms that have NO overlapping CONFIRMED / CHECKED_IN
     * reservation for the window [checkIn, checkOut).
     *
     * Overlap condition: existingCheckIn < checkOut AND existingCheckOut > checkIn
     */
    @Override
    public List<Room> findAvailableRoomsForDates(LocalDate checkIn, LocalDate checkOut)
            throws SQLException {
        List<Room> list = new ArrayList<>();
        String sql =
                "SELECT r.* FROM rooms r " +
                        "WHERE r.is_active = TRUE " +
                        "  AND r.id NOT IN ( " +
                        "    SELECT DISTINCT rr.room_id " +
                        "    FROM reservation_rooms rr " +
                        "    JOIN reservations res ON rr.reservation_id = res.id " +
                        "    WHERE res.reservation_status IN ('CONFIRMED', 'CHECKED_IN') " +
                        "      AND res.check_in_date  < ? " +
                        "      AND res.check_out_date > ? " +
                        "  ) " +
                        "ORDER BY r.room_number";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(checkOut));
            ps.setDate(2, java.sql.Date.valueOf(checkIn));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── STATUS UPDATE ─────────────────────────────────────────────────────────────

    @Override
    public boolean updateStatus(Long id, Room.RoomStatus status) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE rooms SET status=?, updated_at=? WHERE id=?")) {
            ps.setString(1, status.name());
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── COUNTS ────────────────────────────────────────────────────────────────────

    @Override
    public long count() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM rooms")) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    @Override
    public long countAvailableRooms() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
                     "SELECT COUNT(*) FROM rooms WHERE status='AVAILABLE' AND is_active=TRUE")) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM rooms WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // ── ROW MAPPER ────────────────────────────────────────────────────────────────

    private Room map(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setId(rs.getLong("id"));
        room.setRoomNumber(rs.getString("room_number"));

        safeSetType(room,   rs.getString("room_type"));
        safeSetView(room,   rs.getString("room_view"));
        safeSetStatus(room, rs.getString("status"));

        room.setFloorNumber(rs.getObject("floor_number") != null ? rs.getInt("floor_number") : null);
        room.setCapacity(rs.getObject("capacity")        != null ? rs.getInt("capacity")     : null);
        room.setBasePrice(rs.getBigDecimal("base_price"));
        room.setTaxRate(rs.getBigDecimal("tax_rate"));
        room.setAmenities(rs.getString("amenities"));
        room.setDescription(rs.getString("description"));
        room.setActive(rs.getBoolean("is_active"));

        Timestamp ca = rs.getTimestamp("created_at");
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ca != null) room.setCreatedAt(ca.toLocalDateTime());
        if (ua != null) room.setUpdatedAt(ua.toLocalDateTime());
        return room;
    }

    private void safeSetType(Room r, String s) {
        if (s != null) {
            try { r.setRoomType(Room.RoomType.valueOf(s)); }
            catch (IllegalArgumentException ignored) {}
        }
    }

    private void safeSetView(Room r, String s) {
        if (s != null) {
            try { r.setRoomView(Room.RoomView.valueOf(s)); }
            catch (IllegalArgumentException ignored) {}
        }
    }

    private void safeSetStatus(Room r, String s) {
        if (s != null) {
            try { r.setStatus(Room.RoomStatus.valueOf(s)); }
            catch (IllegalArgumentException ignored) { r.setStatus(Room.RoomStatus.AVAILABLE); }
        }
    }
}