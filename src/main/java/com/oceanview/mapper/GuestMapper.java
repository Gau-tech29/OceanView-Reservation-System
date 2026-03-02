package com.oceanview.mapper;

import com.oceanview.dto.GuestDTO;
import com.oceanview.model.Guest;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Maps between Guest entity and GuestDTO.
 *
 * Note: idCardType is stored as a plain String in both Guest and GuestDTO
 * (the DB column is an ENUM but Java treats it as String — no IdCardType enum exists).
 */
public class GuestMapper {

    private static GuestMapper instance;

    private GuestMapper() {}

    public static synchronized GuestMapper getInstance() {
        if (instance == null) {
            instance = new GuestMapper();
        }
        return instance;
    }

    // ── Entity → DTO ─────────────────────────────────────────────────────────────

    public GuestDTO toDTO(Guest guest) {
        if (guest == null) return null;

        GuestDTO dto = new GuestDTO();
        dto.setId(guest.getId());
        dto.setGuestNumber(guest.getGuestNumber());
        dto.setFirstName(guest.getFirstName());
        dto.setLastName(guest.getLastName());
        dto.setEmail(guest.getEmail());
        dto.setPhone(guest.getPhone());
        dto.setAddress(guest.getAddress());
        dto.setCity(guest.getCity());
        dto.setCountry(guest.getCountry());
        dto.setPostalCode(guest.getPostalCode());
        dto.setIdCardNumber(guest.getIdCardNumber());
        // idCardType is already a String — no .name() call needed
        dto.setIdCardType(guest.getIdCardType());
        dto.setIsVip(guest.isVip());
        dto.setLoyaltyPoints(guest.getLoyaltyPoints());
        dto.setNotes(guest.getNotes());
        dto.setCreatedAt(guest.getCreatedAt());
        dto.setUpdatedAt(guest.getUpdatedAt());

        return dto;
    }

    // ── DTO → Entity ─────────────────────────────────────────────────────────────

    public Guest toEntity(GuestDTO dto) {
        if (dto == null) return null;

        Guest guest = new Guest();
        guest.setId(dto.getId());
        guest.setGuestNumber(dto.getGuestNumber());
        guest.setFirstName(dto.getFirstName());
        guest.setLastName(dto.getLastName());
        guest.setEmail(dto.getEmail());
        guest.setPhone(dto.getPhone());
        guest.setAddress(dto.getAddress());
        guest.setCity(dto.getCity());
        guest.setCountry(dto.getCountry());
        guest.setPostalCode(dto.getPostalCode());
        guest.setIdCardNumber(dto.getIdCardNumber());
        // idCardType is a plain String — assign directly, no enum conversion
        guest.setIdCardType(dto.getIdCardType());
        guest.setVip(dto.getIsVip() != null && dto.getIsVip());
        guest.setLoyaltyPoints(dto.getLoyaltyPoints() != null ? dto.getLoyaltyPoints() : 0);
        guest.setNotes(dto.getNotes());

        return guest;
    }

    // ── List helpers ──────────────────────────────────────────────────────────────

    public List<GuestDTO> toDTOList(List<Guest> guests) {
        return guests.stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<Guest> toEntityList(List<GuestDTO> dtos) {
        return dtos.stream().map(this::toEntity).collect(Collectors.toList());
    }
}