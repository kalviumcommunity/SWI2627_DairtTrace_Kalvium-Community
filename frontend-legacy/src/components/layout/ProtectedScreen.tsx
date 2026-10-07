"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { hasActiveSession } from "../../services/authService";

type ProtectedScreenProps = {
  children: ReactNode;
};

export function ProtectedScreen({ children }: ProtectedScreenProps) {
  const router = useRouter();
  const [isAuthorized, setIsAuthorized] = useState(false);

  useEffect(() => {
    if (!hasActiveSession()) {
      router.replace("/login");
      return;
    }

    setIsAuthorized(true);
  }, [router]);

  if (!isAuthorized) {
    return null;
  }

  return children;
}
