package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.model.Reservation;
import com.oceanview.model.Guest;
import com.oceanview.model.Room;
import com.oceanview.util.ValidationUtils;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class ReservationService {

    private final ReservationDAO reservationDAO;

    public ReservationService() {
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public ReservationService(ReservationDAO reservationDAO) {
        this.reservationDAO = reservationDAO;
    }

    // Create new reservation
    public Reservation createReservation(Reservation reservation) throws SQLException, IllegalArgumentException {
        // Validate reservation data
        validateReservation(reservation);

        // Generate reservation number if not provided
        if (reservation.getReservationNumber() == null || reservation.getReservationNumber().trim().isEmpty()) {
            reservation.setReservationNumber(generateReservationNumber());
        }

        // Calculate total nights and amounts
        reservation.setTotalNights(reservation.getTotalNights());
        reservation.calculateTotals();

        return reservationDAO.save(reservation);
    }

    // Get reservation by ID
    public Optional<Reservation> getReservationById(Long id) throws SQLException {
        if (id == null) {
            return Optional.empty();
        }
        return reservationDAO.findById(id);
    }

    // Get reservation by number
    public Optional<Reservation> getReservationByNumber(String reservationNumber) throws SQLException {
        if (reservationNumber == null || reservationNumber.trim().isEmpty()) {
            return Optional.empty();
        }
        return reservationDAO.findByReservationNumber(reservationNumber);
    }

    // Get all reservations
    public List<Reservation> getAllReservations() throws SQLException {
        return reservationDAO.findAll();
    }

    // Get reservations with pagination
    public List<Reservation> getReservations(int page, int size) throws SQLException {
        return reservationDAO.findAll(page, size);
    }

    // Get reservations by guest
    public List<Reservation> getReservationsByGuest(Long guestId) throws SQLException {
        return reservationDAO.findByGuestId(guestId);
    }

    // Get reservations by room
    public List<Reservation> getReservationsByRoom(Long roomId) throws SQLException {
        return reservationDAO.findByRoomId(roomId);
    }

    // Get reservations by date range
    public List<Reservation> getReservationsByDateRange(LocalDate startDate, LocalDate endDate) throws SQLException {
        return reservationDAO.findByDateRange(startDate, endDate);
    }

    // Get reservations by status
    public List<Reservation> getReservationsByStatus(Reservation.ReservationStatus status) throws SQLException {
        return reservationDAO.findByStatus(status);
    }

    // Get active reservations
    public List<Reservation> getActiveReservations() throws SQLException {
        return reservationDAO.findActiveReservations();
    }

    // Get today's check-ins
    public List<Reservation> getTodaysCheckIns() throws SQLException {
        return reservationDAO.findCheckInsByDate(LocalDate.now());
    }

    // Get today's check-outs
    public List<Reservation> getTodaysCheckOuts() throws SQLException {
        return reservationDAO.findCheckOutsByDate(LocalDate.now());
    }

    // Get recent reservations (for dashboard)
    public List<Reservation> getRecentReservations(int limit) throws SQLException {
        return reservationDAO.findAll(1, limit);
    }

    // Update reservation
    public Reservation updateReservation(Reservation reservation) throws SQLException, IllegalArgumentException {
        if (reservation.getId() == null) {
            throw new IllegalArgumentException("Reservation ID is required for update");
        }

        // Check if reservation exists
        if (!reservationDAO.exists(reservation.getId())) {
            throw new IllegalArgumentException("Reservation not found with ID: " + reservation.getId());
        }

        // Recalculate totals
        reservation.calculateTotals();

        return reservationDAO.update(reservation);
    }

    // Update reservation status
    public Reservation updateReservationStatus(Long id, Reservation.ReservationStatus status)
            throws SQLException, IllegalArgumentException {

        Optional<Reservation> reservationOpt = getReservationById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();
        reservation.setReservationStatus(status);

        return reservationDAO.update(reservation);
    }

    // Update payment status
    public Reservation updatePaymentStatus(Long id, Reservation.PaymentStatus status)
            throws SQLException, IllegalArgumentException {

        Optional<Reservation> reservationOpt = getReservationById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();
        reservation.setPaymentStatus(status);

        return reservationDAO.update(reservation);
    }

    // Check-in guest
    public Reservation checkIn(Long id) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = getReservationById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();

        if (reservation.getReservationStatus() != Reservation.ReservationStatus.CONFIRMED) {
            throw new IllegalArgumentException("Only confirmed reservations can be checked in");
        }

        reservation.setReservationStatus(Reservation.ReservationStatus.CHECKED_IN);

        return reservationDAO.update(reservation);
    }

    // Check-out guest
    public Reservation checkOut(Long id) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = getReservationById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();

        if (reservation.getReservationStatus() != Reservation.ReservationStatus.CHECKED_IN) {
            throw new IllegalArgumentException("Only checked-in reservations can be checked out");
        }

        reservation.setReservationStatus(Reservation.ReservationStatus.CHECKED_OUT);

        return reservationDAO.update(reservation);
    }

    // Cancel reservation
    public Reservation cancelReservation(Long id) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = getReservationById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();

        if (reservation.getReservationStatus() == Reservation.ReservationStatus.CHECKED_OUT ||
                reservation.getReservationStatus() == Reservation.ReservationStatus.CANCELLED) {
            throw new IllegalArgumentException("Cannot cancel checked-out or already cancelled reservation");
        }

        reservation.setReservationStatus(Reservation.ReservationStatus.CANCELLED);

        return reservationDAO.update(reservation);
    }

    // Delete reservation
    public boolean deleteReservation(Long id) throws SQLException {
        return reservationDAO.delete(id);
    }

    // Count methods for dashboard
    public int getActiveReservationsCount() throws SQLException {
        return reservationDAO.findActiveReservations().size();
    }

    public long getTotalReservationsCount() throws SQLException {
        return reservationDAO.count();
    }

    public int getTodaysCheckInsCount() throws SQLException {
        return reservationDAO.findCheckInsByDate(LocalDate.now()).size();
    }

    public int getTodaysCheckOutsCount() throws SQLException {
        return reservationDAO.findCheckOutsByDate(LocalDate.now()).size();
    }

    // Revenue methods
    public double getCurrentMonthRevenue() throws SQLException {
        LocalDate now = LocalDate.now();
        LocalDate startOfMonth = now.withDayOfMonth(1);
        LocalDate endOfMonth = now.withDayOfMonth(now.lengthOfMonth());

        List<Reservation> reservations = reservationDAO.findByDateRange(startOfMonth, endOfMonth);
        return calculateTotalRevenue(reservations);
    }

    public double getMonthlyRevenue(int month, int year) throws SQLException {
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        List<Reservation> reservations = reservationDAO.findByDateRange(startDate, endDate);
        return calculateTotalRevenue(reservations);
    }

    public double getYearlyRevenue(int year) throws SQLException {
        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);

        List<Reservation> reservations = reservationDAO.findByDateRange(startDate, endDate);
        return calculateTotalRevenue(reservations);
    }

    public double getTotalRevenue() throws SQLException {
        List<Reservation> reservations = reservationDAO.findAll();
        return calculateTotalRevenue(reservations);
    }

    // Guest count (you'll need to implement this in GuestDAO)
    public int getTotalGuestsCount() throws SQLException {
        // This should be implemented in GuestDAO
        // For now, return a placeholder
        return 0;
    }

    // Occupancy rate calculation
    public double getOccupancyRate(LocalDate date, long totalRooms) throws SQLException {
        if (totalRooms == 0) return 0.0;

        int occupiedRooms = reservationDAO.countOccupiedRoomsByDate(date);
        return (double) occupiedRooms / totalRooms * 100;
    }

    // Helper method to calculate total revenue from reservations
    private double calculateTotalRevenue(List<Reservation> reservations) {
        return reservations.stream()
                .filter(r -> r.getPaymentStatus() == Reservation.PaymentStatus.PAID)
                .mapToDouble(r -> r.getTotalAmount().doubleValue())
                .sum();
    }

    // Generate unique reservation number
    private String generateReservationNumber() {
        return "RES-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    // Validate reservation data
    private void validateReservation(Reservation reservation) throws IllegalArgumentException {
        if (reservation.getGuestId() == null) {
            throw new IllegalArgumentException("Guest ID is required");
        }

        if (reservation.getRoomId() == null) {
            throw new IllegalArgumentException("Room ID is required");
        }

        if (reservation.getCheckInDate() == null) {
            throw new IllegalArgumentException("Check-in date is required");
        }

        if (reservation.getCheckOutDate() == null) {
            throw new IllegalArgumentException("Check-out date is required");
        }

        if (reservation.getCheckOutDate().isBefore(reservation.getCheckInDate())) {
            throw new IllegalArgumentException("Check-out date must be after check-in date");
        }

        if (reservation.getCheckInDate().isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("Check-in date cannot be in the past");
        }

        if (reservation.getAdults() == null || reservation.getAdults() <= 0) {
            throw new IllegalArgumentException("At least one adult is required");
        }

        if (reservation.getChildren() == null) {
            reservation.setChildren(0);
        }
    }

    // Check if room is available for given dates
    public boolean isRoomAvailable(Long roomId, LocalDate checkIn, LocalDate checkOut) throws SQLException {
        List<Reservation> existingReservations = reservationDAO.findByRoomId(roomId);

        for (Reservation res : existingReservations) {
            if (res.getReservationStatus() == Reservation.ReservationStatus.CONFIRMED ||
                    res.getReservationStatus() == Reservation.ReservationStatus.CHECKED_IN) {

                // Check for date overlap
                if (!(checkOut.isBefore(res.getCheckInDate()) || checkIn.isAfter(res.getCheckOutDate()))) {
                    return false;
                }
            }
        }

        return true;
    }

    // Get available rooms for date range
    public List<Room> getAvailableRooms(LocalDate checkIn, LocalDate checkOut) throws SQLException {
        // This would require RoomService integration
        // For now, return empty list
        return List.of();
    }
}