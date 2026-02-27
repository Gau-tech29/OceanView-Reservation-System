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
import java.util.Optional;  // Add this missing import

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
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "new":
                    showNewForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "view":
                    viewStaff(request, response);
                    break;
                case "delete":
                    deleteStaff(request, response);
                    break;
                case "toggle":
                    toggleStaffStatus(request, response);
                    break;
                default:
                    listStaff(request, response);
                    break;
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
            if ("create".equals(action)) {
                createStaff(request, response);
            } else if ("update".equals(action)) {
                updateStaff(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
        }
    }

    private void listStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        List<User> staffList = userService.getUsersByRole(User.UserRole.STAFF);
        // Also get admins if you want to show them too
        List<User> adminList = userService.getUsersByRole(User.UserRole.ADMIN);
        staffList.addAll(adminList);

        request.setAttribute("staffList", staffList);
        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/WEB-INF/views/admin/manage-staff.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "staff");
        request.setAttribute("mode", "create");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }

        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);

        if (userOpt.isPresent()) {
            request.setAttribute("staff", userOpt.get());
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=notfound");
            return;
        }

        request.setAttribute("activePage", "staff");
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
    }

    private void viewStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
            return;
        }

        Long id = Long.parseLong(idParam);
        Optional<User> userOpt = userService.getUserById(id);

        if (userOpt.isPresent()) {
            request.setAttribute("staff", userOpt.get());
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=notfound");
            return;
        }

        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/WEB-INF/views/admin/staff-view.jsp").forward(request, response);
    }

    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roleStr = request.getParameter("role");
        String activeStr = request.getParameter("active");

        // Validation
        if (!ValidationUtils.isValidUsername(username)) {
            request.setAttribute("error", "Invalid username format (3-50 characters, alphanumeric and underscore only)");
            request.setAttribute("staff", createUserObject(username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtils.isValidPassword(password)) {
            request.setAttribute("error", "Password must be at least 8 characters with mixed case and numbers");
            request.setAttribute("staff", createUserObject(username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtils.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format");
            request.setAttribute("staff", createUserObject(username, firstName, lastName, email, phone, roleStr, activeStr));
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(roleStr != null && roleStr.equals("ADMIN") ? User.UserRole.ADMIN : User.UserRole.STAFF);
        user.setActive(activeStr != null && activeStr.equals("on"));

        try {
            userService.createUser(user, password);
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?success=created");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("staff", user);
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("/WEB-INF/views/admin/staff-form.jsp").forward(request, response);
        }
    }

    private void updateStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        Long id = Long.parseLong(request.getParameter("id"));
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roleStr = request.getParameter("role");
        String activeStr = request.getParameter("active");

        // Validation
        if (!ValidationUtils.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format");
            request.getRequestDispatcher("/admin/manage-staff?action=edit&id=" + id).forward(request, response);
            return;
        }

        Optional<User> userOpt = userService.getUserById(id);
        if (!userOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=notfound");
            return;
        }

        User user = userOpt.get();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(roleStr != null && roleStr.equals("ADMIN") ? User.UserRole.ADMIN : User.UserRole.STAFF);
        user.setActive(activeStr != null && activeStr.equals("on"));

        try {
            userService.updateUser(user);
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?success=updated");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?action=edit&id=" + id);
        }
    }

    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            Long id = Long.parseLong(idParam);
            userService.deactivateUser(id);
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=invalid");
        }
    }

    private void toggleStaffStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String idParam = request.getParameter("id");
        String action = request.getParameter("toggle");

        if (idParam != null && !idParam.trim().isEmpty()) {
            Long id = Long.parseLong(idParam);
            if ("activate".equals(action)) {
                userService.activateUser(id);
            } else if ("deactivate".equals(action)) {
                userService.deactivateUser(id);
            }
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?success=statuschanged");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?error=invalid");
        }
    }

    private User createUserObject(String username, String firstName, String lastName,
                                  String email, String phone, String roleStr, String activeStr) {
        User user = new User();
        user.setUsername(username);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(roleStr != null && roleStr.equals("ADMIN") ? User.UserRole.ADMIN : User.UserRole.STAFF);
        user.setActive(activeStr != null && activeStr.equals("on"));
        return user;
    }


}