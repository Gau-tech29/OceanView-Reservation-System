<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
  // FIX: removed admin-only redirect — both staff and admin can process refunds
  boolean isAdmin = user.isAdmin();
  String basePath = isAdmin ? "/admin" : "/staff";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Refund Payment - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #0d6efd;
      --primary-dark: #0b5ed7;
      --secondary: #6c757d;
      --danger: #dc3545;
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
    .sidebar-brand p  { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }

    .sidebar-menu { list-style: none; padding: 5px 10px; margin: 0; }
    .sidebar-menu li { margin-bottom: 4px; }
    .sidebar-menu a {
      display: flex; align-items: center; padding: 11px 15px;
      color: rgba(255,255,255,0.85); text-decoration: none;
      border-radius: 10px; transition: all 0.2s;
    }
    .sidebar-menu a:hover,
    .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
    .sidebar-menu a i { width: 28px; font-size: 1.05rem; }
    .sidebar-menu a span { font-size: 0.9rem; font-weight: 500; }

    .main-content { margin-left: var(--sidebar-width); padding: 22px 28px; }

    .top-nav {
      background: white; border-radius: 15px; padding: 14px 22px;
      margin-bottom: 22px; box-shadow: 0 2px 10px rgba(0,0,0,0.06);
      display: flex; justify-content: space-between; align-items: center;
    }
    .page-title h2 { font-size: 1.35rem; font-weight: 600; color: #212529; margin: 0; }

    .user-avatar {
      width: 40px; height: 40px;
      background: linear-gradient(135deg, #0d6efd, #0b5ed7);
      border-radius: 10px; display: flex; align-items: center;
      justify-content: center; color: white; font-weight: 700;
    }

    .refund-container {
      max-width: 700px;
      margin: 0 auto;
      background: white;
      border-radius: 20px;
      padding: 30px;
      box-shadow: 0 5px 20px rgba(0,0,0,0.08);
    }

    .payment-summary {
      background: #f8f9fa;
      border-radius: 15px;
      padding: 20px;
      margin-bottom: 25px;
      border-left: 4px solid var(--danger);
    }

    .summary-row {
      display: flex;
      justify-content: space-between;
      padding: 10px 0;
      border-bottom: 1px solid #e9ecef;
    }
    .summary-row:last-child { border-bottom: none; }
    .summary-label { font-weight: 600; color: #495057; font-size: 0.9rem; }
    .summary-value { font-weight: 500; font-size: 0.9rem; }

    .warning-box {
      background: #fff3cd;
      border: 1px solid #ffeeba;
      border-radius: 10px;
      padding: 15px 18px;
      margin-bottom: 25px;
      color: #856404;
      display: flex;
      align-items: flex-start;
      gap: 10px;
    }
    .warning-box i { font-size: 1.2rem; margin-top: 2px; flex-shrink: 0; }

    .form-label { font-weight: 600; color: #495057; margin-bottom: 8px; }

    .form-control {
      border-radius: 10px;
      padding: 10px 15px;
      border: 1px solid #dee2e6;
    }
    .form-control:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 0.2rem rgba(13,110,253,0.25);
    }

    .btn-refund {
      background: linear-gradient(135deg, #dc3545, #b02a37);
      color: white; border: none;
      padding: 12px 30px;
      border-radius: 12px;
      font-weight: 600;
      transition: all 0.2s;
      cursor: pointer;
    }
    .btn-refund:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(220,53,69,0.3);
      color: white;
    }

    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; }
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
  <ul class="sidebar-menu">
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
      <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations">
      <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
      <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests">
      <i class="fas fa-users"></i><span>Guests</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">
      <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
    <li><a href="${pageContext.request.contextPath}<%= basePath %>/payments" class="active">
      <i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
    <% if (isAdmin) { %>
    <li><a href="${pageContext.request.contextPath}/admin/manage-staff">
      <i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/manage-rooms">
      <i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/reports">
      <i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
    <% } %>
    <li><a href="${pageContext.request.contextPath}/logout">
      <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
  </ul>
</div>

<!-- Main Content -->
<div class="main-content">
  <div class="top-nav">
    <div class="page-title">
      <h2><i class="fas fa-undo-alt me-2 text-danger"></i>Process Refund</h2>
    </div>
    <div class="d-flex align-items-center gap-3">
      <div class="user-avatar">
        <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
      </div>
      <div>
        <div style="font-weight:600;font-size:.9rem;"><%= user.getFullName() %></div>
        <div style="font-size:.75rem;color:#6c757d;">
          <%= user.getRole() %><%= isAdmin ? " (Admin)" : "" %>
        </div>
      </div>
    </div>
  </div>

  <div class="refund-container">
    <h4 class="mb-4">
      <i class="fas fa-exclamation-triangle text-warning me-2"></i>Confirm Refund
    </h4>

    <!-- Payment Summary -->
    <div class="payment-summary">
      <h5 class="mb-3 fw-600">Payment Details</h5>
      <div class="summary-row">
        <span class="summary-label">Payment Number</span>
        <span class="summary-value"><strong>${payment.paymentNumber}</strong></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Amount to Refund</span>
        <span class="summary-value text-danger fw-bold fs-5">${payment.formattedAmount}</span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Payment Method</span>
        <span class="summary-value">${payment.paymentMethodDisplay}</span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Payment Date</span>
        <span class="summary-value">${payment.formattedPaymentDate}</span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Guest Name</span>
        <span class="summary-value">${payment.guestName}</span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Reservation #</span>
        <span class="summary-value">${payment.reservationNumber}</span>
      </div>
      <c:if test="${not empty payment.billNumber}">
        <div class="summary-row">
          <span class="summary-label">Bill #</span>
          <span class="summary-value">${payment.billNumber}</span>
        </div>
      </c:if>
    </div>

    <!-- Warning -->
    <div class="warning-box">
      <i class="fas fa-exclamation-circle"></i>
      <div>
        <strong>Warning:</strong> This action will permanently mark the payment as
        <strong>REFUNDED</strong>. The payment status cannot be changed back unless
        a new payment is processed for this reservation.
      </div>
    </div>

    <!-- Refund Form -->
    <%-- FIX: form posts to basePath (works for both /admin and /staff) --%>
    <form method="POST"
          action="${pageContext.request.contextPath}<%= basePath %>/payments/refund"
          onsubmit="return confirmRefund()">
      <input type="hidden" name="id" value="${payment.id}">

      <div class="mb-4">
        <label class="form-label">
          Reason for Refund <span class="text-danger">*</span>
        </label>
        <textarea name="reason" class="form-control" rows="4"
                  placeholder="Please provide the reason for this refund (e.g., guest cancellation, overpayment, service issue, early departure...)"
                  required></textarea>
        <div class="form-text text-muted mt-1">
          This reason will be recorded in the payment notes for audit purposes.
        </div>
      </div>

      <div class="d-flex gap-3">
        <button type="submit" class="btn-refund flex-grow-1">
          <i class="fas fa-check-circle me-2"></i>Confirm Refund of ${payment.formattedAmount}
        </button>
        <a href="${pageContext.request.contextPath}<%= basePath %>/payments/view?id=${payment.id}"
           class="btn btn-outline-secondary px-4">
          <i class="fas fa-times me-1"></i>Cancel
        </a>
      </div>
    </form>
  </div>
</div>

<script>
  function confirmRefund() {
    const reason = document.querySelector('textarea[name="reason"]').value.trim();
    if (!reason) {
      alert('Please provide a reason for the refund.');
      return false;
    }
    return confirm(
            'Are you absolutely sure you want to process this refund?\n\n' +
            'Payment: ${payment.paymentNumber}\n' +
            'Amount:  ${payment.formattedAmount}\n' +
            'Guest:   ${payment.guestName}\n\n' +
            'This will:\n' +
            '  • Mark the payment status as REFUNDED\n' +
            '  • Record the reason in payment notes\n' +
            '  • This action cannot be undone\n\n' +
            'Proceed?'
    );
  }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
