package com.oceanview.dao;

import com.oceanview.model.Reservation;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ReservationDAO extends BaseDAO<Reservation, Long> {
    Optional<Reservation> findByReservationNumber(String reservationNumber) throws SQLException;
    List<Reservation> findByGuestId(Long guestId) throws SQLException;
    List<Reservation> findByRoomId(Long roomId) throws SQLException;
    List<Reservation> findByDateRange(LocalDate startDate, LocalDate endDate) throws SQLException;
    List<Reservation> findByStatus(Reservation.ReservationStatus status) throws SQLException;
    List<Reservation> findByPaymentStatus(Reservation.PaymentStatus status) throws SQLException;
    List<Reservation> findActiveReservations() throws SQLException;
    List<Reservation> findCheckInsByDate(LocalDate date) throws SQLException;
    List<Reservation> findCheckOutsByDate(LocalDate date) throws SQLException;
    int countOccupiedRoomsByDate(LocalDate date) throws SQLException;
    boolean updateStatus(Long id, Reservation.ReservationStatus status) throws SQLException;
    boolean updatePaymentStatus(Long id, Reservation.PaymentStatus status) throws SQLException;
}