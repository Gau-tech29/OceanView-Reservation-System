package com.oceanview.controller;

import com.oceanview.util.DBConnection;
import com.oceanview.util.PasswordUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/diagnostic")
public class DiagnosticServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<html>");
        out.println("<head>");
        out.println("<style>");
        out.println("body { font-family: monospace; padding: 30px; background: #f4f4f4; }");
        out.println(".box { background: white; padding: 20px; border-radius: 10px;");
        out.println("margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }");
        out.println(".ok  { color: green; font-weight: bold; }");
        out.println(".err { color: red; font-weight: bold; }");
        out.println(".warn{ color: orange; font-weight: bold; }");
        out.println("table { border-collapse: collapse; width: 100%; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }");
        out.println("th { background: #0d6efd; color: white; }");
        out.println("tr:nth-child(even) { background: #f9f9f9; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h2>🔍 Ocean View — Diagnostic Report</h2>");

        // 1. JDBC Driver Check
        out.println("<div class='box'><h3>1. JDBC Driver</h3>");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            out.println("<p class='ok'>✅ MySQL JDBC Driver loaded successfully</p>");
        } catch (ClassNotFoundException e) {
            out.println("<p class='err'>❌ Driver NOT found: " + e.getMessage() + "</p>");
        }
        out.println("</div>");

        // 2. Database Connection Check
        out.println("<div class='box'><h3>2. Database Connection</h3>");
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            out.println("<p class='ok'>✅ Connected to database successfully</p>");

            DatabaseMetaData meta = conn.getMetaData();
            out.println("<p>URL: " + meta.getURL() + "</p>");
            out.println("<p>DB Product: " + meta.getDatabaseProductName()
                    + " " + meta.getDatabaseProductVersion() + "</p>");
            out.println("<p>User: " + meta.getUserName() + "</p>");

        } catch (SQLException e) {
            out.println("<p class='err'>❌ Connection FAILED: " + e.getMessage() + "</p>");
            out.println("</div></body></html>");
            return;
        }
        out.println("</div>");

        // 3. Database & Table Check
        out.println("<div class='box'><h3>3. Database & Table Check</h3>");
        try {

            ResultSet dbs = conn.getMetaData().getCatalogs();
            boolean dbFound = false;

            while (dbs.next()) {
                if ("oceanview_db".equalsIgnoreCase(dbs.getString(1))) {
                    dbFound = true;
                    break;
                }
            }

            if (dbFound) {
                out.println("<p class='ok'>✅ Database 'oceanview_db' exists</p>");
            } else {
                out.println("<p class='err'>❌ Database 'oceanview_db' NOT found</p>");
            }

            ResultSet tables = conn.getMetaData().getTables(
                    "oceanview_db", null, "users", new String[]{"TABLE"});

            if (tables.next()) {
                out.println("<p class='ok'>✅ Table 'users' exists</p>");
            } else {
                out.println("<p class='err'>❌ Table 'users' NOT found</p>");
            }

        } catch (SQLException e) {
            out.println("<p class='err'>❌ Error: " + e.getMessage() + "</p>");
        }
        out.println("</div>");

        // 4. Users Table Data
        out.println("<div class='box'><h3>4. Users in Database</h3>");
        try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM users");
             ResultSet rs = ps.executeQuery()) {

            out.println("<table>");
            out.println("<tr><th>ID</th><th>Username</th><th>First Name</th>"
                    + "<th>Role</th><th>Active</th></tr>");

            int count = 0;
            while (rs.next()) {
                count++;

                out.println("<tr>");
                out.println("<td>" + rs.getLong("id") + "</td>");
                out.println("<td>" + rs.getString("username") + "</td>");
                out.println("<td>" + rs.getString("first_name") + "</td>");
                out.println("<td>" + rs.getString("role") + "</td>");
                out.println("<td>" + rs.getBoolean("active") + "</td>");
                out.println("</tr>");
            }

            if (count == 0) {
                out.println("<tr><td colspan='5' style='color:orange'>No users found</td></tr>");
            }

            out.println("</table>");
            out.println("<p>Total users: <strong>" + count + "</strong></p>");

        } catch (SQLException e) {
            out.println("<p class='err'>❌ Could not read users: " + e.getMessage() + "</p>");
        }
        out.println("</div>");

        // 5. BCrypt Password Test
        out.println("<div class='box'><h3>5. BCrypt Password Verification Test</h3>");

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT username, password FROM users WHERE username IN ('admin','staff')");
             ResultSet rs = ps.executeQuery()) {

            out.println("<table>");
            out.println("<tr><th>Username</th><th>Test Password</th><th>Match Result</th></tr>");

            while (rs.next()) {

                String username = rs.getString("username");
                String storedHash = rs.getString("password");

                String testPassword;
                if ("admin".equals(username)) {
                    testPassword = "Admin@1234";
                } else {
                    testPassword = "Staff@1234";
                }

                boolean match = false;
                try {
                    match = PasswordUtils.checkPassword(testPassword, storedHash);
                } catch (Exception e) {
                    out.println("<tr><td colspan='3' style='color:red;'>BCrypt Error: "
                            + e.getMessage() + "</td></tr>");
                    continue;
                }

                out.println("<tr>");
                out.println("<td>" + username + "</td>");
                out.println("<td>" + testPassword + "</td>");
                out.println("<td>" +
                        (match
                                ? "<span class='ok'>✅ MATCH — Login will work</span>"
                                : "<span class='err'>❌ NO MATCH — Password hash incorrect</span>")
                        + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");

        } catch (SQLException e) {
            out.println("<p class='err'>❌ Error checking password: " + e.getMessage() + "</p>");
        }

        out.println("</div>");


        // 5. Quick Links
        out.println("<div class='box'>");
        out.println("<h3>5. Quick Links</h3>");
        out.println("<a href='" + request.getContextPath() + "/setup'>Run Setup</a>");
        out.println("&nbsp;&nbsp;");
        out.println("<a href='" + request.getContextPath() + "/login'>Go to Login</a>");
        out.println("</div>");

        try {
            if (conn != null) conn.close();
        } catch (SQLException ignored) {}

        out.println("</body></html>");
    }
}