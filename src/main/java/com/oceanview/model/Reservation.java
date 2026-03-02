package com.oceanview.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class Reservation {

    private Long          id;
    private String        reservationNumber;
    private Long          guestId;
    private Long          userId;

    /**
     * Total number of rooms booked under this reservation.
     * Stored in reservations.number_of_rooms.
     * All actual room details live in reservation_rooms table.
     */
    private Integer       numberOfRooms;

    private LocalDate     checkInDate;
    private LocalDate     checkOutDate;
    private Integer       adults;
    private Integer       children;
    private Integer       totalNights;

    /**
     * Combined nightly rate across ALL booked rooms.
     * e.g. Room A ($100) + Room B ($150) = $250 / night stored here.
     */
    private BigDecimal    roomPrice;

    private BigDecimal    taxAmount;
    private BigDecimal    discountAmount;
    private BigDecimal    subtotal;       // combinedNightlyRate × nights
    private BigDecimal    totalAmount;    // single amount guest pays

    private PaymentStatus     paymentStatus;
    private ReservationStatus reservationStatus;
    private String            specialRequests;
    private ReservationSource source;
    private LocalDateTime     createdAt;
    private LocalDateTime     updatedAt;

    // ── Associated objects (not persisted in reservations table) ────────────────
    private Guest      guest;
    private User       user;

    /**
     * Transient list of all room IDs for this reservation.
     * Populated from reservation_rooms at query time. Not a DB column.
     */
    private List<Long> roomIds = new ArrayList<>();

    // ── Enums ─────────────────────────────────────────────────────────────────────

    public enum PaymentStatus {
        PENDING, PARTIAL, PAID, REFUNDED
    }

    public enum ReservationStatus {
        CONFIRMED, CHECKED_IN, CHECKED_OUT, CANCELLED, NO_SHOW
    }

    public enum ReservationSource {
        WALK_IN, PHONE, EMAIL, WEBSITE, AGENT
    }

    // ── Constructors ──────────────────────────────────────────────────────────────

    public Reservation() {
        this.adults            = 1;
        this.children          = 0;
        this.numberOfRooms     = 1;
        this.discountAmount    = BigDecimal.ZERO;
        this.paymentStatus     = PaymentStatus.PENDING;
        this.reservationStatus = ReservationStatus.CONFIRMED;
        this.source            = ReservationSource.WALK_IN;
        this.roomIds           = new ArrayList<>();
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getReservationNumber() { return reservationNumber; }
    public void setReservationNumber(String reservationNumber) {
        this.reservationNumber = reservationNumber;
    }

    public Long getGuestId() { return guestId; }
    public void setGuestId(Long guestId) { this.guestId = guestId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Integer getNumberOfRooms() {
        return numberOfRooms != null ? numberOfRooms : 1;
    }
    public void setNumberOfRooms(Integer numberOfRooms) {
        this.numberOfRooms = (numberOfRooms != null && numberOfRooms > 0) ? numberOfRooms : 1;
    }

    /** Transient: all room IDs from reservation_rooms. Never persisted. */
    public List<Long> getRoomIds() {
        return roomIds != null ? roomIds : new ArrayList<>();
    }
    public void setRoomIds(List<Long> roomIds) {
        this.roomIds = roomIds != null ? roomIds : new ArrayList<>();
    }

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public Integer getAdults() { return adults; }
    public void setAdults(Integer adults) { this.adults = adults; }

    public Integer getChildren() { return children; }
    public void setChildren(Integer children) { this.children = children; }

    public Integer getTotalNights() {
        if (totalNights == null && checkInDate != null && checkOutDate != null) {
            return (int) ChronoUnit.DAYS.between(checkInDate, checkOutDate);
        }
        return totalNights;
    }
    public void setTotalNights(Integer totalNights) { this.totalNights = totalNights; }

    public BigDecimal getRoomPrice() { return roomPrice; }
    public void setRoomPrice(BigDecimal roomPrice) { this.roomPrice = roomPrice; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public PaymentStatus getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public ReservationStatus getReservationStatus() { return reservationStatus; }
    public void setReservationStatus(ReservationStatus reservationStatus) {
        this.reservationStatus = reservationStatus;
    }

    public String getSpecialRequests() { return specialRequests; }
    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public ReservationSource getSource() { return source; }
    public void setSource(ReservationSource source) { this.source = source; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Guest getGuest() { return guest; }
    public void setGuest(Guest guest) { this.guest = guest; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    // ── Business helpers ──────────────────────────────────────────────────────────

    public int getTotalGuests() {
        return (adults != null ? adults : 0) + (children != null ? children : 0);
    }

    public BigDecimal calculateTotalNights() {
        if (checkInDate != null && checkOutDate != null) {
            return new BigDecimal(ChronoUnit.DAYS.between(checkInDate, checkOutDate));
        }
        return BigDecimal.ZERO;
    }

    public boolean isCheckedIn()  { return reservationStatus == ReservationStatus.CHECKED_IN;  }
    public boolean isCheckedOut() { return reservationStatus == ReservationStatus.CHECKED_OUT; }
    public boolean isCancelled()  { return reservationStatus == ReservationStatus.CANCELLED;   }
    public boolean isPaid()       { return paymentStatus == PaymentStatus.PAID;                }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return Objects.equals(id, ((Reservation) o).id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }

    @Override
    public String toString() {
        return "Reservation{id=" + id
                + ", number='" + reservationNumber + '\''
                + ", numberOfRooms=" + numberOfRooms
                + ", checkIn=" + checkInDate
                + ", checkOut=" + checkOutDate
                + ", status=" + reservationStatus + '}';
    }
}