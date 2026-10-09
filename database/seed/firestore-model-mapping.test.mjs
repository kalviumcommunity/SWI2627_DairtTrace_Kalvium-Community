import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const fixture = JSON.parse(
  await readFile(new URL("./firestore-validation-fixtures.json", import.meta.url), "utf8"),
);
const entitySource = await readFile(
  new URL("../../backend/src/main/java/com/dairytrace/model/Collection.java", import.meta.url),
  "utf8",
);
const requestSource = await readFile(
  new URL("../../backend/src/main/java/com/dairytrace/dto/CollectionRequest.java", import.meta.url),
  "utf8",
);

const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

test("Firestore milk collection samples expose the current backend mapping edge cases", () => {
  const collections = fixture.seedDocuments.milkCollections;
  assert.equal(collections.length, 2);

  assert.match(entitySource, /\bprivate UUID id;/);
  assert.match(entitySource, /\bprivate String collectionCode;/);
  assert.match(entitySource, /\bprivate UUID farmerId;/);
  assert.match(entitySource, /\bprivate UUID centerId;/);
  assert.match(entitySource, /\bprivate UUID operatorId;/);
  assert.match(entitySource, /\bprivate LocalDate collectionDate;/);
  assert.match(entitySource, /\bprivate LocalDateTime collectionTime;/);
  assert.match(entitySource, /\bprivate BigDecimal quantityLiters;/);
  assert.match(entitySource, /\bprivate UUID batchId;/);
  assert.match(requestSource, /\bString collectionCode\b/);
  assert.match(requestSource, /\bUUID farmerId\b/);
  assert.match(requestSource, /\bUUID centerId\b/);
  assert.match(requestSource, /\bUUID operatorId\b/);
  assert.match(requestSource, /\bLocalDate collectionDate\b/);
  assert.match(requestSource, /\bLocalDateTime collectionTime\b/);
  assert.match(requestSource, /\bBigDecimal quantityLiters\b/);
  assert.match(requestSource, /\bUUID batchId\b/);

  for (const collection of collections) {
    assert.equal(typeof collection.id, "string");
    assert.equal(collection.id, collection.id.trim());
    assert.ok(!("collectionCode" in collection), "fixture id needs an explicit collectionCode mapping");
    assert.ok(!uuidPattern.test(collection.id), `${collection.id} is a business code, not a UUID`);
    assert.ok(
      !uuidPattern.test(collection.farmerId) &&
        !uuidPattern.test(collection.centerId) &&
        !uuidPattern.test(collection.operatorId) &&
        !uuidPattern.test(collection.batchId),
      `${collection.id} contains string references that cannot bind to UUID model fields`,
    );
    assert.match(collection.collectionDate, /^\d{4}-\d{2}-\d{2}$/);
    assert.match(collection.collectionTime, /Z$/);
    assert.equal(typeof collection.quantityLiters, "number");
  }
});
