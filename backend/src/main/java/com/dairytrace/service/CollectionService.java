package com.dairytrace.service;

import com.dairytrace.dto.CollectionRequest;
import com.dairytrace.model.Collection;
import com.dairytrace.repository.CollectionRepository;
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
}