<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.StringWriter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error - Ocean View Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Poppins', sans-serif; background: #f4f6f9; padding: 50px; }
        .error-container { max-width: 800px; margin: 0 auto; background: white; border-radius: 15px; padding: 30px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); }
        .error-title { color: #dc3545; margin-bottom: 20px; }
        .error-details { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px; }
    </style>
</head>
<body>
<div class="error-container">
    <h1 class="error-title"><i class="fas fa-exclamation-triangle me-2"></i>500 - Internal Server Error</h1>
    <p class="lead">Sorry, something went wrong on our server.</p>

    <% if (request.getAttribute("error") != null) { %>
    <div class="error-details">
        <h5>Error Details:</h5>
        <p class="text-danger"><%= request.getAttribute("error") %></p>
    </div>
    <% } %>

    <div class="mt-4">
        <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-primary">
            <i class="fas fa-home me-2"></i>Go to Dashboard
        </a>
        <button onclick="history.back()" class="btn btn-secondary ms-2">
            <i class="fas fa-arrow-left me-2"></i>Go Back
        </button>
    </div>
</div>
</body>
</html>