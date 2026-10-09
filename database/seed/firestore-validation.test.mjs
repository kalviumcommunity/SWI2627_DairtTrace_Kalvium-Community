import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const fixture = JSON.parse(
  await readFile(new URL("./firestore-validation-fixtures.json", import.meta.url), "utf8"),
);
const seed = fixture.seedDocuments;

const ids = (collection) => new Set(seed[collection].map(({ id }) => id));
const hasDocument = (collection, id) => ids(collection).has(id);
const isDate = (value) =>
  typeof value === "string" &&
  /^\d{4}-\d{2}-\d{2}$/.test(value) &&
  Number.isFinite(Date.parse(`${value}T00:00:00Z`)) &&
  new Date(`${value}T00:00:00Z`).toISOString().startsWith(value);
const isTimestamp = (value) =>
  typeof value === "string" &&
  /^\d{4}-\d{2}-\d{2}T/.test(value) &&
  Number.isFinite(Date.parse(value));

test("fixture has unique document IDs and the expected DairyTrace collections", () => {
  assert.equal(fixture.fixtureVersion, 1);
  assert.deepEqual(Object.keys(seed).sort(), [
    "auditLogs",
    "batches",
    "collectionCenters",
    "disputes",
    "farmers",
    "milkCollections",
    "pricingRules",
    "qualityAlerts",
    "qualityParameters",
    "qualityReadings",
    "reconciliationItems",
    "reconciliations",
    "users",
  ]);

  for (const [collection, documents] of Object.entries(seed)) {
    assert.ok(documents.length > 0, `${collection} should contain test data`);
    const documentIds = documents.map(({ id }) => id);
    assert.ok(documentIds.every((id) => typeof id === "string" && id.length > 0));
    assert.equal(new Set(documentIds).size, documentIds.length, `${collection} IDs must be unique`);
  }
});

test("seed references resolve and quality-reading uniqueness is respected", () => {
  for (const farmer of seed.farmers) {
    assert.ok(hasDocument("collectionCenters", farmer.centerId), `${farmer.id} center`);
    if (farmer.userId !== null) assert.ok(hasDocument("users", farmer.userId), `${farmer.id} user`);
  }

  for (const collection of seed.milkCollections) {
    assert.ok(hasDocument("farmers", collection.farmerId), `${collection.id} farmer`);
    assert.ok(hasDocument("collectionCenters", collection.centerId), `${collection.id} center`);
    assert.ok(hasDocument("users", collection.operatorId), `${collection.id} operator`);
    assert.ok(hasDocument("batches", collection.batchId), `${collection.id} batch`);
  }

  const qualityCollectionIds = seed.qualityReadings.map(({ collectionId }) => collectionId);
  assert.equal(
    new Set(qualityCollectionIds).size,
    qualityCollectionIds.length,
    "each collection can have only one quality reading",
  );
  for (const reading of seed.qualityReadings) {
    assert.ok(hasDocument("milkCollections", reading.collectionId), `${reading.id} collection`);
    assert.ok(hasDocument("users", reading.recordedBy), `${reading.id} recorder`);
    assert.equal(reading.id, reading.collectionId, "quality reading ID should be deterministic per collection");
  }

  for (const alert of seed.qualityAlerts) {
    assert.ok(hasDocument("milkCollections", alert.collectionId), `${alert.id} collection`);
  }
  for (const batch of seed.batches) {
    assert.ok(hasDocument("collectionCenters", batch.centerId), `${batch.id} center`);
    if (batch.testedBy !== null) assert.ok(hasDocument("users", batch.testedBy), `${batch.id} tester`);
  }
  for (const item of seed.reconciliationItems) {
    assert.ok(hasDocument("reconciliations", item.reconciliationId), `${item.id} reconciliation`);
    assert.ok(hasDocument("farmers", item.farmerId), `${item.id} farmer`);
  }
  for (const dispute of seed.disputes) {
    assert.ok(hasDocument("farmers", dispute.farmerId), `${dispute.id} farmer`);
    assert.notEqual(
      dispute.collectionId !== null,
      dispute.reconciliationItemId !== null,
      `${dispute.id} must concern exactly one collection or reconciliation item`,
    );
    if (dispute.collectionId !== null) {
      assert.ok(hasDocument("milkCollections", dispute.collectionId), `${dispute.id} collection`);
    }
    if (dispute.reconciliationItemId !== null) {
      assert.ok(hasDocument("reconciliationItems", dispute.reconciliationItemId), `${dispute.id} item`);
    }
  }
  for (const audit of seed.auditLogs) {
    assert.ok(hasDocument("users", audit.userId), `${audit.id} actor`);
    const entityCollection = {
      milkCollections: "milkCollections",
      farmers: "farmers",
      batches: "batches",
      reconciliations: "reconciliations",
      reconciliationItems: "reconciliationItems",
      qualityReadings: "qualityReadings",
      qualityAlerts: "qualityAlerts",
      disputes: "disputes",
    }[audit.entityType];
    assert.ok(entityCollection, `${audit.id} entity type`);
    assert.ok(hasDocument(entityCollection, audit.entityId), `${audit.id} entity`);
  }
});

