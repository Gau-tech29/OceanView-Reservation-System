package com.oceanview.controller;

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
import java.util.stream.Collectors;

@WebServlet("/staff/rooms")
public class StaffRoomsServlet extends HttpServlet {

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
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
            return;
        }

        String search       = request.getParameter("search");
        String typeFilter   = request.getParameter("type");
        String statusFilter = request.getParameter("status");
        String viewFilter   = request.getParameter("roomView");
        String floorFilter  = request.getParameter("floor");

        try {
            List<Room> allRooms = roomService.getAllRooms();

            List<Room> filtered = allRooms.stream()
                    .filter(r -> {
                        if (search != null && !search.trim().isEmpty()) {
                            String q = search.trim().toLowerCase();
                            return (r.getRoomNumber()  != null && r.getRoomNumber().toLowerCase().contains(q))
                                    || (r.getAmenities()   != null && r.getAmenities().toLowerCase().contains(q))
                                    || (r.getDescription() != null && r.getDescription().toLowerCase().contains(q));
                        }
                        return true;
                    })
                    .filter(r -> (typeFilter   == null || typeFilter.isEmpty()   || (r.getRoomType() != null && typeFilter.equals(r.getRoomType().name()))))
                    .filter(r -> (statusFilter == null || statusFilter.isEmpty() || (r.getStatus()   != null && statusFilter.equals(r.getStatus().name()))))
                    .filter(r -> (viewFilter   == null || viewFilter.isEmpty()   || (r.getRoomView() != null && viewFilter.equals(r.getRoomView().name()))))
                    .filter(r -> {
                        if (floorFilter != null && !floorFilter.isEmpty()) {
                            try { return r.getFloorNumber() != null && r.getFloorNumber() == Integer.parseInt(floorFilter); }
                            catch (NumberFormatException e) { return true; }
                        }
                        return true;
                    })
                    .collect(Collectors.toList());

            long totalRooms       = allRooms.size();
            long availableRooms   = allRooms.stream().filter(r -> r.getStatus() == Room.RoomStatus.AVAILABLE).count();
            long occupiedRooms    = allRooms.stream().filter(r -> r.getStatus() == Room.RoomStatus.OCCUPIED).count();
            long maintenanceRooms = allRooms.stream().filter(r -> r.getStatus() == Room.RoomStatus.MAINTENANCE).count();
            long reservedRooms    = allRooms.stream().filter(r -> r.getStatus() == Room.RoomStatus.RESERVED).count();

            List<Integer> floors = allRooms.stream()
                    .map(Room::getFloorNumber).filter(f -> f != null)
                    .distinct().sorted().collect(Collectors.toList());

            request.setAttribute("rooms",            filtered);
            request.setAttribute("totalRooms",       totalRooms);
            request.setAttribute("availableRooms",   availableRooms);
            request.setAttribute("occupiedRooms",    occupiedRooms);
            request.setAttribute("maintenanceRooms", maintenanceRooms);
            request.setAttribute("reservedRooms",    reservedRooms);
            request.setAttribute("floors",           floors);
            request.setAttribute("filteredCount",    filtered.size());

            request.setAttribute("searchParam",   search      != null ? search      : "");
            request.setAttribute("typeParam",     typeFilter  != null ? typeFilter   : "");
            request.setAttribute("statusParam",   statusFilter!= null ? statusFilter : "");
            request.setAttribute("roomViewParam", viewFilter  != null ? viewFilter   : "");
            request.setAttribute("floorParam",    floorFilter != null ? floorFilter  : "");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Failed to load rooms: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/staff/rooms.jsp")
                .forward(request, response);
    }
}