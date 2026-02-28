package com.oceanview.dto;

import java.math.BigDecimal;

public class RoomDTO {
    private Long id;
    private String roomNumber;
    private String roomType;
    private String roomView;
    private Integer floorNumber;
    private Integer capacity;
    private BigDecimal basePrice;
    private String status;
    private String description;
    private boolean active;

    // Constructors
    public RoomDTO() {}

    public RoomDTO(Long id, String roomNumber, String roomType, String roomView,
                   Integer floorNumber, Integer capacity, BigDecimal basePrice) {
        this.id = id;
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.roomView = roomView;
        this.floorNumber = floorNumber;
        this.capacity = capacity;
        this.basePrice = basePrice;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

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

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}