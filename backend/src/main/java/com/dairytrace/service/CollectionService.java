
package com.dairytrace.service;

import com.dairytrace.dto.CollectionListResponse;
import com.dairytrace.dto.CollectionRequest;
import com.dairytrace.model.Collection;
import com.dairytrace.repository.CollectionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class CollectionService {

    private final CollectionRepository collectionRepository;

    public CollectionService(CollectionRepository collectionRepository) {
        this.collectionRepository = collectionRepository;
    }

    public Collection createCollection(CollectionRequest request) {

        if (collectionRepository.existsByCollectionCode(
                request.collectionCode())) {
            throw new IllegalArgumentException(
                    "Collection code already exists"
            );
        }

        Collection collection = new Collection();

        collection.setCollectionCode(request.collectionCode());
        collection.setFarmerId(request.farmerId());
        collection.setCenterId(request.centerId());
        collection.setOperatorId(request.operatorId());
        collection.setCollectionDate(request.collectionDate());
        collection.setCollectionTime(request.collectionTime());
        collection.setSession(request.session());
        collection.setQuantityLiters(request.quantityLiters());
        collection.setBatchId(request.batchId());

        LocalDateTime now = LocalDateTime.now();

        collection.setCreatedAt(now);
        collection.setUpdatedAt(now);

        return collectionRepository.save(collection);
    }

    public CollectionListResponse getCollections(int page, int size) {

        if (page < 0) {
            throw new IllegalArgumentException(
                    "Page must be zero or greater"
            );
        }

        if (size < 1 || size > 100) {
            throw new IllegalArgumentException(
                    "Size must be between 1 and 100"
            );
        }

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "collectionDate")
                        .and(Sort.by(
                                Sort.Direction.DESC,
                                "createdAt"
                        ))
        );

        Page<Collection> result =
                collectionRepository.findAll(pageable);

        return new CollectionListResponse(
                result.getContent(),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements(),
                result.getTotalPages(),
                result.hasNext()
        );
    }
}
