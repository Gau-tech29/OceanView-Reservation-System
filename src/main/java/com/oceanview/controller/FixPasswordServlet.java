package com.oceanview.controller;

import com.oceanview.util.DBConnection;
import com.oceanview.util.PasswordUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/fix-passwords")
public class FixPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<html><head><title>Fix Passwords</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; padding: 20px; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println("</style>");
        out.println("</head><body>");

        out.println("<h2>🔧 Password Fix Utility</h2>");

        try (Connection conn = DBConnection.getConnection()) {

            // Fix admin password
            String adminPassword = "Admin@1234";
            String adminHash = PasswordUtils.hashPassword(adminPassword);

            String updateAdmin = "UPDATE users SET password = ? WHERE username = 'admin'";
            try (PreparedStatement ps = conn.prepareStatement(updateAdmin)) {
                ps.setString(1, adminHash);
                int updated = ps.executeUpdate();
                if (updated > 0) {
                    out.println("<p class='success'>✅ Admin password updated to: " + adminPassword + "</p>");
                    out.println("<p>Hash: " + adminHash + "</p>");
                }
            }

            // Fix staff password
            String staffPassword = "Staff@1234";
            String staffHash = PasswordUtils.hashPassword(staffPassword);

            String updateStaff = "UPDATE users SET password = ? WHERE username = 'staff'";
            try (PreparedStatement ps = conn.prepareStatement(updateStaff)) {
                ps.setString(1, staffHash);
                int updated = ps.executeUpdate();
                if (updated > 0) {
                    out.println("<p class='success'>✅ Staff password updated to: " + staffPassword + "</p>");
                    out.println("<p>Hash: " + staffHash + "</p>");
                }
            }

            // Verify the updates
            out.println("<h3>Verification:</h3>");
            String verify = "SELECT username, password FROM users WHERE username IN ('admin', 'staff')";
            try (PreparedStatement ps = conn.prepareStatement(verify);
                 ResultSet rs = ps.executeQuery()) {

                out.println("<table border='1' cellpadding='8'>");
                out.println("<tr><th>Username</th><th>Password Test</th><th>Result</th></tr>");

                while (rs.next()) {
                    String username = rs.getString("username");
                    String hash = rs.getString("password");

                    String testPass = username.equals("admin") ? "Admin@1234" : "Staff@1234";
                    boolean matches = PasswordUtils.checkPassword(testPass, hash);

                    out.println("<tr>");
                    out.println("<td>" + username + "</td>");
                    out.println("<td>" + testPass + "</td>");
                    out.println("<td>" + (matches ? "✅ MATCHES" : "❌ DOES NOT MATCH") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }

            out.println("<p><a href='" + request.getContextPath() + "/diagnostic'>Back to Diagnostic</a></p>");
            out.println("<p><a href='" + request.getContextPath() + "/login'>Go to Login</a></p>");

        } catch (SQLException e) {
            out.println("<p class='error'>❌ Database error: " + e.getMessage() + "</p>");
        }

        out.println("</body></html>");
    }
}