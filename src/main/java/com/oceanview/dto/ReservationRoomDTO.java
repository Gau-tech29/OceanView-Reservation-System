package com.oceanview.dto;

import java.math.BigDecimal;


public class ReservationRoomDTO {

    private Long       id;             // reservation_rooms.id
    private Long       reservationId;
    private Long       roomId;
    private BigDecimal roomPrice;      // base price per night at time of booking
    private String     roomNumber;
    private String     roomType;
    private String     roomView;
    private Integer    floorNumber;
    private Integer    capacity;

    public ReservationRoomDTO() {}
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public BigDecimal getRoomPrice() { return roomPrice; }
    public void setRoomPrice(BigDecimal roomPrice) { this.roomPrice = roomPrice; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public String getRoomView() { return roomView; }
    public void setRoomView(String roomView) { this.roomView = roomView; }

    public Integer getFloorNumber() { return floorNumber; }
    public void setFloorNumber(Integer floorNumber) { this.floorNumber = floorNumber; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    /**
     * Readable label for display, e.g. "Room 201 (DELUXE - OCEAN VIEW)"
     */
    public String getDisplayLabel() {
        StringBuilder sb = new StringBuilder("Room ").append(roomNumber);
        if (roomType != null) sb.append(" (").append(roomType);
        if (roomView != null && !roomView.isEmpty()) sb.append(" - ").append(roomView);
        if (roomType != null) sb.append(")");
        return sb.toString();
    }

    @Override
    public String toString() {
        return "ReservationRoomDTO{roomId=" + roomId
                + ", roomNumber='" + roomNumber + '\''
                + ", roomType='" + roomType + '\''
                + ", roomPrice=" + roomPrice + '}';
    }
}