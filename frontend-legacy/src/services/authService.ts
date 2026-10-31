const SESSION_TOKEN_KEY = "dairytrace.sessionToken";

function getSessionStorage(): Storage | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    return window.sessionStorage;
  } catch (error) {
    if (error instanceof DOMException && error.name === "SecurityError") {
      return null;
    }

    throw error;
  }
}

export function startSession(token: string): void {
  const storage = getSessionStorage();

  if (!token.trim()) {
    throw new Error("A session token is required.");
  }

  if (!storage) {
    throw new Error("Session storage is unavailable in this environment.");
  }

  storage.setItem(SESSION_TOKEN_KEY, token);
}

export function hasActiveSession(): boolean {
  const storage = getSessionStorage();

  if (!storage) {
    return false;
  }

  return Boolean(storage.getItem(SESSION_TOKEN_KEY));
}

export function logout(): void {
  const storage = getSessionStorage();

  if (!storage) {
    return;
  }

  storage.removeItem(SESSION_TOKEN_KEY);
}
