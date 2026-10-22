import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import test from "node:test";

const rootReadme = readFileSync(new URL("../../README.md", import.meta.url), "utf8");
const requiredDirectories = [
  "backend",
  "frontend",
  "frontend-legacy",
  "mobile",
  "database",
  "docs",
];

test("project documentation reflects the actual repository layout", () => {
  for (const directory of requiredDirectories) {
    assert.ok(existsSync(new URL(`../../${directory}`, import.meta.url)), `${directory} directory is missing`);
  }

  assert.match(rootReadme, /frontend-legacy/i, "README should document the legacy Next.js frontend");
  assert.match(rootReadme, /frontend\s*\/\s*#\s*Flutter web\/desktop/i, "README should document the Flutter frontend");
  assert.match(rootReadme, /mobile\s*\/\s*#\s*Flutter mobile app/i, "README should document the Flutter mobile app");
  assert.match(rootReadme, /\[frontend-legacy\/README\.md\]\(\.\/frontend-legacy\/README\.md\)/i, "README should link to the frontend app docs with a relative path");
});
