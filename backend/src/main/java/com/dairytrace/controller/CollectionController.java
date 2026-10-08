package com.dairytrace.controller;

import com.dairytrace.dto.CollectionRequest;
import com.dairytrace.model.Collection;
import com.dairytrace.service.CollectionService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/collections")
public class CollectionController {

    private final CollectionService collectionService;

    public CollectionController(CollectionService collectionService) {
        this.collectionService = collectionService;
    }

    @PostMapping
    public ResponseEntity<Collection> createCollection(
            @Valid @RequestBody CollectionRequest request) {

        Collection collection =
                collectionService.createCollection(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(collection);
    }
}