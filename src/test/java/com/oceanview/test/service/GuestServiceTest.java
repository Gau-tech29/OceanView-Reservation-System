package com.oceanview.test.service;

import com.oceanview.dao.GuestDAO;
import com.oceanview.dto.GuestDTO;
import com.oceanview.model.Guest;
import com.oceanview.service.GuestService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.lang.reflect.Field;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class GuestServiceTest {

    @Mock
    private GuestDAO guestDAO;

    private GuestService guestService;

    @BeforeEach
    void setUp() throws Exception {
        // GuestService has no injectable constructor, so inject mock via reflection
        guestService = new GuestService();
        Field daoField = GuestService.class.getDeclaredField("guestDAO");
        daoField.setAccessible(true);
        daoField.set(guestService, guestDAO);
    }

    // ── Create ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Create guest with valid data should succeed")
    void createGuest_WithValidData_ShouldReturnDTO() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("John");
        dto.setLastName("Doe");
        dto.setEmail("john@email.com");
        dto.setPhone("1234567890");

        when(guestDAO.findByEmail("john@email.com")).thenReturn(Optional.empty());

        Guest savedGuest = new Guest();
        savedGuest.setId(1L);
        savedGuest.setGuestNumber("GST-001");
        savedGuest.setFirstName("John");
        savedGuest.setLastName("Doe");

        when(guestDAO.save(any(Guest.class))).thenReturn(savedGuest);

        // Act
        GuestDTO result = guestService.createGuest(dto);

        // Assert
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("GST-001", result.getGuestNumber());
        assertEquals("John", result.getFirstName());
        assertEquals("Doe", result.getLastName());
        verify(guestDAO).save(any(Guest.class));
    }

    @Test
    @DisplayName("Create guest with missing first name should throw exception")
    void createGuest_WithMissingFirstName_ShouldThrowException() {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("");
        dto.setLastName("Doe");
        dto.setEmail("john@email.com");

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.createGuest(dto));

        assertTrue(exception.getMessage().contains("First name is required"));
        verifyNoInteractions(guestDAO);
    }

    @Test
    @DisplayName("Create guest with missing last name should throw exception")
    void createGuest_WithMissingLastName_ShouldThrowException() {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("John");
        dto.setLastName(null);
        dto.setEmail("john@email.com");

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.createGuest(dto));

        assertTrue(exception.getMessage().contains("Last name is required"));
        verifyNoInteractions(guestDAO);
    }

    @Test
    @DisplayName("Create guest with duplicate email should throw exception")
    void createGuest_WithDuplicateEmail_ShouldThrowException() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("John");
        dto.setLastName("Doe");
        dto.setEmail("existing@email.com");

        Guest existing = new Guest();
        existing.setId(1L);
        existing.setEmail("existing@email.com");

        when(guestDAO.findByEmail("existing@email.com")).thenReturn(Optional.of(existing));

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.createGuest(dto));

        assertTrue(exception.getMessage().contains("already exists"));
        verify(guestDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create guest without email should skip email uniqueness check")
    void createGuest_WithoutEmail_ShouldSkipEmailCheck() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("Jane");
        dto.setLastName("Smith");
        // No email

        Guest savedGuest = new Guest();
        savedGuest.setId(2L);
        savedGuest.setGuestNumber("GST-002");
        savedGuest.setFirstName("Jane");
        savedGuest.setLastName("Smith");

        when(guestDAO.save(any(Guest.class))).thenReturn(savedGuest);

        // Act
        GuestDTO result = guestService.createGuest(dto);

        // Assert
        assertNotNull(result);
        assertEquals(2L, result.getId());
        verify(guestDAO, never()).findByEmail(any());
        verify(guestDAO).save(any(Guest.class));
    }

    // ── Read ──────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get guest by ID when exists should return DTO")
    void getGuestById_WhenExists_ShouldReturnDTO() throws Exception {
        // Arrange
        Long id = 1L;
        Guest guest = new Guest();
        guest.setId(id);
        guest.setFirstName("John");
        guest.setLastName("Doe");
        guest.setEmail("john@email.com");

        when(guestDAO.findById(id)).thenReturn(Optional.of(guest));

        // Act
        Optional<GuestDTO> result = guestService.getGuestById(id);

        // Assert
        assertTrue(result.isPresent());
        assertEquals(id, result.get().getId());
        assertEquals("John", result.get().getFirstName());
        assertEquals("Doe", result.get().getLastName());
        verify(guestDAO).findById(id);
    }

    @Test
    @DisplayName("Get guest by ID when not exists should return empty")
    void getGuestById_WhenNotExists_ShouldReturnEmpty() throws Exception {
        // Arrange
        Long id = 999L;
        when(guestDAO.findById(id)).thenReturn(Optional.empty());

        // Act
        Optional<GuestDTO> result = guestService.getGuestById(id);

        // Assert
        assertFalse(result.isPresent());
        verify(guestDAO).findById(id);
    }

    @Test
    @DisplayName("Get guest by email when exists should return DTO")
    void getGuestByEmail_WhenExists_ShouldReturnDTO() throws Exception {
        // Arrange
        String email = "john@email.com";
        Guest guest = new Guest();
        guest.setId(1L);
        guest.setEmail(email);
        guest.setFirstName("John");
        guest.setLastName("Doe");

        when(guestDAO.findByEmail(email)).thenReturn(Optional.of(guest));

        // Act
        Optional<GuestDTO> result = guestService.getGuestByEmail(email);

        // Assert
        assertTrue(result.isPresent());
        assertEquals(email, result.get().getEmail());
    }

    @Test
    @DisplayName("Get all guests should return list of DTOs")
    void getAllGuests_ShouldReturnList() throws Exception {
        // Arrange
        Guest g1 = new Guest(); g1.setId(1L); g1.setFirstName("John"); g1.setLastName("Doe");
        Guest g2 = new Guest(); g2.setId(2L); g2.setFirstName("Jane"); g2.setLastName("Smith");

        when(guestDAO.findAll()).thenReturn(Arrays.asList(g1, g2));

        // Act
        List<GuestDTO> result = guestService.getAllGuests();

        // Assert
        assertEquals(2, result.size());
        verify(guestDAO).findAll();
    }

    @Test
    @DisplayName("Search guests by keyword should return matching results")
    void searchGuests_WithKeyword_ShouldReturnMatching() throws Exception {
        // Arrange
        String keyword = "john";

        Guest guest1 = new Guest();
        guest1.setId(1L);
        guest1.setFirstName("John");
        guest1.setLastName("Doe");

        Guest guest2 = new Guest();
        guest2.setId(2L);
        guest2.setFirstName("Johnny");
        guest2.setLastName("Smith");

        when(guestDAO.searchGuests(keyword)).thenReturn(Arrays.asList(guest1, guest2));

        // Act
        List<GuestDTO> results = guestService.searchGuests(keyword);

        // Assert
        assertEquals(2, results.size());
        verify(guestDAO).searchGuests(keyword);
    }

    // ── Update ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Update guest with valid data should succeed")
    void updateGuest_WithValidData_ShouldUpdate() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setId(1L);
        dto.setFirstName("John");
        dto.setLastName("Updated");
        dto.setEmail("john.updated@email.com");

        Guest existingGuest = new Guest();
        existingGuest.setId(1L);
        existingGuest.setEmail("john.old@email.com");
        existingGuest.setGuestNumber("GST-001");

        when(guestDAO.findById(1L)).thenReturn(Optional.of(existingGuest));
        when(guestDAO.findByEmail("john.updated@email.com")).thenReturn(Optional.empty());

        // Act
        GuestDTO result = guestService.updateGuest(dto);

        // Assert
        assertNotNull(result);
        assertEquals("Updated", result.getLastName());
        verify(guestDAO).update(any(Guest.class));
    }

    @Test
    @DisplayName("Update guest without ID should throw exception")
    void updateGuest_WithoutId_ShouldThrowException() {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setFirstName("John");
        dto.setLastName("Doe");
        // No ID set

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.updateGuest(dto));

        assertTrue(exception.getMessage().contains("Guest ID is required"));
    }

    @Test
    @DisplayName("Update guest with non-existing ID should throw exception")
    void updateGuest_WithNonExistingId_ShouldThrowException() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setId(999L);
        dto.setFirstName("John");
        dto.setLastName("Doe");

        when(guestDAO.findById(999L)).thenReturn(Optional.empty());

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.updateGuest(dto));

        assertTrue(exception.getMessage().contains("Guest not found"));
    }

    @Test
    @DisplayName("Update guest with conflicting email should throw exception")
    void updateGuest_WithConflictingEmail_ShouldThrowException() throws Exception {
        // Arrange
        GuestDTO dto = new GuestDTO();
        dto.setId(1L);
        dto.setFirstName("John");
        dto.setLastName("Doe");
        dto.setEmail("taken@email.com");

        Guest existingGuest = new Guest();
        existingGuest.setId(1L);
        existingGuest.setEmail("original@email.com");

        Guest conflictGuest = new Guest();
        conflictGuest.setId(2L);
        conflictGuest.setEmail("taken@email.com");

        when(guestDAO.findById(1L)).thenReturn(Optional.of(existingGuest));
        when(guestDAO.findByEmail("taken@email.com")).thenReturn(Optional.of(conflictGuest));

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () ->
                guestService.updateGuest(dto));

        assertTrue(exception.getMessage().contains("already in use"));
        verify(guestDAO, never()).update(any());
    }

    // ── Delete ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Delete guest should call DAO delete and return true")
    void deleteGuest_ShouldCallDAO() throws Exception {
        // Arrange
        Long id = 1L;
        when(guestDAO.delete(id)).thenReturn(true);

        // Act
        boolean result = guestService.deleteGuest(id);

        // Assert
        assertTrue(result);
        verify(guestDAO).delete(id);
    }

    @Test
    @DisplayName("Delete non-existing guest should return false")
    void deleteGuest_WhenNotExists_ShouldReturnFalse() throws Exception {
        // Arrange
        Long id = 999L;
        when(guestDAO.delete(id)).thenReturn(false);

        // Act
        boolean result = guestService.deleteGuest(id);

        // Assert
        assertFalse(result);
        verify(guestDAO).delete(id);
    }

    // ── Counts ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get total guests count should return correct count")
    void getTotalGuestsCount_ShouldReturnCount() throws Exception {
        // Arrange
        when(guestDAO.count()).thenReturn(42L);

        // Act
        long count = guestService.getTotalGuestsCount();

        // Assert
        assertEquals(42L, count);
        verify(guestDAO).count();
    }

    @Test
    @DisplayName("Get active guests count should return correct count")
    void getActiveGuestsCount_ShouldReturnCount() throws Exception {
        // Arrange
        when(guestDAO.countActiveGuests()).thenReturn(15L);

        // Act
        long count = guestService.getActiveGuestsCount();

        // Assert
        assertEquals(15L, count);
        verify(guestDAO).countActiveGuests();
    }

    // ── Mapper ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("toDTO should correctly map all Guest fields to GuestDTO")
    void toDTO_ShouldMapAllFields() {
        // Arrange
        Guest guest = new Guest();
        guest.setId(5L);
        guest.setGuestNumber("GST-005");
        guest.setFirstName("Alice");
        guest.setLastName("Wonder");
        guest.setEmail("alice@example.com");
        guest.setPhone("9876543210");
        guest.setAddress("123 Main St");
        guest.setCity("Colombo");
        guest.setCountry("Sri Lanka");
        guest.setPostalCode("10100");
        guest.setIdCardNumber("ID123456");
        guest.setIdCardType("NIC");
        guest.setVip(true);
        guest.setLoyaltyPoints(500);
        guest.setNotes("VIP guest");

        // Act
        GuestDTO dto = guestService.toDTO(guest);

        // Assert
        assertEquals(5L, dto.getId());
        assertEquals("GST-005", dto.getGuestNumber());
        assertEquals("Alice", dto.getFirstName());
        assertEquals("Wonder", dto.getLastName());
        assertEquals("alice@example.com", dto.getEmail());
        assertEquals("9876543210", dto.getPhone());
        assertEquals("123 Main St", dto.getAddress());
        assertEquals("Colombo", dto.getCity());
        assertEquals("Sri Lanka", dto.getCountry());
        assertEquals("10100", dto.getPostalCode());
        assertEquals("ID123456", dto.getIdCardNumber());
        assertEquals("NIC", dto.getIdCardType());
        assertTrue(dto.getIsVip());
        assertEquals(500, dto.getLoyaltyPoints());
        assertEquals("VIP guest", dto.getNotes());
    }

    @Test
    @DisplayName("toDTO with null guest should return null")
    void toDTO_WithNullGuest_ShouldReturnNull() {
        assertNull(guestService.toDTO(null));
    }
}