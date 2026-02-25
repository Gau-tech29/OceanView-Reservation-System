package com.oceanview.dao;

import com.oceanview.model.User;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public interface UserDAO extends BaseDAO<User, Long> {
    boolean authenticate(String username, String password) throws SQLException;
    Optional<User> findByUsername(String username) throws SQLException;
    Optional<User> findByEmail(String email) throws SQLException;
    List<User> findByRole(User.UserRole role) throws SQLException;
    boolean changePassword(Long userId, String newPassword) throws SQLException;
    void updateLastLogin(Long userId) throws SQLException;
}