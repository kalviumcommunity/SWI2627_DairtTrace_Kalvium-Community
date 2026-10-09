package com.dairytrace.dto;

import com.dairytrace.model.Collection;
import java.util.List;

public record CollectionListResponse(
        List<Collection> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasNext
) {}