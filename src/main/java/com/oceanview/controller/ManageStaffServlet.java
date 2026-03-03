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
import java.util.List;
import java.util.Optional;

@WebServlet("/admin/manage-staff")
public class ManageStaffServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
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

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "new":       showNewForm(request, response);      break;
                case "edit":      showEditForm(request, response);     break;
                case "view":      viewStaff(request, response);        break;
                case "delete":    deleteStaff(request, response);      break;
                case "toggle":    toggleStaffStatus(request, response); break;
                case "resetpw":   showResetPasswordForm(request, response); break;
                default:          listStaff(request, response);        break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
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
        User currentUser = (User) session.getAttribute("user");
        if (!currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "create":      createStaff(request, response);         break;
                case "update":      updateStaff(request, response);         break;
                case "resetpw":     resetPassword(request, response);       break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
        }
    }

    // ── LIST ──────────────────────────────────────────────────────────────────

    private void listStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        List<User> staffList = userService.getUsersByRole(User.UserRole.STAFF);
        List<User> adminList = userService.getUsersByRole(User.UserRole.ADMIN);
        staffList.addAll(adminList);

        // Flash messages from session
        HttpSession session = request.getSession(false);
        String successMsg = (String) session.getAttribute("successMsg");
        String errorMsg   = (String) session.getAttribute("errorMsg");
        if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
        if (errorMsg   != null) { request.setAttribute("errorMsg",   errorMsg);   session.removeAttribute("errorMsg");   }

        request.setAttribute("staffList", staffList);
        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/WEB-INF/views/admin/manage-staff.jsp").forward(request, response);
    }

    // ── NEW FORM ──────────────────────────────────────────────────────────────

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "staff");
        request.setAttribute("mode", "create");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
    }

    // ── EDIT FORM ─────────────────────────────────────────────────────────────

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }
        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=notfound");
            return;
        }
        request.setAttribute("staff", userOpt.get());
        request.setAttribute("activePage", "staff");
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
    }

    // ── VIEW ──────────────────────────────────────────────────────────────────

    private void viewStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }
        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=notfound");
            return;
        }

        // Flash messages
        HttpSession session = request.getSession(false);
        String successMsg = (String) session.getAttribute("successMsg");
        String errorMsg   = (String) session.getAttribute("errorMsg");
        if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
        if (errorMsg   != null) { request.setAttribute("errorMsg",   errorMsg);   session.removeAttribute("errorMsg");   }

        request.setAttribute("staff", userOpt.get());
        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-view.jsp").forward(request, response);
    }

    // ── RESET PASSWORD FORM (GET) ─────────────────────────────────────────────

    private void showResetPasswordForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }
        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }
        request.setAttribute("staff", userOpt.get());
        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-reset-password.jsp").forward(request, response);
    }

    // ── RESET PASSWORD (POST) ─────────────────────────────────────────────────

    private void resetPassword(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        String idParam    = request.getParameter("id");
        String newPw      = request.getParameter("newPassword");
        String confirmPw  = request.getParameter("confirmPassword");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }
        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }

        // Validate
        if (newPw == null || newPw.trim().isEmpty()) {
            request.setAttribute("error", "New password is required.");
            request.setAttribute("staff", userOpt.get());
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-reset-password.jsp").forward(request, response);
            return;
        }
        if (!newPw.equals(confirmPw)) {
            request.setAttribute("error", "Passwords do not match.");
            request.setAttribute("staff", userOpt.get());
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-reset-password.jsp").forward(request, response);
            return;
        }

        try {
            userService.adminResetPassword(id, newPw);
            HttpSession session = request.getSession(false);
            session.setAttribute("successMsg", "Password for " + userOpt.get().getFullName() + " has been reset successfully.");
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?action=view&id=" + id);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("staff", userOpt.get());
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-reset-password.jsp").forward(request, response);
        }
    }

    // ── CREATE ────────────────────────────────────────────────────────────────

    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String email     = request.getParameter("email");
        String phone     = request.getParameter("phone");
        String roleStr   = request.getParameter("role");
        String activeStr = request.getParameter("active");

        if (!ValidationUtils.isValidUsername(username)) {
            request.setAttribute("error", "Invalid username format (3-50 chars, alphanumeric and underscore only)");
            request.setAttribute("staff", buildUser(null, username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtils.isValidPassword(password)) {
            request.setAttribute("error", "Password must be at least 8 characters with uppercase, lowercase and number");
            request.setAttribute("staff", buildUser(null, username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtils.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format");
            request.setAttribute("staff", buildUser(null, username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }

        User user = buildUser(null, username, firstName, lastName, email, phone, roleStr, activeStr);
        try {
            userService.createUser(user, password);
            HttpSession session = request.getSession(false);
            session.setAttribute("successMsg", "Staff member '" + user.getFullName() + "' created successfully!");
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("staff", user);
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
        }
    }

    // ── UPDATE ────────────────────────────────────────────────────────────────

    private void updateStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        Long   id        = Long.parseLong(request.getParameter("id"));
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String email     = request.getParameter("email");
        String phone     = request.getParameter("phone");
        String roleStr   = request.getParameter("role");
        String activeStr = request.getParameter("active");

        if (!ValidationUtils.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format");
            Optional<User> existing = userService.getUserById(id);
            existing.ifPresent(u -> request.setAttribute("staff", u));
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }

        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }

        User user = userOpt.get();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole("ADMIN".equals(roleStr) ? User.UserRole.ADMIN : User.UserRole.STAFF);
        user.setActive("on".equals(activeStr));

        try {
            userService.updateUser(user);
            HttpSession session = request.getSession(false);
            session.setAttribute("successMsg", "Staff member '" + user.getFullName() + "' updated successfully!");
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?action=view&id=" + id);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("staff", user);
            request.setAttribute("mode", "edit");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
        }
    }

    // ── DELETE / TOGGLE ───────────────────────────────────────────────────────

    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            userService.deactivateUser(Long.parseLong(idParam));
            HttpSession session = request.getSession(false);
            session.setAttribute("successMsg", "Staff member deactivated successfully.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
    }

    private void toggleStaffStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String idParam = request.getParameter("id");
        String toggle  = request.getParameter("toggle");
        if (idParam != null && !idParam.trim().isEmpty()) {
            Long id = Long.parseLong(idParam);
            if ("activate".equals(toggle))   userService.activateUser(id);
            else if ("deactivate".equals(toggle)) userService.deactivateUser(id);
            HttpSession session = request.getSession(false);
            session.setAttribute("successMsg", "Staff status changed successfully.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────

    private User buildUser(Long id, String username, String firstName, String lastName,
                           String email, String phone, String roleStr, String activeStr) {
        User u = new User();
        if (id != null) u.setId(id);
        u.setUsername(username);
        u.setFirstName(firstName != null ? firstName : "");
        u.setLastName(lastName   != null ? lastName  : "");
        u.setEmail(email         != null ? email     : "");
        u.setPhone(phone);
        u.setRole("ADMIN".equals(roleStr) ? User.UserRole.ADMIN : User.UserRole.STAFF);
        u.setActive("on".equals(activeStr));
        return u;
    }
}