package com.oceanview.mapper;

import com.oceanview.dto.GuestDTO;
import com.oceanview.model.Guest;

import java.util.List;
import java.util.stream.Collectors;

public class GuestMapper {

    private static GuestMapper instance;

    private GuestMapper() {}

    public static synchronized GuestMapper getInstance() {
        if (instance == null) {
            instance = new GuestMapper();
        }
        return instance;
    }

    public GuestDTO toDTO(Guest guest) {
        if (guest == null) {
            return null;
        }

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
        dto.setIdCardType(guest.getIdCardType() != null ? guest.getIdCardType().name() : null);
        dto.setIsVip(guest.isVip());
        dto.setLoyaltyPoints(guest.getLoyaltyPoints());
        dto.setNotes(guest.getNotes());
        dto.setCreatedAt(guest.getCreatedAt());
        dto.setUpdatedAt(guest.getUpdatedAt());

        return dto;
    }

    public List<GuestDTO> toDTOList(List<Guest> guests) {
        return guests.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public Guest toEntity(GuestDTO dto) {
        if (dto == null) {
            return null;
        }

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

        if (dto.getIdCardType() != null && !dto.getIdCardType().isEmpty()) {
            guest.setIdCardType(Guest.IdCardType.valueOf(dto.getIdCardType()));
        }

        guest.setVip(dto.getIsVip() != null ? dto.getIsVip() : false);
        guest.setLoyaltyPoints(dto.getLoyaltyPoints() != null ? dto.getLoyaltyPoints() : 0);
        guest.setNotes(dto.getNotes());

        return guest;
    }
}