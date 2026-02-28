package com.oceanview.dao;

import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.Reservation;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * ReservationDAO — data access interface for Reservation.
 *
 * Methods returning ReservationDTO (not Reservation) perform JOIN queries
 * to include guest name and room number in a single database round-trip.
 */
public interface ReservationDAO extends BaseDAO<Reservation, Long> {

    // ── Single record lookups ────────────────────────────────────────
    Optional<ReservationDTO> findDTOById(Long id) throws SQLException;
    Optional<ReservationDTO> findDTOByNumber(String reservationNumber) throws SQLException;

    // ── List queries (return DTOs so JSPs get guest+room info) ───────
    List<ReservationDTO> findAllDTOs(int page, int size) throws SQLException;
    List<ReservationDTO> findRecentDTOs(int limit) throws SQLException;
    List<ReservationDTO> findByGuestId(Long guestId) throws SQLException;
    List<ReservationDTO> findByRoomId(Long roomId) throws SQLException;
    List<ReservationDTO> findByDateRange(LocalDate startDate, LocalDate endDate) throws SQLException;
    List<ReservationDTO> searchDTOs(String keyword, String status,
                                    String paymentStatus,
                                    LocalDate checkInDate,
                                    LocalDate checkOutDate) throws SQLException;

    // ── Status-based lists ───────────────────────────────────────────
    List<Reservation> findActiveReservations() throws SQLException;
    List<Reservation> findCheckInsByDate(LocalDate date) throws SQLException;
    List<Reservation> findCheckOutsByDate(LocalDate date) throws SQLException;

    // ── Aggregates ───────────────────────────────────────────────────
    int countOccupiedRoomsByDate(LocalDate date) throws SQLException;
    int countCheckInsByDate(LocalDate date) throws SQLException;
    int countCheckOutsByDate(LocalDate date) throws SQLException;
    double getTotalRevenueByMonth(int year, int month) throws SQLException;
}
