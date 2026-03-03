package com.oceanview.controller;

import com.oceanview.model.User;
import com.oceanview.service.UserService;
import com.oceanview.util.ValidationUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/settings")
public class AdminSettingsServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    // ── GET ───────────────────────────────────────────────────────────────────

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

        // Transfer flash messages from session → request
        transferFlash(session, request);

        request.setAttribute("activePage", "settings");
        request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp")
                .forward(request, response);
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        if (!currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "updateProfile":
                    handleUpdateProfile(request, response, session, currentUser);
                    break;
                case "changePassword":
                    handleChangePassword(request, response, session, currentUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/settings");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/settings");
        }
    }

    // ── Update Profile ────────────────────────────────────────────────────────

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response,
                                     HttpSession session, User currentUser)
            throws SQLException, IOException {

        String firstName = trim(request.getParameter("firstName"));
        String lastName  = trim(request.getParameter("lastName"));
        String email     = trim(request.getParameter("email"));
        String phone     = trim(request.getParameter("phone"));

        if (firstName.isEmpty() || lastName.isEmpty()) {
            session.setAttribute("errorMsg",  "First name and last name are required.");
            session.setAttribute("activeTab", "profile");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }
        if (!ValidationUtils.isValidEmail(email)) {
            session.setAttribute("errorMsg",  "Invalid email address format.");
            session.setAttribute("activeTab", "profile");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }
        if (!ValidationUtils.isValidPhone(phone)) {
            session.setAttribute("errorMsg",  "Invalid phone number format.");
            session.setAttribute("activeTab", "profile");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }

        currentUser.setFirstName(firstName);
        currentUser.setLastName(lastName);
        currentUser.setEmail(email);
        currentUser.setPhone(phone.isEmpty() ? null : phone);

        try {
            User updated = userService.updateUser(currentUser);
            session.setAttribute("user",       updated);
            session.setAttribute("successMsg", "Profile updated successfully!");
            session.setAttribute("activeTab",  "profile");
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMsg",  e.getMessage());
            session.setAttribute("activeTab", "profile");
        }
        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }

    // ── Change Password ───────────────────────────────────────────────────────

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User currentUser)
            throws SQLException, IOException {

        String currentPw = request.getParameter("currentPassword");
        String newPw     = request.getParameter("newPassword");
        String confirmPw = request.getParameter("confirmPassword");

        if (isBlank(currentPw) || isBlank(newPw) || isBlank(confirmPw)) {
            session.setAttribute("errorMsg",  "All password fields are required.");
            session.setAttribute("activeTab", "security");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }
        if (!newPw.equals(confirmPw)) {
            session.setAttribute("errorMsg",  "New password and confirm password do not match.");
            session.setAttribute("activeTab", "security");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }
        if (currentPw.equals(newPw)) {
            session.setAttribute("errorMsg",  "New password must be different from your current password.");
            session.setAttribute("activeTab", "security");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }

        try {
            userService.changePassword(currentUser.getId(), currentPw, newPw);
            session.setAttribute("successMsg", "Password changed successfully!");
            session.setAttribute("activeTab",  "security");
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMsg",  e.getMessage());
            session.setAttribute("activeTab", "security");
        }
        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private void transferFlash(HttpSession session, HttpServletRequest request) {
        for (String key : new String[]{"successMsg", "errorMsg", "activeTab"}) {
            Object val = session.getAttribute(key);
            if (val != null) {
                request.setAttribute(key, val);
                session.removeAttribute(key);
            }
        }
    }

    private String  trim(String s)    { return s == null ? "" : s.trim(); }
    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}