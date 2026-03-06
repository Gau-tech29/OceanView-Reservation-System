package com.oceanview.dto;

import com.oceanview.model.Payment;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class PaymentDTO {
    private Long id;
    private String paymentNumber;
    private Long reservationId;
    private String reservationNumber;
    private Long guestId;
    private String guestName;
    private String guestEmail;
    private String guestPhone;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentStatus;
    private String transactionId;
    private String cardLastFour;
    private LocalDateTime paymentDate;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Bill information
    private Long billId;
    private String billNumber;
    private BigDecimal billTotalAmount;
    private String billStatus;

    public PaymentDTO() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPaymentNumber() { return paymentNumber; }
    public void setPaymentNumber(String paymentNumber) { this.paymentNumber = paymentNumber; }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

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

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

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

    public Long getBillId() { return billId; }
    public void setBillId(Long billId) { this.billId = billId; }

    public String getBillNumber() { return billNumber; }
    public void setBillNumber(String billNumber) { this.billNumber = billNumber; }

    public BigDecimal getBillTotalAmount() { return billTotalAmount; }
    public void setBillTotalAmount(BigDecimal billTotalAmount) { this.billTotalAmount = billTotalAmount; }

    public String getBillStatus() { return billStatus; }
    public void setBillStatus(String billStatus) { this.billStatus = billStatus; }

    // Helper methods for display
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
            case "CASH": return "Cash";
            case "CREDIT_CARD": return "Credit Card";
            case "DEBIT_CARD": return "Debit Card";
            case "BANK_TRANSFER": return "Bank Transfer";
            default: return paymentMethod;
        }
    }

    public String getPaymentStatusBadgeClass() {
        if (paymentStatus == null) return "badge-pending";
        switch (paymentStatus) {
            case "COMPLETED": return "badge-completed";
            case "REFUNDED": return "badge-refunded";
            case "PENDING": return "badge-pending";
            case "FAILED": return "badge-failed";
            default: return "badge-pending";
        }
    }

    public String getPaymentStatusDisplay() {
        if (paymentStatus == null) return "Pending";
        switch (paymentStatus) {
            case "COMPLETED": return "Completed";
            case "REFUNDED": return "Refunded";
            case "PENDING": return "Pending";
            case "FAILED": return "Failed";
            default: return paymentStatus;
        }
    }

    public boolean isRefundable() {
        return "COMPLETED".equals(paymentStatus);
    }
}