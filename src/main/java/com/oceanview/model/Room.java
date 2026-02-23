package com.oceanview.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

public class Room {
    private Long id;
    private String roomNumber;
    private RoomType roomType;
    private RoomView roomView;
    private Integer floorNumber;
    private Integer capacity;
    private BigDecimal basePrice;
    private BigDecimal taxRate;
    private String amenities;
    private String description;
    private RoomStatus status;
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public enum RoomType {
        STANDARD, DELUXE, SUITE, EXECUTIVE, FAMILY
    }

    public enum RoomView {
        OCEAN_VIEW, GARDEN_VIEW, CITY_VIEW, POOL_VIEW
    }

    public enum RoomStatus {
        AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
    }

    // Constructors
    public Room() {}

    public Room(String roomNumber, RoomType roomType, RoomView roomView,
                Integer floorNumber, Integer capacity, BigDecimal basePrice) {
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.roomView = roomView;
        this.floorNumber = floorNumber;
        this.capacity = capacity;
        this.basePrice = basePrice;
        this.taxRate = new BigDecimal("12.00");
        this.status = RoomStatus.AVAILABLE;
        this.isActive = true;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }

    public RoomView getRoomView() { return roomView; }
    public void setRoomView(RoomView roomView) { this.roomView = roomView; }

    public Integer getFloorNumber() { return floorNumber; }
    public void setFloorNumber(Integer floorNumber) { this.floorNumber = floorNumber; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public BigDecimal getTaxRate() { return taxRate; }
    public void setTaxRate(BigDecimal taxRate) { this.taxRate = taxRate; }

    public String getAmenities() { return amenities; }
    public void setAmenities(String amenities) { this.amenities = amenities; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public RoomStatus getStatus() { return status; }
    public void setStatus(RoomStatus status) { this.status = status; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public BigDecimal calculatePricePerNight() {
        return basePrice;
    }

    public BigDecimal calculateTaxPerNight() {
        return basePrice.multiply(taxRate).divide(new BigDecimal("100"));
    }

    public BigDecimal calculateTotalPerNight() {
        return basePrice.add(calculateTaxPerNight());
    }

    public boolean isAvailable() {
        return status == RoomStatus.AVAILABLE;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Room room = (Room) o;
        return Objects.equals(id, room.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Room{" +
                "id=" + id +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomType=" + roomType +
                ", roomView=" + roomView +
                ", status=" + status +
                '}';
    }
}