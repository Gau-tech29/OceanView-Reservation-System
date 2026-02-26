package com.oceanview.dao;

import com.oceanview.model.Room;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public interface RoomDAO extends BaseDAO<Room, Long> {
    Optional<Room> findByRoomNumber(String roomNumber) throws SQLException;
    List<Room> findByType(Room.RoomType type) throws SQLException;
    List<Room> findByStatus(Room.RoomStatus status) throws SQLException;
    List<Room> findByFloor(int floorNumber) throws SQLException;
    List<Room> findAvailableRooms() throws SQLException;
    List<Room> findOccupiedRooms() throws SQLException;
    List<Room> findRoomsByCapacity(int capacity) throws SQLException;
    List<Room> findRoomsByPriceRange(double minPrice, double maxPrice) throws SQLException;
    boolean updateStatus(Long id, Room.RoomStatus status) throws SQLException;
    long countAvailableRooms() throws SQLException;
}