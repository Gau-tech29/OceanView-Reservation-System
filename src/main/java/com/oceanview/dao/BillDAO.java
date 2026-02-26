package com.oceanview.dao;

import com.oceanview.model.Bill;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface BillDAO extends BaseDAO<Bill, Long> {
    Optional<Bill> findByBillNumber(String billNumber) throws SQLException;
    List<Bill> findByReservationId(Long reservationId) throws SQLException;
    List<Bill> findByGuestId(Long guestId) throws SQLException;
    List<Bill> findByStatus(Bill.BillStatus status) throws SQLException;
    List<Bill> findByDateRange(LocalDate start, LocalDate end) throws SQLException;
    List<Bill> findOverdueBills() throws SQLException;
    double getTotalRevenueByDateRange(LocalDate start, LocalDate end) throws SQLException;
    boolean updateStatus(Long id, Bill.BillStatus status) throws SQLException;
    boolean incrementPrintedCount(Long id) throws SQLException;
}