import { beforeEach, describe, expect, it, vi } from "vitest";
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

  it("handles session storage access being denied by the browser", () => {
    const storageGetter = vi
      .spyOn(window, "sessionStorage", "get")
      .mockImplementation(() => {
        throw new DOMException("Access denied.", "SecurityError");
      });

    try {
      expect(hasActiveSession()).toBe(false);
      expect(() => logout()).not.toThrow();
      expect(() => startSession("test-jwt")).toThrow(
        "Session storage is unavailable in this environment.",
      );
    } finally {
      storageGetter.mockRestore();
    }
  });

  it("handles non-browser environments without crashing", () => {
    const originalWindow = globalThis.window;

    try {
      vi.stubGlobal("window", undefined as unknown as Window & typeof globalThis);

      expect(hasActiveSession()).toBe(false);
      expect(() => logout()).not.toThrow();
      expect(() => startSession("not-a-real-session")).toThrow(
        "Session storage is unavailable in this environment.",
      );
    } finally {
      vi.unstubAllGlobals();
      globalThis.window = originalWindow;
    }
  });
});
