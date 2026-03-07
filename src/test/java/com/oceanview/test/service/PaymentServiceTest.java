package com.oceanview.test.service;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.dto.PaymentDTO;
import com.oceanview.model.Payment;
import com.oceanview.service.PaymentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class PaymentServiceTest {

    @Mock
    private PaymentDAO paymentDAO;

    private PaymentService paymentService;

    @BeforeEach
    void setUp() {
        paymentService = new PaymentService(paymentDAO);
    }

    // ── Create ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Create payment with valid data should succeed")
    void createPayment_WithValidData_ShouldReturnPayment() throws Exception {
        Payment payment = new Payment();
        payment.setReservationId(1L);
        payment.setAmount(new BigDecimal("500.00"));
        payment.setPaymentMethod(Payment.PaymentMethod.CASH);

        Payment savedPayment = new Payment();
        savedPayment.setId(1L);
        savedPayment.setPaymentNumber("PAY-123456");
        savedPayment.setAmount(new BigDecimal("500.00"));

        when(paymentDAO.save(any(Payment.class))).thenReturn(savedPayment);

        Payment result = paymentService.createPayment(payment);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertNotNull(result.getPaymentNumber());
        verify(paymentDAO).save(any(Payment.class));
    }

    // KEY FIX: declare throws Exception on the test method itself.
    // JUnit 5 handles it — no try/catch needed inside assertThrows.

    @Test
    @DisplayName("Create payment with zero amount should throw exception")
    void createPayment_WithZeroAmount_ShouldThrowException() throws Exception {
        Payment payment = new Payment();
        payment.setReservationId(1L);
        payment.setAmount(BigDecimal.ZERO);
        payment.setPaymentMethod(Payment.PaymentMethod.CASH);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.createPayment(payment));

        assertTrue(ex.getMessage().contains("greater than zero"));
        verify(paymentDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create payment with null amount should throw exception")
    void createPayment_WithNullAmount_ShouldThrowException() throws Exception {
        Payment payment = new Payment();
        payment.setReservationId(1L);
        payment.setAmount(null);
        payment.setPaymentMethod(Payment.PaymentMethod.CASH);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.createPayment(payment));

        assertTrue(ex.getMessage().contains("greater than zero"));
        verify(paymentDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create payment with null payment method should throw exception")
    void createPayment_WithNullPaymentMethod_ShouldThrowException() throws Exception {
        Payment payment = new Payment();
        payment.setReservationId(1L);
        payment.setAmount(new BigDecimal("100.00"));
        payment.setPaymentMethod(null);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.createPayment(payment));

        assertTrue(ex.getMessage().contains("Payment method is required"));
        verify(paymentDAO, never()).save(any());
    }

    @Test
    @DisplayName("Create payment without payment number should auto-generate one")
    void createPayment_WithoutPaymentNumber_ShouldGenerateNumber() throws Exception {
        Payment payment = new Payment();
        payment.setReservationId(1L);
        payment.setAmount(new BigDecimal("300.00"));
        payment.setPaymentMethod(Payment.PaymentMethod.CREDIT_CARD);

        Payment savedPayment = new Payment();
        savedPayment.setId(2L);
        savedPayment.setPaymentNumber("PAY-AUTOGEN");

        when(paymentDAO.save(any(Payment.class))).thenReturn(savedPayment);

        Payment result = paymentService.createPayment(payment);

        verify(paymentDAO).save(argThat(p ->
                p.getPaymentNumber() != null && p.getPaymentNumber().startsWith("PAY-")));
        assertNotNull(result);
    }

    // ── Refund ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Process refund for completed payment should succeed")
    void processRefund_ForCompletedPayment_ShouldMarkRefunded() throws Exception {
        Long id = 1L;
        String reason = "Customer requested cancellation";

        Payment payment = new Payment();
        payment.setId(id);
        payment.setPaymentNumber("PAY-123456");
        payment.setPaymentStatus(Payment.PaymentStatus.COMPLETED);
        payment.setAmount(new BigDecimal("500.00"));

        when(paymentDAO.findById(id)).thenReturn(Optional.of(payment));
        when(paymentDAO.update(any(Payment.class))).thenAnswer(inv -> inv.getArgument(0));

        Payment result = paymentService.processRefund(id, reason);

        assertNotNull(result);
        assertEquals(Payment.PaymentStatus.REFUNDED, result.getPaymentStatus());
        assertNotNull(result.getNotes());
        assertTrue(result.getNotes().contains(reason));
        verify(paymentDAO).update(any(Payment.class));
    }

    @Test
    @DisplayName("Process refund for pending payment should throw exception")
    void processRefund_ForPendingPayment_ShouldThrowException() throws Exception {
        Long id = 1L;
        Payment payment = new Payment();
        payment.setId(id);
        payment.setPaymentStatus(Payment.PaymentStatus.PENDING);

        when(paymentDAO.findById(id)).thenReturn(Optional.of(payment));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.processRefund(id, "Test reason"));

        assertTrue(ex.getMessage().contains("Only completed payments"));
        verify(paymentDAO, never()).update(any());
    }

    @Test
    @DisplayName("Process refund for already-refunded payment should throw exception")
    void processRefund_ForAlreadyRefundedPayment_ShouldThrowException() throws Exception {
        Long id = 1L;
        Payment payment = new Payment();
        payment.setId(id);
        payment.setPaymentStatus(Payment.PaymentStatus.REFUNDED);

        when(paymentDAO.findById(id)).thenReturn(Optional.of(payment));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.processRefund(id, "Double refund attempt"));

        assertTrue(ex.getMessage().contains("already been refunded"));
        verify(paymentDAO, never()).update(any());
    }

    @Test
    @DisplayName("Process refund for non-existing payment should throw exception")
    void processRefund_ForNonExistingPayment_ShouldThrowException() throws Exception {
        Long id = 999L;
        when(paymentDAO.findById(id)).thenReturn(Optional.empty());

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> paymentService.processRefund(id, "reason"));

        assertTrue(ex.getMessage().contains("Payment not found"));
        verify(paymentDAO, never()).update(any());
    }

    // ── Read by ID ────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get payment DTO by ID when exists should return DTO")
    void getPaymentDTOById_WhenExists_ShouldReturnDTO() throws Exception {
        Long id = 1L;
        PaymentDTO dto = new PaymentDTO();
        dto.setId(id);
        dto.setPaymentNumber("PAY-123456");
        dto.setAmount(new BigDecimal("500.00"));

        when(paymentDAO.findPaymentDTOById(id)).thenReturn(Optional.of(dto));

        Optional<PaymentDTO> result = paymentService.getPaymentDTOById(id);

        assertTrue(result.isPresent());
        assertEquals(id, result.get().getId());
        assertEquals("PAY-123456", result.get().getPaymentNumber());
        verify(paymentDAO).findPaymentDTOById(id);
    }

    @Test
    @DisplayName("Get payment DTO by ID when not exists should return empty")
    void getPaymentDTOById_WhenNotExists_ShouldReturnEmpty() throws Exception {
        Long id = 999L;
        when(paymentDAO.findPaymentDTOById(id)).thenReturn(Optional.empty());

        Optional<PaymentDTO> result = paymentService.getPaymentDTOById(id);

        assertFalse(result.isPresent());
        verify(paymentDAO).findPaymentDTOById(id);
    }

    // ── Read raw Payment ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get payment by ID when exists should return Payment")
    void getPaymentById_WhenExists_ShouldReturnPayment() throws Exception {
        Long id = 1L;
        Payment payment = new Payment();
        payment.setId(id);
        payment.setPaymentNumber("PAY-XYZ");

        when(paymentDAO.findById(id)).thenReturn(Optional.of(payment));

        Optional<Payment> result = paymentService.getPaymentById(id);

        assertTrue(result.isPresent());
        assertEquals(id, result.get().getId());
    }

    @Test
    @DisplayName("Get payment by number when exists should return Payment")
    void getPaymentByNumber_WhenExists_ShouldReturnPayment() throws Exception {
        String number = "PAY-ABC123";
        Payment payment = new Payment();
        payment.setId(1L);
        payment.setPaymentNumber(number);

        when(paymentDAO.findByPaymentNumber(number)).thenReturn(Optional.of(payment));

        Optional<Payment> result = paymentService.getPaymentByNumber(number);

        assertTrue(result.isPresent());
        assertEquals(number, result.get().getPaymentNumber());
    }

    // ── Counts ────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get total payments count should return correct count")
    void getTotalPaymentsCount_ShouldReturnCount() throws Exception {
        when(paymentDAO.countPayments()).thenReturn(100L);

        long count = paymentService.getTotalPaymentsCount();

        assertEquals(100L, count);
        verify(paymentDAO).countPayments();
    }

    // ── Revenue ───────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Get total revenue for date range should return sum")
    void getTotalRevenue_ForDateRange_ShouldReturnSum() throws Exception {
        LocalDateTime start = LocalDateTime.now().minusDays(30);
        LocalDateTime end   = LocalDateTime.now();

        when(paymentDAO.getTotalPaymentsByDateRange(start, end)).thenReturn(9500.75);

        double result = paymentService.getTotalRevenue(start, end);

        assertEquals(9500.75, result, 0.001);
        verify(paymentDAO).getTotalPaymentsByDateRange(start, end);
    }

    @Test
    @DisplayName("Get total refunded amount should return correct sum")
    void getTotalRefundedAmount_ShouldReturnSum() throws Exception {
        LocalDateTime start = LocalDateTime.now().minusDays(30);
        LocalDateTime end   = LocalDateTime.now();

        when(paymentDAO.getTotalRefundedAmount(start, end)).thenReturn(250.00);

        double result = paymentService.getTotalRefundedAmount(start, end);

        assertEquals(250.00, result, 0.001);
    }

    // ── Search / List ─────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Search payments by date range should return results")
    void searchPayments_ByDateRange_ShouldReturnResults() throws Exception {
        LocalDate startDate = LocalDate.now().minusDays(7);
        LocalDate endDate   = LocalDate.now();

        List<PaymentDTO> mockResults = Arrays.asList(
                createMockPaymentDTO(1L, "PAY-001", new BigDecimal("100.00")),
                createMockPaymentDTO(2L, "PAY-002", new BigDecimal("200.00"))
        );

        when(paymentDAO.searchPaymentDTOs(any(), any(), any(), any(), any()))
                .thenReturn(mockResults);

        List<PaymentDTO> results = paymentService.searchPayments(
                null, null, null, startDate, endDate);

        assertEquals(2, results.size());
        verify(paymentDAO).searchPaymentDTOs(any(), any(), any(), any(), any());
    }

    @Test
    @DisplayName("Get payments by reservation should return list")
    void getPaymentsByReservation_ShouldReturnList() throws Exception {
        Long reservationId = 5L;
        Payment p1 = new Payment(); p1.setId(1L); p1.setReservationId(reservationId);
        Payment p2 = new Payment(); p2.setId(2L); p2.setReservationId(reservationId);

        when(paymentDAO.findByReservationId(reservationId)).thenReturn(Arrays.asList(p1, p2));

        List<Payment> results = paymentService.getPaymentsByReservation(reservationId);

        assertEquals(2, results.size());
        verify(paymentDAO).findByReservationId(reservationId);
    }

    @Test
    @DisplayName("Get recent payment DTOs should return limited list")
    void getRecentPaymentDTOs_ShouldReturnLimitedList() throws Exception {
        int limit = 5;
        List<PaymentDTO> mockList = Arrays.asList(
                createMockPaymentDTO(1L, "PAY-001", new BigDecimal("100.00")),
                createMockPaymentDTO(2L, "PAY-002", new BigDecimal("200.00"))
        );

        when(paymentDAO.findRecentPaymentDTOs(limit)).thenReturn(mockList);

        List<PaymentDTO> results = paymentService.getRecentPaymentDTOs(limit);

        assertEquals(2, results.size());
        verify(paymentDAO).findRecentPaymentDTOs(limit);
    }

    @Test
    @DisplayName("Update payment status should delegate to DAO")
    void updatePaymentStatus_ShouldCallDAO() throws Exception {
        Long id = 1L;
        when(paymentDAO.updateStatus(id, Payment.PaymentStatus.COMPLETED)).thenReturn(true);

        boolean result = paymentService.updatePaymentStatus(id, Payment.PaymentStatus.COMPLETED);

        assertTrue(result);
        verify(paymentDAO).updateStatus(id, Payment.PaymentStatus.COMPLETED);
    }

    // ── Helper ────────────────────────────────────────────────────────────────────

    private PaymentDTO createMockPaymentDTO(Long id, String number, BigDecimal amount) {
        PaymentDTO dto = new PaymentDTO();
        dto.setId(id);
        dto.setPaymentNumber(number);
        dto.setAmount(amount);
        return dto;
    }
}