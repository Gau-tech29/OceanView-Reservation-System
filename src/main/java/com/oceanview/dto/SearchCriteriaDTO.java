package com.oceanview.dto;

import java.time.LocalDate;

public class SearchCriteriaDTO {

    private String searchType;    // "number", "guest", "room", "date"
    private String searchValue;   // the actual keyword
    private String status;        // reservation_status filter
    private String paymentStatus; // payment_status filter
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private int page = 1;
    private int size = 10;

    public SearchCriteriaDTO() {}

    public String getSearchType() { return searchType; }
    public void setSearchType(String searchType) { this.searchType = searchType; }

    public String getSearchValue() { return searchValue; }
    public void setSearchValue(String searchValue) { this.searchValue = searchValue; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }

    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }

    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }

    public int getSize() { return size; }
    public void setSize(int size) { this.size = size; }
}
