package com.oceanview.test.service;

import com.oceanview.dao.RoomDAO;
import com.oceanview.dto.RoomDTO;
import com.oceanview.model.Room;
import com.oceanview.service.RoomService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class RoomServiceTest {

    @Mock
    private RoomDAO roomDAO;

    private RoomService roomService;

    @BeforeEach
    void setUp() {
        roomService = new RoomService(roomDAO);
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    private Room buildValidRoom(String number) {
        Room room = new Room();
        room.setRoomNumber(number);
        room.setRoomType(Room.RoomType.DELUXE);
        room.setRoomView(Room.RoomView.OCEAN_VIEW);
        room.setFloorNumber(1);
        room.setCapacity(2);
        room.setBasePrice(new BigDecimal("150.00"));
        room.setStatus(Room.RoomStatus.AVAILABLE);
        room.setActive(true);
        return room;
    }

    // ─── Create ───────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Create room with valid data should succeed")
    void createRoom_WithValidData_ShouldReturnRoom() throws Exception {
        Room room = buildValidRoom("101");
        when(roomDAO.findByRoomNumber("101")).thenReturn(Optional.empty());

        Room savedRoom = buildValidRoom("101");
        savedRoom.setId(1L);
        when(roomDAO.save(any(Room.class))).thenReturn(savedRoom);

        Room result = roomService.createRoom(room);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(roomDAO).save(any(Room.class));
    }

    @Test
    @DisplayName("Create room with duplicate number should throw exception")
    void createRoom_WithDuplicateNumber_ShouldThrowException() throws Exception {
        Room room = buildValidRoom("101");

        Room existingRoom = buildValidRoom("101");
        existingRoom.setId(1L);
        when(roomDAO.findByRoomNumber("101")).thenReturn(Optional.of(existingRoom));

        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                roomService.createRoom(room));

        assertTrue(exception.getMessage().contains("already exists"));
        verify(roomDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create room with null room number should throw exception")
    void createRoom_WithNullRoomNumber_ShouldThrowException() throws Exception {
        Room room = buildValidRoom(null);
        assertThrows(IllegalArgumentException.class, () -> roomService.createRoom(room));
        verify(roomDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create room with null room type should throw exception")
    void createRoom_WithNullRoomType_ShouldThrowException() throws Exception {
        Room room = buildValidRoom("101");
        room.setRoomType(null);
        assertThrows(IllegalArgumentException.class, () -> roomService.createRoom(room));
        verify(roomDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create room with null room view should throw exception")
    void createRoom_WithNullRoomView_ShouldThrowException() throws Exception {
        Room room = buildValidRoom("101");
        room.setRoomView(null);
        assertThrows(IllegalArgumentException.class, () -> roomService.createRoom(room));
        verify(roomDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create room with zero base price should throw exception")
    void createRoom_WithZeroBasePrice_ShouldThrowException() throws Exception {
        Room room = buildValidRoom("101");
        room.setBasePrice(BigDecimal.ZERO);
        assertThrows(IllegalArgumentException.class, () -> roomService.createRoom(room));
        verify(roomDAO, never()).save(any());
    }

    // ─── Update ───────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Update room with no ID should throw exception")
    void updateRoom_WithNoId_ShouldThrowException() throws Exception {
        Room room = buildValidRoom("101");
        // id is null by default
        assertThrows(IllegalArgumentException.class, () -> roomService.updateRoom(room));
        verify(roomDAO, never()).update(any());
    }

    // ─── Status update ────────────────────────────────────────────────────────

    @Test
    @DisplayName("Update room status should succeed")
    void updateRoomStatus_ShouldUpdate() throws Exception {
        Long roomId = 1L;
        Room room = buildValidRoom("101");
        room.setId(roomId);

        Room updatedRoom = buildValidRoom("101");
        updatedRoom.setId(roomId);
        updatedRoom.setStatus(Room.RoomStatus.MAINTENANCE);

        when(roomDAO.findById(roomId)).thenReturn(Optional.of(room));
        when(roomDAO.update(any(Room.class))).thenReturn(updatedRoom);

        Room result = roomService.updateRoomStatus(roomId, Room.RoomStatus.MAINTENANCE);

        assertEquals(Room.RoomStatus.MAINTENANCE, result.getStatus());
        verify(roomDAO).update(argThat(r -> r.getStatus() == Room.RoomStatus.MAINTENANCE));
    }

    @Test
    @DisplayName("Update room status when room not found should throw exception")
    void updateRoomStatus_WhenRoomNotFound_ShouldThrowException() throws Exception {
        Long roomId = 999L;
        when(roomDAO.findById(roomId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> roomService.updateRoomStatus(roomId, Room.RoomStatus.MAINTENANCE));
    }

    // ─── Delete ───────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Delete room should return true")
    void deleteRoom_ShouldReturnTrue() throws Exception {
        Long roomId = 1L;
        when(roomDAO.delete(roomId)).thenReturn(true);

        boolean result = roomService.deleteRoom(roomId);

        assertTrue(result);
        verify(roomDAO).delete(roomId);
    }

    // ─── Find by ID ───────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get room by ID when exists should return room")
    void getRoomById_WhenExists_ShouldReturnRoom() throws Exception {
        Long id = 1L;
        Room room = buildValidRoom("101");
        room.setId(id);
        when(roomDAO.findById(id)).thenReturn(Optional.of(room));

        Optional<Room> result = roomService.getRoomById(id);

        assertTrue(result.isPresent());
        assertEquals(id, result.get().getId());
    }

    @Test
    @DisplayName("Get room by ID when not exists should return empty")
    void getRoomById_WhenNotExists_ShouldReturnEmpty() throws Exception {
        Long id = 999L;
        when(roomDAO.findById(id)).thenReturn(Optional.empty());

        Optional<Room> result = roomService.getRoomById(id);

        assertFalse(result.isPresent());
    }

    // ─── Find all / filter ────────────────────────────────────────────────────

    @Test
    @DisplayName("Get all rooms should return list")
    void getAllRooms_ShouldReturnList() throws Exception {
        Room room1 = buildValidRoom("101");
        Room room2 = buildValidRoom("102");
        when(roomDAO.findAll()).thenReturn(Arrays.asList(room1, room2));

        List<Room> results = roomService.getAllRooms();

        assertEquals(2, results.size());
        verify(roomDAO).findAll();
    }

    @Test
    @DisplayName("Get rooms by type should return filtered list")
    void getRoomsByType_ShouldReturnFiltered() throws Exception {
        Room.RoomType type = Room.RoomType.DELUXE;
        Room room1 = buildValidRoom("101");
        room1.setId(1L);
        Room room2 = buildValidRoom("102");
        room2.setId(2L);
        when(roomDAO.findByType(type)).thenReturn(Arrays.asList(room1, room2));

        List<Room> results = roomService.getRoomsByType(type);

        assertEquals(2, results.size());
        verify(roomDAO).findByType(type);
    }

    @Test
    @DisplayName("Get available rooms should return list")
    void getAvailableRooms_ShouldReturnList() throws Exception {
        Room room1 = buildValidRoom("101");
        when(roomDAO.findAvailableRooms()).thenReturn(List.of(room1));

        List<Room> results = roomService.getAvailableRooms();

        assertEquals(1, results.size());
        verify(roomDAO).findAvailableRooms();
    }

    @Test
    @DisplayName("Get rooms by floor should return list")
    void getRoomsByFloor_ShouldReturnList() throws Exception {
        Room room1 = buildValidRoom("101");
        when(roomDAO.findByFloor(1)).thenReturn(List.of(room1));

        List<Room> results = roomService.getRoomsByFloor(1);

        assertEquals(1, results.size());
        verify(roomDAO).findByFloor(1);
    }

    @Test
    @DisplayName("Get rooms by capacity should return list")
    void getRoomsByCapacity_ShouldReturnList() throws Exception {
        Room room1 = buildValidRoom("101");
        when(roomDAO.findRoomsByCapacity(2)).thenReturn(List.of(room1));

        List<Room> results = roomService.getRoomsByCapacity(2);

        assertEquals(1, results.size());
        verify(roomDAO).findRoomsByCapacity(2);
    }

    @Test
    @DisplayName("Get rooms by price range should return list")
    void getRoomsByPriceRange_ShouldReturnList() throws Exception {
        Room room1 = buildValidRoom("101");
        when(roomDAO.findRoomsByPriceRange(100.0, 200.0)).thenReturn(List.of(room1));

        List<Room> results = roomService.getRoomsByPriceRange(100.0, 200.0);

        assertEquals(1, results.size());
        verify(roomDAO).findRoomsByPriceRange(100.0, 200.0);
    }

    // ─── Availability for dates ───────────────────────────────────────────────

    @Test
    @DisplayName("Get available rooms for dates should return list")
    void getAvailableRoomsForDates_ShouldReturnList() throws Exception {
        LocalDate checkIn  = LocalDate.now().plusDays(1);
        LocalDate checkOut = LocalDate.now().plusDays(4);

        Room room1 = buildValidRoom("101");
        room1.setId(1L);
        Room room2 = buildValidRoom("102");
        room2.setId(2L);
        room2.setBasePrice(new BigDecimal("130.00"));

        when(roomDAO.findAvailableRoomsForDates(checkIn, checkOut))
                .thenReturn(Arrays.asList(room1, room2));

        List<RoomDTO> results = roomService.getAvailableRoomsForDates(checkIn, checkOut);

        assertEquals(2, results.size());
        assertEquals("101", results.get(0).getRoomNumber());
        verify(roomDAO).findAvailableRoomsForDates(checkIn, checkOut);
    }

    // ─── Counts ───────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get total rooms count should return count")
    void getTotalRooms_ShouldReturnCount() throws Exception {
        when(roomDAO.count()).thenReturn(10L);

        long result = roomService.getTotalRooms();

        assertEquals(10L, result);
        verify(roomDAO).count();
    }

    @Test
    @DisplayName("Get available rooms count should return count")
    void getAvailableRoomsCount_ShouldReturnCount() throws Exception {
        when(roomDAO.countAvailableRooms()).thenReturn(5L);

        long result = roomService.getAvailableRoomsCount();

        assertEquals(5L, result);
        verify(roomDAO).countAvailableRooms();
    }
}