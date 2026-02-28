package com.oceanview.api;

import com.oceanview.dto.GuestDTO;
import com.oceanview.service.GuestService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/guests/search")
public class ApiServlet extends HttpServlet {

    private GuestService guestService;

    @Override
    public void init() throws ServletException {
        guestService = new GuestService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        PrintWriter out = response.getWriter();

        try {
            List<GuestDTO> guests = guestService.searchGuests(keyword);
            out.print(convertToJson(guests));
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Database error\"}");
        } finally {
            out.flush();
        }
    }

    private String convertToJson(List<GuestDTO> guests) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < guests.size(); i++) {
            GuestDTO g = guests.get(i);
            json.append("{")
                    .append("\"id\":").append(g.getId()).append(",")
                    .append("\"guestNumber\":\"").append(escapeJson(g.getGuestNumber())).append("\",")
                    .append("\"fullName\":\"").append(escapeJson(g.getFullName())).append("\",")
                    .append("\"email\":\"").append(escapeJson(g.getEmail())).append("\",")
                    .append("\"phone\":\"").append(escapeJson(g.getPhone())).append("\"")
                    .append("}");
            if (i < guests.size() - 1) json.append(",");
        }
        json.append("]");
        return json.toString();
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