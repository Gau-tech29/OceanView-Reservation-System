<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dto.GuestDTO" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }

  GuestDTO guest = (GuestDTO) request.getAttribute("guest");
  boolean isEdit = (guest != null && guest.getId() != null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= isEdit ? "Edit Guest" : "New Guest" %> - Ocean View Hotel</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Poppins', sans-serif; background: #f4f6f9; }
    .form-container { max-width: 800px; margin: 30px auto; }
    .card { border: none; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .card-header {
      background: linear-gradient(135deg, #0d6efd, #0b5ed7);
      color: white; border-radius: 15px 15px 0 0 !important;
      padding: 20px 25px;
    }
    .card-header h4 { margin: 0; font-weight: 600; }
    .card-body { padding: 30px; }
    .form-label { font-weight: 500; color: #495057; }
    .form-control, .form-select {
      border: 2px solid #e0e0e0; border-radius: 10px;
      padding: 10px 15px; transition: all 0.3s;
    }
    .form-control:focus, .form-select:focus {
      border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13,110,253,0.1);
    }
    .required-star { color: #dc3545; }
    .btn-primary {
      background: linear-gradient(135deg, #0d6efd, #0b5ed7);
      border: none; border-radius: 10px; padding: 12px 30px;
      font-weight: 600;
    }
    .btn-secondary {
      border-radius: 10px; padding: 12px 30px;
    }
    .err-box {
      background: #f8d7da; color: #721c24; border: none;
      border-radius: 10px; padding: 15px 20px; margin-bottom: 20px;
    }
  </style>
</head>
<body>
<div class="container form-container">

  <div class="mb-3">
    <a href="${pageContext.request.contextPath}/admin/guests" class="btn btn-outline-secondary btn-sm">
      <i class="fas fa-arrow-left me-1"></i>Back to Guests
    </a>
  </div>

  <% if (request.getAttribute("error") != null) { %>
  <div class="err-box alert-dismissible fade show">
    <i class="fas fa-exclamation-circle me-2"></i><%= request.getAttribute("error") %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% } %>

  <div class="card">
    <div class="card-header">
      <h4><i class="fas fa-user me-2"></i><%= isEdit ? "Edit Guest" : "New Guest" %></h4>
    </div>
    <div class="card-body">
      <form method="POST" action="${pageContext.request.contextPath}/admin/guests/<%= isEdit ? "update" : "save" %>">
        <% if (isEdit) { %>
        <input type="hidden" name="id" value="<%= guest.getId() %>">
        <% } %>

        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">First Name <span class="required-star">*</span></label>
            <input type="text" name="firstName" class="form-control"
                   value="<%= isEdit ? guest.getFirstName() : "" %>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Last Name <span class="required-star">*</span></label>
            <input type="text" name="lastName" class="form-control"
                   value="<%= isEdit ? guest.getLastName() : "" %>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control"
                   value="<%= isEdit ? guest.getEmail() : "" %>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone</label>
            <input type="text" name="phone" class="form-control"
                   value="<%= isEdit ? guest.getPhone() : "" %>">
          </div>
          <div class="col-12">
            <label class="form-label">Address</label>
            <input type="text" name="address" class="form-control"
                   value="<%= isEdit ? guest.getAddress() : "" %>">
          </div>
          <div class="col-md-4">
            <label class="form-label">City</label>
            <input type="text" name="city" class="form-control"
                   value="<%= isEdit ? guest.getCity() : "" %>">
          </div>
          <div class="col-md-4">
            <label class="form-label">Country</label>
            <input type="text" name="country" class="form-control"
                   value="<%= isEdit ? guest.getCountry() : "" %>">
          </div>
          <div class="col-md-4">
            <label class="form-label">Postal Code</label>
            <input type="text" name="postalCode" class="form-control"
                   value="<%= isEdit ? guest.getPostalCode() : "" %>">
          </div>
          <div class="col-md-6">
            <label class="form-label">ID Type</label>
            <select name="idCardType" class="form-select">
              <option value="">-- Select --</option>
              <option value="PASSPORT" <%= isEdit && "PASSPORT".equals(guest.getIdCardType()) ? "selected" : "" %>>Passport</option>
              <option value="NATIONAL_ID" <%= isEdit && "NATIONAL_ID".equals(guest.getIdCardType()) ? "selected" : "" %>>National ID</option>
              <option value="DRIVERS_LICENSE" <%= isEdit && "DRIVERS_LICENSE".equals(guest.getIdCardType()) ? "selected" : "" %>>Driver's License</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">ID Number</label>
            <input type="text" name="idCardNumber" class="form-control"
                   value="<%= isEdit ? guest.getIdCardNumber() : "" %>">
          </div>
          <div class="col-md-6">
            <label class="form-label">Loyalty Points</label>
            <input type="number" name="loyaltyPoints" class="form-control" min="0"
                   value="<%= isEdit ? guest.getLoyaltyPoints() : "0" %>">
          </div>
          <div class="col-md-6">
            <div class="form-check mt-4">
              <input type="checkbox" name="isVip" class="form-check-input"
                <%= isEdit && guest.getIsVip() ? "checked" : "" %>>
              <label class="form-check-label">VIP Guest</label>
            </div>
          </div>
          <div class="col-12">
            <label class="form-label">Notes</label>
            <textarea name="notes" class="form-control" rows="3"><%= isEdit ? guest.getNotes() : "" %></textarea>
          </div>
        </div>

        <div class="d-flex gap-3 justify-content-end mt-4">
          <a href="${pageContext.request.contextPath}/admin/guests" class="btn btn-secondary">
            <i class="fas fa-times me-1"></i>Cancel
          </a>
          <button type="submit" class="btn btn-primary">
            <i class="fas fa-save me-1"></i>
            <%= isEdit ? "Update Guest" : "Create Guest" %>
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>