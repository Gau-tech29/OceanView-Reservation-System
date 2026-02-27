package com.oceanview.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Objects;

public class Bill {
    private Long id;
    private String billNumber;
    private Long reservationId;
    private Long guestId;
    private Long userId;
    private LocalDate issueDate;
    private LocalDate dueDate;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private BigDecimal roomCharges;
    private BigDecimal additionalCharges;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private BillStatus billStatus;
    private PaymentMethod paymentMethod;
    private LocalDateTime paymentDate;
    private String notes;
    private Integer printedCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Reservation reservation;
    private Guest guest;
    private User user;

    public enum BillStatus {
        DRAFT, PENDING, ISSUED, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
    }

    public enum PaymentMethod {
        CASH, CARD, BANK_TRANSFER, MIXED
    }

    public Bill() {
        this.issueDate = LocalDate.now();
        this.additionalCharges = BigDecimal.ZERO;
        this.discountAmount = BigDecimal.ZERO;
        this.paidAmount = BigDecimal.ZERO;
        this.printedCount = 0;
        this.billStatus = BillStatus.DRAFT;
    }

    public Bill(String billNumber, Long reservationId, Long guestId, Long userId) {
        this.billNumber = billNumber;
        this.reservationId = reservationId;
        this.guestId = guestId;
        this.userId = userId;
        this.issueDate = LocalDate.now();
        this.additionalCharges = BigDecimal.ZERO;
        this.discountAmount = BigDecimal.ZERO;
        this.paidAmount = BigDecimal.ZERO;
        this.printedCount = 0;
        this.billStatus = BillStatus.DRAFT;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBillNumber() { return billNumber; }
    public void setBillNumber(String billNumber) { this.billNumber = billNumber; }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

    public Long getGuestId() { return guestId; }
    public void setGuestId(Long guestId) { this.guestId = guestId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public LocalDate getIssueDate() { return issueDate; }
    public void setIssueDate(LocalDate issueDate) { this.issueDate = issueDate; }

    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public BigDecimal getRoomCharges() { return roomCharges; }
    public void setRoomCharges(BigDecimal roomCharges) { this.roomCharges = roomCharges; }

    public BigDecimal getAdditionalCharges() { return additionalCharges; }
    public void setAdditionalCharges(BigDecimal additionalCharges) {
        this.additionalCharges = additionalCharges != null ? additionalCharges : BigDecimal.ZERO;
    }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount != null ? discountAmount : BigDecimal.ZERO;
    }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getPaidAmount() { return paidAmount; }
    public void setPaidAmount(BigDecimal paidAmount) {
        this.paidAmount = paidAmount != null ? paidAmount : BigDecimal.ZERO;
    }

    public BigDecimal getBalanceDue() { return balanceDue; }
    public void setBalanceDue(BigDecimal balanceDue) { this.balanceDue = balanceDue; }

    public BillStatus getBillStatus() { return billStatus; }
    public void setBillStatus(BillStatus billStatus) { this.billStatus = billStatus; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getPrintedCount() { return printedCount; }
    public void setPrintedCount(Integer printedCount) { this.printedCount = printedCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }

    public Guest getGuest() { return guest; }
    public void setGuest(Guest guest) { this.guest = guest; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    // Business methods
    public void calculateTotals() {
        this.totalAmount = roomCharges
                .add(additionalCharges)
                .add(taxAmount)
                .subtract(discountAmount)
                .setScale(2, RoundingMode.HALF_UP);

        this.balanceDue = totalAmount.subtract(paidAmount);
    }

    public void addPayment(BigDecimal amount) {
        this.paidAmount = this.paidAmount.add(amount);
        this.balanceDue = this.totalAmount.subtract(this.paidAmount);

        if (this.balanceDue.compareTo(BigDecimal.ZERO) <= 0) {
            this.billStatus = BillStatus.PAID;
        } else if (this.paidAmount.compareTo(BigDecimal.ZERO) > 0) {
            this.billStatus = BillStatus.PARTIALLY_PAID;
        }
    }

    public boolean isPaid() {
        return billStatus == BillStatus.PAID;
    }

    public boolean isOverdue() {
        return billStatus == BillStatus.ISSUED &&
                dueDate != null &&
                LocalDate.now().isAfter(dueDate);
    }

    public void incrementPrintedCount() {
        this.printedCount++;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Bill bill = (Bill) o;
        return Objects.equals(id, bill.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Bill{" +
                "id=" + id +
                ", billNumber='" + billNumber + '\'' +
                ", totalAmount=" + totalAmount +
                ", status=" + billStatus +
                '}';
    }
}