package com.dairytrace.repository;

import com.dairytrace.model.Collection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CollectionRepository extends JpaRepository<Collection, UUID> {

    boolean existsByCollectionCode(String collectionCode);
}