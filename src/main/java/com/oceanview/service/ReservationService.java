package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dao.impl.RoomDAOImpl;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.SearchCriteriaDTO;
import com.oceanview.mapper.ReservationMapper;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class ReservationService {

    private final ReservationDAO reservationDAO;
    private final RoomDAO roomDAO;
    private final ReservationMapper mapper;

    public ReservationService() {
        this.reservationDAO = ReservationDAOImpl.getInstance();
        this.roomDAO = RoomDAOImpl.getInstance();
        this.mapper = ReservationMapper.getInstance();
    }

    public ReservationService(ReservationDAO reservationDAO, RoomDAO roomDAO) {
        this.reservationDAO = reservationDAO;
        this.roomDAO = roomDAO;
        this.mapper = ReservationMapper.getInstance();
    }

    // ─── Create ─────────────────────────────────────────────────────

    /**
     * Creates a reservation.
     * Calculates pricing automatically from the room's base price.
     */
    public ReservationDTO createReservation(ReservationDTO dto)
            throws SQLException, IllegalArgumentException {

        // 1. Validate required fields
        if (dto.getGuestId() == null)    throw new IllegalArgumentException("Guest is required.");
        if (dto.getRoomId() == null)     throw new IllegalArgumentException("Room is required.");
        if (dto.getCheckInDate() == null) throw new IllegalArgumentException("Check-in date is required.");
        if (dto.getCheckOutDate() == null) throw new IllegalArgumentException("Check-out date is required.");
        if (!dto.getCheckOutDate().isAfter(dto.getCheckInDate()))
            throw new IllegalArgumentException("Check-out must be after check-in.");

        // 2. Load room to get price
        Room room = roomDAO.findById(dto.getRoomId())
                .orElseThrow(() -> new IllegalArgumentException("Room not found."));

        if (!room.isActive()) throw new IllegalArgumentException("Selected room is not available.");

        // 3. Calculate pricing
        int nights = (int) ChronoUnit.DAYS.between(dto.getCheckInDate(), dto.getCheckOutDate());
        if (nights <= 0) {
            throw new IllegalArgumentException("Invalid number of nights.");
        }

        BigDecimal roomPrice = room.getBasePrice();
        BigDecimal roomCharges = roomPrice.multiply(BigDecimal.valueOf(nights));
        BigDecimal discount = dto.getDiscountAmount() != null ? dto.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal taxRate = room.getTaxRate() != null ? room.getTaxRate().divide(new BigDecimal("100")) : new BigDecimal("0.12");
        BigDecimal taxable = roomCharges.subtract(discount);
        BigDecimal tax = taxable.multiply(taxRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = taxable.add(tax);

        // 4. Build entity
        Reservation r = new Reservation();
        r.setReservationNumber(generateReservationNumber());
        r.setGuestId(dto.getGuestId());
        r.setUserId(dto.getUserId());
        r.setRoomId(dto.getRoomId());
        r.setCheckInDate(dto.getCheckInDate());
        r.setCheckOutDate(dto.getCheckOutDate());
        r.setAdults(dto.getAdults() != null ? dto.getAdults() : 1);
        r.setChildren(dto.getChildren() != null ? dto.getChildren() : 0);
        r.setTotalNights(nights);
        r.setRoomPrice(roomPrice);
        r.setTaxAmount(tax);
        r.setDiscountAmount(discount);
        r.setSubtotal(roomCharges);
        r.setTotalAmount(total);
        r.setSpecialRequests(dto.getSpecialRequests());
        r.setPaymentStatus(Reservation.PaymentStatus.PENDING);
        r.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);
        r.setSource(dto.getSource() != null
                ? safeSource(dto.getSource()) : Reservation.ReservationSource.WALK_IN);
        r.setCreatedAt(LocalDateTime.now());
        r.setUpdatedAt(LocalDateTime.now());

        Reservation saved = reservationDAO.save(r);
        System.out.println("Reservation saved with ID: " + saved.getId()); // Debug log

        // Return full DTO with guest+room names via JOIN
        return reservationDAO.findDTOById(saved.getId()).orElse(mapper.toDTO(saved));
    }

    public double getMonthlyRevenue(int month, int year) throws SQLException {
        return reservationDAO.getTotalRevenueByMonth(year, month);
    }

    // ─── Update ─────────────────────────────────────────────────────

    public ReservationDTO updateReservation(ReservationDTO dto)
            throws SQLException, IllegalArgumentException {

        if (dto.getId() == null) throw new IllegalArgumentException("Reservation ID required.");

        Reservation existing = reservationDAO.findById(dto.getId())
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found."));

        // Recalculate if dates/room changed
        Long roomId = dto.getRoomId() != null ? dto.getRoomId() : existing.getRoomId();
        LocalDate ci = dto.getCheckInDate() != null ? dto.getCheckInDate() : existing.getCheckInDate();
        LocalDate co = dto.getCheckOutDate() != null ? dto.getCheckOutDate() : existing.getCheckOutDate();

        Room room = roomDAO.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found."));

        int nights = (int) ChronoUnit.DAYS.between(ci, co);
        if (nights <= 0) {
            throw new IllegalArgumentException("Check-out date must be after check-in date.");
        }

        BigDecimal roomPrice = room.getBasePrice();
        BigDecimal roomCharges = roomPrice.multiply(BigDecimal.valueOf(nights));
        BigDecimal discount = dto.getDiscountAmount() != null ? dto.getDiscountAmount() : existing.getDiscountAmount();
        if (discount == null) discount = BigDecimal.ZERO;

        BigDecimal taxRate = room.getTaxRate() != null ? room.getTaxRate().divide(new BigDecimal("100")) : new BigDecimal("0.12");
        BigDecimal taxable = roomCharges.subtract(discount);
        BigDecimal tax = taxable.multiply(taxRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = taxable.add(tax);

        existing.setRoomId(roomId);
        existing.setCheckInDate(ci);
        existing.setCheckOutDate(co);
        existing.setAdults(dto.getAdults() != null ? dto.getAdults() : existing.getAdults());
        existing.setChildren(dto.getChildren() != null ? dto.getChildren() : existing.getChildren());
        existing.setTotalNights(nights);
        existing.setRoomPrice(roomPrice);
        existing.setTaxAmount(tax);
        existing.setDiscountAmount(discount);
        existing.setSubtotal(roomCharges);
        existing.setTotalAmount(total);
        existing.setSpecialRequests(dto.getSpecialRequests() != null
                ? dto.getSpecialRequests() : existing.getSpecialRequests());
        if (dto.getSource() != null) existing.setSource(safeSource(dto.getSource()));
        existing.setUpdatedAt(LocalDateTime.now());

        reservationDAO.update(existing);
        return reservationDAO.findDTOById(existing.getId()).orElse(mapper.toDTO(existing));
    }

    // ─── Delete ─────────────────────────────────────────────────────

    public boolean deleteReservation(Long id) throws SQLException {
        return reservationDAO.delete(id);
    }

    // ─── Read ───────────────────────────────────────────────────────

    public Optional<ReservationDTO> getReservationById(Long id) throws SQLException {
        return reservationDAO.findDTOById(id);
    }

    public Optional<ReservationDTO> getReservationByNumber(String number) throws SQLException {
        return reservationDAO.findDTOByNumber(number);
    }

    public List<ReservationDTO> getReservations(int page, int size) throws SQLException {
        return reservationDAO.findAllDTOs(page, size);
    }

    public List<ReservationDTO> getRecentReservations(int limit) throws SQLException {
        return reservationDAO.findRecentDTOs(limit);
    }

    public List<ReservationDTO> searchReservations(SearchCriteriaDTO criteria) throws SQLException {
        return reservationDAO.searchDTOs(
                criteria.getSearchValue(),
                criteria.getStatus(),
                criteria.getPaymentStatus(),
                criteria.getCheckInDate(),
                criteria.getCheckOutDate());
    }

    // ─── Status changes ─────────────────────────────────────────────

    public void checkIn(Long id) throws SQLException, IllegalArgumentException {
        Reservation r = requireReservation(id);
        if (r.getReservationStatus() != Reservation.ReservationStatus.CONFIRMED)
            throw new IllegalArgumentException("Only CONFIRMED reservations can be checked in.");
        r.setReservationStatus(Reservation.ReservationStatus.CHECKED_IN);
        r.setUpdatedAt(LocalDateTime.now());
        reservationDAO.update(r);
    }

    public void checkOut(Long id) throws SQLException, IllegalArgumentException {
        Reservation r = requireReservation(id);
        if (r.getReservationStatus() != Reservation.ReservationStatus.CHECKED_IN)
            throw new IllegalArgumentException("Guest must be checked in before checking out.");
        r.setReservationStatus(Reservation.ReservationStatus.CHECKED_OUT);
        r.setUpdatedAt(LocalDateTime.now());
        reservationDAO.update(r);
    }

    public void cancelReservation(Long id) throws SQLException, IllegalArgumentException {
        Reservation r = requireReservation(id);
        if (r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_IN
                || r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_OUT)
            throw new IllegalArgumentException("Cannot cancel a reservation that is already checked in/out.");
        r.setReservationStatus(Reservation.ReservationStatus.CANCELLED);
        r.setUpdatedAt(LocalDateTime.now());
        reservationDAO.update(r);
    }

    // ─── Dashboard stats ────────────────────────────────────────────

    public long getTotalReservationsCount() throws SQLException {
        return reservationDAO.count();
    }

    public long getActiveReservationsCount() throws SQLException {
        return reservationDAO.findActiveReservations().size();
    }

    public int getTodaysCheckInsCount() throws SQLException {
        return reservationDAO.countCheckInsByDate(LocalDate.now());
    }

    public int getTodaysCheckOutsCount() throws SQLException {
        return reservationDAO.countCheckOutsByDate(LocalDate.now());
    }

    public List<ReservationDTO> getReservationsByGuestId(Long guestId) throws SQLException {
        return reservationDAO.findByGuestId(guestId);
    }

    public double getCurrentMonthRevenue() throws SQLException {
        YearMonth ym = YearMonth.now();
        return reservationDAO.getTotalRevenueByMonth(ym.getYear(), ym.getMonthValue());
    }

    // ─── Private helpers ────────────────────────────────────────────

    private Reservation requireReservation(Long id) throws SQLException {
        return reservationDAO.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found: " + id));
    }

    private String generateReservationNumber() {
        return "RES-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private Reservation.ReservationSource safeSource(String s) {
        try { return Reservation.ReservationSource.valueOf(s); }
        catch (Exception e) { return Reservation.ReservationSource.WALK_IN; }
    }
}