test("collection, quality, batch, and period values satisfy the fixture's domain constraints", () => {
  const readingsByCollection = new Map(
    seed.qualityReadings.map((reading) => [reading.collectionId, reading]),
  );
  const allowedRoles = ["ADMIN", "MANAGER", "OPERATOR", "QUALITY_STAFF", "FARMER"];
  const parameter = seed.qualityParameters.find(
    ({ parameter: name, isActive }) => name === "SNF" && isActive,
  );
  assert.ok(parameter, "an active SNF quality parameter is required");

  for (const user of seed.users) {
    assert.ok(allowedRoles.includes(user.role), `${user.id} role`);
    assert.equal(typeof user.isActive, "boolean");
    assert.ok(!("password" in user) && !("passwordHash" in user), `${user.id} must not contain credentials`);
  }

  for (const center of seed.collectionCenters) {
    assert.ok(isTimestamp(center.createdAt), `${center.id} createdAt`);
    assert.ok(isTimestamp(center.updatedAt), `${center.id} updatedAt`);
  }
  for (const farmer of seed.farmers) {
    assert.ok(isTimestamp(farmer.createdAt), `${farmer.id} createdAt`);
    assert.ok(isTimestamp(farmer.updatedAt), `${farmer.id} updatedAt`);
  }

  for (const collection of seed.milkCollections) {
    assert.ok(["MORNING", "EVENING"].includes(collection.session), `${collection.id} session`);
    assert.ok(isDate(collection.collectionDate), `${collection.id} collectionDate`);
    assert.ok(isTimestamp(collection.collectionTime), `${collection.id} collectionTime`);
    assert.ok(isTimestamp(collection.createdAt), `${collection.id} createdAt`);
    assert.ok(isTimestamp(collection.updatedAt), `${collection.id} updatedAt`);
    assert.ok(Number.isFinite(collection.quantityLiters) && collection.quantityLiters > 0);
    assert.equal(collection.collectionTime.slice(0, 10), collection.collectionDate);
  }

  for (const qualityParameter of seed.qualityParameters) {
    assert.equal(typeof qualityParameter.isActive, "boolean");
    assert.ok(isDate(qualityParameter.effectiveFrom), `${qualityParameter.id} effectiveFrom`);
    assert.ok(
      qualityParameter.maximum === null ||
        (Number.isFinite(qualityParameter.maximum) && qualityParameter.maximum >= qualityParameter.minimum),
      `${qualityParameter.id} threshold bounds`,
    );
  }

  for (const reading of seed.qualityReadings) {
    assert.ok(Number.isFinite(reading.fatPercentage) && reading.fatPercentage >= 0);
    assert.ok(Number.isFinite(reading.snfPercentage) && reading.snfPercentage >= 0);
    assert.ok(isTimestamp(reading.recordedAt), `${reading.id} recordedAt`);
  }

  for (const alert of seed.qualityAlerts) {
    const reading = readingsByCollection.get(alert.collectionId);
    assert.ok(reading, `${alert.id} must have a reading`);
    assert.equal(alert.parameter, "SNF");
    assert.equal(alert.observedValue, reading.snfPercentage);
    assert.equal(alert.thresholdValue, parameter.minimum);
    assert.ok(alert.observedValue < alert.thresholdValue, `${alert.id} must represent a violation`);
    assert.ok(["OPEN", "REVIEWED", "RESOLVED"].includes(alert.status), `${alert.id} status`);
    assert.ok(isTimestamp(alert.createdAt), `${alert.id} createdAt`);
    if (alert.status === "RESOLVED") {
      assert.ok(isTimestamp(alert.resolvedAt), `${alert.id} resolvedAt`);
      assert.ok(hasDocument("users", alert.resolvedBy), `${alert.id} resolver`);
    } else {
      assert.equal(alert.resolvedAt, null);
      assert.equal(alert.resolvedBy, null);
    }
  }

  for (const batch of seed.batches) {
    assert.ok(["PENDING", "PASSED", "FAILED", "QUARANTINED", "RELEASED"].includes(batch.status));
    assert.ok(["PENDING", "PASSED", "FAILED", "QUARANTINED", "RELEASED"].includes(batch.qualityResult));
    assert.ok(isDate(batch.batchDate), `${batch.id} batchDate`);
    assert.ok(isTimestamp(batch.createdAt), `${batch.id} createdAt`);
  }

  for (const rule of seed.pricingRules) {
    assert.ok(Number.isFinite(rule.ratePerLiter) && rule.ratePerLiter > 0, `${rule.id} rate`);
    assert.ok(isDate(rule.effectiveFrom), `${rule.id} effectiveFrom`);
    assert.ok(rule.effectiveTo === null || isDate(rule.effectiveTo), `${rule.id} effectiveTo`);
    assert.equal(typeof rule.isActive, "boolean");
    assert.ok(isTimestamp(rule.createdAt), `${rule.id} createdAt`);
    for (const [minimum, maximum] of [
      [rule.minFat, rule.maxFat],
      [rule.minSnf, rule.maxSnf],
    ]) {
      assert.ok(minimum === null || Number.isFinite(minimum));
      assert.ok(maximum === null || Number.isFinite(maximum));
      if (minimum !== null && maximum !== null) assert.ok(minimum <= maximum);
    }
  }

  for (const reconciliation of seed.reconciliations) {
    assert.ok(isDate(reconciliation.periodStart));
    assert.ok(isDate(reconciliation.periodEnd));
    assert.ok(reconciliation.periodStart <= reconciliation.periodEnd);
    assert.ok(["OPEN", "CALCULATING", "REVIEW", "FINALIZED"].includes(reconciliation.status));
    assert.ok(isTimestamp(reconciliation.createdAt), `${reconciliation.id} createdAt`);
    if (reconciliation.status === "FINALIZED") {
      assert.ok(hasDocument("users", reconciliation.finalizedBy));
      assert.ok(isTimestamp(reconciliation.finalizedAt));
    }
  }

  for (const item of seed.reconciliationItems) {
    assert.ok(Number.isFinite(item.totalQuantityLiters) && item.totalQuantityLiters >= 0);
    assert.ok(Number.isFinite(item.calculatedAmount) && item.calculatedAmount >= 0);
    assert.ok(isTimestamp(item.createdAt), `${item.id} createdAt`);
  }

  for (const dispute of seed.disputes) {
    assert.ok(["OPEN", "UNDER_REVIEW", "RESOLVED", "REJECTED"].includes(dispute.status));
    assert.ok(isTimestamp(dispute.raisedAt), `${dispute.id} raisedAt`);
    if (dispute.status === "OPEN" || dispute.status === "UNDER_REVIEW") {
      assert.equal(dispute.resolvedBy, null);
      assert.equal(dispute.resolvedAt, null);
    }
    if (dispute.status === "RESOLVED" || dispute.status === "REJECTED") {
      assert.ok(hasDocument("users", dispute.resolvedBy), `${dispute.id} resolver`);
      assert.ok(isTimestamp(dispute.resolvedAt), `${dispute.id} resolvedAt`);
    }
  }

  for (const audit of seed.auditLogs) {
    assert.ok(isTimestamp(audit.createdAt), `${audit.id} createdAt`);
  }
});

test("validation cases cover representative acceptance, rejection, and workflow outcomes", () => {
  const cases = fixture.validationCases;
  const caseIds = cases.map(({ id }) => id);
  assert.equal(new Set(caseIds).size, caseIds.length);
  assert.ok(caseIds.includes("valid-collection"));
  assert.ok(caseIds.includes("missing-farmer-reference"));
  assert.ok(caseIds.includes("invalid-session"));
  assert.ok(caseIds.includes("non-positive-quantity"));
  assert.ok(caseIds.includes("quality-below-threshold"));
  assert.ok(caseIds.includes("orphan-quality-reading"));
  assert.ok(caseIds.includes("duplicate-quality-reading"));
  assert.ok(caseIds.includes("failed-batch-traceability"));
  assert.ok(caseIds.includes("finalized-reconciliation-edit"));

  for (const validationCase of cases) {
    assert.ok(["accept", "reject", "accept-with-alert", "accept-with-audit"].includes(validationCase.expected));
    assert.ok(/^[a-zA-Z]+\/[^/]+$/.test(validationCase.documentPath));
    assert.ok(validationCase.rule.length > 0);
  }
});
