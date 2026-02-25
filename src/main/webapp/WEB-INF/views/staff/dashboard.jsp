<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - Ocean View Hotel</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Chart.js for analytics -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --info-color: #0dcaf0;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --light-bg: #f8f9fa;
            --dark-color: #212529;
            --sidebar-width: 250px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f6f9;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white;
            padding: 20px 0;
            transition: all 0.3s;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }

        .sidebar-brand {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            margin-bottom: 20px;
        }

        .sidebar-brand h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0;
        }

        .sidebar-brand p {
            font-size: 0.85rem;
            opacity: 0.8;
            margin: 5px 0 0;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar-menu li {
            margin-bottom: 5px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: all 0.3s;
            border-left: 3px solid transparent;
        }

        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: rgba(255,255,255,0.1);
            color: white;
            border-left-color: white;
        }

        .sidebar-menu a i {
            width: 30px;
            font-size: 1.2rem;
        }

        .sidebar-menu a span {
            font-size: 0.95rem;
            font-weight: 400;
        }

        /* Main Content Styles */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px 30px;
            transition: all 0.3s;
        }

        /* Top Navigation */
        .top-nav {
            background: white;
            border-radius: 15px;
            padding: 15px 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
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
            margin: 5px 0 0;
            font-size: 0.9rem;
        }

        .user-menu {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .notifications {
            position: relative;
            cursor: pointer;
        }

        .notifications i {
            font-size: 1.3rem;
            color: var(--secondary-color);
        }

        .badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: var(--danger-color);
            color: white;
            border-radius: 50%;
            padding: 3px 6px;
            font-size: 0.7rem;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            padding: 5px 10px;
            border-radius: 10px;
            transition: background 0.3s;
        }

        .user-profile:hover {
            background: var(--light-bg);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        .user-info {
            display: none;
        }

        @media (min-width: 768px) {
            .user-info {
                display: block;
            }
        }

        .user-info .name {
            font-weight: 600;
            color: var(--dark-color);
            line-height: 1.2;
        }

        .user-info .role {
            font-size: 0.8rem;
            color: var(--secondary-color);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .stat-info h3 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 5px;
        }

        .stat-info p {
            color: var(--secondary-color);
            margin: 0;
            font-size: 0.9rem;
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .stat-icon i {
            font-size: 30px;
            color: white;
        }

        /* Section Styles */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-header h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
        }

        .view-all {
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .view-all:hover {
            text-decoration: underline;
        }

        /* Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .feature-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s;
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .card-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }

        .card-icon i {
            font-size: 30px;
            color: white;
        }

        .feature-card h4 {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 10px;
        }

        .feature-card p {
            color: var(--secondary-color);
            font-size: 0.9rem;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .card-link {
            color: var(--primary-color);
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .card-link i {
            transition: transform 0.3s;
        }

        .feature-card:hover .card-link i {
            transform: translateX(5px);
        }

        /* Tables */
        .recent-bookings {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }

        .table {
            margin: 0;
        }

        .table th {
            border-top: none;
            color: var(--secondary-color);
            font-weight: 500;
            font-size: 0.9rem;
            padding: 15px 10px;
        }

        .table td {
            padding: 15px 10px;
            vertical-align: middle;
            color: var(--dark-color);
        }

        .badge-status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .badge-confirmed {
            background: #d4edda;
            color: #155724;
        }

        .badge-pending {
            background: #fff3cd;
            color: #856404;
        }

        .badge-checked-in {
            background: #cce5ff;
            color: #004085;
        }

        .badge-checked-out {
            background: #e2e3e5;
            color: #383d41;
        }

        .btn-action {
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.8rem;
            margin: 0 2px;
        }

        /* Chart Container */
        .chart-container {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .cards-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Get current date
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String currentDate = today.format(formatter);

    // Sample data (replace with actual data from database)
    int activeReservations = 15;
    int availableRooms = 8;
    int totalGuests = 24;
    int todayCheckins = 5;
%>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="#" class="active">
                <i class="fas fa-dashboard"></i>
                <span>Dashboard</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-plus-circle"></i>
                <span>New Reservation</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-search"></i>
                <span>View Reservation</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-receipt"></i>
                <span>Calculate Bill</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-list-alt"></i>
                <span>All Reservations</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-users"></i>
                <span>Guests</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-door-open"></i>
                <span>Rooms</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-chart-bar"></i>
                <span>Reports</span>
            </a>
        </li>
        <li>
            <a href="#">
                <i class="fas fa-question-circle"></i>
                <span>Help</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </a>
        </li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Top Navigation -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Staff Dashboard</h2>
            <p><i class="fas fa-calendar-alt me-2"></i><%= currentDate %></p>
        </div>

        <div class="user-menu">
            <div class="notifications">
                <i class="fas fa-bell"></i>
                <span class="badge">3</span>
            </div>

            <div class="user-profile" onclick="toggleUserMenu()">
                <div class="user-avatar">
                    <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
                </div>
                <div class="user-info">
                    <div class="name"><%= user.getFullName() %></div>
                    <div class="role"><%= user.getRole() %></div>
                </div>
                <i class="fas fa-chevron-down" style="color: var(--secondary-color); font-size: 0.8rem;"></i>
            </div>
        </div>
    </div>

    <!-- Welcome, Banner -->
    <div class="alert alert-primary" style="background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%); color: white; border: none; border-radius: 15px; padding: 20px 30px; margin-bottom: 30px;">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h4 style="font-weight: 600; margin-bottom: 10px;">Welcome back, <%= user.getFirstName() %>! 👋</h4>
                <p style="margin: 0; opacity: 0.9;">You have <%= todayCheckins %> check-ins scheduled for today. Have a great day!</p>
            </div>
            <div class="col-md-4 text-md-end">
                <i class="fas fa-sun" style="font-size: 3rem; opacity: 0.3;"></i>
            </div>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <h3><%= activeReservations %></h3>
                <p>Active Reservations</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-calendar-check"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= availableRooms %></h3>
                <p>Available Rooms</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-door-open"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= totalGuests %></h3>
                <p>Total Guests</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-users"></i>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <h3><%= todayCheckins %></h3>
                <p>Check-ins Today</p>
            </div>
            <div class="stat-icon">
                <i class="fas fa-sign-in-alt"></i>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="section-header">
        <h3>Quick Actions</h3>
    </div>

    <div class="cards-grid">
        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-plus-circle"></i>
            </div>
            <h4>New Reservation</h4>
            <p>Create a new booking for guests with room selection, dates, and special requests.</p>
            <span class="card-link">Create Reservation <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-search"></i>
            </div>
            <h4>Find Reservation</h4>
            <p>Search for existing reservations by booking number, guest name, or dates.</p>
            <span class="card-link">Search Now <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-receipt"></i>
            </div>
            <h4>Generate Bill</h4>
            <p>Calculate stay costs and generate bills for check-out guests.</p>
            <span class="card-link">Calculate Bill <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-door-open"></i>
            </div>
            <h4>Check-in Guest</h4>
            <p>Process guest check-in and assign rooms.</p>
            <span class="card-link">Check-in <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-sign-out-alt"></i>
            </div>
            <h4>Check-out Guest</h4>
            <p>Process guest check-out and generate final bills.</p>
            <span class="card-link">Check-out <i class="fas fa-arrow-right"></i></span>
        </a>

        <a href="#" class="feature-card">
            <div class="card-icon">
                <i class="fas fa-chart-bar"></i>
            </div>
            <h4>View Reports</h4>
            <p>Access occupancy reports, revenue analysis, and booking trends.</p>
            <span class="card-link">View Reports <i class="fas fa-arrow-right"></i></span>
        </a>
    </div>

    <!-- Recent Bookings Table -->
    <div class="recent-bookings">
        <div class="section-header">
            <h3>Recent Bookings</h3>
            <a href="#" class="view-all">View All <i class="fas fa-arrow-right ms-1"></i></a>
        </div>

        <div class="table-responsive">
            <table class="table">
                <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Guest Name</th>
                    <th>Room Type</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td><strong>#BK001</strong></td>
                    <td>John Smith</td>
                    <td>Deluxe Suite</td>
                    <td>2024-02-25</td>
                    <td>2024-02-28</td>
                    <td><span class="badge-status badge-confirmed">Confirmed</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action"><i class="fas fa-edit"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#BK002</strong></td>
                    <td>Emma Wilson</td>
                    <td>Ocean View</td>
                    <td>2024-02-26</td>
                    <td>2024-03-01</td>
                    <td><span class="badge-status badge-pending">Pending</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action"><i class="fas fa-edit"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#BK003</strong></td>
                    <td>Michael Brown</td>
                    <td>Standard Room</td>
                    <td>2024-02-24</td>
                    <td>2024-02-27</td>
                    <td><span class="badge-status badge-checked-in">Checked In</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action"><i class="fas fa-edit"></i></button>
                    </td>
                </tr>
                <tr>
                    <td><strong>#BK004</strong></td>
                    <td>Sarah Davis</td>
                    <td>Family Room</td>
                    <td>2024-02-23</td>
                    <td>2024-02-26</td>
                    <td><span class="badge-status badge-checked-out">Checked Out</span></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary btn-action"><i class="fas fa-eye"></i></button>
                        <button class="btn btn-sm btn-outline-success btn-action"><i class="fas fa-edit"></i></button>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Charts and Additional Info -->
    <div class="row">
        <div class="col-md-8">
            <div class="chart-container">
                <div class="section-header">
                    <h3>Weekly Occupancy</h3>
                </div>
                <canvas id="occupancyChart"></canvas>
            </div>
        </div>

        <div class="col-md-4">
            <div class="chart-container">
                <div class="section-header">
                    <h3>Room Type Distribution</h3>
                </div>
                <canvas id="roomTypeChart"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Toggle user menu (you can implement a dropdown menu here)
    function toggleUserMenu() {
        // Implement user menu dropdown
        console.log('User menu clicked');
    }

    // Initialize charts
    document.addEventListener('DOMContentLoaded', function() {
        // Occupancy Chart
        const ctx1 = document.getElementById('occupancyChart').getContext('2d');
        new Chart(ctx1, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Occupancy Rate',
                    data: [65, 70, 75, 80, 85, 90, 88],
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });

        // Room Type Chart
        const ctx2 = document.getElementById('roomTypeChart').getContext('2d');
        new Chart(ctx2, {
            type: 'doughnut',
            data: {
                labels: ['Standard', 'Deluxe', 'Suite', 'Ocean View', 'Family'],
                datasets: [{
                    data: [30, 25, 15, 20, 10],
                    backgroundColor: [
                        '#0d6efd',
                        '#198754',
                        '#ffc107',
                        '#dc3545',
                        '#6c757d'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    });

    // Auto-refresh data every 30 seconds (optional)
    setInterval(function() {
        // Refresh stats and recent bookings
        console.log('Refreshing dashboard data...');
    }, 30000);
</script>
</body>
</html>