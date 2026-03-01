package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dao.impl.RoomDAOImpl;
import com.oceanview.dto.RoomDTO;
import com.oceanview.mapper.RoomMapper;
import com.oceanview.model.Room;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class RoomService {

    private final RoomDAO roomDAO;
    private final ReservationDAO reservationDAO;
    private final RoomMapper mapper;

    public RoomService() {
        this.roomDAO        = RoomDAOImpl.getInstance();
        this.reservationDAO = ReservationDAOImpl.getInstance();
        this.mapper         = RoomMapper.getInstance();
    }

    public RoomService(RoomDAO roomDAO) {
        this.roomDAO        = roomDAO;
        this.reservationDAO = ReservationDAOImpl.getInstance();
        this.mapper         = RoomMapper.getInstance();
    }

    // ── Create / Update / Delete ──────────────────────────────────────────────

    public Room createRoom(Room room) throws SQLException, IllegalArgumentException {
        validateRoom(room);
        Optional<Room> existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Room number already exists: " + room.getRoomNumber());
        }
        return roomDAO.save(room);
    }

    public Room updateRoom(Room room) throws SQLException, IllegalArgumentException {
        if (room.getId() == null) {
            throw new IllegalArgumentException("Room ID is required for update");
        }
        validateRoom(room);
        if (!roomDAO.exists(room.getId())) {
            throw new IllegalArgumentException("Room not found with ID: " + room.getId());
        }
        Optional<Room> existing = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existing.isPresent() && !existing.get().getId().equals(room.getId())) {
            throw new IllegalArgumentException("Room number already exists: " + room.getRoomNumber());
        }
        return roomDAO.update(room);
    }

    public boolean deleteRoom(Long id) throws SQLException {
        return roomDAO.delete(id);
    }

    // ── Reads ─────────────────────────────────────────────────────────────────

    public Optional<Room> getRoomById(Long id) throws SQLException {
        return roomDAO.findById(id);
    }

    public Optional<RoomDTO> getRoomDTOById(Long id) throws SQLException {
        return roomDAO.findById(id).map(mapper::toDTO);
    }

    public Optional<Room> getRoomByNumber(String roomNumber) throws SQLException {
        return roomDAO.findByRoomNumber(roomNumber);
    }

    public List<Room> getAllRooms() throws SQLException {
        return roomDAO.findAll();
    }

    public List<Room> getRooms(int page, int size) throws SQLException {
        return roomDAO.findAll(page, size);
    }

    public List<Room> getRoomsByType(Room.RoomType type) throws SQLException {
        return roomDAO.findByType(type);
    }

    public List<Room> getRoomsByStatus(Room.RoomStatus status) throws SQLException {
        return roomDAO.findByStatus(status);
    }

    public List<Room> getAvailableRooms() throws SQLException {
        return roomDAO.findAvailableRooms();
    }

    public List<Room> getRoomsByFloor(int floor) throws SQLException {
        return roomDAO.findByFloor(floor);
    }

    public List<Room> getRoomsByCapacity(int capacity) throws SQLException {
        return roomDAO.findRoomsByCapacity(capacity);
    }

    public List<Room> getRoomsByPriceRange(double minPrice, double maxPrice) throws SQLException {
        return roomDAO.findRoomsByPriceRange(minPrice, maxPrice);
    }

    public List<Room> getRecentRooms(int limit) throws SQLException {
        return roomDAO.findAll(1, limit);
    }

    // ── Status update ─────────────────────────────────────────────────────────

    public Room updateRoomStatus(Long id, Room.RoomStatus status) throws SQLException {
        Optional<Room> roomOpt = roomDAO.findById(id);
        if (!roomOpt.isPresent()) {
            throw new IllegalArgumentException("Room not found");
        }
        Room room = roomOpt.get();
        room.setStatus(status);
        return roomDAO.update(room);
    }

    // ── Counts (used by dashboards) ───────────────────────────────────────────

    public long getTotalRooms() throws SQLException {
        return roomDAO.count();
    }

    public long getAvailableRoomsCount() throws SQLException {
        return roomDAO.countAvailableRooms();
    }

    public long getOccupiedRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.OCCUPIED).size();
    }

    public long getMaintenanceRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.MAINTENANCE).size();
    }

    public int getReservedRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.RESERVED).size();
    }

    // ── Revenue (delegates to ReservationDAO) ─────────────────────────────────

    public double getMonthlyRevenue(int month, int year) throws SQLException {
        return reservationDAO.getTotalRevenueByMonth(year, month);
    }

    // ── NEW: date-range availability (used by RoomAvailabilityApiServlet) ─────

    /**
     * Returns all active rooms with NO overlapping CONFIRMED/CHECKED_IN
     * reservation for the window [checkIn, checkOut).
     */
    public List<RoomDTO> getAvailableRoomsForDates(LocalDate checkIn, LocalDate checkOut)
            throws SQLException {
        List<Room> rooms = roomDAO.findAvailableRoomsForDates(checkIn, checkOut);
        return mapper.toDTOList(rooms);
    }

    // ── Validation ────────────────────────────────────────────────────────────

    private void validateRoom(Room room) {
        if (room.getRoomNumber() == null || room.getRoomNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Room number is required");
        }
        if (room.getRoomType() == null) {
            throw new IllegalArgumentException("Room type is required");
        }
        if (room.getRoomView() == null) {
            throw new IllegalArgumentException("Room view is required");
        }
        if (room.getFloorNumber() == null || room.getFloorNumber() <= 0) {
            throw new IllegalArgumentException("Valid floor number is required");
        }
        if (room.getCapacity() == null || room.getCapacity() <= 0) {
            throw new IllegalArgumentException("Valid capacity is required");
        }
        if (room.getBasePrice() == null || room.getBasePrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Valid base price is required");
        }
    }
}