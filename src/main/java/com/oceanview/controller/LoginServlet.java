package com.oceanview.controller;

import com.oceanview.model.User;
import com.oceanview.service.UserService;
import com.oceanview.util.SessionManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            }
            return;
        }

        // Check for remember me cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberedUsername".equals(cookie.getName())) {
                    request.setAttribute("rememberedUsername", cookie.getValue());
                    break;
                }
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        // Basic validation
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        try {
            Optional<User> userOpt = userService.login(username, password);

            if (userOpt.isPresent()) {
                User user = userOpt.get();

                if (!user.isActive()) {
                    request.setAttribute("error", "Your account is deactivated. Please contact administrator.");
                    request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                    return;
                }

                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getId());
                session.setAttribute("userRole", user.getRole().toString());
                session.setAttribute("userName", user.getFullName());

                // Set session timeout (30 minutes)
                session.setMaxInactiveInterval(30 * 60);

                // Handle "Remember Me"
                if ("on".equals(remember) || "true".equals(remember)) {
                    Cookie usernameCookie = new Cookie("rememberedUsername", username);
                    usernameCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                    usernameCookie.setHttpOnly(true);
                    usernameCookie.setPath("/");
                    response.addCookie(usernameCookie);

                    Cookie rememberMeCookie = new Cookie("rememberMe", "true");
                    rememberMeCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                    rememberMeCookie.setHttpOnly(true);
                    rememberMeCookie.setPath("/");
                    response.addCookie(rememberMeCookie);
                }

                // Log the login
                SessionManager.logUserActivity(user.getId(), "LOGIN", "User logged in successfully");

                // Redirect based on role
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                }

            } else {
                request.setAttribute("error", "Invalid username or password");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}