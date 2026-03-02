package com.oceanview.mapper;

import com.oceanview.dto.RoomDTO;
import com.oceanview.model.Room;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Maps between Room entity and RoomDTO.
 * Singleton pattern mirrors ReservationMapper.
 */
public class RoomMapper {

    private static RoomMapper instance;

    private RoomMapper() {}

    public static synchronized RoomMapper getInstance() {
        if (instance == null) instance = new RoomMapper();
        return instance;
    }

    // ── Entity → DTO ─────────────────────────────────────────────────────────────

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
        dto.setTaxRate(room.getTaxRate());
        dto.setAmenities(room.getAmenities());
        dto.setDescription(room.getDescription());
        dto.setStatus(room.getStatus() != null ? room.getStatus().name() : null);
        dto.setActive(room.isActive());
        return dto;
    }

    // ── DTO → Entity ─────────────────────────────────────────────────────────────

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
        if (dto.getStatus() != null) {
            try { room.setStatus(Room.RoomStatus.valueOf(dto.getStatus())); }
            catch (IllegalArgumentException ignored) {}
        }

        room.setFloorNumber(dto.getFloorNumber());
        room.setCapacity(dto.getCapacity());
        room.setBasePrice(dto.getBasePrice());
        room.setTaxRate(dto.getTaxRate());
        room.setAmenities(dto.getAmenities());
        room.setDescription(dto.getDescription());
        room.setActive(dto.isActive());
        return room;
    }

    // ── List conversions ──────────────────────────────────────────────────────────

    public List<RoomDTO> toDTOList(List<Room> rooms) {
        return rooms.stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<Room> toEntityList(List<RoomDTO> dtos) {
        return dtos.stream().map(this::toEntity).collect(Collectors.toList());
    }
}