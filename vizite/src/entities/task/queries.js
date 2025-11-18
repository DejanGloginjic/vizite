import { useQuery } from "@tanstack/react-query";
import { getPatientTasks } from "./api";
import { QK } from "../../shared/lib/queryKeys";

export const usePatientTasksQuery = (id, date) =>
  useQuery({
    queryKey: QK.tasks(id, date),
    queryFn: () => getPatientTasks(id, date),
    enabled: !!id,
    staleTime: 10_000,
  });
