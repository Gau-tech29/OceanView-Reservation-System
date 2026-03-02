package com.oceanview.dto;

import java.time.LocalDate;

/**
 * DTO that carries search parameters from the search form
 * through the controller into the service/DAO layer.
 */
public class SearchCriteriaDTO {

    private String    searchType;
    private String    searchValue;
    private String    status;
    private String    paymentStatus;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private int       page = 1;
    private int       size = 10;

    public SearchCriteriaDTO() {}

    // ── Getters & Setters ─────────────────────────────────────────────────────────

    public String getSearchType()                   { return searchType; }
    public void setSearchType(String v)             { this.searchType = v; }

    public String getSearchValue()                  { return searchValue; }
    public void setSearchValue(String v)            { this.searchValue = v; }

    public String getStatus()                       { return status; }
    public void setStatus(String v)                 { this.status = v; }

    public String getPaymentStatus()                { return paymentStatus; }
    public void setPaymentStatus(String v)          { this.paymentStatus = v; }

    public LocalDate getCheckInDate()               { return checkInDate; }
    public void setCheckInDate(LocalDate v)         { this.checkInDate = v; }

    public LocalDate getCheckOutDate()              { return checkOutDate; }
    public void setCheckOutDate(LocalDate v)        { this.checkOutDate = v; }

    public int getPage()                            { return page; }
    public void setPage(int v)                      { this.page = v; }

    public int getSize()                            { return size; }
    public void setSize(int v)                      { this.size = v; }
}