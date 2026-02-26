package com.oceanview.dao;

import com.oceanview.model.Guest;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public interface GuestDAO extends BaseDAO<Guest, Long> {
    Optional<Guest> findByGuestNumber(String guestNumber) throws SQLException;
    Optional<Guest> findByEmail(String email) throws SQLException;
    Optional<Guest> findByPhone(String phone) throws SQLException;
    List<Guest> findByName(String firstName, String lastName) throws SQLException;
    List<Guest> findVipGuests() throws SQLException;
    List<Guest> findTopGuests(int limit) throws SQLException;
    boolean updateLoyaltyPoints(Long id, int points) throws SQLException;
    boolean markAsVip(Long id) throws SQLException;
}