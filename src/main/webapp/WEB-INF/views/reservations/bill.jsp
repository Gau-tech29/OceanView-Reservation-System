<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.ReservationRoomDTO" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill - ${reservation.reservationNumber} - Ocean View Hotel</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: #f8f9fa;
            padding: 30px;
        }
        .bill-container {
            max-width: 900px;
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
        .hotel-address { color: #6c757d; font-size: 0.9rem; }
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
        .info-row { display: flex; margin-bottom: 10px; }
        .info-label { width: 150px; font-weight: 600; color: #495057; }
        .info-value { flex: 1; color: #212529; }
        .guest-details { margin-bottom: 30px; }
        .guest-details h5 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: #0d6efd;
        }
        .table { margin-bottom: 30px; }
        .table th { background: #f8f9fa; font-weight: 600; }
        .total-row { font-size: 1.2rem; font-weight: 700; }
        .total-amount { color: #0d6efd; font-size: 1.5rem; }
        .bill-footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px dashed #dee2e6;
            text-align: center;
            color: #6c757d;
            font-size: 0.9rem;
        }
        .print-button { text-align: center; margin-top: 30px; }
        .room-detail-item {
            border-bottom: 1px solid #e9ecef;
            padding: 8px 0;
        }
        .room-detail-item:last-child {
            border-bottom: none;
        }

        @media print {
            body { background: white; padding: 0; }
            .bill-container { box-shadow: none; padding: 20px; }
            .print-button, .no-print { display: none !important; }
        }
    </style>
</head>
<body>
<div class="bill-container">

    <!-- ── Header ── -->
    <div class="bill-header">
        <div class="hotel-name"><i class="fas fa-hotel me-2"></i>OCEAN VIEW HOTEL</div>
        <div class="hotel-address">
            123 Beach Road, Colombo 03, Sri Lanka<br>
            Tel: +94 11 234 5678 | Email: info@oceanview.lk
        </div>
        <div class="bill-title">INVOICE / BILL</div>
    </div>

    <!-- ── Bill Information ── -->
    <div class="bill-info">
        <div class="row">
            <div class="col-md-6">
                <div class="info-row">
                    <span class="info-label">Bill No:</span>
                    <span class="info-value"><strong>${reservation.reservationNumber}</strong></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Date:</span>
                    <span class="info-value">${reservation.formattedCreatedAtLong}</span>
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
                    <span class="badge bg-warning text-dark">${reservation.paymentStatus}</span>
                </c:otherwise>
            </c:choose>
          </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Res. Status:</span>
                    <span class="info-value">
            <c:choose>
                <c:when test="${reservation.reservationStatus == 'CONFIRMED'}">
                    <span class="badge bg-success">Confirmed</span>
                </c:when>
                <c:when test="${reservation.reservationStatus == 'CHECKED_IN'}">
                    <span class="badge bg-primary">Checked In</span>
                </c:when>
                <c:when test="${reservation.reservationStatus == 'CHECKED_OUT'}">
                    <span class="badge bg-secondary">Checked Out</span>
                </c:when>
                <c:when test="${reservation.reservationStatus == 'CANCELLED'}">
                    <span class="badge bg-danger">Cancelled</span>
                </c:when>
                <c:otherwise>
                    <span class="badge bg-warning text-dark">Pending</span>
                </c:otherwise>
            </c:choose>
          </span>
                </div>
            </div>
        </div>
    </div>

    <!-- ── Guest Details ── -->
    <div class="guest-details">
        <h5><i class="fas fa-user me-2"></i>Guest Information</h5>
        <div class="row">
            <div class="col-md-6">
                <div class="info-row">
                    <span class="info-label">Name:</span>
                    <span class="info-value">${reservation.guestName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${not empty reservation.guestEmail ? reservation.guestEmail : '—'}</span>
                </div>
            </div>
            <div class="col-md-6">
                <div class="info-row">
                    <span class="info-label">Phone:</span>
                    <span class="info-value">${not empty reservation.guestPhone ? reservation.guestPhone : '—'}</span>
                </div>
                <c:if test="${not empty reservation.guestNumber}">
                    <div class="info-row">
                        <span class="info-label">Guest #:</span>
                        <span class="info-value">${reservation.guestNumber}</span>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- ── Stay Details ── -->
    <div class="guest-details">
        <h5><i class="fas fa-calendar-alt me-2"></i>Stay Details</h5>
        <div class="row">
            <div class="col-md-6">
                <div class="info-row">
                    <span class="info-label">Check-in:</span>
                    <span class="info-value">${reservation.formattedCheckInDate}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Check-out:</span>
                    <span class="info-value">${reservation.formattedCheckOutDate}</span>
                </div>
            </div>
            <div class="col-md-6">
                <div class="info-row">
                    <span class="info-label">Nights:</span>
                    <span class="info-value">${reservation.totalNights} night(s)</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Guests:</span>
                    <span class="info-value">${reservation.adults} Adults, ${reservation.children} Children</span>
                </div>
            </div>
        </div>

        <!-- Rooms List -->
        <div class="mt-3">
            <div class="info-row">
                <span class="info-label">Room(s):</span>
                <span class="info-value">
          <c:forEach items="${reservation.rooms}" var="room" varStatus="loop">
            <div class="room-detail-item">
              <strong>Room ${room.roomNumber}</strong>
              <c:if test="${not empty room.roomType}">
                  (${room.roomType}<c:if test="${not empty room.roomView}"> - ${room.roomView.replace('_', ' ')}</c:if>)
              </c:if>
              <c:if test="${not empty room.capacity}">
                  <span class="text-muted"> · Capacity: ${room.capacity}</span>
              </c:if>
            </div>
          </c:forEach>
          <c:if test="${empty reservation.rooms}">
              ${reservation.roomNumber} (${reservation.roomType})
          </c:if>
        </span>
            </div>
        </div>
    </div>

    <!-- ── Charges Table ── -->
    <table class="table table-bordered">
        <thead class="table-light">
        <tr>
            <th>Description</th>
            <th class="text-end">Rate (per night)</th>
            <th class="text-end">Nights</th>
            <th class="text-end">Amount</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${reservation.rooms}" var="room" varStatus="loop">
            <tr>
                <td>
                    Room ${room.roomNumber}
                    <c:if test="${not empty room.roomType}">
                        (${room.roomType}<c:if test="${not empty room.roomView}"> - ${room.roomView.replace('_', ' ')}</c:if>)
                    </c:if>
                </td>
                <td class="text-end">Rs.<fmt:formatNumber value="${room.roomPrice}" pattern="#,##0.00"/></td>
                <td class="text-end">${reservation.totalNights}</td>
                <td class="text-end">Rs.<fmt:formatNumber value="${room.roomPrice * reservation.totalNights}" pattern="#,##0.00"/></td>
            </tr>
        </c:forEach>

        <!-- If no rooms in list, show single room (fallback) -->
        <c:if test="${empty reservation.rooms}">
            <tr>
                <td>Room Charges — ${reservation.roomType} (Room ${reservation.roomNumber})</td>
                <td class="text-end">Rs.<fmt:formatNumber value="${reservation.roomPrice}" pattern="#,##0.00"/></td>
                <td class="text-end">${reservation.totalNights}</td>
                <td class="text-end">Rs.<fmt:formatNumber value="${reservation.subtotal}" pattern="#,##0.00"/></td>
            </tr>
        </c:if>

        <tr>
            <td colspan="3" class="text-end fw-semibold">Subtotal</td>
            <td class="text-end">Rs.<fmt:formatNumber value="${reservation.subtotal}" pattern="#,##0.00"/></td>
        </tr>
        <tr>
            <td colspan="3" class="text-end fw-semibold">Tax (12%)</td>
            <td class="text-end">Rs.<fmt:formatNumber value="${reservation.taxAmount}" pattern="#,##0.00"/></td>
        </tr>
        <c:if test="${reservation.discountAmount != null && reservation.discountAmount > 0}">
            <tr>
                <td colspan="3" class="text-end fw-semibold">Discount</td>
                <td class="text-end text-success">-Rs.<fmt:formatNumber value="${reservation.discountAmount}" pattern="#,##0.00"/></td>
            </tr>
        </c:if>
        <tr class="total-row table-light">
            <td colspan="3" class="text-end">TOTAL AMOUNT</td>
            <td class="text-end total-amount">Rs.<fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0.00"/></td>
        </tr>
        </tbody>
    </table>

    <!-- ── Payment Status Alert ── -->
    <div class="alert ${reservation.paymentStatus == 'PAID' ? 'alert-success' : 'alert-warning'}">
        <strong><i class="fas fa-info-circle me-1"></i>Payment Status:</strong> ${reservation.paymentStatus}
        <c:if test="${reservation.paymentStatus != 'PAID'}">
            <br><small>Please settle the balance at the reception desk.</small>
        </c:if>
    </div>

    <!-- ── Special Requests ── -->
    <c:if test="${not empty reservation.specialRequests}">
        <div class="mt-3 p-3 bg-light rounded">
            <strong><i class="fas fa-comment me-1"></i>Special Requests:</strong><br>
                ${reservation.specialRequests}
        </div>
    </c:if>

    <!-- ── Footer ── -->
    <div class="bill-footer">
        <p><strong>Thank you for choosing Ocean View Hotel!</strong></p>
        <p>This is a computer-generated invoice — no signature required.</p>
    </div>

    <!-- ── Print Button ── -->
    <div class="print-button no-print">
        <button onclick="window.print()" class="btn btn-primary">
            <i class="fas fa-print me-2"></i>Print Bill
        </button>
        <button onclick="closeBillTab()" class="btn btn-secondary ms-2">
            <i class="fas fa-times me-2"></i>Close
        </button>
    </div>
</div>

<script>
    function closeBillTab() {
        // window.close() only works when tab was opened via window.open().
        // When opened via <a target="_blank">, browsers block it.
        // So we try close(), then fall back to history.back() after a short delay.
        var closed = false;
        try {
            window.close();
            // Give the browser 400ms to close; if still open, go back instead
            setTimeout(function () {
                if (!document.hidden) {
                    // Tab is still open — navigate back instead
                    if (window.history.length > 1) {
                        window.history.back();
                    } else {
                        // Nowhere to go back to — just blank the tab
                        window.location.href = "about:blank";
                    }
                }
            }, 400);
        } catch (e) {
            window.history.back();
        }
    }

    window.onload = function () {
        // Uncomment to auto-print on open:
        // window.print();
    };
</script>
</body>
</html>
