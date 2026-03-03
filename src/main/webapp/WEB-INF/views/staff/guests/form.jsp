<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --primary-light: #e8f0fe;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --danger-color: #dc3545;
            --dark-color: #212529;
            --sidebar-width: 280px;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f7fc;
            overflow-x: hidden;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
            color: white;
            z-index: 1000;
            box-shadow: 3px 0 20px rgba(0,0,0,0.1);
            overflow-y: auto;
        }
        .sidebar-brand {
            padding: 25px 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            margin-bottom: 15px;
        }
        .sidebar-brand h3 {
            font-size: 1.4rem;
            font-weight: 700;
            margin: 0;
        }
        .sidebar-brand p {
            font-size: 0.8rem;
            opacity: 0.8;
            margin: 4px 0 0;
        }
        .sidebar-menu {
            list-style: none;
            padding: 5px 15px;
            margin: 0;
        }
        .sidebar-menu li {
            margin-bottom: 4px;
        }
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: all 0.3s;
            border-radius: 10px;
        }
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.15);
            color: white;
            transform: translateX(5px);
        }
        .sidebar-menu a i {
            width: 30px;
            font-size: 1.1rem;
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px 30px;
        }

        .top-nav {
            background: white;
            border-radius: 16px;
            padding: 15px 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .page-title h2 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
        }
        .page-title p {
            color: var(--secondary-color);
            margin: 3px 0 0;
            font-size: 0.85rem;
        }
        .user-menu {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1rem;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--secondary-color);
            text-decoration: none;
            margin-bottom: 20px;
            padding: 8px 15px;
            background: white;
            border-radius: 10px;
            transition: all 0.3s;
        }
        .back-link:hover {
            background: var(--primary-light);
            color: var(--primary-color);
            transform: translateX(-5px);
        }

        .form-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .form-header {
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--primary-light);
        }
        .form-header h4 {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 5px;
        }
        .form-header p {
            color: var(--secondary-color);
            margin: 0;
            font-size: 0.9rem;
        }

        .form-section {
            margin-bottom: 30px;
        }
        .form-section-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .form-section-title i {
            font-size: 1.1rem;
        }

        .form-label {
            font-weight: 500;
            font-size: 0.85rem;
            color: var(--dark-color);
            margin-bottom: 6px;
        }
        .required-star {
            color: var(--danger-color);
        }
        .form-control, .form-select {
            border-radius: 10px;
            border: 2px solid #e9ecef;
            padding: 10px 15px;
            font-size: 0.9rem;
            transition: all 0.3s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(13,110,253,0.1);
            outline: none;
        }

        .vip-toggle {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 15px;
            background: #fff9e6;
            border: 2px solid #ffc107;
            border-radius: 10px;
            cursor: pointer;
        }
        .vip-toggle input {
            width: 20px;
            height: 20px;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e9ecef;
        }
        .btn-submit {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(13,110,253,0.3);
        }
        .btn-cancel {
            background: #e9ecef;
            color: var(--secondary-color);
            border: none;
            padding: 12px 30px;
            border-radius: 10px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
        }
        .btn-cancel:hover {
            background: #dee2e6;
            color: var(--dark-color);
        }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .form-actions { flex-direction: column; }
            .btn-submit, .btn-cancel { width: 100%; text-align: center; }
        }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String basePath = user.isAdmin() ? "/admin" : "/staff";
    GuestDTO guest = (GuestDTO) request.getAttribute("guest");
    boolean isEdit = guest != null && guest.getId() != null;
