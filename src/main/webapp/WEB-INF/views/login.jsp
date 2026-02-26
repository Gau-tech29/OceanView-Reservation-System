<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View - Staff Portal</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary-color: #4361ee;
            --secondary-color: #3f37c9;
            --accent-color: #4cc9f0;
            --dark-color: #1e293b;
            --light-color: #f8f9fa;
            --success-color: #06d6a0;
            --gradient: linear-gradient(135deg, #4361ee, #3a0ca3);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f0f2f5;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .split-container {
            display: flex;
            max-width: 1200px;
            width: 95%;
            min-height: 650px;
            background: white;
            border-radius: 30px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
        }

        /* Left Side - Image/Hero Section */
        .hero-section {
            flex: 1.2;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
        }

        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('${pageContext.request.contextPath}/images/login.jpg') center/cover;
        }

        /* Dark overlay for better text readability */
        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(100deg, rgba(0,0,0,0.3), rgba(0,0,0,0.3));
            z-index: 1;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            color: white;
            padding: 50px 40px;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .brand-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            padding: 8px 16px;
            border-radius: 50px;
            font-size: 0.9rem;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            width: fit-content;
        }

        .hero-title {
            font-size: 3.2rem;
            font-weight: 700;
            line-height: 1.2;
            margin-bottom: 20px;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .hero-subtitle {
            font-size: 1.2rem;
            opacity: 0.95;
            margin-bottom: 30px;
            max-width: 80%;
            text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
        }

        .quote-section {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            padding: 25px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            margin: 20px 0;
        }

        .quote-text {
            font-size: 1.1rem;
            font-style: italic;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .quote-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .quote-author i {
            font-size: 2rem;
            opacity: 0.8;
        }

        .author-info h4 {
            font-weight: 600;
            margin-bottom: 2px;
            font-size: 1rem;
        }

        .author-info p {
            opacity: 0.8;
            font-size: 0.85rem;
            margin: 0;
        }

        .stats-container {
            display: flex;
            gap: 20px;
            margin-top: 30px;
        }

        .stat-item {
            flex: 1;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            padding: 15px;
            border-radius: 12px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .stat-number {
            font-size: 1.8rem;
            font-weight: 700;
            line-height: 1.2;
        }

        .stat-label {
            font-size: 0.8rem;
            opacity: 0.9;
        }

        /* Right Side - Form Section */
        .form-section {
            flex: 1;
            padding: 50px 45px;
            background: white;
            display: flex;
            flex-direction: column;
        }

        .form-header {
            margin-bottom: 40px;
        }

        .form-header h2 {
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 10px;
        }

        .form-header p {
            color: #6b7280;
            font-size: 1rem;
        }

        .role-badge {
            display: inline-block;
            background: #eef2f6;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            color: var(--dark-color);
            margin-top: 10px;
        }

        .role-badge i {
            color: var(--primary-color);
            margin-right: 5px;
        }

        .form-group {
            margin-bottom: 25px;
            position: relative;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: var(--dark-color);
            font-weight: 500;
            font-size: 0.95rem;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 15px;
            color: #9ca3af;
            font-size: 1rem;
            z-index: 2;
        }

        .form-control {
            width: 100%;
            height: 55px;
            padding: 10px 45px 10px 45px;
            border: 2px solid #eef2f6;
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s;
            background: #f8fafc;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            background: white;
            box-shadow: 0 0 0 4px rgba(67, 97, 238, 0.1);
            outline: none;
        }

        .toggle-password {
            position: absolute;
            right: 15px;
            color: #9ca3af;
            cursor: pointer;
            font-size: 1.2rem;
            z-index: 2;
        }

        .toggle-password:hover {
            color: var(--primary-color);
        }

        #password {
            padding-right: 45px;
        }

        .remember-forgot {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 25px 0 30px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .remember-me input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: var(--primary-color);
        }

        .remember-me label {
            color: #4b5563;
            cursor: pointer;
            font-size: 0.95rem;
        }

        .forgot-link {
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 500;
        }

        .forgot-link:hover {
            text-decoration: underline;
        }

        .btn-login {
            width: 100%;
            height: 55px;
            background: var(--gradient);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 25px;
            box-shadow: 0 10px 20px rgba(67, 97, 238, 0.3);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(67, 97, 238, 0.4);
        }

        .staff-note {
            text-align: center;
            margin-top: 20px;
            padding: 15px;
            background: #f8fafc;
            border-radius: 12px;
            border: 1px solid #eef2f6;
        }

        .staff-note p {
            color: #6b7280;
            font-size: 0.9rem;
            margin: 0;
        }

        .staff-note i {
            color: var(--primary-color);
            margin-right: 5px;
        }

        .alert {
            border-radius: 12px;
            padding: 15px 20px;
            margin-bottom: 25px;
            border: none;
            font-size: 0.95rem;
        }

        .alert-danger {
            background: #fee;
            color: #c00;
        }

        .alert-success {
            background: #e8f5e9;
            color: #2e7d32;
        }

        .spinner {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.9);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .spinner.active {
            display: flex;
        }

        .spinner::after {
            content: '';
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @media (max-width: 968px) {
            .split-container {
                flex-direction: column;
                min-height: auto;
            }

            .hero-section {
                min-height: 450px;
            }

            .hero-title {
                font-size: 2.5rem;
            }
        }
    </style>
</head>
<body>

<div class="spinner" id="spinner"></div>

<div class="split-container">
    <!-- Left Side - Staff/Admin Focused Quotes -->
    <div class="hero-section">
        <div class="hero-overlay"></div>

        <div class="hero-content">
            <div class="brand-badge">
                <i class="fas fa-hotel me-2"></i> Ocean View Staff Portal
            </div>

            <div>
                <h1 class="hero-title">
                    Staff & Admin<br>Reservation System
                </h1>

                <p class="hero-subtitle">
                    Secure access for hotel management team to handle reservations, guest requests, and room assignments.
                </p>

                <!-- Quick Stats for Staff -->
                <div class="stats-container">
                    <div class="stat-item">
                        <div class="stat-number">156</div>
                        <div class="stat-label">Rooms</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">89%</div>
                        <div class="stat-label">Occupancy</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">24/7</div>
                        <div class="stat-label">Support</div>
                    </div>
                </div>
            </div>

            <!-- Additional Quote at Bottom -->
            <div class="testimonial" style="margin-top: 20px;">
                <p class="testimonial-text" style="font-size: 0.9rem;">
                </p>
                <div class="testimonial-author">
                    <i class="fas fa-crown" style="color: gold;"></i>
                    <div class="author-info">
                        <strong>Management Team</strong>
                        <small>Ocean View Hotel</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Side - Login Form (Unchanged) -->
    <div class="form-section">
        <div class="form-header">
            <h2>Staff Login</h2>
            <p>Welcome back! Please login to access the management system</p>
            <div class="role-badge">
                <i class="fas fa-shield-alt"></i> Authorized Personnel Only
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle me-2"></i>
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle me-2"></i>
            <%= request.getAttribute("success") %>
        </div>
        <% } %>

        <!-- Login Form -->
        <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <i class="fas fa-user input-icon"></i>
                    <input type="text"
                           class="form-control"
                           id="username"
                           name="username"
                           placeholder="Enter your username"
                           value="${rememberedUsername != null ? rememberedUsername : ''}"
                           required
                           autofocus>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <i class="fas fa-lock input-icon"></i>
                    <input type="password"
                           class="form-control"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           required>
                    <i class="fas fa-eye toggle-password" id="togglePassword"></i>
                </div>
            </div>

            <div class="remember-forgot">
                <div class="remember-me">
                    <input type="checkbox" id="remember" name="remember" ${cookie.rememberMe != null ? 'checked' : ''}>
                    <label for="remember">Remember me</label>
                </div>
                <a href="#" class="forgot-link" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal">
                    Forgot Password?
                </a>
            </div>

            <button type="submit" class="btn-login" id="loginBtn">
                Access Dashboard
                <i class="fas fa-arrow-right"></i>
            </button>
        </form>

        <div class="staff-note">
            <p>
                <i class="fas fa-info-circle"></i>
                This portal is for authorized staff and administrators only. All activities are logged.
            </p>
        </div>
    </div>
</div>

<!-- Forgot Password Modal -->
<div class="modal fade" id="forgotPasswordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Reset Password</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Please contact the system administrator to reset your password:</p>
                <div class="mt-3 p-3 bg-light rounded">
                    <p class="mb-2"><i class="fas fa-envelope text-primary me-2"></i>admin@oceanview.com</p>
                    <p class="mb-0"><i class="fas fa-phone text-primary me-2"></i>+94 71 234 5678</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    $(document).ready(function() {
        $('#loginForm').on('submit', function() {
            $('#spinner').addClass('active');
            $('#loginBtn').prop('disabled', true);
        });

        $('#togglePassword').click(function() {
            const passwordField = $('#password');
            const type = passwordField.attr('type') === 'password' ? 'text' : 'password';
            passwordField.attr('type', type);
            $(this).toggleClass('fa-eye fa-eye-slash');
        });

        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    });
</script>
</body>
</html>