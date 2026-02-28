package com.oceanview.mapper;

import com.oceanview.dto.ReservationDTO;
import com.oceanview.model.Reservation;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * ReservationMapper — converts between Reservation model and ReservationDTO.
 *
 * Guest name / room number fields are populated by ReservationDAOImpl
 * via JOIN queries, so toEntity() only maps core reservation columns.
 */
public class ReservationMapper {

    private static ReservationMapper instance;

    private ReservationMapper() {}

    public static synchronized ReservationMapper getInstance() {
        if (instance == null) {
            instance = new ReservationMapper();
        }
        return instance;
    }

    // ── DTO → Entity ────────────────────────────────────────────────
    public Reservation toEntity(ReservationDTO dto) {
        if (dto == null) return null;

        Reservation r = new Reservation();
        r.setId(dto.getId());
        r.setReservationNumber(dto.getReservationNumber());
        r.setGuestId(dto.getGuestId());
        r.setUserId(dto.getUserId());
        r.setRoomId(dto.getRoomId());
        r.setCheckInDate(dto.getCheckInDate());
        r.setCheckOutDate(dto.getCheckOutDate());
        r.setAdults(dto.getAdults() != null ? dto.getAdults() : 1);
        r.setChildren(dto.getChildren() != null ? dto.getChildren() : 0);
        r.setTotalNights(dto.getTotalNights());
        r.setRoomPrice(dto.getRoomPrice());
        r.setTaxAmount(dto.getTaxAmount() != null ? dto.getTaxAmount() : BigDecimal.ZERO);
        r.setDiscountAmount(dto.getDiscountAmount() != null ? dto.getDiscountAmount() : BigDecimal.ZERO);
        r.setSubtotal(dto.getSubtotal());
        r.setTotalAmount(dto.getTotalAmount());
        r.setSpecialRequests(dto.getSpecialRequests());

        if (dto.getSource() != null) {
            try { r.setSource(Reservation.ReservationSource.valueOf(dto.getSource())); }
            catch (IllegalArgumentException ignored) { r.setSource(Reservation.ReservationSource.WALK_IN); }
        }

        if (dto.getPaymentStatus() != null) {
            try { r.setPaymentStatus(Reservation.PaymentStatus.valueOf(dto.getPaymentStatus())); }
            catch (IllegalArgumentException ignored) {}
        }
        if (dto.getReservationStatus() != null) {
            try { r.setReservationStatus(Reservation.ReservationStatus.valueOf(dto.getReservationStatus())); }
            catch (IllegalArgumentException ignored) {}
        }

        return r;
    }

    // ── Entity → DTO ────────────────────────────────────────────────
    public ReservationDTO toDTO(Reservation r) {
        if (r == null) return null;

        ReservationDTO dto = new ReservationDTO();
        dto.setId(r.getId());
        dto.setReservationNumber(r.getReservationNumber());
        dto.setGuestId(r.getGuestId());
        dto.setUserId(r.getUserId());
        dto.setRoomId(r.getRoomId());
        dto.setCheckInDate(r.getCheckInDate());
        dto.setCheckOutDate(r.getCheckOutDate());
        dto.setTotalNights(r.getTotalNights());
        dto.setAdults(r.getAdults());
        dto.setChildren(r.getChildren());
        dto.setRoomPrice(r.getRoomPrice());
        dto.setTaxAmount(r.getTaxAmount());
        dto.setDiscountAmount(r.getDiscountAmount());
        dto.setSubtotal(r.getSubtotal());
        dto.setTotalAmount(r.getTotalAmount());
        dto.setSpecialRequests(r.getSpecialRequests());
        dto.setSource(r.getSource() != null ? r.getSource().name() : null);
        dto.setPaymentStatus(r.getPaymentStatus() != null ? r.getPaymentStatus().name() : null);
        dto.setReservationStatus(r.getReservationStatus() != null ? r.getReservationStatus().name() : null);
        dto.setCreatedAt(r.getCreatedAt());
        dto.setUpdatedAt(r.getUpdatedAt());

        return dto;
    }

    public List<ReservationDTO> toDTOList(List<Reservation> list) {
        return list.stream().map(this::toDTO).collect(Collectors.toList());
    }
}