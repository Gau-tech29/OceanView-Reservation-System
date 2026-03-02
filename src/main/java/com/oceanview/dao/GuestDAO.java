package com.oceanview.dao;

import com.oceanview.model.Guest;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * DAO interface for Guest entity.
 */
public interface GuestDAO extends BaseDAO<Guest, Long> {

    Optional<Guest> findByEmail(String email)         throws SQLException;
    Optional<Guest> findByGuestNumber(String number)  throws SQLException;
    List<Guest> findByName(String name)                throws SQLException;
    List<Guest> findByPhone(String phone)              throws SQLException;
    List<Guest> searchGuests(String keyword)           throws SQLException;
    long countActiveGuests()                           throws SQLException;

    /**
     * Returns the top {@code limit} guests ordered by number of reservations (most stays first).
     * Used by ReportService for the monthly report.
     */
    List<Guest> findTopGuests(int limit)               throws SQLException;
}