package com.dairytrace.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record CollectionRequest(

        @NotBlank(message = "Collection code is required")
        String collectionCode,

        @NotNull(message = "Farmer ID is required")
        UUID farmerId,

        @NotNull(message = "Collection center ID is required")
        UUID centerId,

        @NotNull(message = "Operator ID is required")
        UUID operatorId,

        @NotNull(message = "Collection date is required")
        LocalDate collectionDate,

        @NotNull(message = "Collection time is required")
        LocalDateTime collectionTime,

        @NotBlank(message = "Session is required")
        String session,

        @NotNull(message = "Quantity is required")
        @DecimalMin(
                value = "0.01",
                message = "Quantity must be greater than 0"
        )
        BigDecimal quantityLiters,

        UUID batchId
) {
}