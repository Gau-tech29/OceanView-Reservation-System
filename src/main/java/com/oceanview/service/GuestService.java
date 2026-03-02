package com.oceanview.service;

import com.oceanview.dao.GuestDAO;
import com.oceanview.dao.impl.GuestDAOImpl;
import com.oceanview.dto.GuestDTO;
import com.oceanview.model.Guest;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Business-logic layer for Guest operations.
 * Called by dashboard servlets and reservation controllers.
 */
public class GuestService {

    private final GuestDAO guestDAO;

    public GuestService() {
        this.guestDAO = GuestDAOImpl.getInstance();
    }

    // ── Create ────────────────────────────────────────────────────────────────────

    /**
     * Creates a new guest and returns the persisted GuestDTO (with generated id/number).
     */
    public GuestDTO createGuest(GuestDTO dto) throws SQLException {
        validateGuest(dto);

        // Check email uniqueness if provided
        if (dto.getEmail() != null && !dto.getEmail().trim().isEmpty()) {
            Optional<Guest> existing = guestDAO.findByEmail(dto.getEmail().trim());
            if (existing.isPresent()) {
                throw new IllegalArgumentException(
                        "A guest with email '" + dto.getEmail() + "' already exists.");
            }
        }

        Guest guest = toEntity(dto);
        Guest saved = guestDAO.save(guest);
        return toDTO(saved);
    }

    // ── Update ────────────────────────────────────────────────────────────────────

    public GuestDTO updateGuest(GuestDTO dto) throws SQLException {
        if (dto.getId() == null)
            throw new IllegalArgumentException("Guest ID is required for update.");
        validateGuest(dto);

        Guest existing = guestDAO.findById(dto.getId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Guest not found with ID: " + dto.getId()));

        // If email changed, check uniqueness
        if (dto.getEmail() != null && !dto.getEmail().trim().isEmpty()
                && !dto.getEmail().trim().equalsIgnoreCase(existing.getEmail())) {
            Optional<Guest> conflict = guestDAO.findByEmail(dto.getEmail().trim());
            if (conflict.isPresent()) {
                throw new IllegalArgumentException(
                        "Email '" + dto.getEmail() + "' is already in use.");
            }
        }

        Guest updated = toEntity(dto);
        updated.setGuestNumber(existing.getGuestNumber()); // preserve auto-generated number
        guestDAO.update(updated);
        return toDTO(updated);
    }

    // ── Read ──────────────────────────────────────────────────────────────────────

    public Optional<GuestDTO> getGuestById(Long id) throws SQLException {
        return guestDAO.findById(id).map(this::toDTO);
    }

    public Optional<GuestDTO> getGuestByEmail(String email) throws SQLException {
        return guestDAO.findByEmail(email).map(this::toDTO);
    }

    public Optional<GuestDTO> getGuestByNumber(String number) throws SQLException {
        return guestDAO.findByGuestNumber(number).map(this::toDTO);
    }

    public List<GuestDTO> getAllGuests() throws SQLException {
        return guestDAO.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<GuestDTO> getGuests(int page, int size) throws SQLException {
        return guestDAO.findAll(page, size).stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<GuestDTO> searchGuests(String keyword) throws SQLException {
        return guestDAO.searchGuests(keyword).stream().map(this::toDTO).collect(Collectors.toList());
    }

    // ── Counts (used by dashboards) ───────────────────────────────────────────────

    public long getTotalGuestsCount() throws SQLException {
        return guestDAO.count();
    }

    /**
     * Returns the number of active guests.
     * Used by StaffDashboardServlet and AdminDashboardServlet.
     */
    public long getActiveGuestsCount() throws SQLException {
        return guestDAO.countActiveGuests();
    }

    // ── Delete ────────────────────────────────────────────────────────────────────

    public boolean deleteGuest(Long id) throws SQLException {
        return guestDAO.delete(id);
    }

    // ── Mapper helpers ────────────────────────────────────────────────────────────

    private Guest toEntity(GuestDTO dto) {
        Guest g = new Guest();
        g.setId(dto.getId());
        g.setGuestNumber(dto.getGuestNumber());
        g.setFirstName(dto.getFirstName() != null ? dto.getFirstName().trim() : null);
        g.setLastName(dto.getLastName()   != null ? dto.getLastName().trim()  : null);
        g.setEmail(dto.getEmail()         != null ? dto.getEmail().trim()     : null);
        g.setPhone(dto.getPhone());
        g.setAddress(dto.getAddress());
        g.setCity(dto.getCity());
        g.setCountry(dto.getCountry());
        g.setPostalCode(dto.getPostalCode());
        g.setIdCardNumber(dto.getIdCardNumber());
        g.setIdCardType(dto.getIdCardType());
        g.setVip(dto.getIsVip() != null && dto.getIsVip());
        g.setLoyaltyPoints(dto.getLoyaltyPoints() != null ? dto.getLoyaltyPoints() : 0);
        g.setNotes(dto.getNotes());
        return g;
    }

    public GuestDTO toDTO(Guest g) {
        if (g == null) return null;
        GuestDTO dto = new GuestDTO();
        dto.setId(g.getId());
        dto.setGuestNumber(g.getGuestNumber());
        dto.setFirstName(g.getFirstName());
        dto.setLastName(g.getLastName());
        dto.setEmail(g.getEmail());
        dto.setPhone(g.getPhone());
        dto.setAddress(g.getAddress());
        dto.setCity(g.getCity());
        dto.setCountry(g.getCountry());
        dto.setPostalCode(g.getPostalCode());
        dto.setIdCardNumber(g.getIdCardNumber());
        dto.setIdCardType(g.getIdCardType());
        dto.setIsVip(g.isVip());
        dto.setLoyaltyPoints(g.getLoyaltyPoints());
        dto.setNotes(g.getNotes());
        dto.setCreatedAt(g.getCreatedAt());
        return dto;
    }

    // ── Validation ────────────────────────────────────────────────────────────────

    private void validateGuest(GuestDTO dto) {
        if (dto.getFirstName() == null || dto.getFirstName().trim().isEmpty())
            throw new IllegalArgumentException("First name is required.");
        if (dto.getLastName() == null || dto.getLastName().trim().isEmpty())
            throw new IllegalArgumentException("Last name is required.");
    }
}