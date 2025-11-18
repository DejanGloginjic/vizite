import { useQueryClient } from "@tanstack/react-query";
import { QK } from "../../shared/lib/queryKeys";
import { getPatientById } from "../../entities/patient/api";
import { getPatientTasks } from "../../entities/task/api";
import { toISODate } from "../../shared/lib/date";

export function usePrefetchPatient() {
  const qc = useQueryClient();
  const today = toISODate();

  return async function prefetch(id) {
    if (!id) return;
    await Promise.all([
      qc.prefetchQuery({
        queryKey: QK.patient(id),
        queryFn: () => getPatientById(id),
        staleTime: 60_000,
      }),
      qc.prefetchQuery({
        queryKey: QK.tasks(id, today),
        queryFn: () => getPatientTasks(id, today),
        staleTime: 30_000,
      }),
    ]);
  };
}
