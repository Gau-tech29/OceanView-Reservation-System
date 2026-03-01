package com.oceanview.service;

import com.oceanview.dao.BillDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.impl.BillDAOImpl;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.model.Bill;
import com.oceanview.model.Reservation;

import java.math.BigDecimal;
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

    public Bill createBill(Long reservationId, Long userId) throws SQLException, IllegalArgumentException {
        // Use DAO directly to get the Reservation model (not DTO)
        Optional<Reservation> reservationOpt = reservationDAO.findById(reservationId);

        if (!reservationOpt.isPresent()) {
            throw new IllegalArgumentException("Reservation not found");
        }

        Reservation reservation = reservationOpt.get();

        // Check if bill already exists
        List<Bill> existingBills = billDAO.findByReservationId(reservationId);
        if (!existingBills.isEmpty()) {
            throw new IllegalArgumentException("Bill already exists for this reservation");
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

        // Calculate room charges (room price * number of nights)
        BigDecimal nights = new BigDecimal(reservation.getTotalNights());
        bill.setRoomCharges(reservation.getRoomPrice().multiply(nights));
        bill.setAdditionalCharges(BigDecimal.ZERO);

        // Calculate tax (12%)
        BigDecimal subtotal = bill.getRoomCharges().add(bill.getAdditionalCharges());
        bill.setTaxAmount(subtotal.multiply(new BigDecimal("0.12"))
                .setScale(2, BigDecimal.ROUND_HALF_UP));
        bill.setDiscountAmount(reservation.getDiscountAmount() != null
                ? reservation.getDiscountAmount()
                : BigDecimal.ZERO);

        // Calculate total
        bill.calculateTotals();
        bill.setBillStatus(Bill.BillStatus.PENDING);

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

    public Bill updateBill(Bill bill) throws SQLException, IllegalArgumentException {
        if (bill.getId() == null) {
            throw new IllegalArgumentException("Bill ID is required for update");
        }
        bill.calculateTotals();
        return billDAO.update(bill);
    }

    public Bill addPayment(Long billId, BigDecimal amount, Bill.PaymentMethod method)
            throws SQLException, IllegalArgumentException {

        Optional<Bill> billOpt = billDAO.findById(billId);
        if (!billOpt.isPresent()) {
            throw new IllegalArgumentException("Bill not found");
        }

        Bill bill = billOpt.get();

        if (bill.isPaid()) {
            throw new IllegalArgumentException("Bill is already paid");
        }

        if (amount.compareTo(bill.getBalanceDue()) > 0) {
            throw new IllegalArgumentException("Payment amount exceeds balance due");
        }

        bill.addPayment(amount);
        bill.setPaymentMethod(method);
        bill.setPaymentDate(java.time.LocalDateTime.now());

        return billDAO.update(bill);
    }

    public Bill markAsPaid(Long billId, Bill.PaymentMethod method)
            throws SQLException, IllegalArgumentException {

        Optional<Bill> billOpt = billDAO.findById(billId);
        if (!billOpt.isPresent()) {
            throw new IllegalArgumentException("Bill not found");
        }

        Bill bill = billOpt.get();
        bill.setPaidAmount(bill.getTotalAmount());
        bill.setBalanceDue(BigDecimal.ZERO);
        bill.setBillStatus(Bill.BillStatus.PAID);
        bill.setPaymentMethod(method);
        bill.setPaymentDate(java.time.LocalDateTime.now());

        return billDAO.update(bill);
    }

    public Bill updateBillStatus(Long id, Bill.BillStatus status)
            throws SQLException, IllegalArgumentException {

        Optional<Bill> billOpt = billDAO.findById(id);
        if (!billOpt.isPresent()) {
            throw new IllegalArgumentException("Bill not found");
        }

        Bill bill = billOpt.get();
        bill.setBillStatus(status);

        return billDAO.update(bill);
    }

    public void printBill(Long id) throws SQLException, IllegalArgumentException {
        Optional<Bill> billOpt = billDAO.findById(id);
        if (!billOpt.isPresent()) {
            throw new IllegalArgumentException("Bill not found");
        }
        billDAO.incrementPrintedCount(id);
    }

    public Bill cancelBill(Long id) throws SQLException, IllegalArgumentException {
        Optional<Bill> billOpt = billDAO.findById(id);
        if (!billOpt.isPresent()) {
            throw new IllegalArgumentException("Bill not found");
        }

        Bill bill = billOpt.get();
        bill.setBillStatus(Bill.BillStatus.CANCELLED);

        return billDAO.update(bill);
    }

    private String generateBillNumber() {
        return "BILL-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}