package com.dairytrace.service;

import com.dairytrace.dto.DashboardSummaryResponse;
import org.springframework.stereotype.Service;

@Service
public class DashboardService {

    public DashboardSummaryResponse getDashboardSummary() {
        // MVP baseline values.
        // These will be replaced with repository-backed aggregation
        // when collection, quality and batch modules are implemented.
        return new DashboardSummaryResponse(
                0,
                0.0,
                0,
                0
        );
    }
}