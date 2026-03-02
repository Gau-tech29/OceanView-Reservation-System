package com.oceanview.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Data-transfer object for Reservation.
 *
 * Key points:
 *  - numberOfRooms  → count stored in reservations.number_of_rooms
 *  - rooms          → full list of ReservationRoomDTO loaded from reservation_rooms
 *  - roomIds        → transient list used in form → controller → service flow
 *
 * Single-room convenience getters (getRoomId, getRoomNumber, getRoomType, getFirstRoomPrice)
 * delegate to the FIRST element of the rooms list so that edit-mode JSP code works.
 */
public class ReservationDTO {

    private Long   id;
    private String reservationNumber;
    private Long   guestId;
    private Long   userId;

    // ── Room summary ──────────────────────────────────────────────────────────────

    /** Total rooms booked — stored in reservations.number_of_rooms. */
    private Integer numberOfRooms;

    /**
     * All room details for this reservation, loaded from reservation_rooms.
     * Always use this list for display / billing.
     */
    private List<ReservationRoomDTO> rooms = new ArrayList<>();

    /**
     * Transient: room IDs collected from the form and passed through to the service.
     * Not stored in the database.
     */
    private List<Long> roomIds = new ArrayList<>();

    // ── Stay fields ───────────────────────────────────────────────────────────────

    private LocalDate  checkInDate;
    private LocalDate  checkOutDate;
    private Integer    totalNights;
    private Integer    adults;
    private Integer    children;

    // ── Pricing ───────────────────────────────────────────────────────────────────

    /** Combined nightly rate across all rooms (sum of each room base price). */
    private BigDecimal roomPrice;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal subtotal;
    private BigDecimal totalAmount;

    // ── Status ────────────────────────────────────────────────────────────────────

    private String paymentStatus;
    private String reservationStatus;
    private String specialRequests;
    private String source;

    // ── Guest (joined) ────────────────────────────────────────────────────────────

    private String guestName;
    private String guestEmail;
    private String guestPhone;
    private String guestNumber;

    // ── Staff (joined) ────────────────────────────────────────────────────────────

    private String staffName;

    // ── Timestamps ────────────────────────────────────────────────────────────────

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────────────────────────

    public ReservationDTO() {
        this.rooms         = new ArrayList<>();
        this.roomIds       = new ArrayList<>();
        this.numberOfRooms = 1;
    }

    // ── Core Getters & Setters ────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getReservationNumber() { return reservationNumber; }
    public void setReservationNumber(String n) { this.reservationNumber = n; }

