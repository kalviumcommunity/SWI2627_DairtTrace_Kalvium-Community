package com.dairytrace.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "collection")
public class Collection {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "collection_code", nullable = false, unique = true, length = 50)
    private String collectionCode;

    @Column(name = "farmer_id", nullable = false)
    private UUID farmerId;

    @Column(name = "center_id", nullable = false)
    private UUID centerId;

    @Column(name = "operator_id", nullable = false)
    private UUID operatorId;

    @Column(name = "collection_date", nullable = false)
    private LocalDate collectionDate;

    @Column(name = "collection_time", nullable = false)
    private LocalDateTime collectionTime;

    @Column(name = "session", nullable = false, length = 20)
    private String session;

    @Column(name = "quantity_liters", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityLiters;

    @Column(name = "batch_id")
    private UUID batchId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // Getters and setters
}