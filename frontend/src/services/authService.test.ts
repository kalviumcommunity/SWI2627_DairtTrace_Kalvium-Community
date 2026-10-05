import { beforeEach, describe, expect, it } from "vitest";
import { hasActiveSession, logout, startSession } from "./authService";

describe("authService", () => {
  beforeEach(() => {
    window.sessionStorage.clear();
  });

  it("clears the active session on logout", () => {
    startSession("test-jwt");

    expect(hasActiveSession()).toBe(true);

    logout();

    expect(hasActiveSession()).toBe(false);
  });

  it("rejects empty session tokens", () => {
    expect(() => startSession("  ")).toThrow("A session token is required.");
    expect(hasActiveSession()).toBe(false);
  });

  it("allows logout when no session is active", () => {
    expect(() => logout()).not.toThrow();
    expect(hasActiveSession()).toBe(false);
  });
});
