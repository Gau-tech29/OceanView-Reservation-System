package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dao.impl.RoomDAOImpl;
import com.oceanview.model.Room;
import com.oceanview.util.ValidationUtils;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class RoomService {

    private final RoomDAO roomDAO;
    private final ReservationDAO reservationDAO;

    public RoomService() {
        this.roomDAO = RoomDAOImpl.getInstance();
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public RoomService(RoomDAO roomDAO) {
        this.roomDAO = roomDAO;
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public Room createRoom(Room room) throws SQLException, IllegalArgumentException {
        // Validate room data
        validateRoom(room);

        // Check if room number already exists
        Optional<Room> existingRoom = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existingRoom.isPresent()) {
            throw new IllegalArgumentException("Room number already exists: " + room.getRoomNumber());
        }

        return roomDAO.save(room);
    }

    public Room updateRoom(Room room) throws SQLException, IllegalArgumentException {
        if (room.getId() == null) {
            throw new IllegalArgumentException("Room ID is required for update");
        }

        validateRoom(room);

        // Check if room exists
        if (!roomDAO.exists(room.getId())) {
            throw new IllegalArgumentException("Room not found with ID: " + room.getId());
        }

        // Check if room number is taken by another room
        Optional<Room> existingRoom = roomDAO.findByRoomNumber(room.getRoomNumber());
        if (existingRoom.isPresent() && !existingRoom.get().getId().equals(room.getId())) {
            throw new IllegalArgumentException("Room number already exists: " + room.getRoomNumber());
        }

        return roomDAO.update(room);
    }

    public boolean deleteRoom(Long id) throws SQLException {
        // Check if room has active reservations
        // You should implement this check in ReservationDAO
        return roomDAO.delete(id);
    }

    public Optional<Room> getRoomById(Long id) throws SQLException {
        return roomDAO.findById(id);
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

    public Room updateRoomStatus(Long id, Room.RoomStatus status) throws SQLException, IllegalArgumentException {
        Optional<Room> roomOpt = roomDAO.findById(id);
        if (!roomOpt.isPresent()) {
            throw new IllegalArgumentException("Room not found");
        }

        Room room = roomOpt.get();
        room.setStatus(status);
        return roomDAO.update(room);
    }

// Add these methods to RoomService.java

    public int getOccupiedRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.OCCUPIED).size();
    }

    public int getMaintenanceRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.MAINTENANCE).size();
    }

    public int getReservedRoomsCount() throws SQLException {
        return roomDAO.findByStatus(Room.RoomStatus.RESERVED).size();
    }

    public List<Room> getRecentRooms(int limit) throws SQLException {
        return roomDAO.findAll(1, limit); // Page 1 with specified limit
    }

    public long getTotalRooms() throws SQLException {
        return roomDAO.count();
    }

    public long getAvailableRoomsCount() throws SQLException {
        return roomDAO.countAvailableRooms();
    }

    public double getMonthlyRevenue(int month, int year) throws SQLException {
        return reservationDAO.getTotalRevenueByMonth(year, month);
    }

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