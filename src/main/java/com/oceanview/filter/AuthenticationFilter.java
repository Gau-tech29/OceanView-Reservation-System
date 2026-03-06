package com.oceanview.filter;

import com.oceanview.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/staff/*"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Session is gone (invalidated on logout) — send back to login
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check admin-only areas
        String requestURI = request.getRequestURI();
        if (requestURI.contains("/admin/") && !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/WEB-INF/views/error/403.jsp");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {}
}