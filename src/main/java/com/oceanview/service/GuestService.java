package com.oceanview.service;

import com.oceanview.dao.GuestDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.GuestDAOImpl;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dto.GuestDTO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.mapper.GuestMapper;
import com.oceanview.model.Guest;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class GuestService {

    private final GuestDAO guestDAO;
    private final GuestMapper guestMapper;
    private ReservationDAO reservationDAO;

    public GuestService() {
        this.guestDAO = GuestDAOImpl.getInstance();
        this.guestMapper = GuestMapper.getInstance();
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public GuestService(GuestDAO guestDAO) {
        this.guestDAO = guestDAO;
        this.guestMapper = GuestMapper.getInstance();
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public boolean deleteGuest(Long id) throws SQLException {
        // Check if guest has any reservations
        List<ReservationDTO> reservations = reservationDAO.findByGuestId(id);

        // Only allow deletion if no active reservations
        boolean hasActiveReservations = reservations.stream()
                .anyMatch(r -> !"CANCELLED".equals(r.getReservationStatus()) &&
                        !"CHECKED_OUT".equals(r.getReservationStatus()));

        if (hasActiveReservations) {
            throw new SQLException("Cannot delete guest with active reservations");
        }

        return guestDAO.delete(id);
    }

    public GuestDTO createGuest(GuestDTO guestDTO) throws SQLException, IllegalArgumentException {
        // Only check uniqueness when the field is actually provided
        String email = guestDTO.getEmail();
        if (email != null && !email.trim().isEmpty()) {
            Optional<Guest> existingGuest = guestDAO.findByEmail(email.trim());
            if (existingGuest.isPresent()) {
                throw new IllegalArgumentException(
                        "A guest with email '" + email.trim() + "' already exists. " +
                                "Please search for the existing guest instead.");
            }
        }
        String phone = guestDTO.getPhone();
        if (phone != null && !phone.trim().isEmpty()) {
            Optional<Guest> existingGuest = guestDAO.findByPhone(phone.trim());
            if (existingGuest.isPresent()) {
                throw new IllegalArgumentException(
                        "A guest with phone '" + phone.trim() + "' already exists. " +
                                "Please search for the existing guest instead.");
            }
        }

        Guest guest = guestMapper.toEntity(guestDTO);

        // Generate guest number if not provided
        if (guest.getGuestNumber() == null || guest.getGuestNumber().trim().isEmpty()) {
            guest.setGuestNumber(generateGuestNumber());
        }

        // New guests start as non-VIP
        guest.setVip(false);
        if (guest.getLoyaltyPoints() == null) {
            guest.setLoyaltyPoints(0);
        }

        Guest savedGuest = guestDAO.save(guest);
        return guestMapper.toDTO(savedGuest);
    }

    public GuestDTO updateGuest(GuestDTO guestDTO) throws SQLException, IllegalArgumentException {
        if (guestDTO.getId() == null) {
            throw new IllegalArgumentException("Guest ID is required for update");
        }

        Optional<Guest> existingOpt = guestDAO.findById(guestDTO.getId());
        if (!existingOpt.isPresent()) {
            throw new IllegalArgumentException("Guest not found with ID: " + guestDTO.getId());
        }

        Guest existing = existingOpt.get();

        // Check email uniqueness if changed
        if (guestDTO.getEmail() != null && !guestDTO.getEmail().equals(existing.getEmail())) {
            Optional<Guest> emailCheck = guestDAO.findByEmail(guestDTO.getEmail());
            if (emailCheck.isPresent() && !emailCheck.get().getId().equals(guestDTO.getId())) {
                throw new IllegalArgumentException("Email already in use by another guest");
            }
        }

        // Check phone uniqueness if changed
        if (guestDTO.getPhone() != null && !guestDTO.getPhone().equals(existing.getPhone())) {
            Optional<Guest> phoneCheck = guestDAO.findByPhone(guestDTO.getPhone());
            if (phoneCheck.isPresent() && !phoneCheck.get().getId().equals(guestDTO.getId())) {
                throw new IllegalArgumentException("Phone number already in use by another guest");
            }
        }

        Guest guest = guestMapper.toEntity(guestDTO);
        Guest updatedGuest = guestDAO.update(guest);
        return guestMapper.toDTO(updatedGuest);
    }

    public Optional<GuestDTO> getGuestById(Long id) throws SQLException {
        return guestDAO.findById(id).map(guestMapper::toDTO);
    }

    public Optional<GuestDTO> getGuestByEmail(String email) throws SQLException {
        return guestDAO.findByEmail(email).map(guestMapper::toDTO);
    }

    public Optional<GuestDTO> getGuestByPhone(String phone) throws SQLException {
        return guestDAO.findByPhone(phone).map(guestMapper::toDTO);
    }

    public Optional<GuestDTO> getGuestByNumber(String guestNumber) throws SQLException {
        return guestDAO.findByGuestNumber(guestNumber).map(guestMapper::toDTO);
    }

    public List<GuestDTO> searchGuests(String keyword) throws SQLException {
        if (keyword == null || keyword.trim().isEmpty()) {
            return guestMapper.toDTOList(guestDAO.findAll());
        }
        return guestMapper.toDTOList(guestDAO.searchGuests(keyword));
    }

    public List<GuestDTO> getAllGuests() throws SQLException {
        return guestMapper.toDTOList(guestDAO.findAll());
    }

    public List<GuestDTO> getGuests(int page, int size) throws SQLException {
        return guestMapper.toDTOList(guestDAO.findAll(page, size));
    }

    public List<GuestDTO> getRecentGuests(int limit) throws SQLException {
        return guestMapper.toDTOList(guestDAO.findRecentGuests(limit));
    }

    public long getActiveGuestsCount() throws SQLException {
        return guestDAO.count(); // Count all guests since they're all active
    }

    private String generateGuestNumber() {
        return "GST-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}