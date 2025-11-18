import React from "react";
import { QueryClientProvider } from "@tanstack/react-query";
import { makeQueryClient } from "./QueryClient";
import { SessionProvider } from "./SessionContext";

const client = makeQueryClient();

export function Providers({ children }) {
  return (
    <QueryClientProvider client={client}>
      <SessionProvider>{children}</SessionProvider>
    </QueryClientProvider>
  );
}
