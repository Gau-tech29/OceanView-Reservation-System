<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
  boolean isAdmin = user.isAdmin();
  String basePath = isAdmin ? "/admin" : "/staff";
  // FIX: expose isAdmin to EL scope so ${isAdmin} works inside c:if tags
  pageContext.setAttribute("isAdmin", isAdmin);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Payment Details - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #0d6efd; --primary-dark: #0b5ed7;
      --secondary: #6c757d; --success: #198754;
      --danger: #dc3545; --warning: #ffc107; --info: #0dcaf0;
      --sidebar-width: 280px;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; overflow-x: hidden; }

    .sidebar {
      position: fixed; top: 0; left: 0; height: 100vh;
      width: var(--sidebar-width);
      background: linear-gradient(180deg, #0b5ed7 0%, #0d6efd 100%);
      color: white; z-index: 1000; overflow-y: auto;
      box-shadow: 3px 0 15px rgba(0,0,0,0.15);
    }
    .sidebar-brand { padding: 25px 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
    .sidebar-brand h3 { font-size: 1.4rem; font-weight: 700; margin: 0; }
    .sidebar-brand p { font-size: 0.8rem; opacity: 0.8; margin: 4px 0 0; }
    .sidebar-menu { list-style: none; padding: 5px 10px; margin: 0; }
    .sidebar-menu li { margin-bottom: 4px; }
    .sidebar-menu a {
      display: flex; align-items: center; padding: 11px 15px;
      color: rgba(255,255,255,0.85); text-decoration: none;
      border-radius: 10px; transition: all 0.2s;
    }
    .sidebar-menu a:hover, .sidebar-menu a.active { background: rgba(255,255,255,0.15); color: white; }
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

    .detail-container {
      background: white; border-radius: 20px; padding: 30px;
      box-shadow: 0 5px 20px rgba(0,0,0,0.08); margin-bottom: 25px;
    }
    .detail-header {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #f0f4f8;
    }
    .detail-header h3 { font-size: 1.3rem; font-weight: 700; color: #212529; margin: 0; }

    .status-badge { padding: 8px 18px; border-radius: 30px; font-weight: 600; font-size: 0.9rem; }
    .status-COMPLETED { background: #d4edda; color: #155724; }
    .status-REFUNDED  { background: #f8d7da; color: #721c24; }
    .status-PENDING   { background: #fff3cd; color: #856404; }
    .status-FAILED    { background: #f8d7da; color: #721c24; }

    .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; }
    .info-card { background: #f8f9fa; border-radius: 15px; padding: 20px; }
    .info-card h5 {
      font-size: 1rem; font-weight: 600; color: var(--primary);
      margin-bottom: 15px; padding-bottom: 8px; border-bottom: 2px solid #e9ecef;
    }
    .info-row { display: flex; margin-bottom: 10px; }
    .info-label { width: 130px; font-size: 0.85rem; color: #6c757d; flex-shrink: 0; }
    .info-value { flex: 1; font-size: 0.95rem; font-weight: 500; color: #212529; }

    .amount-box {
      background: linear-gradient(135deg, #0d6efd, #0a3d8f);
      color: white; border-radius: 15px; padding: 25px;
      text-align: center; margin-bottom: 30px;
    }
    .amount-box .label { font-size: 0.9rem; opacity: 0.9; margin-bottom: 5px; }
    .amount-box .amount { font-size: 3rem; font-weight: 700; line-height: 1.2; }

    /* FIX: Refunded state styling for the amount box */
    .amount-box.refunded {
      background: linear-gradient(135deg, #dc3545, #b02a37);
    }

    .bill-card {
      background: #f8f9fa; border-radius: 15px; padding: 20px;
      margin-top: 20px; border: 1px solid #e9ecef;
    }
    .bill-card h5 { font-size: 1rem; font-weight: 600; color: var(--primary); margin-bottom: 15px; }

    .badge-status { padding: 5px 12px; border-radius: 20px; font-size: 0.76rem; font-weight: 600; display: inline-block; }
    .badge-completed { background: #d4edda; color: #155724; }
    .badge-pending   { background: #fff3cd; color: #856404; }
    .badge-issued    { background: #cce5ff; color: #004085; }
    .badge-draft     { background: #e2e3e5; color: #383d41; }
    .badge-refunded  { background: #f8d7da; color: #721c24; }

    /* Refund warning banner */
    .refund-notice {
      background: #fff3cd; border: 1px solid #ffc107; border-radius: 12px;
      padding: 14px 18px; margin-bottom: 20px;
      display: flex; align-items: center; gap: 12px; color: #856404;
    }

    .action-buttons { display: flex; gap: 10px; margin-top: 30px; flex-wrap: wrap; }

    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; }
      .info-grid { grid-template-columns: 1fr; }
      .action-buttons { flex-direction: column; }
    }
  </style>
</head>
<body>

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
    <li><a href="${pageContext.request.contextPath}/logout">
      <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
  </ul>
</div>

<div class="main-content">
  <div class="top-nav">
    <div class="page-title">
      <h2><i class="fas fa-credit-card me-2 text-primary"></i>Payment Details</h2>
    </div>
    <div class="d-flex align-items-center gap-3">
      <div class="user-avatar">
        <%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %>
      </div>
      <div>
        <div style="font-weight:600;font-size:.9rem;"><%= user.getFullName() %></div>
        <div style="font-size:.75rem;color:#6c757d;"><%= user.getRole() %></div>
      </div>
    </div>
  </div>

  <c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show">
      <i class="fas fa-exclamation-circle me-2"></i>${error}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <%-- Show refunded notice --%>
  <c:if test="${payment.paymentStatus == 'REFUNDED'}">
    <div class="refund-notice">
      <i class="fas fa-exclamation-triangle fa-lg"></i>
      <div>
        <strong>This payment has been refunded.</strong>
        <c:if test="${not empty payment.notes}">
          <span class="ms-2">Note: ${payment.notes}</span>
        </c:if>
      </div>
    </div>
  </c:if>

  <div class="detail-container">
    <div class="detail-header">
      <h3>Payment #${payment.paymentNumber}</h3>
      <span class="status-badge status-${payment.paymentStatus}">
        ${payment.paymentStatusDisplay}
      </span>
    </div>

    <%-- FIX: highlight amount box differently when refunded --%>
    <div class="amount-box ${payment.paymentStatus == 'REFUNDED' ? 'refunded' : ''}">
      <div class="label">
        <c:choose>
          <c:when test="${payment.paymentStatus == 'REFUNDED'}">Refunded Amount</c:when>
          <c:otherwise>Total Amount Paid</c:otherwise>
        </c:choose>
      </div>
      <div class="amount">${payment.formattedAmount}</div>
      <div class="mt-2">via ${payment.paymentMethodDisplay}</div>
    </div>

    <div class="info-grid">
      <!-- Payment Information -->
      <div class="info-card">
        <h5><i class="fas fa-calendar me-2"></i>Payment Information</h5>
        <div class="info-row">
          <span class="info-label">Payment Date:</span>
          <span class="info-value">${payment.formattedPaymentDate}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Payment #:</span>
          <span class="info-value"><strong>${payment.paymentNumber}</strong></span>
        </div>
        <div class="info-row">
          <span class="info-label">Method:</span>
          <span class="info-value">${payment.paymentMethodDisplay}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Status:</span>
          <span class="info-value">
                        <span class="badge-status badge-${payment.paymentStatus == 'COMPLETED' ? 'completed' : (payment.paymentStatus == 'REFUNDED' ? 'refunded' : 'pending')}">
                          ${payment.paymentStatusDisplay}
                        </span>
                    </span>
        </div>
        <div class="info-row">
          <span class="info-label">Transaction ID:</span>
          <span class="info-value">${not empty payment.transactionId ? payment.transactionId : '—'}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Card Last 4:</span>
          <span class="info-value">${not empty payment.cardLastFour ? '****'.concat(payment.cardLastFour) : '—'}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Notes:</span>
          <span class="info-value" style="font-size:0.85rem;">${not empty payment.notes ? payment.notes : '—'}</span>
        </div>
      </div>

      <!-- Guest Information -->
      <div class="info-card">
        <h5><i class="fas fa-user me-2"></i>Guest Information</h5>
        <div class="info-row">
          <span class="info-label">Name:</span>
          <span class="info-value"><strong>${payment.guestName}</strong></span>
        </div>
        <div class="info-row">
          <span class="info-label">Email:</span>
          <span class="info-value">${not empty payment.guestEmail ? payment.guestEmail : '—'}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Phone:</span>
          <span class="info-value">${not empty payment.guestPhone ? payment.guestPhone : '—'}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Guest ID:</span>
          <span class="info-value">${payment.guestId}</span>
        </div>
      </div>
    </div>

    <div class="info-grid">
      <!-- Reservation Details -->
      <div class="info-card">
        <h5><i class="fas fa-hotel me-2"></i>Reservation Details</h5>
        <div class="info-row">
          <span class="info-label">Reservation #:</span>
          <span class="info-value">
                        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?number=${payment.reservationNumber}"
                           class="text-decoration-none fw-semibold">
                          ${payment.reservationNumber}
                        </a>
                    </span>
        </div>
        <div class="info-row">
          <span class="info-label">Reservation ID:</span>
          <span class="info-value">${payment.reservationId}</span>
        </div>
      </div>

      <!-- Bill Information -->
      <c:choose>
        <c:when test="${not empty payment.billNumber}">
          <div class="info-card">
            <h5><i class="fas fa-file-invoice me-2"></i>Bill Information</h5>
            <div class="info-row">
              <span class="info-label">Bill #:</span>
              <span class="info-value">
                                <%-- FIX: use reservationId param which ReservationController.printBill() now handles --%>
                                <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${payment.reservationId}"
                                   class="text-decoration-none fw-semibold" target="_blank">
                                    ${payment.billNumber} <i class="fas fa-external-link-alt ms-1" style="font-size:0.75rem;"></i>
                                </a>
                            </span>
            </div>
            <div class="info-row">
              <span class="info-label">Bill Total:</span>
              <span class="info-value">
                                Rs.<fmt:formatNumber value="${payment.billTotalAmount}" pattern="#,##0.00"/>
                            </span>
            </div>
            <div class="info-row">
              <span class="info-label">Bill Status:</span>
              <span class="info-value">
                                <span class="badge-status
                                    <c:choose>
                                        <c:when test="${payment.billStatus == 'PAID'}">badge-completed</c:when>
                                        <c:when test="${payment.billStatus == 'PARTIALLY PAID'}">badge-pending</c:when>
                                        <c:when test="${payment.billStatus == 'ISSUED'}">badge-issued</c:when>
                                        <c:otherwise>badge-draft</c:otherwise>
                                    </c:choose>">
                                    ${payment.billStatus}
                                </span>
                            </span>
            </div>
            <div class="mt-3">
              <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${payment.reservationId}"
                 class="btn btn-sm btn-primary" target="_blank">
                <i class="fas fa-print me-1"></i>Print Bill
              </a>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <div class="info-card">
            <h5><i class="fas fa-file-invoice me-2"></i>Bill Information</h5>
            <div class="text-muted py-3 text-center">
              <i class="fas fa-file-times fa-2x mb-2 d-block" style="opacity:0.3;"></i>
              No bill generated yet for this payment.
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Associated Bill Details (from bill service) -->
    <c:if test="${not empty bill}">
      <div class="bill-card">
        <h5><i class="fas fa-receipt me-2"></i>Bill Breakdown</h5>
        <div class="row g-3">
          <div class="col-md-3">
            <small class="text-muted d-block">Bill Number</small>
            <strong>${bill.billNumber}</strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Issue Date</small>
            <strong>${bill.issueDate}</strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Due Date</small>
            <strong>${bill.dueDate}</strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Room Charges</small>
            <strong>Rs.<fmt:formatNumber value="${bill.roomCharges}" pattern="#,##0.00"/></strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Tax Amount</small>
            <strong>Rs.<fmt:formatNumber value="${bill.taxAmount}" pattern="#,##0.00"/></strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Discount</small>
            <strong>-Rs.<fmt:formatNumber value="${bill.discountAmount}" pattern="#,##0.00"/></strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Total Amount</small>
            <strong class="text-primary fs-5">Rs.<fmt:formatNumber value="${bill.totalAmount}" pattern="#,##0.00"/></strong>
          </div>
          <div class="col-md-3">
            <small class="text-muted d-block">Status</small>
            <span class="badge-status
                            <c:choose>
                                <c:when test="${bill.billStatus.name() == 'PAID'}">badge-completed</c:when>
                                <c:when test="${bill.billStatus.name() == 'ISSUED'}">badge-issued</c:when>
                                <c:when test="${bill.billStatus.name() == 'PARTIALLY_PAID'}">badge-pending</c:when>
                                <c:otherwise>badge-draft</c:otherwise>
                            </c:choose>">
                ${bill.billStatus}
            </span>
          </div>
        </div>
        <div class="mt-3 text-end">
          <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${payment.reservationId}"
             class="btn btn-primary" target="_blank">
            <i class="fas fa-print me-1"></i>Print Bill
          </a>
        </div>
      </div>
    </c:if>

    <!-- Action Buttons -->
    <div class="action-buttons">
      <a href="${pageContext.request.contextPath}<%= basePath %>/payments"
         class="btn btn-outline-secondary">
        <i class="fas fa-arrow-left me-1"></i>Back to List
      </a>

      <%--
          FIX: Use ${isAdmin} which now correctly reflects the pageContext-scoped variable.
          The refund button is shown only for admins when payment status is COMPLETED.
      --%>
      <c:if test="${payment.paymentStatus == 'COMPLETED'}">
        <a href="${pageContext.request.contextPath}<%= basePath %>/payments/refund?id=${payment.id}"
           class="btn btn-danger">
          <i class="fas fa-undo-alt me-1"></i>Process Refund
        </a>
      </c:if>

      <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?number=${payment.reservationNumber}"
         class="btn btn-outline-primary">
        <i class="fas fa-calendar-alt me-1"></i>View Reservation
      </a>

      <c:if test="${not empty payment.billNumber}">
        <%-- FIX: reservationId param --%>
        <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?reservationId=${payment.reservationId}"
           class="btn btn-outline-info" target="_blank">
          <i class="fas fa-print me-1"></i>Print Bill
        </a>
      </c:if>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
