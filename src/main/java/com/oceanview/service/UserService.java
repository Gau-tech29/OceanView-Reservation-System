package com.oceanview.service;

import com.oceanview.model.User;
import com.oceanview.dao.UserDAO;
import com.oceanview.dao.impl.UserDAOImpl;
import com.oceanview.util.PasswordUtils;
import com.oceanview.util.ValidationUtils;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class UserService {

    private final UserDAO userDAO;

    // Dependency Injection
    public UserService() {
        this.userDAO = UserDAOImpl.getInstance();
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public Optional<User> login(String username, String password) throws SQLException {
        if (!ValidationUtils.isValidUsername(username) || !ValidationUtils.isValidPassword(password)) {
            return Optional.empty();
        }

        if (userDAO.authenticate(username, password)) {
            Optional<User> userOpt = userDAO.findByUsername(username);
            userOpt.ifPresent(user -> {
                try {
                    userDAO.updateLastLogin(user.getId());
                } catch (SQLException e) {
                    // Log error but don't fail login
                }
            });
            return userOpt;
        }

        return Optional.empty();
    }

    public User createUser(User user, String password) throws SQLException, IllegalArgumentException {
        // Validate user data
        if (!ValidationUtils.isValidUsername(user.getUsername())) {
            throw new IllegalArgumentException("Invalid username format");
        }

        if (!ValidationUtils.isValidPassword(password)) {
            throw new IllegalArgumentException("Password must be at least 8 characters with mixed case and numbers");
        }

        if (!ValidationUtils.isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }

        if (!ValidationUtils.isValidPhone(user.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }

        // Check if username already exists
        if (userDAO.findByUsername(user.getUsername()).isPresent()) {
            throw new IllegalArgumentException("Username already exists");
        }

        // Check if email already exists
        if (userDAO.findByEmail(user.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }

        // Hash password and save
        user.setPassword(PasswordUtils.hashPassword(password));
        return userDAO.save(user);
    }

    public Optional<User> getUserById(Long id) throws SQLException {
        return userDAO.findById(id);
    }

    public Optional<User> getUserByUsername(String username) throws SQLException {
        return userDAO.findByUsername(username);
    }

    public List<User> getAllUsers() throws SQLException {
        return userDAO.findAll();
    }

    public List<User> getUsersByRole(User.UserRole role) throws SQLException {
        return userDAO.findByRole(role);
    }

    public User updateUser(User user) throws SQLException, IllegalArgumentException {
        // Validate user data
        if (!ValidationUtils.isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }

        if (!ValidationUtils.isValidPhone(user.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }

        // Check if email already exists for another user
        Optional<User> existingUser = userDAO.findByEmail(user.getEmail());
        if (existingUser.isPresent() && !existingUser.get().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Email already exists for another user");
        }

        return userDAO.update(user);
    }

    public boolean changePassword(Long userId, String oldPassword, String newPassword) throws SQLException, IllegalArgumentException {
        Optional<User> userOpt = userDAO.findById(userId);

        if (!userOpt.isPresent()) {
            throw new IllegalArgumentException("User not found");
        }

        User user = userOpt.get();

        // Verify old password
        if (!PasswordUtils.checkPassword(oldPassword, user.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        // Validate new password
        if (!ValidationUtils.isValidPassword(newPassword)) {
            throw new IllegalArgumentException("New password must be at least 8 characters with mixed case and numbers");
        }

        return userDAO.changePassword(userId, newPassword);
    }

    public boolean deactivateUser(Long userId) throws SQLException {
        Optional<User> userOpt = userDAO.findById(userId);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setActive(false);
            userDAO.update(user);
            return true;
        }

        return false;
    }

    public boolean activateUser(Long userId) throws SQLException {
        Optional<User> userOpt = userDAO.findById(userId);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setActive(true);
            userDAO.update(user);
            return true;
        }

        return false;
    }

    public long getTotalUsers() throws SQLException {
        return userDAO.count();
    }
}