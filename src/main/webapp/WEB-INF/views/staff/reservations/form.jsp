<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
<%@ page import="com.oceanview.dto.RoomDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }

  ReservationDTO reservation = (ReservationDTO) request.getAttribute("reservation");
  GuestDTO selectedGuest = (GuestDTO) request.getAttribute("selectedGuest");
  boolean isEdit = (reservation != null && reservation.getId() != null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= isEdit ? "Edit" : "New" %> Reservation</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <style>
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; padding: 20px; }
    .form-container { max-width: 900px; margin: 0 auto; }
    .card { border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .card-header {
      background: linear-gradient(135deg, #0d6efd, #0b5ed7);
      color: white; border-radius: 15px 15px 0 0 !important;
      padding: 15px 20px;
    }
    .guest-tabs {
      display: flex; border: 2px solid #0d6efd; border-radius: 10px; overflow: hidden;
      margin-bottom: 20px;
    }
    .guest-tab {
      flex: 1; padding: 10px; text-align: center; cursor: pointer;
      background: white; color: #0d6efd; font-weight: 500;
    }
    .guest-tab.active { background: #0d6efd; color: white; }
    .search-results {
      position: absolute; z-index: 1000; background: white; width: 100%;
      border: 1px solid #ddd; max-height: 200px; overflow-y: auto;
      display: none;
    }
    .search-result-item {
      padding: 10px; cursor: pointer; border-bottom: 1px solid #eee;
    }
    .search-result-item:hover { background: #f0f0f0; }
    .room-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 15px; max-height: 400px; overflow-y: auto; padding: 10px;
    }
    .room-card {
      border: 2px solid #ddd; border-radius: 10px; padding: 15px;
      cursor: pointer; transition: all 0.3s;
    }
    .room-card:hover { border-color: #0d6efd; background: #f0f8ff; }
    .room-card.selected { border-color: #0d6efd; background: #e6f2ff; }
    .bill-preview {
      background: #f8f9fa; border-radius: 10px; padding: 15px;
      margin-top: 20px;
    }
  </style>
</head>
<body>
<div class="form-container">
  <div class="mb-3">
    <a href="${pageContext.request.contextPath}/staff/reservations" class="btn btn-outline-secondary">
      <i class="fas fa-arrow-left"></i> Back
    </a>
  </div>

  <% if(request.getAttribute("error") != null) { %>
  <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
  <% } %>

  <form method="POST" action="${pageContext.request.contextPath}/staff/reservations/<%= isEdit ? "update" : "save" %>"
        onsubmit="return validateForm()">
    <% if(isEdit) { %>
    <input type="hidden" name="id" value="<%= reservation.getId() %>">
    <% } %>

    <div class="card mb-3">
      <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-user"></i> Guest Information</h5>
      </div>
      <div class="card-body">
        <% if(!isEdit) { %>
        <input type="hidden" name="guestMode" id="guestMode" value="existing">
        <div class="guest-tabs">
          <div class="guest-tab active" onclick="switchMode('existing')">Existing Guest</div>
          <div class="guest-tab" onclick="switchMode('new')">New Guest</div>
        </div>

        <div id="existingGuestSection">
          <div class="mb-3">
            <label class="form-label">Search Guest</label>
            <input type="text" class="form-control" id="guestSearch"
                   placeholder="Type name, email or phone..." autocomplete="off">
            <div class="search-results" id="searchResults"></div>
          </div>
          <input type="hidden" name="guestId" id="guestId">
          <div id="selectedGuestInfo" class="alert alert-info" style="display: none;">
            <span id="selectedGuestName"></span>
            <button type="button" class="btn-close float-end" onclick="clearGuest()"></button>
          </div>
        </div>

        <div id="newGuestSection" style="display: none;">
          <div class="row">
            <div class="col-md-6 mb-2">
              <input type="text" name="firstName" class="form-control" placeholder="First Name *">
            </div>
            <div class="col-md-6 mb-2">
              <input type="text" name="lastName" class="form-control" placeholder="Last Name *">
            </div>
            <div class="col-md-6 mb-2">
              <input type="email" name="guestEmail" class="form-control" placeholder="Email">
            </div>
            <div class="col-md-6 mb-2">
              <input type="text" name="guestPhone" class="form-control" placeholder="Phone">
            </div>
          </div>
        </div>
        <% } else { %>
        <input type="hidden" name="guestId" value="<%= reservation.getGuestId() %>">
        <div class="alert alert-info">
          <strong><%= reservation.getGuestName() %></strong><br>
          <small><%= reservation.getGuestEmail() %> | <%= reservation.getGuestPhone() %></small>
        </div>
        <% } %>
      </div>
    </div>

    <div class="card mb-3">
      <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-door-open"></i> Room Selection</h5>
      </div>
      <div class="card-body">
        <input type="hidden" name="roomId" id="roomId"
               value="<%= isEdit ? reservation.getRoomId() : "" %>">
        <div class="room-grid" id="roomGrid">
          <%
            @SuppressWarnings("unchecked")
            List<RoomDTO> rooms = (List<RoomDTO>) request.getAttribute("rooms");
            if(rooms != null) {
              for(RoomDTO room : rooms) {
                boolean selected = isEdit && reservation.getRoomId() != null
                        && reservation.getRoomId().equals(room.getId());
          %>
          <div class="room-card <%= selected ? "selected" : "" %>"
               onclick="selectRoom(<%= room.getId() %>, '<%= room.getRoomNumber() %>',
                       '<%= room.getRoomType() %>', <%= room.getBasePrice() %>)">
            <div class="fw-bold">Room <%= room.getRoomNumber() %></div>
            <div><small><%= room.getRoomType() %></small></div>
            <!-- CHANGED: $ -> Rs. -->
            <div class="text-primary">Rs. <%= room.getBasePrice() %>/night</div>
          </div>
          <% }} %>
        </div>
      </div>
    </div>

    <div class="card mb-3">
      <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-calendar"></i> Stay Details</h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6 mb-3">
            <label>Check-in Date</label>
            <input type="date" name="checkInDate" class="form-control"
                   value="<%= isEdit ? reservation.getCheckInDate() : "" %>"
                   min="<%= LocalDate.now() %>" required onchange="calculateBill()">
          </div>
          <div class="col-md-6 mb-3">
            <label>Check-out Date</label>
            <input type="date" name="checkOutDate" class="form-control"
                   value="<%= isEdit ? reservation.getCheckOutDate() : "" %>"
                   min="<%= LocalDate.now() %>" required onchange="calculateBill()">
          </div>
          <div class="col-md-3 mb-3">
            <label>Adults</label>
            <input type="number" name="adults" class="form-control" min="1"
                   value="<%= isEdit ? reservation.getAdults() : 1 %>" required>
          </div>
          <div class="col-md-3 mb-3">
            <label>Children</label>
            <input type="number" name="children" class="form-control" min="0"
                   value="<%= isEdit ? reservation.getChildren() : 0 %>">
          </div>
          <div class="col-md-3 mb-3">
            <!-- CHANGED: Discount ($) -> Discount (Rs.) -->
            <label>Discount (Rs.)</label>
            <input type="number" name="discountAmount" class="form-control" min="0" step="0.01"
                   value="<%= isEdit && reservation.getDiscountAmount() != null ? reservation.getDiscountAmount() : 0 %>"
                   onchange="calculateBill()">
          </div>
          <div class="col-md-3 mb-3">
            <label>Source</label>
            <select name="source" class="form-control">
              <option value="WALK_IN">Walk-in</option>
              <option value="PHONE">Phone</option>
              <option value="EMAIL">Email</option>
              <option value="WEBSITE">Website</option>
            </select>
          </div>
        </div>

        <div class="bill-preview" id="billPreview">
          <h6>Bill Preview</h6>
          <div class="row">
            <!-- CHANGED: all $ -> Rs. in bill preview labels and JS below -->
            <div class="col-6">Room Rate:</div>
            <div class="col-6 text-end" id="roomRate">Rs. 0.00/night</div>
            <div class="col-6">Nights:</div>
            <div class="col-6 text-end" id="nights">0</div>
            <div class="col-6">Subtotal:</div>
            <div class="col-6 text-end" id="subtotal">Rs. 0.00</div>
            <div class="col-6">Tax (12%):</div>
            <div class="col-6 text-end" id="tax">Rs. 0.00</div>
            <div class="col-6">Discount:</div>
            <div class="col-6 text-end" id="discount">-Rs. 0.00</div>
            <div class="col-6 fw-bold">Total:</div>
            <div class="col-6 text-end fw-bold" id="total">Rs. 0.00</div>
          </div>
        </div>
      </div>
    </div>

    <div class="text-end">
      <button type="submit" class="btn btn-primary px-5">
        <%= isEdit ? "Update" : "Create" %> Reservation
      </button>
    </div>
  </form>
</div>

<script>
  let currentRoomPrice = 0;
  const ctxPath = '${pageContext.request.contextPath}';

  function switchMode(mode) {
    document.getElementById('guestMode').value = mode;
    document.querySelectorAll('.guest-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.guest-tab')[mode === 'existing' ? 0 : 1].classList.add('active');
    document.getElementById('existingGuestSection').style.display = mode === 'existing' ? 'block' : 'none';
    document.getElementById('newGuestSection').style.display = mode === 'new' ? 'block' : 'none';
  }

  // Guest search
  let searchTimeout;
  document.getElementById('guestSearch')?.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const query = this.value.trim();
    if(query.length < 2) {
      document.getElementById('searchResults').style.display = 'none';
      return;
    }

    searchTimeout = setTimeout(() => {
      fetch(ctxPath + '/api/guests/search?keyword=' + encodeURIComponent(query))
              .then(res => res.json())
              .then(data => {
                const resultsDiv = document.getElementById('searchResults');
                resultsDiv.innerHTML = '';
                if(data.length === 0) {
                  resultsDiv.innerHTML = '<div class="search-result-item">No guests found</div>';
                } else {
                  data.forEach(guest => {
                    const div = document.createElement('div');
                    div.className = 'search-result-item';
                    div.innerHTML = `<strong>${guest.fullName}</strong><br>
                                            <small>${guest.email} | ${guest.phone}</small>`;
                    div.onclick = () => selectGuest(guest.id, guest.fullName);
                    resultsDiv.appendChild(div);
                  });
                }
                resultsDiv.style.display = 'block';
              });
    }, 300);
  });

  function selectGuest(id, name) {
    document.getElementById('guestId').value = id;
    document.getElementById('selectedGuestName').textContent = name;
    document.getElementById('selectedGuestInfo').style.display = 'block';
    document.getElementById('searchResults').style.display = 'none';
    document.getElementById('guestSearch').value = '';
  }

  function clearGuest() {
    document.getElementById('guestId').value = '';
    document.getElementById('selectedGuestInfo').style.display = 'none';
  }

  function selectRoom(id, number, type, price) {
    document.getElementById('roomId').value = id;
    document.querySelectorAll('.room-card').forEach(c => c.classList.remove('selected'));
    event.currentTarget.classList.add('selected');
    currentRoomPrice = price;
    calculateBill();
  }

  function calculateBill() {
    const checkIn  = document.querySelector('input[name="checkInDate"]').value;
    const checkOut = document.querySelector('input[name="checkOutDate"]').value;
    const discount = parseFloat(document.querySelector('input[name="discountAmount"]').value) || 0;

    if(!checkIn || !checkOut || !currentRoomPrice) return;

    const nights   = Math.round((new Date(checkOut) - new Date(checkIn)) / (1000 * 60 * 60 * 24));
    if(nights <= 0) return;

    const subtotal = currentRoomPrice * nights;
    const tax      = subtotal * 0.12;
    const total    = subtotal + tax - discount;

    // CHANGED: all $ -> Rs. in dynamic bill preview
    document.getElementById('roomRate').textContent  = 'Rs. ' + currentRoomPrice.toFixed(2) + '/night';
    document.getElementById('nights').textContent    = nights;
    document.getElementById('subtotal').textContent  = 'Rs. ' + subtotal.toFixed(2);
    document.getElementById('tax').textContent       = 'Rs. ' + tax.toFixed(2);
    document.getElementById('discount').textContent  = '-Rs. ' + discount.toFixed(2);
    document.getElementById('total').textContent     = 'Rs. ' + total.toFixed(2);
  }

  function validateForm() {
    const mode = document.getElementById('guestMode')?.value || 'existing';

    if(mode === 'existing') {
      if(!document.getElementById('guestId').value) {
        alert('Please select a guest');
        return false;
      }
    } else {
      const firstName = document.querySelector('input[name="firstName"]').value.trim();
      const lastName  = document.querySelector('input[name="lastName"]').value.trim();
      if(!firstName || !lastName) {
        alert('First name and last name are required');
        return false;
      }
    }

    if(!document.getElementById('roomId').value) {
      alert('Please select a room');
      return false;
    }

    return true;
  }

  // Hide search results when clicking outside
  document.addEventListener('click', function(e) {
    if(!e.target.closest('#guestSearch')) {
      document.getElementById('searchResults').style.display = 'none';
    }
  });
</script>
</body>
</html>
