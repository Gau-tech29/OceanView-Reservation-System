<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
<%@ page import="com.oceanview.dto.RoomDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
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
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; }
        .form-container { max-width: 920px; margin: 28px auto; padding: 0 16px 60px; }
        .card { border: none; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); margin-bottom: 22px; }
        .card-header {
            background: linear-gradient(135deg,#0d6efd,#0b5ed7); color: white;
            border-radius: 16px 16px 0 0 !important; padding: 16px 24px;
        }
        .card-header h4 { margin:0; font-weight:600; font-size:1.1rem; }
        .card-body { padding: 24px; }
        .form-label { font-weight:500; font-size:.88rem; color:#495057; }
        .form-control, .form-select {
            border-radius:8px; border:1.5px solid #dee2e6;
            font-size:.9rem; padding:9px 13px; transition:.2s;
        }
        .form-control:focus, .form-select:focus {
            border-color:#0d6efd; box-shadow:0 0 0 3px rgba(13,110,253,.12);
        }
        .required-star { color:#dc3545; }

        .guest-tabs { display:flex; border-radius:10px; overflow:hidden; border:2px solid #0d6efd; margin-bottom:20px; }
        .guest-tab {
            flex:1; padding:10px; text-align:center; cursor:pointer;
            font-weight:600; font-size:.88rem; transition:.2s;
            background:white; color:#0d6efd; user-select:none;
        }
        .guest-tab.active { background:#0d6efd; color:white; }
        .guest-tab:not(.active):hover { background:#e6f2ff; }

        .search-wrap { position:relative; }
        .search-results {
            position:absolute; top:100%; left:0; right:0; z-index:1050;
            background:white; border:1.5px solid #0d6efd; border-top:none;
            border-radius:0 0 10px 10px; max-height:260px; overflow-y:auto;
            box-shadow:0 8px 20px rgba(0,0,0,.14); display:none;
        }
        .sr-item { padding:11px 16px; cursor:pointer; transition:.15s; border-bottom:1px solid #f0f4f8; }
        .sr-item:hover { background:#e6f2ff; }
        .sr-item:last-child { border-bottom:none; }
        .sr-name { font-weight:600; font-size:.9rem; }
        .sr-info { font-size:.78rem; color:#6c757d; }

        .selected-guest {
            background:#f0f9ff; border:2px solid #0d6efd; border-radius:10px;
            padding:13px 16px; display:none; position:relative;
        }
        .selected-guest.show { display:block; }
        .selected-guest h6 { font-weight:700; color:#0d6efd; margin-bottom:3px; }
        .selected-guest p { margin:0; font-size:.84rem; color:#495057; }
        .sg-clear { position:absolute; top:10px; right:12px; cursor:pointer; color:#dc3545; font-size:1.1rem; }

        .room-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:12px; }
        .room-card {
            border:2px solid #dee2e6; border-radius:10px; padding:13px;
            cursor:pointer; transition:.2s;
        }
        .room-card:hover { border-color:#0d6efd; background:#f0f9ff; }
        .room-card.selected { border-color:#0d6efd; background:#e6f2ff; }
        .room-card .rn { font-weight:700; font-size:.95rem; }
        .room-card .rt { font-size:.75rem; text-transform:uppercase; color:#6c757d; }
        .room-card .rp { font-weight:700; color:#0d6efd; margin-top:5px; }

        .bill-box { background:#f8f9fa; border-radius:10px; padding:16px; border:1px solid #e9ecef; }
        .bill-row { display:flex; justify-content:space-between; padding:4px 0; font-size:.87rem; }
        .bill-row.total { font-weight:700; font-size:.98rem; border-top:2px solid #dee2e6; margin-top:8px; padding-top:10px; color:#0d6efd; }

        .btn-primary { background:linear-gradient(135deg,#0d6efd,#0b5ed7); border:none; border-radius:8px; padding:10px 28px; font-weight:600; }
        .btn-secondary { border-radius:8px; padding:10px 22px; }
        .err-box { background:#f8d7da; color:#721c24; border:none; border-radius:10px; }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    ReservationDTO reservation = (ReservationDTO) request.getAttribute("reservation");
    GuestDTO selectedGuest    = (GuestDTO) request.getAttribute("selectedGuest");
    boolean isEdit = (reservation != null && reservation.getId() != null);

    String roleBase   = user.isAdmin() ? "/admin/reservations" : "/staff/reservations";
    String formAction = request.getContextPath() + roleBase + (isEdit ? "/update" : "/save");
    String backUrl    = request.getContextPath() + roleBase;

    String errorMsg = (String) request.getAttribute("error");
    String today    = LocalDate.now().toString();

    // In edit mode, resolve the selected guest from the reservation's guestId
    // The servlet should set selectedGuest, but we also handle it here
    String preGuestId   = "";
    String preGuestName = "";
    String preGuestInfo = "";

    if (isEdit && reservation.getGuestId() != null) {
        preGuestId   = String.valueOf(reservation.getGuestId());
        preGuestName = reservation.getGuestName() != null ? reservation.getGuestName() : "Guest #" + reservation.getGuestId();
        String email = reservation.getGuestEmail() != null ? reservation.getGuestEmail() : "";
        String phone = reservation.getGuestPhone() != null ? " | " + reservation.getGuestPhone() : "";
        String gnum  = reservation.getGuestNumber() != null ? " | #" + reservation.getGuestNumber() : "";
        preGuestInfo = email + phone + gnum;
    } else if (selectedGuest != null) {
        preGuestId   = String.valueOf(selectedGuest.getId());
        preGuestName = selectedGuest.getFullName() != null ? selectedGuest.getFullName() : "";
        String email = selectedGuest.getEmail() != null ? selectedGuest.getEmail() : "";
        String phone = selectedGuest.getPhone() != null ? " | " + selectedGuest.getPhone() : "";
        String gnum  = selectedGuest.getGuestNumber() != null ? " | #" + selectedGuest.getGuestNumber() : "";
        preGuestInfo = email + phone + gnum;
    }

    boolean hasPreGuest = !preGuestId.isEmpty();
%>

<div class="form-container">

    <div class="mb-3">
        <a href="<%= backUrl %>" class="btn btn-outline-secondary btn-sm">
            <i class="fas fa-arrow-left me-1"></i>Back to Reservations
        </a>
    </div>

    <% if (errorMsg != null) { %>
    <div class="alert err-box alert-dismissible fade show mb-3">
        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <form id="resForm" method="POST" action="<%= formAction %>" novalidate>
        <% if (isEdit) { %>
        <input type="hidden" name="id" value="<%= reservation.getId() %>">
        <% } %>

        <%-- ══════════ GUEST ══════════ --%>
        <div class="card">
            <div class="card-header">
                <h4><i class="fas fa-user me-2"></i>Guest Information</h4>
            </div>
            <div class="card-body">
                <% if (!isEdit) { %>
                <%-- Mode toggle only shown for new reservations --%>
                <div class="guest-tabs" id="guestTabs">
                    <div class="guest-tab active" id="tab-existing" onclick="switchMode('existing')">
                        <i class="fas fa-search me-1"></i>Existing Guest
                    </div>
                    <div class="guest-tab" id="tab-new" onclick="switchMode('new')">
                        <i class="fas fa-user-plus me-1"></i>New Guest
                    </div>
                </div>
                <input type="hidden" name="guestMode" id="guestMode" value="existing">

                <%-- EXISTING GUEST panel --%>
                <div id="panelExisting">
                    <div class="search-wrap mb-3">
                        <label class="form-label">Search Guest <span class="required-star">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="fas fa-search text-primary"></i></span>
                            <input type="text" id="guestSearchInput" class="form-control"
                                   placeholder="Name, email, phone or guest number..." autocomplete="off">
                            <button type="button" class="btn btn-outline-primary"
                                    onclick="doSearch(document.getElementById('guestSearchInput').value)">Search</button>
                        </div>
                        <div class="search-results" id="searchResults"></div>
                    </div>
                    <input type="hidden" name="guestId" id="guestId" value="<%= hasPreGuest ? preGuestId : "" %>">
                    <div class="selected-guest <%= hasPreGuest ? "show" : "" %>" id="selectedGuest">
                        <span class="sg-clear" onclick="clearGuest()" title="Clear selection">
                            <i class="fas fa-times-circle"></i>
                        </span>
                        <h6 id="sgName"><%= hasPreGuest ? preGuestName : "" %></h6>
                        <p id="sgInfo"><%= hasPreGuest ? preGuestInfo : "" %></p>
                    </div>
                    <small class="text-muted d-block mt-2">
                        <i class="fas fa-info-circle me-1"></i>Type at least 2 characters to search. Click a result to select.
                    </small>
                </div>

                <%-- NEW GUEST panel --%>
                <div id="panelNew" style="display:none;">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">First Name <span class="required-star">*</span></label>
                            <input type="text" name="firstName" id="newFirstName" class="form-control" placeholder="First name">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Last Name <span class="required-star">*</span></label>
                            <input type="text" name="lastName" id="newLastName" class="form-control" placeholder="Last name">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="guestEmail" class="form-control" placeholder="guest@email.com">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Phone</label>
                            <input type="text" name="guestPhone" class="form-control" placeholder="+1 234 567 8900">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">ID Type</label>
                            <select name="idCardType" class="form-select">
                                <option value="">-- Select --</option>
                                <option value="PASSPORT">Passport</option>
                                <option value="NATIONAL_ID">National ID</option>
                                <option value="DRIVERS_LICENSE">Driver's License</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">ID Number</label>
                            <input type="text" name="idCardNumber" class="form-control" placeholder="ID card number">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <input type="text" name="address" class="form-control" placeholder="Street address">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">City</label>
                            <input type="text" name="city" class="form-control" placeholder="City">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Country</label>
                            <input type="text" name="country" class="form-control" placeholder="Country">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Postal Code</label>
                            <input type="text" name="postalCode" class="form-control" placeholder="Postal code">
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">
                        <i class="fas fa-info-circle me-1"></i>A guest profile will be created automatically on submission.
                    </small>
                </div>

                <% } else { /* EDIT MODE – guest read-only */ %>
                <input type="hidden" name="guestMode" value="existing">
                <input type="hidden" name="guestId" value="<%= preGuestId %>">
                <div class="selected-guest show">
                    <h6><i class="fas fa-user me-2"></i><%= preGuestName %></h6>
                    <p><%= preGuestInfo %></p>
                </div>
                <% } %>
            </div>
        </div>

        <%-- ══════════ ROOM ══════════ --%>
        <div class="card">
            <div class="card-header">
                <h4><i class="fas fa-door-open me-2"></i>Room Selection <span class="required-star">*</span></h4>
            </div>
            <div class="card-body">
                <input type="hidden" name="roomId" id="roomId"
                       value="<%= isEdit && reservation.getRoomId() != null ? reservation.getRoomId() : "" %>">

                <%
                    @SuppressWarnings("unchecked")
                    List<RoomDTO> roomList = (List<RoomDTO>) request.getAttribute("rooms");
                    if (roomList != null && !roomList.isEmpty()) {
                %>
                <div class="room-grid">
                    <% for (RoomDTO room : roomList) {
                        boolean sel = isEdit && reservation.getRoomId() != null
                                && reservation.getRoomId().equals(room.getId());
                        double basePrice = room.getBasePrice() != null ? room.getBasePrice().doubleValue() : 0;
                    %>
                    <div class="room-card <%= sel ? "selected" : "" %>"
                         id="rc-<%= room.getId() %>"
                         onclick="pickRoom(<%= room.getId() %>,'<%= room.getRoomNumber().replace("'","\'") %>',
                                 '<%= room.getRoomType().replace("'","\'") %>',<%= basePrice %>)">
                        <div class="rn">Room <%= room.getRoomNumber() %></div>
                        <div class="rt">
                            <%= room.getRoomType() %>
                            <% if (room.getFloorNumber() != null) { %>&nbsp;· Floor <%= room.getFloorNumber() %><% } %>
                        </div>
                        <div class="rp">$<%= String.format("%.2f", basePrice) %>/night</div>
                        <% if (room.getRoomView() != null && !room.getRoomView().isEmpty()) { %>
                        <small class="text-muted"><i class="fas fa-eye me-1"></i><%= room.getRoomView().replace("_"," ") %></small>
                        <% } %>
                        <% if (room.getCapacity() != null && room.getCapacity() > 0) { %>
                        <small class="text-muted d-block"><i class="fas fa-users me-1"></i>Cap. <%= room.getCapacity() %></small>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle me-2"></i>No rooms available.
                </div>
                <% } %>

                <div id="roomInfo" class="mt-3" style="display:<%= isEdit ? "block" : "none" %>">
                    <small class="text-primary fw-semibold">
                        <i class="fas fa-check-circle me-1"></i>
                        Selected: Room <span id="ri-num"><%= isEdit && reservation.getRoomNumber() != null ? reservation.getRoomNumber() : "" %></span>
                        — <span id="ri-type"><%= isEdit && reservation.getRoomType() != null ? reservation.getRoomType() : "" %></span>
                        @ $<span id="ri-price"><%= isEdit && reservation.getRoomPrice() != null ? reservation.getRoomPrice() : "0.00" %></span>/night
                    </small>
                </div>
            </div>
        </div>

        <%-- ══════════ STAY DETAILS ══════════ --%>
        <div class="card">
            <div class="card-header">
                <h4><i class="fas fa-calendar-alt me-2"></i>Stay Details</h4>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Check-in Date <span class="required-star">*</span></label>
                        <input type="date" name="checkInDate" id="checkInDate" class="form-control" required
                               min="<%= today %>"
                               value="<%= isEdit && reservation.getCheckInDate() != null ? reservation.getCheckInDate() : "" %>"
                               onchange="recalc()">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Check-out Date <span class="required-star">*</span></label>
                        <input type="date" name="checkOutDate" id="checkOutDate" class="form-control" required
                               min="<%= today %>"
                               value="<%= isEdit && reservation.getCheckOutDate() != null ? reservation.getCheckOutDate() : "" %>"
                               onchange="recalc()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Adults <span class="required-star">*</span></label>
                        <input type="number" name="adults" class="form-control" min="1" max="10"
                               value="<%= isEdit && reservation.getAdults() != null ? reservation.getAdults() : 1 %>" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Children</label>
                        <input type="number" name="children" class="form-control" min="0" max="10"
                               value="<%= isEdit && reservation.getChildren() != null ? reservation.getChildren() : 0 %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Discount ($)</label>
                        <input type="number" name="discountAmount" id="discountAmount"
                               class="form-control" min="0" step="0.01"
                               value="<%= isEdit && reservation.getDiscountAmount() != null ? reservation.getDiscountAmount() : "0" %>"
                               onchange="recalc()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Source</label>
                        <select name="source" class="form-select">
                            <option value="WALK_IN" <%= isEdit && "WALK_IN".equals(reservation.getSource()) ? "selected" : "" %>>Walk-in</option>
                            <option value="PHONE"   <%= isEdit && "PHONE".equals(reservation.getSource())   ? "selected" : "" %>>Phone</option>
                            <option value="EMAIL"   <%= isEdit && "EMAIL".equals(reservation.getSource())   ? "selected" : "" %>>Email</option>
                            <option value="WEBSITE" <%= isEdit && "WEBSITE".equals(reservation.getSource()) ? "selected" : "" %>>Website</option>
                            <option value="AGENT"   <%= isEdit && "AGENT".equals(reservation.getSource())   ? "selected" : "" %>>Agent</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Special Requests</label>
                        <textarea name="specialRequests" class="form-control" rows="3"
                                  placeholder="Dietary needs, room preferences..."><%= isEdit && reservation.getSpecialRequests() != null ? reservation.getSpecialRequests() : "" %></textarea>
                    </div>
                </div>

                <%-- Bill Preview --%>
                <div class="bill-box mt-4" id="billBox">
                    <div style="font-size:.8rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#0d6efd;margin-bottom:12px;">
                        Bill Preview
                    </div>
                    <div class="bill-row"><span>Room</span><span id="b-room">—</span></div>
                    <div class="bill-row"><span>Nights</span><span id="b-nights">—</span></div>
                    <div class="bill-row"><span>Room Charges</span><span id="b-charges">—</span></div>
                    <div class="bill-row"><span>Tax (12%)</span><span id="b-tax">—</span></div>
                    <div class="bill-row"><span>Discount</span><span id="b-discount">—</span></div>
                    <div class="bill-row total"><span>Total</span><span id="b-total">—</span></div>
                </div>
            </div>
        </div>

        <div class="d-flex gap-3 justify-content-end">
            <a href="<%= backUrl %>" class="btn btn-secondary"><i class="fas fa-times me-1"></i>Cancel</a>
            <button type="submit" class="btn btn-primary" onclick="return validateForm()">
                <i class="fas fa-save me-1"></i>
                <%= isEdit ? "Update Reservation" : "Create Reservation" %>
            </button>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ─── 1. Guest mode toggle ──────────────────────────────────────────────
    function switchMode(mode) {
        document.getElementById('guestMode').value = mode;
        document.getElementById('tab-existing').classList.toggle('active', mode === 'existing');
        document.getElementById('tab-new').classList.toggle('active', mode === 'new');
        document.getElementById('panelExisting').style.display = mode === 'existing' ? 'block' : 'none';
        document.getElementById('panelNew').style.display      = mode === 'new'      ? 'block' : 'none';
    }

    // ─── 2. Guest search ──────────────────────────────────────────────────
    var _searchTimer;
    var _ctxPath = '<%= request.getContextPath() %>';

    var inp = document.getElementById('guestSearchInput');
    if (inp) {
        inp.addEventListener('input', function() {
            clearTimeout(_searchTimer);
            var q = this.value.trim();
            if (q.length >= 2) _searchTimer = setTimeout(function(){ doSearch(q); }, 350);
            else hideResults();
        });
    }

    function doSearch(q) {
        if (!q || q.trim().length < 1) return;
        fetch(_ctxPath + '/api/guests/search?keyword=' + encodeURIComponent(q.trim()))
            .then(function(r){ return r.json(); })
            .then(function(data){ renderResults(data); })
            .catch(function(){ showSearchError('Search failed. Please try again.'); });
    }

    function renderResults(guests) {
        var box = document.getElementById('searchResults');
        if (!guests || guests.length === 0) {
            box.innerHTML = '<div class="sr-item text-muted"><i class="fas fa-info-circle me-1"></i>No guests found. Switch to "New Guest" to create one.</div>';
        } else {
            box.innerHTML = guests.map(function(g) {
                var info = [];
                if (g.email) info.push(g.email);
                if (g.phone) info.push(g.phone);
                if (g.guestNumber) info.push('#' + g.guestNumber);
                return '<div class="sr-item" onclick="pickGuest(' + g.id + ',\'' +
                    escapeJS(g.fullName) + '\',\'' + escapeJS(g.email||'') + '\',\'' +
                    escapeJS(g.phone||'') + '\',\'' + escapeJS(g.guestNumber||'') + '\')">' +
                    '<div class="sr-name"><i class="fas fa-user me-1 text-primary"></i>' + escapeHtml(g.fullName) + '</div>' +
                    '<div class="sr-info">' + escapeHtml(info.join(' | ')) + '</div>' +
                    '</div>';
            }).join('');
        }
        box.style.display = 'block';
    }

    function escapeJS(s) {
        if (!s) return '';
        return s.replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/"/g,'\\"');
    }
    function escapeHtml(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    function showSearchError(msg) {
        var box = document.getElementById('searchResults');
        box.innerHTML = '<div class="sr-item text-danger"><i class="fas fa-exclamation-circle me-1"></i>' + msg + '</div>';
        box.style.display = 'block';
    }

    function pickGuest(id, name, email, phone, gnum) {
        document.getElementById('guestId').value = id;
        document.getElementById('sgName').textContent = name;
        var parts = [];
        if (email) parts.push(email);
        if (phone) parts.push(phone);
        if (gnum)  parts.push('#' + gnum);
        document.getElementById('sgInfo').textContent = parts.join(' | ');
        document.getElementById('selectedGuest').classList.add('show');
        document.getElementById('guestSearchInput').value = '';
        hideResults();
    }

    function clearGuest() {
        document.getElementById('guestId').value = '';
        document.getElementById('selectedGuest').classList.remove('show');
        document.getElementById('guestSearchInput').value = '';
    }

    function hideResults() {
        var box = document.getElementById('searchResults');
        if (box) box.style.display = 'none';
    }

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.search-wrap')) hideResults();
    });

    // ─── 3. Room selection ────────────────────────────────────────────────
    var _roomPrice = 0;
    <% if (isEdit && reservation.getRoomPrice() != null) { %>
    _roomPrice = parseFloat('<%= reservation.getRoomPrice() %>');
    setTimeout(recalc, 100);
    <% } %>

    function pickRoom(id, num, type, price) {
        document.getElementById('roomId').value = id;
        _roomPrice = price;
        document.querySelectorAll('.room-card').forEach(function(c){ c.classList.remove('selected'); });
        var card = document.getElementById('rc-' + id);
        if (card) card.classList.add('selected');
        document.getElementById('ri-num').textContent   = num;
        document.getElementById('ri-type').textContent  = type;
        document.getElementById('ri-price').textContent = price.toFixed(2);
        document.getElementById('roomInfo').style.display = 'block';
        recalc();
    }

    // ─── 4. Bill calculation ──────────────────────────────────────────────
    function recalc() {
        var ci   = document.getElementById('checkInDate').value;
        var co   = document.getElementById('checkOutDate').value;
        var disc = parseFloat(document.getElementById('discountAmount').value) || 0;
        if (!ci || !co || _roomPrice <= 0) return;
        var nights  = Math.round((new Date(co) - new Date(ci)) / 86400000);
        if (nights <= 0) return;
        var charges = _roomPrice * nights;
        var taxable = charges - disc;
        var tax     = taxable * 0.12;
        var total   = taxable + tax;
        document.getElementById('b-room').textContent    = '$' + _roomPrice.toFixed(2) + '/night';
        document.getElementById('b-nights').textContent  = nights + ' night(s)';
        document.getElementById('b-charges').textContent = '$' + charges.toFixed(2);
        document.getElementById('b-tax').textContent     = '$' + tax.toFixed(2);
        document.getElementById('b-discount').textContent= '-$' + disc.toFixed(2);
        document.getElementById('b-total').textContent   = '$' + total.toFixed(2);
    }

    // ─── 5. Form validation ───────────────────────────────────────────────
    function validateForm() {
        var modeEl = document.getElementById('guestMode');
        var mode   = modeEl ? modeEl.value : 'existing';

        if (mode === 'existing') {
            var gid = document.getElementById('guestId');
            if (!gid || !gid.value) {
                alert('Please search for and select an existing guest, or switch to "New Guest".');
                return false;
            }
        } else {
            var fn = document.getElementById('newFirstName').value.trim();
            var ln = document.getElementById('newLastName').value.trim();
            if (!fn || !ln) { alert('First name and last name are required for a new guest.'); return false; }
        }

        var rid = document.getElementById('roomId').value;
        if (!rid) { alert('Please select a room.'); return false; }

        var ci = document.getElementById('checkInDate').value;
        var co = document.getElementById('checkOutDate').value;
        if (!ci || !co) { alert('Check-in and check-out dates are required.'); return false; }
        if (new Date(co) <= new Date(ci)) { alert('Check-out date must be after check-in date.'); return false; }
        return true;
    }

    // ─── Date min constraints ─────────────────────────────────────────────
    var ciEl = document.getElementById('checkInDate');
    var coEl = document.getElementById('checkOutDate');
    if (ciEl) {
        ciEl.addEventListener('change', function() {
            if (coEl) {
                coEl.min = this.value;
                if (coEl.value && new Date(coEl.value) <= new Date(this.value)) coEl.value = '';
            }
            recalc();
        });
    }
    if (coEl) coEl.addEventListener('change', recalc);
</script>
</body>
</html>
