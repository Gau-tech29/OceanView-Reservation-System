package com.oceanview.test.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.service.ReservationService;
import com.oceanview.service.RoomService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ReservationServiceTest {

    @Mock
    private ReservationDAO reservationDAO;

    @Mock
    private RoomService roomService;

    private ReservationService reservationService;

    private Room availableRoom;

    // ─── Inject mocks via reflection since no matching constructor exists ─────

    @BeforeEach
    void setUp() throws Exception {
        reservationService = new ReservationService();
        injectField(reservationService, "reservationDAO", reservationDAO);
        injectField(reservationService, "roomService",    roomService);

        availableRoom = new Room();
        availableRoom.setId(1L);
        availableRoom.setRoomNumber("101");
        availableRoom.setRoomType(Room.RoomType.DELUXE);
        availableRoom.setRoomView(Room.RoomView.OCEAN_VIEW);
        availableRoom.setFloorNumber(1);
        availableRoom.setCapacity(2);
        availableRoom.setBasePrice(new BigDecimal("150.00"));
        availableRoom.setTaxRate(new BigDecimal("0.12"));
        availableRoom.setStatus(Room.RoomStatus.AVAILABLE);
        availableRoom.setActive(true);
    }

    /**
     * Injects {@code value} into the named private field of {@code target},
     * regardless of access modifier.
     */
    private static void injectField(Object target, String fieldName, Object value)
            throws Exception {
        Field f = target.getClass().getDeclaredField(fieldName);
        f.setAccessible(true);
        f.set(target, value);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private ReservationDTO buildDTO(Long id, LocalDate checkIn, LocalDate checkOut) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(id);
        dto.setGuestId(10L);
        dto.setCheckInDate(checkIn);
        dto.setCheckOutDate(checkOut);
        dto.setAdults(2);
        dto.setChildren(0);
        dto.setRoomIds(List.of(1L));
        return dto;
    }

    private Reservation buildReservation(Long id, LocalDate checkIn, LocalDate checkOut) {
        Reservation r = new Reservation();
        r.setId(id);
        r.setGuestId(10L);
        r.setCheckInDate(checkIn);
        r.setCheckOutDate(checkOut);
        r.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);
        r.setPaymentStatus(Reservation.PaymentStatus.PENDING);
        r.setTotalAmount(new BigDecimal("450.00"));
        r.setNumberOfRooms(1);
        return r;
    }

    // ─── createReservation ────────────────────────────────────────────────────

    @Test
    @DisplayName("Create reservation with valid data should return DTO")
    void createReservation_WithValidData_ShouldReturnDTO() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);

        when(roomService.getRoomById(1L)).thenReturn(Optional.of(availableRoom));
        when(reservationDAO.findConflictingReservationIds(
                eq(1L), eq(checkIn), eq(checkOut), isNull()))
                .thenReturn(Collections.emptyList());

        Reservation saved = buildReservation(1L, checkIn, checkOut);
        when(reservationDAO.save(any(Reservation.class))).thenReturn(saved);
        doNothing().when(reservationDAO)
                .saveReservationRooms(anyLong(), anyList(), anyMap());

        ReservationDTO resultDTO = buildDTO(1L, checkIn, checkOut);
        when(reservationDAO.findDTOById(1L)).thenReturn(Optional.of(resultDTO));

        ReservationDTO result = reservationService.createReservation(dto, List.of(1L));

        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(reservationDAO).save(any(Reservation.class));
    }

    @Test
    @DisplayName("Create reservation with no rooms should throw exception")
    void createReservation_WithNoRooms_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);

        assertThrows(IllegalArgumentException.class, () ->
                reservationService.createReservation(dto, Collections.emptyList()));

        verify(reservationDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create reservation when room not active should throw exception")
    void createReservation_WithInactiveRoom_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);

        Room inactiveRoom = new Room();
        inactiveRoom.setId(1L);
        inactiveRoom.setRoomNumber("101");
        inactiveRoom.setActive(false);

        when(roomService.getRoomById(1L)).thenReturn(Optional.of(inactiveRoom));

        assertThrows(IllegalArgumentException.class, () ->
                reservationService.createReservation(dto, List.of(1L)));

        verify(reservationDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create reservation with room conflict should throw exception")
    void createReservation_WithRoomConflict_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);

        when(roomService.getRoomById(1L)).thenReturn(Optional.of(availableRoom));
        when(reservationDAO.findConflictingReservationIds(
                eq(1L), eq(checkIn), eq(checkOut), isNull()))
                .thenReturn(List.of(99L));

        assertThrows(IllegalArgumentException.class, () ->
                reservationService.createReservation(dto, List.of(1L)));

        verify(reservationDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create reservation with null guest should throw exception")
    void createReservation_WithNullGuest_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);
        dto.setGuestId(null);

        assertThrows(IllegalArgumentException.class, () ->
                reservationService.createReservation(dto, List.of(1L)));

        verify(reservationDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create reservation with check-out before check-in should throw exception")
    void createReservation_WithInvalidDates_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(4);
        LocalDate checkOut = LocalDate.now().plusDays(1); // before check-in

        ReservationDTO dto = buildDTO(null, checkIn, checkOut);

        assertThrows(IllegalArgumentException.class, () ->
                reservationService.createReservation(dto, List.of(1L)));

        verify(reservationDAO, never()).save(any());
    }

    // ─── getReservationById ───────────────────────────────────────────────────

    @Test
    @DisplayName("Get reservation by ID when exists should return DTO")
    void getReservationById_WhenExists_ShouldReturnDTO() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto = buildDTO(1L, checkIn, checkOut);
        when(reservationDAO.findDTOById(1L)).thenReturn(Optional.of(dto));

        Optional<ReservationDTO> result = reservationService.getReservationById(1L);

        assertTrue(result.isPresent());
        assertEquals(1L, result.get().getId());
    }

    @Test
    @DisplayName("Get reservation by ID when not exists should return empty")
    void getReservationById_WhenNotExists_ShouldReturnEmpty() throws Exception {
        when(reservationDAO.findDTOById(999L)).thenReturn(Optional.empty());

        Optional<ReservationDTO> result = reservationService.getReservationById(999L);

        assertFalse(result.isPresent());
    }

    // ─── getReservations (paged) ──────────────────────────────────────────────

    @Test
    @DisplayName("Get reservations paged should return list")
    void getReservations_ShouldReturnList() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        ReservationDTO dto1 = buildDTO(1L, checkIn, checkOut);
        ReservationDTO dto2 = buildDTO(2L, checkIn.plusDays(5), checkOut.plusDays(5));

        when(reservationDAO.findAllDTOs(1, 10)).thenReturn(List.of(dto1, dto2));

        List<ReservationDTO> results = reservationService.getReservations(1, 10);

        assertEquals(2, results.size());
        verify(reservationDAO).findAllDTOs(1, 10);
    }

    // ─── cancelReservation ────────────────────────────────────────────────────

    @Test
    @DisplayName("Cancel reservation should update status to CANCELLED")
    void cancelReservation_ShouldUpdateStatus() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));
        when(reservationDAO.update(any(Reservation.class))).thenReturn(reservation);

        reservationService.cancelReservation(1L);

        verify(reservationDAO).update(argThat(r ->
                r.getReservationStatus() == Reservation.ReservationStatus.CANCELLED));
    }

    @Test
    @DisplayName("Cancel reservation when not found should throw exception")
    void cancelReservation_WhenNotFound_ShouldThrowException() throws Exception {
        when(reservationDAO.findById(999L)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> reservationService.cancelReservation(999L));
    }

    @Test
    @DisplayName("Cancel already checked-out reservation should throw exception")
    void cancelReservation_WhenCheckedOut_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().minusDays(3);
        LocalDate checkOut = LocalDate.now();

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CHECKED_OUT);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));

        assertThrows(IllegalArgumentException.class,
                () -> reservationService.cancelReservation(1L));
    }

    // ─── checkIn ─────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Check-in reservation should update status to CHECKED_IN")
    void checkInReservation_ShouldUpdateStatus() throws Exception {
        LocalDate checkIn  = LocalDate.now();
        LocalDate checkOut = LocalDate.now().plusDays(3);

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));
        when(reservationDAO.update(any(Reservation.class))).thenReturn(reservation);

        reservationService.checkIn(1L);

        verify(reservationDAO).update(argThat(r ->
                r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_IN));
    }

    @Test
    @DisplayName("Check-in non-CONFIRMED reservation should throw exception")
    void checkInReservation_WhenNotConfirmed_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now();
        LocalDate checkOut = LocalDate.now().plusDays(3);

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CHECKED_IN);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));

        assertThrows(IllegalArgumentException.class,
                () -> reservationService.checkIn(1L));
    }

    // ─── checkOut ────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Check-out reservation should update status to CHECKED_OUT")
    void checkOutReservation_ShouldUpdateStatus() throws Exception {
        LocalDate checkIn  = LocalDate.now().minusDays(3);
        LocalDate checkOut = LocalDate.now();

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CHECKED_IN);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));
        when(reservationDAO.update(any(Reservation.class))).thenReturn(reservation);

        reservationService.checkOut(1L);

        verify(reservationDAO).update(argThat(r ->
                r.getReservationStatus() == Reservation.ReservationStatus.CHECKED_OUT));
    }

    @Test
    @DisplayName("Check-out non-CHECKED_IN reservation should throw exception")
    void checkOutReservation_WhenNotCheckedIn_ShouldThrowException() throws Exception {
        LocalDate checkIn  = LocalDate.now().minusDays(3);
        LocalDate checkOut = LocalDate.now();

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setReservationStatus(Reservation.ReservationStatus.CONFIRMED);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));

        assertThrows(IllegalArgumentException.class,
                () -> reservationService.checkOut(1L));
    }

    // ─── Dashboard / counts ───────────────────────────────────────────────────

    @Test
    @DisplayName("Get active reservations count should return count")
    void getActiveReservationsCount_ShouldReturnCount() throws Exception {
        when(reservationDAO.countActiveReservations()).thenReturn(5L);

        long count = reservationService.getActiveReservationsCount();

        assertEquals(5L, count);
        verify(reservationDAO).countActiveReservations();
    }

    @Test
    @DisplayName("Get today's check-ins count should return count")
    void getTodaysCheckInsCount_ShouldReturnCount() throws Exception {
        when(reservationDAO.countCheckInsByDate(LocalDate.now())).thenReturn(3);

        int count = reservationService.getTodaysCheckInsCount();

        assertEquals(3, count);
    }

    @Test
    @DisplayName("Get today's check-outs count should return count")
    void getTodaysCheckOutsCount_ShouldReturnCount() throws Exception {
        when(reservationDAO.countCheckOutsByDate(LocalDate.now())).thenReturn(2);

        int count = reservationService.getTodaysCheckOutsCount();

        assertEquals(2, count);
    }

    // ─── Reservations by check-in / check-out date ────────────────────────────

    @Test
    @DisplayName("Get reservations by check-in date should return list")
    void getReservationsByCheckInDate_ShouldReturnList() throws Exception {
        LocalDate today    = LocalDate.now();
        LocalDate checkOut = today.plusDays(3);

        ReservationDTO dto = buildDTO(1L, today, checkOut);
        when(reservationDAO.findByCheckInDate(today)).thenReturn(List.of(dto));

        List<ReservationDTO> results =
                reservationService.getReservationsByCheckInDate(today);

        assertEquals(1, results.size());
        verify(reservationDAO).findByCheckInDate(today);
    }

    @Test
    @DisplayName("Get reservations by check-in date with null should throw exception")
    void getReservationsByCheckInDate_WithNull_ShouldThrowException() throws Exception {
        assertThrows(IllegalArgumentException.class,
                () -> reservationService.getReservationsByCheckInDate(null));
    }

    @Test
    @DisplayName("Get reservations by check-out date should return list")
    void getReservationsByCheckOutDate_ShouldReturnList() throws Exception {
        LocalDate today   = LocalDate.now();
        LocalDate checkIn = today.minusDays(3);

        ReservationDTO dto = buildDTO(1L, checkIn, today);
        when(reservationDAO.findByCheckOutDate(today)).thenReturn(List.of(dto));

        List<ReservationDTO> results =
                reservationService.getReservationsByCheckOutDate(today);

        assertEquals(1, results.size());
        verify(reservationDAO).findByCheckOutDate(today);
    }

    // ─── Revenue ──────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get monthly revenue should return correct amount")
    void getMonthlyRevenue_ShouldReturnAmount() throws Exception {
        when(reservationDAO.getTotalRevenueByMonth(2024, 3)).thenReturn(5000.0);

        double revenue = reservationService.getMonthlyRevenue(2024, 3);

        assertEquals(5000.0, revenue);
        verify(reservationDAO).getTotalRevenueByMonth(2024, 3);
    }

    // ─── Delete ───────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Delete reservation should return true")
    void deleteReservation_ShouldReturnTrue() throws Exception {
        when(reservationDAO.delete(1L)).thenReturn(true);

        boolean result = reservationService.deleteReservation(1L);

        assertTrue(result);
        verify(reservationDAO).delete(1L);
    }

    // ─── Mark as paid ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("Mark reservation as paid should update payment status")
    void markReservationAsPaid_ShouldUpdatePaymentStatus() throws Exception {
        LocalDate checkIn  = LocalDate.now();
        LocalDate checkOut = LocalDate.now().plusDays(3);

        Reservation reservation = buildReservation(1L, checkIn, checkOut);
        reservation.setPaymentStatus(Reservation.PaymentStatus.PENDING);

        when(reservationDAO.findById(1L)).thenReturn(Optional.of(reservation));
        when(reservationDAO.update(any(Reservation.class))).thenReturn(reservation);

        reservationService.markReservationAsPaid(1L);

        verify(reservationDAO).update(argThat(r ->
                r.getPaymentStatus() == Reservation.PaymentStatus.PAID));
    }

    @Test
    @DisplayName("Mark as paid when reservation not found should throw exception")
    void markReservationAsPaid_WhenNotFound_ShouldThrowException() throws Exception {
        when(reservationDAO.findById(999L)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> reservationService.markReservationAsPaid(999L));
    }
}