package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.ReservationRoomDTO;
import com.oceanview.dto.SearchCriteriaDTO;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/**
 * Business logic for Reservation operations.
 *
 * The reservations table now stores number_of_rooms (count) instead of room_id.
 * All actual room assignments live in the reservation_rooms junction table.
 */
public class ReservationService {

    private final ReservationDAO reservationDAO;
    private final RoomService    roomService;

    public ReservationService() {
        this.reservationDAO = ReservationDAOImpl.getInstance();
        this.roomService    = new RoomService();
    }

    // ─── Create ───────────────────────────────────────────────────────────────────

    /**
     * Creates a single reservation for one or more rooms.
     *
     * One reservation_number is generated.
     * One row is inserted in reservations with number_of_rooms = roomIds.size().
     * N rows are inserted in reservation_rooms (one per room).
     * The guest makes ONE payment for the combined total.
     *
     * @param dto     Reservation data (guest, dates, guests count, discount, etc.)
     * @param roomIds IDs of all rooms to book under this reservation
     * @return Fully populated ReservationDTO including all room details
     */
    public ReservationDTO createReservation(ReservationDTO dto, List<Long> roomIds)
            throws SQLException {

        // ── Validate inputs ──────────────────────────────────────────────────────
        if (dto.getGuestId() == null)
            throw new IllegalArgumentException("Guest is required.");
        if (roomIds == null || roomIds.isEmpty())
            throw new IllegalArgumentException("At least one room must be selected.");
        if (dto.getCheckInDate() == null || dto.getCheckOutDate() == null)
            throw new IllegalArgumentException("Check-in and check-out dates are required.");
        if (!dto.getCheckOutDate().isAfter(dto.getCheckInDate()))
            throw new IllegalArgumentException("Check-out date must be after check-in date.");

        // ── Prevent duplicate room IDs in selection ──────────────────────────────
        Set<Long> unique = new HashSet<>();
        for (Long roomId : roomIds) {
            if (!unique.add(roomId))
                throw new IllegalArgumentException(
                        "Duplicate room selected. Each room can only be added once.");
        }

        // ── Load and validate rooms ──────────────────────────────────────────────
        List<Room> rooms = new ArrayList<>();
        Map<Long, BigDecimal> roomPrices = new HashMap<>();

        for (Long roomId : roomIds) {
            Room room = roomService.getRoomById(roomId)
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Room ID " + roomId + " not found."));
            if (!room.isActive())
                throw new IllegalArgumentException(
                        "Room " + room.getRoomNumber() + " is not available for booking.");

            // Check for date conflicts in reservation_rooms
            List<Long> conflicts = reservationDAO.findConflictingReservationIds(
                    roomId, dto.getCheckInDate(), dto.getCheckOutDate(), null);
            if (!conflicts.isEmpty())
                throw new IllegalArgumentException(
                        "Room " + room.getRoomNumber() + " is already booked for the selected dates.");

            rooms.add(room);
            roomPrices.put(roomId, room.getBasePrice() != null ? room.getBasePrice() : BigDecimal.ZERO);
        }

        // ── Calculate pricing ────────────────────────────────────────────────────
        long nights = ChronoUnit.DAYS.between(dto.getCheckInDate(), dto.getCheckOutDate());
        if (nights <= 0) nights = 1;

        // Combined nightly rate = sum of all rooms' base prices
        BigDecimal combinedNightlyRate = rooms.stream()
                .map(r -> r.getBasePrice() != null ? r.getBasePrice() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal subtotal      = combinedNightlyRate.multiply(BigDecimal.valueOf(nights));
        BigDecimal discount      = dto.getDiscountAmount() != null ? dto.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal taxable       = subtotal.subtract(discount);
        BigDecimal taxRate       = rooms.get(0).getTaxRate() != null
                ? rooms.get(0).getTaxRate()
                : new BigDecimal("0.12");
        BigDecimal taxAmount     = taxable.multiply(taxRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal totalAmount   = taxable.add(taxAmount).setScale(2, RoundingMode.HALF_UP);

        // ── Build and save Reservation entity ────────────────────────────────────
        Reservation reservation = new Reservation();
        reservation.setGuestId(dto.getGuestId());
        reservation.setUserId(dto.getUserId());
        // number_of_rooms = count of selected rooms (NO room_id column)
        reservation.setNumberOfRooms(roomIds.size());
        reservation.setCheckInDate(dto.getCheckInDate());
        reservation.setCheckOutDate(dto.getCheckOutDate());
        reservation.setAdults(dto.getAdults() != null ? dto.getAdults() : 1);
        reservation.setChildren(dto.getChildren() != null ? dto.getChildren() : 0);
        reservation.setTotalNights((int) nights);
        reservation.setRoomPrice(combinedNightlyRate);              // combined nightly rate
        reservation.setDiscountAmount(discount);
        reservation.setSubtotal(subtotal);
        reservation.setTaxAmount(taxAmount);
        reservation.setTotalAmount(totalAmount);
        reservation.setSpecialRequests(dto.getSpecialRequests());
        reservation.setPaymentStatus(Reservation.PaymentStatus.PENDING);
        reservation.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);

        if (dto.getSource() != null && !dto.getSource().isEmpty()) {
            try {
                reservation.setSource(Reservation.ReservationSource.valueOf(dto.getSource()));
            } catch (IllegalArgumentException ignored) {
                reservation.setSource(Reservation.ReservationSource.WALK_IN);
            }
        }

        // Save ONE reservation row
        Reservation saved = reservationDAO.save(reservation);

        // Save ALL rooms into reservation_rooms junction table
        reservationDAO.saveReservationRooms(saved.getId(), roomIds, roomPrices);

        // Return fully populated DTO (with all room details)
        return reservationDAO.findDTOById(saved.getId())
                .orElseThrow(() -> new SQLException(
                        "Failed to reload reservation after save."));
    }

    /**
     * Convenience overload — single room booking.
     */
    public ReservationDTO createReservation(ReservationDTO dto) throws SQLException {
        List<Long> roomIds = new ArrayList<>();
        if (dto.getRoomIds() != null && !dto.getRoomIds().isEmpty()) {
            roomIds.addAll(dto.getRoomIds());
        }
        if (roomIds.isEmpty())
            throw new IllegalArgumentException("At least one room must be selected.");
        return createReservation(dto, roomIds);
    }

    // ─── Update ───────────────────────────────────────────────────────────────────

    /**
     * Updates an existing reservation with a new set of rooms.
     * Atomically replaces old room links with the new list.
     */
    public ReservationDTO updateReservation(ReservationDTO dto, List<Long> roomIds)
            throws SQLException {

        if (dto.getId() == null)
            throw new IllegalArgumentException("Reservation ID is required for update.");
        if (roomIds == null || roomIds.isEmpty())
            throw new IllegalArgumentException("At least one room must be selected.");
        if (!dto.getCheckOutDate().isAfter(dto.getCheckInDate()))
            throw new IllegalArgumentException("Check-out date must be after check-in date.");

        // Prevent duplicate room selections
        Set<Long> unique = new HashSet<>();
        for (Long roomId : roomIds) {
            if (!unique.add(roomId))
                throw new IllegalArgumentException(
                        "Duplicate room selected. Each room can only be added once.");
        }

        // Validate rooms and availability
        List<Room> rooms = new ArrayList<>();
        Map<Long, BigDecimal> roomPrices = new HashMap<>();

        for (Long roomId : roomIds) {
            Room room = roomService.getRoomById(roomId)
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Room ID " + roomId + " not found."));

            List<Long> conflicts = reservationDAO.findConflictingReservationIds(
                    roomId, dto.getCheckInDate(), dto.getCheckOutDate(), dto.getId());
            if (!conflicts.isEmpty())
                throw new IllegalArgumentException(
                        "Room " + room.getRoomNumber() + " is already booked for the selected dates.");

            rooms.add(room);
            roomPrices.put(roomId, room.getBasePrice() != null ? room.getBasePrice() : BigDecimal.ZERO);
        }

        // Recalculate pricing
        long nights = ChronoUnit.DAYS.between(dto.getCheckInDate(), dto.getCheckOutDate());
        if (nights <= 0) nights = 1;

        BigDecimal combinedNightlyRate = rooms.stream()
                .map(r -> r.getBasePrice() != null ? r.getBasePrice() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal subtotal    = combinedNightlyRate.multiply(BigDecimal.valueOf(nights));
        BigDecimal discount    = dto.getDiscountAmount() != null ? dto.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal taxable     = subtotal.subtract(discount);
        BigDecimal taxRate     = rooms.get(0).getTaxRate() != null
                ? rooms.get(0).getTaxRate()
                : new BigDecimal("0.12");
        BigDecimal taxAmount   = taxable.multiply(taxRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal totalAmount = taxable.add(taxAmount).setScale(2, RoundingMode.HALF_UP);

        // Load existing entity to preserve reservation_number etc.
        Reservation existing = reservationDAO.findById(dto.getId())
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));

        existing.setNumberOfRooms(roomIds.size());
        existing.setCheckInDate(dto.getCheckInDate());
        existing.setCheckOutDate(dto.getCheckOutDate());
        existing.setAdults(dto.getAdults() != null ? dto.getAdults() : 1);
        existing.setChildren(dto.getChildren() != null ? dto.getChildren() : 0);
        existing.setTotalNights((int) nights);
        existing.setRoomPrice(combinedNightlyRate);
        existing.setDiscountAmount(discount);
        existing.setSubtotal(subtotal);
        existing.setTaxAmount(taxAmount);
        existing.setTotalAmount(totalAmount);
        existing.setSpecialRequests(dto.getSpecialRequests());

        if (dto.getSource() != null && !dto.getSource().isEmpty()) {
            try {
                existing.setSource(Reservation.ReservationSource.valueOf(dto.getSource()));
            } catch (IllegalArgumentException ignored) {}
        }

        reservationDAO.update(existing);

        // Atomically replace room links
        reservationDAO.deleteReservationRooms(dto.getId());
        reservationDAO.saveReservationRooms(dto.getId(), roomIds, roomPrices);

        return reservationDAO.findDTOById(dto.getId())
                .orElseThrow(() -> new SQLException("Failed to reload reservation after update."));
    }

    /**
     * Convenience overload — reads roomIds from DTO.
     */
    public ReservationDTO updateReservation(ReservationDTO dto) throws SQLException {
        List<Long> roomIds = dto.getRoomIds();
        if (roomIds == null || roomIds.isEmpty())
            throw new IllegalArgumentException("At least one room must be selected.");
        return updateReservation(dto, roomIds);
    }

    // ─── Read ─────────────────────────────────────────────────────────────────────

    public Optional<ReservationDTO> getReservationById(Long id) throws SQLException {
        return reservationDAO.findDTOById(id);
    }

    public Optional<ReservationDTO> getReservationByNumber(String number) throws SQLException {
        return reservationDAO.findDTOByNumber(number);
    }

    public List<ReservationDTO> getReservations(int page, int size) throws SQLException {
        return reservationDAO.findAllDTOs(page, size);
    }

    public long getTotalReservationsCount() throws SQLException {
        return reservationDAO.count();
    }

    public List<ReservationDTO> getReservationsByGuest(Long guestId) throws SQLException {
        return reservationDAO.findByGuestId(guestId);
    }

    public List<ReservationDTO> getReservationsByRoom(Long roomId) throws SQLException {
        return reservationDAO.findByRoomId(roomId);
    }

    public List<ReservationDTO> getReservationsByDateRange(LocalDate start, LocalDate end)
            throws SQLException {
        return reservationDAO.findByDateRange(start, end);
    }

    /**
     * Search reservations based on criteria
     * @param criteria The search criteria DTO
     * @return List of matching ReservationDTOs
     */
    /**
     * Search reservations based on criteria
     * @param criteria The search criteria DTO
     * @return List of matching ReservationDTOs
     */
    public List<ReservationDTO> searchReservations(SearchCriteriaDTO criteria) throws SQLException {
        String searchValue = criteria.getSearchValue();

        // If search value is empty or null, return empty list
        if (searchValue == null || searchValue.trim().isEmpty()) {
            return new ArrayList<>();
        }

        // Pass all parameters to the DAO which will handle the search
        return reservationDAO.searchDTOs(
                searchValue,
                criteria.getStatus(),
                criteria.getPaymentStatus(),
                criteria.getCheckInDate(),
                criteria.getCheckOutDate()
        );
    }

    // ─── New methods for dashboard ─────────────────────────────────────────────────

    /**
     * Get count of active reservations (CONFIRMED and CHECKED_IN)
     */
    public long getActiveReservationsCount() throws SQLException {
        return reservationDAO.countActiveReservations();
    }

    /**
     * Get today's check-ins count
     */
    public int getTodaysCheckInsCount() throws SQLException {
        return reservationDAO.countCheckInsByDate(LocalDate.now());
    }

    /**
     * Get today's check-outs count
     */
    public int getTodaysCheckOutsCount() throws SQLException {
        return reservationDAO.countCheckOutsByDate(LocalDate.now());
    }

    // Add these methods to your ReservationService.java

    /**
     * Get reservations by check-in date
     */
    /**
     * Get reservations by check-in date
     */
    public List<ReservationDTO> getReservationsByCheckInDate(LocalDate date) throws SQLException {
        if (date == null) {
            throw new IllegalArgumentException("Date cannot be null");
        }
        return reservationDAO.findByCheckInDate(date);
    }

    /**
     * Get reservations by check-out date
     */
    public List<ReservationDTO> getReservationsByCheckOutDate(LocalDate date) throws SQLException {
        return reservationDAO.findByCheckOutDate(date);
    }
    /**
     * Marks a reservation's payment_status as PAID.
     * Called after a successful payment is recorded during checkout.
     */
    public void markReservationAsPaid(Long reservationId) throws SQLException {
        Reservation r = reservationDAO.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));
        r.setPaymentStatus(Reservation.PaymentStatus.PAID);
        reservationDAO.update(r);
    }

    /**
     * Get current month's revenue
     */
    public double getCurrentMonthRevenue() throws SQLException {
        LocalDate now = LocalDate.now();
        return reservationDAO.getTotalRevenueByMonth(now.getYear(), now.getMonthValue());
    }

    // ─── Status changes ───────────────────────────────────────────────────────────

    public void checkIn(Long reservationId) throws SQLException {
        Reservation r = reservationDAO.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));
        if (r.getReservationStatus() != Reservation.ReservationStatus.CONFIRMED)
            throw new IllegalArgumentException(
                    "Only CONFIRMED reservations can be checked in.");
        r.setReservationStatus(Reservation.ReservationStatus.CHECKED_IN);
        reservationDAO.update(r);
    }

    public void checkOut(Long reservationId) throws SQLException {
        Reservation r = reservationDAO.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));
        if (r.getReservationStatus() != Reservation.ReservationStatus.CHECKED_IN)
            throw new IllegalArgumentException(
                    "Only CHECKED_IN reservations can be checked out.");
        r.setReservationStatus(Reservation.ReservationStatus.CHECKED_OUT);
        reservationDAO.update(r);
    }

    public void cancelReservation(Long reservationId) throws SQLException {
        Reservation r = reservationDAO.findById(reservationId)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));
        if (r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_OUT)
            throw new IllegalArgumentException("Cannot cancel a checked-out reservation.");
        r.setReservationStatus(Reservation.ReservationStatus.CANCELLED);
        reservationDAO.update(r);
    }

    public boolean deleteReservation(Long id) throws SQLException {
        return reservationDAO.delete(id);
    }

    // ─── Dashboard stats ──────────────────────────────────────────────────────────

    public int getOccupiedRoomsCount(LocalDate date) throws SQLException {
        return reservationDAO.countOccupiedRoomsByDate(date);
    }

    public int getTodayCheckInsCount() throws SQLException {
        return reservationDAO.countCheckInsByDate(LocalDate.now());
    }

    public int getTodayCheckOutsCount() throws SQLException {
        return reservationDAO.countCheckOutsByDate(LocalDate.now());
    }

    public double getMonthlyRevenue(int year, int month) throws SQLException {
        return reservationDAO.getTotalRevenueByMonth(year, month);
    }

    public List<ReservationDTO> getRecentReservations(int limit) throws SQLException {
        return reservationDAO.findRecentDTOs(limit);
    }
}