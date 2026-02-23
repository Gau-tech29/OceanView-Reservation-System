package com.oceanview.model;

import java.time.LocalDateTime;
import java.util.Objects;

public class Guest {
    private Long id;
    private String guestNumber;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String address;
    private String city;
    private String country;
    private String postalCode;
    private String idCardNumber;
    private IdCardType idCardType;
    private boolean isVip;
    private Integer loyaltyPoints;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public enum IdCardType {
        PASSPORT, NATIONAL_ID, DRIVERS_LICENSE
    }

    // Constructors
    public Guest() {
        this.loyaltyPoints = 0;
        this.isVip = false;
    }

    public Guest(String guestNumber, String firstName, String lastName,
                 String email, String phone) {
        this.guestNumber = guestNumber;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.loyaltyPoints = 0;
        this.isVip = false;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getGuestNumber() { return guestNumber; }
    public void setGuestNumber(String guestNumber) { this.guestNumber = guestNumber; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getFullName() { return firstName + " " + lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }

    public IdCardType getIdCardType() { return idCardType; }
    public void setIdCardType(IdCardType idCardType) { this.idCardType = idCardType; }

    public boolean isVip() { return isVip; }
    public void setVip(boolean vip) { isVip = vip; }

    public Integer getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public void addLoyaltyPoints(int points) {
        this.loyaltyPoints += points;
        updateVipStatus();
    }

    private void updateVipStatus() {
        // VIP status after 1000 points
        this.isVip = this.loyaltyPoints >= 1000;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Guest guest = (Guest) o;
        return Objects.equals(id, guest.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Guest{" +
                "id=" + id +
                ", guestNumber='" + guestNumber + '\'' +
                ", fullName='" + getFullName() + '\'' +
                ", email='" + email + '\'' +
                ", isVip=" + isVip +
                '}';
    }
}