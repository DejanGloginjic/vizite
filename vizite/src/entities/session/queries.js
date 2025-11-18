import { useQuery } from "@tanstack/react-query";
import { getSession } from "./api";

export function useSessionQuery() {
  return useQuery({
    queryKey: ["session"],
    queryFn: getSession,
    staleTime: 60_000, // sesija se rijetko mijenja
  });
}
