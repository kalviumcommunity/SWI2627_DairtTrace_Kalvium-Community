package com.dairytrace.dto;

public record DashboardSummaryResponse(
        long todayCollections,
        double totalMilkLiters,
        long qualityAlerts,
        long activeBatches
) {
}