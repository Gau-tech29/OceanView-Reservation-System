package com.oceanview.api;

import com.oceanview.dto.RoomDTO;
import com.oceanview.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Endpoint: GET /api/rooms/available?checkIn=YYYY-MM-DD&checkOut=YYYY-MM-DD[&excludeRoomId=123]
 *
 * Returns JSON array of rooms with NO overlapping CONFIRMED/CHECKED_IN reservation.
 * Both check-in and check-out dates are treated as INCLUSIVE (occupied days).
 *
 * The optional excludeRoomId parameter lets the frontend exclude the already-selected
 * first room from the second room's available list (so user can't pick the same room twice).
 *
 * Save as: src/main/java/com/oceanview/api/RoomAvailabilityApiServlet.java
 */
@WebServlet("/api/rooms/available")
public class RoomAvailabilityApiServlet extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        roomService = new RoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String checkInStr  = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String excludeStr  = request.getParameter("excludeRoomId"); // optional

        if (checkInStr == null || checkOutStr == null
                || checkInStr.trim().isEmpty() || checkOutStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"checkIn and checkOut parameters are required\"}");
            out.flush();
            return;
        }

        try {
            LocalDate checkIn  = LocalDate.parse(checkInStr.trim());
            LocalDate checkOut = LocalDate.parse(checkOutStr.trim());

            if (checkOut.isBefore(checkIn)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"checkOut must not be before checkIn\"}");
                out.flush();
                return;
            }

            List<RoomDTO> rooms = roomService.getAvailableRoomsForDates(checkIn, checkOut);

            // Exclude an already-selected room (for 2nd room picker)
            if (excludeStr != null && !excludeStr.trim().isEmpty()) {
                try {
                    final long excludeId = Long.parseLong(excludeStr.trim());
                    rooms = rooms.stream()
                            .filter(r -> r.getId() != null && r.getId() != excludeId)
                            .collect(Collectors.toList());
                } catch (NumberFormatException ignored) { /* bad param — just ignore */ }
            }

            out.print(toJson(rooms));

        } catch (DateTimeParseException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid date format. Use YYYY-MM-DD.\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Database error: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            out.flush();
        }
    }

    // ── JSON serialiser ───────────────────────────────────────────────────────

    private String toJson(List<RoomDTO> rooms) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rooms.size(); i++) {
            RoomDTO r = rooms.get(i);
            sb.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"roomNumber\":\"").append(escapeJson(r.getRoomNumber())).append("\",")
                    .append("\"roomType\":\"").append(escapeJson(r.getRoomType())).append("\",")
                    .append("\"roomView\":\"").append(escapeJson(r.getRoomView())).append("\",")
                    .append("\"floorNumber\":").append(r.getFloorNumber() != null ? r.getFloorNumber() : 0).append(",")
                    .append("\"capacity\":").append(r.getCapacity() != null ? r.getCapacity() : 0).append(",")
                    .append("\"basePrice\":").append(r.getBasePrice() != null ? r.getBasePrice().toPlainString() : "0").append(",")
                    .append("\"taxRate\":").append(r.getTaxRate() != null ? r.getTaxRate().toPlainString() : "12").append(",")
                    .append("\"amenities\":\"").append(escapeJson(r.getAmenities())).append("\",")
                    .append("\"description\":\"").append(escapeJson(r.getDescription())).append("\"")
                    .append("}");
            if (i < rooms.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
