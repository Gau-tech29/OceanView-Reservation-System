package com.oceanview.dto;

import java.time.LocalDateTime;

/**
 * Data-transfer object for Guest.
 * Used in form submissions and service layer communication.
 */
public class GuestDTO {

    private Long          id;
    private String        guestNumber;
    private String        firstName;
    private String        lastName;
    private String        email;
    private String        phone;
    private String        address;
    private String        city;
    private String        country;
    private String        postalCode;
    private String        idCardNumber;
    private String        idCardType;
    private Boolean       isVip;
    private Integer       loyaltyPoints;
    private String        notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public GuestDTO() {
        this.isVip         = false;
        this.loyaltyPoints = 0;
    }

    // ── Convenience ───────────────────────────────────────────────────────────────

    public String getFullName() {
        String fn = firstName != null ? firstName : "";
        String ln = lastName  != null ? lastName  : "";
        return (fn + " " + ln).trim();
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    public Long getId()                         { return id; }
    public void setId(Long id)                  { this.id = id; }

    public String getGuestNumber()              { return guestNumber; }
    public void setGuestNumber(String v)        { this.guestNumber = v; }

    public String getFirstName()                { return firstName; }
    public void setFirstName(String v)          { this.firstName = v; }

    public String getLastName()                 { return lastName; }
    public void setLastName(String v)           { this.lastName = v; }

    public String getEmail()                    { return email; }
    public void setEmail(String v)              { this.email = v; }

    public String getPhone()                    { return phone; }
    public void setPhone(String v)              { this.phone = v; }

    public String getAddress()                  { return address; }
    public void setAddress(String v)            { this.address = v; }

    public String getCity()                     { return city; }
    public void setCity(String v)               { this.city = v; }

    public String getCountry()                  { return country; }
    public void setCountry(String v)            { this.country = v; }

    public String getPostalCode()               { return postalCode; }
    public void setPostalCode(String v)         { this.postalCode = v; }

    public String getIdCardNumber()             { return idCardNumber; }
    public void setIdCardNumber(String v)       { this.idCardNumber = v; }

    public String getIdCardType()               { return idCardType; }
    public void setIdCardType(String v)         { this.idCardType = v; }

    public Boolean getIsVip()                   { return isVip; }
    public void setIsVip(Boolean v)             { this.isVip = v != null && v; }

    public Integer getLoyaltyPoints()           { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer v)     { this.loyaltyPoints = v != null ? v : 0; }

    public String getNotes()                    { return notes; }
    public void setNotes(String v)              { this.notes = v; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime v)   { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()         { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v)   { this.updatedAt = v; }
}