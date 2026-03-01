package com.oceanview.mapper;

import com.oceanview.dto.RoomDTO;
import com.oceanview.model.Room;

import java.util.ArrayList;
import java.util.List;

public class RoomMapper {

    private static RoomMapper instance;

    private RoomMapper() {}

    public static synchronized RoomMapper getInstance() {
        if (instance == null) instance = new RoomMapper();
        return instance;
    }

    public RoomDTO toDTO(Room room) {
        if (room == null) return null;
        RoomDTO dto = new RoomDTO();
        dto.setId(room.getId());
        dto.setRoomNumber(room.getRoomNumber());

        // RoomType and RoomView are enums — convert to String for the DTO
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

    public List<RoomDTO> toDTOList(List<Room> rooms) {
        List<RoomDTO> list = new ArrayList<>();
        if (rooms != null) {
            for (Room r : rooms) list.add(toDTO(r));
        }
        return list;
    }
}