"use client";

import { useRouter } from "next/navigation";
import { logout } from "../../services/authService";

export function LogoutButton() {
  const router = useRouter();

  function handleLogout() {
    logout();
    router.replace("/login");
  }

  return (
    <button type="button" onClick={handleLogout}>
      Log out
    </button>
  );
}
