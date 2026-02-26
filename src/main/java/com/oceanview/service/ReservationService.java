package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.model.Reservation;
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

    public Reservation createReservation(Reservation reservation) throws SQLException, IllegalArgumentException {
        // Validate
        if (reservation.getGuestId() == null) {
            throw new IllegalArgumentException("Guest ID is required");
        }
        if (reservation.getRoomId() == null) {
            throw new IllegalArgumentException("Room ID is required");
        }
        if (reservation.getCheckInDate() == null || reservation.getCheckOutDate() == null) {
            throw new IllegalArgumentException("Check-in and check-out dates are required");
        }
        if (reservation.getCheckOutDate().isBefore(reservation.getCheckInDate())) {
            throw new IllegalArgumentException("Check-out date must be after check-in date");
        }

        // Generate reservation number
        if (reservation.getReservationNumber() == null || reservation.getReservationNumber().trim().isEmpty()) {
            reservation.setReservationNumber(generateReservationNumber());
        }

        // Calculate totals
        reservation.calculateTotals();

        return reservationDAO.save(reservation);
    }

    public Optional<Reservation> getReservationById(Long id) throws SQLException {
        return reservationDAO.findById(id);
    }

    public Optional<Reservation> getReservationByNumber(String reservationNumber) throws SQLException {
        return reservationDAO.findByReservationNumber(reservationNumber);
    }

    public List<Reservation> getReservationsByGuest(Long guestId) throws SQLException {
        return reservationDAO.findByGuestId(guestId);
    }

    public List<Reservation> getReservationsByRoom(Long roomId) throws SQLException {
        return reservationDAO.findByRoomId(roomId);
    }

    public List<Reservation> getAllReservations() throws SQLException {
        return reservationDAO.findAll();
    }

    public List<Reservation> getActiveReservations() throws SQLException {
        return reservationDAO.findActiveReservations();
    }

    public List<Reservation> getReservationsByDateRange(LocalDate start, LocalDate end) throws SQLException {
        return reservationDAO.findByDateRange(start, end);
    }

    public List<Reservation> getCheckInsByDate(LocalDate date) throws SQLException {
        return reservationDAO.findCheckInsByDate(date);
    }

    public List<Reservation> getCheckOutsByDate(LocalDate date) throws SQLException {
        return reservationDAO.findCheckOutsByDate(date);
    }

    public Reservation updateReservation(Reservation reservation) throws SQLException, IllegalArgumentException {
        if (reservation.getId() == null) {
            throw new IllegalArgumentException("Reservation ID is required for update");
        }

        // Recalculate totals
        reservation.calculateTotals();

        return reservationDAO.update(reservation);
    }

    public Reservation updateStatus(Long id, Reservation.ReservationStatus status)
            throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();
        reservation.setReservationStatus(status);

        return reservationDAO.update(reservation);
    }

    public Reservation updatePaymentStatus(Long id, Reservation.PaymentStatus status)
            throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();
        reservation.setPaymentStatus(status);

        return reservationDAO.update(reservation);
    }

    public Reservation checkIn(Long id) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(id);

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

    public Reservation checkOut(Long id) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(id);

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

    public Reservation cancelReservation(Long id, String reason) throws SQLException, IllegalArgumentException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(id);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();
        reservation.setReservationStatus(Reservation.ReservationStatus.CANCELLED);

        if (reason != null && !reason.trim().isEmpty()) {
            reservation.setSpecialRequests((reservation.getSpecialRequests() != null ?
                    reservation.getSpecialRequests() + " | " : "") + "Cancelled: " + reason);
        }

        return reservationDAO.update(reservation);
    }

    public int countOccupiedRoomsByDate(LocalDate date) throws SQLException {
        return reservationDAO.countOccupiedRoomsByDate(date);
    }

    private String generateReservationNumber() {
        return "RES-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}