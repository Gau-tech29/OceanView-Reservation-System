<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.ReservationDTO" %>
<%@ page import="com.oceanview.dto.ReservationRoomDTO" %>
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
        .form-card { background: white; border-radius: var(--radius-lg); box-shadow: var(--shadow-md); margin-bottom: 24px; overflow: hidden; border: 1px solid rgba(13,110,253,0.06); transition: box-shadow 0.2s; }
        .form-card:hover { box-shadow: var(--shadow-lg); }
        .card-head { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; padding: 16px 24px; display: flex; align-items: center; gap: 12px; }
        .card-head .icon-wrap { width: 38px; height: 38px; background: rgba(255,255,255,0.2); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; font-size: 1rem; }
        .card-head h4 { margin: 0; font-size: 1rem; font-weight: 600; }
        .card-head p  { margin: 2px 0 0; font-size: 0.78rem; opacity: 0.85; }
        .card-body { padding: 24px; }
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
        .selected-guest-card { display: none; background: linear-gradient(135deg, #e8f4fd, #f0f8ff); border: 2px solid var(--primary); border-radius: var(--radius-md); padding: 14px 16px; position: relative; margin-bottom: 20px; }
        .selected-guest-card.show { display: flex; align-items: center; gap: 14px; }
        .sg-avatar { width: 46px; height: 46px; background: linear-gradient(135deg, var(--primary), var(--primary-dark)); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 1.1rem; flex-shrink: 0; }
        .sg-name { font-weight: 700; font-size: 0.95rem; color: var(--dark); }
        .sg-info { font-size: 0.8rem; color: var(--gray-600); margin-top: 2px; }
        .sg-clear { position: absolute; top: 10px; right: 12px; cursor: pointer; color: var(--danger); font-size: 1rem; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; border-radius: 50%; transition: background 0.2s; }
        .sg-clear:hover { background: var(--danger-light); }
        .sg-edit { position: absolute; top: 10px; right: 45px; cursor: pointer; color: var(--primary); font-size: 1rem; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; border-radius: 50%; transition: background 0.2s; }
        .sg-edit:hover { background: var(--primary-light); }
        .guest-edit-section {
            display: none; background: var(--gray-100); border-radius: var(--radius-md);
            padding: 20px; margin-bottom: 20px; border: 2px solid var(--primary); position: relative;
        }
        .guest-edit-section.show { display: block; }
        .guest-edit-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid var(--gray-300); }
        .guest-edit-title { font-weight: 600; color: var(--primary); }
        .guest-edit-close { cursor: pointer; color: var(--danger); font-size: 1.2rem; width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; border-radius: 50%; transition: background 0.2s; }
        .guest-edit-close:hover { background: var(--danger-light); }
        .capacity-checker { background: var(--gray-100); border-radius: var(--radius-md); padding: 14px 16px; margin-top: 16px; border: 1.5px solid var(--gray-300); display: none; }
        .capacity-checker.show { display: block; }
        .capacity-bar-wrap { background: var(--gray-200); border-radius: 20px; height: 8px; overflow: hidden; margin: 8px 0 6px; }
        .capacity-bar { height: 100%; border-radius: 20px; transition: width 0.4s ease, background 0.3s; background: var(--success); }
        .capacity-bar.warn { background: var(--warning); }
        .capacity-bar.over { background: var(--danger); }
        .capacity-label { font-size: 0.82rem; font-weight: 600; }
        .capacity-alert { display: none; background: var(--danger-light); border: 1.5px solid var(--danger); border-radius: var(--radius-sm); padding: 10px 14px; font-size: 0.84rem; color: #721c24; margin-top: 10px; align-items: center; gap: 8px; }
        .capacity-alert.show { display: flex; }
        .room-slot-panel { border: 1.5px solid var(--gray-300); border-radius: var(--radius-md); margin-bottom: 16px; overflow: hidden; transition: border-color 0.2s; }
        .room-slot-panel.has-room { border-color: var(--primary); }
        .room-slot-header { display: flex; align-items: center; justify-content: space-between; padding: 11px 16px; background: var(--gray-100); cursor: pointer; user-select: none; }
        .room-slot-panel.has-room .room-slot-header { background: var(--primary-light); }
        .room-slot-title { display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 0.9rem; color: var(--dark); }
        .slot-num-badge { width: 26px; height: 26px; border-radius: 50%; background: var(--gray-300); color: var(--gray-600); display: flex; align-items: center; justify-content: center; font-size: 0.78rem; font-weight: 700; }
        .room-slot-panel.has-room .slot-num-badge { background: var(--primary); color: white; }
        .slot-check-icon { color: var(--success); display: none; }
        .room-slot-panel.has-room .slot-check-icon { display: inline; }
        .slot-required-badge { font-size: 0.72rem; color: var(--danger); font-weight: 700; }
        .slot-optional-badge { font-size: 0.72rem; color: var(--gray-600); font-weight: 700; }
        .slot-selected-preview { font-size: 0.8rem; color: var(--primary); font-weight: 600; }
        .slot-collapse-icon { font-size: 0.8rem; color: var(--gray-600); transition: transform 0.25s; }
        .room-slot-panel.open .slot-collapse-icon { transform: rotate(180deg); }
        .room-slot-body { display: none; padding: 16px; border-top: 1.5px solid var(--gray-300); }
        .room-slot-panel.open .room-slot-body { display: block; }
        .room-slot-panel.has-room .room-slot-body { border-top-color: var(--primary); }
        .remove-slot-btn { background: none; border: none; color: var(--danger); cursor: pointer; font-size: 0.78rem; font-weight: 600; padding: 4px 8px; border-radius: 6px; border: 1.5px solid var(--danger); transition: all 0.2s; white-space: nowrap; }
        .remove-slot-btn:hover { background: var(--danger); color: white; }
        .room-section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 10px; }
        .room-filters { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
        .filter-chip { padding: 6px 12px; border-radius: 20px; border: 1.5px solid var(--gray-300); background: white; font-size: 0.78rem; font-weight: 600; cursor: pointer; transition: all 0.2s; color: var(--gray-600); }
        .filter-chip.active, .filter-chip:hover { background: var(--primary); border-color: var(--primary); color: white; }
        .room-search-box { position: relative; }
        .room-search-box input { border-radius: 20px; padding: 7px 14px 7px 34px; border: 1.5px solid var(--gray-300); font-size: 0.8rem; width: 180px; transition: all 0.2s; font-family: 'Poppins',sans-serif; }
        .room-search-box input:focus { border-color: var(--primary); width: 220px; box-shadow: 0 0 0 3px rgba(13,110,253,0.1); outline: none; }
        .room-search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--gray-600); font-size: 0.78rem; }
        .rooms-loading { text-align: center; padding: 40px 20px; color: var(--gray-600); }
        .rooms-loading .spinner-border { width: 2.5rem; height: 2.5rem; border-width: 3px; }
        .room-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
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
        .selected-room-bar { display: none; background: linear-gradient(135deg, var(--primary-light), #f0f8ff); border: 2px solid var(--primary); border-radius: var(--radius-md); padding: 11px 14px; margin-top: 14px; align-items: center; gap: 12px; }
        .selected-room-bar.show { display: flex; }
        .srb-icon { width: 38px; height: 38px; background: var(--primary); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; color: white; font-size: 1.1rem; flex-shrink: 0; }
        .srb-name { font-weight: 700; color: var(--dark); font-size: 0.9rem; }
        .srb-info { font-size: 0.78rem; color: var(--gray-600); margin-top: 2px; }
        .srb-clear { margin-left: auto; cursor: pointer; color: var(--danger); padding: 4px 8px; border-radius: 6px; font-size: 0.78rem; font-weight: 600; border: 1.5px solid var(--danger); transition: all 0.2s; white-space: nowrap; }
        .srb-clear:hover { background: var(--danger); color: white; }
        .add-room-btn { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 13px; border: 2px dashed var(--primary); border-radius: var(--radius-md); background: var(--primary-light); color: var(--primary); font-weight: 600; font-size: 0.88rem; cursor: pointer; transition: all 0.2s; width: 100%; font-family: 'Poppins', sans-serif; margin-top: 4px; }
        .add-room-btn:hover { background: var(--primary); color: white; border-style: solid; }
        .bill-preview { background: linear-gradient(135deg, #f8f9fa, #fff); border: 1.5px solid var(--gray-300); border-radius: var(--radius-md); padding: 18px 20px; margin-top: 20px; }
        .bill-preview-title { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--primary); margin-bottom: 14px; display: flex; align-items: center; gap: 8px; }
        .bill-row { display: flex; justify-content: space-between; padding: 5px 0; font-size: 0.84rem; color: var(--dark); border-bottom: 1px dashed var(--gray-200); }
        .bill-row:last-child { border-bottom: none; }
        .bill-row.total { font-weight: 700; font-size: 0.97rem; color: var(--primary); border-top: 2px solid var(--gray-300); margin-top: 8px; padding-top: 10px; border-bottom: none; }
        .bill-row .label { color: var(--gray-600); }
        .bill-section-divider { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--gray-600); padding: 6px 0 4px; border-bottom: 1px dashed var(--gray-300); margin-top: 4px; }
        .back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--gray-600); font-size: 0.85rem; font-weight: 500; text-decoration: none; padding: 7px 14px; border-radius: 20px; background: white; border: 1.5px solid var(--gray-300); margin-bottom: 20px; transition: all 0.2s; }
        .back-link:hover { color: var(--primary); border-color: var(--primary); background: var(--primary-light); }
        .err-box { background: var(--danger-light); color: #721c24; border: none; border-radius: var(--radius-md); padding: 12px 18px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .info-tip { background: #e8f4fd; border: 1.5px solid #bee5fb; border-radius: var(--radius-sm); padding: 9px 14px; font-size: 0.81rem; color: #0c5460; display: flex; align-items: center; gap: 8px; margin-top: 10px; }
        .btn-submit { background: linear-gradient(135deg, #0d6efd, #0b5ed7); color: white; border: none; border-radius: var(--radius-md); padding: 13px 34px; font-size: 0.95rem; font-weight: 700; cursor: pointer; transition: all 0.2s; font-family: 'Poppins', sans-serif; }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(13,110,253,0.35); }
        .btn-cancel { background: var(--gray-100); color: var(--gray-600); border: 1.5px solid var(--gray-300); border-radius: var(--radius-md); padding: 12px 28px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.2s; font-family: 'Poppins', sans-serif; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; }
        .btn-cancel:hover { background: var(--gray-200); color: var(--dark); }
        .rooms-summary-bar { background: var(--success-light); border: 1.5px solid var(--success); border-radius: var(--radius-md); padding: 10px 16px; margin-bottom: 14px; display: none; align-items: center; gap: 10px; font-size: 0.85rem; font-weight: 600; color: var(--success); }
        .rooms-summary-bar.show { display: flex; }
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

    if (errorMsg == null) {
        errorMsg = (String) session.getAttribute("error");
        if (errorMsg != null) session.removeAttribute("error");
    }

    String today = LocalDate.now().toString();

    String preGuestId = "", preGuestName = "", preGuestInfo = "", preGuestInitials = "";
    String preFirstName = "", preLastName = "", preEmail = "", prePhone = "";
    String preAddress = "", preCity = "", preCountry = "", prePostalCode = "";
    String preIdCardNumber = "", preIdCardType = "";

    if (isEdit && reservation.getGuestId() != null) {
        preGuestId   = String.valueOf(reservation.getGuestId());
        preGuestName = reservation.getGuestName() != null ? reservation.getGuestName() : "Guest #" + reservation.getGuestId();
        String em = reservation.getGuestEmail() != null ? reservation.getGuestEmail() : "";
        String ph = reservation.getGuestPhone() != null ? " · " + reservation.getGuestPhone() : "";
        String gn = reservation.getGuestNumber() != null ? " · #" + reservation.getGuestNumber() : "";
        preGuestInfo = em + ph + gn;
        String[] np = preGuestName.split(" ");
        preGuestInitials = np.length >= 2
                ? String.valueOf(np[0].charAt(0)) + String.valueOf(np[np.length - 1].charAt(0))
                : preGuestName.substring(0, Math.min(2, preGuestName.length())).toUpperCase();
        preFirstName = reservation.getGuestName() != null ?
                (reservation.getGuestName().contains(" ") ?
                        reservation.getGuestName().substring(0, reservation.getGuestName().lastIndexOf(' ')) :
                        reservation.getGuestName()) : "";
        preLastName = reservation.getGuestName() != null && reservation.getGuestName().contains(" ") ?
                reservation.getGuestName().substring(reservation.getGuestName().lastIndexOf(' ') + 1) : "";
        preEmail = reservation.getGuestEmail() != null ? reservation.getGuestEmail() : "";
        prePhone = reservation.getGuestPhone() != null ? reservation.getGuestPhone() : "";
    } else if (selectedGuest != null) {
        preGuestId   = String.valueOf(selectedGuest.getId());
        preGuestName = selectedGuest.getFullName() != null ? selectedGuest.getFullName() : "";
        String em = selectedGuest.getEmail()  != null ? selectedGuest.getEmail()  : "";
        String ph = selectedGuest.getPhone()  != null ? " · " + selectedGuest.getPhone()  : "";
        String gn = selectedGuest.getGuestNumber() != null ? " · #" + selectedGuest.getGuestNumber() : "";
        preGuestInfo = em + ph + gn;
        if (selectedGuest.getFirstName() != null && selectedGuest.getLastName() != null)
            preGuestInitials = String.valueOf(selectedGuest.getFirstName().charAt(0))
                    + String.valueOf(selectedGuest.getLastName().charAt(0));
        preFirstName = selectedGuest.getFirstName() != null ? selectedGuest.getFirstName() : "";
        preLastName = selectedGuest.getLastName() != null ? selectedGuest.getLastName() : "";
        preEmail = selectedGuest.getEmail() != null ? selectedGuest.getEmail() : "";
        prePhone = selectedGuest.getPhone() != null ? selectedGuest.getPhone() : "";
        preAddress = selectedGuest.getAddress() != null ? selectedGuest.getAddress() : "";
        preCity = selectedGuest.getCity() != null ? selectedGuest.getCity() : "";
        preCountry = selectedGuest.getCountry() != null ? selectedGuest.getCountry() : "";
        prePostalCode = selectedGuest.getPostalCode() != null ? selectedGuest.getPostalCode() : "";
        preIdCardNumber = selectedGuest.getIdCardNumber() != null ? selectedGuest.getIdCardNumber() : "";
        preIdCardType = selectedGuest.getIdCardType() != null ? selectedGuest.getIdCardType() : "";
    }
    boolean hasPreGuest = !preGuestId.isEmpty();

    String preCheckIn  = "";
    String preCheckOut = "";
    String preRoomsJson = "[]";

    if (isEdit) {
        preCheckIn  = reservation.getCheckInDate()  != null ? reservation.getCheckInDate().toString()  : "";
        preCheckOut = reservation.getCheckOutDate() != null ? reservation.getCheckOutDate().toString() : "";

        List<ReservationRoomDTO> preRooms = reservation.getRooms();
        if (preRooms != null && !preRooms.isEmpty()) {
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < preRooms.size(); i++) {
                ReservationRoomDTO r = preRooms.get(i);
                if (i > 0) sb.append(",");
                long   rid   = r.getRoomId()     != null ? r.getRoomId()     : 0L;
                String rnum  = r.getRoomNumber()  != null ? r.getRoomNumber().replace("'", "\\'")  : "";
                String rtype = r.getRoomType()    != null ? r.getRoomType().replace("'", "\\'")    : "";
                double rprice= r.getRoomPrice()   != null ? r.getRoomPrice().doubleValue()         : 0.0;
                int    rcap  = r.getCapacity()    != null ? r.getCapacity()                        : 0;
                sb.append("{\"id\":").append(rid)
                        .append(",\"roomNumber\":\"").append(rnum).append("\"")
                        .append(",\"roomType\":\"").append(rtype).append("\"")
                        .append(",\"basePrice\":").append(rprice)
                        .append(",\"capacity\":").append(rcap)
                        .append("}");
            }
            sb.append("]");
            preRoomsJson = sb.toString();
        }
    }
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

    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
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
                    <button type="button" class="guest-mode-btn active" id="tab-existing" onclick="switchMode('existing')">
                        <i class="fas fa-search me-2"></i>Existing Guest
                    </button>
                    <button type="button" class="guest-mode-btn" id="tab-new" onclick="switchMode('new')">
                        <i class="fas fa-user-plus me-2"></i>New Guest
                    </button>
                </div>
                <input type="hidden" name="guestMode" id="guestMode" value="existing">
                <input type="hidden" name="updateGuest" id="updateGuest" value="false">

                <!-- Existing Guest Panel -->
                <div id="panelExisting">
                    <div class="search-wrap mb-3">
                        <label class="form-label">Search Guest <span class="required-star">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="fas fa-search text-primary"></i></span>
                            <input type="text" id="guestSearchInput" class="form-control border-start-0"
                                   placeholder="Name, email, phone or guest #..." autocomplete="off">
                            <button type="button" class="btn btn-primary"
                                    onclick="doSearch(document.getElementById('guestSearchInput').value)">Search</button>
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
                        <span class="sg-edit" onclick="editGuest()" title="Edit Guest Details"><i class="fas fa-pencil-alt"></i></span>
                        <span class="sg-clear" onclick="clearGuest()" title="Clear Guest"><i class="fas fa-times"></i></span>
                    </div>

                    <div class="guest-edit-section" id="guestEditSection">
                        <div class="guest-edit-header">
                            <h5 class="guest-edit-title"><i class="fas fa-edit me-2"></i>Edit Guest Details</h5>
                            <span class="guest-edit-close" onclick="closeGuestEdit()"><i class="fas fa-times"></i></span>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">First Name <span class="required-star">*</span></label>
                                <input type="text" name="firstName" id="editFirstName" class="form-control"
                                       value="<%= preFirstName %>" placeholder="First name">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Last Name <span class="required-star">*</span></label>
                                <input type="text" name="lastName" id="editLastName" class="form-control"
                                       value="<%= preLastName %>" placeholder="Last name">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email</label>
                                <input type="email" name="guestEmail" id="editEmail" class="form-control"
                                       value="<%= preEmail %>" placeholder="guest@email.com">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" name="guestPhone" id="editPhone" class="form-control"
                                       value="<%= prePhone %>" placeholder="+94 XX XXX XXXX">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ID Type</label>
                                <select name="idCardType" id="editIdCardType" class="form-select">
                                    <option value="">-- Select --</option>
                                    <option value="PASSPORT" <%= "PASSPORT".equals(preIdCardType) ? "selected" : "" %>>Passport</option>
                                    <option value="NATIONAL_ID" <%= "NATIONAL_ID".equals(preIdCardType) ? "selected" : "" %>>National ID</option>
                                    <option value="DRIVERS_LICENSE" <%= "DRIVERS_LICENSE".equals(preIdCardType) ? "selected" : "" %>>Driver's License</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">ID Number</label>
                                <input type="text" name="idCardNumber" id="editIdCardNumber" class="form-control"
                                       value="<%= preIdCardNumber %>" placeholder="ID number">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" id="editAddress" class="form-control"
                                       value="<%= preAddress %>" placeholder="Street address">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">City</label>
                                <input type="text" name="city" id="editCity" class="form-control" value="<%= preCity %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Country</label>
                                <input type="text" name="country" id="editCountry" class="form-control" value="<%= preCountry %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Postal Code</label>
                                <input type="text" name="postalCode" id="editPostalCode" class="form-control" value="<%= prePostalCode %>">
                            </div>
                            <div class="col-12">
                                <button type="button" class="btn btn-primary" onclick="saveGuestEdits()">
                                    <i class="fas fa-save me-2"></i>Update Guest
                                </button>
                                <button type="button" class="btn btn-secondary" onclick="closeGuestEdit()">Cancel</button>
                            </div>
                        </div>
                    </div>
                    <div class="info-tip"><i class="fas fa-info-circle"></i> Type at least 2 characters to search, then click a result. Click <i class="fas fa-pencil-alt"></i> to edit guest details.</div>
                </div>

                <!-- New Guest Panel -->
                <div id="panelNew" style="display:none;">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">First Name <span class="required-star">*</span></label>
                            <input type="text" name="newFirstName" id="newFirstName" class="form-control" placeholder="First name">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Last Name <span class="required-star">*</span></label>
                            <input type="text" name="newLastName" id="newLastName" class="form-control" placeholder="Last name">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="newGuestEmail" id="newGuestEmail" class="form-control" placeholder="guest@email.com">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Phone</label>
                            <input type="text" name="newGuestPhone" id="newGuestPhone" class="form-control" placeholder="+94 XX XXX XXXX">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">ID Type</label>
                            <select name="newIdCardType" id="newIdCardType" class="form-select">
                                <option value="">-- Select --</option>
                                <option value="PASSPORT">Passport</option>
                                <option value="NATIONAL_ID">National ID</option>
                                <option value="DRIVERS_LICENSE">Driver's License</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">ID Number</label>
                            <input type="text" name="newIdCardNumber" id="newIdCardNumber" class="form-control" placeholder="ID number">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <input type="text" name="newAddress" id="newAddress" class="form-control" placeholder="Street address">
                        </div>
                        <div class="col-md-4"><label class="form-label">City</label><input type="text" name="newCity" id="newCity" class="form-control"></div>
                        <div class="col-md-4"><label class="form-label">Country</label><input type="text" name="newCountry" id="newCountry" class="form-control"></div>
                        <div class="col-md-4"><label class="form-label">Postal Code</label><input type="text" name="newPostalCode" id="newPostalCode" class="form-control"></div>
                    </div>
                    <div class="info-tip mt-3"><i class="fas fa-info-circle"></i> A new guest profile will be created on submission.</div>
                </div>
                <% } else { %>
                <input type="hidden" name="guestMode" value="existing">
                <input type="hidden" name="guestId" value="<%= preGuestId %>">
                <div class="selected-guest-card show">
                    <div class="sg-avatar"><%= preGuestInitials %></div>
                    <div>
                        <div class="sg-name"><%= preGuestName %></div>
                        <div class="sg-info"><%= preGuestInfo %></div>
                    </div>
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
                        <input type="date" name="checkInDate" id="checkInDate" class="form-control"
                               required min="<%= today %>" value="<%= preCheckIn %>" onchange="onDatesChange()">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Check-out Date <span class="required-star">*</span></label>
                        <input type="date" name="checkOutDate" id="checkOutDate" class="form-control"
                               required min="<%= today %>" value="<%= preCheckOut %>" onchange="onDatesChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Adults <span class="required-star">*</span></label>
                        <input type="number" name="adults" id="adults" class="form-control" min="1" max="20" required
                               value="<%= isEdit && reservation.getAdults() != null ? reservation.getAdults() : 1 %>"
                               onchange="onGuestCountChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Children</label>
                        <input type="number" name="children" id="children" class="form-control" min="0" max="20"
                               value="<%= isEdit && reservation.getChildren() != null ? reservation.getChildren() : 0 %>"
                               onchange="onGuestCountChange()">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Discount (Rs.)</label>
                        <input type="number" name="discountAmount" id="discountAmount" class="form-control"
                               min="0" step="0.01"
                               value="<%= isEdit && reservation.getDiscountAmount() != null ? reservation.getDiscountAmount() : "0" %>"
                               onchange="recalcBill()">
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
                        <textarea name="specialRequests" class="form-control" rows="2"
                                  placeholder="Dietary needs, extra pillows, late check-in..."><%= isEdit && reservation.getSpecialRequests() != null ? reservation.getSpecialRequests() : "" %></textarea>
                    </div>
                </div>
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
                    <h4>Room Selection <span style="opacity:0.7;font-weight:400;font-size:0.85rem;">(unlimited rooms per reservation)</span></h4>
                    <p>Only rooms available for your chosen dates are shown.</p>
                </div>
            </div>
            <div class="card-body">
                <div id="roomSlotsContainer"></div>
                <button type="button" class="add-room-btn" id="addRoomBtn" onclick="addRoomSlot()">
                    <i class="fas fa-plus-circle"></i> Add Another Room
                </button>
                <div class="rooms-summary-bar" id="roomsSummaryBar">
                    <i class="fas fa-door-open"></i>
                    <span id="roomsSummaryText">1 room selected</span>
                </div>
                <!-- Bill preview -->
                <div class="bill-preview" id="billPreview" style="display:none;">
                    <div class="bill-preview-title"><i class="fas fa-receipt"></i> Bill Preview</div>
                    <div id="billRoomsSection"></div>
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
                    <div class="rd-item"><div class="rd-label"><i class="fas fa-rupee-sign me-1"></i>Price/night</div><div class="rd-value" id="md-price">—</div></div>
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
    var _ctx         = '<%= request.getContextPath() %>';
    var _slots       = [];
    var _slotSeq     = 0;
    var _datesLoaded = false;
    var _modalRoom   = null;
    var _modalSlotId = null;
    var _preRooms = <%= preRoomsJson %>;
    var _currentGuest = {
        id: '<%= preGuestId %>',
        firstName: '<%= preFirstName.replace("'", "\\'") %>',
        lastName: '<%= preLastName.replace("'", "\\'") %>',
        email: '<%= preEmail.replace("'", "\\'") %>',
        phone: '<%= prePhone.replace("'", "\\'") %>',
        address: '<%= preAddress.replace("'", "\\'") %>',
        city: '<%= preCity.replace("'", "\\'") %>',
        country: '<%= preCountry.replace("'", "\\'") %>',
        postalCode: '<%= prePostalCode.replace("'", "\\'") %>',
        idCardNumber: '<%= preIdCardNumber.replace("'", "\\'") %>',
        idCardType: '<%= preIdCardType %>'
    };

    // ═══ Guest Edit Functions ═══════════════════════════════════════════════════

    function editGuest() {
        if (!_currentGuest.id) return;
        document.getElementById('editFirstName').value = _currentGuest.firstName;
        document.getElementById('editLastName').value = _currentGuest.lastName;
        document.getElementById('editEmail').value = _currentGuest.email;
        document.getElementById('editPhone').value = _currentGuest.phone;
        document.getElementById('editAddress').value = _currentGuest.address;
        document.getElementById('editCity').value = _currentGuest.city;
        document.getElementById('editCountry').value = _currentGuest.country;
        document.getElementById('editPostalCode').value = _currentGuest.postalCode;
        document.getElementById('editIdCardNumber').value = _currentGuest.idCardNumber;
        var idTypeSelect = document.getElementById('editIdCardType');
        for (var i = 0; i < idTypeSelect.options.length; i++) {
            if (idTypeSelect.options[i].value === _currentGuest.idCardType) { idTypeSelect.selectedIndex = i; break; }
        }
        document.getElementById('guestEditSection').classList.add('show');
    }

    function saveGuestEdits() {
        var firstName = document.getElementById('editFirstName').value.trim();
        var lastName = document.getElementById('editLastName').value.trim();
        if (!firstName || !lastName) { alert('First name and last name are required.'); return; }
        _currentGuest.firstName = firstName;
        _currentGuest.lastName = lastName;
        _currentGuest.email = document.getElementById('editEmail').value.trim();
        _currentGuest.phone = document.getElementById('editPhone').value.trim();
        _currentGuest.address = document.getElementById('editAddress').value.trim();
        _currentGuest.city = document.getElementById('editCity').value.trim();
        _currentGuest.country = document.getElementById('editCountry').value.trim();
        _currentGuest.postalCode = document.getElementById('editPostalCode').value.trim();
        _currentGuest.idCardNumber = document.getElementById('editIdCardNumber').value.trim();
        _currentGuest.idCardType = document.getElementById('editIdCardType').value;
        var fullName = firstName + ' ' + lastName;
        document.getElementById('sgName').textContent = fullName;
        var info = [];
        if (_currentGuest.email) info.push(_currentGuest.email);
        if (_currentGuest.phone) info.push(_currentGuest.phone);
        if (info.length > 0) document.getElementById('sgInfo').textContent = info.join(' · ');
        document.getElementById('sgAvatar').textContent = (firstName.charAt(0) + lastName.charAt(0)).toUpperCase();
        document.getElementById('updateGuest').value = 'true';
        closeGuestEdit();
        alert('Guest details updated. Changes will be saved when you create the reservation.');
    }

    function closeGuestEdit() { document.getElementById('guestEditSection').classList.remove('show'); }

    // ═══ Slot management ════════════════════════════════════════════════════════

    function createSlot() { _slotSeq++; return { slotId: _slotSeq, roomList: [], selectedRoom: null, filter: 'ALL', open: true }; }

    function addRoomSlot() {
        var slot = createSlot(); _slots.push(slot); renderAllSlots();
        var ci = document.getElementById('checkInDate').value;
        var co = document.getElementById('checkOutDate').value;
        if (ci && co && _datesLoaded) loadRoomsForSlot(slot.slotId, ci, co);
        setTimeout(function() { toggleSlot(slot.slotId, true); }, 50);
        updateStepIndicators();
    }

    function removeRoomSlot(slotId) {
        _slots = _slots.filter(function(s){ return s.slotId !== slotId; });
        renderAllSlots(); recalcBill(); onGuestCountChange(); updateStepIndicators();
    }

    function toggleSlot(slotId, forceOpen) {
        var slot = getSlot(slotId); if (!slot) return;
        slot.open = (forceOpen !== undefined) ? forceOpen : !slot.open;
        var panel = document.getElementById('slot-panel-' + slotId);
        if (panel) panel.classList.toggle('open', slot.open);
    }

    function getSlot(slotId) { return _slots.find(function(s){ return s.slotId === slotId; }) || null; }
    function getSelectedRoomIds() { var ids = []; _slots.forEach(function(s){ if (s.selectedRoom) ids.push(s.selectedRoom.id); }); return ids; }

    // ═══ Render all slot panels ══════════════════════════════════════════════════

    function renderAllSlots() {
        var container = document.getElementById('roomSlotsContainer');
        var existing = document.querySelectorAll('input[name="roomIds"]');
        existing.forEach(function(el){ el.parentNode.removeChild(el); });
        var html = '';
        _slots.forEach(function(slot, idx) {
            var slotNum = idx + 1; var isFirst = idx === 0;
            var hasRoom = !!slot.selectedRoom; var isOpen = slot.open;
            var selectedPreview = hasRoom
                ? 'Room ' + slot.selectedRoom.roomNumber + ' · Rs. ' + slot.selectedRoom.basePrice.toFixed(2) + '/night'
                : '';
            html += '<div class="room-slot-panel' + (hasRoom ? ' has-room' : '') + (isOpen ? ' open' : '') + '" id="slot-panel-' + slot.slotId + '">';
            html += '<div class="room-slot-header" onclick="toggleSlot(' + slot.slotId + ')">';
            html += '<div class="room-slot-title">';
            html += '<div class="slot-num-badge">' + slotNum + '</div>';
            html += '<span>Room ' + slotNum + '</span>';
            html += isFirst ? '<span class="slot-required-badge">(Required)</span>' : '<span class="slot-optional-badge">(Optional)</span>';
            html += '<i class="fas fa-check-circle slot-check-icon"></i>';
            if (hasRoom) html += '<span class="slot-selected-preview">' + escH(selectedPreview) + '</span>';
            html += '</div>';
            html += '<div style="display:flex;align-items:center;gap:8px;">';
            if (!isFirst) html += '<button type="button" class="remove-slot-btn" onclick="event.stopPropagation();removeRoomSlot(' + slot.slotId + ')"><i class="fas fa-trash-alt me-1"></i>Remove</button>';
            html += '<i class="fas fa-chevron-down slot-collapse-icon"></i>';
            html += '</div></div>';
            html += '<div class="room-slot-body">';
            html += '<div class="room-section-header">';
            html += '<div class="room-filters" id="typeFilters-' + slot.slotId + '">';
            html += '<span style="font-size:0.8rem;font-weight:600;color:var(--gray-600);align-self:center;">Filter:</span>';
            var types = ['ALL','STANDARD','DELUXE','SUITE','EXECUTIVE','FAMILY','PRESIDENTIAL'];
            types.forEach(function(t) {
                var isActive = slot.filter === t;
                html += '<span class="filter-chip' + (isActive ? ' active' : '') + '" onclick="filterRooms(' + slot.slotId + ',\'' + t + '\',this)">' + (t === 'ALL' ? 'All' : t.charAt(0) + t.slice(1).toLowerCase()) + '</span>';
            });
            html += '</div>';
            html += '<div class="room-search-box"><i class="fas fa-search"></i><input type="text" id="roomSearch-' + slot.slotId + '" placeholder="Room number..." oninput="filterRooms(' + slot.slotId + ',null,null)"></div>';
            html += '</div>';
            html += '<div id="roomsContainer-' + slot.slotId + '">';
            if (!_datesLoaded) {
                html += '<div class="need-dates-notice"><i class="fas fa-calendar-alt"></i><strong>Fill in check-in and check-out dates above</strong><br><span style="font-size:0.84rem;">Available rooms will appear here.</span></div>';
            } else if (!slot.roomList.length) {
                html += '<div class="rooms-loading"><div class="spinner-border text-primary mb-3"></div><div>Loading available rooms...</div></div>';
            }
            html += '</div>';
            html += '<div class="selected-room-bar' + (hasRoom ? ' show' : '') + '" id="selectedRoomBar-' + slot.slotId + '">';
            html += '<div class="srb-icon"><i class="fas fa-check"></i></div>';
            html += '<div><div class="srb-name" id="srbName-' + slot.slotId + '">' + (hasRoom ? 'Room ' + escH(slot.selectedRoom.roomNumber) + ' — ' + escH(slot.selectedRoom.roomType) : '—') + '</div>';
            html += '<div class="srb-info" id="srbInfo-' + slot.slotId + '">' + (hasRoom ? 'Rs. ' + slot.selectedRoom.basePrice.toFixed(2) + '/night · Capacity: ' + slot.selectedRoom.capacity + ' guests' : '—') + '</div></div>';
            html += '<span class="srb-clear" onclick="clearRoom(' + slot.slotId + ')"><i class="fas fa-times me-1"></i>Change</span>';
            html += '</div></div></div>';
        });
        container.innerHTML = html;
        _slots.forEach(function(slot) { if (slot.roomList.length) renderRoomGrid(slot.slotId); });
        var form = document.getElementById('resForm');
        _slots.forEach(function(slot) {
            var inp = document.createElement('input');
            inp.type = 'hidden'; inp.name = 'roomIds'; inp.id = 'roomId-hidden-' + slot.slotId;
            inp.value = slot.selectedRoom ? slot.selectedRoom.id : '';
            form.appendChild(inp);
        });
        updateRoomsSummary();
    }

    // ═══ Load rooms from server ══════════════════════════════════════════════════

    function loadRoomsForSlot(slotId, checkIn, checkOut) {
        var container = document.getElementById('roomsContainer-' + slotId);
        if (container) container.innerHTML = '<div class="rooms-loading"><div class="spinner-border text-primary mb-3"></div><div>Loading available rooms...</div></div>';
        var excludeIds = getSelectedRoomIds();
        var slot = getSlot(slotId);
        if (slot && slot.selectedRoom) excludeIds = excludeIds.filter(function(id){ return id !== slot.selectedRoom.id; });
        var url = _ctx + '/api/rooms/available?checkIn=' + encodeURIComponent(checkIn) + '&checkOut=' + encodeURIComponent(checkOut);
        excludeIds.forEach(function(id) { url += '&excludeRoomId=' + id; });
        fetch(url)
            .then(function(r){ if(!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
            .then(function(rooms) {
                var s = getSlot(slotId);
                if (s) { s.roomList = rooms; if (!_datesLoaded) _datesLoaded = true; renderRoomGrid(slotId); onGuestCountChange(); }
            })
            .catch(function(e) {
                console.error('Room load error:', e);
                var c = document.getElementById('roomsContainer-' + slotId);
                if (c) c.innerHTML = '<div class="no-rooms-msg"><i class="fas fa-exclamation-triangle" style="color:var(--warning);"></i><strong>Failed to load rooms.</strong><br><span style="font-size:0.84rem;">Check dates and try again.</span></div>';
            });
    }

    function loadAllSlotsRooms() {
        var ci = document.getElementById('checkInDate').value;
        var co = document.getElementById('checkOutDate').value;
        if (!ci || !co) return;
        _datesLoaded = true;
        _slots.forEach(function(slot) { loadRoomsForSlot(slot.slotId, ci, co); });
    }

    // ═══ Render room grid for one slot ═══════════════════════════════════════════

    function renderRoomGrid(slotId) {
        var slot = getSlot(slotId); var container = document.getElementById('roomsContainer-' + slotId);
        if (!slot || !container) return;
        var keyword = ''; var searchEl = document.getElementById('roomSearch-' + slotId);
        if (searchEl) keyword = (searchEl.value || '').trim().toLowerCase();
        var filt = slot.filter; var selId = slot.selectedRoom ? slot.selectedRoom.id : null;
        var otherSelectedIds = [];
        _slots.forEach(function(s) { if (s.slotId !== slotId && s.selectedRoom) otherSelectedIds.push(s.selectedRoom.id); });
        var filtered = slot.roomList.filter(function(r) {
            if (otherSelectedIds.indexOf(r.id) !== -1) return false;
            var mt = (filt === 'ALL' || r.roomType === filt);
            var ms = !keyword || r.roomNumber.toLowerCase().indexOf(keyword) !== -1;
            return mt && ms;
        });
        if (!filtered.length) {
            var msg = slot.roomList.length === 0
                ? '<strong>No rooms available</strong> for these dates.'
                : '<strong>No rooms match your filter.</strong> Try a different type or clear search.';
            container.innerHTML = '<div class="no-rooms-msg"><i class="fas fa-door-open"></i>' + msg + '</div>';
            return;
        }
        var html = '<div class="room-grid">';
        filtered.forEach(function(r) {
            var isSel = selId && r.id === selId; var bc = getBadge(r.roomType);
            var vstr = r.roomView ? r.roomView.replace(/_/g,' ') : '';
            html += '<div class="room-card' + (isSel ? ' selected' : '') + '" id="rc-' + slotId + '-' + r.id + '" onclick="pickRoom(' + slotId + ',' + r.id + ',\'' + escJ(r.roomNumber) + '\',\'' + escJ(r.roomType) + '\',' + r.basePrice + ',' + r.capacity + ')">';
            html += '<span class="room-type-badge ' + bc + '">' + escH(r.roomType) + '</span>';
            html += '<div class="room-number">' + escH(r.roomNumber) + '</div>';
            html += '<div class="room-floor">' + (r.floorNumber ? 'Floor ' + r.floorNumber : '') + '</div>';
            html += '<div class="room-price">Rs. ' + parseFloat(r.basePrice).toFixed(2) + ' <small>/ night</small></div>';
            html += '<div class="room-meta">';
            html += '<span class="room-tag"><i class="fas fa-users"></i> ' + r.capacity + ' pax</span>';
            if (vstr) html += '<span class="room-tag"><i class="fas fa-eye"></i> ' + escH(vstr) + '</span>';
            html += '</div>';
            html += '<button type="button" class="room-detail-btn" onclick="event.stopPropagation();showRoomDetail(' + slotId + ',' + r.id + ')"><i class="fas fa-info-circle me-1"></i>View Details</button>';
            html += '</div>';
        });
        html += '</div>';
        container.innerHTML = html;
    }

    function getBadge(t) {
        return ({STANDARD:'badge-standard',DELUXE:'badge-deluxe',SUITE:'badge-suite',EXECUTIVE:'badge-executive',FAMILY:'badge-family',PRESIDENTIAL:'badge-presidential'}[t] || 'badge-other');
    }

    function filterRooms(slotId, type, el) {
        var slot = getSlot(slotId); if (!slot) return;
        if (type !== null) {
            slot.filter = type;
            var chips = document.querySelectorAll('#typeFilters-' + slotId + ' .filter-chip');
            chips.forEach(function(c){ c.classList.remove('active'); });
            if (el) el.classList.add('active');
        }
        if (slot.roomList.length) renderRoomGrid(slotId);
    }

    function pickRoom(slotId, id, num, type, price, cap) {
        var slot = getSlot(slotId); if (!slot) return;
        slot.selectedRoom = { id: id, roomNumber: num, roomType: type, basePrice: parseFloat(price), capacity: parseInt(cap) };
        var inp = document.getElementById('roomId-hidden-' + slotId); if (inp) inp.value = id;
        var panel = document.getElementById('slot-panel-' + slotId); if (panel) panel.classList.add('has-room');
        var bar = document.getElementById('selectedRoomBar-' + slotId);
        if (bar) {
            bar.classList.add('show');
            document.getElementById('srbName-' + slotId).textContent = 'Room ' + num + ' — ' + type;
            document.getElementById('srbInfo-' + slotId).textContent = 'Rs. ' + parseFloat(price).toFixed(2) + '/night · Capacity: ' + cap + ' guests';
        }
        renderRoomGrid(slotId);
        _slots.forEach(function(s) { if (s.slotId !== slotId && s.open && s.roomList.length) renderRoomGrid(s.slotId); });
        recalcBill(); onGuestCountChange(); updateStepIndicators(); updateRoomsSummary();
    }

    function clearRoom(slotId, silent) {
        var slot = getSlot(slotId); if (!slot) return; slot.selectedRoom = null;
        var inp = document.getElementById('roomId-hidden-' + slotId); if (inp) inp.value = '';
        var panel = document.getElementById('slot-panel-' + slotId); if (panel) panel.classList.remove('has-room');
        var bar = document.getElementById('selectedRoomBar-' + slotId); if (bar) bar.classList.remove('show');
        if (!silent) {
            renderRoomGrid(slotId);
            _slots.forEach(function(s) { if (s.slotId !== slotId && s.open && s.roomList.length) renderRoomGrid(s.slotId); });
            recalcBill(); onGuestCountChange(); updateStepIndicators(); updateRoomsSummary();
        }
    }

    function onDatesChange() {
        var ci = document.getElementById('checkInDate'); var co = document.getElementById('checkOutDate');
        if (ci && co && co.value && ci.value && new Date(co.value) < new Date(ci.value)) {
            co.value = ''; co.classList.add('is-invalid');
        } else { if (ci) ci.classList.remove('is-invalid'); if (co) co.classList.remove('is-invalid'); }
        var ciV = document.getElementById('checkInDate').value; var coV = document.getElementById('checkOutDate').value;
        if (ciV && coV && new Date(coV) >= new Date(ciV)) {
            _slots.forEach(function(s){ clearRoom(s.slotId, true); }); _datesLoaded = false; loadAllSlotsRooms();
        }
        recalcBill(); updateStepIndicators();
    }

    function showRoomDetail(slotId, id) {
        var slot = getSlot(slotId); if (!slot) return;
        var room = slot.roomList.find(function(r){ return r.id === id; }); if (!room) return;
        _modalRoom = room; _modalSlotId = slotId;
        document.getElementById('md-room-number').textContent = 'Room ' + room.roomNumber;
        var badge = document.getElementById('md-room-type-badge');
        badge.textContent = room.roomType; badge.className = 'room-type-badge ' + getBadge(room.roomType);
        document.getElementById('md-floor').textContent    = room.floorNumber ? 'Floor ' + room.floorNumber : '—';
        document.getElementById('md-capacity').textContent = room.capacity + ' Guests';
        document.getElementById('md-view').textContent     = room.roomView ? room.roomView.replace(/_/g,' ') : '—';
        document.getElementById('md-price').textContent    = 'Rs. ' + parseFloat(room.basePrice).toFixed(2);
        var amenEl = document.getElementById('md-amenities');
        if (room.amenities) {
            amenEl.innerHTML = room.amenities.split(',').map(function(a){ return '<span class="amenity-tag">'+escH(a.trim())+'</span>'; }).join('');
        } else { amenEl.textContent = 'No amenities listed'; }
        document.getElementById('md-description').textContent = room.description || 'No description available.';
        var btn = document.getElementById('md-select-btn'); var cur = slot.selectedRoom;
        if (cur && cur.id === id) { btn.innerHTML = '<i class="fas fa-check me-2"></i>Already Selected'; btn.className = 'btn btn-success'; }
        else {
            var slotNum = _slots.findIndex(function(s){ return s.slotId === slotId; }) + 1;
            btn.innerHTML = '<i class="fas fa-check me-2"></i>Select for Room ' + slotNum; btn.className = 'btn btn-primary';
        }
        new bootstrap.Modal(document.getElementById('roomDetailModal')).show();
    }

    function selectRoomFromModal() {
        if (!_modalRoom || !_modalSlotId) return;
        var r = _modalRoom; pickRoom(_modalSlotId, r.id, r.roomNumber, r.roomType, r.basePrice, r.capacity);
        bootstrap.Modal.getInstance(document.getElementById('roomDetailModal')).hide();
    }

    function onGuestCountChange() {
        recalcBill();
        var totalCap = 0; _slots.forEach(function(s){ if (s.selectedRoom) totalCap += s.selectedRoom.capacity; });
        if (totalCap <= 0) { document.getElementById('capacityChecker').classList.remove('show'); document.getElementById('capacityAlert').classList.remove('show'); return; }
        var adults = parseInt(document.getElementById('adults').value) || 0;
        var children = parseInt(document.getElementById('children').value) || 0;
        var total = adults + children; var pct = Math.min(100, Math.round((total / totalCap) * 100));
        document.getElementById('capacityChecker').classList.add('show');
        var bar = document.getElementById('capacityBar'); bar.style.width = pct + '%'; bar.classList.remove('warn','over');
        document.getElementById('capacityText').textContent = total + ' / ' + totalCap + ' guests';
        document.getElementById('capacityAlert').classList.remove('show');
        if (total > totalCap) {
            bar.classList.add('over'); document.getElementById('capacityText').style.color = 'var(--danger)';
            document.getElementById('capacityAlertMsg').textContent = '⚠ Guest count (' + total + ') exceeds combined room capacity (' + totalCap + '). Add more rooms or reduce guests.';
            document.getElementById('capacityAlert').classList.add('show');
        } else if (pct >= 80) { bar.classList.add('warn'); document.getElementById('capacityText').style.color = 'var(--warning)'; }
        else { document.getElementById('capacityText').style.color = 'var(--success)'; }
    }

    function recalcBill() {
        var ci = document.getElementById('checkInDate').value; var co = document.getElementById('checkOutDate').value;
        var disc = parseFloat(document.getElementById('discountAmount').value) || 0;
        var selectedSlots = _slots.filter(function(s){ return s.selectedRoom; });
        if (!ci || !co || selectedSlots.length === 0) { document.getElementById('billPreview').style.display = 'none'; return; }
        var nights = Math.round((new Date(co) - new Date(ci)) / 86400000); if (nights <= 0) return;
        document.getElementById('billPreview').style.display = 'block';
        var billHtml = ''; var totalCharges = 0;
        selectedSlots.forEach(function(s) {
            var r = s.selectedRoom; var charges = r.basePrice * nights; totalCharges += charges;
            var slotNum = _slots.indexOf(s) + 1;
            billHtml += '<div class="bill-section-divider">Room ' + slotNum + '</div>';
            billHtml += '<div class="bill-row"><span class="label">Room</span><span>Room ' + escH(r.roomNumber) + '</span></div>';
            billHtml += '<div class="bill-row"><span class="label">Rate/night</span><span>Rs. ' + r.basePrice.toFixed(2) + '</span></div>';
            billHtml += '<div class="bill-row"><span class="label">Room ' + slotNum + ' Charges</span><span>Rs. ' + charges.toFixed(2) + '</span></div>';
        });
        document.getElementById('billRoomsSection').innerHTML = billHtml;
        var taxable = totalCharges - disc; var tax = taxable * 0.12; var total = taxable + tax;
        document.getElementById('b-nights').textContent        = nights + ' night' + (nights > 1 ? 's' : '');
        document.getElementById('b-total-charges').textContent = 'Rs. ' + totalCharges.toFixed(2);
        document.getElementById('b-tax').textContent           = 'Rs. ' + tax.toFixed(2);
        document.getElementById('b-discount').textContent      = '-Rs. ' + disc.toFixed(2);
        document.getElementById('b-total').textContent         = 'Rs. ' + total.toFixed(2);
    }

    function updateRoomsSummary() {
        var count = _slots.filter(function(s){ return s.selectedRoom; }).length;
        var bar = document.getElementById('roomsSummaryBar');
        if (count > 0) { bar.classList.add('show'); document.getElementById('roomsSummaryText').textContent = count + ' room' + (count > 1 ? 's' : '') + ' selected'; }
        else { bar.classList.remove('show'); }
    }

    function updateStepIndicators() {
        var modeEl = document.getElementById('guestMode'); var isEditMode = <%= isEdit ? "true" : "false" %>;
        var guestOk = isEditMode ? true : (function() {
            var mode = modeEl ? modeEl.value : 'existing';
            return mode === 'existing'
                ? !!(document.getElementById('guestId') && document.getElementById('guestId').value)
                : (document.getElementById('newFirstName') && document.getElementById('newLastName') &&
                    document.getElementById('newFirstName').value.trim() && document.getElementById('newLastName').value.trim());
        })();
        var datesOk = !!(document.getElementById('checkInDate').value && document.getElementById('checkOutDate').value);
        var roomOk = _slots.some(function(s){ return s.selectedRoom; });
        setStep(1, guestOk); setStep(2, datesOk); setStep(3, roomOk); setStep(4, guestOk && datesOk && roomOk, true);
    }

    function setStep(num, done, isLast) {
        var el = document.getElementById('step-' + num); if (!el) return;
        el.classList.remove('done','active');
        if (done) {
            el.classList.add('done'); el.querySelector('.step-num').innerHTML = '<i class="fas fa-check" style="font-size:0.6rem;"></i>';
            var ln = document.getElementById('line-' + num); if (ln && !isLast) ln.classList.add('done');
        } else { el.querySelector('.step-num').textContent = num; var ln = document.getElementById('line-' + num); if (ln) ln.classList.remove('done'); }
    }

    function validateForm() {
        var isEditMode = <%= isEdit ? "true" : "false" %>;
        if (!isEditMode) {
            var mode = (document.getElementById('guestMode') || {}).value || 'existing';
            if (mode === 'existing') {
                var gid = document.getElementById('guestId');
                if (!gid || !gid.value) { alert('Please search and select a guest, or switch to "New Guest" tab.'); return false; }
            } else {
                var fn = document.getElementById('newFirstName'); var ln = document.getElementById('newLastName');
                if (!fn || !ln || !fn.value.trim() || !ln.value.trim()) { alert('First name and last name are required.'); return false; }
            }
        }
        var ci = document.getElementById('checkInDate').value; var co = document.getElementById('checkOutDate').value;
        if (!ci || !co) { alert('Please select check-in and check-out dates.'); return false; }
        if (new Date(co) < new Date(ci)) { alert('Check-out date must not be before check-in date.'); return false; }
        var selectedSlots = _slots.filter(function(s){ return s.selectedRoom; });
        if (selectedSlots.length === 0) { alert('Please select at least one room.'); return false; }
        var ids = selectedSlots.map(function(s){ return s.selectedRoom.id; });
        var uniqueIds = ids.filter(function(v, i){ return ids.indexOf(v) === i; });
        if (ids.length !== uniqueIds.length) { alert('Duplicate rooms detected. Please select different rooms.'); return false; }
        var totalCap = 0; selectedSlots.forEach(function(s){ totalCap += s.selectedRoom.capacity; });
        if (totalCap > 0) {
            var guests = (parseInt(document.getElementById('adults').value) || 0) + (parseInt(document.getElementById('children').value) || 0);
            if (guests > totalCap) { alert('Guest count (' + guests + ') exceeds combined room capacity (' + totalCap + '). Add more rooms or reduce guest count.'); return false; }
        }
        return true;
    }

    function switchMode(mode) {
        document.getElementById('guestMode').value = mode;
        document.getElementById('tab-existing').classList.toggle('active', mode === 'existing');
        document.getElementById('tab-new').classList.toggle('active', mode === 'new');
        document.getElementById('panelExisting').style.display = mode === 'existing' ? 'block' : 'none';
        document.getElementById('panelNew').style.display      = mode === 'new'      ? 'block' : 'none';
        if (mode === 'new') clearGuest();
    }

    var _searchTimer;
    var _gsi = document.getElementById('guestSearchInput');
    if (_gsi) {
        _gsi.addEventListener('input', function() {
            clearTimeout(_searchTimer); var q = this.value.trim();
            if (q.length >= 2) _searchTimer = setTimeout(function(){ doSearch(q); }, 350);
            else hideGuestResults();
        });
    }

    function doSearch(q) {
        if (!q || q.trim().length < 1) return;
        fetch(_ctx + '/api/guests/search?keyword=' + encodeURIComponent(q.trim()))
            .then(function(r){ return r.json(); }).then(renderGuestResults)
            .catch(function(){ showGuestErr('Search failed. Try again.'); });
    }

    function renderGuestResults(guests) {
        var box = document.getElementById('searchResults');
        if (!guests || !guests.length) {
            box.innerHTML = '<div class="sr-item" style="color:var(--gray-600);"><i class="fas fa-info-circle me-2"></i>No guests found. Switch to "New Guest" tab.</div>';
        } else {
            box.innerHTML = guests.map(function(g) {
                var info = []; if (g.email) info.push(g.email); if (g.phone) info.push(g.phone); if (g.guestNumber) info.push('#' + g.guestNumber);
                var ini = g.fullName ? g.fullName.split(' ').map(function(p){ return p[0]; }).join('').substring(0,2).toUpperCase() : '??';
                return '<div class="sr-item" onclick="pickGuest(' + g.id + ',\'' + escJ(g.fullName) + '\',\'' + escJ(g.email||'') + '\',\'' + escJ(g.phone||'') + '\',\'' + escJ(g.guestNumber||'') + '\',\'' + escJ(g.firstName||'') + '\',\'' + escJ(g.lastName||'') + '\',\'' + escJ(g.address||'') + '\',\'' + escJ(g.city||'') + '\',\'' + escJ(g.country||'') + '\',\'' + escJ(g.postalCode||'') + '\',\'' + escJ(g.idCardNumber||'') + '\',\'' + escJ(g.idCardType||'') + '\')">' +
                    '<div class="sr-avatar">' + escH(ini) + '</div>' +
                    '<div><div class="sr-name">' + escH(g.fullName) + '</div>' +
                    '<div class="sr-info">' + escH(info.join(' · ')) + '</div></div></div>';
            }).join('');
        }
        box.style.display = 'block';
    }

    function showGuestErr(msg) {
        var box = document.getElementById('searchResults');
        box.innerHTML = '<div class="sr-item" style="color:var(--danger);"><i class="fas fa-exclamation-circle me-2"></i>' + msg + '</div>';
        box.style.display = 'block';
    }

    function pickGuest(id, name, email, phone, gnum, firstName, lastName, address, city, country, postalCode, idCardNumber, idCardType) {
        document.getElementById('guestId').value = id;
        document.getElementById('sgAvatar').textContent = (firstName && lastName) ? (firstName.charAt(0) + lastName.charAt(0)).toUpperCase() : (name ? name.substring(0,2).toUpperCase() : '??');
        document.getElementById('sgName').textContent = name;
        var p = []; if (email) p.push(email); if (phone) p.push(phone); if (gnum) p.push('#' + gnum);
        document.getElementById('sgInfo').textContent = p.join(' · ');
        document.getElementById('selectedGuest').classList.add('show');
        document.getElementById('guestSearchInput').value = ''; hideGuestResults();
        _currentGuest = { id: id, firstName: firstName || '', lastName: lastName || '', email: email || '', phone: phone || '', address: address || '', city: city || '', country: country || '', postalCode: postalCode || '', idCardNumber: idCardNumber || '', idCardType: idCardType || '' };
        document.getElementById('updateGuest').value = 'false';
        updateStepIndicators();
    }

    function clearGuest() {
        document.getElementById('guestId').value = '';
        document.getElementById('selectedGuest').classList.remove('show');
        document.getElementById('guestSearchInput').value = '';
        document.getElementById('updateGuest').value = 'false';
        _currentGuest = { id: '' }; closeGuestEdit(); updateStepIndicators();
    }

    function hideGuestResults() { var b = document.getElementById('searchResults'); if (b) b.style.display = 'none'; }
    document.addEventListener('click', function(e){ if (!e.target.closest('.search-wrap')) hideGuestResults(); });

    function escJ(s) { if(!s) return ''; return String(s).replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/"/g,'\\"').replace(/\n/g,'\\n'); }
    function escH(s) { if(!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

    document.addEventListener('DOMContentLoaded', function() {
        var ciEl = document.getElementById('checkInDate'); var coEl = document.getElementById('checkOutDate');
        if (ciEl) {
            ciEl.addEventListener('change', function() {
                if (coEl) { coEl.min = this.value; if (coEl.value && new Date(coEl.value) < new Date(this.value)) coEl.value = ''; }
            });
        }
        var isEditMode = (<%= isEdit ? "true" : "false" %>);
        if (isEditMode && _preRooms.length > 0) {
            var ci = '<%= preCheckIn %>'; var co = '<%= preCheckOut %>';
            _datesLoaded = true;
            _preRooms.forEach(function(preRoom) {
                var slot = createSlot();
                slot.selectedRoom = { id: preRoom.id, roomNumber: preRoom.roomNumber, roomType: preRoom.roomType, basePrice: preRoom.basePrice, capacity: preRoom.capacity };
                _slots.push(slot);
            });
            renderAllSlots();
            _slots.forEach(function(slot) { loadRoomsForSlot(slot.slotId, ci, co); });
            recalcBill(); onGuestCountChange(); updateStepIndicators(); updateRoomsSummary();
        } else {
            var firstSlot = createSlot(); _slots.push(firstSlot); renderAllSlots();
            var ci = document.getElementById('checkInDate').value; var co = document.getElementById('checkOutDate').value;
            if (ci && co) { _datesLoaded = true; loadRoomsForSlot(firstSlot.slotId, ci, co); }
        }
        updateStepIndicators();
    });
</script>
</body>
</html>
