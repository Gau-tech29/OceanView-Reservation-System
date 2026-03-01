package com.oceanview.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class ReservationDTO {

    private Long id;
    private String reservationNumber;

    // Guest info (from join)
    private Long guestId;
    private String guestName;
    private String guestEmail;
    private String guestPhone;
    private String guestNumber;

    // User (staff) who created it
    private Long userId;
    private String staffName;

    // Room info (from join)
    private Long roomId;
    private String roomNumber;
    private String roomType;
    private String roomView;
    private Integer floorNumber;

    // Stay details
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private Integer totalNights;
    private Integer adults;
    private Integer children;

    // Pricing
    private BigDecimal roomPrice;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal subtotal;
    private BigDecimal totalAmount;

    // Status
    private String paymentStatus;
    private String reservationStatus;

    // Meta
    private String specialRequests;
    private String source;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ─── Constructors ───────────────────────────────────────────────
    public ReservationDTO() {}

    // ─── Formatted date helpers (safe for JSP/EL, no fmt:formatDate needed) ──

    public String getFormattedCheckInDate() {
        if (checkInDate == null) return "";
        return checkInDate.format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));
    }

    public String getFormattedCheckOutDate() {
        if (checkOutDate == null) return "";
        return checkOutDate.format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));
    }

    public String getFormattedCheckInDateShort() {
        if (checkInDate == null) return "";
        return checkInDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }

    public String getFormattedCheckOutDateShort() {
        if (checkOutDate == null) return "";
        return checkOutDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm"));
    }

    public String getFormattedCreatedAtLong() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));
    }

    // ─── Computed helpers ───────────────────────────────────────────

    public int computeNights() {
        if (checkInDate == null || checkOutDate == null) return 0;
        return (int) ChronoUnit.DAYS.between(checkInDate, checkOutDate);
    }

    public Integer getTotalNights() {
        if (totalNights != null && totalNights > 0) return totalNights;
        return computeNights();
    }

    // ─── Getters & Setters ──────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getReservationNumber() { return reservationNumber; }
    public void setReservationNumber(String reservationNumber) { this.reservationNumber = reservationNumber; }

    public Long getGuestId() { return guestId; }
    public void setGuestId(Long guestId) { this.guestId = guestId; }

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getGuestPhone() { return guestPhone; }
    public void setGuestPhone(String guestPhone) { this.guestPhone = guestPhone; }

    public String getGuestNumber() { return guestNumber; }
    public void setGuestNumber(String guestNumber) { this.guestNumber = guestNumber; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public String getRoomView() { return roomView; }
    public void setRoomView(String roomView) { this.roomView = roomView; }

    public Integer getFloorNumber() { return floorNumber; }
    public void setFloorNumber(Integer floorNumber) { this.floorNumber = floorNumber; }

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public void setTotalNights(Integer totalNights) { this.totalNights = totalNights; }

    public Integer getAdults() { return adults; }
    public void setAdults(Integer adults) { this.adults = adults; }

    public Integer getChildren() { return children; }
    public void setChildren(Integer children) { this.children = children; }

    public BigDecimal getRoomPrice() { return roomPrice; }
    public void setRoomPrice(BigDecimal roomPrice) { this.roomPrice = roomPrice; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getReservationStatus() { return reservationStatus; }
    public void setReservationStatus(String reservationStatus) { this.reservationStatus = reservationStatus; }

    public String getSpecialRequests() { return specialRequests; }
    public void setSpecialRequests(String specialRequests) { this.specialRequests = specialRequests; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}