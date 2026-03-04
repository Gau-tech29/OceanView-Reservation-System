package com.oceanview.controller;

import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Serves the Help & Guidelines page for both Staff and Admin users.
 * Accessible at /help
 */
@WebServlet("/help")
public class HelpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Redirect to login if no active session
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Forward to the shared help JSP
        // The JSP itself detects whether the user is admin or staff
        // and adjusts the sidebar + admin-only sections accordingly.
        request.getRequestDispatcher("/WEB-INF/views/help.jsp")
                .forward(request, response);
    }
}
