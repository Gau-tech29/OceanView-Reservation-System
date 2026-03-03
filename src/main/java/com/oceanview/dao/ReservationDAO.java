package com.oceanview.dao;

import com.oceanview.dto.ReservationDTO;
import com.oceanview.dto.ReservationRoomDTO;
import com.oceanview.model.Reservation;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ReservationDAO extends BaseDAO<Reservation, Long> {

    // ─── DTO methods ─────────────────────────────────────────────────────────────

    Optional<ReservationDTO> findDTOById(Long id) throws SQLException;

    Optional<ReservationDTO> findDTOByNumber(String number) throws SQLException;

    List<ReservationDTO> findAllDTOs(int page, int size) throws SQLException;

    List<ReservationDTO> findRecentDTOs(int limit) throws SQLException;

    List<ReservationDTO> findByGuestId(Long guestId) throws SQLException;

    List<ReservationDTO> findByRoomId(Long roomId) throws SQLException;

    List<ReservationDTO> findByDateRange(LocalDate start, LocalDate end) throws SQLException;

    List<ReservationDTO> searchDTOs(String keyword, String status,
                                    String paymentStatus,
                                    LocalDate checkInDate,
                                    LocalDate checkOutDate) throws SQLException;

    // ─── Entity list methods ─────────────────────────────────────────────────────

    List<Reservation> findActiveReservations() throws SQLException;

    List<Reservation> findCheckInsByDate(LocalDate date) throws SQLException;

    List<Reservation> findCheckOutsByDate(LocalDate date) throws SQLException;

    // Add these methods to ReservationDAO.java

    List<ReservationDTO> findByCheckInDate(LocalDate date) throws SQLException;

    List<ReservationDTO> findByCheckOutDate(LocalDate date) throws SQLException;

    // ─── New method for dashboard ────────────────────────────────────────────────

    long countActiveReservations() throws SQLException;

    // ─── Aggregates ───────────────────────────────────────────────────────────────

    int countOccupiedRoomsByDate(LocalDate date) throws SQLException;

    int countCheckInsByDate(LocalDate date) throws SQLException;

    int countCheckOutsByDate(LocalDate date) throws SQLException;

    double getTotalRevenueByMonth(int year, int month) throws SQLException;

    // ─── Multi-room methods ───────────────────────────────────────────────────────

    void saveReservationRooms(Long reservationId,
                              List<Long> roomIds,
                              Map<Long, BigDecimal> roomPrices) throws SQLException;

    List<ReservationRoomDTO> findReservationRooms(Long reservationId) throws SQLException;

    void deleteReservationRooms(Long reservationId) throws SQLException;

    List<Long> findConflictingReservationIds(Long roomId,
                                             LocalDate checkIn,
                                             LocalDate checkOut,
                                             Long excludeReservationId) throws SQLException;
}