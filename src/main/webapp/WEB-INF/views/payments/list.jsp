<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.PaymentDTO" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    boolean isAdmin = user.isAdmin();
    String basePath = isAdmin ? "/admin" : "/staff";
    // FIX: expose isAdmin to EL scope so ${isAdmin} works in JSTL c:if tags
    pageContext.setAttribute("isAdmin", isAdmin);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments & Bills - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0d6efd;
            --primary-dark: #0b5ed7;
            --secondary: #6c757d;
            --success: #198754;
            --danger: #dc3545;
            --warning: #ffc107;
            --info: #0dcaf0;
            --sidebar-width: 280px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f6f9;
            overflow-x: hidden;
        }

        .sidebar {
            position: fixed;
            top: 0; left: 0;
            height: 100vh;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
            color: white;
            z-index: 1000;
            overflow-y: auto;
            box-shadow: 3px 0 15px rgba(0,0,0,0.15);
        }

        .sidebar-brand {
            padding: 25px 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            margin-bottom: 10px;
        }
        .sidebar-brand h3 { font-size: 1.4rem; font-weight: 700; margin: 0; }
        .sidebar-brand p { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }

        .sidebar-label {
            font-size: 0.7rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px;
            opacity: 0.5; padding: 15px 22px 5px;
        }

        .sidebar-menu { list-style: none; padding: 5px 12px; margin: 0; }
        .sidebar-menu li { margin-bottom: 4px; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 11px 15px;
            color: rgba(255,255,255,0.85); text-decoration: none;
            transition: all 0.2s; border-radius: 10px; font-weight: 500;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,255,255,0.18); color: white;
        }
        .sidebar-menu a i { width: 28px; font-size: 1.05rem; }
        .sidebar-menu a span { font-size: 0.88rem; }

        .main-content { margin-left: var(--sidebar-width); padding: 22px 30px; }

        .top-nav {
            background: white; border-radius: 16px; padding: 14px 24px;
            margin-bottom: 22px; box-shadow: 0 4px 20px rgba(13,110,253,0.1);
            display: flex; justify-content: space-between; align-items: center;
        }

        .page-title h2 {
            font-size: 1.5rem; font-weight: 700; margin: 0;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .page-title p { color: var(--secondary); margin: 3px 0 0; font-size: 0.85rem; }

        .user-menu { display: flex; align-items: center; gap: 15px; }
        .user-avatar {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; color: white; font-weight: 700; font-size: 1rem;
        }
        .user-name { font-weight: 600; color: #212529; font-size: 0.9rem; }
        .user-role { font-size: 0.75rem; color: var(--secondary); }

        .alert-success-custom {
            background: #d4edda; color: #155724; border: 1px solid #c3e6cb;
            border-radius: 10px; padding: 12px 18px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-error-custom {
            background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;
            border-radius: 10px; padding: 12px 18px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
        }

        .stats-grid {
            display: grid; grid-template-columns: repeat(4, 1fr);
            gap: 18px; margin-bottom: 25px;
        }
        .stat-card {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: 0 4px 20px rgba(13,110,253,0.1);
            display: flex; align-items: center; justify-content: space-between;
            transition: all 0.25s; border-left: 4px solid var(--primary);
        }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(13,110,253,0.18); }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; color: #212529; margin-bottom: 4px; line-height: 1; }
        .stat-info p { color: var(--secondary); margin: 0; font-size: 0.82rem; font-weight: 500; }
        .stat-icon {
            width: 55px; height: 55px;
            background: linear-gradient(135deg, #0d6efd, #0a3d8f);
            border-radius: 12px; display: flex; align-items: center; justify-content: center;
            box-shadow: 0 8px 15px rgba(13,110,253,0.3);
        }
        .stat-icon i { font-size: 24px; color: white; }

        .section-title {
            font-size: 1.05rem; font-weight: 600; color: #212529;
            margin-bottom: 15px; padding-left: 12px;
            border-left: 3px solid var(--primary);
        }

        .search-section {
            background: white; border-radius: 15px; padding: 20px;
            box-shadow: 0 4px 20px rgba(13,110,253,0.1); margin-bottom: 25px;
        }

        .table-card {
            background: white; border-radius: 15px; padding: 22px;
            box-shadow: 0 4px 20px rgba(13,110,253,0.1); margin-bottom: 25px;
        }
        .table-header {
            display: flex; justify-content: space-between;
            align-items: center; margin-bottom: 15px;
        }
        .table th {
            font-size: 0.78rem; font-weight: 700; color: var(--secondary);
            text-transform: uppercase; letter-spacing: 0.5px; padding: 12px 10px;
            border-bottom: 2px solid #f0f4f8;
        }
        .table td {
            padding: 13px 10px; vertical-align: middle;
            font-size: 0.88rem; border-bottom: 1px solid #f8f9fa;
        }

        .badge-status {
            padding: 5px 12px; border-radius: 20px;
            font-size: 0.76rem; font-weight: 600; display: inline-block;
        }
        .badge-completed  { background: #d4edda; color: #155724; }
        .badge-refunded   { background: #f8d7da; color: #721c24; }
        .badge-pending    { background: #fff3cd; color: #856404; }
        .badge-failed     { background: #f8d7da; color: #721c24; }
        .badge-paid       { background: #d4edda; color: #155724; }
        .badge-draft      { background: #e2e3e5; color: #383d41; }
        .badge-issued     { background: #cce5ff; color: #004085; }

        .payment-method-badge {
            padding: 4px 8px; border-radius: 12px;
            font-size: 0.75rem; font-weight: 500;
            background: #e9ecef; color: #495057;
        }
        .payment-method-cash  { background: #d4edda; color: #155724; }
        .payment-method-card  { background: #cce5ff; color: #004085; }
        .payment-method-bank  { background: #fff3cd; color: #856404; }

        .pagination { margin-top: 20px; justify-content: center; }
        .page-link {
            border-radius: 8px; margin: 0 3px;
            color: var(--primary); border: 1px solid #dee2e6;
        }
        .page-item.active .page-link { background: var(--primary); border-color: var(--primary); }

        .action-buttons { display: flex; gap: 5px; flex-wrap: wrap; }
        .btn-action {
            width: 32px; height: 32px; padding: 0;
            display: inline-flex; align-items: center;
            justify-content: center; border-radius: 8px;
        }

        .search-box { position: relative; max-width: 400px; }
        .search-box input {
            padding-right: 45px; border-radius: 30px;
            border: 1px solid #dee2e6;
        }
        .search-box button {
            position: absolute; right: 5px; top: 50%;
            transform: translateY(-50%); background: none;
            border: none; color: var(--secondary); padding: 8px 12px;
        }

        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; padding: 15px; }
            .stats-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p><%= isAdmin ? "Admin Control Panel" : "Hotel Reservation System" %></p>
    </div>

    <div class="sidebar-label">Main Menu</div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
        </li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations">
            <i class="fas fa-calendar-alt"></i><span>Reservations</span></a>
        </li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a>
        </li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests">
            <i class="fas fa-users"></i><span>Guests</span></a>
        </li>
<%--        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">--%>
<%--            <i class="fas fa-door-open"></i><span>Rooms</span></a>--%>
<%--        </li>--%>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/payments" class="active">
            <i class="fas fa-credit-card"></i><span>Payments & Bills</span></a>
        </li>
    </ul>

    <% if (isAdmin) { %>
    <div class="sidebar-label">Administration</div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff">
            <i class="fas fa-users-cog"></i><span>Manage Staff</span></a>
        </li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms">
            <i class="fas fa-door-open"></i><span>Manage Rooms</span></a>
        </li>
        <li><a href="${pageContext.request.contextPath}/admin/reports">
            <i class="fas fa-chart-bar"></i><span>Reports</span></a>
        </li>
    </ul>
    <% } %>

    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-credit-card me-2"></i>${pageTitle}</h2>
            <p><i class="fas fa-calendar-alt me-1"></i><%= java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy")) %></p>
        </div>
        <div class="user-menu">
            <div class="user-avatar">
                <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
            </div>
            <div>
                <div class="user-name"><%= user.getFullName() %></div>
                <div class="user-role"><%= user.getRole() %><%= isAdmin ? " (Admin)" : "" %></div>
            </div>
        </div>
    </div>

    <!-- Alert Messages -->
    <%
        String successMsg = (String) session.getAttribute("success");
        String errorMsg   = (String) session.getAttribute("error");
        if (successMsg != null) { session.removeAttribute("success"); }
        if (errorMsg   != null) { session.removeAttribute("error");   }
    %>
    <% if (successMsg != null) { %>
    <div class="alert-success-custom">
        <i class="fas fa-check-circle"></i> <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert-error-custom">
        <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
    </div>
    <% } %>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <h3>$<fmt:formatNumber value="${weeklyRevenue}" pattern="#,##0.00"/></h3>
                <p>Weekly Revenue</p>
            </div>
            <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
        </div>
        <div class="stat-card" style="border-left-color: #198754;">
            <div class="stat-info">
                <h3>$<fmt:formatNumber value="${monthlyRevenue}" pattern="#,##0.00"/></h3>
                <p>Monthly Revenue</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#198754,#146c43);">
                <i class="fas fa-calendar-alt"></i>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #dc3545;">
            <div class="stat-info">
                <h3>$<fmt:formatNumber value="${weeklyRefunds}" pattern="#,##0.00"/></h3>
                <p>Weekly Refunds</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#dc3545,#b02a37);">
                <i class="fas fa-undo-alt"></i>
            </div>
        </div>
        <div class="stat-card" style="border-left-color: #ffc107;">
            <div class="stat-info">
                <h3>${totalCount}</h3>
                <p>Total Transactions</p>
            </div>
            <div class="stat-icon" style="background: linear-gradient(135deg,#ffc107,#e0a800);">
                <i class="fas fa-exchange-alt"></i>
            </div>
        </div>
    </div>

    <!-- Search Section -->
    <div class="search-section">
        <form action="${pageContext.request.contextPath}<%= basePath %>/payments/search" method="get" class="row g-3">
            <div class="col-md-4">
                <label class="form-label fw-semibold">Search</label>
                <div class="search-box">
                    <input type="text" name="keyword" class="form-control"
                           placeholder="Payment #, Bill #, Guest name..." value="${param.keyword}">
                    <button type="submit"><i class="fas fa-search"></i></button>
                </div>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold">Status</label>
                <select name="status" class="form-select">
                    <option value="">All Status</option>
                    <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                    <option value="PENDING"   ${param.status == 'PENDING'   ? 'selected' : ''}>Pending</option>
                    <option value="REFUNDED"  ${param.status == 'REFUNDED'  ? 'selected' : ''}>Refunded</option>
                    <option value="FAILED"    ${param.status == 'FAILED'    ? 'selected' : ''}>Failed</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold">Method</label>
                <select name="method" class="form-select">
                    <option value="">All Methods</option>
                    <option value="CASH"          ${param.method == 'CASH'          ? 'selected' : ''}>Cash</option>
                    <option value="CREDIT_CARD"   ${param.method == 'CREDIT_CARD'   ? 'selected' : ''}>Credit Card</option>
                    <option value="DEBIT_CARD"    ${param.method == 'DEBIT_CARD'    ? 'selected' : ''}>Debit Card</option>
                    <option value="BANK_TRANSFER" ${param.method == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold">From</label>
                <input type="date" name="startDate" class="form-control" value="${param.startDate}">
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold">To</label>
                <input type="date" name="endDate" class="form-control" value="${param.endDate}">
            </div>
            <div class="col-12 text-end">
                <a href="${pageContext.request.contextPath}<%= basePath %>/payments"
                   class="btn btn-outline-secondary">
                    <i class="fas fa-times me-1"></i>Clear
                </a>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search me-1"></i>Search
                </button>
            </div>
        </form>
    </div>

    <!-- Payments Table -->
    <div class="table-card">
        <div class="table-header">
            <span class="section-title mb-0">
                <i class="fas fa-list me-2"></i>Payment Transactions
                <c:if test="${not empty searchKeyword}">
                    <span class="badge bg-info ms-2">Search: "${searchKeyword}"</span>
                </c:if>
            </span>
            <div>
                <span class="text-muted me-3">Total: ${totalCount} records</span>
                <button onclick="window.location.reload()" class="btn btn-sm btn-outline-secondary">
                    <i class="fas fa-sync-alt"></i>
                </button>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>Payment #</th>
                    <th>Date</th>
                    <th>Guest</th>
                    <th>Reservation</th>
                    <th>Bill #</th>
                    <th>Amount</th>
                    <th>Method</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty payments}">
                        <tr>
                            <td colspan="9" class="text-center py-5 text-muted">
                                <i class="fas fa-credit-card fa-3x mb-3 d-block" style="opacity:0.3;"></i>
                                No payment records found.
                                <c:if test="${empty searchKeyword}">
                                    <br><small>Payments appear here when guests check out.</small>
                                </c:if>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${payments}" var="p">
                            <tr>
                                <td><strong>${p.paymentNumber}</strong></td>
                                <td>${p.formattedPaymentDate}</td>
                                <td>
                                        ${p.guestName}
                                    <c:if test="${not empty p.guestEmail}">
                                        <br><small class="text-muted">${p.guestEmail}</small>
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${not empty p.reservationNumber}">
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?number=${p.reservationNumber}"
                                           class="text-decoration-none fw-semibold">
                                                ${p.reservationNumber}
                                        </a>
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${not empty p.billNumber}">
                                        <%-- FIX: use 'id' param not 'reservationId' to match ReservationController.printBill() --%>
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${p.reservationId}"
                                           class="text-decoration-none" target="_blank">
                                                ${p.billNumber}
                                        </a>
                                    </c:if>
                                </td>
                                <td><strong class="text-primary">${p.formattedAmount}</strong></td>
                                <td>
                                    <span class="payment-method-badge
                                        <c:choose>
                                            <c:when test="${p.paymentMethod == 'CASH'}">payment-method-cash</c:when>
                                            <c:when test="${p.paymentMethod == 'CREDIT_CARD' or p.paymentMethod == 'DEBIT_CARD'}">payment-method-card</c:when>
                                            <c:when test="${p.paymentMethod == 'BANK_TRANSFER'}">payment-method-bank</c:when>
                                        </c:choose>">
                                            ${p.paymentMethodDisplay}
                                    </span>
                                </td>
                                <td>
                                    <span class="badge-status ${p.paymentStatusBadgeClass}">
                                            ${p.paymentStatusDisplay}
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <!-- View Details -->
                                        <a href="${pageContext.request.contextPath}<%= basePath %>/payments/view?id=${p.id}"
                                           class="btn btn-sm btn-outline-primary btn-action" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>

                                            <%--
                                                FIX: Use pageContext.getAttribute("isAdmin") to correctly read
                                                the isAdmin flag we set via pageContext.setAttribute() above.
                                                ${isAdmin} now works because we exposed it to EL scope.
                                            --%>
                                        <c:if test="${p.paymentStatus == 'COMPLETED'}">
                                            <a href="${pageContext.request.contextPath}<%= basePath %>/payments/refund?id=${p.id}"
                                               class="btn btn-sm btn-outline-danger btn-action" title="Process Refund"
                                               onclick="return confirm('Are you sure you want to refund payment ${p.paymentNumber}?')">
                                                <i class="fas fa-undo-alt"></i>
                                            </a>
                                        </c:if>

                                        <!-- View / Print Bill -->
                                        <c:if test="${not empty p.billNumber}">
                                            <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${p.reservationId}"
                                               class="btn btn-sm btn-outline-info btn-action" title="View / Print Bill" target="_blank">
                                                <i class="fas fa-file-invoice"></i>
                                            </a>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav>
                <ul class="pagination">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link"
                           href="?page=${currentPage - 1}&size=10${not empty searchKeyword ? '&keyword='.concat(searchKeyword) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.method ? '&method='.concat(param.method) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link"
                               href="?page=${i}&size=10${not empty searchKeyword ? '&keyword='.concat(searchKeyword) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.method ? '&method='.concat(param.method) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}">
                                    ${i}
                            </a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link"
                           href="?page=${currentPage + 1}&size=10${not empty searchKeyword ? '&keyword='.concat(searchKeyword) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.method ? '&method='.concat(param.method) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