%>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations">
            <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="active">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/bills">
            <i class="fas fa-receipt"></i><span>Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><%= request.getAttribute("pageTitle") %></h2>
            <p><i class="fas fa-user me-1"></i><%= isEdit ? "Update guest information" : "Add a new guest to the system" %></p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div style="font-weight:600;"><%= user.getFullName() %></div>
                <div style="font-size:0.8rem;color:#6c757d;"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Guests
    </a>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}<%= basePath %>/guests/<%= isEdit ? "update" : "save" %>" method="post">
            <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= guest.getId() %>">
            <% } %>

            <div class="form-header">
                <h4><%= isEdit ? "Edit Guest" : "New Guest" %></h4>
                <p>Fill in the guest's personal information and identification details</p>
            </div>

            <!-- Personal Information Section -->
            <div class="form-section">
                <div class="form-section-title">
                    <i class="fas fa-user-circle"></i> Personal Information
                </div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">First Name <span class="required-star">*</span></label>
                        <input type="text" name="firstName" class="form-control"
                               value="<%= isEdit ? guest.getFirstName() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Last Name <span class="required-star">*</span></label>
                        <input type="text" name="lastName" class="form-control"
                               value="<%= isEdit ? guest.getLastName() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email Address</label>
                        <input type="email" name="email" class="form-control"
                               value="<%= isEdit && guest.getEmail() != null ? guest.getEmail() : "" %>"
                               placeholder="guest@example.com">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Phone Number</label>
                        <input type="tel" name="phone" class="form-control"
                               value="<%= isEdit && guest.getPhone() != null ? guest.getPhone() : "" %>"
                               placeholder="+1 234 567 8900">
                    </div>
                </div>
            </div>

            <!-- Address Section -->
            <div class="form-section">
                <div class="form-section-title">
                    <i class="fas fa-map-marker-alt"></i> Address
                </div>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label">Street Address</label>
                        <input type="text" name="address" class="form-control"
                               value="<%= isEdit && guest.getAddress() != null ? guest.getAddress() : "" %>"
                               placeholder="Street address">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">City</label>
                        <input type="text" name="city" class="form-control"
                               value="<%= isEdit && guest.getCity() != null ? guest.getCity() : "" %>"
                               placeholder="City">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Country</label>
                        <input type="text" name="country" class="form-control"
                               value="<%= isEdit && guest.getCountry() != null ? guest.getCountry() : "" %>"
                               placeholder="Country">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Postal Code</label>
                        <input type="text" name="postalCode" class="form-control"
                               value="<%= isEdit && guest.getPostalCode() != null ? guest.getPostalCode() : "" %>"
                               placeholder="Postal code">
                    </div>
                </div>
            </div>

            <!-- Identification Section -->
            <div class="form-section">
                <div class="form-section-title">
                    <i class="fas fa-id-card"></i> Identification
                </div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">ID Type</label>
                        <select name="idCardType" class="form-select">
                            <option value="">-- Select ID Type --</option>
                            <option value="PASSPORT" <%= isEdit && "PASSPORT".equals(guest.getIdCardType()) ? "selected" : "" %>>Passport</option>
                            <option value="NATIONAL_ID" <%= isEdit && "NATIONAL_ID".equals(guest.getIdCardType()) ? "selected" : "" %>>National ID</option>
                            <option value="DRIVERS_LICENSE" <%= isEdit && "DRIVERS_LICENSE".equals(guest.getIdCardType()) ? "selected" : "" %>>Driver's License</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">ID Number</label>
                        <input type="text" name="idCardNumber" class="form-control"
                               value="<%= isEdit && guest.getIdCardNumber() != null ? guest.getIdCardNumber() : "" %>"
                               placeholder="ID number">
                    </div>
                </div>
            </div>

            <!-- Loyalty & Preferences -->
            <div class="form-section">
                <div class="form-section-title">
                    <i class="fas fa-star"></i> Loyalty & Preferences
                </div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Loyalty Points</label>
                        <input type="number" name="loyaltyPoints" class="form-control" min="0"
                               value="<%= isEdit && guest.getLoyaltyPoints() != null ? guest.getLoyaltyPoints() : 0 %>">
                    </div>
                    <div class="col-md-6">
                        <div class="vip-toggle">
                            <input type="checkbox" name="isVip" id="isVip"
                                <%= isEdit && guest.getIsVip() != null && guest.getIsVip() ? "checked" : "" %>>
                            <label for="isVip" style="font-weight: 500; cursor: pointer;">
                                <i class="fas fa-crown" style="color: #ffc107;"></i> VIP Guest
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Notes -->
            <div class="form-section">
                <div class="form-section-title">
                    <i class="fas fa-sticky-note"></i> Additional Notes
                </div>
                <div class="row">
                    <div class="col-12">
                        <textarea name="notes" class="form-control" rows="4"
                                  placeholder="Special requests, preferences, or any notes about this guest..."><%= isEdit && guest.getNotes() != null ? guest.getNotes() : "" %></textarea>
                    </div>
                </div>
            </div>

            <!-- Form Actions -->
            <div class="form-actions">
                <a href="${pageContext.request.contextPath}<%= basePath %>/guests" class="btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </a>
                <button type="submit" class="btn-submit">
                    <i class="fas fa-save"></i> <%= isEdit ? "Update Guest" : "Save Guest" %>
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>