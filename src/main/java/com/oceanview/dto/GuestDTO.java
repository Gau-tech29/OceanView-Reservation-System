package com.oceanview.dto;

import java.time.LocalDateTime;

public class GuestDTO {
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
    private String idCardType;   // matches Guest.IdCardType enum name
    private Boolean isVip;
    private Integer loyaltyPoints;
    private String notes;
    private Integer totalStays;
    private LocalDateTime lastStay;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public GuestDTO() {}

    public GuestDTO(Long id, String guestNumber, String firstName, String lastName,
                    String email, String phone) {
        this.id = id;
        this.guestNumber = guestNumber;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
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

    public String getIdCardType() { return idCardType; }
    public void setIdCardType(String idCardType) { this.idCardType = idCardType; }

    public Boolean getIsVip() { return isVip; }
    public void setIsVip(Boolean isVip) { this.isVip = isVip; }

    public Integer getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getTotalStays() { return totalStays; }
    public void setTotalStays(Integer totalStays) { this.totalStays = totalStays; }

    public LocalDateTime getLastStay() { return lastStay; }
    public void setLastStay(LocalDateTime lastStay) { this.lastStay = lastStay; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Helper methods
    public String getFullName() {
        return firstName + " " + lastName;
    }
}