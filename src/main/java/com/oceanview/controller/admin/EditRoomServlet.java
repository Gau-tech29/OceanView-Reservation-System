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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Optional;

@WebServlet("/admin/rooms/edit")
public class EditRoomServlet extends HttpServlet {

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

        String roomId = request.getParameter("id");
        if (roomId == null || roomId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-rooms");
            return;
        }

        try {
            Optional<Room> roomOpt = roomService.getRoomById(Long.parseLong(roomId));
            if (roomOpt.isPresent()) {
                request.setAttribute("room", roomOpt.get());
                request.getRequestDispatcher("/WEB-INF/views/admin/rooms/edit.jsp")
                        .forward(request, response);
            } else {
                request.getSession().setAttribute("error", "Room not found");
                response.sendRedirect(request.getContextPath() + "/admin/manage-rooms");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/manage-rooms");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get room ID
            Long roomId = Long.parseLong(request.getParameter("id"));

            // Create room object from form data
            Room room = new Room();
            room.setId(roomId);
            room.setRoomNumber(request.getParameter("roomNumber"));
            room.setRoomType(Room.RoomType.valueOf(request.getParameter("roomType")));
            room.setRoomView(Room.RoomView.valueOf(request.getParameter("roomView")));
            room.setFloorNumber(Integer.parseInt(request.getParameter("floorNumber")));
            room.setCapacity(Integer.parseInt(request.getParameter("capacity")));
            room.setBasePrice(new BigDecimal(request.getParameter("basePrice")));

            if (request.getParameter("taxRate") != null && !request.getParameter("taxRate").isEmpty()) {
                room.setTaxRate(new BigDecimal(request.getParameter("taxRate")));
            }

            room.setAmenities(request.getParameter("amenities"));
            room.setDescription(request.getParameter("description"));
            room.setStatus(Room.RoomStatus.valueOf(request.getParameter("status")));
            room.setActive(request.getParameter("isActive") != null);

            // Update room
            Room updatedRoom = roomService.updateRoom(room);

            request.getSession().setAttribute("success",
                    "Room " + updatedRoom.getRoomNumber() + " updated successfully!");
            response.sendRedirect(request.getContextPath() + "/admin/manage-rooms");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format: " + e.getMessage());
            doGet(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Validation error: " + e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unexpected error: " + e.getMessage());
            doGet(request, response);
        }
    }
}