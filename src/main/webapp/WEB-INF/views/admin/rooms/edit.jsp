<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("pageTitle", "Edit Room");
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Room - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --primary-light: #e6f2ff;
            --secondary-color: #6c757d;
            --dark-color: #212529;
            --sidebar-width: 280px;
            --card-shadow: 0 10px 30px rgba(13,110,253,0.1);
            --transition: all 0.3s ease;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Poppins',sans-serif; background:linear-gradient(135deg,#f5f7fa 0%,#e9ecef 100%); min-height:100vh; overflow-x:hidden; }

        .sidebar { position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width); background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%); color:white; z-index:1000; box-shadow:5px 0 25px rgba(13,110,253,0.3); }
        .sidebar-brand { padding:25px; border-bottom:2px solid rgba(255,255,255,0.15); margin-bottom:20px; }
        .sidebar-brand h3 { font-size:1.8rem; font-weight:700; margin:0; }
        .sidebar-brand p { font-size:0.9rem; opacity:0.9; margin:5px 0 0; }
        .sidebar-menu { list-style:none; padding:0 15px; margin:0; }
        .sidebar-menu li { margin-bottom:8px; }
        .sidebar-menu a { display:flex; align-items:center; padding:14px 20px; color:rgba(255,255,255,0.85); text-decoration:none; transition:var(--transition); border-radius:12px; font-weight:500; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,0.15); color:white; transform:translateX(5px); }
        .sidebar-menu a i { width:30px; font-size:1.2rem; }

        .main-content { margin-left:var(--sidebar-width); padding:25px 35px; }
        .top-nav { background:white; border-radius:20px; padding:15px 30px; margin-bottom:30px; box-shadow:var(--card-shadow); display:flex; justify-content:space-between; align-items:center; border:1px solid rgba(13,110,253,0.1); }
        .page-title h2 { font-size:1.8rem; font-weight:600; margin:0; background:linear-gradient(135deg,#0d6efd,#0a58ca); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        .page-title p { color:var(--secondary-color); margin:3px 0 0; font-size:0.9rem; }
        .user-profile { display:flex; align-items:center; gap:12px; padding:8px 15px; border-radius:15px; background:var(--primary-light); }
        .user-avatar { width:45px; height:45px; background:linear-gradient(135deg,#0d6efd,#0a58ca); border-radius:12px; display:flex; align-items:center; justify-content:center; color:white; font-weight:600; font-size:1.1rem; }
        .user-info .name { font-weight:600; color:var(--dark-color); line-height:1.2; }
        .user-info .role { font-size:0.8rem; color:var(--secondary-color); }

        .breadcrumb-bar { background:white; border-radius:15px; padding:12px 20px; margin-bottom:25px; box-shadow:var(--card-shadow); border:1px solid rgba(13,110,253,0.08); }
        .breadcrumb { margin:0; }
        .breadcrumb-item a { color:var(--primary-color); text-decoration:none; font-size:0.9rem; font-weight:500; }
        .breadcrumb-item.active { font-size:0.9rem; font-weight:500; color:var(--secondary-color); }

        /* Room Info Bar */
        .room-info-bar { background:linear-gradient(135deg,#0d6efd,#0a58ca); border-radius:16px; padding:20px 25px; margin-bottom:25px; color:white; display:flex; align-items:center; gap:20px; }
        .room-info-bar i { font-size:2rem; opacity:0.8; }
        .room-info-bar h4 { margin:0; font-weight:700; font-size:1.3rem; }
        .room-info-bar p { margin:0; opacity:0.85; font-size:0.9rem; }

        .form-card { background:white; border-radius:20px; padding:35px; box-shadow:var(--card-shadow); border:1px solid rgba(13,110,253,0.08); }
        .form-card-header { display:flex; align-items:center; gap:15px; margin-bottom:30px; padding-bottom:20px; border-bottom:2px solid #f0f0f0; }
        .form-card-icon { width:55px; height:55px; background:linear-gradient(135deg,#198754,#157347); border-radius:14px; display:flex; align-items:center; justify-content:center; }
        .form-card-icon i { font-size:1.5rem; color:white; }
        .form-card-title h3 { font-size:1.3rem; font-weight:600; color:var(--dark-color); margin:0; }
        .form-card-title p { color:var(--secondary-color); margin:3px 0 0; font-size:0.85rem; }

        .section-divider { font-size:0.8rem; font-weight:600; color:var(--secondary-color); text-transform:uppercase; letter-spacing:1px; margin:25px 0 15px; padding-bottom:8px; border-bottom:1px solid #f0f0f0; }

        .form-label { font-weight:500; font-size:0.88rem; color:var(--dark-color); margin-bottom:6px; }
        .form-label .req { color:#dc3545; }
        .form-control, .form-select { border:2px solid #e9ecef; border-radius:12px; padding:11px 15px; font-size:0.9rem; transition:var(--transition); background:#fafbfc; }
        .form-control:focus, .form-select:focus { border-color:var(--primary-color); box-shadow:0 0 0 4px rgba(13,110,253,0.1); background:white; outline:none; }

        .input-group-text { border:2px solid #e9ecef; border-right:none; background:#f8f9fa; border-radius:12px 0 0 12px; color:var(--secondary-color); }
        .input-group .form-control { border-left:none; border-radius:0 12px 12px 0; }
        .input-group:focus-within .input-group-text { border-color:var(--primary-color); }

        .form-check-input { width:20px; height:20px; cursor:pointer; }
        .form-check-input:checked { background-color:var(--primary-color); border-color:var(--primary-color); }
        .form-check-label { font-size:0.9rem; font-weight:500; color:var(--dark-color); padding-top:2px; cursor:pointer; }

        .btn-submit { background:linear-gradient(135deg,#198754,#157347); color:white; border:none; padding:13px 35px; border-radius:12px; font-size:0.95rem; font-weight:600; cursor:pointer; transition:var(--transition); box-shadow:0 8px 20px rgba(25,135,84,0.3); display:inline-flex; align-items:center; gap:8px; }
        .btn-submit:hover { transform:translateY(-2px); box-shadow:0 12px 28px rgba(25,135,84,0.4); color:white; }
        .btn-cancel { background:white; color:var(--secondary-color); border:2px solid #e9ecef; padding:13px 25px; border-radius:12px; font-size:0.95rem; font-weight:500; cursor:pointer; transition:var(--transition); text-decoration:none; display:inline-flex; align-items:center; gap:8px; }
        .btn-cancel:hover { background:#f8f9fa; color:var(--dark-color); border-color:#ced4da; }

        .alert { border-radius:12px; border:none; padding:15px 20px; margin-bottom:20px; }

        @media(max-width:992px) { .sidebar { transform:translateX(-100%); } .main-content { margin-left:0; padding:20px; } }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms" class="active"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/bills"><i class="fas fa-file-invoice-dollar"></i><span>Bills & Payments</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/maintenance"><i class="fas fa-tools"></i><span>Maintenance</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/settings"><i class="fas fa-cog"></i><span>Settings</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<!-- Main Content -->
<div class="main-content">

    <!-- Top Nav -->
    <div class="top-nav">
        <div class="page-title">
            <h2>Edit Room</h2>
            <p>Update the room details below</p>
        </div>
        <div class="user-profile">
            <div class="user-avatar"><%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %></div>
            <div class="user-info d-none d-md-block">
                <div class="name"><%= user.getFullName() %></div>
                <div class="role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Breadcrumb -->
    <div class="breadcrumb-bar">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-home me-1"></i>Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/manage-rooms">Manage Rooms</a></li>
                <li class="breadcrumb-item active">Edit Room ${room.roomNumber}</li>
            </ol>
        </nav>
    </div>

    <!-- Room Info Bar -->
    <c:if test="${not empty room}">
        <div class="room-info-bar">
            <i class="fas fa-door-open"></i>
            <div>
                <h4>Room ${room.roomNumber} — ${room.roomType}</h4>
                <p>Floor ${room.floorNumber} &nbsp;|&nbsp; ${room.roomView} &nbsp;|&nbsp; Capacity: ${room.capacity} &nbsp;|&nbsp; $${room.basePrice}/night</p>
            </div>
        </div>
    </c:if>

    <!-- Error Alert -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i>${error}</div>
    </c:if>

    <!-- Form Card -->
    <div class="form-card">
        <div class="form-card-header">
            <div class="form-card-icon"><i class="fas fa-edit"></i></div>
            <div class="form-card-title">
                <h3>Update Room Information</h3>
                <p>Fields marked with <span style="color:#dc3545;">*</span> are required</p>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty room}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Room not found. <a href="${pageContext.request.contextPath}/admin/manage-rooms">Return to Manage Rooms</a>
                </div>
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/admin/rooms/edit" method="POST" id="editRoomForm" novalidate>
                    <input type="hidden" name="id" value="${room.id}">

                    <div class="section-divider"><i class="fas fa-info-circle me-2"></i>Basic Details</div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Room Number <span class="req">*</span></label>
                            <input type="text" class="form-control" name="roomNumber"
                                   value="${room.roomNumber}" required maxlength="10">
                            <div class="invalid-feedback">Room number is required.</div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Room Type <span class="req">*</span></label>
                            <select class="form-select" name="roomType" required>
                                <option value="">-- Select Type --</option>
                                <option value="STANDARD"  ${room.roomType == 'STANDARD'  ? 'selected' : ''}>Standard</option>
                                <option value="DELUXE"    ${room.roomType == 'DELUXE'    ? 'selected' : ''}>Deluxe</option>
                                <option value="SUITE"     ${room.roomType == 'SUITE'     ? 'selected' : ''}>Suite</option>
                                <option value="EXECUTIVE" ${room.roomType == 'EXECUTIVE' ? 'selected' : ''}>Executive</option>
                                <option value="FAMILY"    ${room.roomType == 'FAMILY'    ? 'selected' : ''}>Family</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Room View <span class="req">*</span></label>
                            <select class="form-select" name="roomView" required>
                                <option value="">-- Select View --</option>
                                <option value="OCEAN_VIEW"  ${room.roomView == 'OCEAN_VIEW'  ? 'selected' : ''}>Ocean View</option>
                                <option value="GARDEN_VIEW" ${room.roomView == 'GARDEN_VIEW' ? 'selected' : ''}>Garden View</option>
                                <option value="CITY_VIEW"   ${room.roomView == 'CITY_VIEW'   ? 'selected' : ''}>City View</option>
                                <option value="POOL_VIEW"   ${room.roomView == 'POOL_VIEW'   ? 'selected' : ''}>Pool View</option>
                            </select>
                        </div>
                    </div>

                    <div class="section-divider mt-4"><i class="fas fa-building me-2"></i>Room Specifications</div>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label">Floor Number <span class="req">*</span></label>
                            <input type="number" class="form-control" name="floorNumber"
                                   value="${room.floorNumber}" required min="1" max="50">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Capacity <span class="req">*</span></label>
                            <input type="number" class="form-control" name="capacity"
                                   value="${room.capacity}" required min="1" max="20">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Base Price / Night <span class="req">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" class="form-control" name="basePrice"
                                       value="${room.basePrice}" required min="0.01" step="0.01">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Tax Rate (%)</label>
                            <div class="input-group">
                                <input type="number" class="form-control" name="taxRate"
                                       value="${room.taxRate}" min="0" max="100" step="0.01">
                                <span class="input-group-text" style="border-left:none; border-radius:0 12px 12px 0; border:2px solid #e9ecef; background:#f8f9fa;">%</span>
                            </div>
                        </div>
                    </div>

                    <div class="section-divider mt-4"><i class="fas fa-concierge-bell me-2"></i>Amenities & Description</div>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Amenities</label>
                            <input type="text" class="form-control" name="amenities"
                                   placeholder="e.g. WiFi, AC, TV, Mini Bar"
                                   value="${room.amenities}">
                            <div class="form-text">Separate amenities with commas</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Status <span class="req">*</span></label>
                            <select class="form-select" name="status" required>
                                <option value="AVAILABLE"   ${room.status == 'AVAILABLE'   ? 'selected' : ''}>Available</option>
                                <option value="OCCUPIED"    ${room.status == 'OCCUPIED'    ? 'selected' : ''}>Occupied</option>
                                <option value="MAINTENANCE" ${room.status == 'MAINTENANCE' ? 'selected' : ''}>Under Maintenance</option>
                                <option value="RESERVED"    ${room.status == 'RESERVED'    ? 'selected' : ''}>Reserved</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="description" rows="3"
                                      placeholder="Describe the room's features...">${room.description}</textarea>
                        </div>
                    </div>

                    <div class="section-divider mt-4"><i class="fas fa-toggle-on me-2"></i>Visibility</div>
                    <div class="row g-3">
                        <div class="col-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="isActive" id="isActive" ${room.active ? 'checked' : ''}>
                                <label class="form-check-label" for="isActive">
                                    Room is <strong>Active</strong> — visible and available for bookings
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex gap-3 mt-4 pt-3" style="border-top:2px solid #f0f0f0;">
                        <button type="submit" class="btn-submit">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/manage-rooms" class="btn-cancel">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('editRoomForm') && document.getElementById('editRoomForm').addEventListener('submit', function(e) {
        if (!this.checkValidity()) {
            e.preventDefault();
            e.stopPropagation();
        }
        this.classList.add('was-validated');
    });
</script>
</body>
</html>
