<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bill - ${reservation.reservationNumber} - Ocean View Hotel</title>

  <!-- Bootstrap 5 CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Font Awesome 6 -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <style>
    body {
      font-family: 'Poppins', sans-serif;
      background: #f8f9fa;
      padding: 30px;
    }

    .bill-container {
      max-width: 800px;
      margin: 0 auto;
      background: white;
      border-radius: 15px;
      padding: 40px;
      box-shadow: 0 5px 20px rgba(0,0,0,0.1);
    }

    .bill-header {
      text-align: center;
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 2px dashed #dee2e6;
    }

    .hotel-name {
      font-size: 2rem;
      font-weight: 700;
      color: #0d6efd;
      margin-bottom: 5px;
    }

    .hotel-address {
      color: #6c757d;
      font-size: 0.9rem;
    }

    .bill-title {
      font-size: 1.5rem;
      font-weight: 600;
      margin: 20px 0;
      color: #212529;
    }

    .bill-info {
      background: #f8f9fa;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 30px;
    }

    .info-row {
      display: flex;
      margin-bottom: 10px;
    }

    .info-label {
      width: 150px;
      font-weight: 600;
      color: #495057;
    }

    .info-value {
      flex: 1;
      color: #212529;
    }

    .guest-details {
      margin-bottom: 30px;
    }

    .guest-details h5 {
      font-size: 1.1rem;
      font-weight: 600;
      margin-bottom: 15px;
      color: #0d6efd;
    }

    .table {
      margin-bottom: 30px;
    }

    .table th {
      background: #f8f9fa;
      font-weight: 600;
    }

    .total-row {
      font-size: 1.2rem;
      font-weight: 700;
    }

    .total-amount {
      color: #0d6efd;
      font-size: 1.5rem;
    }

    .bill-footer {
      margin-top: 30px;
      padding-top: 20px;
      border-top: 2px dashed #dee2e6;
      text-align: center;
      color: #6c757d;
      font-size: 0.9rem;
    }

    .print-button {
      text-align: center;
      margin-top: 30px;
    }

    @media print {
      body {
        background: white;
        padding: 0;
      }
      .bill-container {
        box-shadow: none;
        padding: 20px;
      }
      .print-button {
        display: none;
      }
      .no-print {
        display: none;
      }
    }
  </style>
</head>
<body>
<div class="bill-container">
  <!-- Header -->
  <div class="bill-header">
    <div class="hotel-name">OCEAN VIEW HOTEL</div>
    <div class="hotel-address">
      123 Beach Road, Colombo 03, Sri Lanka<br>
      Tel: +94 11 234 5678 | Email: info@oceanview.lk
    </div>
    <div class="bill-title">INVOICE / BILL</div>
  </div>

  <!-- Bill Information -->
  <div class="bill-info">
    <div class="row">
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Bill No:</span>
          <span class="info-value">${reservation.reservationNumber}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Date:</span>
          <span class="info-value"><fmt:formatDate value="${reservation.createdAt}" pattern="dd MMMM yyyy"/></span>
        </div>
      </div>
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Status:</span>
          <span class="info-value">
                            <c:choose>
                              <c:when test="${reservation.paymentStatus == 'PAID'}">
                                <span class="badge bg-success">Paid</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge bg-warning">${reservation.paymentStatus}</span>
                              </c:otherwise>
                            </c:choose>
                        </span>
        </div>
      </div>
    </div>
  </div>

  <!-- Guest Details -->
  <div class="guest-details">
    <h5>Guest Information</h5>
    <div class="row">
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Name:</span>
          <span class="info-value">${reservation.guestName}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Email:</span>
          <span class="info-value">${reservation.guestEmail}</span>
        </div>
      </div>
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Phone:</span>
          <span class="info-value">${reservation.guestPhone}</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Stay Details -->
  <div class="guest-details">
    <h5>Stay Details</h5>
    <div class="row">
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Check-in:</span>
          <span class="info-value"><fmt:formatDate value="${reservation.checkInDate}" pattern="dd MMMM yyyy"/></span>
        </div>
        <div class="info-row">
          <span class="info-label">Check-out:</span>
          <span class="info-value"><fmt:formatDate value="${reservation.checkOutDate}" pattern="dd MMMM yyyy"/></span>
        </div>
      </div>
      <div class="col-md-6">
        <div class="info-row">
          <span class="info-label">Room:</span>
          <span class="info-value">${reservation.roomNumber} (${reservation.roomType})</span>
        </div>
        <div class="info-row">
          <span class="info-label">Guests:</span>
          <span class="info-value">${reservation.adults} Adults, ${reservation.children} Children</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Charges Table -->
  <table class="table table-bordered">
    <thead>
    <tr>
      <th>Description</th>
      <th class="text-end">Rate (per night)</th>
      <th class="text-end">Nights</th>
      <th class="text-end">Amount</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td>Room Charges - ${reservation.roomType}</td>
      <td class="text-end">$${reservation.roomPrice}</td>
      <td class="text-end">${reservation.totalNights}</td>
      <td class="text-end">$${reservation.subtotal}</td>
    </tr>
    <tr>
      <td colspan="3" class="text-end">Subtotal</td>
      <td class="text-end">$${reservation.subtotal}</td>
    </tr>
    <tr>
      <td colspan="3" class="text-end">Tax (12%)</td>
      <td class="text-end">$${reservation.taxAmount}</td>
    </tr>
    <c:if test="${reservation.discountAmount > 0}">
      <tr>
        <td colspan="3" class="text-end">Discount</td>
        <td class="text-end text-success">-$${reservation.discountAmount}</td>
      </tr>
    </c:if>
    <tr class="total-row">
      <td colspan="3" class="text-end">TOTAL AMOUNT</td>
      <td class="text-end total-amount">$${reservation.totalAmount}</td>
    </tr>
    </tbody>
  </table>

  <!-- Payment Status -->
  <div class="alert ${reservation.paymentStatus == 'PAID' ? 'alert-success' : 'alert-warning'}">
    <strong>Payment Status:</strong> ${reservation.paymentStatus}
    <c:if test="${reservation.paymentStatus != 'PAID'}">
      <br><small>Please settle the payment at the reception.</small>
    </c:if>
  </div>

  <!-- Special Requests -->
  <c:if test="${not empty reservation.specialRequests}">
    <div class="mt-3 p-3 bg-light rounded">
      <strong>Special Requests:</strong><br>
        ${reservation.specialRequests}
    </div>
  </c:if>

  <!-- Footer -->
  <div class="bill-footer">
    <p>Thank you for choosing Ocean View Hotel!</p>
    <p>This is a computer generated invoice - no signature required.</p>
  </div>

  <!-- Print Button -->
  <div class="print-button no-print">
    <button onclick="window.print()" class="btn btn-primary">
      <i class="fas fa-print me-2"></i>Print Bill
    </button>
    <a href="javascript:window.close()" class="btn btn-secondary ms-2">
      <i class="fas fa-times me-2"></i>Close
    </a>
  </div>
</div>

<script>
  // Auto print when page loads (optional)
  // window.onload = function() { window.print(); }
</script>
</body>
</html>