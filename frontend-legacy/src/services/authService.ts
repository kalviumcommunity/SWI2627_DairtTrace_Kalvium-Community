const SESSION_TOKEN_KEY = "dairytrace.sessionToken";

export function startSession(token: string): void {
  if (!token.trim()) {
    throw new Error("A session token is required.");
  }

  window.sessionStorage.setItem(SESSION_TOKEN_KEY, token);
}

export function hasActiveSession(): boolean {
  return Boolean(window.sessionStorage.getItem(SESSION_TOKEN_KEY));
}

export function logout(): void {
  window.sessionStorage.removeItem(SESSION_TOKEN_KEY);
}
