<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Guidelines - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --sidebar-width: 260px;
            --dark-color: #212529;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

        /* ── Sidebar ── */
        .sidebar {
            position: fixed; top: 0; left: 0; height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
            color: white; z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,0.15);
            overflow-y: auto;
        }
        .sidebar-brand { padding: 25px 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
        .sidebar-brand h3 { font-size: 1.4rem; font-weight: 700; margin: 0; }
        .sidebar-brand p  { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }
        .sidebar-menu { list-style: none; padding: 5px 10px; margin: 0; }
        .sidebar-menu li { margin-bottom: 4px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 11px 15px;
            color: rgba(255,255,255,0.85); text-decoration: none;
            transition: all 0.2s; border-radius: 10px;
        }
        .sidebar-menu a:hover,
        .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
        .sidebar-menu a i    { width: 28px; font-size: 1.1rem; }
        .sidebar-menu a span { font-size: 0.9rem; font-weight: 500; }

        /* ── Main ── */
        .main-content { margin-left: var(--sidebar-width); padding: 20px 28px; }
        .top-nav {
            background: white; border-radius: 15px; padding: 14px 22px;
            margin-bottom: 22px; box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            display: flex; justify-content: space-between; align-items: center;
        }
        .page-title h2 { font-size: 1.4rem; font-weight: 600; color: var(--dark-color); margin: 0; }
        .page-title p   { color: var(--secondary-color); margin: 3px 0 0; font-size: 0.85rem; }
        .user-menu { display: flex; align-items: center; gap: 18px; }
        .user-avatar {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 700; font-size: 1rem;
        }
        .user-name { font-weight: 600; color: var(--dark-color); font-size: 0.9rem; }
        .user-role { font-size: 0.75rem; color: var(--secondary-color); }

        /* ── Hero banner ── */
        .help-banner {
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; border-radius: 18px; padding: 28px 35px;
            margin-bottom: 28px; box-shadow: 0 10px 30px rgba(13,110,253,0.25);
        }
        .help-banner h4 { font-size: 1.5rem; font-weight: 700; margin-bottom: 8px; }
        .help-banner p  { opacity: 0.9; margin: 0; font-size: 0.95rem; max-width: 680px; }

        /* ── Quick-nav pills ── */
        .quick-nav {
            display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 28px;
        }
        .quick-nav a {
            background: white; border: 2px solid #e9ecef;
            border-radius: 25px; padding: 8px 18px;
            font-size: 0.83rem; font-weight: 500;
            color: var(--dark-color); text-decoration: none;
            transition: all 0.2s; box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }
        .quick-nav a:hover {
            border-color: var(--primary-color); color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(13,110,253,0.15);
        }
        .quick-nav a i { margin-right: 6px; }

        /* ── Section title ── */
        .section-title {
            font-size: 1.05rem; font-weight: 600; color: var(--dark-color);
            margin-bottom: 16px; padding-left: 10px;
            border-left: 3px solid var(--primary-color);
        }

        /* ── Help cards ── */
        .help-card {
            background: white; border-radius: 14px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            margin-bottom: 22px; overflow: hidden;
        }
        .help-card-header {
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white; padding: 16px 22px;
            display: flex; align-items: center; gap: 14px; cursor: pointer;
            transition: opacity 0.2s;
        }
        .help-card-header:hover { opacity: 0.92; }
        .help-card-header .icon-circle {
            width: 44px; height: 44px; background: rgba(255,255,255,0.2);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .help-card-header .icon-circle i { font-size: 20px; }
        .help-card-header h5 { margin: 0; font-size: 1rem; font-weight: 600; }
        .help-card-header p  { margin: 3px 0 0; font-size: 0.8rem; opacity: 0.85; }
        .help-card-header .chevron { margin-left: auto; transition: transform 0.3s; }
        .help-card-header.collapsed .chevron { transform: rotate(-90deg); }

        .help-card-body { padding: 22px; }

        /* ── Steps ── */
        .step-list { list-style: none; padding: 0; margin: 0; }
        .step-list li {
            display: flex; align-items: flex-start; gap: 14px;
            padding: 14px 0; border-bottom: 1px solid #f0f4f8;
        }
        .step-list li:last-child { border-bottom: none; padding-bottom: 0; }
        .step-num {
            width: 32px; height: 32px; background: var(--primary-color);
            color: white; border-radius: 50%; display: flex; align-items: center;
            justify-content: center; font-weight: 700; font-size: 0.85rem; flex-shrink: 0;
            margin-top: 1px;
        }
        .step-content h6  { font-size: 0.9rem; font-weight: 600; margin-bottom: 4px; color: var(--dark-color); }
        .step-content p   { font-size: 0.83rem; color: var(--secondary-color); margin: 0; }
        .step-content ul  { margin: 6px 0 0 0; padding-left: 16px; }
        .step-content ul li { font-size: 0.82rem; color: var(--secondary-color); padding: 2px 0; border: none; }

        /* ── Tips ── */
        .tip-box {
            background: #f0f7ff; border: 1px solid #cce0ff;
            border-radius: 10px; padding: 14px 18px;
            display: flex; gap: 12px; margin-top: 16px;
        }
        .tip-box i { color: var(--primary-color); font-size: 1.1rem; margin-top: 2px; flex-shrink: 0; }
        .tip-box p { margin: 0; font-size: 0.83rem; color: #0a4a9c; }

        .warning-box {
            background: #fff8e1; border: 1px solid #ffe082;
            border-radius: 10px; padding: 14px 18px;
            display: flex; gap: 12px; margin-top: 12px;
        }
        .warning-box i { color: #f0a500; font-size: 1.1rem; margin-top: 2px; flex-shrink: 0; }
        .warning-box p { margin: 0; font-size: 0.83rem; color: #795500; }

        /* ── Status badge reference ── */
        .status-ref { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 12px; }
        .status-item {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.83rem; color: var(--dark-color);
        }
        .badge-status { padding: 4px 12px; border-radius: 20px; font-size: 0.76rem; font-weight: 500; }
        .badge-confirmed  { background: #d4edda; color: #155724; }
        .badge-checked-in { background: #cce5ff; color: #004085; }
        .badge-checked-out{ background: #e2e3e5; color: #383d41; }
        .badge-cancelled  { background: #f8d7da; color: #721c24; }
        .badge-pending    { background: #fff3cd; color: #856404; }

        /* ── FAQ ── */
        .faq-item { border-bottom: 1px solid #f0f4f8; padding: 14px 0; }
        .faq-item:last-child { border-bottom: none; }
        .faq-q {
            font-size: 0.9rem; font-weight: 600; color: var(--dark-color);
            cursor: pointer; display: flex; justify-content: space-between; align-items: center;
            gap: 10px;
        }
        .faq-q i { color: var(--primary-color); font-size: 0.8rem; transition: transform 0.3s; flex-shrink: 0; }
        .faq-a {
            font-size: 0.83rem; color: var(--secondary-color);
            padding-top: 8px; display: none; line-height: 1.6;
        }
        .faq-item.open .faq-q i { transform: rotate(180deg); }
        .faq-item.open .faq-a   { display: block; }

        /* ── Contact card ── */
        .contact-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; }
        .contact-card {
            background: #f8faff; border: 1px solid #e4ecff;
            border-radius: 12px; padding: 18px; text-align: center;
        }
        .contact-card i { font-size: 1.8rem; color: var(--primary-color); margin-bottom: 10px; display: block; }
        .contact-card h6 { font-size: 0.88rem; font-weight: 600; margin-bottom: 4px; color: var(--dark-color); }
        .contact-card p  { font-size: 0.8rem; color: var(--secondary-color); margin: 0; }

        /* ── Back-to-top ── */
        #backToTop {
            position: fixed; bottom: 30px; right: 30px;
            width: 42px; height: 42px; border-radius: 50%;
            background: var(--primary-color); color: white;
            border: none; box-shadow: 0 4px 12px rgba(13,110,253,0.4);
            font-size: 1.1rem; cursor: pointer; display: none;
            align-items: center; justify-content: center;
            transition: all 0.2s; z-index: 999;
        }
        #backToTop:hover { background: var(--primary-dark); transform: translateY(-2px); }

        @media (max-width: 992px) { .contact-grid { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .contact-grid { grid-template-columns: 1fr; }
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
    boolean isAdmin = user.isAdmin();
    String dashboardUrl = isAdmin
            ? request.getContextPath() + "/admin/dashboard"
            : request.getContextPath() + "/staff/dashboard";
    String basePath = isAdmin ? "/admin" : "/staff";
%>

<!-- ══ Sidebar ══ -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="<%= dashboardUrl %>">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/reservations">
            <i class="fas fa-list-alt"></i><span>All Reservations</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/reservations/search">
            <i class="fas fa-search"></i><span>Search Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/payments">
            <i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
        <% if (isAdmin) { %>
        <li><a href="<%= request.getContextPath() %>/admin/manage-staff">
            <i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="<%= request.getContextPath() %>/admin/reports">
            <i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <% } %>
        <li><a href="<%= request.getContextPath() %>/help" class="active">
            <i class="fas fa-question-circle"></i><span>Help & Guidelines</span></a></li>
        <li><a href="<%= request.getContextPath() %>/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- ══ Main Content ══ -->
<div class="main-content">

    <!-- Top Nav -->
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-question-circle me-2" style="color:#0d6efd;"></i>Help & Guidelines</h2>
            <p>Step-by-step guide for using the Ocean View Hotel Reservation System</p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div class="user-name"><%= user.getFullName() %></div>
                <div class="user-role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Hero Banner -->
    <div class="help-banner">
        <div class="row align-items-center">
            <div class="col-md-9">
                <h4><i class="fas fa-life-ring me-2"></i>Welcome to the Help Center</h4>
                <p>This guide walks you through every feature of the Ocean View Hotel Reservation System.
                    Use the quick links below to jump to any topic, or scroll through at your own pace.</p>
            </div>
            <div class="col-md-3 text-end d-none d-md-block">
                <i class="fas fa-book-open" style="font-size:3.5rem; opacity:0.25;"></i>
            </div>
        </div>
    </div>

    <!-- Quick Navigation Pills -->
    <div class="quick-nav">
        <a href="#getting-started"><i class="fas fa-play-circle"></i>Getting Started</a>
        <a href="#reservations"><i class="fas fa-calendar-alt"></i>Reservations</a>
        <a href="#checkin-checkout"><i class="fas fa-exchange-alt"></i>Check-in / Check-out</a>
        <a href="#guests"><i class="fas fa-users"></i>Guest Management</a>
        <a href="#rooms"><i class="fas fa-door-open"></i>Room Management</a>
        <a href="#payments"><i class="fas fa-credit-card"></i>Payments & Bills</a>
        <% if (isAdmin) { %>
        <a href="#admin"><i class="fas fa-shield-alt"></i>Admin Features</a>
        <% } %>
        <a href="#statuses"><i class="fas fa-tags"></i>Status Reference</a>
        <a href="#faq"><i class="fas fa-comment-dots"></i>FAQ</a>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 1 · GETTING STARTED
    ════════════════════════════════════════ -->
    <div id="getting-started">
        <div class="section-title"><i class="fas fa-play-circle me-2"></i>Getting Started</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-sign-in-alt"></i></div>
                <div>
                    <h5>Logging In &amp; Dashboard Overview</h5>
                    <p>First steps when you arrive at work</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Navigate to the login page</h6>
                            <p>Open your browser and go to the hotel system URL provided by your manager.
                                You will see the Ocean View login screen.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Enter your credentials</h6>
                            <p>Type your <strong>Username</strong> (usually your employee ID or email)
                                and your <strong>Password</strong>, then click <em>Login</em>.
                                Contact your administrator if you have not received credentials.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Understand the Dashboard</h6>
                            <p>After logging in you will land on the Staff Dashboard. Key areas:</p>
                            <ul>
                                <li><strong>Stats Cards</strong> — live counts of active reservations, available rooms, total guests, and today's arrivals/departures.</li>
                                <li><strong>Quick Actions</strong> — shortcut buttons to the most common tasks.</li>
                                <li><strong>Recent Reservations</strong> — the latest 8 bookings with action buttons.</li>
                                <li><strong>Left Sidebar</strong> — full navigation menu always visible.</li>
                            </ul>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Always log out when finished</h6>
                            <p>Click <strong>Logout</strong> in the sidebar to end your session securely,
                                especially on shared computers. Sessions expire automatically after 30 minutes
                                of inactivity.</p>
                        </div>
                    </li>
                </ul>
                <div class="tip-box">
                    <i class="fas fa-lightbulb"></i>
                    <p>Bookmark the dashboard URL so you can reach the system quickly at the start of each shift.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 2 · RESERVATIONS
    ════════════════════════════════════════ -->
    <div id="reservations">
        <div class="section-title"><i class="fas fa-calendar-alt me-2"></i>Managing Reservations</div>

        <!-- Create -->
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-plus-circle"></i></div>
                <div>
                    <h5>Creating a New Reservation</h5>
                    <p>Step-by-step walkthrough for booking a room</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Open the New Reservation form</h6>
                            <p>Click <strong>New Reservation</strong> in the sidebar or on the Quick Actions panel of the dashboard.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Select or create a Guest profile</h6>
                            <p>Start typing the guest's name or email in the search box.
                                If the guest has stayed before, select them from the dropdown.
                                For a first-time guest, fill in all required fields:
                                first name, last name, email, phone, and ID card details.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Choose Check-in and Check-out dates</h6>
                            <p>Select dates using the date pickers. The system will automatically
                                calculate the number of nights and the total cost.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Select a Room</h6>
                            <p>Only available rooms for the chosen dates will appear.
                                Choose the room type (Standard, Deluxe, Suite, Ocean View, Family)
                                and a specific room number.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">5</div>
                        <div class="step-content">
                            <h6>Add any special requests</h6>
                            <p>Note dietary needs, accessibility requirements, or late check-in
                                information in the <em>Special Requests</em> field.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">6</div>
                        <div class="step-content">
                            <h6>Confirm &amp; Save</h6>
                            <p>Review the summary panel on the right, then click
                                <strong>Create Reservation</strong>.
                                The system assigns a unique Reservation Number (e.g. <code>RES-000123</code>)
                                and sets the status to <em>CONFIRMED</em>.</p>
                        </div>
                    </li>
                </ul>
                <div class="warning-box">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p>Double-check the guest's name and ID details before saving — these cannot be changed after check-in without admin approval.</p>
                </div>
            </div>
        </div>

        <!-- Search & View -->
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-search"></i></div>
                <div>
                    <h5>Finding &amp; Viewing a Reservation</h5>
                    <p>Quickly locate any booking</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Use Search Reservation</h6>
                            <p>Click <strong>Search Reservation</strong> in the sidebar.
                                You can search by Reservation Number, guest name, guest email,
                                room number, or check-in date.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Browse All Reservations</h6>
                            <p>Go to <strong>All Reservations</strong> to see the complete list.
                                Use the filter dropdowns at the top to narrow results by status or date range.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Open the Reservation Detail</h6>
                            <p>Click the <i class="fas fa-eye text-primary"></i> eye icon on any row
                                to open the full reservation detail — room info, guest profile,
                                payment history, and activity log.</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>

        <!-- Edit / Cancel -->
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-edit"></i></div>
                <div>
                    <h5>Editing &amp; Cancelling a Reservation</h5>
                    <p>Modify dates, rooms, or cancel a booking</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Open Edit mode</h6>
                            <p>Click the <i class="fas fa-edit text-secondary"></i> pencil icon
                                next to a reservation. Only <em>CONFIRMED</em> or <em>PENDING</em>
                                reservations can be fully edited.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Change dates or room</h6>
                            <p>Update the check-in/check-out dates or swap to a different available room.
                                The total amount will recalculate automatically.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>To cancel a reservation</h6>
                            <p>On the edit form, change the status to <em>CANCELLED</em> and save.
                                Alternatively, click the <i class="fas fa-trash text-danger"></i> delete
                                icon — this permanently removes the reservation (use with caution).</p>
                        </div>
                    </li>
                </ul>
                <div class="warning-box">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p>Deleting a reservation is permanent and cannot be undone. Cancel instead of delete whenever possible to keep an audit trail.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 3 · CHECK-IN / CHECK-OUT
    ════════════════════════════════════════ -->
    <div id="checkin-checkout">
        <div class="section-title"><i class="fas fa-exchange-alt me-2"></i>Check-in &amp; Check-out Process</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-sign-in-alt"></i></div>
                <div>
                    <h5>Processing a Check-in</h5>
                    <p>Welcoming a guest upon arrival</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Find today's arrivals</h6>
                            <p>From the Dashboard, click the <strong>Check-ins Today</strong> stat card
                                (teal card) to see all guests arriving today.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Verify guest identity</h6>
                            <p>Ask for the ID card or passport. Confirm it matches the reservation details.
                                You can view the stored ID number on the reservation detail page.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Click Check-in</h6>
                            <p>Press the <i class="fas fa-sign-in-alt text-success"></i> green check-in
                                button on the reservation row. Confirm the prompt.
                                Status changes from <em>CONFIRMED</em> → <em>CHECKED IN</em>.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Issue room keys</h6>
                            <p>Hand over the physical or digital room key.
                                Provide the guest with any hotel information (Wi-Fi code, breakfast times, etc.).</p>
                        </div>
                    </li>
                </ul>
                <div class="tip-box">
                    <i class="fas fa-lightbulb"></i>
                    <p>Early check-in is only possible if the room has been cleaned and marked available. Check Room Status before confirming early arrival.</p>
                </div>
            </div>
        </div>

        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-sign-out-alt"></i></div>
                <div>
                    <h5>Processing a Check-out</h5>
                    <p>Settling a guest's bill and releasing the room</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Find today's departures</h6>
                            <p>Click the <strong>Check-outs Today</strong> stat card on the Dashboard
                                to list all departing guests.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Review the bill</h6>
                            <p>Go to <strong>Payments &amp; Bills</strong> and open the guest's bill.
                                Verify any additional charges (room service, late check-out fees, etc.)
                                are included before finalising.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Collect payment</h6>
                            <p>Process payment via cash or card. Mark the invoice as <em>PAID</em>
                                in the Payments module and generate the final receipt.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Click Check-out</h6>
                            <p>Press the <i class="fas fa-sign-out-alt text-warning"></i> yellow
                                check-out button. Confirm the prompt.
                                Status changes to <em>CHECKED OUT</em> and the room is released.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">5</div>
                        <div class="step-content">
                            <h6>Collect room keys</h6>
                            <p>Retrieve any physical key cards. Wish the guest a safe journey and
                                invite them to return.</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 4 · GUEST MANAGEMENT
    ════════════════════════════════════════ -->
    <div id="guests">
        <div class="section-title"><i class="fas fa-users me-2"></i>Guest Management</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-user-plus"></i></div>
                <div>
                    <h5>Adding &amp; Managing Guests</h5>
                    <p>Create and maintain guest profiles</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Go to the Guests section</h6>
                            <p>Click <strong>Guests</strong> in the sidebar to open the full guest directory.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Search before creating</h6>
                            <p>Always search the guest's name or email first to avoid duplicates.
                                The system also auto-suggests matching guests when creating a new reservation.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Add a new guest</h6>
                            <p>Click <strong>Add Guest</strong> and fill in all fields.
                                Required: First &amp; Last name, Email, Phone, ID Card Type &amp; Number.
                                Optional but recommended: Address, City, Country, Postal Code.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Edit guest information</h6>
                            <p>Click the pencil icon next to any guest to update their contact details
                                or ID information. A Guest Number (e.g. <code>GST-000045</code>) is
                                assigned automatically and cannot be changed.</p>
                        </div>
                    </li>
                </ul>
                <div class="tip-box">
                    <i class="fas fa-lightbulb"></i>
                    <p>Keeping guest profiles complete and accurate improves check-in speed and helps management generate better reports.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 5 · ROOMS
    ════════════════════════════════════════ -->
    <div id="rooms">
        <div class="section-title"><i class="fas fa-door-open me-2"></i>Room Management</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-door-open"></i></div>
                <div>
                    <h5>Viewing &amp; Understanding Room Status</h5>
                    <p>Monitor room availability in real time</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Open Room Status</h6>
                            <p>Click <strong>Rooms</strong> in the sidebar to see the live room grid.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Room status colours</h6>
                            <ul>
                                <li><strong style="color:#198754;">Available</strong> — clean and ready for a new guest.</li>
                                <li><strong style="color:#0d6efd;">Occupied</strong> — a guest is currently checked in.</li>
                                <li><strong style="color:#dc3545;">Maintenance</strong> — out of service; cannot be booked.</li>
                                <li><strong style="color:#ffc107;">Reserved</strong> — booked for an upcoming arrival.</li>
                            </ul>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Filter by type or floor</h6>
                            <p>Use the filter options at the top of the Rooms page to narrow the view
                                by room type (Standard, Deluxe, Suite, Ocean View, Family)
                                or by floor number.</p>
                        </div>
                    </li>
                </ul>
                <div class="warning-box">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p>Only administrators can add, edit, or delete rooms or change a room to Maintenance status.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 6 · PAYMENTS
    ════════════════════════════════════════ -->
    <div id="payments">
        <div class="section-title"><i class="fas fa-credit-card me-2"></i>Payments &amp; Billing</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-file-invoice-dollar"></i></div>
                <div>
                    <h5>Processing Payments &amp; Managing Bills</h5>
                    <p>Record payments, issue receipts, and handle refunds</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Open Payments &amp; Bills</h6>
                            <p>Click <strong>Payments &amp; Bills</strong> in the sidebar
                                to view all payment records.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Record a payment</h6>
                            <p>Find the reservation's bill and click <strong>Add Payment</strong>.
                                Enter the amount, payment method (Cash / Credit Card / Debit Card /
                                Bank Transfer), and transaction reference if applicable.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Generate a receipt</h6>
                            <p>Once a bill is fully paid, click <strong>Print / Download Receipt</strong>
                                to produce a PDF receipt for the guest.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">4</div>
                        <div class="step-content">
                            <h6>Refunds</h6>
                            <p>Refunds can only be processed by an administrator.
                                If a guest requests a refund, note the details and escalate to your manager.</p>
                        </div>
                    </li>
                </ul>
                <div class="tip-box">
                    <i class="fas fa-lightbulb"></i>
                    <p>Always confirm the payment amount with the guest before marking it as PAID. Mistakes require admin correction.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 7 · ADMIN FEATURES (admin only)
    ════════════════════════════════════════ -->
    <% if (isAdmin) { %>
    <div id="admin">
        <div class="section-title"><i class="fas fa-shield-alt me-2"></i>Admin-Only Features</div>
        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-users-cog"></i></div>
                <div>
                    <h5>Managing Staff Accounts</h5>
                    <p>Create, edit, and deactivate staff users</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Go to Manage Staff</h6>
                            <p>Click <strong>Manage Staff</strong> under Administration in the sidebar.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Add a new staff member</h6>
                            <p>Click <strong>Add Staff</strong>, fill in their name, email, and role
                                (STAFF or ADMIN), then set a temporary password.
                                Inform the new employee to change their password on first login.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Edit or deactivate</h6>
                            <p>Use the edit icon to update details.
                                To prevent a staff member from logging in, set their account to <em>Inactive</em>.
                                Do not delete accounts — this removes their activity history.</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>

        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-chart-bar"></i></div>
                <div>
                    <h5>Reports &amp; Analytics</h5>
                    <p>Revenue reports, occupancy trends, and exports</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Open Reports</h6>
                            <p>Click <strong>Reports</strong> in the sidebar (Administration section).</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Available report types</h6>
                            <ul>
                                <li><strong>Revenue Report</strong> — daily/monthly/annual income breakdown.</li>
                                <li><strong>Occupancy Report</strong> — room utilisation percentages by date range.</li>
                                <li><strong>Reservation Summary</strong> — counts by status and date range.</li>
                                <li><strong>Guest Report</strong> — new vs returning guests.</li>
                            </ul>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Export data</h6>
                            <p>Use the <strong>Export CSV</strong> or <strong>Print PDF</strong> buttons
                                to download reports for external use or management review.</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>

        <div class="help-card">
            <div class="help-card-header" onclick="toggleCard(this)">
                <div class="icon-circle"><i class="fas fa-door-open"></i></div>
                <div>
                    <h5>Managing Rooms (Add / Edit / Delete)</h5>
                    <p>Configure the hotel's room inventory</p>
                </div>
                <i class="fas fa-chevron-down chevron"></i>
            </div>
            <div class="help-card-body">
                <ul class="step-list">
                    <li>
                        <div class="step-num">1</div>
                        <div class="step-content">
                            <h6>Go to Manage Rooms</h6>
                            <p>Click <strong>Manage Rooms</strong> under Administration in the sidebar.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">2</div>
                        <div class="step-content">
                            <h6>Add a room</h6>
                            <p>Click <strong>Add Room</strong>. Enter room number, type, floor, capacity,
                                nightly rate, and description. Save to make it bookable.</p>
                        </div>
                    </li>
                    <li>
                        <div class="step-num">3</div>
                        <div class="step-content">
                            <h6>Set a room to Maintenance</h6>
                            <p>Edit the room and change its status to <em>MAINTENANCE</em>.
                                The room will no longer appear as available for new bookings.</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <% } %>

    <!-- ════════════════════════════════════════
         SECTION 8 · STATUS REFERENCE
    ════════════════════════════════════════ -->
    <div id="statuses">
        <div class="section-title"><i class="fas fa-tags me-2"></i>Status Reference Guide</div>
        <div class="help-card">
            <div class="help-card-body" style="padding-top:20px;">
                <p style="font-size:0.88rem; color:var(--secondary-color); margin-bottom:16px;">
                    Quick reference for all status badges you will see throughout the system.
                </p>

                <h6 style="font-size:0.88rem; font-weight:600; margin-bottom:10px;">Reservation Statuses</h6>
                <div class="status-ref">
                    <div class="status-item"><span class="badge-status badge-pending">PENDING</span> — Created but not yet confirmed.</div>
                    <div class="status-item"><span class="badge-status badge-confirmed">CONFIRMED</span> — Booking confirmed; awaiting arrival.</div>
                    <div class="status-item"><span class="badge-status badge-checked-in">CHECKED IN</span> — Guest is currently in the hotel.</div>
                    <div class="status-item"><span class="badge-status badge-checked-out">CHECKED OUT</span> — Guest has departed.</div>
                    <div class="status-item"><span class="badge-status badge-cancelled">CANCELLED</span> — Reservation was cancelled.</div>
                </div>

                <hr style="margin:18px 0; border-color:#f0f4f8;">

                <h6 style="font-size:0.88rem; font-weight:600; margin-bottom:10px;">Payment Statuses</h6>
                <div class="status-ref">
                    <div class="status-item"><span class="badge-status badge-pending">PENDING</span> — Payment not yet received.</div>
                    <div class="status-item"><span class="badge-status badge-confirmed">PAID</span> — Full payment received.</div>
                    <div class="status-item"><span class="badge-status badge-cancelled">REFUNDED</span> — Payment has been returned to the guest.</div>
                </div>

                <hr style="margin:18px 0; border-color:#f0f4f8;">

                <h6 style="font-size:0.88rem; font-weight:600; margin-bottom:10px;">Allowed Status Transitions</h6>
                <p style="font-size:0.83rem; color:var(--secondary-color);">
                    PENDING → CONFIRMED → CHECKED IN → CHECKED OUT<br>
                    Any status → CANCELLED (before check-in only)
                </p>
            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 9 · FAQ
    ════════════════════════════════════════ -->
    <div id="faq">
        <div class="section-title"><i class="fas fa-comment-dots me-2"></i>Frequently Asked Questions</div>
        <div class="help-card">
            <div class="help-card-body" style="padding-top:10px;">

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">What do I do if a guest doesn't have a profile yet?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Create a new guest profile before or during the reservation process.
                        On the New Reservation form, if no match is found in the search, you can fill in the
                        guest details inline — a profile will be saved automatically when the reservation is confirmed.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">A guest wants to extend their stay. How do I do that?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Open the existing reservation, click Edit, and change the check-out date
                        to the new departure date. The system will verify the room is available for the
                        additional nights and recalculate the total cost. Save to confirm the extension.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">How do I move a guest to a different room?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Edit the reservation and select a different room number from the
                        available rooms list for the same dates. Note: room moves during an active CHECKED IN
                        stay may require admin approval depending on hotel policy.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">I made a mistake entering a payment. Who can fix it?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Payment corrections require administrator access.
                        Note down the reservation number, the incorrect amount, and the correct amount,
                        then contact your manager or an admin user to make the adjustment.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">The system shows a room as occupied but the guest checked out. What should I do?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Ensure the check-out button was clicked on the reservation. If the
                        reservation status is still CHECKED IN, open it and click the check-out button.
                        If the issue persists, contact your administrator — there may be a system sync issue.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">How long does my login session last?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Sessions expire after 30 minutes of inactivity. You will be redirected
                        to the login page automatically. Always save your work before stepping away from
                        the computer.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">I forgot my password. What should I do?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Contact your administrator to reset your password.
                        For security reasons, staff members cannot reset their own passwords.
                        An admin can issue a temporary password which you should change immediately
                        after logging in.</div>
                </div>

                <div class="faq-item" onclick="toggleFaq(this)">
                    <div class="faq-q">Can I access the system from my phone?
                        <i class="fas fa-chevron-down"></i></div>
                    <div class="faq-a">Yes. The interface is mobile-responsive. Open the system URL in
                        your phone's browser. For the best experience, use a tablet or laptop.
                        The sidebar collapses on small screens — tap the menu icon to expand it.</div>
                </div>

            </div>
        </div>
    </div>

    <!-- ════════════════════════════════════════
         SECTION 10 · CONTACT SUPPORT
    ════════════════════════════════════════ -->
    <div class="section-title"><i class="fas fa-headset me-2"></i>Need More Help?</div>
    <div class="contact-grid mb-4">
        <div class="contact-card">
            <i class="fas fa-user-tie"></i>
            <h6>Your Manager</h6>
            <p>For operational questions, policy queries, or urgent issues during your shift — speak to your direct supervisor.</p>
        </div>
        <div class="contact-card">
            <i class="fas fa-tools"></i>
            <h6>System Administrator</h6>
            <p>For password resets, account issues, data corrections, or system errors — contact the hotel's system admin.</p>
        </div>
        <div class="contact-card">
            <i class="fas fa-book"></i>
            <h6>This Help Page</h6>
            <p>Bookmark this page and return anytime. It covers all current features of the Ocean View Reservation System.</p>
        </div>
    </div>

</div><!-- /main-content -->

<!-- Back to top -->
<button id="backToTop" onclick="window.scrollTo({top:0,behavior:'smooth'})" title="Back to top">
    <i class="fas fa-chevron-up"></i>
</button>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ── Accordion toggle ── */
    function toggleCard(header) {
        const body = header.nextElementSibling;
        const isOpen = body.style.display !== 'none' && body.style.display !== '';
        if (isOpen) {
            body.style.display = 'none';
            header.classList.add('collapsed');
        } else {
            body.style.display = 'block';
            header.classList.remove('collapsed');
        }
    }

    /* ── FAQ toggle ── */
    function toggleFaq(item) {
        item.classList.toggle('open');
    }

    /* ── Back-to-top visibility ── */
    const btn = document.getElementById('backToTop');
    window.addEventListener('scroll', () => {
        btn.style.display = window.scrollY > 300 ? 'flex' : 'none';
    });

    /* ── Smooth scroll for quick-nav links ── */
    document.querySelectorAll('.quick-nav a').forEach(a => {
        a.addEventListener('click', e => {
            e.preventDefault();
            const target = document.querySelector(a.getAttribute('href'));
            if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });
    });
</script>
</body>
</html>
