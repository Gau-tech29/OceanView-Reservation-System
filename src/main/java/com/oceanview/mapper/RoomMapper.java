package com.oceanview.mapper;

import com.oceanview.dto.RoomDTO;
import com.oceanview.model.Room;

import java.util.List;
import java.util.stream.Collectors;

public class RoomMapper {

    private static RoomMapper instance;

    private RoomMapper() {}

    public static synchronized RoomMapper getInstance() {
        if (instance == null) {
            instance = new RoomMapper();
        }
        return instance;
    }

    public RoomDTO toDTO(Room room) {
        if (room == null) return null;

        RoomDTO dto = new RoomDTO();
        dto.setId(room.getId());
        dto.setRoomNumber(room.getRoomNumber());
        dto.setRoomType(room.getRoomType() != null ? room.getRoomType().name() : null);
        dto.setRoomView(room.getRoomView() != null ? room.getRoomView().name() : null);
        dto.setFloorNumber(room.getFloorNumber());
        dto.setCapacity(room.getCapacity());
        dto.setBasePrice(room.getBasePrice());
        dto.setStatus(room.getStatus() != null ? room.getStatus().name() : null);
        dto.setDescription(room.getDescription());
        dto.setActive(room.isActive());

        return dto;
    }

    public List<RoomDTO> toDTOList(List<Room> rooms) {
        return rooms.stream().map(this::toDTO).collect(Collectors.toList());
    }

    public Room toEntity(RoomDTO dto) {
        if (dto == null) return null;

        Room room = new Room();
        room.setId(dto.getId());
        room.setRoomNumber(dto.getRoomNumber());

        if (dto.getRoomType() != null) {
            try { room.setRoomType(Room.RoomType.valueOf(dto.getRoomType())); }
            catch (IllegalArgumentException ignored) {}
        }

        if (dto.getRoomView() != null) {
            try { room.setRoomView(Room.RoomView.valueOf(dto.getRoomView())); }
            catch (IllegalArgumentException ignored) {}
        }

        room.setFloorNumber(dto.getFloorNumber());
        room.setCapacity(dto.getCapacity());
        room.setBasePrice(dto.getBasePrice());

        if (dto.getStatus() != null) {
            try { room.setStatus(Room.RoomStatus.valueOf(dto.getStatus())); }
            catch (IllegalArgumentException ignored) {}
        }

        room.setDescription(dto.getDescription());
        room.setActive(dto.isActive());

        return room;
    }
}