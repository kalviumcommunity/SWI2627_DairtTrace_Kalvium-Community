package com.dairytrace.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

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

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getCollectionCode() {
        return collectionCode;
    }

    public void setCollectionCode(String collectionCode) {
        this.collectionCode = collectionCode;
    }

    public UUID getFarmerId() {
        return farmerId;
    }

    public void setFarmerId(UUID farmerId) {
        this.farmerId = farmerId;
    }

    public UUID getCenterId() {
        return centerId;
    }

    public void setCenterId(UUID centerId) {
        this.centerId = centerId;
    }

    public UUID getOperatorId() {
        return operatorId;
    }

    public void setOperatorId(UUID operatorId) {
        this.operatorId = operatorId;
    }

    public LocalDate getCollectionDate() {
        return collectionDate;
    }

    public void setCollectionDate(LocalDate collectionDate) {
        this.collectionDate = collectionDate;
    }

    public LocalDateTime getCollectionTime() {
        return collectionTime;
    }

    public void setCollectionTime(LocalDateTime collectionTime) {
        this.collectionTime = collectionTime;
    }

    public String getSession() {
        return session;
    }

    public void setSession(String session) {
        this.session = session;
    }

    public BigDecimal getQuantityLiters() {
        return quantityLiters;
    }

    public void setQuantityLiters(BigDecimal quantityLiters) {
        this.quantityLiters = quantityLiters;
    }

    public UUID getBatchId() {
        return batchId;
    }

    public void setBatchId(UUID batchId) {
        this.batchId = batchId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}