package com.oceanview.dao.impl;

import com.oceanview.dao.GuestDAO;
import com.oceanview.model.Guest;
import com.oceanview.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class GuestDAOImpl implements GuestDAO {

    private static GuestDAOImpl instance;

    private GuestDAOImpl() {}

    public static synchronized GuestDAOImpl getInstance() {
        if (instance == null) {
            instance = new GuestDAOImpl();
        }
        return instance;
    }

    @Override
    public Guest save(Guest guest) throws SQLException {
        String sql = "INSERT INTO guests (guest_number, first_name, last_name, email, phone, " +
                "address, city, country, postal_code, id_card_number, id_card_type, is_vip, " +
                "loyalty_points, notes, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, guest.getGuestNumber());
            ps.setString(2, guest.getFirstName());
            ps.setString(3, guest.getLastName());
            ps.setString(4, guest.getEmail());
            ps.setString(5, guest.getPhone());
            ps.setString(6, guest.getAddress());
            ps.setString(7, guest.getCity());
            ps.setString(8, guest.getCountry());
            ps.setString(9, guest.getPostalCode());
            ps.setString(10, guest.getIdCardNumber());
            ps.setString(11, guest.getIdCardType() != null ? guest.getIdCardType().name() : null);
            ps.setBoolean(12, guest.isVip());
            ps.setInt(13, guest.getLoyaltyPoints() != null ? guest.getLoyaltyPoints() : 0);
            ps.setString(14, guest.getNotes());
            ps.setTimestamp(15, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(16, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating guest failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    guest.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating guest failed, no ID obtained.");
                }
            }
        }
        return guest;
    }

    @Override
    public Guest update(Guest guest) throws SQLException {
        String sql = "UPDATE guests SET first_name = ?, last_name = ?, email = ?, phone = ?, " +
                "address = ?, city = ?, country = ?, postal_code = ?, id_card_number = ?, " +
                "id_card_type = ?, is_vip = ?, loyalty_points = ?, notes = ?, updated_at = ? " +
                "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, guest.getFirstName());
            ps.setString(2, guest.getLastName());
            ps.setString(3, guest.getEmail());
            ps.setString(4, guest.getPhone());
            ps.setString(5, guest.getAddress());
            ps.setString(6, guest.getCity());
            ps.setString(7, guest.getCountry());
            ps.setString(8, guest.getPostalCode());
            ps.setString(9, guest.getIdCardNumber());
            ps.setString(10, guest.getIdCardType() != null ? guest.getIdCardType().name() : null);
            ps.setBoolean(11, guest.isVip());
            ps.setInt(12, guest.getLoyaltyPoints() != null ? guest.getLoyaltyPoints() : 0);
            ps.setString(13, guest.getNotes());
            ps.setTimestamp(14, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(15, guest.getId());

            ps.executeUpdate();
        }
        return guest;
    }

    @Override
    public boolean delete(Long id) throws SQLException {
        String sql = "DELETE FROM guests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Optional<Guest> findById(Long id) throws SQLException {
        String sql = "SELECT * FROM guests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToGuest(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Guest> findByGuestNumber(String guestNumber) throws SQLException {
        String sql = "SELECT * FROM guests WHERE guest_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, guestNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToGuest(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Guest> findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM guests WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToGuest(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Guest> findByPhone(String phone) throws SQLException {
        String sql = "SELECT * FROM guests WHERE phone = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToGuest(rs));
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public List<Guest> findByName(String firstName, String lastName) throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests WHERE first_name LIKE ? AND last_name LIKE ? ORDER BY last_name, first_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + firstName + "%");
            ps.setString(2, "%" + lastName + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guests.add(mapResultSetToGuest(rs));
                }
            }
        }
        return guests;
    }

    @Override
    public List<Guest> searchGuests(String keyword) throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests WHERE first_name LIKE ? OR last_name LIKE ? " +
                "OR email LIKE ? OR phone LIKE ? OR guest_number LIKE ? " +
                "ORDER BY last_name, first_name LIMIT 50";

        String searchPattern = "%" + keyword + "%";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guests.add(mapResultSetToGuest(rs));
                }
            }
        }
        return guests;
    }

    @Override
    public List<Guest> findRecentGuests(int limit) throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guests.add(mapResultSetToGuest(rs));
                }
            }
        }
        return guests;
    }

    /**
     * Returns the top N guests ranked by their total number of reservations.
     * Falls back to ordering by loyalty_points if no reservations exist yet.
     */
    @Override
    public List<Guest> findTopGuests(int limit) throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT g.*, COUNT(r.id) AS stay_count " +
                "FROM guests g " +
                "LEFT JOIN reservations r ON r.guest_id = g.id " +
                "   AND r.reservation_status NOT IN ('CANCELLED', 'NO_SHOW') " +
                "GROUP BY g.id " +
                "ORDER BY stay_count DESC, g.loyalty_points DESC " +
                "LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guests.add(mapResultSetToGuest(rs));
                }
            }
        }
        return guests;
    }

    @Override
    public List<Guest> findAll() throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY last_name, first_name";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                guests.add(mapResultSetToGuest(rs));
            }
        }
        return guests;
    }

    @Override
    public List<Guest> findAll(int page, int size) throws SQLException {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY last_name, first_name LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guests.add(mapResultSetToGuest(rs));
                }
            }
        }
        return guests;
    }

    @Override
    public long countActiveGuests() throws SQLException {
        // "active" guests = non-VIP guests or simply count all (adjust logic as needed)
        String sql = "SELECT COUNT(*) FROM guests";
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
    public long count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM guests";
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
        String sql = "SELECT 1 FROM guests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Guest mapResultSetToGuest(ResultSet rs) throws SQLException {
        Guest guest = new Guest();
        guest.setId(rs.getLong("id"));
        guest.setGuestNumber(rs.getString("guest_number"));
        guest.setFirstName(rs.getString("first_name"));
        guest.setLastName(rs.getString("last_name"));
        guest.setEmail(rs.getString("email"));
        guest.setPhone(rs.getString("phone"));
        guest.setAddress(rs.getString("address"));
        guest.setCity(rs.getString("city"));
        guest.setCountry(rs.getString("country"));
        guest.setPostalCode(rs.getString("postal_code"));
        guest.setIdCardNumber(rs.getString("id_card_number"));

        String idCardType = rs.getString("id_card_type");
        if (idCardType != null && !idCardType.isEmpty()) {
            guest.setIdCardType(Guest.IdCardType.valueOf(idCardType));
        }

        guest.setVip(rs.getBoolean("is_vip"));
        guest.setLoyaltyPoints(rs.getInt("loyalty_points"));
        guest.setNotes(rs.getString("notes"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            guest.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            guest.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return guest;
    }
}