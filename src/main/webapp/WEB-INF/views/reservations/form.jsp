<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
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
        :root {
            --primary: #0d6efd; --primary-dark: #0b5ed7; --primary-light: #e8f0fe;
            --success: #198754; --success-light: #d4edda;
            --warning: #ffc107; --danger: #dc3545; --danger-light: #f8d7da;
            --gray-100: #f8f9fa; --gray-200: #e9ecef; --gray-300: #dee2e6;
            --gray-600: #6c757d; --dark: #212529;
            --radius-sm: 8px; --radius-md: 12px; --radius-lg: 16px;
            --shadow-md: 0 4px 20px rgba(0,0,0,0.08);
            --shadow-lg: 0 10px 40px rgba(13,110,253,0.15);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: #f0f4f8; }

        .form-wizard-wrap { max-width: 980px; margin: 0 auto; padding: 24px 16px 80px; }

        /* ── Wizard Steps ── */
        .wizard-steps { display: flex; align-items: center; justify-content: center; margin-bottom: 32px; }
        .step {
            display: flex; align-items: center; gap: 10px; padding: 10px 18px;
            border-radius: 30px; font-size: 0.85rem; font-weight: 600;
            color: var(--gray-600); background: white; border: 2px solid var(--gray-300);
            transition: all 0.3s;
        }
        .step.active { background: var(--primary); border-color: var(--primary); color: white; box-shadow: 0 4px 15px rgba(13,110,253,0.3); }
        .step.done   { background: var(--success-light); border-color: var(--success); color: var(--success); }
        .step-num {
            width: 24px; height: 24px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; font-size: 0.75rem;
            font-weight: 700; background: rgba(255,255,255,0.3);
        }
        .step.active .step-num { background: rgba(255,255,255,0.25); }
        .step.done   .step-num { background: var(--success); color: white; }
        .step-line { flex: 1; height: 2px; background: var(--gray-300); max-width: 60px; }
        .step-line.done { background: var(--success); }

        /* ── Cards ── */
        .form-card { background: white; border-radius: var(--radius-lg); box-shadow: var(--shadow-md); margin-bottom: 24px; overflow: hidden; border: 1px solid rgba(13,110,253,0.06); transition: box-shadow 0.2s; }
        .form-card:hover { box-shadow: var(--shadow-lg); }
        .card-head { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; padding: 16px 24px; display: flex; align-items: center; gap: 12px; }
        .card-head .icon-wrap { width: 38px; height: 38px; background: rgba(255,255,255,0.2); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; font-size: 1rem; }
        .card-head h4 { margin: 0; font-size: 1rem; font-weight: 600; }
        .card-head p  { margin: 2px 0 0; font-size: 0.78rem; opacity: 0.85; }
        .card-body { padding: 24px; }

        /* ── Form controls ── */
        .form-label { font-weight: 500; font-size: 0.85rem; color: #495057; margin-bottom: 6px; }
        .required-star { color: var(--danger); }
        .form-control, .form-select {
            border-radius: var(--radius-sm); border: 1.5px solid var(--gray-300);
            font-size: 0.9rem; padding: 10px 14px; transition: all 0.2s;
            font-family: 'Poppins', sans-serif;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary); box-shadow: 0 0 0 3px rgba(13,110,253,0.12); outline: none;
        }
        .form-control.is-invalid { border-color: var(--danger); }

        /* ── Guest ── */
        .guest-mode-toggle { display: flex; background: var(--gray-100); border-radius: var(--radius-md); padding: 4px; margin-bottom: 20px; gap: 4px; }
        .guest-mode-btn { flex: 1; padding: 9px 16px; border: none; border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.2s; background: transparent; color: var(--gray-600); }
        .guest-mode-btn.active { background: white; color: var(--primary); box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .search-wrap { position: relative; }
        .search-results { position: absolute; top: 100%; left: 0; right: 0; z-index: 1050; background: white; border: 1.5px solid var(--primary); border-top: none; border-radius: 0 0 var(--radius-md) var(--radius-md); max-height: 260px; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.15); display: none; }
        .sr-item { padding: 12px 16px; cursor: pointer; transition: background 0.15s; border-bottom: 1px solid var(--gray-200); display: flex; align-items: center; gap: 12px; }
        .sr-item:hover { background: var(--primary-light); }
        .sr-item:last-child { border-bottom: none; }
        .sr-avatar { width: 36px; height: 36px; background: linear-gradient(135deg, var(--primary), var(--primary-dark)); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 0.85rem; flex-shrink: 0; }
        .sr-name { font-weight: 600; font-size: 0.88rem; color: var(--dark); }
        .sr-info { font-size: 0.77rem; color: var(--gray-600); }
        .selected-guest-card { display: none; background: linear-gradient(135deg, #e8f4fd, #f0f8ff); border: 2px solid var(--primary); border-radius: var(--radius-md); padding: 14px 16px; position: relative; }
        .selected-guest-card.show { display: flex; align-items: center; gap: 14px; }
        .sg-avatar { width: 46px; height: 46px; background: linear-gradient(135deg, var(--primary), var(--primary-dark)); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 1.1rem; flex-shrink: 0; }
        .sg-name { font-weight: 700; font-size: 0.95rem; color: var(--dark); }
        .sg-info { font-size: 0.8rem; color: var(--gray-600); margin-top: 2px; }
        .sg-clear { position: absolute; top: 10px; right: 12px; cursor: pointer; color: var(--danger); font-size: 1rem; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; border-radius: 50%; transition: background 0.2s; }
        .sg-clear:hover { background: var(--danger-light); }

        /* ── Capacity ── */
        .capacity-checker { background: var(--gray-100); border-radius: var(--radius-md); padding: 14px 16px; margin-top: 16px; border: 1.5px solid var(--gray-300); display: none; }
        .capacity-checker.show { display: block; }
        .capacity-bar-wrap { background: var(--gray-200); border-radius: 20px; height: 8px; overflow: hidden; margin: 8px 0 6px; }
        .capacity-bar { height: 100%; border-radius: 20px; transition: width 0.4s ease, background 0.3s; background: var(--success); }
        .capacity-bar.warn { background: var(--warning); }
        .capacity-bar.over { background: var(--danger); }
        .capacity-label { font-size: 0.82rem; font-weight: 600; }
        .capacity-alert { display: none; background: var(--danger-light); border: 1.5px solid var(--danger); border-radius: var(--radius-sm); padding: 10px 14px; font-size: 0.84rem; color: #721c24; margin-top: 10px; align-items: center; gap: 8px; }
        .capacity-alert.show { display: flex; }

        /* ── Room Section ── */
        .room-section { margin-top: 20px; }
        .room-section-label {
            display: flex; align-items: center; gap: 10px;
            font-size: 0.9rem; font-weight: 700; color: var(--dark);
            padding: 10px 14px; background: var(--gray-100);
            border-radius: var(--radius-md); margin-bottom: 14px;
            border: 1.5px solid var(--gray-300);
        }
        .room-section-label .slot-badge {
            background: var(--primary); color: white;
            border-radius: 20px; padding: 2px 10px; font-size: 0.75rem;
        }
        .room-section-label .slot-badge.optional {
            background: var(--gray-600);
        }
        .room-tabs {
            display: flex; background: var(--gray-100);
            border-radius: var(--radius-md); padding: 4px; gap: 4px; margin-bottom: 16px;
        }
        .room-tab-btn {
            flex: 1; padding: 9px 14px; border: none; border-radius: var(--radius-sm);
            font-size: 0.83rem; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: transparent; color: var(--gray-600);
            display: flex; align-items: center; justify-content: center; gap: 7px;
        }
        .room-tab-btn.active {
            background: white; color: var(--primary); box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .room-tab-btn .tab-check { color: var(--success); font-size: 0.75rem; display: none; }
        .room-tab-btn.has-room .tab-check { display: inline; }

        /* ── Filters ── */
        .room-section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 10px; }
        .room-filters { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
        .filter-chip { padding: 6px 12px; border-radius: 20px; border: 1.5px solid var(--gray-300); background: white; font-size: 0.78rem; font-weight: 600; cursor: pointer; transition: all 0.2s; color: var(--gray-600); }
        .filter-chip.active, .filter-chip:hover { background: var(--primary); border-color: var(--primary); color: white; }
        .room-search-box { position: relative; }
        .room-search-box input { border-radius: 20px; padding: 7px 14px 7px 34px; border: 1.5px solid var(--gray-300); font-size: 0.8rem; width: 180px; transition: all 0.2s; font-family: 'Poppins',sans-serif; }
        .room-search-box input:focus { border-color: var(--primary); width: 220px; box-shadow: 0 0 0 3px rgba(13,110,253,0.1); outline: none; }
        .room-search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--gray-600); font-size: 0.78rem; }

        /* ── Room Grid ── */
        .rooms-loading { text-align: center; padding: 40px 20px; color: var(--gray-600); }
        .rooms-loading .spinner-border { width: 2.5rem; height: 2.5rem; border-width: 3px; }
        .room-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); gap: 12px; }
        .room-card { border: 2px solid var(--gray-300); border-radius: var(--radius-md); padding: 14px; cursor: pointer; transition: all 0.25s; position: relative; background: white; }
        .room-card:hover { border-color: var(--primary); transform: translateY(-3px); box-shadow: 0 8px 25px rgba(13,110,253,0.15); }
        .room-card.selected { border-color: var(--primary); background: var(--primary-light); box-shadow: 0 4px 20px rgba(13,110,253,0.2); }
        .room-card.selected::after { content: '\f00c'; font-family: 'Font Awesome 6 Free'; font-weight: 900; position: absolute; top: 9px; right: 9px; width: 20px; height: 20px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.6rem; line-height: 20px; text-align: center; }
        .room-type-badge { display: inline-block; padding: 3px 9px; border-radius: 12px; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 7px; }
        .badge-standard   { background: #e3f2fd; color: #1565c0; }
        .badge-deluxe     { background: #f3e5f5; color: #7b1fa2; }
        .badge-suite      { background: #fff8e1; color: #f57f17; }
        .badge-executive  { background: #e8f5e9; color: #2e7d32; }
        .badge-family     { background: #fce4ec; color: #c62828; }
        .badge-presidential { background: #fdf3e7; color: #e65100; }
        .badge-other      { background: #eceff1; color: #455a64; }
        .room-number { font-size: 1.15rem; font-weight: 700; color: var(--dark); }
        .room-floor  { font-size: 0.76rem; color: var(--gray-600); margin-top: 2px; }
        .room-price  { font-weight: 700; color: var(--primary); font-size: 0.95rem; margin-top: 7px; }
        .room-price small { font-size: 0.7rem; color: var(--gray-600); font-weight: 400; }
        .room-meta   { display: flex; gap: 7px; margin-top: 7px; flex-wrap: wrap; }
        .room-tag    { font-size: 0.7rem; padding: 2px 7px; background: var(--gray-100); border-radius: 10px; color: var(--gray-600); display: flex; align-items: center; gap: 3px; }
        .room-detail-btn { margin-top: 10px; width: 100%; padding: 6px; border-radius: var(--radius-sm); border: 1.5px solid var(--primary); background: transparent; color: var(--primary); font-size: 0.78rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .room-detail-btn:hover { background: var(--primary); color: white; }
        .no-rooms-msg { grid-column: 1/-1; text-align: center; padding: 40px 20px; color: var(--gray-600); }
        .no-rooms-msg i { font-size: 3rem; opacity: 0.3; margin-bottom: 10px; display: block; }
        .need-dates-notice { text-align: center; padding: 30px 20px; color: var(--gray-600); }
        .need-dates-notice i { font-size: 2.2rem; opacity: 0.4; display: block; margin-bottom: 8px; }

        /* ── Selected Room Bar ── */
        .selected-room-bar { display: none; background: linear-gradient(135deg, var(--primary-light), #f0f8ff); border: 2px solid var(--primary); border-radius: var(--radius-md); padding: 11px 14px; margin-top: 14px; align-items: center; gap: 12px; }
        .selected-room-bar.show { display: flex; }
        .srb-icon { width: 38px; height: 38px; background: var(--primary); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; color: white; font-size: 1.1rem; flex-shrink: 0; }
        .srb-name { font-weight: 700; color: var(--dark); font-size: 0.9rem; }
        .srb-info { font-size: 0.78rem; color: var(--gray-600); margin-top: 2px; }
        .srb-clear { margin-left: auto; cursor: pointer; color: var(--danger); padding: 4px 8px; border-radius: 6px; font-size: 0.78rem; font-weight: 600; border: 1.5px solid var(--danger); transition: all 0.2s; white-space: nowrap; }
        .srb-clear:hover { background: var(--danger); color: white; }

        /* ── Bill Preview ── */
        .bill-preview { background: linear-gradient(135deg, #f8f9fa, #fff); border: 1.5px solid var(--gray-300); border-radius: var(--radius-md); padding: 18px 20px; margin-top: 20px; }
        .bill-preview-title { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--primary); margin-bottom: 14px; display: flex; align-items: center; gap: 8px; }
        .bill-row { display: flex; justify-content: space-between; padding: 5px 0; font-size: 0.84rem; color: var(--dark); border-bottom: 1px dashed var(--gray-200); }
        .bill-row:last-child { border-bottom: none; }
        .bill-row.total { font-weight: 700; font-size: 0.97rem; color: var(--primary); border-top: 2px solid var(--gray-300); margin-top: 8px; padding-top: 10px; border-bottom: none; }
        .bill-row .label { color: var(--gray-600); }
        .bill-section-divider { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--gray-600); padding: 6px 0 4px; border-bottom: 1px dashed var(--gray-300); margin-top: 4px; }

        /* ── Room Add Button ── */
        .add-room-btn {
            display: flex; align-items: center; gap: 8px; justify-content: center;
            padding: 12px; border: 2px dashed var(--primary); border-radius: var(--radius-md);
            background: var(--primary-light); color: var(--primary); font-weight: 600;
            font-size: 0.85rem; cursor: pointer; transition: all 0.2s; margin-top: 14px;
            width: 100%;
        }
        .add-room-btn:hover { background: var(--primary); color: white; }

        /* ── Misc ── */
        .back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--gray-600); font-size: 0.85rem; font-weight: 500; text-decoration: none; padding: 7px 14px; border-radius: 20px; background: white; border: 1.5px solid var(--gray-300); margin-bottom: 20px; transition: all 0.2s; }
        .back-link:hover { color: var(--primary); border-color: var(--primary); background: var(--primary-light); }
        .err-box { background: var(--danger-light); color: #721c24; border: none; border-radius: var(--radius-md); padding: 12px 18px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .info-tip { background: #e8f4fd; border: 1.5px solid #bee5fb; border-radius: var(--radius-sm); padding: 9px 14px; font-size: 0.81rem; color: #0c5460; display: flex; align-items: center; gap: 8px; margin-top: 10px; }
        .btn-submit { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; border: none; border-radius: var(--radius-md); padding: 13px 34px; font-size: 0.95rem; font-weight: 700; cursor: pointer; transition: all 0.2s; font-family: 'Poppins', sans-serif; }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(13,110,253,0.35); }
        .btn-cancel { background: var(--gray-100); color: var(--gray-600); border: 1.5px solid var(--gray-300); border-radius: var(--radius-md); padding: 12px 28px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.2s; font-family: 'Poppins', sans-serif; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; }
        .btn-cancel:hover { background: var(--gray-200); color: var(--dark); }

        /* ── Modal ── */
        .modal-content { border-radius: var(--radius-lg); border: none; }
        .modal-header { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; border-radius: var(--radius-lg) var(--radius-lg) 0 0; padding: 16px 24px; }
        .modal-header .btn-close { filter: invert(1); }
        .room-detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-top: 16px; }
        .rd-item { background: var(--gray-100); border-radius: var(--radius-sm); padding: 12px; }
        .rd-label { font-size: 0.75rem; color: var(--gray-600); font-weight: 500; margin-bottom: 4px; }
        .rd-value { font-size: 0.95rem; font-weight: 600; color: var(--dark); }
        .amenity-tag { display: inline-block; background: var(--primary-light); color: var(--primary); border-radius: 10px; padding: 4px 10px; font-size: 0.78rem; font-weight: 500; margin: 3px; }

        @media (max-width: 768px) {
            .room-grid { grid-template-columns: 1fr; }
            .room-filters { flex-direction: column; align-items: flex-start; }
            .wizard-steps { gap: 4px; }
            .step span { display: none; }
        }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    ReservationDTO reservation = (ReservationDTO) request.getAttribute("reservation");
    GuestDTO selectedGuest     = (GuestDTO) request.getAttribute("selectedGuest");
    boolean isEdit = (reservation != null && reservation.getId() != null);

    String roleBase   = user.isAdmin() ? "/admin/reservations" : "/staff/reservations";
    String formAction = request.getContextPath() + roleBase + (isEdit ? "/update" : "/save");
    String backUrl    = request.getContextPath() + roleBase;
    String errorMsg   = (String) request.getAttribute("error");
    String today      = LocalDate.now().toString();

    // Guest pre-fill
    String preGuestId = "", preGuestName = "", preGuestInfo = "", preGuestInitials = "";
    if (isEdit && reservation.getGuestId() != null) {
        preGuestId   = String.valueOf(reservation.getGuestId());
        preGuestName = reservation.getGuestName() != null ? reservation.getGuestName() : "Guest #" + reservation.getGuestId();
        String em = reservation.getGuestEmail() != null ? reservation.getGuestEmail() : "";
        String ph = reservation.getGuestPhone() != null ? " · " + reservation.getGuestPhone() : "";
        String gn = reservation.getGuestNumber() != null ? " · #" + reservation.getGuestNumber() : "";
        preGuestInfo = em + ph + gn;
        String[] np = preGuestName.split(" ");
        preGuestInitials = np.length >= 2
                ? String.valueOf(np[0].charAt(0)) + String.valueOf(np[np.length-1].charAt(0))
                : preGuestName.substring(0, Math.min(2, preGuestName.length())).toUpperCase();
    } else if (selectedGuest != null) {
        preGuestId   = String.valueOf(selectedGuest.getId());
        preGuestName = selectedGuest.getFullName() != null ? selectedGuest.getFullName() : "";
        String em = selectedGuest.getEmail()  != null ? selectedGuest.getEmail()  : "";
        String ph = selectedGuest.getPhone()  != null ? " · " + selectedGuest.getPhone()  : "";
        String gn = selectedGuest.getGuestNumber() != null ? " · #" + selectedGuest.getGuestNumber() : "";
        preGuestInfo = em + ph + gn;
        if (selectedGuest.getFirstName() != null && selectedGuest.getLastName() != null)
            preGuestInitials = String.valueOf(selectedGuest.getFirstName().charAt(0)) + String.valueOf(selectedGuest.getLastName().charAt(0));
    }
    boolean hasPreGuest = !preGuestId.isEmpty();

    String preRoomId    = isEdit && reservation.getRoomId()    != null ? String.valueOf(reservation.getRoomId())    : "";
    String preRoomNum   = isEdit && reservation.getRoomNumber() != null ? reservation.getRoomNumber() : "";
    String preRoomType  = isEdit && reservation.getRoomType()   != null ? reservation.getRoomType()   : "";
    String preRoomPrice = isEdit && reservation.getRoomPrice()  != null ? reservation.getRoomPrice().toPlainString() : "0";
    String preCheckIn   = isEdit && reservation.getCheckInDate()  != null ? reservation.getCheckInDate().toString()  : "";
    String preCheckOut  = isEdit && reservation.getCheckOutDate() != null ? reservation.getCheckOutDate().toString() : "";
%>

<div class="form-wizard-wrap">

    <a href="<%= backUrl %>" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Reservations
    </a>

    <!-- Progress -->
    <div class="wizard-steps">
        <div class="step active" id="step-1"><div class="step-num">1</div><span>Guest</span></div>
        <div class="step-line" id="line-1"></div>
        <div class="step" id="step-2"><div class="step-num">2</div><span>Stay Details</span></div>
        <div class="step-line" id="line-2"></div>
        <div class="step" id="step-3"><div class="step-num">3</div><span>Rooms</span></div>
        <div class="step-line" id="line-3"></div>
        <div class="step" id="step-4"><div class="step-num">4</div><span>Confirm</span></div>
    </div>

    <% if (errorMsg != null) { %>
    <div class="err-box"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% } %>

    <form id="resForm" method="POST" action="<%= formAction %>" novalidate>
        <% if (isEdit) { %><input type="hidden" name="id" value="<%= reservation.getId() %>"><% } %>

        <!-- ══ STEP 1: GUEST ══ -->
        <div class="form-card" id="card-guest">
            <div class="card-head">
                <div class="icon-wrap"><i class="fas fa-user"></i></div>
                <div><h4>Guest Information</h4><p>Search for existing guest or add new</p></div>
            </div>
            <div class="card-body">
                <% if (!isEdit) { %>
                <div class="guest-mode-toggle">
                    <button type="button" class="guest-mode-btn active" id="tab-existing" onclick="switchMode('existing')"><i class="fas fa-search me-2"></i>Existing Guest</button>
                    <button type="button" class="guest-mode-btn" id="tab-new" onclick="switchMode('new')"><i class="fas fa-user-plus me-2"></i>New Guest</button>
                </div>
                <input type="hidden" name="guestMode" id="guestMode" value="existing">
                <div id="panelExisting">
                    <div class="search-wrap mb-3">
                        <label class="form-label">Search Guest <span class="required-star">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="fas fa-search text-primary"></i></span>
                            <input type="text" id="guestSearchInput" class="form-control border-start-0" placeholder="Name, email, phone or guest #..." autocomplete="off">
                            <button type="button" class="btn btn-primary" onclick="doSearch(document.getElementById('guestSearchInput').value)">Search</button>
                        </div>
                        <div class="search-results" id="searchResults"></div>
                    </div>
                    <input type="hidden" name="guestId" id="guestId" value="<%= hasPreGuest ? preGuestId : "" %>">
                    <div class="selected-guest-card <%= hasPreGuest ? "show" : "" %>" id="selectedGuest">
                        <div class="sg-avatar" id="sgAvatar"><%= hasPreGuest ? preGuestInitials : "" %></div>
                        <div>
                            <div class="sg-name" id="sgName"><%= hasPreGuest ? preGuestName : "" %></div>
                            <div class="sg-info" id="sgInfo"><%= hasPreGuest ? preGuestInfo : "" %></div>
                        </div>
                        <span class="sg-clear" onclick="clearGuest()"><i class="fas fa-times"></i></span>
                    </div>
                    <div class="info-tip"><i class="fas fa-info-circle"></i> Type at least 2 characters to search, then click a result.</div>
                </div>
                <div id="panelNew" style="display:none;">
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label">First Name <span class="required-star">*</span></label><input type="text" name="firstName" id="newFirstName" class="form-control" placeholder="First name"></div>
                        <div class="col-md-6"><label class="form-label">Last Name <span class="required-star">*</span></label><input type="text" name="lastName" id="newLastName" class="form-control" placeholder="Last name"></div>
                        <div class="col-md-6"><label class="form-label">Email</label><input type="email" name="guestEmail" class="form-control" placeholder="guest@email.com"></div>
                        <div class="col-md-6"><label class="form-label">Phone</label><input type="text" name="guestPhone" class="form-control" placeholder="+94 XX XXX XXXX"></div>
                        <div class="col-md-6">
                            <label class="form-label">ID Type</label>
                            <select name="idCardType" class="form-select">
                                <option value="">-- Select --</option>
                                <option value="PASSPORT">Passport</option>
                                <option value="NATIONAL_ID">National ID</option>
                                <option value="DRIVERS_LICENSE">Driver's License</option>
                            </select>
                        </div>
                        <div class="col-md-6"><label class="form-label">ID Number</label><input type="text" name="idCardNumber" class="form-control" placeholder="ID number"></div>
                        <div class="col-12"><label class="form-label">Address</label><input type="text" name="address" class="form-control" placeholder="Street address"></div>
                        <div class="col-md-4"><label class="form-label">City</label><input type="text" name="city" class="form-control"></div>
                        <div class="col-md-4"><label class="form-label">Country</label><input type="text" name="country" class="form-control"></div>
                        <div class="col-md-4"><label class="form-label">Postal Code</label><input type="text" name="postalCode" class="form-control"></div>
                    </div>
                    <div class="info-tip mt-3"><i class="fas fa-info-circle"></i> A new guest profile will be created on submission.</div>
                </div>
                <% } else { %>
                <input type="hidden" name="guestMode" value="existing">
                <input type="hidden" name="guestId" value="<%= preGuestId %>">
                <div class="selected-guest-card show">
                    <div class="sg-avatar"><%= preGuestInitials %></div>
                    <div><div class="sg-name"><%= preGuestName %></div><div class="sg-info"><%= preGuestInfo %></div></div>
                </div>
                <% } %>
            </div>
        </div>

        <!-- ══ STEP 2: STAY DETAILS ══ -->
        <div class="form-card" id="card-stay">
            <div class="card-head">
                <div class="icon-wrap"><i class="fas fa-calendar-alt"></i></div>
                <div><h4>Stay Details</h4><p>Dates and guest count — rooms load after both dates are set</p></div>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Check-in Date <span class="required-star">*</span></label>
                        <input type="date" name="checkInDate" id="checkInDate" class="form-control" required min="<%= today %>" value="<%= preCheckIn %>" onchange="onDatesChange()">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Check-out Date <span class="required-star">*</span></label>
                        <input type="date" name="checkOutDate" id="checkOutDate" class="form-control" required min="<%= today %>" value="<%= preCheckOut %>" onchange="onDatesChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Adults <span class="required-star">*</span></label>
                        <input type="number" name="adults" id="adults" class="form-control" min="1" max="20" required value="<%= isEdit && reservation.getAdults() != null ? reservation.getAdults() : 1 %>" onchange="onGuestCountChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Children</label>
                        <input type="number" name="children" id="children" class="form-control" min="0" max="20" value="<%= isEdit && reservation.getChildren() != null ? reservation.getChildren() : 0 %>" onchange="onGuestCountChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Discount ($)</label>
                        <input type="number" name="discountAmount" id="discountAmount" class="form-control" min="0" step="0.01" value="<%= isEdit && reservation.getDiscountAmount() != null ? reservation.getDiscountAmount() : "0" %>" onchange="recalcBill()">
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
                        <textarea name="specialRequests" class="form-control" rows="2" placeholder="Dietary needs, extra pillows, late check-in..."><%= isEdit && reservation.getSpecialRequests() != null ? reservation.getSpecialRequests() : "" %></textarea>
                    </div>
                </div>

                <!-- Capacity checker -->
                <div class="capacity-checker" id="capacityChecker">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;">
                        <span class="form-label mb-0" style="font-size:0.82rem;">Combined Guest Count vs Room Capacity</span>
                        <span class="capacity-label" id="capacityText">—</span>
                    </div>
                    <div class="capacity-bar-wrap"><div class="capacity-bar" id="capacityBar" style="width:0%"></div></div>
                </div>
                <div class="capacity-alert" id="capacityAlert">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span id="capacityAlertMsg">Guest count exceeds room capacity.</span>
                </div>
            </div>
        </div>

        <!-- ══ STEP 3: ROOM SELECTION ══ -->
        <div class="form-card" id="card-room">
            <div class="card-head">
                <div class="icon-wrap"><i class="fas fa-door-open"></i></div>
                <div>
                    <h4>Room Selection <span style="opacity:0.7;font-weight:400;font-size:0.85rem;">(up to 2 rooms per reservation)</span></h4>
                    <p>Only rooms available for your chosen dates are shown. Both check-in & check-out dates are treated as occupied.</p>
                </div>
            </div>
            <div class="card-body">

                <!-- Hidden inputs for up to 2 rooms -->
                <input type="hidden" name="roomId"  id="roomId"  value="<%= preRoomId %>">
                <input type="hidden" name="roomId2" id="roomId2" value="">

                <!-- Room tab switcher -->
                <div class="room-tabs">
                    <button type="button" class="room-tab-btn active" id="tab-room1" onclick="switchRoomTab(1)">
                        <i class="fas fa-door-closed"></i> Room 1
                        <span class="tab-check" id="check-room1"><i class="fas fa-check-circle"></i></span>
                        <span style="font-size:0.72rem;color:var(--danger);font-weight:700;" id="req-room1">(Required)</span>
                    </button>
                    <button type="button" class="room-tab-btn" id="tab-room2" onclick="switchRoomTab(2)">
                        <i class="fas fa-door-open"></i> Room 2
                        <span class="tab-check" id="check-room2"><i class="fas fa-check-circle"></i></span>
                        <span style="font-size:0.72rem;color:var(--gray-600);font-weight:700;" id="req-room2">(Optional)</span>
                    </button>
                </div>

                <!-- ROOM 1 PANEL -->
                <div id="panel-room1">
                    <div class="room-section-header">
                        <div class="room-filters" id="typeFilters1">
                            <span style="font-size:0.8rem;font-weight:600;color:var(--gray-600);align-self:center;">Filter:</span>
                            <span class="filter-chip active" data-slot="1" data-type="ALL"          onclick="filterRooms(1,'ALL',this)">All</span>
                            <span class="filter-chip"        data-slot="1" data-type="STANDARD"     onclick="filterRooms(1,'STANDARD',this)">Standard</span>
                            <span class="filter-chip"        data-slot="1" data-type="DELUXE"       onclick="filterRooms(1,'DELUXE',this)">Deluxe</span>
                            <span class="filter-chip"        data-slot="1" data-type="SUITE"        onclick="filterRooms(1,'SUITE',this)">Suite</span>
                            <span class="filter-chip"        data-slot="1" data-type="EXECUTIVE"    onclick="filterRooms(1,'EXECUTIVE',this)">Executive</span>
                            <span class="filter-chip"        data-slot="1" data-type="FAMILY"       onclick="filterRooms(1,'FAMILY',this)">Family</span>
                            <span class="filter-chip"        data-slot="1" data-type="PRESIDENTIAL" onclick="filterRooms(1,'PRESIDENTIAL',this)">Presidential</span>
                        </div>
                        <div class="room-search-box"><i class="fas fa-search"></i><input type="text" id="roomSearch1" placeholder="Room number..." oninput="filterRooms(1,null,null)"></div>
                    </div>
                    <div id="roomsContainer1">
                        <div class="need-dates-notice"><i class="fas fa-calendar-alt"></i><strong>Fill in check-in and check-out dates above</strong><br><span style="font-size:0.84rem;">Available rooms will appear here.</span></div>
                    </div>
                    <div class="selected-room-bar" id="selectedRoomBar1">
                        <div class="srb-icon"><i class="fas fa-check"></i></div>
                        <div><div class="srb-name" id="srbName1">—</div><div class="srb-info" id="srbInfo1">—</div></div>
                        <span class="srb-clear" onclick="clearRoom(1)"><i class="fas fa-times me-1"></i>Change</span>
                    </div>
                </div>

                <!-- ROOM 2 PANEL -->
                <div id="panel-room2" style="display:none;">
                    <div class="room-section-header">
                        <div class="room-filters" id="typeFilters2">
                            <span style="font-size:0.8rem;font-weight:600;color:var(--gray-600);align-self:center;">Filter:</span>
                            <span class="filter-chip active" data-slot="2" data-type="ALL"          onclick="filterRooms(2,'ALL',this)">All</span>
                            <span class="filter-chip"        data-slot="2" data-type="STANDARD"     onclick="filterRooms(2,'STANDARD',this)">Standard</span>
                            <span class="filter-chip"        data-slot="2" data-type="DELUXE"       onclick="filterRooms(2,'DELUXE',this)">Deluxe</span>
                            <span class="filter-chip"        data-slot="2" data-type="SUITE"        onclick="filterRooms(2,'SUITE',this)">Suite</span>
                            <span class="filter-chip"        data-slot="2" data-type="EXECUTIVE"    onclick="filterRooms(2,'EXECUTIVE',this)">Executive</span>
                            <span class="filter-chip"        data-slot="2" data-type="FAMILY"       onclick="filterRooms(2,'FAMILY',this)">Family</span>
                            <span class="filter-chip"        data-slot="2" data-type="PRESIDENTIAL" onclick="filterRooms(2,'PRESIDENTIAL',this)">Presidential</span>
                        </div>
                        <div class="room-search-box"><i class="fas fa-search"></i><input type="text" id="roomSearch2" placeholder="Room number..." oninput="filterRooms(2,null,null)"></div>
                    </div>
                    <div id="roomsContainer2">
                        <div class="need-dates-notice"><i class="fas fa-calendar-alt"></i><strong>Select Room 1 first, then choose Room 2 here</strong><br><span style="font-size:0.84rem;">Room 2 will exclude your already-selected Room 1.</span></div>
                    </div>
                    <div class="selected-room-bar" id="selectedRoomBar2">
                        <div class="srb-icon"><i class="fas fa-check"></i></div>
                        <div><div class="srb-name" id="srbName2">—</div><div class="srb-info" id="srbInfo2">—</div></div>
                        <span class="srb-clear" onclick="clearRoom(2)"><i class="fas fa-times me-1"></i>Remove Room 2</span>
                    </div>
                </div>

                <!-- Bill preview -->
                <div class="bill-preview" id="billPreview" style="display:none;">
                    <div class="bill-preview-title"><i class="fas fa-receipt"></i> Bill Preview</div>
                    <!-- Room 1 section -->
                    <div id="bill-room1-section">
                        <div class="bill-section-divider">Room 1</div>
                        <div class="bill-row"><span class="label">Room</span><span id="b-room1">—</span></div>
                        <div class="bill-row"><span class="label">Rate/night</span><span id="b-rate1">—</span></div>
                        <div class="bill-row"><span class="label">Room 1 Charges</span><span id="b-charges1">—</span></div>
                    </div>
                    <!-- Room 2 section (shown only when room 2 is selected) -->
                    <div id="bill-room2-section" style="display:none;">
                        <div class="bill-section-divider">Room 2</div>
                        <div class="bill-row"><span class="label">Room</span><span id="b-room2">—</span></div>
                        <div class="bill-row"><span class="label">Rate/night</span><span id="b-rate2">—</span></div>
                        <div class="bill-row"><span class="label">Room 2 Charges</span><span id="b-charges2">—</span></div>
                    </div>
                    <!-- Totals -->
                    <div class="bill-section-divider" style="margin-top:8px;">Summary</div>
                    <div class="bill-row"><span class="label">Nights</span><span id="b-nights">—</span></div>
                    <div class="bill-row"><span class="label">Total Room Charges</span><span id="b-total-charges">—</span></div>
                    <div class="bill-row"><span class="label">Tax (12%)</span><span id="b-tax">—</span></div>
                    <div class="bill-row"><span class="label">Discount</span><span id="b-discount">—</span></div>
                    <div class="bill-row total"><span>Total Amount</span><span id="b-total">—</span></div>
                </div>
            </div>
        </div>

        <!-- Submit -->
        <div class="d-flex gap-3 justify-content-end align-items-center">
            <a href="<%= backUrl %>" class="btn-cancel"><i class="fas fa-times"></i> Cancel</a>
            <button type="submit" class="btn-submit" onclick="return validateForm()">
                <i class="fas fa-save me-2"></i>
                <%= isEdit ? "Update Reservation" : "Create Reservation" %>
            </button>
        </div>
    </form>
</div>

<!-- Room Detail Modal -->
<div class="modal fade" id="roomDetailModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold"><i class="fas fa-door-open me-2"></i>Room Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div style="text-align:center;margin-bottom:16px;">
                    <h2 id="md-room-number" style="font-size:2.2rem;font-weight:800;color:var(--primary);">—</h2>
                    <span id="md-room-type-badge" class="room-type-badge">—</span>
                </div>
                <div class="room-detail-grid">
                    <div class="rd-item"><div class="rd-label"><i class="fas fa-layer-group me-1"></i>Floor</div><div class="rd-value" id="md-floor">—</div></div>
                    <div class="rd-item"><div class="rd-label"><i class="fas fa-users me-1"></i>Capacity</div><div class="rd-value" id="md-capacity">—</div></div>
                    <div class="rd-item"><div class="rd-label"><i class="fas fa-eye me-1"></i>View</div><div class="rd-value" id="md-view">—</div></div>
                    <div class="rd-item"><div class="rd-label"><i class="fas fa-dollar-sign me-1"></i>Price/night</div><div class="rd-value" id="md-price">—</div></div>
                </div>
                <div style="margin-top:16px;"><div class="rd-label"><i class="fas fa-concierge-bell me-1"></i>Amenities</div><div id="md-amenities" style="margin-top:8px;">—</div></div>
                <div style="margin-top:14px;"><div class="rd-label"><i class="fas fa-align-left me-1"></i>Description</div><p id="md-description" style="font-size:0.88rem;color:var(--dark);margin-top:6px;">—</p></div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="md-select-btn" onclick="selectRoomFromModal()">
                    <i class="fas fa-check me-2"></i>Select This Room
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ═══ Global State ═══════════════════════════════════════════════════════════
    var _ctx   = '<%= request.getContextPath() %>';

    // Each slot: 1 = Room 1 (required), 2 = Room 2 (optional)
    var _rooms         = { 1: [], 2: [] };  // full available lists
    var _selectedRoom  = { 1: null, 2: null }; // selected room objects
    var _filter        = { 1: 'ALL', 2: 'ALL' };
    var _datesLoaded   = false;
    var _activeSlot    = 1;   // which tab is showing
    var _modalRoom     = null;
    var _modalSlot     = 1;

    // Pre-fill edit mode room 1
    <% if (!preRoomId.isEmpty()) { %>
    _selectedRoom[1] = { id: parseInt('<%= preRoomId %>'), roomNumber: '<%= preRoomNum %>', roomType: '<%= preRoomType %>', basePrice: parseFloat('<%= preRoomPrice %>'), capacity: 0 };
    <% } %>

    // ═══ 1. Guest Mode ══════════════════════════════════════════════════════════
    function switchMode(mode) {
        document.getElementById('guestMode').value = mode;
        document.getElementById('tab-existing').classList.toggle('active', mode === 'existing');
        document.getElementById('tab-new').classList.toggle('active', mode === 'new');
        document.getElementById('panelExisting').style.display = mode === 'existing' ? 'block' : 'none';
        document.getElementById('panelNew').style.display      = mode === 'new'      ? 'block' : 'none';
    }

    // ═══ 2. Guest Search ════════════════════════════════════════════════════════
    var _searchTimer;
    var _gsi = document.getElementById('guestSearchInput');
    if (_gsi) {
        _gsi.addEventListener('input', function () {
            clearTimeout(_searchTimer);
            var q = this.value.trim();
            if (q.length >= 2) _searchTimer = setTimeout(function () { doSearch(q); }, 350);
            else hideGuestResults();
        });
    }
    function doSearch(q) {
        if (!q || q.trim().length < 1) return;
        fetch(_ctx + '/api/guests/search?keyword=' + encodeURIComponent(q.trim()))
            .then(function(r){ return r.json(); })
            .then(renderGuestResults)
            .catch(function(){ showGuestErr('Search failed. Try again.'); });
    }
    function renderGuestResults(guests) {
        var box = document.getElementById('searchResults');
        if (!guests || !guests.length) {
            box.innerHTML = '<div class="sr-item" style="color:var(--gray-600);"><i class="fas fa-info-circle me-2"></i>No guests found. Switch to "New Guest" tab.</div>';
        } else {
            box.innerHTML = guests.map(function(g) {
                var info = []; if(g.email) info.push(g.email); if(g.phone) info.push(g.phone); if(g.guestNumber) info.push('#'+g.guestNumber);
                var ini = g.fullName ? g.fullName.split(' ').map(function(p){return p[0];}).join('').substring(0,2).toUpperCase() : '??';
                return '<div class="sr-item" onclick="pickGuest('+g.id+',\''+escJ(g.fullName)+'\',\''+escJ(g.email||'')+'\',\''+escJ(g.phone||'')+'\',\''+escJ(g.guestNumber||'')+'\',\''+escJ(ini)+'\')">' +
                    '<div class="sr-avatar">'+escH(ini)+'</div><div><div class="sr-name">'+escH(g.fullName)+'</div><div class="sr-info">'+escH(info.join(' · '))+'</div></div></div>';
            }).join('');
        }
        box.style.display = 'block';
    }
    function showGuestErr(msg) {
        var box = document.getElementById('searchResults');
        box.innerHTML = '<div class="sr-item" style="color:var(--danger);"><i class="fas fa-exclamation-circle me-2"></i>'+msg+'</div>';
        box.style.display = 'block';
    }
    function pickGuest(id, name, email, phone, gnum, ini) {
        document.getElementById('guestId').value = id;
        document.getElementById('sgAvatar').textContent = ini || (name ? name.substring(0,2).toUpperCase() : '??');
        document.getElementById('sgName').textContent   = name;
        var p = []; if(email) p.push(email); if(phone) p.push(phone); if(gnum) p.push('#'+gnum);
        document.getElementById('sgInfo').textContent   = p.join(' · ');
        document.getElementById('selectedGuest').classList.add('show');
        document.getElementById('guestSearchInput').value = '';
        hideGuestResults(); updateStepIndicators();
    }
    function clearGuest() {
        document.getElementById('guestId').value = '';
        document.getElementById('selectedGuest').classList.remove('show');
        document.getElementById('guestSearchInput').value = '';
        updateStepIndicators();
    }
    function hideGuestResults() { var b = document.getElementById('searchResults'); if(b) b.style.display='none'; }
    document.addEventListener('click', function(e){ if(!e.target.closest('.search-wrap')) hideGuestResults(); });

    // ═══ 3. Dates Change → Load Rooms ═══════════════════════════════════════════
    function onDatesChange() {
        var ci = document.getElementById('checkInDate');
        var co = document.getElementById('checkOutDate');
        if (ci && co && co.value && ci.value && new Date(co.value) < new Date(ci.value)) {
            co.value = ''; co.classList.add('is-invalid');
        } else {
            if(ci) ci.classList.remove('is-invalid');
            if(co) co.classList.remove('is-invalid');
        }
        recalcBill(); updateStepIndicators();
        var ciV = document.getElementById('checkInDate').value;
        var coV = document.getElementById('checkOutDate').value;
        if (ciV && coV && new Date(coV) >= new Date(ciV)) {
            // Reset rooms when dates change
            clearRoom(1, true);
            clearRoom(2, true);
            loadRoomsForSlot(1, ciV, coV, null);
        }
    }

    function loadRoomsForSlot(slot, checkIn, checkOut, excludeId) {
        var container = document.getElementById('roomsContainer' + slot);
        container.innerHTML = '<div class="rooms-loading"><div class="spinner-border text-primary mb-3"></div><div>Loading available rooms...</div></div>';

        var url = _ctx + '/api/rooms/available?checkIn=' + encodeURIComponent(checkIn) + '&checkOut=' + encodeURIComponent(checkOut);
        if (excludeId) url += '&excludeRoomId=' + excludeId;

        fetch(url)
            .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
            .then(function(rooms) {
                _rooms[slot] = rooms;
                if (slot === 1) _datesLoaded = true;
                renderRooms(slot);
                onGuestCountChange();
            })
            .catch(function(e) {
                console.error('Room load error:', e);
                container.innerHTML = '<div class="no-rooms-msg"><i class="fas fa-exclamation-triangle" style="color:var(--warning);"></i><strong>Failed to load rooms.</strong><br><span style="font-size:0.84rem;">Check dates and try again.</span></div>';
            });
    }

    // ═══ 4. Room Tab Switching ═══════════════════════════════════════════════════
    function switchRoomTab(slot) {
        _activeSlot = slot;
        document.getElementById('tab-room1').classList.toggle('active', slot === 1);
        document.getElementById('tab-room2').classList.toggle('active', slot === 2);
        document.getElementById('panel-room1').style.display = slot === 1 ? 'block' : 'none';
        document.getElementById('panel-room2').style.display = slot === 2 ? 'block' : 'none';

        // Load room 2 list when switching to tab 2 (exclude room 1)
        if (slot === 2 && _datesLoaded) {
            var ci = document.getElementById('checkInDate').value;
            var co = document.getElementById('checkOutDate').value;
            var excl = _selectedRoom[1] ? _selectedRoom[1].id : null;
            if (!_rooms[2].length) {
                loadRoomsForSlot(2, ci, co, excl);
            } else {
                renderRooms(2); // re-render to reflect any room 1 changes
            }
        }
    }

    // ═══ 5. Render Rooms ═════════════════════════════════════════════════════════
    function renderRooms(slot) {
        var container = document.getElementById('roomsContainer' + slot);
        var rooms     = _rooms[slot];
        var keyword   = (document.getElementById('roomSearch' + slot).value || '').trim().toLowerCase();
        var filt      = _filter[slot];
        var selId     = _selectedRoom[slot] ? _selectedRoom[slot].id : null;

        // For slot 2: also exclude slot 1 selection from display
        var excl1 = (slot === 2 && _selectedRoom[1]) ? _selectedRoom[1].id : null;

        var filtered = rooms.filter(function(r) {
            if (excl1 && r.id === excl1) return false;
            var mt = (filt === 'ALL' || r.roomType === filt);
            var ms = !keyword || r.roomNumber.toLowerCase().includes(keyword);
            return mt && ms;
        });

        if (!filtered.length) {
            var msg = rooms.length === 0
                ? '<strong>No rooms available</strong> for these dates.'
                : '<strong>No rooms match your filter.</strong> Try a different type or clear search.';
            container.innerHTML = '<div class="no-rooms-msg"><i class="fas fa-door-open"></i>' + msg + '</div>';
            return;
        }

        var html = '<div class="room-grid">';
        filtered.forEach(function(r) {
            var isSel = selId && r.id === selId;
            var bc    = getBadge(r.roomType);
            var vstr  = r.roomView ? r.roomView.replace(/_/g,' ') : '';
            html += '<div class="room-card'+(isSel?' selected':'') + '" id="rc'+slot+'-'+r.id+'" onclick="pickRoom('+slot+','+r.id+',\''+escJ(r.roomNumber)+'\',\''+escJ(r.roomType)+'\','+r.basePrice+','+r.capacity+')">' +
                '<span class="room-type-badge '+bc+'">'+escH(r.roomType)+'</span>' +
                '<div class="room-number">'+escH(r.roomNumber)+'</div>' +
                '<div class="room-floor">'+(r.floorNumber?'Floor '+r.floorNumber:'')+'</div>' +
                '<div class="room-price">$'+parseFloat(r.basePrice).toFixed(2)+' <small>/ night</small></div>' +
                '<div class="room-meta">' +
                '<span class="room-tag"><i class="fas fa-users"></i> '+r.capacity+' pax</span>' +
                (vstr ? '<span class="room-tag"><i class="fas fa-eye"></i> '+escH(vstr)+'</span>' : '') +
                '</div>' +
                '<button type="button" class="room-detail-btn" onclick="event.stopPropagation();showRoomDetail('+slot+','+r.id+')"><i class="fas fa-info-circle me-1"></i>View Details</button>' +
                '</div>';
        });
        html += '</div>';
        container.innerHTML = html;
    }

    function getBadge(t) {
        return ({STANDARD:'badge-standard',DELUXE:'badge-deluxe',SUITE:'badge-suite',EXECUTIVE:'badge-executive',FAMILY:'badge-family',PRESIDENTIAL:'badge-presidential'}[t] || 'badge-other');
    }

    // ═══ 6. Filter / Search ══════════════════════════════════════════════════════
    function filterRooms(slot, type, el) {
        if (type !== null) {
            _filter[slot] = type;
            document.querySelectorAll('[data-slot="'+slot+'"].filter-chip').forEach(function(c){ c.classList.remove('active'); });
            if (el) el.classList.add('active');
        }
        if (_rooms[slot].length) renderRooms(slot);
    }

    // ═══ 7. Pick Room ════════════════════════════════════════════════════════════
    function pickRoom(slot, id, num, type, price, cap) {
        var room = { id: id, roomNumber: num, roomType: type, basePrice: parseFloat(price), capacity: parseInt(cap) };
        _selectedRoom[slot] = room;
        document.getElementById('room' + (slot === 1 ? 'Id' : 'Id2')).value = id;

        renderRooms(slot); // re-render to show checkmark

        var bar = document.getElementById('selectedRoomBar' + slot);
        document.getElementById('srbName' + slot).textContent = 'Room ' + num + ' — ' + type;
        document.getElementById('srbInfo' + slot).textContent = '$' + parseFloat(price).toFixed(2) + '/night · Capacity: ' + cap + ' guests';
        bar.classList.add('show');

        // Mark tab as having a room
        document.getElementById('tab-room' + slot).classList.add('has-room');

        // If room 2 is open, reload to exclude room 1
        if (slot === 1 && _datesLoaded) {
            var ci = document.getElementById('checkInDate').value;
            var co = document.getElementById('checkOutDate').value;
            _rooms[2] = []; // force reload
            if (_activeSlot === 2) loadRoomsForSlot(2, ci, co, id);
        }

        recalcBill();
        onGuestCountChange();
        updateStepIndicators();
    }

    function clearRoom(slot, silent) {
        _selectedRoom[slot] = null;
        document.getElementById('room' + (slot === 1 ? 'Id' : 'Id2')).value = '';
        var bar = document.getElementById('selectedRoomBar' + slot);
        if (bar) bar.classList.remove('show');
        document.getElementById('tab-room' + slot).classList.remove('has-room');
        if (!silent) {
            renderRooms(slot);
            recalcBill();
            onGuestCountChange();
            updateStepIndicators();
        }
        if (slot === 2) {
            document.getElementById('bill-room2-section').style.display = 'none';
        }
    }

    // ═══ 8. Room Detail Modal ════════════════════════════════════════════════════
    function showRoomDetail(slot, id) {
        var room = _rooms[slot].find(function(r){ return r.id === id; });
        if (!room) return;
        _modalRoom = room; _modalSlot = slot;

        document.getElementById('md-room-number').textContent = 'Room ' + room.roomNumber;
        var badge = document.getElementById('md-room-type-badge');
        badge.textContent = room.roomType; badge.className = 'room-type-badge ' + getBadge(room.roomType);
        document.getElementById('md-floor').textContent    = room.floorNumber ? 'Floor ' + room.floorNumber : '—';
        document.getElementById('md-capacity').textContent = room.capacity + ' Guests';
        document.getElementById('md-view').textContent     = room.roomView ? room.roomView.replace(/_/g,' ') : '—';
        document.getElementById('md-price').textContent    = '$' + parseFloat(room.basePrice).toFixed(2);

        var amenEl = document.getElementById('md-amenities');
        if (room.amenities) {
            amenEl.innerHTML = room.amenities.split(',').map(function(a){ return '<span class="amenity-tag">'+escH(a.trim())+'</span>'; }).join('');
        } else { amenEl.textContent = 'No amenities listed'; }
        document.getElementById('md-description').textContent = room.description || 'No description available.';

        var btn = document.getElementById('md-select-btn');
        var cur = _selectedRoom[slot];
        if (cur && cur.id === id) {
            btn.innerHTML = '<i class="fas fa-check me-2"></i>Already Selected';
            btn.className = 'btn btn-success';
        } else {
            btn.innerHTML = '<i class="fas fa-check me-2"></i>Select for Room ' + slot;
            btn.className = 'btn btn-primary';
        }
        new bootstrap.Modal(document.getElementById('roomDetailModal')).show();
    }
    function selectRoomFromModal() {
        if (!_modalRoom) return;
        var r = _modalRoom;
        pickRoom(_modalSlot, r.id, r.roomNumber, r.roomType, r.basePrice, r.capacity);
        bootstrap.Modal.getInstance(document.getElementById('roomDetailModal')).hide();
    }

    // ═══ 9. Capacity Check ═══════════════════════════════════════════════════════
    function onGuestCountChange() {
        recalcBill();
        var totalCap = 0;
        if (_selectedRoom[1]) totalCap += _selectedRoom[1].capacity;
        if (_selectedRoom[2]) totalCap += _selectedRoom[2].capacity;
        if (totalCap <= 0) {
            document.getElementById('capacityChecker').classList.remove('show');
            document.getElementById('capacityAlert').classList.remove('show');
            return;
        }
        var adults   = parseInt(document.getElementById('adults').value)   || 0;
        var children = parseInt(document.getElementById('children').value) || 0;
        var total    = adults + children;
        var pct      = Math.min(100, Math.round((total / totalCap) * 100));

        document.getElementById('capacityChecker').classList.add('show');
        var bar = document.getElementById('capacityBar');
        bar.style.width = pct + '%';
        bar.classList.remove('warn','over');
        document.getElementById('capacityText').textContent = total + ' / ' + totalCap + ' guests';
        document.getElementById('capacityAlert').classList.remove('show');

        if (total > totalCap) {
            bar.classList.add('over');
            document.getElementById('capacityText').style.color = 'var(--danger)';
            document.getElementById('capacityAlertMsg').textContent = '⚠ Guest count (' + total + ') exceeds combined room capacity (' + totalCap + '). Add a second room or reduce guests.';
            document.getElementById('capacityAlert').classList.add('show');
        } else if (pct >= 80) {
            bar.classList.add('warn');
            document.getElementById('capacityText').style.color = 'var(--warning)';
        } else {
            document.getElementById('capacityText').style.color = 'var(--success)';
        }
    }

    // ═══ 10. Bill Calculation ════════════════════════════════════════════════════
    function recalcBill() {
        var ci   = document.getElementById('checkInDate').value;
        var co   = document.getElementById('checkOutDate').value;
        var disc = parseFloat(document.getElementById('discountAmount').value) || 0;
        var r1   = _selectedRoom[1];
        var r2   = _selectedRoom[2];

        if (!ci || !co || !r1) { document.getElementById('billPreview').style.display = 'none'; return; }
        var nights = Math.round((new Date(co) - new Date(ci)) / 86400000);
        if (nights <= 0) return;

        document.getElementById('billPreview').style.display = 'block';

        var charges1 = r1.basePrice * nights;
        document.getElementById('b-room1').textContent    = 'Room ' + r1.roomNumber;
        document.getElementById('b-rate1').textContent    = '$' + r1.basePrice.toFixed(2) + '/night';
        document.getElementById('b-charges1').textContent = '$' + charges1.toFixed(2);

        var charges2 = 0;
        if (r2) {
            charges2 = r2.basePrice * nights;
            document.getElementById('bill-room2-section').style.display = 'block';
            document.getElementById('b-room2').textContent    = 'Room ' + r2.roomNumber;
            document.getElementById('b-rate2').textContent    = '$' + r2.basePrice.toFixed(2) + '/night';
            document.getElementById('b-charges2').textContent = '$' + charges2.toFixed(2);
        } else {
            document.getElementById('bill-room2-section').style.display = 'none';
        }

        var totalCharges = charges1 + charges2;
        var taxable      = totalCharges - disc;
        var tax          = taxable * 0.12;
        var total        = taxable + tax;

        document.getElementById('b-nights').textContent        = nights + ' night' + (nights > 1 ? 's' : '');
        document.getElementById('b-total-charges').textContent = '$' + totalCharges.toFixed(2);
        document.getElementById('b-tax').textContent           = '$' + tax.toFixed(2);
        document.getElementById('b-discount').textContent      = '-$' + disc.toFixed(2);
        document.getElementById('b-total').textContent         = '$' + total.toFixed(2);
    }

    // ═══ 11. Step Indicators ═════════════════════════════════════════════════════
    function updateStepIndicators() {
        var modeEl = document.getElementById('guestMode');
        var mode   = modeEl ? modeEl.value : 'existing';
        var guestOk = mode === 'existing'
            ? !!(document.getElementById('guestId') && document.getElementById('guestId').value)
            : (document.getElementById('newFirstName') && document.getElementById('newLastName') &&
                document.getElementById('newFirstName').value.trim() && document.getElementById('newLastName').value.trim());
        var datesOk = !!(document.getElementById('checkInDate').value && document.getElementById('checkOutDate').value);
        var roomOk  = !!_selectedRoom[1];

        setStep(1, guestOk); setStep(2, datesOk); setStep(3, roomOk);
        setStep(4, guestOk && datesOk && roomOk, true);
    }
    function setStep(num, done, isLast) {
        var el = document.getElementById('step-' + num); if (!el) return;
        el.classList.remove('done','active');
        if (done) {
            el.classList.add('done');
            el.querySelector('.step-num').innerHTML = '<i class="fas fa-check" style="font-size:0.6rem;"></i>';
            var ln = document.getElementById('line-' + num);
            if (ln && !isLast) ln.classList.add('done');
        } else {
            el.querySelector('.step-num').textContent = num;
            var ln = document.getElementById('line-' + num);
            if (ln) ln.classList.remove('done');
        }
    }

    // ═══ 12. Validate ════════════════════════════════════════════════════════════
    function validateForm() {
        var mode = (document.getElementById('guestMode') || {}).value || 'existing';
        if (mode === 'existing') {
            var gid = document.getElementById('guestId');
            if (!gid || !gid.value) { alert('Please search and select a guest, or switch to "New Guest" tab.'); return false; }
        } else {
            var fn = document.getElementById('newFirstName'), ln = document.getElementById('newLastName');
            if (!fn.value.trim() || !ln.value.trim()) { alert('First name and last name are required.'); return false; }
        }
        var ci = document.getElementById('checkInDate').value;
        var co = document.getElementById('checkOutDate').value;
        if (!ci || !co) { alert('Please select check-in and check-out dates.'); return false; }
        if (new Date(co) < new Date(ci)) { alert('Check-out date must not be before check-in date.'); return false; }
        if (!_selectedRoom[1]) { alert('Please select at least Room 1.'); return false; }

        // Combined capacity check
        var totalCap = (_selectedRoom[1] ? _selectedRoom[1].capacity : 0) + (_selectedRoom[2] ? _selectedRoom[2].capacity : 0);
        if (totalCap > 0) {
            var guests = (parseInt(document.getElementById('adults').value) || 0) + (parseInt(document.getElementById('children').value) || 0);
            if (guests > totalCap) {
                alert('Guest count (' + guests + ') exceeds combined room capacity (' + totalCap + '). Add a second room or reduce guest count.');
                return false;
            }
        }
        return true;
    }

    // ═══ Helpers ═════════════════════════════════════════════════════════════════
    function escJ(s) { if(!s) return ''; return String(s).replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/"/g,'\\"').replace(/\n/g,'\\n'); }
    function escH(s) { if(!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

    // ═══ Init ════════════════════════════════════════════════════════════════════
    document.addEventListener('DOMContentLoaded', function () {
        // Date constraint: checkout min = checkin
        var ciEl = document.getElementById('checkInDate');
        var coEl = document.getElementById('checkOutDate');
        if (ciEl) {
            ciEl.addEventListener('change', function () {
                if (coEl) {
                    coEl.min = this.value;
                    if (coEl.value && new Date(coEl.value) < new Date(this.value)) coEl.value = '';
                }
            });
        }

        // Edit mode: pre-load rooms
        <% if (isEdit && !preCheckIn.isEmpty() && !preCheckOut.isEmpty()) { %>
        loadRoomsForSlot(1, '<%= preCheckIn %>', '<%= preCheckOut %>', null);
        setTimeout(function() {
            if (_selectedRoom[1]) {
                document.getElementById('roomId').value = '<%= preRoomId %>';
                var bar = document.getElementById('selectedRoomBar1');
                document.getElementById('srbName1').textContent = 'Room <%= preRoomNum %> — <%= preRoomType %>';
                document.getElementById('srbInfo1').textContent = '$<%= preRoomPrice %>/night (previously selected)';
                bar.classList.add('show');
                document.getElementById('tab-room1').classList.add('has-room');
                recalcBill();
            }
        }, 900);
        <% } %>

        updateStepIndicators();
    });
</script>
</body>
</html>
