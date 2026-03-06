package com.oceanview.dto;

import java.math.BigDecimal;

public class RoomDTO {

    private Long       id;
    private String     roomNumber;
    private String     roomType;
    private String     roomView;
    private Integer    floorNumber;
    private Integer    capacity;
    private BigDecimal basePrice;
    private BigDecimal taxRate;
    private String     amenities;
    private String     description;
    private String     status;
    private boolean    isActive;

    public RoomDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    /** Returns empty string (never null) so JSON serialiser is safe. */
    public String getRoomView() { return roomView != null ? roomView : ""; }
    public void setRoomView(String roomView) { this.roomView = roomView; }

    public Integer getFloorNumber() { return floorNumber; }
    public void setFloorNumber(Integer floorNumber) { this.floorNumber = floorNumber; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public BigDecimal getTaxRate() { return taxRate; }
    public void setTaxRate(BigDecimal taxRate) { this.taxRate = taxRate; }

    /** Returns empty string (never null) so JSON serialiser is safe. */
    public String getAmenities() { return amenities != null ? amenities : ""; }
    public void setAmenities(String amenities) { this.amenities = amenities; }

    /** Returns empty string (never null) so JSON serialiser is safe. */
    public String getDescription() { return description != null ? description : ""; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}