package com.oceanview.util;

import javax.servlet.http.HttpSession;

public class SessionManager {

    private SessionManager() {}

    public static void logUserActivity(Long userId, String action, String details) {
        // Simple console log — replace with DB logging if needed
        System.out.println("[ACTIVITY] UserID=" + userId + " | Action=" + action + " | " + details);
    }

    public static void invalidateSession(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }
}