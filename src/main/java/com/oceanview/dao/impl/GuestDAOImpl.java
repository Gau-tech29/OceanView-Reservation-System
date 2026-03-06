package com.oceanview.dao.impl;

import com.oceanview.dao.GuestDAO;
import com.oceanview.model.Guest;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class GuestDAOImpl implements GuestDAO {

    private static GuestDAOImpl instance;

    private GuestDAOImpl() {}

    public static synchronized GuestDAOImpl getInstance() {
        if (instance == null) instance = new GuestDAOImpl();
        return instance;
    }

    @Override
    public Guest save(Guest g) throws SQLException {
        String sql =
                "INSERT INTO guests " +
                        "(guest_number, first_name, last_name, email, phone, " +
                        " address, city, country, postal_code, " +
                        " id_card_number, id_card_type, is_vip, loyalty_points, notes, " +
                        " created_at, updated_at) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            String gNum = g.getGuestNumber() != null
                    ? g.getGuestNumber() : generateGuestNumber();
            g.setGuestNumber(gNum);

            LocalDateTime now = LocalDateTime.now();
            ps.setString(1,  gNum);
            ps.setString(2,  g.getFirstName());
            ps.setString(3,  g.getLastName());
            ps.setString(4,  g.getEmail());
            ps.setString(5,  g.getPhone());
            ps.setString(6,  g.getAddress());
            ps.setString(7,  g.getCity());
            ps.setString(8,  g.getCountry());
            ps.setString(9,  g.getPostalCode());
            ps.setString(10, g.getIdCardNumber());
            ps.setString(11, g.getIdCardType());
            ps.setBoolean(12, g.isVip());
            ps.setInt(13,    g.getLoyaltyPoints());
            ps.setString(14, g.getNotes());
            ps.setTimestamp(15, Timestamp.valueOf(now));
            ps.setTimestamp(16, Timestamp.valueOf(now));
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) g.setId(keys.getLong(1));
            }
        }
        return g;
    }

    // ── UPDATE ────────────────────────────────────────────────────────────────────

    @Override
    public Guest update(Guest g) throws SQLException {
        String sql =
                "UPDATE guests SET " +
                        "first_name=?, last_name=?, email=?, phone=?, " +
                        "address=?, city=?, country=?, postal_code=?, " +
                        "id_card_number=?, id_card_type=?, is_vip=?, loyalty_points=?, " +
                        "notes=?, updated_at=? " +
                        "WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1,  g.getFirstName());
            ps.setString(2,  g.getLastName());
            ps.setString(3,  g.getEmail());
            ps.setString(4,  g.getPhone());
            ps.setString(5,  g.getAddress());
            ps.setString(6,  g.getCity());
            ps.setString(7,  g.getCountry());
            ps.setString(8,  g.getPostalCode());
            ps.setString(9,  g.getIdCardNumber());
            ps.setString(10, g.getIdCardType());
            ps.setBoolean(11, g.isVip());
            ps.setInt(12,    g.getLoyaltyPoints());
            ps.setString(13, g.getNotes());
            ps.setTimestamp(14, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(15,   g.getId());

            ps.executeUpdate();
        }
        return g;
    }

    // ── DELETE ────────────────────────────────────────────────────────────────────

    @Override
    public boolean delete(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM guests WHERE id=?")) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── SINGLE READS ──────────────────────────────────────────────────────────────

    @Override
    public Optional<Guest> findById(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        }
    }

    @Override
    public Optional<Guest> findByEmail(String email) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests WHERE email=? LIMIT 1")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        }
    }

    @Override
    public Optional<Guest> findByGuestNumber(String number) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests WHERE guest_number=? LIMIT 1")) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        }
    }

    // ── LIST READS ────────────────────────────────────────────────────────────────

    @Override
    public List<Guest> findAll() throws SQLException {
        List<Guest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(
                     "SELECT * FROM guests ORDER BY last_name, first_name")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    @Override
    public List<Guest> findAll(int page, int size) throws SQLException {
        List<Guest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests ORDER BY last_name, first_name LIMIT ? OFFSET ?")) {
            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Guest> findByName(String name) throws SQLException {
        List<Guest> list = new ArrayList<>();
        String p = "%" + name + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests WHERE first_name LIKE ? OR last_name LIKE ? " +
                             "ORDER BY last_name, first_name")) {
            ps.setString(1, p);
            ps.setString(2, p);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Guest> findByPhone(String phone) throws SQLException {
        List<Guest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM guests WHERE phone LIKE ? ORDER BY last_name")) {
            ps.setString(1, "%" + phone + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    @Override
    public List<Guest> searchGuests(String keyword) throws SQLException {
        List<Guest> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return findAll();
        String p = "%" + keyword.trim() + "%";
        String sql =
                "SELECT * FROM guests WHERE " +
                        "first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR phone LIKE ? " +
                        "OR guest_number LIKE ? " +
                        "ORDER BY last_name, first_name LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) ps.setString(i, p);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /**
     * Returns up to {@code limit} guests ordered by their total number of reservations
     * (most frequent guests first). Falls back to alphabetical order if no reservations exist.
     */
    @Override
    public List<Guest> findTopGuests(int limit) throws SQLException {
        List<Guest> list = new ArrayList<>();
        String sql =
                "SELECT g.*, COUNT(r.id) AS reservation_count " +
                        "FROM guests g " +
                        "LEFT JOIN reservations r ON r.guest_id = g.id " +
                        "GROUP BY g.id " +
                        "ORDER BY reservation_count DESC, g.last_name " +
                        "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── COUNTS ────────────────────────────────────────────────────────────────────

    @Override
    public long count() throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM guests")) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    @Override
    public long countActiveGuests() throws SQLException {
        // guests table has no is_active column — count all guests
        return count();
    }

    @Override
    public boolean exists(Long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM guests WHERE id=?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // ── ROW MAPPER ────────────────────────────────────────────────────────────────

    private Guest map(ResultSet rs) throws SQLException {
        Guest g = new Guest();
        g.setId(rs.getLong("id"));
        g.setGuestNumber(rs.getString("guest_number"));
        g.setFirstName(rs.getString("first_name"));
        g.setLastName(rs.getString("last_name"));
        g.setEmail(rs.getString("email"));
        g.setPhone(rs.getString("phone"));
        g.setAddress(rs.getString("address"));
        g.setCity(rs.getString("city"));
        g.setCountry(rs.getString("country"));
        g.setPostalCode(rs.getString("postal_code"));
        g.setIdCardNumber(rs.getString("id_card_number"));
        g.setIdCardType(rs.getString("id_card_type"));
        g.setVip(rs.getBoolean("is_vip"));
        g.setLoyaltyPoints(rs.getInt("loyalty_points"));
        g.setNotes(rs.getString("notes"));

        Timestamp ca = rs.getTimestamp("created_at");
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ca != null) g.setCreatedAt(ca.toLocalDateTime());
        if (ua != null) g.setUpdatedAt(ua.toLocalDateTime());
        return g;
    }

    // ── HELPER ────────────────────────────────────────────────────────────────────

    private String generateGuestNumber() {
        return "GST-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}