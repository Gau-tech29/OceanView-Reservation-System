<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null || !currentUser.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/login"); return;
  }
  // KPI scalars
  String totalRevenue       = nvl(request.getAttribute("totalRevenue"),       "0.00");
  String totalReservations  = nvl(request.getAttribute("totalReservations"),  "0");
  String totalGuests        = nvl(request.getAttribute("totalGuests"),         "0");
  String totalRooms         = nvl(request.getAttribute("totalRooms"),          "0");
  String availableRooms     = nvl(request.getAttribute("availableRooms"),      "0");
  String occupiedRooms      = nvl(request.getAttribute("occupiedRooms"),       "0");
  String pendingPayments    = nvl(request.getAttribute("pendingPayments"),     "0");
  String monthRevenue       = nvl(request.getAttribute("monthRevenue"),        "0.00");
  String activeStaff        = nvl(request.getAttribute("activeStaff"),         "0");
  String totalDiscounts     = nvl(request.getAttribute("totalDiscounts"),      "0.00");
  String totalTax           = nvl(request.getAttribute("totalTax"),            "0.00");
  String avgBillValue       = nvl(request.getAttribute("avgBillValue"),        "0.00");
  String outstandingBalance = nvl(request.getAttribute("outstandingBalance"),  "0.00");
  String avgNights          = nvl(request.getAttribute("avgNights"),           "0");
  String avgGuests          = nvl(request.getAttribute("avgGuests"),           "0");
  String thisMonthResv      = nvl(request.getAttribute("thisMonthReservations"),"0");
  String cancelledResv      = nvl(request.getAttribute("cancelledReservations"),"0");
  String vipGuests          = nvl(request.getAttribute("vipGuests"),           "0");
  String loyaltyPoints      = nvl(request.getAttribute("totalLoyaltyPoints"),  "0");
  String newGuestsMonth     = nvl(request.getAttribute("newGuestsThisMonth"),  "0");
  String avgRoomPrice       = nvl(request.getAttribute("avgRoomPrice"),        "0.00");
  String maintenanceRooms   = nvl(request.getAttribute("maintenanceRooms"),    "0");

  // Lists
  List<Map<String,Object>> billStatusList         = safeList(request.getAttribute("billStatusList"));
  List<Map<String,Object>> paymentMethods         = safeList(request.getAttribute("paymentMethods"));
  List<Map<String,Object>> monthlyRevenue         = safeList(request.getAttribute("monthlyRevenue"));
  List<Map<String,Object>> topBills               = safeList(request.getAttribute("topBills"));
  List<Map<String,Object>> reservationStatusList  = safeList(request.getAttribute("reservationStatusList"));
  List<Map<String,Object>> bookingSources         = safeList(request.getAttribute("bookingSources"));
  List<Map<String,Object>> monthlyReservations    = safeList(request.getAttribute("monthlyReservations"));
  List<Map<String,Object>> guestCountries         = safeList(request.getAttribute("guestCountries"));
  List<Map<String,Object>> topGuests              = safeList(request.getAttribute("topGuests"));
  List<Map<String,Object>> guestCities            = safeList(request.getAttribute("guestCities"));
  List<Map<String,Object>> idCardTypes            = safeList(request.getAttribute("idCardTypes"));
  List<Map<String,Object>> roomTypes              = safeList(request.getAttribute("roomTypes"));
  List<Map<String,Object>> roomViews              = safeList(request.getAttribute("roomViews"));
  List<Map<String,Object>> roomStatusList         = safeList(request.getAttribute("roomStatusList"));
  List<Map<String,Object>> mostBookedRooms        = safeList(request.getAttribute("mostBookedRooms"));
  List<Map<String,Object>> floorDistribution      = safeList(request.getAttribute("floorDistribution"));
  List<Map<String,Object>> staffByRole            = safeList(request.getAttribute("staffByRole"));
  List<Map<String,Object>> staffActivity          = safeList(request.getAttribute("staffActivity"));
  List<Map<String,Object>> recentLogins           = safeList(request.getAttribute("recentLogins"));
  List<Map<String,Object>> staffBills             = safeList(request.getAttribute("staffBills"));

  // Computed
  int totR=parseInt(totalRooms), occR=parseInt(occupiedRooms);
  int occupancyPct = totR>0 ? (occR*100/totR) : 0;
  int totRes=parseInt(totalReservations), canRes=parseInt(cancelledResv);
  int cancelRate = totRes>0 ? (canRes*100/totRes) : 0;

  // Chart JSON
  String revLabels  = jsArr(monthlyRevenue,"month_label",true);
  String revData    = jsArr(monthlyRevenue,"revenue",false);
  String resvLabels = jsArr(monthlyReservations,"month_label",true);
  String resvTotData= jsArr(monthlyReservations,"total",false);
  String resvCanData= jsArr(monthlyReservations,"cancelled",false);
  String rtLabels   = jsArr(roomTypes,"room_type",true);
  String rtData     = jsArr(roomTypes,"cnt",false);
  String pmLabels   = jsArr(paymentMethods,"payment_method",true);
  String pmData     = jsArr(paymentMethods,"total",false);
  String srcLabels  = jsArr(bookingSources,"source",true);
  String srcData    = jsArr(bookingSources,"cnt",false);
  String ctryLabels = jsArr(guestCountries,"country",true);
  String ctryData   = jsArr(guestCountries,"cnt",false);
  String rvLabels   = jsArr(roomViews,"room_view",true);
  String rvData     = jsArr(roomViews,"cnt",false);

  String todayStr = java.time.LocalDate.now()
          .format(java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy"));
%>
<%!
  private String nvl(Object o, String d) { return o==null?d:o.toString(); }
  @SuppressWarnings("unchecked")
  private java.util.List<java.util.Map<String,Object>> safeList(Object o) {
    if (o instanceof java.util.List) return (java.util.List<java.util.Map<String,Object>>) o;
    return new java.util.ArrayList<>();
  }
  private int parseInt(String s) { try{return Integer.parseInt(s.split("\\.")[0]);}catch(Exception e){return 0;} }
  private String jsArr(java.util.List<java.util.Map<String,Object>> list, String key, boolean q) {
    StringBuilder sb=new StringBuilder("[");
    for(int i=0;i<list.size();i++){
      if(i>0)sb.append(",");
      Object v=list.get(i).get(key); String s=v==null?"":v.toString();
      if(q) sb.append("\"").append(s.replace("\"","'")).append("\"");
      else  sb.append(s.isEmpty()?"0":s);
    }
    return sb.append("]").toString();
  }
  private String badge(String s) {
    if(s==null)return "badge-muted";
    switch(s.toUpperCase()){
      case "PAID":case "COMPLETED":case "CONFIRMED":case "CHECKED_IN":return "badge-green";
      case "PENDING":case "DRAFT":case "PARTIALLY_PAID":return "badge-orange";
      case "CANCELLED":case "FAILED":case "MAINTENANCE":return "badge-red";
      case "ISSUED":case "RESERVED":return "badge-blue";
      case "CHECKED_OUT":return "badge-teal";
      default:return "badge-muted";
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reports - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    :root{--primary:#0d6efd;--primary-dark:#0a58ca;--primary-light:#e8f0fe;--success:#10b981;--warning:#f59e0b;--danger:#ef4444;--info:#0891b2;--purple:#7c3aed;--muted:#6c757d;--dark:#1e2130;--border:#e9ecef;--bg:#f4f6f9;--cr:18px;--sw:280px;}
    *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Poppins',sans-serif;background:var(--bg);overflow-x:hidden;}

    /* Sidebar */
    .sidebar{position:fixed;top:0;left:0;height:100vh;width:var(--sw);background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%);color:white;z-index:1000;box-shadow:5px 0 25px rgba(13,110,253,.3);overflow-y:auto;}
    .sidebar-brand{padding:26px 25px 20px;border-bottom:1px solid rgba(255,255,255,.18);margin-bottom:8px;}
    .sidebar-brand h3{font-size:1.5rem;font-weight:700;margin:0;}
    .sidebar-brand p{font-size:.82rem;opacity:.85;margin:4px 0 0;}
    .sidebar-menu{list-style:none;padding:0 14px;margin:0;}
    .sidebar-menu li{margin-bottom:4px;}
    .sidebar-menu a{display:flex;align-items:center;padding:11px 18px;color:rgba(255,255,255,.85);text-decoration:none;border-radius:12px;transition:all .25s;font-size:.88rem;font-weight:500;}
    .sidebar-menu a i{width:30px;font-size:1rem;}
    .sidebar-menu a:hover,.sidebar-menu a.active{background:rgba(255,255,255,.17);color:white;transform:translateX(4px);}
    .sidebar-divider{height:1px;background:rgba(255,255,255,.12);margin:10px 14px;}

    /* Layout */
    .main-content{margin-left:var(--sw);padding:24px 32px;min-height:100vh;}

    /* Top nav */
    .top-nav{background:white;border-radius:var(--cr);padding:16px 26px;margin-bottom:26px;box-shadow:0 4px 20px rgba(13,110,253,.08);display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px;}
    .page-title h2{font-size:1.45rem;font-weight:700;color:var(--dark);margin:0;display:flex;align-items:center;gap:10px;}
    .page-title p{color:var(--muted);margin:3px 0 0;font-size:.8rem;}
    .user-chip{display:flex;align-items:center;gap:10px;background:#f8faff;border-radius:14px;padding:8px 16px 8px 10px;border:1.5px solid var(--primary-light);}
    .u-av{width:38px;height:38px;border-radius:10px;background:linear-gradient(135deg,#0d6efd,#0a58ca);display:flex;align-items:center;justify-content:center;color:white;font-weight:700;font-size:.9rem;}
    .date-badge{background:var(--primary-light);color:var(--primary);border-radius:20px;padding:5px 14px;font-size:.76rem;font-weight:600;display:flex;align-items:center;gap:6px;}

    /* Tabs */
    .report-tabs{background:white;border-radius:var(--cr);padding:8px;margin-bottom:24px;box-shadow:0 4px 20px rgba(13,110,253,.08);display:flex;gap:4px;flex-wrap:wrap;}
    .rtab{flex:1;min-width:120px;padding:11px 16px;background:none;border:none;border-radius:12px;font-family:'Poppins',sans-serif;font-size:.82rem;font-weight:600;color:var(--muted);cursor:pointer;transition:all .2s;display:flex;align-items:center;justify-content:center;gap:7px;}
    .rtab:hover{background:#f8faff;color:var(--dark);}
    .rtab.active{color:white;}
    .rtab.active.tb{background:linear-gradient(135deg,#0d6efd,#0a58ca);box-shadow:0 4px 14px rgba(13,110,253,.35);}
    .rtab.active.tg{background:linear-gradient(135deg,#10b981,#059669);box-shadow:0 4px 14px rgba(16,185,129,.35);}
    .rtab.active.tp{background:linear-gradient(135deg,#7c3aed,#6d28d9);box-shadow:0 4px 14px rgba(124,58,237,.35);}
    .rtab.active.to{background:linear-gradient(135deg,#f59e0b,#d97706);box-shadow:0 4px 14px rgba(245,158,11,.35);}
    .rtab.active.tt{background:linear-gradient(135deg,#0891b2,#0e7490);box-shadow:0 4px 14px rgba(8,145,178,.35);}

    /* Panels */
    .rp{display:none;}.rp.active{display:block;animation:fi .3s ease;}
    @keyframes fi{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}

    /* KPI grid */
    .kpi-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
    .kpi-card{background:white;border-radius:var(--cr);padding:20px 22px;box-shadow:0 2px 12px rgba(0,0,0,.06);position:relative;overflow:hidden;transition:transform .2s,box-shadow .2s;cursor:default;}
    .kpi-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.1);}
    .kpi-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
    .kc-b::before{background:linear-gradient(90deg,#0d6efd,#0a58ca);}
    .kc-g::before{background:linear-gradient(90deg,#10b981,#059669);}
    .kc-o::before{background:linear-gradient(90deg,#f59e0b,#d97706);}
    .kc-p::before{background:linear-gradient(90deg,#7c3aed,#6d28d9);}
    .kc-t::before{background:linear-gradient(90deg,#0891b2,#0e7490);}
    .kc-r::before{background:linear-gradient(90deg,#ef4444,#dc2626);}
    .kpi-ico{width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:white;margin-bottom:14px;}
    .kc-b .kpi-ico{background:linear-gradient(135deg,#0d6efd,#0a58ca);}
    .kc-g .kpi-ico{background:linear-gradient(135deg,#10b981,#059669);}
    .kc-o .kpi-ico{background:linear-gradient(135deg,#f59e0b,#d97706);}
    .kc-p .kpi-ico{background:linear-gradient(135deg,#7c3aed,#6d28d9);}
    .kc-t .kpi-ico{background:linear-gradient(135deg,#0891b2,#0e7490);}
    .kc-r .kpi-ico{background:linear-gradient(135deg,#ef4444,#dc2626);}
    .kpi-val{font-size:1.55rem;font-weight:700;color:var(--dark);line-height:1;margin-bottom:5px;}
    .kpi-label{font-size:.75rem;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.4px;}
    .kpi-sub{font-size:.74rem;color:var(--muted);margin-top:4px;}

    /* Stat row */
    .stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:22px;}
    .stat-tile{background:white;border-radius:14px;padding:16px 18px;box-shadow:0 2px 10px rgba(0,0,0,.05);display:flex;align-items:center;gap:14px;}
    .st-ico{width:42px;height:42px;border-radius:11px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:1rem;color:white;}
    .st-val{font-size:1.2rem;font-weight:700;color:var(--dark);}
    .st-lbl{font-size:.72rem;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.3px;}

    /* Panel cards */
    .pc{background:white;border-radius:var(--cr);padding:24px;box-shadow:0 2px 12px rgba(0,0,0,.06);margin-bottom:20px;}
    .pc:last-child{margin-bottom:0;}
    .ct{font-size:.9rem;font-weight:700;color:var(--dark);margin-bottom:18px;display:flex;align-items:center;justify-content:space-between;}
    .ct i{color:var(--primary);}

    /* Grid helpers */
    .g2{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
    .g3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:20px;}

    /* Charts */
    .cw{position:relative;height:260px;}
    .cw-sm{position:relative;height:200px;}
    .cw-lg{position:relative;height:320px;}

    /* Table */
    .rt{width:100%;border-collapse:collapse;font-size:.82rem;}
    .rt th{padding:10px 12px;text-align:left;font-weight:700;font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;border-bottom:2px solid var(--border);white-space:nowrap;}
    .rt td{padding:11px 12px;border-bottom:1px solid #f1f3f6;color:var(--dark);vertical-align:middle;}
    .rt tbody tr:hover{background:#fafbff;}
    .rt tbody tr:last-child td{border-bottom:none;}

    /* Badges */
    .bp{display:inline-flex;align-items:center;gap:4px;padding:4px 11px;border-radius:20px;font-size:.72rem;font-weight:600;white-space:nowrap;}
    .badge-green{background:#d1fae5;color:#065f46;}
    .badge-orange{background:#fef3c7;color:#92400e;}
    .badge-red{background:#fee2e2;color:#991b1b;}
    .badge-blue{background:#dbeafe;color:#1e40af;}
    .badge-purple{background:#ede9fe;color:#5b21b6;}
    .badge-teal{background:#cffafe;color:#164e63;}
    .badge-muted{background:#f3f4f6;color:#6b7280;}

    /* Progress */
    .pw{margin-bottom:14px;}
    .pl{display:flex;justify-content:space-between;font-size:.8rem;margin-bottom:5px;font-weight:500;}
    .pt{height:8px;background:#e9ecef;border-radius:10px;overflow:hidden;}
    .pf{height:100%;border-radius:10px;transition:width .6s ease;}

    /* Bill status tiles */
    .bsg{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;}
    .bst{border-radius:12px;padding:14px 16px;text-align:center;}
    .bst .bsc{font-size:1.4rem;font-weight:700;margin-bottom:3px;}
    .bst .bsl{font-size:.72rem;font-weight:600;text-transform:uppercase;letter-spacing:.4px;}
    .bst-paid{background:#d1fae5;color:#065f46;}.bst-partial{background:#fce7f3;color:#9d174d;}
    .bst-pend{background:#fef3c7;color:#92400e;}.bst-issued{background:#dbeafe;color:#1e40af;}
    .bst-draft{background:#f3f4f6;color:#374151;}

    /* Occupancy ring */
    .orw{display:flex;align-items:center;justify-content:center;gap:28px;padding:16px 0;}
    .rc{position:relative;width:160px;height:160px;}
    .rcn{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center;}
    .rcn .rcp{font-size:1.8rem;font-weight:700;color:var(--dark);line-height:1;}
    .rcn .rcs{font-size:.72rem;color:var(--muted);margin-top:2px;}
    .rl{display:flex;flex-direction:column;gap:12px;}
    .rli{display:flex;align-items:center;gap:10px;}
    .rd{width:12px;height:12px;border-radius:3px;flex-shrink:0;}
    .rli .rll{font-size:.75rem;color:var(--muted);}
    .rli .rlv{font-size:.88rem;font-weight:700;color:var(--dark);}

    /* Buttons */
    .btn-print{background:linear-gradient(135deg,#6c757d,#495057);color:white;border:none;padding:9px 20px;border-radius:11px;font-weight:600;font-size:.8rem;cursor:pointer;font-family:'Poppins',sans-serif;display:inline-flex;align-items:center;gap:7px;transition:all .2s;text-decoration:none;}
    .btn-print:hover{transform:translateY(-2px);color:white;box-shadow:0 4px 14px rgba(0,0,0,.2);}

    /* Section header */
    .sh{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;flex-wrap:wrap;gap:10px;}
    .st2{font-size:1.1rem;font-weight:700;color:var(--dark);display:flex;align-items:center;gap:10px;}
    .si{width:38px;height:38px;border-radius:11px;display:flex;align-items:center;justify-content:center;color:white;font-size:.95rem;}
    .si-b{background:linear-gradient(135deg,#0d6efd,#0a58ca);}
    .si-g{background:linear-gradient(135deg,#10b981,#059669);}
    .si-o{background:linear-gradient(135deg,#f59e0b,#d97706);}
    .si-p{background:linear-gradient(135deg,#7c3aed,#6d28d9);}
    .si-t{background:linear-gradient(135deg,#0891b2,#0e7490);}

    .empty{text-align:center;padding:32px;color:var(--muted);}
    .empty i{font-size:2rem;opacity:.2;display:block;margin-bottom:8px;}
    .empty p{font-size:.82rem;}

    /* Responsive */
    @media(max-width:1200px){.kpi-grid{grid-template-columns:repeat(3,1fr);}.stat-row{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:900px){.sidebar{transform:translateX(-100%);}.main-content{margin-left:0;padding:16px;}.kpi-grid{grid-template-columns:repeat(2,1fr);}.g2,.g3{grid-template-columns:1fr;}.bsg{grid-template-columns:1fr 1fr;}}
    @media(max-width:600px){.kpi-grid{grid-template-columns:1fr;}.stat-row{grid-template-columns:1fr;}}
    @media print{.sidebar,.report-tabs,.btn-print,.user-chip{display:none!important;}.main-content{margin-left:0;padding:0;}.rp{display:block!important;}}
  </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar">
  <div class="sidebar-brand"><h3><i class="fas fa-hotel me-2"></i>Ocean View</h3><p>Hotel Reservation System</p></div>
  <ul class="sidebar-menu">
    <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/manage-staff"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/payments"><i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
    <li><a href="${pageContext.request.contextPath}/admin/reports" class="active"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
    <div class="sidebar-divider"></div>
    <li><a href="${pageContext.request.contextPath}/admin/settings"><i class="fas fa-cog"></i><span>Settings</span></a></li>
    <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
  </ul>
</div>

<div class="main-content">

  <!-- Top Nav -->
  <div class="top-nav">
    <div class="page-title">
      <h2><i class="fas fa-chart-bar" style="color:var(--primary);"></i>Reports &amp; Analytics</h2>
      <p>Comprehensive insights into Ocean View Hotel operations</p>
    </div>
    <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
      <span class="date-badge"><i class="fas fa-calendar"></i><%= todayStr %></span>
      <button class="btn-print" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
      <div class="user-chip">
        <div class="u-av"><%= currentUser.getFirstName().charAt(0) %><%= currentUser.getLastName().charAt(0) %></div>
        <div><div style="font-weight:600;font-size:.85rem;color:var(--dark);"><%= currentUser.getFullName() %></div>
          <div style="font-size:.72rem;color:var(--muted);"><%= currentUser.getRole() %></div></div>
      </div>
    </div>
  </div>

  <!-- Overview KPIs -->
  <div class="kpi-grid">
    <div class="kpi-card kc-b"><div class="kpi-ico"><i class="fas fa-dollar-sign"></i></div>
      <div class="kpi-val">LKR <%= totalRevenue %></div>
      <div class="kpi-label">Total Revenue</div>
      <div class="kpi-sub">This month: LKR <%= monthRevenue %></div></div>
    <div class="kpi-card kc-g"><div class="kpi-ico"><i class="fas fa-calendar-check"></i></div>
      <div class="kpi-val"><%= totalReservations %></div>
      <div class="kpi-label">Total Reservations</div>
      <div class="kpi-sub">This month: <%= thisMonthResv %></div></div>
    <div class="kpi-card kc-p"><div class="kpi-ico"><i class="fas fa-users"></i></div>
      <div class="kpi-val"><%= totalGuests %></div>
      <div class="kpi-label">Total Guests</div>
      <div class="kpi-sub">VIP: <%= vipGuests %> &nbsp;·&nbsp; New this month: <%= newGuestsMonth %></div></div>
    <div class="kpi-card kc-o"><div class="kpi-ico"><i class="fas fa-bed"></i></div>
      <div class="kpi-val"><%= occupancyPct %>%</div>
      <div class="kpi-label">Occupancy Rate</div>
      <div class="kpi-sub"><%= occupiedRooms %> / <%= totalRooms %> rooms occupied</div></div>
    <div class="kpi-card kc-t"><div class="kpi-ico"><i class="fas fa-door-open"></i></div>
      <div class="kpi-val"><%= availableRooms %></div>
      <div class="kpi-label">Available Rooms</div>
      <div class="kpi-sub">Maintenance: <%= maintenanceRooms %></div></div>
    <div class="kpi-card kc-r"><div class="kpi-ico"><i class="fas fa-file-invoice-dollar"></i></div>
      <div class="kpi-val"><%= pendingPayments %></div>
      <div class="kpi-label">Pending Bills</div>
      <div class="kpi-sub">Outstanding: LKR <%= outstandingBalance %></div></div>
    <div class="kpi-card kc-b"><div class="kpi-ico"><i class="fas fa-users-cog"></i></div>
      <div class="kpi-val"><%= activeStaff %></div>
      <div class="kpi-label">Active Staff</div>
      <div class="kpi-sub">All roles combined</div></div>
    <div class="kpi-card kc-g"><div class="kpi-ico"><i class="fas fa-moon"></i></div>
      <div class="kpi-val"><%= avgNights %></div>
      <div class="kpi-label">Avg Stay (Nights)</div>
      <div class="kpi-sub">Avg guests / booking: <%= avgGuests %></div></div>
  </div>

  <!-- Tabs -->
  <div class="report-tabs">
    <button class="rtab active tb" onclick="showTab('revenue')"><i class="fas fa-dollar-sign"></i> Revenue &amp; Billing</button>
    <button class="rtab tg"        onclick="showTab('reservations')"><i class="fas fa-calendar-alt"></i> Reservations</button>
    <button class="rtab tp"        onclick="showTab('guests')"><i class="fas fa-users"></i> Guests</button>
    <button class="rtab to"        onclick="showTab('rooms')"><i class="fas fa-bed"></i> Rooms</button>
    <button class="rtab tt"        onclick="showTab('staff')"><i class="fas fa-id-badge"></i> Staff</button>
  </div>

  <!-- ════ TAB 1: REVENUE ════ -->
  <div class="rp active" id="panel-revenue">
    <div class="sh">
      <div class="st2"><span class="si si-b"><i class="fas fa-dollar-sign"></i></span>Revenue &amp; Billing Report</div>
      <span class="date-badge"><i class="fas fa-sync-alt"></i> Live Data</span>
    </div>
    <div class="stat-row">
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#0d6efd,#0a58ca);"><i class="fas fa-chart-line"></i></div><div><div class="st-val">LKR <%= avgBillValue %></div><div class="st-lbl">Avg Bill Value</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-receipt"></i></div><div><div class="st-val">LKR <%= totalTax %></div><div class="st-lbl">Tax Collected</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#f59e0b,#d97706);"><i class="fas fa-tag"></i></div><div><div class="st-val">LKR <%= totalDiscounts %></div><div class="st-lbl">Total Discounts</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#ef4444,#dc2626);"><i class="fas fa-exclamation-circle"></i></div><div><div class="st-val">LKR <%= outstandingBalance %></div><div class="st-lbl">Outstanding</div></div></div>
    </div>
    <div class="g2">
      <div class="pc">
        <div class="ct"><span><i class="fas fa-chart-area"></i> Monthly Revenue (Last 12 Months)</span></div>
        <div class="cw-lg"><canvas id="revenueChart"></canvas></div>
      </div>
      <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="pc">
          <div class="ct"><span><i class="fas fa-file-invoice"></i> Bill Status Breakdown</span></div>
          <div class="bsg">
            <% for(Map<String,Object> row:billStatusList){
              String st=String.valueOf(row.get("bill_status"));
              String cnt=String.valueOf(row.get("cnt"));
              String tot=String.valueOf(row.get("total"));
              String tc="bst-draft";
              if(st.equals("PAID"))tc="bst-paid";
              else if(st.equals("PARTIALLY_PAID"))tc="bst-partial";
              else if(st.equals("ISSUED"))tc="bst-issued";
              else if(st.equals("DRAFT")||st.equals("PENDING"))tc="bst-pend";
            %>
            <div class="bst <%= tc %>">
              <div class="bsc"><%= cnt %></div>
              <div class="bsl"><%= st.replace("_"," ") %></div>
              <div style="font-size:.7rem;margin-top:3px;opacity:.8;">LKR <%= tot %></div>
            </div>
            <% } %>
          </div>
        </div>
        <div class="pc">
          <div class="ct"><span><i class="fas fa-credit-card"></i> Payment Methods</span></div>
          <div class="cw-sm"><canvas id="payMethodChart"></canvas></div>
        </div>
      </div>
    </div>
    <div class="pc">
      <div class="ct"><span><i class="fas fa-star"></i> Top 5 Bills by Amount</span></div>
      <% if(!topBills.isEmpty()){ %><div class="table-responsive"><table class="rt">
      <thead><tr><th>#</th><th>Bill Number</th><th>Guest</th><th>Amount</th><th>Status</th><th>Issue Date</th></tr></thead>
      <tbody>
      <% int br=1; for(Map<String,Object> row:topBills){ String bs=String.valueOf(row.get("bill_status")); %>
      <tr><td><strong>#<%= br++ %></strong></td><td><strong><%= row.get("bill_number") %></strong></td>
        <td><%= row.get("first_name") %> <%= row.get("last_name") %></td>
        <td><strong>LKR <%= row.get("total_amount") %></strong></td>
        <td><span class="bp <%= badge(bs) %>"><%= bs.replace("_"," ") %></span></td>
        <td style="color:var(--muted);font-size:.78rem;"><%= row.get("issue_date") %></td></tr>
      <% } %></tbody></table></div>
      <% }else{ %><div class="empty"><i class="fas fa-file-invoice"></i><p>No bill data available</p></div><% } %>
    </div>
  </div>

  <!-- ════ TAB 2: RESERVATIONS ════ -->
  <div class="rp" id="panel-reservations">
    <div class="sh">
      <div class="st2"><span class="si si-g"><i class="fas fa-calendar-alt"></i></span>Reservation Report</div>
      <span class="date-badge"><i class="fas fa-sync-alt"></i> Live Data</span>
    </div>
    <div class="stat-row">
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-calendar-plus"></i></div><div><div class="st-val"><%= thisMonthResv %></div><div class="st-lbl">This Month</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#ef4444,#dc2626);"><i class="fas fa-calendar-times"></i></div><div><div class="st-val"><%= cancelRate %>%</div><div class="st-lbl">Cancellation Rate</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#0891b2,#0e7490);"><i class="fas fa-moon"></i></div><div><div class="st-val"><%= avgNights %> nights</div><div class="st-lbl">Avg Stay</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#7c3aed,#6d28d9);"><i class="fas fa-user-friends"></i></div><div><div class="st-val"><%= avgGuests %></div><div class="st-lbl">Avg Guests/Booking</div></div></div>
    </div>
    <div class="g2">
      <div class="pc">
        <div class="ct"><span><i class="fas fa-chart-bar"></i> Monthly Reservations (Last 12 Months)</span></div>
        <div class="cw-lg"><canvas id="resvChart"></canvas></div>
      </div>
      <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="pc">
          <div class="ct"><span><i class="fas fa-tasks"></i> Reservation Status</span></div>
          <% for(Map<String,Object> row:reservationStatusList){
            String rs=String.valueOf(row.get("reservation_status"));
            int rc=parseInt(String.valueOf(row.get("cnt")));
            int rp=totRes>0?(rc*100/totRes):0;
            String fc="#10b981";
            if(rs.contains("CANCEL"))fc="#ef4444";
            else if(rs.contains("PENDING"))fc="#f59e0b";
            else if(rs.contains("CHECKED_IN"))fc="#0891b2";
            else if(rs.contains("CHECKED_OUT"))fc="#6c757d";
          %>
          <div class="pw"><div class="pl"><span><%= rs.replace("_"," ") %></span><span><strong><%= rc %></strong> (<%= rp %>%)</span></div>
            <div class="pt"><div class="pf" style="width:<%= rp %>%;background:<%= fc %>;"></div></div></div>
          <% } %>
        </div>
        <div class="pc">
          <div class="ct"><span><i class="fas fa-globe"></i> Booking Sources</span></div>
          <div class="cw-sm"><canvas id="srcChart"></canvas></div>
        </div>
      </div>
    </div>
    <div class="pc">
      <div class="ct"><span><i class="fas fa-money-check-alt"></i> Reservation Status Detail</span></div>
      <% if(!reservationStatusList.isEmpty()){ %><div class="table-responsive"><table class="rt">
      <thead><tr><th>Status</th><th>Count</th><th>Percentage</th><th>Visual</th></tr></thead>
      <tbody>
      <% for(Map<String,Object> row:reservationStatusList){ String rs2=String.valueOf(row.get("reservation_status")); int rc2=parseInt(String.valueOf(row.get("cnt"))); int rp2=totRes>0?(rc2*100/totRes):0; %>
      <tr><td><span class="bp <%= badge(rs2) %>"><%= rs2.replace("_"," ") %></span></td>
        <td><strong><%= rc2 %></strong></td><td><%= rp2 %>%</td>
        <td><div style="width:120px;height:6px;background:#e9ecef;border-radius:10px;overflow:hidden;"><div style="height:100%;width:<%= rp2 %>%;background:var(--primary);border-radius:10px;"></div></div></td></tr>
      <% } %></tbody></table></div>
      <% }else{ %><div class="empty"><i class="fas fa-calendar"></i><p>No reservation data</p></div><% } %>
    </div>
  </div>

  <!-- ════ TAB 3: GUESTS ════ -->
  <div class="rp" id="panel-guests">
    <div class="sh">
      <div class="st2"><span class="si si-p"><i class="fas fa-users"></i></span>Guest Report</div>
      <span class="date-badge"><i class="fas fa-sync-alt"></i> Live Data</span>
    </div>
    <div class="stat-row">
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#7c3aed,#6d28d9);"><i class="fas fa-users"></i></div><div><div class="st-val"><%= totalGuests %></div><div class="st-lbl">Total Guests</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#f59e0b,#d97706);"><i class="fas fa-crown"></i></div><div><div class="st-val"><%= vipGuests %></div><div class="st-lbl">VIP Guests</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-star"></i></div><div><div class="st-val"><%= loyaltyPoints %></div><div class="st-lbl">Loyalty Points</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#0891b2,#0e7490);"><i class="fas fa-user-plus"></i></div><div><div class="st-val"><%= newGuestsMonth %></div><div class="st-lbl">New This Month</div></div></div>
    </div>
    <div class="g2">
      <div class="pc">
        <div class="ct"><span><i class="fas fa-globe-asia"></i> Guests by Country (Top 8)</span></div>
        <div class="cw-lg"><canvas id="countryChart"></canvas></div>
      </div>
      <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="pc">
          <div class="ct"><span><i class="fas fa-id-card"></i> ID Document Types</span></div>
          <% int totId=0; for(Map<String,Object> r:idCardTypes) totId+=parseInt(String.valueOf(r.get("cnt")));
            for(Map<String,Object> row:idCardTypes){ String idt=String.valueOf(row.get("id_card_type")); int idc=parseInt(String.valueOf(row.get("cnt"))); int idp=totId>0?(idc*100/totId):0; %>
          <div class="pw"><div class="pl"><span><%= idt.replace("_"," ") %></span><span><strong><%= idc %></strong> (<%= idp %>%)</span></div>
            <div class="pt"><div class="pf" style="width:<%= idp %>%;background:var(--purple);"></div></div></div>
          <% } %>
        </div>
        <div class="pc">
          <div class="ct"><span><i class="fas fa-city"></i> Top Cities</span></div>
          <% if(!guestCities.isEmpty()){
            int totCt=0; for(Map<String,Object> r:guestCities) totCt+=parseInt(String.valueOf(r.get("cnt")));
            for(Map<String,Object> row:guestCities){ %>
          <div style="display:flex;align-items:center;justify-content:space-between;padding:7px 0;border-bottom:1px solid var(--border);font-size:.82rem;">
            <span><i class="fas fa-map-marker-alt me-2" style="color:var(--purple);"></i><%= row.get("city") %></span>
            <span class="bp badge-purple"><%= row.get("cnt") %></span>
          </div>
          <% }}else{ %><div class="empty"><i class="fas fa-city"></i><p>No city data</p></div><% } %>
        </div>
      </div>
    </div>
    <div class="pc">
      <div class="ct"><span><i class="fas fa-trophy"></i> Top 5 Guests by Total Spend</span></div>
      <% if(!topGuests.isEmpty()){ %><div class="table-responsive"><table class="rt">
      <thead><tr><th>#</th><th>Guest Name</th><th>Email</th><th>Reservations</th><th>Total Spent</th><th>Loyalty Pts</th><th>VIP</th></tr></thead>
      <tbody>
      <% int gr=1; for(Map<String,Object> row:topGuests){ %>
      <tr><td><strong>#<%= gr++ %></strong></td>
        <td><strong><%= row.get("first_name") %> <%= row.get("last_name") %></strong></td>
        <td style="color:var(--muted);font-size:.78rem;"><%= row.get("email") %></td>
        <td><span class="bp badge-blue"><%= row.get("reservation_count") %></span></td>
        <td><strong>LKR <%= row.get("total_spent") %></strong></td>
        <td><span class="bp badge-orange"><%= row.get("loyalty_points") %></span></td>
        <td><% if("1".equals(String.valueOf(row.get("is_vip")))){ %><span style="color:#f59e0b;font-weight:700;"><i class="fas fa-crown"></i> VIP</span><% }else{ %><span style="color:var(--muted);">—</span><% } %></td>
      </tr>
      <% } %></tbody></table></div>
      <% }else{ %><div class="empty"><i class="fas fa-users"></i><p>No guest data</p></div><% } %>
    </div>
  </div>

  <!-- ════ TAB 4: ROOMS ════ -->
  <div class="rp" id="panel-rooms">
    <div class="sh">
      <div class="st2"><span class="si si-o"><i class="fas fa-bed"></i></span>Room Utilization Report</div>
      <span class="date-badge"><i class="fas fa-sync-alt"></i> Live Data</span>
    </div>
    <div class="stat-row">
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#f59e0b,#d97706);"><i class="fas fa-door-open"></i></div><div><div class="st-val"><%= totalRooms %></div><div class="st-lbl">Active Rooms</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-check-circle"></i></div><div><div class="st-val"><%= availableRooms %></div><div class="st-lbl">Available Now</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#0d6efd,#0a58ca);"><i class="fas fa-tag"></i></div><div><div class="st-val">LKR <%= avgRoomPrice %></div><div class="st-lbl">Avg Room Price</div></div></div>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#ef4444,#dc2626);"><i class="fas fa-tools"></i></div><div><div class="st-val"><%= maintenanceRooms %></div><div class="st-lbl">Maintenance</div></div></div>
    </div>
    <div class="g3">
      <div class="pc"><div class="ct"><span><i class="fas fa-layer-group"></i> By Room Type</span></div><div class="cw"><canvas id="roomTypeChart"></canvas></div></div>
      <div class="pc"><div class="ct"><span><i class="fas fa-eye"></i> By Room View</span></div><div class="cw"><canvas id="roomViewChart"></canvas></div></div>
      <div class="pc">
        <div class="ct"><span><i class="fas fa-percentage"></i> Occupancy Rate</span></div>
        <div class="orw">
          <div class="rc"><canvas id="occupancyChart" width="160" height="160"></canvas>
            <div class="rcn"><div class="rcp"><%= occupancyPct %>%</div><div class="rcs">Occupied</div></div></div>
          <div class="rl">
            <% if(roomStatusList!=null){ String[] dotColors={"#0d6efd","#10b981","#f59e0b","#7c3aed"}; int di=0;
              for(Map<String,Object> row:roomStatusList){ String dc=dotColors[Math.min(di++,dotColors.length-1)];
                String rs3=String.valueOf(row.get("status")); if(rs3.equals("AVAILABLE"))dc="#10b981"; else if(rs3.equals("OCCUPIED"))dc="#0d6efd"; else if(rs3.equals("MAINTENANCE"))dc="#f59e0b"; else if(rs3.equals("RESERVED"))dc="#7c3aed"; %>
            <div class="rli"><div class="rd" style="background:<%= dc %>;"></div>
              <div><div class="rlv"><%= row.get("cnt") %></div><div class="rll"><%= rs3 %></div></div></div>
            <% }} %>
          </div>
        </div>
      </div>
    </div>
    <div class="g2">
      <div class="pc">
        <div class="ct"><span><i class="fas fa-building"></i> Rooms by Floor</span></div>
        <% if(!floorDistribution.isEmpty()){ %><div class="table-responsive"><table class="rt">
        <thead><tr><th>Floor</th><th>Total</th><th>Available</th><th>Utilization</th></tr></thead>
        <tbody>
        <% for(Map<String,Object> row:floorDistribution){ int ft=parseInt(String.valueOf(row.get("cnt"))); int fa=parseInt(String.valueOf(row.get("available"))); int fp=ft>0?((ft-fa)*100/ft):0; %>
        <tr><td><strong>Floor <%= row.get("floor_number") %></strong></td><td><%= ft %></td>
          <td><span class="bp badge-green"><%= fa %></span></td>
          <td><div style="display:flex;align-items:center;gap:8px;"><div style="flex:1;height:6px;background:#e9ecef;border-radius:10px;overflow:hidden;"><div style="height:100%;width:<%= fp %>%;background:var(--primary);border-radius:10px;"></div></div><span style="font-size:.74rem;font-weight:700;color:var(--muted);width:30px;"><%= fp %>%</span></div></td>
        </tr>
        <% } %></tbody></table></div>
        <% }else{ %><div class="empty"><i class="fas fa-building"></i><p>No floor data</p></div><% } %>
      </div>
      <div class="pc">
        <div class="ct"><span><i class="fas fa-fire"></i> Most Booked Rooms</span></div>
        <% if(!mostBookedRooms.isEmpty()){ %><div class="table-responsive"><table class="rt">
        <thead><tr><th>Room</th><th>Type</th><th>Bookings</th><th>Revenue</th></tr></thead>
        <tbody>
        <% for(Map<String,Object> row:mostBookedRooms){ %>
        <tr><td><strong><%= row.get("room_number") %></strong></td>
          <td><span class="bp badge-orange" style="font-size:.68rem;"><%= String.valueOf(row.get("room_type")).replace("_"," ") %></span></td>
          <td><span class="bp badge-blue"><%= row.get("booking_count") %></span></td>
          <td style="font-weight:600;">LKR <%= row.get("total_earned") %></td></tr>
        <% } %></tbody></table></div>
        <% }else{ %><div class="empty"><i class="fas fa-bed"></i><p>No booking data</p></div><% } %>
      </div>
    </div>
    <div class="pc">
      <div class="ct"><span><i class="fas fa-table"></i> Room Type Summary</span></div>
      <% if(!roomTypes.isEmpty()){ %><div class="table-responsive"><table class="rt">
      <thead><tr><th>Room Type</th><th>Total</th><th>Available</th><th>Occupied</th><th>Avg Price</th><th>Occupancy</th></tr></thead>
      <tbody>
      <% for(Map<String,Object> row:roomTypes){ int rt2=parseInt(String.valueOf(row.get("cnt"))); int ro=parseInt(String.valueOf(row.get("occupied"))); int rp3=rt2>0?(ro*100/rt2):0; %>
      <tr><td><strong><%= String.valueOf(row.get("room_type")).replace("_"," ") %></strong></td><td><%= rt2 %></td>
        <td><span class="bp badge-green"><%= row.get("available") %></span></td>
        <td><span class="bp badge-blue"><%= ro %></span></td>
        <td>LKR <%= row.get("avg_price") %></td>
        <td><div style="display:flex;align-items:center;gap:8px;"><div style="width:80px;height:6px;background:#e9ecef;border-radius:10px;overflow:hidden;"><div style="height:100%;width:<%= rp3 %>%;background:var(--warning);border-radius:10px;"></div></div><span style="font-size:.74rem;font-weight:700;color:var(--dark);"><%= rp3 %>%</span></div></td>
      </tr>
      <% } %></tbody></table></div>
      <% }else{ %><div class="empty"><i class="fas fa-door-open"></i><p>No room data</p></div><% } %>
    </div>
  </div>

  <!-- ════ TAB 5: STAFF ════ -->
  <div class="rp" id="panel-staff">
    <div class="sh">
      <div class="st2"><span class="si si-t"><i class="fas fa-id-badge"></i></span>Staff Engagement Report</div>
      <span class="date-badge"><i class="fas fa-sync-alt"></i> Live Data</span>
    </div>
    <div class="stat-row">
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#0891b2,#0e7490);"><i class="fas fa-user-check"></i></div><div><div class="st-val"><%= activeStaff %></div><div class="st-lbl">Active Staff</div></div></div>
      <% for(Map<String,Object> row:staffByRole){ %>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#7c3aed,#6d28d9);"><i class="fas fa-user-shield"></i></div><div><div class="st-val"><%= row.get("cnt") %></div><div class="st-lbl"><%= row.get("role") %> Role</div></div></div>
      <% } %>
      <div class="stat-tile"><div class="st-ico" style="background:linear-gradient(135deg,#10b981,#059669);"><i class="fas fa-clock"></i></div><div><div class="st-val"><%= recentLogins.size() %></div><div class="st-lbl">Recent Logins</div></div></div>
    </div>
    <div class="g2">
      <div class="pc">
        <div class="ct"><span><i class="fas fa-chart-bar"></i> Staff Reservations Handled</span></div>
        <% if(!staffActivity.isEmpty()){ %><div class="table-responsive"><table class="rt">
        <thead><tr><th>Staff Member</th><th>Role</th><th>Reservations</th><th>Revenue</th><th>Status</th></tr></thead>
        <tbody>
        <% for(Map<String,Object> row:staffActivity){ boolean ia="1".equals(String.valueOf(row.get("active"))); %>
        <tr><td><strong><%= row.get("first_name") %> <%= row.get("last_name") %></strong></td>
          <td><span class="bp badge-teal" style="font-size:.7rem;"><%= row.get("role") %></span></td>
          <td><span class="bp badge-blue"><%= row.get("reservations_handled") %></span></td>
          <td style="font-weight:600;">LKR <%= row.get("revenue_handled") %></td>
          <td><span class="bp <%= ia?"badge-green":"badge-red" %>"><%= ia?"Active":"Inactive" %></span></td></tr>
        <% } %></tbody></table></div>
        <% }else{ %><div class="empty"><i class="fas fa-users-cog"></i><p>No staff activity data</p></div><% } %>
      </div>
      <div style="display:flex;flex-direction:column;gap:20px;">
        <div class="pc">
          <div class="ct"><span><i class="fas fa-file-invoice"></i> Bills Processed per Staff</span></div>
          <% if(!staffBills.isEmpty()){ %><div class="table-responsive"><table class="rt">
          <thead><tr><th>Staff Member</th><th>Bills</th><th>Total Billed</th></tr></thead>
          <tbody>
          <% for(Map<String,Object> row:staffBills){ %>
          <tr><td><strong><%= row.get("first_name") %> <%= row.get("last_name") %></strong>
            <div style="font-size:.72rem;color:var(--muted);"><%= row.get("role") %></div></td>
            <td><span class="bp badge-blue"><%= row.get("bills_count") %></span></td>
            <td style="font-weight:600;">LKR <%= row.get("bills_total") %></td></tr>
          <% } %></tbody></table></div>
          <% }else{ %><div class="empty"><i class="fas fa-file-invoice"></i><p>No billing data</p></div><% } %>
        </div>
        <div class="pc">
          <div class="ct"><span><i class="fas fa-sign-in-alt"></i> Recent Staff Logins</span></div>
          <% if(!recentLogins.isEmpty()){ for(Map<String,Object> row:recentLogins){ String fn=String.valueOf(row.get("first_name")),ln=String.valueOf(row.get("last_name")); %>
          <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--border);">
            <div style="width:36px;height:36px;border-radius:10px;background:linear-gradient(135deg,#0891b2,#0e7490);display:flex;align-items:center;justify-content:center;color:white;font-weight:700;font-size:.85rem;flex-shrink:0;"><%= fn.charAt(0) %><%= ln.charAt(0) %></div>
            <div style="flex:1;"><div style="font-weight:600;font-size:.85rem;"><%= fn %> <%= ln %></div><div style="font-size:.72rem;color:var(--muted);"><%= row.get("role") %></div></div>
            <div style="font-size:.72rem;color:var(--muted);"><i class="fas fa-clock me-1"></i><%= row.get("last_login") %></div>
          </div>
          <% }}else{ %><div class="empty"><i class="fas fa-sign-in-alt"></i><p>No login data</p></div><% } %>
        </div>
      </div>
    </div>
  </div>

</div><!-- /main-content -->

<script>
  // Tab switching
  function showTab(n){
    document.querySelectorAll('.rp').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.rtab').forEach(b=>b.classList.remove('active'));
    document.getElementById('panel-'+n).classList.add('active');
    var b=document.querySelector('[onclick="showTab(\''+n+'\')"]');
    if(b)b.classList.add('active');
    localStorage.setItem('repTab',n);
  }
  (function(){var t=localStorage.getItem('repTab');if(t&&document.getElementById('panel-'+t))showTab(t);})();

  Chart.defaults.font.family="'Poppins',sans-serif";
  Chart.defaults.font.size=12;
  Chart.defaults.color='#6c757d';
  var pal=['#0d6efd','#10b981','#f59e0b','#ef4444','#7c3aed','#0891b2','#ec4899','#84cc16','#f97316'];

  // Revenue line
  new Chart(document.getElementById('revenueChart'),{type:'line',data:{labels:<%= revLabels %>,datasets:[{label:'Revenue (LKR)',data:<%= revData %>,borderColor:'#0d6efd',backgroundColor:'rgba(13,110,253,0.1)',borderWidth:2.5,fill:true,tension:0.4,pointBackgroundColor:'#0d6efd',pointRadius:4,pointHoverRadius:7}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false},tooltip:{callbacks:{label:c=>'LKR '+Number(c.raw).toLocaleString()}}},scales:{x:{grid:{display:false}},y:{grid:{color:'rgba(0,0,0,.05)'},ticks:{callback:v=>'LKR '+Number(v).toLocaleString()}}}}});

  // Payment methods doughnut
  new Chart(document.getElementById('payMethodChart'),{type:'doughnut',data:{labels:<%= pmLabels %>,datasets:[{data:<%= pmData %>,backgroundColor:pal,borderWidth:2,borderColor:'#fff'}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'right',labels:{boxWidth:12,padding:10}},tooltip:{callbacks:{label:c=>c.label+': LKR '+c.raw}}},cutout:'60%'}});

  // Reservations bar
  new Chart(document.getElementById('resvChart'),{type:'bar',data:{labels:<%= resvLabels %>,datasets:[{label:'Total',data:<%= resvTotData %>,backgroundColor:'rgba(13,110,253,0.75)',borderRadius:6},{label:'Cancelled',data:<%= resvCanData %>,backgroundColor:'rgba(239,68,68,0.7)',borderRadius:6}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'top'}},scales:{x:{grid:{display:false}},y:{grid:{color:'rgba(0,0,0,.05)'},ticks:{stepSize:1}}}}});

  // Sources horizontal bar
  new Chart(document.getElementById('srcChart'),{type:'bar',data:{labels:<%= srcLabels %>,datasets:[{label:'Bookings',data:<%= srcData %>,backgroundColor:pal,borderRadius:6}]},options:{responsive:true,maintainAspectRatio:false,indexAxis:'y',plugins:{legend:{display:false}},scales:{x:{grid:{color:'rgba(0,0,0,.05)'},ticks:{stepSize:1}},y:{grid:{display:false}}}}});

  // Country bar
  new Chart(document.getElementById('countryChart'),{type:'bar',data:{labels:<%= ctryLabels %>,datasets:[{label:'Guests',data:<%= ctryData %>,backgroundColor:pal,borderRadius:6}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{grid:{display:false}},y:{grid:{color:'rgba(0,0,0,.05)'},ticks:{stepSize:1}}}}});

  // Room type doughnut
  new Chart(document.getElementById('roomTypeChart'),{type:'doughnut',data:{labels:<%= rtLabels %>,datasets:[{data:<%= rtData %>,backgroundColor:pal,borderWidth:2,borderColor:'#fff'}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom',labels:{boxWidth:12,padding:8}}},cutout:'55%'}});

  // Room view doughnut
  new Chart(document.getElementById('roomViewChart'),{type:'doughnut',data:{labels:<%= rvLabels %>,datasets:[{data:<%= rvData %>,backgroundColor:['#0d6efd','#10b981','#f59e0b','#ef4444','#7c3aed'],borderWidth:2,borderColor:'#fff'}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom',labels:{boxWidth:12,padding:8}}},cutout:'55%'}});

  // Occupancy ring
  (function(){var p=<%= occupancyPct %>;new Chart(document.getElementById('occupancyChart'),{type:'doughnut',data:{datasets:[{data:[p,100-p],backgroundColor:['#0d6efd','#e9ecef'],borderWidth:0}]},options:{responsive:false,cutout:'72%',plugins:{legend:{display:false},tooltip:{enabled:false}}}});})();
</script>
</body>
</html>