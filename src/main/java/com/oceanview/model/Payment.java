package com.oceanview.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

public class Payment {
    private Long id;
    private String paymentNumber;
    private Long reservationId;
    private BigDecimal amount;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private String transactionId;
    private String cardLastFour;
    private LocalDateTime paymentDate;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Reservation reservation;
    private Guest guest; // Added for easier access
    private Bill bill;   // Added for easier access

    public enum PaymentMethod {
        CASH, CREDIT_CARD, DEBIT_CARD, BANK_TRANSFER
    }

    public enum PaymentStatus {
        PENDING, COMPLETED, FAILED, REFUNDED
    }

    public Payment() {
        this.paymentStatus = PaymentStatus.PENDING;
        this.paymentDate = LocalDateTime.now();
    }

    public Payment(String paymentNumber, Long reservationId, BigDecimal amount, PaymentMethod paymentMethod) {
        this.paymentNumber = paymentNumber;
        this.reservationId = reservationId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = PaymentStatus.PENDING;
        this.paymentDate = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPaymentNumber() { return paymentNumber; }
    public void setPaymentNumber(String paymentNumber) { this.paymentNumber = paymentNumber; }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public PaymentStatus getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(PaymentStatus paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getCardLastFour() { return cardLastFour; }
    public void setCardLastFour(String cardLastFour) { this.cardLastFour = cardLastFour; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }

    public Guest getGuest() { return guest; }
    public void setGuest(Guest guest) { this.guest = guest; }

    public Bill getBill() { return bill; }
    public void setBill(Bill bill) { this.bill = bill; }

    // Helper methods
    public boolean isCompleted() {
        return paymentStatus == PaymentStatus.COMPLETED;
    }

    public boolean isRefunded() {
        return paymentStatus == PaymentStatus.REFUNDED;
    }

    public boolean isPending() {
        return paymentStatus == PaymentStatus.PENDING;
    }

    public boolean isFailed() {
        return paymentStatus == PaymentStatus.FAILED;
    }

    public void markAsCompleted() {
        this.paymentStatus = PaymentStatus.COMPLETED;
    }

    public void markAsFailed() {
        this.paymentStatus = PaymentStatus.FAILED;
    }

    public void markAsRefunded() {
        this.paymentStatus = PaymentStatus.REFUNDED;
    }

    public String getFormattedPaymentDate() {
        if (paymentDate == null) return "";
        return paymentDate.format(DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    public String getFormattedAmount() {
        return String.format("Rs. %.2f", amount != null ? amount.doubleValue() : 0.0);
    }

    public String getPaymentMethodDisplay() {
        if (paymentMethod == null) return "";
        switch (paymentMethod) {
            case CASH: return "Cash";
            case CREDIT_CARD: return "Credit Card";
            case DEBIT_CARD: return "Debit Card";
            case BANK_TRANSFER: return "Bank Transfer";
            default: return paymentMethod.name();
        }
    }

    public String getPaymentStatusBadgeClass() {
        if (paymentStatus == null) return "badge-pending";
        switch (paymentStatus) {
            case COMPLETED: return "badge-completed";
            case REFUNDED: return "badge-refunded";
            case PENDING: return "badge-pending";
            case FAILED: return "badge-failed";
            default: return "badge-pending";
        }
    }

    public String getPaymentStatusDisplay() {
        if (paymentStatus == null) return "PENDING";
        switch (paymentStatus) {
            case COMPLETED: return "Completed";
            case REFUNDED: return "Refunded";
            case PENDING: return "Pending";
            case FAILED: return "Failed";
            default: return paymentStatus.name();
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Payment payment = (Payment) o;
        return Objects.equals(id, payment.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Payment{" +
                "id=" + id +
                ", paymentNumber='" + paymentNumber + '\'' +
                ", amount=" + amount +
                ", method=" + paymentMethod +
                ", status=" + paymentStatus +
                '}';
    }
}