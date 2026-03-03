<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    boolean isAdmin = user.isAdmin();
    String basePath = isAdmin ? "/admin" : "/staff";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout & Payment - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#0d6efd; --primary-dark:#0b5ed7; --sidebar-width:280px; }
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Poppins',sans-serif;background:#f4f6f9;overflow-x:hidden;}
        .sidebar{
            position:fixed;top:0;left:0;height:100vh;width:var(--sidebar-width);
            background:linear-gradient(180deg,#0b5ed7 0%,#0d6efd 100%);
            color:white;z-index:1000;overflow-y:auto;box-shadow:3px 0 15px rgba(0,0,0,.15);
        }
        .sidebar-brand{padding:25px 20px 20px;border-bottom:1px solid rgba(255,255,255,.2);margin-bottom:10px;}
        .sidebar-brand h3{font-size:1.4rem;font-weight:700;margin:0;}
        .sidebar-brand p{font-size:.8rem;opacity:.8;margin:4px 0 0;}
        .sidebar-menu{list-style:none;padding:5px 10px;margin:0;}
        .sidebar-menu li{margin-bottom:4px;}
        .sidebar-menu a{
            display:flex;align-items:center;padding:11px 15px;
            color:rgba(255,255,255,.85);text-decoration:none;
            border-radius:10px;transition:all .2s;
        }
        .sidebar-menu a:hover,.sidebar-menu a.active{background:rgba(255,255,255,.15);color:white;}
        .sidebar-menu a i{width:28px;font-size:1.05rem;}
        .sidebar-menu a span{font-size:.9rem;font-weight:500;}
        .main-content{margin-left:var(--sidebar-width);padding:22px 28px;}
        .top-nav{
            background:white;border-radius:15px;padding:14px 22px;
            margin-bottom:22px;box-shadow:0 2px 10px rgba(0,0,0,.06);
            display:flex;justify-content:space-between;align-items:center;
        }
        .page-title h2{font-size:1.35rem;font-weight:600;color:#212529;margin:0;}
        .user-avatar{
            width:40px;height:40px;background:linear-gradient(135deg,#0d6efd,#0b5ed7);
            border-radius:10px;display:flex;align-items:center;justify-content:center;
            color:white;font-weight:700;
        }
        .total-banner{
            background:linear-gradient(135deg,#0d6efd,#0a3d8f);color:white;
            border-radius:18px;padding:22px 30px;
            display:flex;justify-content:space-between;align-items:center;
            margin-bottom:24px;box-shadow:0 10px 30px rgba(13,110,253,.25);
        }
        .total-banner .amount{font-size:2.2rem;font-weight:700;}
        .total-banner .label{font-size:.9rem;opacity:.85;}
        .total-banner .meta{font-size:.82rem;opacity:.75;margin-top:4px;}
        .card-section{
            background:white;border-radius:14px;padding:24px;
            box-shadow:0 2px 10px rgba(0,0,0,.06);margin-bottom:20px;
        }
        .sec-title{
            font-size:1rem;font-weight:600;color:#212529;
            padding-bottom:10px;border-bottom:2px solid #f0f4f8;
            margin-bottom:16px;display:flex;align-items:center;gap:8px;
        }
        .sec-title i{color:var(--primary);}
        .info-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;}
        .info-item{background:#f8f9fa;border-radius:10px;padding:13px;}
        .info-item .lbl{font-size:.76rem;color:#6c757d;margin-bottom:3px;}
        .info-item .val{font-size:.92rem;font-weight:600;color:#212529;}
        .price-box{background:#f8f9fa;border-radius:12px;padding:18px;}
        .p-row{display:flex;justify-content:space-between;padding:7px 0;font-size:.88rem;border-bottom:1px solid #e9ecef;}
        .p-row:last-child{border:none;}
        .p-row.total{font-weight:700;font-size:1.1rem;color:var(--primary);border-top:2px solid #dee2e6;border-bottom:none;margin-top:8px;padding-top:12px;}
        .p-row.disc span:last-child{color:#198754;}
        .pay-card{
            border:2px solid #e9ecef;border-radius:12px;padding:14px 18px;
            cursor:pointer;transition:all .2s;display:flex;align-items:center;gap:14px;margin-bottom:10px;
        }
        .pay-card:hover{border-color:var(--primary);background:#f0f5ff;}
        .pay-card.selected{border-color:var(--primary);background:#e8f0fe;}
        .pay-card input[type="radio"]{display:none;}
        .pay-icon{
            width:44px;height:44px;border-radius:10px;
            display:flex;align-items:center;justify-content:center;
            font-size:1.25rem;color:white;flex-shrink:0;
        }
        .amount-confirm{
            background:#e8f5e9;border:1px solid #c8e6c9;border-radius:12px;
            padding:16px 20px;margin-bottom:20px;
            display:flex;justify-content:space-between;align-items:center;
        }
        .btn-checkout-submit{
            background:linear-gradient(135deg,#198754,#146c43);color:white;border:none;
            padding:13px 32px;border-radius:12px;font-size:.95rem;font-weight:600;
            cursor:pointer;transition:all .2s;
        }
        .btn-checkout-submit:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(25,135,84,.3);color:white;}
        .room-badge {
            background: #e9ecef;
            padding: 8px 12px;
            border-radius: 8px;
            margin-bottom: 8px;
        }
        .room-badge:last-child {
            margin-bottom: 0;
        }
        @media(max-width:768px){.sidebar{transform:translateX(-100%)}.main-content{margin-left:0}}
    </style>
</head>
<body>

<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/dashboard">
            <i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations" class="active">
            <i class="fas fa-calendar-alt"></i><span>Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/reservations/new">
            <i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/guests">
            <i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/rooms">
            <i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}<%= basePath %>/bills">
            <i class="fas fa-receipt"></i><span>Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout">
            <i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-cash-register me-2 text-warning"></i>Checkout &amp; Payment</h2>
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

    <c:choose>
        <c:when test="${empty reservation}">
            <div class="alert alert-danger">
                Reservation not found.
                <a href="${pageContext.request.contextPath}<%= basePath %>/reservations">Back to list</a>
            </div>
        </c:when>
        <c:otherwise>

            <!-- Amount Due Banner -->
            <div class="total-banner">
                <div>
                    <div class="label"><i class="fas fa-file-invoice-dollar me-2"></i>Total Amount Due for Checkout</div>
                    <div class="amount">$<fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0.00"/></div>
                    <div class="meta">
                        Reservation: <strong>${reservation.reservationNumber}</strong>
                        &nbsp;&bull;&nbsp; Guest: <strong>${reservation.guestName}</strong>
                        &nbsp;&bull;&nbsp; ${reservation.totalNights} Night(s)
                    </div>
                </div>
                <div style="font-size:3.5rem;opacity:.15;"><i class="fas fa-receipt"></i></div>
            </div>

            <div class="row g-4">

                <!-- ── Left: Summary ── -->
                <div class="col-lg-5">

                    <div class="card-section">
                        <div class="sec-title"><i class="fas fa-user"></i>Guest Information</div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="lbl">Full Name</div>
                                <div class="val">${reservation.guestName}</div>
                            </div>
                            <c:if test="${not empty reservation.guestPhone}">
                                <div class="info-item">
                                    <div class="lbl">Phone</div>
                                    <div class="val">${reservation.guestPhone}</div>
                                </div>
                            </c:if>
                            <c:if test="${not empty reservation.guestEmail}">
                                <div class="info-item" style="grid-column:1/-1">
                                    <div class="lbl">Email</div>
                                    <div class="val">${reservation.guestEmail}</div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <div class="card-section">
                        <div class="sec-title"><i class="fas fa-calendar-alt"></i>Stay Details</div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="lbl">Check-in</div>
                                <div class="val">${reservation.formattedCheckInDate}</div>
                            </div>
                            <div class="info-item">
                                <div class="lbl">Check-out</div>
                                <div class="val">${reservation.formattedCheckOutDate}</div>
                            </div>
                            <div class="info-item">
                                <div class="lbl">Total Nights</div>
                                <div class="val">${reservation.totalNights}</div>
                            </div>
                            <div class="info-item">
                                <div class="lbl">Room(s)</div>
                                <div class="val">
                                    <c:forEach items="${reservation.rooms}" var="room" varStatus="loop">
                                        <div class="room-badge">
                                            <strong>Room ${room.roomNumber}</strong>
                                            <c:if test="${not empty room.roomType}">
                                                <br><small class="text-muted">${room.roomType}
                                                <c:if test="${not empty room.roomView}"> - ${room.roomView.replace('_', ' ')}</c:if></small>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty reservation.rooms}">
                                        ${reservation.roomNumber} (${reservation.roomType})
                                    </c:if>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="lbl">Guests</div>
                                <div class="val">${reservation.adults} Adults, ${reservation.children} Children</div>
                            </div>
                        </div>
                    </div>

                    <div class="card-section">
                        <div class="sec-title"><i class="fas fa-dollar-sign"></i>Price Breakdown</div>
                        <div class="price-box">
                            <!-- Show each room's charges -->
                            <c:forEach var="room" items="${reservation.rooms}" varStatus="loop">
                                <div class="p-row">
                                    <span>
                                        <small class="text-muted">Room ${loop.index+1}:</small><br>
                                        ${room.roomNumber}
                                        <c:if test="${not empty room.roomType}">
                                            (${room.roomType})
                                        </c:if>
                                    </span>
                                    <span class="text-end">
                                        $<fmt:formatNumber value="${room.roomPrice}" pattern="#,##0.00"/> × ${reservation.totalNights} nights<br>
                                        <strong>$<fmt:formatNumber value="${room.roomPrice * reservation.totalNights}" pattern="#,##0.00"/></strong>
                                    </span>
                                </div>
                            </c:forEach>

                            <div class="p-row">
                                <span>Room Charges Total</span>
                                <span>$<fmt:formatNumber value="${reservation.subtotal}" pattern="#,##0.00"/></span>
                            </div>
                            <div class="p-row">
                                <span>Tax (12%)</span>
                                <span>$<fmt:formatNumber value="${reservation.taxAmount}" pattern="#,##0.00"/></span>
                            </div>
                            <c:if test="${not empty reservation.discountAmount and reservation.discountAmount > 0}">
                                <div class="p-row disc">
                                    <span>Discount</span>
                                    <span>-$<fmt:formatNumber value="${reservation.discountAmount}" pattern="#,##0.00"/></span>
                                </div>
                            </c:if>
                            <div class="p-row total">
                                <span>TOTAL DUE</span>
                                <span>$<fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0.00"/></span>
                            </div>
                        </div>
                    </div>

                </div><!-- end left col -->

                <!-- ── Right: Payment Form ── -->
                <div class="col-lg-7">
                    <div class="card-section">
                        <div class="sec-title"><i class="fas fa-credit-card"></i>Select Payment Method</div>

                        <div class="alert alert-info" style="border-radius:10px;font-size:.9rem;">
                            <i class="fas fa-info-circle me-2"></i>
                            Collect payment from the guest first, then confirm below.
                            The bill will be marked <strong>PAID</strong> and the reservation
                            status changed to <strong>CHECKED OUT</strong>.
                        </div>

                        <form method="POST"
                              action="${pageContext.request.contextPath}<%= basePath %>/reservations/process-checkout"
                              id="paymentForm" class="mt-3">
                            <input type="hidden" name="id" value="${reservation.id}">

                            <div class="mb-3">
                                <label class="form-label fw-semibold mb-2">Payment Method *</label>

                                <label class="pay-card" id="mc-CASH" onclick="selectPay(this,'CASH')">
                                    <input type="radio" name="paymentMethod" value="CASH" required>
                                    <div class="pay-icon" style="background:linear-gradient(135deg,#198754,#146c43);">
                                        <i class="fas fa-money-bill-wave"></i>
                                    </div>
                                    <div>
                                        <div style="font-weight:600;">Cash</div>
                                        <div style="font-size:.8rem;color:#6c757d;">Physical currency payment at front desk</div>
                                    </div>
                                </label>

                                <label class="pay-card" id="mc-CREDIT_CARD" onclick="selectPay(this,'CREDIT_CARD')">
                                    <input type="radio" name="paymentMethod" value="CREDIT_CARD" required>
                                    <div class="pay-icon" style="background:linear-gradient(135deg,#0d6efd,#0b5ed7);">
                                        <i class="fas fa-credit-card"></i>
                                    </div>
                                    <div>
                                        <div style="font-weight:600;">Credit Card</div>
                                        <div style="font-size:.8rem;color:#6c757d;">Visa, MasterCard, American Express</div>
                                    </div>
                                </label>

                                <label class="pay-card" id="mc-DEBIT_CARD" onclick="selectPay(this,'DEBIT_CARD')">
                                    <input type="radio" name="paymentMethod" value="DEBIT_CARD" required>
                                    <div class="pay-icon" style="background:linear-gradient(135deg,#6f42c1,#59359a);">
                                        <i class="fas fa-credit-card"></i>
                                    </div>
                                    <div>
                                        <div style="font-weight:600;">Debit Card</div>
                                        <div style="font-size:.8rem;color:#6c757d;">Direct bank debit card</div>
                                    </div>
                                </label>

                                <label class="pay-card" id="mc-BANK_TRANSFER" onclick="selectPay(this,'BANK_TRANSFER')">
                                    <input type="radio" name="paymentMethod" value="BANK_TRANSFER" required>
                                    <div class="pay-icon" style="background:linear-gradient(135deg,#fd7e14,#e96c02);">
                                        <i class="fas fa-university"></i>
                                    </div>
                                    <div>
                                        <div style="font-weight:600;">Bank Transfer</div>
                                        <div style="font-size:.8rem;color:#6c757d;">Wire transfer / online banking</div>
                                    </div>
                                </label>
                            </div>

                            <!-- Card last 4 (for card payments) -->
                            <div id="extra-card" style="display:none;" class="mb-3">
                                <label class="form-label fw-semibold">
                                    Last 4 Digits of Card
                                    <small class="text-muted fw-normal">(optional)</small>
                                </label>
                                <input type="text" name="cardLastFour" maxlength="4" pattern="[0-9]{4}"
                                       class="form-control" placeholder="e.g. 1234"
                                       style="border-radius:10px;max-width:200px;">
                            </div>

                            <!-- Transaction ID (for bank transfer) -->
                            <div id="extra-txn" style="display:none;" class="mb-3">
                                <label class="form-label fw-semibold">
                                    Transaction / Reference ID
                                    <small class="text-muted fw-normal">(optional)</small>
                                </label>
                                <input type="text" name="transactionId"
                                       class="form-control" placeholder="Enter reference number"
                                       style="border-radius:10px;">
                            </div>

                            <!-- Notes -->
                            <div class="mb-3">
                                <label class="form-label fw-semibold">
                                    Notes
                                    <small class="text-muted fw-normal">(optional)</small>
                                </label>
                                <textarea name="paymentNotes" class="form-control" rows="2"
                                          placeholder="Any remarks about this payment..."
                                          style="border-radius:10px;"></textarea>
                            </div>

                            <!-- Amount confirmation box -->
                            <div class="amount-confirm">
                                <div>
                                    <div style="font-size:.82rem;color:#1a6e38;font-weight:500;">
                                        Amount to Collect from Guest
                                    </div>
                                    <div style="font-size:.85rem;color:#555;">
                                        Reservation <strong>${reservation.reservationNumber}</strong>
                                        <c:if test="${reservation.numberOfRooms > 1}">
                                            <br><small>${reservation.numberOfRooms} rooms</small>
                                        </c:if>
                                    </div>
                                </div>
                                <div style="font-size:1.7rem;font-weight:700;color:#198754;">
                                    $<fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0.00"/>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-3">
                                <button type="submit" class="btn-checkout-submit"
                                        onclick="return confirmPayment()">
                                    <i class="fas fa-check-circle me-2"></i>Confirm Payment &amp; Check Out
                                </button>
                                <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/view?id=${reservation.id}"
                                   class="btn btn-outline-secondary"
                                   style="border-radius:12px;padding:11px 22px;font-weight:500;">
                                    <i class="fas fa-times me-2"></i>Cancel
                                </a>
                                <a href="${pageContext.request.contextPath}<%= basePath %>/reservations/print-bill?id=${reservation.id}"
                                   class="btn btn-info text-white"
                                   style="border-radius:12px;padding:11px 22px;font-weight:500;"
                                   target="_blank">
                                    <i class="fas fa-print me-2"></i>Preview Bill
                                </a>
                            </div>

                        </form>
                    </div>
                </div><!-- end right col -->

            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function selectPay(label, method) {
        document.querySelectorAll('.pay-card').forEach(c => c.classList.remove('selected'));
        label.classList.add('selected');
        document.getElementById('extra-card').style.display =
            (method === 'CREDIT_CARD' || method === 'DEBIT_CARD') ? 'block' : 'none';
        document.getElementById('extra-txn').style.display  =
            (method === 'BANK_TRANSFER') ? 'block' : 'none';
    }
    function confirmPayment() {
        const sel = document.querySelector('input[name="paymentMethod"]:checked');
        if (!sel) { alert('Please select a payment method to continue.'); return false; }
        const method = sel.value.replace(/_/g, ' ');
        const amt    = '${reservation.totalAmount}';
        return confirm(
            'Confirm payment of $' + parseFloat(amt).toFixed(2) + ' via ' + method + '?\n\n'
            + 'This will:\n'
            + '\u2022 Mark the bill as PAID\n'
            + '\u2022 Set reservation status to CHECKED OUT\n\n'
            + 'Proceed?'
        );
    }
</script>
</body>
</html>