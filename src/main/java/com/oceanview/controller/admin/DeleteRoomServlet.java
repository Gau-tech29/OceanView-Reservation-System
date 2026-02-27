package com.oceanview.controller.admin;

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

@WebServlet("/admin/rooms/delete")
public class DeleteRoomServlet extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        roomService = new RoomService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
            boolean deleted = roomService.deleteRoom(Long.parseLong(roomId));

            if (deleted) {
                request.getSession().setAttribute("success", "Room deleted successfully!");
            } else {
                request.getSession().setAttribute("error", "Failed to delete room");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-rooms");
    }
}