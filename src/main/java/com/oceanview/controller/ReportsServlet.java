package com.oceanview.controller;

import com.oceanview.model.User;
import com.oceanview.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/reports")
public class ReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login"); return;
        }
        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard"); return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            loadOverview(conn, request);
            loadRevenue(conn, request);
            loadReservations(conn, request);
            loadGuests(conn, request);
            loadRooms(conn, request);
            loadStaff(conn, request);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("dbError", e.getMessage());
        }

        request.setAttribute("activePage", "reports");
        request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
    }

    // ── Overview ──────────────────────────────────────────────────────────────
    private void loadOverview(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("totalRevenue",       scalar(c, "SELECT COALESCE(SUM(total_amount),0) FROM bills WHERE bill_status IN ('PAID','PARTIALLY_PAID')"));
        r.setAttribute("totalReservations",  scalar(c, "SELECT COUNT(*) FROM reservations"));
        r.setAttribute("totalGuests",        scalar(c, "SELECT COUNT(*) FROM guests"));
        r.setAttribute("totalRooms",         scalar(c, "SELECT COUNT(*) FROM rooms WHERE is_active=1"));
        r.setAttribute("availableRooms",     scalar(c, "SELECT COUNT(*) FROM rooms WHERE status='AVAILABLE' AND is_active=1"));
        r.setAttribute("occupiedRooms",      scalar(c, "SELECT COUNT(*) FROM rooms WHERE status='OCCUPIED' AND is_active=1"));
        r.setAttribute("pendingPayments",    scalar(c, "SELECT COUNT(*) FROM bills WHERE bill_status IN ('DRAFT','ISSUED','PARTIALLY_PAID')"));
        r.setAttribute("monthRevenue",       scalar(c, "SELECT COALESCE(SUM(total_amount),0) FROM bills WHERE bill_status IN ('PAID','PARTIALLY_PAID') AND MONTH(issue_date)=MONTH(CURDATE()) AND YEAR(issue_date)=YEAR(CURDATE())"));
        r.setAttribute("activeStaff",        scalar(c, "SELECT COUNT(*) FROM users WHERE active=1"));
    }

    // ── Revenue ───────────────────────────────────────────────────────────────
    private void loadRevenue(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("billStatusList",  list(c, "SELECT bill_status, COUNT(*) as cnt, COALESCE(SUM(total_amount),0) as total FROM bills GROUP BY bill_status ORDER BY cnt DESC"));
        r.setAttribute("paymentMethods",  list(c, "SELECT payment_method, COUNT(*) as cnt, COALESCE(SUM(amount),0) as total FROM payments GROUP BY payment_method ORDER BY total DESC"));
        r.setAttribute("monthlyRevenue",  list(c, "SELECT DATE_FORMAT(issue_date,'%b %Y') as month_label, DATE_FORMAT(issue_date,'%Y-%m') as month_key, COALESCE(SUM(total_amount),0) as revenue, COALESCE(SUM(tax_amount),0) as tax, COALESCE(SUM(discount_amount),0) as discount FROM bills WHERE issue_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) GROUP BY month_key, month_label ORDER BY month_key ASC"));
        r.setAttribute("topBills",        list(c, "SELECT b.bill_number, g.first_name, g.last_name, b.total_amount, b.bill_status, b.issue_date FROM bills b JOIN guests g ON b.guest_id=g.id ORDER BY b.total_amount DESC LIMIT 5"));
        r.setAttribute("totalDiscounts",  scalar(c, "SELECT COALESCE(SUM(discount_amount),0) FROM bills"));
        r.setAttribute("totalTax",        scalar(c, "SELECT COALESCE(SUM(tax_amount),0) FROM bills WHERE bill_status='PAID'"));
        r.setAttribute("avgBillValue",    scalar(c, "SELECT COALESCE(AVG(total_amount),0) FROM bills WHERE bill_status='PAID'"));
        r.setAttribute("outstandingBalance", scalar(c, "SELECT COALESCE(SUM(balance_due),0) FROM bills WHERE bill_status NOT IN ('PAID')"));
    }

    // ── Reservations ──────────────────────────────────────────────────────────
    private void loadReservations(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("reservationStatusList",   list(c, "SELECT reservation_status, COUNT(*) as cnt FROM reservations GROUP BY reservation_status ORDER BY cnt DESC"));
        r.setAttribute("bookingSources",          list(c, "SELECT source, COUNT(*) as cnt, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM reservations),1) as pct FROM reservations GROUP BY source ORDER BY cnt DESC"));
        r.setAttribute("reservationPaymentStatus",list(c, "SELECT payment_status, COUNT(*) as cnt FROM reservations GROUP BY payment_status ORDER BY cnt DESC"));
        r.setAttribute("monthlyReservations",     list(c, "SELECT DATE_FORMAT(created_at,'%b %Y') as month_label, DATE_FORMAT(created_at,'%Y-%m') as month_key, COUNT(*) as total, SUM(CASE WHEN reservation_status='CONFIRMED' THEN 1 ELSE 0 END) as confirmed, SUM(CASE WHEN reservation_status='CANCELLED' THEN 1 ELSE 0 END) as cancelled FROM reservations WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) GROUP BY month_key, month_label ORDER BY month_key ASC"));
        r.setAttribute("avgNights",               scalar(c, "SELECT COALESCE(ROUND(AVG(total_nights),1),0) FROM reservations"));
        r.setAttribute("avgGuests",               scalar(c, "SELECT COALESCE(ROUND(AVG(adults+children),1),0) FROM reservations"));
        r.setAttribute("thisMonthReservations",   scalar(c, "SELECT COUNT(*) FROM reservations WHERE MONTH(created_at)=MONTH(CURDATE()) AND YEAR(created_at)=YEAR(CURDATE())"));
        r.setAttribute("cancelledReservations",   scalar(c, "SELECT COUNT(*) FROM reservations WHERE reservation_status='CANCELLED'"));
    }

    // ── Guests ────────────────────────────────────────────────────────────────
    private void loadGuests(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("vipGuests",          scalar(c, "SELECT COUNT(*) FROM guests WHERE is_vip=1"));
        r.setAttribute("totalLoyaltyPoints", scalar(c, "SELECT COALESCE(SUM(loyalty_points),0) FROM guests"));
        r.setAttribute("newGuestsThisMonth", scalar(c, "SELECT COUNT(*) FROM guests WHERE MONTH(created_at)=MONTH(CURDATE()) AND YEAR(created_at)=YEAR(CURDATE())"));
        r.setAttribute("guestCountries",     list(c, "SELECT country, COUNT(*) as cnt FROM guests WHERE country IS NOT NULL AND country!='' GROUP BY country ORDER BY cnt DESC LIMIT 8"));
        r.setAttribute("idCardTypes",        list(c, "SELECT id_card_type, COUNT(*) as cnt FROM guests GROUP BY id_card_type ORDER BY cnt DESC"));
        r.setAttribute("topGuests",          list(c, "SELECT g.first_name, g.last_name, g.email, g.is_vip, g.loyalty_points, COUNT(r.id) as reservation_count, COALESCE(SUM(r.total_amount),0) as total_spent FROM guests g LEFT JOIN reservations r ON g.id=r.guest_id GROUP BY g.id, g.first_name, g.last_name, g.email, g.is_vip, g.loyalty_points ORDER BY total_spent DESC LIMIT 5"));
        r.setAttribute("guestCities",        list(c, "SELECT city, COUNT(*) as cnt FROM guests WHERE city IS NOT NULL AND city!='' GROUP BY city ORDER BY cnt DESC LIMIT 6"));
    }

    // ── Rooms ─────────────────────────────────────────────────────────────────
    private void loadRooms(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("roomTypes",       list(c, "SELECT room_type, COUNT(*) as cnt, ROUND(AVG(base_price),2) as avg_price, SUM(CASE WHEN status='AVAILABLE' THEN 1 ELSE 0 END) as available, SUM(CASE WHEN status='OCCUPIED' THEN 1 ELSE 0 END) as occupied FROM rooms WHERE is_active=1 GROUP BY room_type ORDER BY avg_price DESC"));
        r.setAttribute("roomViews",       list(c, "SELECT room_view, COUNT(*) as cnt FROM rooms WHERE is_active=1 GROUP BY room_view ORDER BY cnt DESC"));
        r.setAttribute("roomStatusList",  list(c, "SELECT status, COUNT(*) as cnt FROM rooms WHERE is_active=1 GROUP BY status ORDER BY cnt DESC"));
        r.setAttribute("mostBookedRooms", list(c, "SELECT r.room_type, r.room_number, r.room_view, r.base_price, COUNT(rr.id) as booking_count, COALESCE(SUM(rr.room_price),0) as total_earned FROM rooms r LEFT JOIN reservation_rooms rr ON r.id=rr.room_id WHERE r.is_active=1 GROUP BY r.id, r.room_type, r.room_number, r.room_view, r.base_price ORDER BY booking_count DESC LIMIT 8"));
        r.setAttribute("floorDistribution",list(c, "SELECT floor_number, COUNT(*) as cnt, SUM(CASE WHEN status='AVAILABLE' THEN 1 ELSE 0 END) as available FROM rooms WHERE is_active=1 GROUP BY floor_number ORDER BY floor_number ASC"));
        r.setAttribute("avgRoomPrice",    scalar(c, "SELECT COALESCE(ROUND(AVG(base_price),2),0) FROM rooms WHERE is_active=1"));
        r.setAttribute("maintenanceRooms",scalar(c, "SELECT COUNT(*) FROM rooms WHERE status='MAINTENANCE'"));
    }

    // ── Staff ─────────────────────────────────────────────────────────────────
    private void loadStaff(Connection c, HttpServletRequest r) throws SQLException {
        r.setAttribute("staffByRole",    list(c, "SELECT role, COUNT(*) as cnt FROM users GROUP BY role ORDER BY cnt DESC"));
        r.setAttribute("staffStatus",    list(c, "SELECT CASE WHEN active=1 THEN 'Active' ELSE 'Inactive' END as status, COUNT(*) as cnt FROM users GROUP BY active"));
        r.setAttribute("staffActivity",  list(c, "SELECT u.first_name, u.last_name, u.role, u.active, COUNT(r.id) as reservations_handled, COALESCE(SUM(r.total_amount),0) as revenue_handled, u.last_login FROM users u LEFT JOIN reservations r ON u.id=r.user_id GROUP BY u.id, u.first_name, u.last_name, u.role, u.active, u.last_login ORDER BY reservations_handled DESC"));
        r.setAttribute("recentLogins",   list(c, "SELECT first_name, last_name, role, last_login FROM users WHERE last_login IS NOT NULL ORDER BY last_login DESC LIMIT 5"));
        r.setAttribute("staffBills",     list(c, "SELECT u.first_name, u.last_name, u.role, COUNT(b.id) as bills_count, COALESCE(SUM(b.total_amount),0) as bills_total FROM users u LEFT JOIN bills b ON u.id=b.user_id GROUP BY u.id, u.first_name, u.last_name, u.role ORDER BY bills_count DESC"));
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private String scalar(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Object v = rs.getObject(1);
                if (v == null) return "0";
                if (v instanceof java.math.BigDecimal) return String.format("%.2f", v);
                return v.toString();
            }
        }
        return "0";
    }

    private List<Map<String,Object>> list(Connection conn, String sql) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData m = rs.getMetaData();
            int cols = m.getColumnCount();
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) {
                    Object v = rs.getObject(i);
                    if (v instanceof java.math.BigDecimal) v = String.format("%.2f", v);
                    row.put(m.getColumnLabel(i), v != null ? v : "");
                }
                out.add(row);
            }
        }
        return out;
    }
}