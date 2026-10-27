import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { LogoutButton } from "./LogoutButton";
import { ProtectedScreen } from "./ProtectedScreen";
import { hasActiveSession, startSession } from "../../services/authService";

const { replace } = vi.hoisted(() => ({
  replace: vi.fn(),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace }),
}));

describe("logout flow", () => {
  beforeEach(() => {
    window.sessionStorage.clear();
    replace.mockClear();
  });

  it("ends the session and navigates away from the protected screen", async () => {
    startSession("test-jwt");

    const { unmount } = render(
      <ProtectedScreen>
        <h1>Dashboard</h1>
        <LogoutButton />
      </ProtectedScreen>,
    );

    expect(await screen.findByRole("heading", { name: "Dashboard" })).toBeVisible();

    fireEvent.click(screen.getByRole("button", { name: "Log out" }));

    expect(hasActiveSession()).toBe(false);
    expect(replace).toHaveBeenCalledWith("/login");

    unmount();
    render(
      <ProtectedScreen>
        <h1>Dashboard</h1>
      </ProtectedScreen>,
    );

    expect(screen.queryByRole("heading", { name: "Dashboard" })).not.toBeInTheDocument();
    await waitFor(() => expect(replace).toHaveBeenCalledTimes(2));
  });

  it("redirects to login and never renders protected content without a session", async () => {
    render(
      <ProtectedScreen>
        <h1>Protected dashboard</h1>
      </ProtectedScreen>,
    );

    expect(screen.queryByRole("heading", { name: "Protected dashboard" })).not.toBeInTheDocument();
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/login"));
  });

  it("still redirects and protects content when storage access is denied", async () => {
    startSession("test-jwt");
    let unmount = render(<LogoutButton />).unmount;
    const storageGetter = vi
      .spyOn(window, "sessionStorage", "get")
      .mockImplementation(() => {
        throw new DOMException("Access denied.", "SecurityError");
      });

    try {
      fireEvent.click(screen.getByRole("button", { name: "Log out" }));

      expect(replace).toHaveBeenCalledWith("/login");

      unmount();
      const protectedScreen = render(
        <ProtectedScreen>
          <h1>Protected dashboard</h1>
        </ProtectedScreen>,
      );
      unmount = protectedScreen.unmount;

      expect(
        screen.queryByRole("heading", { name: "Protected dashboard" }),
      ).not.toBeInTheDocument();
      await waitFor(() => expect(replace).toHaveBeenCalledTimes(2));
    } finally {
      storageGetter.mockRestore();
      unmount();
    }
  });
});
