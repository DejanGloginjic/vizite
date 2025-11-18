import React, { createContext, useContext } from "react";
import { useSessionQuery } from "../../entities/session/queries";
import { ENV } from "../../shared/config/env";

const SessionCtx = createContext({ session: null, isMock: false });

export function useSession() {
  return useContext(SessionCtx);
}

export function SessionProvider({ children }) {
  const { data, isLoading, isError, error } = useSessionQuery();

  if (isLoading) {
    return (
      <div
        style={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 18,
        }}
      >
        Učitavam sesiju…
      </div>
    );
  }
  if (isError) {
    return (
      <div
        style={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#b00020",
          padding: 16,
          textAlign: "center",
        }}
      >
        Greška pri učitavanju sesije:{" "}
        {String(error?.message || "Nepoznata greška")}
      </div>
    );
  }

  return (
    <SessionCtx.Provider
      value={{ session: data, isMock: ENV.USE_MOCK_SESSION }}
    >
      {ENV.USE_MOCK_SESSION ? (
        <div
          style={{
            position: "fixed",
            bottom: 12,
            right: 12,
            background: "rgba(58,160,255,.12)",
            border: "1px solid rgba(58,160,255,.4)",
            color: "#9ad0ff",
            padding: "6px 10px",
            borderRadius: 8,
            fontSize: 12,
          }}
        >
          MOCK session
        </div>
      ) : null}
      {children}
    </SessionCtx.Provider>
  );
}