    public Long getGuestId() { return guestId; }
    public void setGuestId(Long guestId) { this.guestId = guestId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    /** Total rooms count. If rooms list is loaded, derived from its size. */
    public Integer getNumberOfRooms() {
        if (rooms != null && !rooms.isEmpty()) return rooms.size();
        return numberOfRooms != null ? numberOfRooms : 1;
    }
    public void setNumberOfRooms(Integer n) {
        this.numberOfRooms = (n != null && n > 0) ? n : 1;
    }

    /** Full room details from reservation_rooms (for display and billing). */
    public List<ReservationRoomDTO> getRooms() {
        return rooms != null ? rooms : new ArrayList<>();
    }
    public void setRooms(List<ReservationRoomDTO> rooms) {
        this.rooms = rooms != null ? rooms : new ArrayList<>();
        if (!this.rooms.isEmpty()) this.numberOfRooms = this.rooms.size();
    }

    /** Transient room IDs from form to controller to service. */
    public List<Long> getRoomIds() { return roomIds != null ? roomIds : new ArrayList<>(); }
    public void setRoomIds(List<Long> roomIds) { this.roomIds = roomIds != null ? roomIds : new ArrayList<>(); }

    // ── Single-room convenience getters (delegate to first room in list) ──────────
    // These exist ONLY so that form.jsp edit-mode scriptlet code compiles without errors.
    // For multi-room reservations always iterate getRooms() instead.

    /**
     * Returns the ID of the first booked room, or null if rooms list is empty.
     */
    public Long getRoomId() {
        if (rooms != null && !rooms.isEmpty()) {
            return rooms.get(0).getRoomId();
        }
        return null;
    }

    /**
     * Returns the room number of the first booked room, or null.
     */
    public String getRoomNumber() {
        if (rooms != null && !rooms.isEmpty()) {
            return rooms.get(0).getRoomNumber();
        }
        return null;
    }

    /**
     * Returns the room type of the first booked room, or null.
     */
    public String getRoomType() {
        if (rooms != null && !rooms.isEmpty()) {
            return rooms.get(0).getRoomType();
        }
        return null;
    }

    /**
     * Returns the price of the first booked room, or falls back to roomPrice.
     * Named getFirstRoomPrice to avoid collision with getRoomPrice (combined rate).
     */
    public BigDecimal getFirstRoomPrice() {
        if (rooms != null && !rooms.isEmpty() && rooms.get(0).getRoomPrice() != null) {
            return rooms.get(0).getRoomPrice();
        }
        return roomPrice != null ? roomPrice : BigDecimal.ZERO;
    }

    // ── Stay field getters/setters ────────────────────────────────────────────────

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public Integer getTotalNights() {
        if (totalNights == null && checkInDate != null && checkOutDate != null)
            return (int) ChronoUnit.DAYS.between(checkInDate, checkOutDate);
        return totalNights;
    }
    public void setTotalNights(Integer totalNights) { this.totalNights = totalNights; }

    public Integer getAdults() { return adults; }
    public void setAdults(Integer adults) { this.adults = adults; }

    public Integer getChildren() { return children; }
    public void setChildren(Integer children) { this.children = children; }

    // ── Pricing getters/setters ───────────────────────────────────────────────────

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

    // ── Status getters/setters ────────────────────────────────────────────────────

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getReservationStatus() { return reservationStatus; }
    public void setReservationStatus(String reservationStatus) { this.reservationStatus = reservationStatus; }

    public String getSpecialRequests() { return specialRequests; }
    public void setSpecialRequests(String specialRequests) { this.specialRequests = specialRequests; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    // ── Guest getters/setters ─────────────────────────────────────────────────────

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getGuestEmail() { return guestEmail; }
    public void setGuestEmail(String guestEmail) { this.guestEmail = guestEmail; }

    public String getGuestPhone() { return guestPhone; }
    public void setGuestPhone(String guestPhone) { this.guestPhone = guestPhone; }

    public String getGuestNumber() { return guestNumber; }
    public void setGuestNumber(String guestNumber) { this.guestNumber = guestNumber; }

    // ── Timestamp getters/setters ─────────────────────────────────────────────────

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // ── Display helpers ───────────────────────────────────────────────────────────

    /** Comma-separated room numbers from all booked rooms. e.g. "101, 202, 305" */
    public String getRoomNumbersSummary() {
        if (rooms == null || rooms.isEmpty()) return "N/A";
        return rooms.stream()
                .map(r -> r.getRoomNumber() != null ? r.getRoomNumber() : "?")
                .collect(Collectors.joining(", "));
    }

    /** Comma-separated distinct room types. e.g. "DELUXE, SUITE" */
    public String getRoomTypesSummary() {
        if (rooms == null || rooms.isEmpty()) return "N/A";
        return rooms.stream()
                .map(r -> r.getRoomType() != null ? r.getRoomType() : "?")
                .distinct()
                .collect(Collectors.joining(", "));
    }

    /** Readable multi-line room summary. */
    public String getRoomsDetailSummary() {
        if (rooms == null || rooms.isEmpty()) return "N/A";
        return rooms.stream()
                .map(r -> r.getDisplayLabel()
                        + (r.getRoomPrice() != null ? " @ $" + r.getRoomPrice() + "/night" : ""))
                .collect(Collectors.joining("\n"));
    }

    /** Formatted createdAt for JSP display (avoids fmt:formatDate on LocalDateTime). */
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    /** Formatted checkInDate for JSP display. */
    public String getFormattedCheckInDate() {
        if (checkInDate == null) return "";
        return checkInDate.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy"));
    }

    /** Formatted checkOutDate for JSP display. */
    public String getFormattedCheckOutDate() {
        if (checkOutDate == null) return "";
        return checkOutDate.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy"));
    }

    /** Total guests (adults + children). */
    public int getTotalGuests() {
        return (adults != null ? adults : 0) + (children != null ? children : 0);
    }

    @Override
    public String toString() {
        return "ReservationDTO{id=" + id
                + ", number='" + reservationNumber + '\''
                + ", numberOfRooms=" + getNumberOfRooms()
                + ", rooms=" + getRoomNumbersSummary()
                + ", checkIn=" + checkInDate
                + ", checkOut=" + checkOutDate + '}';
    }
}