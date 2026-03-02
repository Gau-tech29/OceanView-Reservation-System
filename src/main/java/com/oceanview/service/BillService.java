package com.oceanview.service;

import com.oceanview.dao.BillDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.BillDAOImpl;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.model.Bill;
import com.oceanview.model.Reservation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class BillService {

    private final BillDAO billDAO;
    private final ReservationDAO reservationDAO;

    public BillService() {
        this.billDAO = BillDAOImpl.getInstance();
        this.reservationDAO = ReservationDAOImpl.getInstance();
    }

    public BillService(BillDAO billDAO, ReservationDAO reservationDAO) {
        this.billDAO = billDAO;
        this.reservationDAO = reservationDAO;
    }

    /**
     * Creates a bill for the given reservation.
     * Uses ISSUED status (PENDING is NOT a valid DB enum value).
     * If a bill already exists, returns the existing one instead of throwing.
     */
    public Bill createBill(Long reservationId, Long userId) throws SQLException {
        Optional<Reservation> reservationOpt = reservationDAO.findById(reservationId);
        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }
        Reservation reservation = reservationOpt.get();

        // Return existing bill if present
        List<Bill> existingBills = billDAO.findByReservationId(reservationId);
        if (!existingBills.isEmpty()) {
            return existingBills.get(0);
        }

        Bill bill = new Bill();
        bill.setBillNumber(generateBillNumber());
        bill.setReservationId(reservationId);
        bill.setGuestId(reservation.getGuestId());
        bill.setUserId(userId);
        bill.setIssueDate(LocalDate.now());
        bill.setDueDate(LocalDate.now().plusDays(7));
        bill.setCheckInDate(reservation.getCheckInDate());
        bill.setCheckOutDate(reservation.getCheckOutDate());

        BigDecimal nights = new BigDecimal(
                reservation.getTotalNights() != null ? reservation.getTotalNights() : 1);
        BigDecimal roomPrice = reservation.getRoomPrice() != null
                ? reservation.getRoomPrice() : BigDecimal.ZERO;
        bill.setRoomCharges(roomPrice.multiply(nights));
        bill.setAdditionalCharges(BigDecimal.ZERO);

        BigDecimal subtotal = bill.getRoomCharges();
        BigDecimal discount = reservation.getDiscountAmount() != null
                ? reservation.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal taxable  = subtotal.subtract(discount);
        BigDecimal taxAmount = taxable.multiply(new BigDecimal("0.12"))
                .setScale(2, RoundingMode.HALF_UP);

        bill.setTaxAmount(taxAmount);
        bill.setDiscountAmount(discount);

        BigDecimal total = taxable.add(taxAmount).setScale(2, RoundingMode.HALF_UP);
        bill.setTotalAmount(total);
        bill.setPaidAmount(BigDecimal.ZERO);

        // ISSUED is a valid DB enum value; PENDING is NOT
        bill.setBillStatus(Bill.BillStatus.ISSUED);

        return billDAO.save(bill);
    }

    public Optional<Bill> getBillById(Long id) throws SQLException {
        return billDAO.findById(id);
    }

    public Optional<Bill> getBillByNumber(String billNumber) throws SQLException {
        return billDAO.findByBillNumber(billNumber);
    }

    public List<Bill> getBillsByReservation(Long reservationId) throws SQLException {
        return billDAO.findByReservationId(reservationId);
    }

    public List<Bill> getBillsByGuest(Long guestId) throws SQLException {
        return billDAO.findByGuestId(guestId);
    }

    public List<Bill> getAllBills() throws SQLException {
        return billDAO.findAll();
    }

    public List<Bill> getBillsByStatus(Bill.BillStatus status) throws SQLException {
        return billDAO.findByStatus(status);
    }

    public List<Bill> getBillsByDateRange(LocalDate start, LocalDate end) throws SQLException {
        return billDAO.findByDateRange(start, end);
    }

    public List<Bill> getOverdueBills() throws SQLException {
        return billDAO.findOverdueBills();
    }

    public double getTotalRevenue(LocalDate start, LocalDate end) throws SQLException {
        return billDAO.getTotalRevenueByDateRange(start, end);
    }

    public Bill updateBill(Bill bill) throws SQLException {
        if (bill.getId() == null) {
            throw new IllegalArgumentException("Bill ID is required for update");
        }
        return billDAO.update(bill);
    }

    public Bill addPayment(Long billId, BigDecimal amount, Bill.PaymentMethod method)
            throws SQLException {

        Bill bill = billDAO.findById(billId)
                .orElseThrow(() -> new IllegalArgumentException("Bill not found"));

        if (bill.isPaid()) {
            throw new IllegalArgumentException("Bill is already paid");
        }

        BigDecimal currentPaid = bill.getPaidAmount() != null ? bill.getPaidAmount() : BigDecimal.ZERO;
        BigDecimal balanceDue  = bill.getTotalAmount().subtract(currentPaid);

        if (amount.compareTo(balanceDue) > 0) {
            throw new IllegalArgumentException("Payment amount exceeds balance due");
        }

        BigDecimal newPaid = currentPaid.add(amount);
        bill.setPaidAmount(newPaid);
        bill.setPaymentMethod(method);
        bill.setPaymentDate(java.time.LocalDateTime.now());

        if (bill.getTotalAmount().subtract(newPaid).compareTo(BigDecimal.ZERO) <= 0) {
            bill.setBillStatus(Bill.BillStatus.PAID);
        } else {
            bill.setBillStatus(Bill.BillStatus.PARTIALLY_PAID);
        }

        return billDAO.update(bill);
    }

    /**
     * Marks the bill as fully paid.
     * Sets paid_amount = total_amount and bill_status = PAID.
     * Does NOT set balanceDue — it is a STORED GENERATED column in DB.
     */
    public Bill markAsPaid(Long billId, Bill.PaymentMethod method) throws SQLException {
        Bill bill = billDAO.findById(billId)
                .orElseThrow(() -> new IllegalArgumentException("Bill not found"));

        bill.setPaidAmount(bill.getTotalAmount());
        // balance_due is STORED GENERATED — DB computes it; we never write it
        bill.setBillStatus(Bill.BillStatus.PAID);
        bill.setPaymentMethod(method);
        bill.setPaymentDate(java.time.LocalDateTime.now());

        return billDAO.update(bill);
    }

    public Bill updateBillStatus(Long id, Bill.BillStatus status) throws SQLException {
        Bill bill = billDAO.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Bill not found"));
        bill.setBillStatus(status);
        return billDAO.update(bill);
    }

    public void printBill(Long id) throws SQLException {
        if (!billDAO.exists(id)) {
            throw new IllegalArgumentException("Bill not found");
        }
        billDAO.incrementPrintedCount(id);
    }

    public Bill cancelBill(Long id) throws SQLException {
        Bill bill = billDAO.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Bill not found"));
        // CANCELLED is not in DB enum; use DRAFT as cancelled state
        bill.setBillStatus(Bill.BillStatus.DRAFT);
        return billDAO.update(bill);
    }

    private String generateBillNumber() {
        return "BILL-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
