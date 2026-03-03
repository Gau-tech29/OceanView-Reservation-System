<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    User staff = (User) request.getAttribute("staff");
    if (staff == null) {
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff"); return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#0d6efd; --sidebar-width:280px; }
        body { font-family:'Poppins',sans-serif; background:#f4f6f9; }
        .sidebar {
            position:fixed; top:0; left:0; height:100vh; width:var(--sidebar-width);
            background:linear-gradient(180deg,#0a58ca 0%,#0d6efd 100%);
            color:white; z-index:1000; overflow-y:auto;
        }
        .sidebar-brand { padding:25px; border-bottom:2px solid rgba(255,255,255,.15); }
        .sidebar-brand h3 { font-size:1.6rem; font-weight:700; margin:0; }
        .sidebar-brand p  { font-size:.85rem; opacity:.9; margin:4px 0 0; }
        .sidebar-menu { list-style:none; padding:10px 15px; margin:0; }
        .sidebar-menu li { margin-bottom:6px; }
        .sidebar-menu a {
            display:flex; align-items:center; padding:12px 20px;
            color:rgba(255,255,255,.85); text-decoration:none;
            border-radius:12px; transition:all .3s;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active { background:rgba(255,255,255,.15); color:white; transform:translateX(5px); }
        .sidebar-menu a i { width:30px; }
        .main-content { margin-left:var(--sidebar-width); padding:25px 35px; }
        .top-nav {
            background:white; border-radius:18px; padding:16px 28px;
            margin-bottom:28px; box-shadow:0 4px 20px rgba(13,110,253,.1);
            display:flex; justify-content:space-between; align-items:center;
        }
        .page-title h2 { font-size:1.6rem; font-weight:600; color:#7c3aed; margin:0; }
        .page-title p  { color:#6c757d; margin:4px 0 0; font-size:.875rem; }

        /* User info strip */
        .user-strip {
            background:linear-gradient(135deg,#7c3aed,#6d28d9);
            border-radius:16px; padding:20px 26px; margin-bottom:26px;
            display:flex; align-items:center; gap:18px; color:white;
            box-shadow:0 8px 24px rgba(124,58,237,.25);
        }
        .strip-avatar {
            width:56px; height:56px; border-radius:14px;
            background:rgba(255,255,255,.2);
            display:flex; align-items:center; justify-content:center;
            font-size:1.4rem; font-weight:700; flex-shrink:0;
        }
        .strip-name { font-size:1.1rem; font-weight:600; margin:0; }
        .strip-meta { font-size:.82rem; opacity:.85; margin:3px 0 0; }
        .strip-badge {
            margin-left:auto; background:rgba(255,255,255,.2);
            border-radius:20px; padding:5px 14px; font-size:.78rem; font-weight:600;
        }

        .form-card { background:white; border-radius:18px; padding:32px; box-shadow:0 4px 20px rgba(13,110,253,.08); }
        .section-title {
            font-size:1rem; font-weight:600; color:#212529;
            margin-bottom:20px; padding-bottom:10px; border-bottom:2px solid #e9ecef;
            display:flex; align-items:center; gap:8px;
        }
        .section-title i { color:#7c3aed; }
        .form-label { font-weight:500; color:#495057; margin-bottom:7px; }
        .form-control {
            border:2px solid #e9ecef; border-radius:12px;
            padding:11px 15px; font-size:.9rem; transition:all .3s;
        }
        .form-control:focus { border-color:#7c3aed; box-shadow:0 0 0 4px rgba(124,58,237,.1); outline:none; }
        .input-group-text { background:#f8f9fa; border:2px solid #e9ecef; color:#6c757d; border-radius:12px 0 0 12px; }
        .input-group .form-control { border-radius:0 0 0 0; }
        .input-group .toggle-btn { border:2px solid #e9ecef; border-left:none; border-radius:0 12px 12px 0; background:#f8f9fa; color:#6c757d; padding:0 14px; cursor:pointer; transition:all .2s; }
        .input-group .toggle-btn:hover { background:#e9ecef; }

        /* Password strength bar */
        .strength-bar-wrap { height:5px; background:#e9ecef; border-radius:10px; margin-top:8px; overflow:hidden; }
        .strength-bar { height:100%; width:0; border-radius:10px; transition:all .4s; }
        .strength-label { font-size:.75rem; font-weight:600; margin-top:5px; }

        /* Rules checklist */
        .rules-list { list-style:none; padding:0; margin:10px 0 0; }
        .rules-list li { font-size:.8rem; color:#6c757d; margin-bottom:4px; display:flex; align-items:center; gap:6px; }
        .rules-list li i { width:14px; }
        .rules-list li.ok   { color:#065f46; }
        .rules-list li.ok i { color:#10b981; }
        .rules-list li.fail { color:#991b1b; }
        .rules-list li.fail i{ color:#ef4444; }

        .hint { font-size:.8rem; color:#6c757d; margin-top:5px; }
        .hint i { color:var(--primary); }

        .alert-error { background:#fee2e2; color:#991b1b; border-radius:12px; padding:13px 18px; margin-bottom:22px; display:flex; align-items:center; gap:10px; }

        /* Warning box */
        .warning-box {
            background:#fffbeb; border:1.5px solid #fde68a; border-radius:12px;
            padding:14px 18px; margin-bottom:24px; display:flex; align-items:flex-start; gap:10px;
            font-size:.875rem; color:#92400e;
        }
        .warning-box i { color:#f59e0b; margin-top:2px; flex-shrink:0; }

        .btn-save {
            background:linear-gradient(135deg,#7c3aed,#6d28d9); color:white; border:none;
            padding:12px 32px; border-radius:12px; font-weight:500; font-size:.9rem;
            transition:all .2s; box-shadow:0 4px 15px rgba(124,58,237,.3);
        }
        .btn-save:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(124,58,237,.4); color:white; }
        .btn-cancel {
            background:white; border:2px solid #e9ecef; color:#495057;
            padding:12px 28px; border-radius:12px; font-weight:500;
            text-decoration:none; display:inline-flex; align-items:center; gap:6px;
        }
        .btn-cancel:hover { background:#f8f9fa; color:#495057; }
        @media(max-width:992px){ .sidebar{transform:translateX(-100%);} .main-content{margin-left:0; padding:15px;} }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-brand">
        <h3><i class="fas fa-hotel me-2"></i>Ocean View</h3>
        <p>Hotel Reservation System</p>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-pie"></i><span>Dashboard</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-staff" class="active"><i class="fas fa-users-cog"></i><span>Manage Staff</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/manage-rooms"><i class="fas fa-door-open"></i><span>Manage Rooms</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reservations"><i class="fas fa-calendar-alt"></i><span>All Reservations</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/guests"><i class="fas fa-users"></i><span>Guests</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/payments"><i class="fas fa-credit-card"></i><span>Payments & Bills</span></a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports"><i class="fas fa-chart-bar"></i><span>Reports</span></a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
    </ul>
</div>

<div class="main-content">
    <div class="top-nav">
        <div class="page-title">
            <h2><i class="fas fa-key me-2"></i>Reset Password</h2>
            <p>Set a new password for this staff member</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/manage-staff?action=view&id=<%= staff.getId() %>" class="btn-cancel">
                <i class="fas fa-arrow-left"></i> Back to Profile
            </a>
        </div>
    </div>

    <!-- Staff info strip -->
    <div class="user-strip">
        <div class="strip-avatar"><%= staff.getFirstName().charAt(0) %><%= staff.getLastName().charAt(0) %></div>
        <div>
            <div class="strip-name"><%= staff.getFullName() %></div>
            <div class="strip-meta">@<%= staff.getUsername() %> &nbsp;·&nbsp; <%= staff.getEmail() %></div>
        </div>
        <span class="strip-badge"><i class="fas fa-user-tag me-1"></i><%= staff.getRole() %></span>
    </div>

    <% if (error != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <div class="warning-box">
        <i class="fas fa-exclamation-triangle"></i>
        <div>
            <strong>Admin Action:</strong> You are resetting the password for <strong><%= staff.getFullName() %></strong>.
            The user's current password will be permanently replaced. Please inform the user of their new password securely.
        </div>
    </div>

    <div class="form-card">
        <div class="section-title"><i class="fas fa-lock"></i>Set New Password</div>

        <form action="${pageContext.request.contextPath}/admin/manage-staff" method="POST" id="resetForm">
            <input type="hidden" name="action" value="resetpw">
            <input type="hidden" name="id"     value="<%= staff.getId() %>">

            <div class="row g-4">
                <div class="col-md-6">
                    <label class="form-label">New Password <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" class="form-control" name="newPassword" id="newPw"
                               required placeholder="Enter new password" autocomplete="new-password"
                               oninput="checkStrength(this.value); checkMatch();">
                        <button type="button" class="toggle-btn" onclick="togglePw('newPw','eyeNew')">
                            <i class="fas fa-eye" id="eyeNew"></i>
                        </button>
                    </div>
                    <!-- Strength bar -->
                    <div class="strength-bar-wrap mt-2"><div class="strength-bar" id="strengthBar"></div></div>
                    <div class="strength-label" id="strengthLabel" style="color:#6c757d;">Enter a password</div>
                    <!-- Rules -->
                    <ul class="rules-list" id="rulesList">
                        <li id="rLen"><i class="fas fa-circle"></i>At least 8 characters</li>
                        <li id="rUp"><i class="fas fa-circle"></i>At least one uppercase letter</li>
                        <li id="rLow"><i class="fas fa-circle"></i>At least one lowercase letter</li>
                        <li id="rNum"><i class="fas fa-circle"></i>At least one number</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Confirm New Password <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" class="form-control" name="confirmPassword" id="confirmPw"
                               required placeholder="Re-enter new password" autocomplete="new-password"
                               oninput="checkMatch();">
                        <button type="button" class="toggle-btn" onclick="togglePw('confirmPw','eyeConf')">
                            <i class="fas fa-eye" id="eyeConf"></i>
                        </button>
                    </div>
                    <div class="hint mt-2" id="matchHint" style="display:none;"></div>
                </div>
            </div>

            <div class="mt-4 text-end d-flex justify-content-end gap-2">
                <a href="${pageContext.request.contextPath}/admin/manage-staff?action=view&id=<%= staff.getId() %>" class="btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </a>
                <button type="submit" class="btn-save" id="submitBtn">
                    <i class="fas fa-key me-2"></i>Reset Password
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePw(inputId, iconId) {
        var inp = document.getElementById(inputId);
        var ico = document.getElementById(iconId);
        inp.type = inp.type === 'password' ? 'text' : 'password';
        ico.className = inp.type === 'text' ? 'fas fa-eye-slash' : 'fas fa-eye';
    }

    function setRule(id, ok) {
        var el = document.getElementById(id);
        el.className = ok ? 'ok' : '';
        el.querySelector('i').className = ok ? 'fas fa-check-circle' : 'fas fa-circle';
    }

    function checkStrength(pw) {
        var len  = pw.length >= 8;
        var up   = /[A-Z]/.test(pw);
        var low  = /[a-z]/.test(pw);
        var num  = /[0-9]/.test(pw);
        var spec = /[^A-Za-z0-9]/.test(pw);
        setRule('rLen', len); setRule('rUp', up); setRule('rLow', low); setRule('rNum', num);

        var score = [len, up, low, num, spec].filter(Boolean).length;
        var bar   = document.getElementById('strengthBar');
        var lbl   = document.getElementById('strengthLabel');
        var pct   = score * 20;
        bar.style.width = pct + '%';

        if (pw.length === 0) { bar.style.width='0'; bar.style.background=''; lbl.textContent='Enter a password'; lbl.style.color='#6c757d'; return; }
        var levels = [
            { min:1, max:1, color:'#ef4444', label:'Very Weak' },
            { min:2, max:2, color:'#f97316', label:'Weak' },
            { min:3, max:3, color:'#eab308', label:'Fair' },
            { min:4, max:4, color:'#22c55e', label:'Strong' },
            { min:5, max:5, color:'#10b981', label:'Very Strong' }
        ];
        var lvl = levels[Math.min(score - 1, 4)];
        bar.style.background = lvl.color;
        lbl.textContent = lvl.label;
        lbl.style.color = lvl.color;
    }

    function checkMatch() {
        var pw  = document.getElementById('newPw').val ? document.getElementById('newPw').val() : document.getElementById('newPw').value;
        var cpw = document.getElementById('confirmPw').value;
        var hint = document.getElementById('matchHint');
        if (!cpw) { hint.style.display='none'; return; }
        hint.style.display = '';
        if (pw === cpw) {
            hint.innerHTML = '<i class="fas fa-check-circle" style="color:#10b981;"></i> <span style="color:#065f46;">Passwords match</span>';
        } else {
            hint.innerHTML = '<i class="fas fa-times-circle" style="color:#ef4444;"></i> <span style="color:#991b1b;">Passwords do not match</span>';
        }
    }

    document.getElementById('resetForm').addEventListener('submit', function(e) {
        var pw  = document.getElementById('newPw').value;
        var cpw = document.getElementById('confirmPw').value;
        if (!pw) { alert('Please enter a new password.'); e.preventDefault(); return; }
        if (pw.length < 8) { alert('Password must be at least 8 characters.'); e.preventDefault(); return; }
        if (!/[A-Z]/.test(pw) || !/[a-z]/.test(pw) || !/[0-9]/.test(pw)) {
            alert('Password must contain at least one uppercase letter, one lowercase letter, and one number.');
            e.preventDefault(); return;
        }
        if (pw !== cpw) { alert('Passwords do not match.'); e.preventDefault(); }
    });
</script>
</body>
</html>