<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Management - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0d6efd; --primary-dark: #0b5ed7;
            --muted: #6c757d;   --dark: #212529;
            --sidebar-width: 260px;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Poppins',sans-serif; background:#f4f6f9; overflow-x:hidden; }

        /* ── Sidebar ── */
        .sidebar {
            position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width);
            background:linear-gradient(180deg,#0b5ed7 0%,#0d6efd 100%);
            color:white; z-index:1000; box-shadow:3px 0 15px rgba(0,0,0,.15); overflow-y:auto;
        }
        .sidebar-brand { padding:25px 20px 20px; border-bottom:1px solid rgba(255,255,255,.2); margin-bottom:10px; }
        .sidebar-brand h3 { font-size:1.4rem; font-weight:700; margin:0; }
        .sidebar-brand p  { font-size:.8rem; opacity:.8; margin:4px 0 0; }
        .sidebar-menu { list-style:none; padding:5px 10px; margin:0; }
        .sidebar-menu li { margin-bottom:4px; }
        .sidebar-menu a {
            display:flex; align-items:center; padding:11px 15px;
            color:rgba(255,255,255,.85); text-decoration:none;
            transition:all .2s; border-radius:10px;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,.15); color:white; }
        .sidebar-menu a i   { width:28px; font-size:1.1rem; }
        .sidebar-menu a span{ font-size:.9rem; font-weight:500; }

        /* ── Layout ── */
        .main-content { margin-left:var(--sidebar-width); padding:20px 28px; }
        .top-nav {
            background:white; border-radius:15px; padding:14px 22px;
            margin-bottom:22px; box-shadow:0 2px 10px rgba(0,0,0,.06);
            display:flex; justify-content:space-between; align-items:center;
        }
        .page-title h2 { font-size:1.4rem; font-weight:600; color:var(--dark); margin:0; }
        .page-title p  { color:var(--muted); margin:3px 0 0; font-size:.85rem; }
        .user-avatar {
            width:40px; height:40px; background:linear-gradient(135deg,#0d6efd,#0b5ed7);
            border-radius:10px; display:flex; align-items:center;
            justify-content:center; color:white; font-weight:700; font-size:1rem;
        }
        .user-name { font-weight:600; color:var(--dark); font-size:.9rem; }
        .user-role { font-size:.75rem; color:var(--muted); }

        /* ── Stats ── */
        .stats-row { display:grid; grid-template-columns:repeat(5,1fr); gap:16px; margin-bottom:24px; }
        .stat-card {
            background:white; border-radius:14px; padding:18px 20px;
            box-shadow:0 2px 10px rgba(0,0,0,.06);
            display:flex; align-items:center; gap:14px;
            border-left:4px solid var(--primary);
            cursor:pointer; transition:transform .2s,box-shadow .2s;
            text-decoration:none; color:inherit;
        }
        .stat-card:hover { transform:translateY(-3px); box-shadow:0 8px 20px rgba(0,0,0,.1); color:inherit; }
        .stat-icon { width:48px; height:48px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .stat-icon i { font-size:22px; color:white; }
        .stat-card h4 { font-size:1.6rem; font-weight:700; margin:0; color:var(--dark); }
        .stat-card p  { font-size:.78rem; color:var(--muted); margin:2px 0 0; }

        /* ── Filter Panel ── */
        .filter-panel {
            background:white; border-radius:14px; padding:20px 24px;
            box-shadow:0 2px 10px rgba(0,0,0,.06); margin-bottom:22px;
        }
        .filter-title { font-size:.95rem; font-weight:600; color:var(--dark); margin-bottom:14px; display:flex; align-items:center; gap:8px; }
        .filter-row { display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end; }
        .filter-group { display:flex; flex-direction:column; gap:5px; flex:1; min-width:150px; }
        .filter-group label { font-size:.78rem; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:.4px; }
        .filter-group .form-control,
        .filter-group .form-select { border-radius:10px; border:1.5px solid #e2e8f0; font-size:.875rem; padding:8px 12px; transition:border-color .2s; }
        .filter-group .form-control:focus,
        .filter-group .form-select:focus { border-color:var(--primary); box-shadow:0 0 0 3px rgba(13,110,253,.1); }
        .btn-filter {
            background:linear-gradient(135deg,#0d6efd,#0b5ed7); color:white; border:none;
            border-radius:10px; padding:9px 22px; font-size:.875rem; font-weight:500;
            cursor:pointer; transition:all .2s; white-space:nowrap;
        }
        .btn-filter:hover { transform:translateY(-1px); box-shadow:0 4px 12px rgba(13,110,253,.3); }
        .btn-reset {
            background:#f8f9fa; color:var(--muted); border:1.5px solid #e2e8f0;
            border-radius:10px; padding:9px 18px; font-size:.875rem; font-weight:500;
            cursor:pointer; transition:all .2s; white-space:nowrap;
        }
        .btn-reset:hover { background:#e9ecef; }

        /* ── Results Bar ── */
        .results-bar { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
        .results-bar span { font-size:.85rem; color:var(--muted); }
        .view-toggle { display:flex; gap:4px; }
        .toggle-btn {
            width:34px; height:34px; border-radius:9px; border:1.5px solid #e2e8f0;
            background:white; display:flex; align-items:center; justify-content:center;
            cursor:pointer; transition:all .2s; color:var(--muted);
        }
        .toggle-btn.active { background:var(--primary); border-color:var(--primary); color:white; }

        /* ── Status Badges ── */
        .status-badge {
            display:inline-flex; align-items:center; gap:5px;
            padding:5px 12px; border-radius:20px; font-size:.76rem; font-weight:600; letter-spacing:.3px;
        }
        .status-badge .dot { width:7px; height:7px; border-radius:50%; display:inline-block; }
        .status-available   { background:#d1fae5; color:#065f46; }
        .status-available .dot   { background:#10b981; }
        .status-occupied    { background:#fce7f3; color:#9d174d; }
        .status-occupied .dot    { background:#ec4899; }
        .status-maintenance { background:#fef3c7; color:#92400e; }
        .status-maintenance .dot { background:#f59e0b; }
        .status-reserved    { background:#dbeafe; color:#1e40af; }
        .status-reserved .dot    { background:#3b82f6; }

        /* ── Room Cards ── */
        .rooms-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(310px,1fr)); gap:20px; }
        .room-card {
            background:white; border-radius:16px; overflow:hidden;
            box-shadow:0 2px 10px rgba(0,0,0,.06); border:2px solid transparent;
            transition:transform .25s,box-shadow .25s,border-color .25s;
        }
        .room-card:hover { transform:translateY(-5px); box-shadow:0 12px 30px rgba(0,0,0,.12); border-color:#e8f0fe; }
        .room-card-header {
            padding:18px 20px 14px; display:flex; justify-content:space-between; align-items:flex-start;
            background:linear-gradient(135deg,#f8faff 0%,#eef3ff 100%); border-bottom:1px solid #eef0f5;
        }
        .room-number { font-size:1.5rem; font-weight:700; color:var(--dark); }
        .room-floor  { font-size:.78rem; color:var(--muted); margin-top:2px; }
        .room-card-body { padding:16px 20px; }
        .room-meta { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:14px; }
        .meta-tag {
            display:inline-flex; align-items:center; gap:5px;
            background:#f4f6f9; border-radius:8px; padding:5px 10px; font-size:.78rem; color:var(--dark);
        }
        .meta-tag i { font-size:.75rem; color:var(--primary); }
        .room-price { display:flex; align-items:baseline; gap:4px; margin-bottom:12px; }
        .price-amount { font-size:1.4rem; font-weight:700; color:var(--dark); }
        .price-label  { font-size:.78rem; color:var(--muted); }
        .amenities-preview { font-size:.78rem; color:var(--muted); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; margin-bottom:14px; }
        .amenities-preview i { color:var(--primary); margin-right:4px; }
        .room-card-footer { padding:12px 20px; border-top:1px solid #f0f2f5; display:flex; justify-content:flex-end; }
        .btn-view {
            background:linear-gradient(135deg,#0d6efd,#0b5ed7); color:white; border:none;
            border-radius:9px; padding:7px 18px; font-size:.82rem; font-weight:500;
            cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:6px; transition:all .2s;
        }
        .btn-view:hover { transform:translateY(-1px); box-shadow:0 4px 10px rgba(13,110,253,.3); color:white; }

        /* ── Table View ── */
        .rooms-table-wrapper { background:white; border-radius:14px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,.06); }
        .rooms-table { width:100%; border-collapse:collapse; }
        .rooms-table thead th {
            background:#f8faff; padding:12px 16px; font-size:.78rem; font-weight:600;
            color:var(--muted); text-transform:uppercase; letter-spacing:.4px; border-bottom:2px solid #eef0f5;
        }
        .rooms-table tbody tr { border-bottom:1px solid #f4f6f9; transition:background .15s; }
        .rooms-table tbody tr:hover { background:#fafbff; }
        .rooms-table tbody td { padding:12px 16px; font-size:.875rem; vertical-align:middle; }

        /* ── Empty State ── */
        .empty-state { text-align:center; padding:60px 20px; background:white; border-radius:16px; box-shadow:0 2px 10px rgba(0,0,0,.06); grid-column:1/-1; }
        .empty-icon { width:80px; height:80px; border-radius:20px; background:linear-gradient(135deg,#e8f0fe,#dbeafe); display:flex; align-items:center; justify-content:center; margin:0 auto 16px; }
        .empty-icon i { font-size:36px; color:#3b82f6; }
        .empty-state h5 { font-weight:600; color:var(--dark); margin-bottom:8px; }
        .empty-state p  { color:var(--muted); font-size:.9rem; }

        /* ── Modal ── */
        .modal-header-custom { background:linear-gradient(135deg,#0d6efd,#0b5ed7); color:white; padding:20px 24px; }
        .modal-header-custom .btn-close { filter:invert(1); }
        .modal-content { border-radius:16px; border:none; overflow:hidden; }
        .modal-body { padding:24px; }
        .detail-row { display:flex; align-items:flex-start; gap:12px; padding:12px 0; border-bottom:1px solid #f0f2f5; }
        .detail-row:last-child { border-bottom:none; }
        .detail-icon { width:36px; height:36px; border-radius:10px; background:linear-gradient(135deg,#0d6efd,#0b5ed7); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .detail-icon i { font-size:15px; color:white; }
        .detail-label { font-size:.75rem; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:.4px; }
        .detail-value { font-size:.95rem; font-weight:500; color:var(--dark); }
        .price-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; background:#f8faff; border-radius:12px; padding:16px; margin-top:4px; }
        .price-box { text-align:center; }
        .price-box .pb-label { font-size:.72rem; color:var(--muted); font-weight:600; text-transform:uppercase; }
        .price-box .pb-val   { font-size:1.1rem; font-weight:700; color:var(--dark); margin-top:4px; }
        .alert-error-custom { background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; border-radius:10px; padding:12px 18px; margin-bottom:20px; display:flex; align-items:center; gap:10px; }

        @media(max-width:1200px){ .stats-row{grid-template-columns:repeat(3,1fr);} }
        @media(max-width:900px) { .stats-row{grid-template-columns:repeat(2,1fr);} }
        @media(max-width:768px){
            .sidebar{transform:translateX(-100%);}
            .main-content{margin-left:0; padding:15px;}
            .stats-row{grid-template-columns:1fr 1fr;}
            .filter-row{flex-direction:column;}
            .rooms-grid{grid-template-columns:1fr;}
        }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String basePath = "/staff";

    @SuppressWarnings("unchecked") List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) rooms = new java.util.ArrayList<>();

    Long totalRooms       = (Long)    request.getAttribute("totalRooms");       if(totalRooms==null)totalRooms=0L;
    Long availableRooms   = (Long)    request.getAttribute("availableRooms");   if(availableRooms==null)availableRooms=0L;
    Long occupiedRooms    = (Long)    request.getAttribute("occupiedRooms");    if(occupiedRooms==null)occupiedRooms=0L;
    Long maintenanceRooms = (Long)    request.getAttribute("maintenanceRooms"); if(maintenanceRooms==null)maintenanceRooms=0L;
    Long reservedRooms    = (Long)    request.getAttribute("reservedRooms");    if(reservedRooms==null)reservedRooms=0L;
    Integer filteredCount = (Integer) request.getAttribute("filteredCount");    if(filteredCount==null)filteredCount=0;

    String searchParam   = (String) request.getAttribute("searchParam");   if(searchParam==null)searchParam="";
    String typeParam     = (String) request.getAttribute("typeParam");     if(typeParam==null)typeParam="";
    String statusParam   = (String) request.getAttribute("statusParam");   if(statusParam==null)statusParam="";
    String roomViewParam = (String) request.getAttribute("roomViewParam"); if(roomViewParam==null)roomViewParam="";
    String floorParam    = (String) request.getAttribute("floorParam");    if(floorParam==null)floorParam="";
    String errorMsg      = (String) request.getAttribute("errorMsg");

    @SuppressWarnings("unchecked") List<Integer> floors = (List<Integer>) request.getAttribute("floors");
    if (floors == null) floors = new java.util.ArrayList<>();

    java.time.LocalDate today = java.time.LocalDate.now();
    String currentDate = today.format(java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy"));
%>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="<%= request.getContextPath() %>/staff/dashboard"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations/new"><i class="fas fa-plus-circle"></i><span>New Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations"><i class="fas fa-list-alt"></i><span>All Reservations</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/reservations/search"><i class="fas fa-search"></i><span>Search Reservation</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="<%= request.getContextPath() %>/staff/rooms" class="active"><i class="fas fa-door-open"></i><span>Rooms</span></a></li>
        <li><a href="<%= request.getContextPath() %><%= basePath %>/payments"><i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
        <li><a href="<%= request.getContextPath() %>/help"><i class="fas fa-question-circle"></i><span>Help & Guidelines</span></a></li>
        <li><a href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">
    <!-- Top Nav -->
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-door-open me-2" style="color:var(--primary);"></i>Room Management</h2>
            <p><i class="fas fa-calendar-alt me-1"></i><%= currentDate %></p>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="user-avatar"><%= user.getFirstName().charAt(0) %><%= user.getLastName().charAt(0) %></div>
            <div>
                <div class="user-name"><%= user.getFullName() %></div>
                <div class="user-role"><%= user.getRole() %></div>
            </div>
        </div>
    </div>

    <% if (errorMsg != null) { %>
    <div class="alert-error-custom"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% } %>

    <!-- Stats -->
    <div class="stats-row">
        <a href="<%= request.getContextPath() %>/staff/rooms" class="stat-card" style="border-left-color:#6c757d;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#6c757d,#495057);"><i class="fas fa-hotel"></i></div>
            <div><h4><%= totalRooms %></h4><p>Total Rooms</p></div>
        </a>
        <a href="<%= request.getContextPath() %>/staff/rooms?status=AVAILABLE" class="stat-card" style="border-left-color:#10b981;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-check-circle"></i></div>
            <div><h4><%= availableRooms %></h4><p>Available</p></div>
        </a>
        <a href="<%= request.getContextPath() %>/staff/rooms?status=OCCUPIED" class="stat-card" style="border-left-color:#ec4899;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#ec4899,#db2777);"><i class="fas fa-user-check"></i></div>
            <div><h4><%= occupiedRooms %></h4><p>Occupied</p></div>
        </a>
        <a href="<%= request.getContextPath() %>/staff/rooms?status=MAINTENANCE" class="stat-card" style="border-left-color:#f59e0b;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#f59e0b,#d97706);"><i class="fas fa-tools"></i></div>
            <div><h4><%= maintenanceRooms %></h4><p>Maintenance</p></div>
        </a>
        <a href="<%= request.getContextPath() %>/staff/rooms?status=RESERVED" class="stat-card" style="border-left-color:#3b82f6;">
            <div class="stat-icon" style="background:linear-gradient(135deg,#3b82f6,#2563eb);"><i class="fas fa-bookmark"></i></div>
            <div><h4><%= reservedRooms %></h4><p>Reserved</p></div>
        </a>
    </div>

    <!-- Filter Panel -->
    <div class="filter-panel">
        <div class="filter-title"><i class="fas fa-filter" style="color:var(--primary);"></i> Search & Filter Rooms</div>
        <form method="get" action="<%= request.getContextPath() %>/staff/rooms" id="filterForm">
            <div class="filter-row">
                <div class="filter-group" style="flex:2;min-width:200px;">
                    <label>Search</label>
                    <input type="text" name="search" class="form-control" placeholder="Room number, amenities, description…" value="<%= searchParam %>">
                </div>
                <div class="filter-group">
                    <label>Room Type</label>
                    <select name="type" class="form-select">
                        <option value="">All Types</option>
                        <option value="STANDARD"  <%= "STANDARD".equals(typeParam)  ?"selected":"" %>>Standard</option>
                        <option value="DELUXE"    <%= "DELUXE".equals(typeParam)    ?"selected":"" %>>Deluxe</option>
                        <option value="SUITE"     <%= "SUITE".equals(typeParam)     ?"selected":"" %>>Suite</option>
                        <option value="EXECUTIVE" <%= "EXECUTIVE".equals(typeParam) ?"selected":"" %>>Executive</option>
                        <option value="FAMILY"    <%= "FAMILY".equals(typeParam)    ?"selected":"" %>>Family</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select name="status" class="form-select">
                        <option value="">All Status</option>
                        <option value="AVAILABLE"   <%= "AVAILABLE".equals(statusParam)   ?"selected":"" %>>Available</option>
                        <option value="OCCUPIED"    <%= "OCCUPIED".equals(statusParam)    ?"selected":"" %>>Occupied</option>
                        <option value="MAINTENANCE" <%= "MAINTENANCE".equals(statusParam) ?"selected":"" %>>Maintenance</option>
                        <option value="RESERVED"    <%= "RESERVED".equals(statusParam)    ?"selected":"" %>>Reserved</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Room View</label>
                    <select name="roomView" class="form-select">
                        <option value="">All Views</option>
                        <option value="OCEAN_VIEW"  <%= "OCEAN_VIEW".equals(roomViewParam)  ?"selected":"" %>>Ocean View</option>
                        <option value="GARDEN_VIEW" <%= "GARDEN_VIEW".equals(roomViewParam) ?"selected":"" %>>Garden View</option>
                        <option value="CITY_VIEW"   <%= "CITY_VIEW".equals(roomViewParam)   ?"selected":"" %>>City View</option>
                        <option value="POOL_VIEW"   <%= "POOL_VIEW".equals(roomViewParam)   ?"selected":"" %>>Pool View</option>
                    </select>
                </div>
                <div class="filter-group" style="min-width:120px;max-width:150px;">
                    <label>Floor</label>
                    <select name="floor" class="form-select">
                        <option value="">All Floors</option>
                        <% for (Integer fl : floors) { %>
                        <option value="<%= fl %>" <%= String.valueOf(fl).equals(floorParam)?"selected":"" %>>Floor <%= fl %></option>
                        <% } %>
                    </select>
                </div>
                <div class="d-flex gap-2 align-items-end">
                    <button type="submit" class="btn-filter"><i class="fas fa-search me-1"></i>Search</button>
                    <button type="button" class="btn-reset" onclick="window.location='<%= request.getContextPath() %>/staff/rooms'">
                        <i class="fas fa-undo me-1"></i>Reset
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Results Bar -->
    <div class="results-bar">
        <span>
            Showing <strong><%= filteredCount %></strong> room<%= filteredCount!=1?"s":"" %>
            <% if(!searchParam.isEmpty()||!typeParam.isEmpty()||!statusParam.isEmpty()||!roomViewParam.isEmpty()||!floorParam.isEmpty()){%> (filtered)<%}%>
        </span>
        <div class="view-toggle">
            <button class="toggle-btn active" id="gridBtn" title="Grid view" onclick="setView('grid')"><i class="fas fa-th-large"></i></button>
            <button class="toggle-btn"        id="tableBtn" title="Table view" onclick="setView('table')"><i class="fas fa-list"></i></button>
        </div>
    </div>

    <!-- Grid View -->
    <div id="gridView" class="rooms-grid">
        <% if (rooms.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-icon"><i class="fas fa-door-open"></i></div>
            <h5>No Rooms Found</h5>
            <p>Try adjusting your search filters or reset to view all rooms.</p>
            <a href="<%= request.getContextPath() %>/staff/rooms" class="btn-filter d-inline-flex mt-3" style="text-decoration:none;">
                <i class="fas fa-undo me-2"></i>View All Rooms
            </a>
        </div>
        <% } else { for (Room r : rooms) {
            String rType   = r.getRoomType()  != null ? r.getRoomType().name().replace("_"," ") : "N/A";
            String rView   = r.getRoomView()  != null ? r.getRoomView().name().replace("_"," ") : "N/A";
            String rStatus = r.getStatus()    != null ? r.getStatus().name() : "AVAILABLE";
            String rStatusDisp = rStatus.replace("_"," ");
            String bCls    = "status-available";
            if("OCCUPIED".equals(rStatus))    bCls="status-occupied";
            else if("MAINTENANCE".equals(rStatus)) bCls="status-maintenance";
            else if("RESERVED".equals(rStatus))    bCls="status-reserved";
            // CHANGED: $ -> Rs.
            String priceStr  = r.getBasePrice() != null ? String.format("Rs. %.2f", r.getBasePrice()) : "Rs. 0.00";
            String taxStr    = r.getTaxRate()   != null ? String.format("%.1f%%", r.getTaxRate())  : "0%";
            String amenities = r.getAmenities() != null && !r.getAmenities().isEmpty() ? r.getAmenities() : "No amenities listed";
            String descr     = r.getDescription() != null ? r.getDescription() : "";
            int cap   = r.getCapacity()    != null ? r.getCapacity()    : 0;
            int floor = r.getFloorNumber() != null ? r.getFloorNumber() : 0;
            String vIcon = "fas fa-eye";
            if(r.getRoomView()!=null){
                String vn=r.getRoomView().name();
                if("OCEAN_VIEW".equals(vn))  vIcon="fas fa-water";
                else if("GARDEN_VIEW".equals(vn)) vIcon="fas fa-leaf";
                else if("POOL_VIEW".equals(vn))   vIcon="fas fa-swimming-pool";
                else if("CITY_VIEW".equals(vn))   vIcon="fas fa-city";
            }
            String safeAmenities = amenities.replace("'","\\'").replace("\"","&quot;");
            String safeDescr     = descr.replace("'","\\'").replace("\"","&quot;");
        %>
        <div class="room-card">
            <div class="room-card-header">
                <div>
                    <div class="room-number">Room <%= r.getRoomNumber() %></div>
                    <div class="room-floor"><i class="fas fa-layer-group me-1"></i>Floor <%= floor %></div>
                </div>
                <span class="status-badge <%= bCls %>"><span class="dot"></span><%= rStatusDisp %></span>
            </div>
            <div class="room-card-body">
                <div class="room-meta">
                    <span class="meta-tag"><i class="fas fa-bed"></i><%= rType %></span>
                    <span class="meta-tag"><i class="<%= vIcon %>"></i><%= rView %></span>
                    <span class="meta-tag"><i class="fas fa-users"></i><%= cap %> Guest<%= cap!=1?"s":"" %></span>
                </div>
                <div class="room-price">
                    <span class="price-amount"><%= priceStr %></span>
                    <span class="price-label">/ night <span style="color:#adb5bd;">(+<%= taxStr %> tax)</span></span>
                </div>
                <div class="amenities-preview">
                    <i class="fas fa-star"></i><%= amenities.length()>60 ? amenities.substring(0,60)+"…" : amenities %>
                </div>
            </div>
            <div class="room-card-footer">
                <button class="btn-view" onclick="openModal('<%= r.getRoomNumber() %>','<%= rType %>','<%= rView %>','<%= floor %>','<%= cap %>','<%= priceStr %>','<%= taxStr %>','<%= rStatus %>','<%= safeAmenities %>','<%= safeDescr %>','<%= r.isActive() %>','<%= bCls %>')">
                    <i class="fas fa-eye"></i> View Details
                </button>
            </div>
        </div>
        <% } } %>
    </div>

    <!-- Table View -->
    <div id="tableView" style="display:none;">
        <div class="rooms-table-wrapper">
            <table class="rooms-table">
                <thead>
                <tr>
                    <th>Room #</th><th>Type</th><th>View</th><th>Floor</th>
                    <th>Capacity</th><th>Base Price</th><th>Status</th><th>Active</th><th>Action</th>
                </tr>
                </thead>
                <tbody>
                <% if(rooms.isEmpty()){%>
                <tr><td colspan="9" class="text-center py-5 text-muted"><i class="fas fa-door-open fa-2x mb-2 d-block"></i>No rooms found.</td></tr>
                <%} else { for(Room r:rooms){
                    String rType   = r.getRoomType()  != null ? r.getRoomType().name().replace("_"," ") : "N/A";
                    String rView   = r.getRoomView()  != null ? r.getRoomView().name().replace("_"," ") : "N/A";
                    String rStatus = r.getStatus()    != null ? r.getStatus().name() : "AVAILABLE";
                    String bCls    = "status-available";
                    if("OCCUPIED".equals(rStatus))    bCls="status-occupied";
                    else if("MAINTENANCE".equals(rStatus)) bCls="status-maintenance";
                    else if("RESERVED".equals(rStatus))    bCls="status-reserved";
                    // CHANGED: $ -> Rs.
                    String priceStr  = r.getBasePrice() != null ? String.format("Rs. %.2f", r.getBasePrice()) : "Rs. 0.00";
                    String taxStr    = r.getTaxRate()   != null ? String.format("%.1f%%", r.getTaxRate())  : "0%";
                    String amenities = r.getAmenities() != null ? r.getAmenities() : "";
                    String descr     = r.getDescription() != null ? r.getDescription() : "";
                    int cap   = r.getCapacity()    != null ? r.getCapacity()    : 0;
                    int floor = r.getFloorNumber() != null ? r.getFloorNumber() : 0;
                    String safeAmenities = amenities.replace("'","\\'");
                    String safeDescr     = descr.replace("'","\\'");
                %>
                <tr>
                    <td><strong><%= r.getRoomNumber() %></strong></td>
                    <td><%= rType %></td>
                    <td><%= rView %></td>
                    <td>Floor <%= floor %></td>
                    <td><i class="fas fa-users me-1 text-muted"></i><%= cap %></td>
                    <td><strong><%= priceStr %></strong><br><small class="text-muted">+<%= taxStr %> tax</small></td>
                    <td><span class="status-badge <%= bCls %>"><span class="dot"></span><%= rStatus.replace("_"," ") %></span></td>
                    <td>
                        <% if(r.isActive()){%><span style="color:#10b981;font-weight:600;font-size:.8rem;"><i class="fas fa-check-circle me-1"></i>Yes</span>
                        <%}else{%><span style="color:#ef4444;font-weight:600;font-size:.8rem;"><i class="fas fa-times-circle me-1"></i>No</span><%}%>
                    </td>
                    <td>
                        <button class="btn-view" style="padding:5px 14px;font-size:.78rem;"
                                onclick="openModal('<%= r.getRoomNumber() %>','<%= rType %>','<%= rView %>','<%= floor %>','<%= cap %>','<%= priceStr %>','<%= taxStr %>','<%= rStatus %>','<%= safeAmenities %>','<%= safeDescr %>','<%= r.isActive() %>','<%= bCls %>')">
                            <i class="fas fa-eye"></i> View
                        </button>
                    </td>
                </tr>
                <%}}%>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Room Detail Modal -->
<div class="modal fade" id="roomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header-custom">
                <div class="d-flex justify-content-between align-items-center w-100">
                    <div>
                        <h5 class="mb-0 fw-bold" id="mTitle" style="font-size:1.2rem;"></h5>
                        <div id="mSubtitle" style="opacity:.85;font-size:.85rem;margin-top:3px;"></div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-hashtag"></i></div>
                            <div><div class="detail-label">Room Number</div><div class="detail-value" id="mNum"></div></div></div>
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-bed"></i></div>
                            <div><div class="detail-label">Room Type</div><div class="detail-value" id="mType"></div></div></div>
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-eye"></i></div>
                            <div><div class="detail-label">Room View</div><div class="detail-value" id="mView"></div></div></div>
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-layer-group"></i></div>
                            <div><div class="detail-label">Floor</div><div class="detail-value" id="mFloor"></div></div></div>
                    </div>
                    <div class="col-md-6">
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-users"></i></div>
                            <div><div class="detail-label">Capacity</div><div class="detail-value" id="mCap"></div></div></div>
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-circle"></i></div>
                            <div><div class="detail-label">Status</div><div class="detail-value" id="mStatus"></div></div></div>
                        <div class="detail-row"><div class="detail-icon"><i class="fas fa-toggle-on"></i></div>
                            <div><div class="detail-label">Active</div><div class="detail-value" id="mActive"></div></div></div>
                    </div>
                </div>
                <!-- CHANGED: fa-dollar-sign -> fa-rupee-sign, label text updated -->
                <div class="detail-label mt-3 mb-2" style="padding-left:4px;"><i class="fas fa-rupee-sign me-1" style="color:var(--primary);"></i>Pricing</div>
                <div class="price-grid">
                    <div class="price-box"><div class="pb-label">Base Rate / Night</div><div class="pb-val" id="mBase"></div></div>
                    <div class="price-box"><div class="pb-label">Tax Rate</div><div class="pb-val" id="mTax"></div></div>
                    <div class="price-box"><div class="pb-label">Est. Total / Night</div><div class="pb-val" id="mTotal"></div></div>
                </div>
                <div class="detail-label mt-3 mb-2" style="padding-left:4px;"><i class="fas fa-star me-1" style="color:var(--primary);"></i>Amenities</div>
                <div id="mAmenities" style="background:#f8faff;border-radius:10px;padding:12px 16px;font-size:.875rem;color:var(--dark);line-height:1.7;"></div>
                <div id="mDescrWrap" style="display:none;">
                    <div class="detail-label mt-3 mb-2" style="padding-left:4px;"><i class="fas fa-info-circle me-1" style="color:var(--primary);"></i>Description</div>
                    <div id="mDescr" style="background:#f8faff;border-radius:10px;padding:12px 16px;font-size:.875rem;color:var(--dark);line-height:1.7;"></div>
                </div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn-reset" data-bs-dismiss="modal" style="border-radius:10px;padding:9px 22px;">Close</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function setView(v) {
        var isGrid = v === 'grid';
        document.getElementById('gridView').style.display  = isGrid ? '' : 'none';
        document.getElementById('tableView').style.display = isGrid ? 'none' : '';
        document.getElementById('gridBtn').classList.toggle('active', isGrid);
        document.getElementById('tableBtn').classList.toggle('active', !isGrid);
        localStorage.setItem('staffRoomView', v);
    }
    (function(){ var s=localStorage.getItem('staffRoomView'); if(s==='table') setView('table'); })();

    function openModal(num, type, view, floor, cap, price, tax, status, amenities, descr, active, badgeCls) {
        document.getElementById('mTitle').textContent    = 'Room ' + num;
        document.getElementById('mSubtitle').textContent = type + ' · ' + view;
        document.getElementById('mNum').textContent   = num;
        document.getElementById('mType').textContent  = type;
        document.getElementById('mView').textContent  = view;
        document.getElementById('mFloor').textContent = 'Floor ' + floor;
        document.getElementById('mCap').textContent   = cap + ' Guest' + (parseInt(cap)!==1?'s':'');
        document.getElementById('mStatus').innerHTML  =
            '<span class="status-badge '+badgeCls+'"><span class="dot"></span>'+status.replace(/_/g,' ')+'</span>';
        document.getElementById('mActive').innerHTML  = active==='true'
            ? '<span style="color:#10b981;font-weight:600;"><i class="fas fa-check-circle me-1"></i>Active</span>'
            : '<span style="color:#ef4444;font-weight:600;"><i class="fas fa-times-circle me-1"></i>Inactive</span>';
        document.getElementById('mBase').textContent = price;
        document.getElementById('mTax').textContent  = tax;
        try {
            // CHANGED: parse "Rs. " prefix instead of "$", display as "Rs. X.XX"
            var b = parseFloat(price.replace('Rs. ', '')), t = parseFloat(tax.replace('%', ''));
            document.getElementById('mTotal').textContent = 'Rs. ' + (b + b * t / 100).toFixed(2);
        } catch(e){ document.getElementById('mTotal').textContent = price; }
        document.getElementById('mAmenities').textContent = amenities || 'No amenities listed.';
        var dw=document.getElementById('mDescrWrap');
        if(descr && descr.trim()!==''){
            document.getElementById('mDescr').textContent=descr; dw.style.display='';
        } else { dw.style.display='none'; }
        new bootstrap.Modal(document.getElementById('roomModal')).show();
    }

    document.addEventListener('DOMContentLoaded', function(){
        document.querySelectorAll('#filterForm select').forEach(function(s){
            s.addEventListener('change', function(){ document.getElementById('filterForm').submit(); });
        });
        var si=document.querySelector('input[name="search"]');
        if(si) si.addEventListener('keydown', function(e){ if(e.key==='Enter') document.getElementById('filterForm').submit(); });
    });
</script>
</body>
</html>
