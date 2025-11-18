import { useQuery } from "@tanstack/react-query";
import { getRooms } from "./api";
import { QK } from "../../shared/lib/queryKeys";

export const useRoomsQuery = () =>
  useQuery({
    queryKey: QK.rooms,
    queryFn: getRooms,
    staleTime: 5 * 60_000,
  });
