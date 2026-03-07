package com.oceanview.test.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Test database configuration - creates schema matching your MySQL database
 */
public class TestDatabaseConfig {

    public static void setupTestDatabase() throws SQLException {
        try (Connection conn = com.oceanview.test.util.TestDBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            // Create users table
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "username VARCHAR(50) UNIQUE NOT NULL, " +
                    "password VARCHAR(255) NOT NULL, " +
                    "first_name VARCHAR(100) NOT NULL, " +
                    "last_name VARCHAR(100) NOT NULL, " +
                    "email VARCHAR(255) UNIQUE NOT NULL, " +
                    "phone VARCHAR(20), " +
                    "role VARCHAR(20) NOT NULL, " +
                    "active BOOLEAN DEFAULT TRUE, " +
                    "last_login TIMESTAMP NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Create guests table
            stmt.execute("CREATE TABLE IF NOT EXISTS guests (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "guest_number VARCHAR(20) UNIQUE NOT NULL, " +
                    "first_name VARCHAR(100) NOT NULL, " +
                    "last_name VARCHAR(100) NOT NULL, " +
                    "email VARCHAR(255), " +
                    "phone VARCHAR(20), " +
                    "address TEXT, " +
                    "city VARCHAR(100), " +
                    "country VARCHAR(100), " +
                    "postal_code VARCHAR(20), " +
                    "id_card_number VARCHAR(50), " +
                    "id_card_type VARCHAR(20), " +
                    "is_vip BOOLEAN DEFAULT FALSE, " +
                    "loyalty_points INT DEFAULT 0, " +
                    "notes TEXT, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Create rooms table
            stmt.execute("CREATE TABLE IF NOT EXISTS rooms (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "room_number VARCHAR(10) UNIQUE NOT NULL, " +
                    "room_type VARCHAR(20) NOT NULL, " +
                    "room_view VARCHAR(20) NOT NULL, " +
                    "floor_number INT, " +
                    "capacity INT NOT NULL, " +
                    "base_price DECIMAL(10,2) NOT NULL, " +
                    "tax_rate DECIMAL(5,2) DEFAULT 12.00, " +
                    "amenities TEXT, " +
                    "description TEXT, " +
                    "status VARCHAR(20) DEFAULT 'AVAILABLE', " +
                    "is_active BOOLEAN DEFAULT TRUE, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Create reservations table
            stmt.execute("CREATE TABLE IF NOT EXISTS reservations (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "reservation_number VARCHAR(20) UNIQUE NOT NULL, " +
                    "guest_id BIGINT NOT NULL, " +
                    "user_id BIGINT, " +
                    "number_of_rooms INT NOT NULL DEFAULT 1, " +
                    "check_in_date DATE NOT NULL, " +
                    "check_out_date DATE NOT NULL, " +
                    "adults INT DEFAULT 1, " +
                    "children INT DEFAULT 0, " +
                    "total_nights INT, " +
                    "room_price DECIMAL(10,2), " +
                    "tax_amount DECIMAL(10,2) DEFAULT 0, " +
                    "discount_amount DECIMAL(10,2) DEFAULT 0, " +
                    "subtotal DECIMAL(10,2), " +
                    "total_amount DECIMAL(10,2), " +
                    "payment_status VARCHAR(20) DEFAULT 'PENDING', " +
                    "reservation_status VARCHAR(20) DEFAULT 'CONFIRMED', " +
                    "special_requests TEXT, " +
                    "source VARCHAR(20) DEFAULT 'WALK_IN', " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Create reservation_rooms junction table
            stmt.execute("CREATE TABLE IF NOT EXISTS reservation_rooms (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "reservation_id BIGINT NOT NULL, " +
                    "room_id BIGINT NOT NULL, " +
                    "room_price DECIMAL(10,2) NOT NULL, " +
                    "UNIQUE KEY unique_reservation_room (reservation_id, room_id))");

            // Create payments table
            stmt.execute("CREATE TABLE IF NOT EXISTS payments (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "payment_number VARCHAR(20) UNIQUE NOT NULL, " +
                    "reservation_id BIGINT NOT NULL, " +
                    "amount DECIMAL(10,2) NOT NULL, " +
                    "payment_method VARCHAR(20) NOT NULL, " +
                    "payment_status VARCHAR(20) DEFAULT 'PENDING', " +
                    "transaction_id VARCHAR(100), " +
                    "card_last_four VARCHAR(4), " +
                    "notes TEXT, " +
                    "payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Create bills table
            stmt.execute("CREATE TABLE IF NOT EXISTS bills (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "bill_number VARCHAR(20) UNIQUE NOT NULL, " +
                    "reservation_id BIGINT NOT NULL, " +
                    "guest_id BIGINT NOT NULL, " +
                    "user_id BIGINT, " +
                    "issue_date DATE NOT NULL, " +
                    "due_date DATE, " +
                    "check_in_date DATE NOT NULL, " +
                    "check_out_date DATE NOT NULL, " +
                    "room_charges DECIMAL(10,2) NOT NULL, " +
                    "additional_charges DECIMAL(10,2) DEFAULT 0, " +
                    "tax_amount DECIMAL(10,2) NOT NULL, " +
                    "discount_amount DECIMAL(10,2) DEFAULT 0, " +
                    "total_amount DECIMAL(10,2) NOT NULL, " +
                    "paid_amount DECIMAL(10,2) DEFAULT 0, " +
                    "bill_status VARCHAR(20) DEFAULT 'DRAFT', " +
                    "payment_method VARCHAR(20), " +
                    "payment_date TIMESTAMP NULL, " +
                    "notes TEXT, " +
                    "printed_count INT DEFAULT 0, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
        }
    }

    public static void cleanDatabase() throws SQLException {
        try (Connection conn = com.oceanview.test.util.TestDBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("SET REFERENTIAL_INTEGRITY FALSE");
            stmt.execute("TRUNCATE TABLE reservation_rooms");
            stmt.execute("TRUNCATE TABLE payments");
            stmt.execute("TRUNCATE TABLE bills");
            stmt.execute("TRUNCATE TABLE reservations");
            stmt.execute("TRUNCATE TABLE rooms");
            stmt.execute("TRUNCATE TABLE guests");
            stmt.execute("TRUNCATE TABLE users");
            stmt.execute("SET REFERENTIAL_INTEGRITY TRUE");
        }
    }

    public static void insertTestData() throws SQLException {
        try (Connection conn = com.oceanview.test.util.TestDBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            // Insert test user
            stmt.execute("INSERT INTO users (id, username, password, first_name, last_name, email, phone, role, active) " +
                    "VALUES (1, 'admin', '$2a$10$NkHhYcJqW5Q5Q5Q5Q5Q5Qe', 'Admin', 'User', 'admin@test.com', '1234567890', 'ADMIN', true)");

            // Insert test guests
            stmt.execute("INSERT INTO guests (id, guest_number, first_name, last_name, email, phone) " +
                    "VALUES (1, 'GST-001', 'John', 'Doe', 'john@test.com', '123-456-7890')");
            stmt.execute("INSERT INTO guests (id, guest_number, first_name, last_name, email, phone) " +
                    "VALUES (2, 'GST-002', 'Jane', 'Smith', 'jane@test.com', '098-765-4321')");

            // Insert test rooms
            stmt.execute("INSERT INTO rooms (id, room_number, room_type, room_view, floor_number, capacity, base_price, status) " +
                    "VALUES (1, '101', 'DELUXE', 'OCEAN_VIEW', 1, 2, 150.00, 'AVAILABLE')");
            stmt.execute("INSERT INTO rooms (id, room_number, room_type, room_view, floor_number, capacity, base_price, status) " +
                    "VALUES (2, '102', 'DELUXE', 'GARDEN_VIEW', 1, 2, 130.00, 'AVAILABLE')");
            stmt.execute("INSERT INTO rooms (id, room_number, room_type, room_view, floor_number, capacity, base_price, status) " +
                    "VALUES (3, '201', 'SUITE', 'OCEAN_VIEW', 2, 4, 250.00, 'AVAILABLE')");
        }
    }
}