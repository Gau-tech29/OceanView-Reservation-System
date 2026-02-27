package com.oceanview.controller.admin;

import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/manage-rooms")
public class ManageRoomsServlet extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        roomService = new RoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        try {
            // Get filter parameters
            String typeFilter = request.getParameter("type");
            String statusFilter = request.getParameter("status");
            String floorFilter = request.getParameter("floor");

            List<Room> rooms;

            if (typeFilter != null && !typeFilter.isEmpty()) {
                rooms = roomService.getRoomsByType(Room.RoomType.valueOf(typeFilter));
            } else if (statusFilter != null && !statusFilter.isEmpty()) {
                rooms = roomService.getRoomsByStatus(Room.RoomStatus.valueOf(statusFilter));
            } else if (floorFilter != null && !floorFilter.isEmpty()) {
                rooms = roomService.getRoomsByFloor(Integer.parseInt(floorFilter));
            } else {
                rooms = roomService.getAllRooms();
            }

            // Get statistics
            long totalRooms = roomService.getTotalRooms();
            long availableRooms = roomService.getAvailableRoomsCount();

            request.setAttribute("rooms", rooms);
            request.setAttribute("totalRooms", totalRooms);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("selectedType", typeFilter);
            request.setAttribute("selectedStatus", statusFilter);
            request.setAttribute("selectedFloor", floorFilter);

            // Get counts by status for summary cards
            long occupiedCount = roomService.getRoomsByStatus(Room.RoomStatus.OCCUPIED).size();
            long maintenanceCount = roomService.getRoomsByStatus(Room.RoomStatus.MAINTENANCE).size();
            long reservedCount = roomService.getRoomsByStatus(Room.RoomStatus.RESERVED).size();

            request.setAttribute("occupiedCount", occupiedCount);
            request.setAttribute("maintenanceCount", maintenanceCount);
            request.setAttribute("reservedCount", reservedCount);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load rooms: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid filter value: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/rooms/list.jsp")
                .forward(request, response);
    }
}