<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("pageTitle", "Manage Rooms");
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Rooms - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --primary-dark: #0b5ed7;
            --primary-light: #e6f2ff;
            --secondary-color: #6c757d;
            --success-color: #198754;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --dark-color: #212529;
            --sidebar-width: 280px;
            --card-shadow: 0 10px 30px rgba(13,110,253,0.1);
            --transition: all 0.3s ease;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Poppins',sans-serif; background:linear-gradient(135deg,#f5f7fa 0%,#e9ecef 100%); min-height:100vh; overflow-x:hidden; }

        /* Sidebar */
        .sidebar { position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width); background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%); color:white; z-index:1000; box-shadow:5px 0 25px rgba(13,110,253,0.3); }
        .sidebar-brand { padding:25px; border-bottom:2px solid rgba(255,255,255,0.15); margin-bottom:20px; }
        .sidebar-brand h3 { font-size:1.8rem; font-weight:700; margin:0; letter-spacing:1px; }
        .sidebar-brand p { font-size:0.9rem; opacity:0.9; margin:5px 0 0; }
        .sidebar-menu { list-style:none; padding:0 15px; margin:0; }
        .sidebar-menu li { margin-bottom:8px; }
        .sidebar-menu a { display:flex; align-items:center; padding:14px 20px; color:rgba(255,255,255,0.85); text-decoration:none; transition:var(--transition); border-radius:12px; font-weight:500; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,0.15); color:white; transform:translateX(5px); box-shadow:0 5px 15px rgba(0,0,0,0.2); }
        .sidebar-menu a i { width:30px; font-size:1.2rem; }

        /* Main */
        .main-content { margin-left:var(--sidebar-width); padding:25px 35px; }
        .top-nav { background:white; border-radius:20px; padding:15px 30px; margin-bottom:30px; box-shadow:var(--card-shadow); display:flex; justify-content:space-between; align-items:center; border:1px solid rgba(13,110,253,0.1); }
        .page-title h2 { font-size:1.8rem; font-weight:600; margin:0; background:linear-gradient(135deg,#0d6efd,#0a58ca); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        .page-title p { color:var(--secondary-color); margin:3px 0 0; font-size:0.9rem; }
        .user-profile { display:flex; align-items:center; gap:12px; padding:8px 15px; border-radius:15px; background:var(--primary-light); cursor:pointer; }
        .user-avatar { width:45px; height:45px; background:linear-gradient(135deg,#0d6efd,#0a58ca); border-radius:12px; display:flex; align-items:center; justify-content:center; color:white; font-weight:600; font-size:1.1rem; }
        .user-info .name { font-weight:600; color:var(--dark-color); line-height:1.2; }
        .user-info .role { font-size:0.8rem; color:var(--secondary-color); }

        /* Alert */
        .alert { border-radius:15px; border:none; padding:15px 20px; margin-bottom:25px; }

        /* Stats Row */
        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:20px; margin-bottom:30px; }
        .stat-card { background:white; border-radius:18px; padding:20px 25px; box-shadow:var(--card-shadow); display:flex; align-items:center; gap:18px; border:1px solid rgba(13,110,253,0.08); transition:var(--transition); }
        .stat-card:hover { transform:translateY(-5px); box-shadow:0 20px 40px rgba(13,110,253,0.15); }
        .stat-icon { width:55px; height:55px; border-radius:14px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .stat-icon i { font-size:1.6rem; color:white; }
        .stat-icon.blue { background:linear-gradient(135deg,#0d6efd,#0a58ca); }
        .stat-icon.green { background:linear-gradient(135deg,#198754,#157347); }
        .stat-icon.yellow { background:linear-gradient(135deg,#ffc107,#e0a800); }
        .stat-icon.red { background:linear-gradient(135deg,#dc3545,#b02a37); }
        .stat-info h3 { font-size:1.9rem; font-weight:700; color:var(--dark-color); margin:0 0 2px; line-height:1; }
        .stat-info p { color:var(--secondary-color); margin:0; font-size:0.85rem; }

        /* Filter Card */
        .filter-card { background:white; border-radius:20px; padding:20px 25px; box-shadow:var(--card-shadow); margin-bottom:25px; border:1px solid rgba(13,110,253,0.08); }
        .filter-card .row { align-items:flex-end; }
        .filter-card .form-select, .filter-card .form-control { border:2px solid #e9ecef; border-radius:10px; padding:10px 15px; font-size:0.9rem; transition:var(--transition); }
        .filter-card .form-select:focus, .filter-card .form-control:focus { border-color:var(--primary-color); box-shadow:0 0 0 3px rgba(13,110,253,0.1); }
        .filter-card label { font-weight:500; font-size:0.85rem; color:var(--dark-color); margin-bottom:6px; }

        /* Table Card */
        .table-card { background:white; border-radius:20px; padding:25px; box-shadow:var(--card-shadow); border:1px solid rgba(13,110,253,0.08); }
        .table-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
        .table-header h3 { font-size:1.3rem; font-weight:600; color:var(--dark-color); margin:0; padding-left:12px; border-left:4px solid var(--primary-color); border-radius:2px; }
        .btn-add { background:linear-gradient(135deg,#0d6efd,#0a58ca); color:white; border:none; padding:10px 22px; border-radius:12px; font-size:0.9rem; font-weight:500; text-decoration:none; display:inline-flex; align-items:center; gap:8px; transition:var(--transition); box-shadow:0 5px 15px rgba(13,110,253,0.3); }
        .btn-add:hover { color:white; transform:translateY(-2px); box-shadow:0 10px 25px rgba(13,110,253,0.4); }

        .table { margin:0; }
        .table thead th { background:#f8f9ff; color:var(--secondary-color); font-weight:600; font-size:0.8rem; text-transform:uppercase; letter-spacing:0.5px; padding:14px 12px; border:none; }
        .table thead th:first-child { border-radius:10px 0 0 10px; }
        .table thead th:last-child { border-radius:0 10px 10px 0; }
        .table tbody tr { transition:var(--transition); }
        .table tbody tr:hover { background:#f8f9ff; }
        .table tbody td { padding:14px 12px; vertical-align:middle; border-bottom:1px solid #f0f0f0; font-size:0.9rem; color:var(--dark-color); }
        .table tbody tr:last-child td { border-bottom:none; }

        .room-num { font-weight:700; font-size:1rem; color:var(--primary-color); }
        .room-type-badge { padding:4px 12px; border-radius:20px; font-size:0.78rem; font-weight:500; }
        .badge-standard { background:#e8f4fd; color:#0369a1; }
        .badge-deluxe { background:#fdf4e8; color:#92400e; }
        .badge-suite { background:#f0fdf4; color:#166534; }
        .badge-executive { background:#faf5ff; color:#6b21a8; }
        .badge-family { background:#fff1f2; color:#9f1239; }

        .status-badge { padding:5px 14px; border-radius:20px; font-size:0.8rem; font-weight:500; display:inline-flex; align-items:center; gap:5px; }
        .status-available { background:#d1fae5; color:#065f46; }
        .status-occupied { background:#dbeafe; color:#1e40af; }
        .status-maintenance { background:#fef9c3; color:#713f12; }
        .status-reserved { background:#ede9fe; color:#4c1d95; }

        .btn-action { padding:6px 12px; border-radius:8px; font-size:0.82rem; border:none; cursor:pointer; transition:var(--transition); display:inline-flex; align-items:center; gap:4px; text-decoration:none; }
        .btn-action:hover { transform:translateY(-2px); }
        .btn-view { background:#e8f4fd; color:#0369a1; }
        .btn-edit { background:#d1fae5; color:#065f46; }
        .btn-delete { background:#fee2e2; color:#991b1b; }

        .price-cell { font-weight:600; color:#0d6efd; }

        .empty-state { text-align:center; padding:50px 20px; color:var(--secondary-color); }
        .empty-state i { font-size:3rem; margin-bottom:15px; opacity:0.4; display:block; }

        @media(max-width:992px) { .sidebar { transform:translateX(-100%); } .main-content { margin-left:0; padding:20px; } .stats-row { grid-template-columns:repeat(2,1fr); } }
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
            <h2><i class="fas fa-door-open me-2" style="font-size:1.4rem; -webkit-text-fill-color:#0d6efd;"></i>Manage Rooms</h2>
            <p>View, add, edit, and manage all hotel rooms</p>
        </div>
        <div class="user-profile">
            <div class="user-avatar"><%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %></div>
            <div class="user-info d-none d-md-block">
                <div class="name"><%= user.getFullName() %></div>
                <div class="role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <!-- Alerts -->
    <c:if test="${param.success == 'created'}">
        <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Room created successfully!</div>
    </c:if>
    <c:if test="${param.success == 'updated'}">
        <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Room updated successfully!</div>
    </c:if>
    <c:if test="${param.success == 'deleted'}">
        <div class="alert alert-warning"><i class="fas fa-trash me-2"></i>Room deleted successfully!</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i>${error}</div>
    </c:if>
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>${sessionScope.success}</div>
        <% session.removeAttribute("success"); %>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.error}</div>
        <% session.removeAttribute("error"); %>
    </c:if>

    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-door-open"></i></div>
            <div class="stat-info">
                <h3>${totalRooms != null ? totalRooms : 0}</h3>
                <p>Total Rooms</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
            <div class="stat-info">
                <h3>${availableRooms != null ? availableRooms : 0}</h3>
                <p>Available</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red"><i class="fas fa-bed"></i></div>
            <div class="stat-info">
                <h3>${occupiedCount != null ? occupiedCount : 0}</h3>
                <p>Occupied</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon yellow"><i class="fas fa-tools"></i></div>
            <div class="stat-info">
                <h3>${maintenanceCount != null ? maintenanceCount : 0}</h3>
                <p>Maintenance</p>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="filter-card">
        <form method="GET" action="${pageContext.request.contextPath}/admin/manage-rooms">
            <div class="row g-3">
                <div class="col-md-3">
                    <label>Filter by Type</label>
                    <select name="type" class="form-select" onchange="this.form.submit()">
                        <option value="">All Types</option>
                        <option value="STANDARD"  ${selectedType == 'STANDARD'  ? 'selected' : ''}>Standard</option>
                        <option value="DELUXE"    ${selectedType == 'DELUXE'    ? 'selected' : ''}>Deluxe</option>
                        <option value="SUITE"     ${selectedType == 'SUITE'     ? 'selected' : ''}>Suite</option>
                        <option value="EXECUTIVE" ${selectedType == 'EXECUTIVE' ? 'selected' : ''}>Executive</option>
                        <option value="FAMILY"    ${selectedType == 'FAMILY'    ? 'selected' : ''}>Family</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Filter by Status</label>
                    <select name="status" class="form-select" onchange="this.form.submit()">
                        <option value="">All Statuses</option>
                        <option value="AVAILABLE"    ${selectedStatus == 'AVAILABLE'    ? 'selected' : ''}>Available</option>
                        <option value="OCCUPIED"     ${selectedStatus == 'OCCUPIED'     ? 'selected' : ''}>Occupied</option>
                        <option value="MAINTENANCE"  ${selectedStatus == 'MAINTENANCE'  ? 'selected' : ''}>Maintenance</option>
                        <option value="RESERVED"     ${selectedStatus == 'RESERVED'     ? 'selected' : ''}>Reserved</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Filter by Floor</label>
                    <select name="floor" class="form-select" onchange="this.form.submit()">
                        <option value="">All Floors</option>
                        <c:forEach begin="1" end="10" var="f">
                            <option value="${f}" ${selectedFloor == f ? 'selected' : ''}>Floor ${f}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>&nbsp;</label>
                    <a href="${pageContext.request.contextPath}/admin/manage-rooms" class="btn btn-outline-secondary d-block" style="border-radius:10px; padding:10px;">
                        <i class="fas fa-times me-1"></i> Clear Filters
                    </a>
                </div>
            </div>
        </form>
    </div>

    <!-- Rooms Table -->
    <div class="table-card">
        <div class="table-header">
            <h3>Rooms List</h3>
            <a href="${pageContext.request.contextPath}/admin/rooms/add" class="btn-add">
                <i class="fas fa-plus"></i> Add New Room
            </a>
        </div>

        <div class="table-responsive">
            <table class="table">
                <thead>
                <tr>
                    <th>Room #</th>
                    <th>Type</th>
                    <th>View</th>
                    <th>Floor</th>
                    <th>Capacity</th>
                    <th>Base Price</th>
                    <th>Status</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty rooms}">
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <i class="fas fa-door-closed"></i>
                                    <h5>No rooms found</h5>
                                    <p>Try adjusting your filters or <a href="${pageContext.request.contextPath}/admin/rooms/add">add a new room</a>.</p>
                                </div>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="room" items="${rooms}">
                            <tr>
                                <td><span class="room-num">${room.roomNumber}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${room.roomType == 'STANDARD'}"><span class="room-type-badge badge-standard">Standard</span></c:when>
                                        <c:when test="${room.roomType == 'DELUXE'}"><span class="room-type-badge badge-deluxe">Deluxe</span></c:when>
                                        <c:when test="${room.roomType == 'SUITE'}"><span class="room-type-badge badge-suite">Suite</span></c:when>
                                        <c:when test="${room.roomType == 'EXECUTIVE'}"><span class="room-type-badge badge-executive">Executive</span></c:when>
                                        <c:when test="${room.roomType == 'FAMILY'}"><span class="room-type-badge badge-family">Family</span></c:when>
                                    </c:choose>
                                </td>
                                <td>${room.roomView.toString().replace('_',' ')}</td>
                                <td>Floor ${room.floorNumber}</td>
                                <td><i class="fas fa-user me-1" style="color:#9ca3af;font-size:0.8rem;"></i>${room.capacity}</td>
                                <td><span class="price-cell">$${room.basePrice}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${room.status == 'AVAILABLE'}"><span class="status-badge status-available"><i class="fas fa-circle" style="font-size:0.5rem;"></i>Available</span></c:when>
                                        <c:when test="${room.status == 'OCCUPIED'}"><span class="status-badge status-occupied"><i class="fas fa-circle" style="font-size:0.5rem;"></i>Occupied</span></c:when>
                                        <c:when test="${room.status == 'MAINTENANCE'}"><span class="status-badge status-maintenance"><i class="fas fa-circle" style="font-size:0.5rem;"></i>Maintenance</span></c:when>
                                        <c:when test="${room.status == 'RESERVED'}"><span class="status-badge status-reserved"><i class="fas fa-circle" style="font-size:0.5rem;"></i>Reserved</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${room.active}"><span class="status-badge status-available">Yes</span></c:when>
                                        <c:otherwise><span class="status-badge status-occupied">No</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/rooms/edit?id=${room.id}" class="btn-action btn-edit" title="Edit">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <button onclick="confirmDelete(${room.id}, '${room.roomNumber}')" class="btn-action btn-delete ms-1" title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px; border:none; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" style="color:#dc3545;"><i class="fas fa-exclamation-triangle me-2"></i>Delete Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-2">
                <p class="mb-0">Are you sure you want to delete room <strong id="deleteRoomNum"></strong>? This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" style="border-radius:10px;" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteForm" method="POST" action="${pageContext.request.contextPath}/admin/rooms/delete" style="display:inline;">
                    <input type="hidden" name="id" id="deleteRoomId">
                    <button type="submit" class="btn btn-danger" style="border-radius:10px;"><i class="fas fa-trash me-2"></i>Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function confirmDelete(id, roomNum) {
        document.getElementById('deleteRoomId').value = id;
        document.getElementById('deleteRoomNum').textContent = roomNum;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    }
    // Auto-dismiss alerts
    setTimeout(() => { document.querySelectorAll('.alert').forEach(a => a.style.display='none'); }, 4000);
</script>
</body>
</html>
