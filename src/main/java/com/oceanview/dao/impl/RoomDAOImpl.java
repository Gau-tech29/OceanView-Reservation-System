package com.oceanview.dao.impl;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class RoomDAOImpl implements RoomDAO {

    private static RoomDAOImpl instance;

    private RoomDAOImpl() {}

    public static synchronized RoomDAOImpl getInstance() {
        if (instance == null) instance = new RoomDAOImpl();
        return instance;
    }

    // ── NEW: Inclusive date-range availability ────────────────────────────────

    /**
     * Returns every active room that has NO overlapping CONFIRMED or CHECKED_IN
     * reservation for the window [checkIn, checkOut] (BOTH DATES INCLUSIVE).
     *
     * Inclusive overlap rule:
     *   An existing reservation [r.checkIn, r.checkOut] overlaps [checkIn, checkOut] when:
     *     r.check_in_date  <= :checkOut   (reservation starts on or before our checkout)
     *   AND
     *     r.check_out_date >= :checkIn    (reservation ends   on or after  our checkin)
     *
     * This means:
     *   - A guest checking IN on the same day another checks OUT → rooms are NOT available
     *     (both dates count as occupied nights)
     *   - A reservation that ends exactly on our checkIn is treated as still occupying the room
     */
    @Override
    public List<Room> findAvailableRoomsForDates(LocalDate checkIn, LocalDate checkOut)
            throws SQLException {

        String sql =
                "SELECT rm.* FROM rooms rm " +
                        "WHERE rm.is_active = 1 " +
                        "  AND rm.id NOT IN ( " +
                        "      SELECT DISTINCT r.room_id " +
                        "      FROM reservations r " +
                        "      WHERE r.reservation_status IN ('CONFIRMED', 'CHECKED_IN') " +
                        "        AND r.check_in_date  <= ? " +   // existing starts on or before our checkout
                        "        AND r.check_out_date >= ? " +   // existing ends   on or after  our checkin
                        "  ) " +
                        "ORDER BY rm.room_type, rm.room_number";

        List<Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(checkOut));   // param 1: our desired checkout (inclusive)
            ps.setDate(2, Date.valueOf(checkIn));    // param 2: our desired checkin  (inclusive)
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToRoom(rs));
            }
        }
        return list;
    }

    // ── CRUD ─────────────────────────────────────────────────────────────────

    @Override
    public Room save(Room room) throws SQLException {
        String sql = "INSERT INTO rooms (room_number, room_type, room_view, floor_number, capacity, " +
                "base_price, tax_rate, amenities, description, status, is_active, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType().name());
            ps.setString(3, room.getRoomView().name());
            ps.setInt(4, room.getFloorNumber());
            ps.setInt(5, room.getCapacity());
            ps.setBigDecimal(6, room.getBasePrice());
            ps.setBigDecimal(7, room.getTaxRate());
            ps.setString(8, room.getAmenities());
            ps.setString(9, room.getDescription());
            ps.setString(10, room.getStatus().name());
            ps.setBoolean(11, room.isActive());
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(13, Timestamp.valueOf(LocalDateTime.now()));
            int rows = ps.executeUpdate();
            if (rows == 0) throw new SQLException("Creating room failed, no rows affected.");
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) room.setId(keys.getLong(1));
                else throw new SQLException("Creating room failed, no ID obtained.");
            }
        }
        return room;
    }

    @Override
    public Room update(Room room) throws SQLException {
        String sql = "UPDATE rooms SET room_number=?, room_type=?, room_view=?, floor_number=?, " +
                "capacity=?, base_price=?, tax_rate=?, amenities=?, description=?, " +
                "status=?, is_active=?, updated_at=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType().name());
            ps.setString(3, room.getRoomView().name());
            ps.setInt(4, room.getFloorNumber());
            ps.setInt(5, room.getCapacity());
            ps.setBigDecimal(6, room.getBasePrice());
            ps.setBigDecimal(7, room.getTaxRate());
            ps.setString(8, room.getAmenities());
            ps.setString(9, room.getDescription());
            ps.setString(10, room.getStatus().name());
            ps.setBoolean(11, room.isActive());
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(13, room.getId());
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

    // ── Queries ───────────────────────────────────────────────────────────────

    @Override
    public Optional<Room> findById(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM rooms WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapResultSetToRoom(rs));
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Room> findByRoomNumber(String roomNumber) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM rooms WHERE room_number=?")) {
            ps.setString(1, roomNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapResultSetToRoom(rs));
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Room> findAll() throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM rooms ORDER BY room_number")) {
            while (rs.next()) rooms.add(mapResultSetToRoom(rs));
        }
        return rooms;
    }

    @Override
    public List<Room> findAll(int page, int size) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms ORDER BY room_number LIMIT ? OFFSET ?")) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

    @Override
    public List<Room> findByType(Room.RoomType type) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE room_type=? AND is_active=true")) {
            ps.setString(1, type.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

    @Override
    public List<Room> findByStatus(Room.RoomStatus status) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE status=? AND is_active=true")) {
            ps.setString(1, status.name());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

    @Override
    public List<Room> findByFloor(int floorNumber) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE floor_number=? AND is_active=true ORDER BY room_number")) {
            ps.setInt(1, floorNumber);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

    @Override
    public List<Room> findAvailableRooms() throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT * FROM rooms WHERE status='AVAILABLE' AND is_active=true ORDER BY room_number")) {
            while (rs.next()) rooms.add(mapResultSetToRoom(rs));
        }
        return rooms;
    }

    @Override
    public List<Room> findOccupiedRooms() throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT * FROM rooms WHERE status='OCCUPIED' AND is_active=true ORDER BY room_number")) {
            while (rs.next()) rooms.add(mapResultSetToRoom(rs));
        }
        return rooms;
    }

    @Override
    public List<Room> findRoomsByCapacity(int capacity) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE capacity>=? AND is_active=true ORDER BY room_number")) {
            ps.setInt(1, capacity);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

    @Override
    public List<Room> findRoomsByPriceRange(double minPrice, double maxPrice) throws SQLException {
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM rooms WHERE base_price BETWEEN ? AND ? AND is_active=true ORDER BY base_price")) {
            ps.setDouble(1, minPrice);
            ps.setDouble(2, maxPrice);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }

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

    // ── Counts ────────────────────────────────────────────────────────────────

    @Override
    public long countAvailableRooms() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT COUNT(*) FROM rooms WHERE status='AVAILABLE' AND is_active=true")) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0;
    }

    @Override
    public long count() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM rooms WHERE is_active=true")) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0;
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM rooms WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // ── Mapper ────────────────────────────────────────────────────────────────

    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setId(rs.getLong("id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomType(Room.RoomType.valueOf(rs.getString("room_type")));
        room.setRoomView(Room.RoomView.valueOf(rs.getString("room_view")));
        room.setFloorNumber(rs.getInt("floor_number"));
        room.setCapacity(rs.getInt("capacity"));
        room.setBasePrice(rs.getBigDecimal("base_price"));
        room.setTaxRate(rs.getBigDecimal("tax_rate"));
        room.setAmenities(rs.getString("amenities"));
        room.setDescription(rs.getString("description"));
        room.setStatus(Room.RoomStatus.valueOf(rs.getString("status")));
        room.setActive(rs.getBoolean("is_active"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) room.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) room.setUpdatedAt(ua.toLocalDateTime());
        return room;
    }
}
