import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createPatientTask,
  getPatientTasks,
  getTaskTypes,
  updatePatientTask,
} from "./api";
import { QK } from "../../shared/lib/queryKeys";

export const usePatientTasksQuery = (id, date) =>
  useQuery({
    queryKey: QK.tasks(id, date),
    queryFn: () => getPatientTasks(id, date),
    enabled: !!id,
    staleTime: 10_000,
  });

export const useTaskTypesQuery = () =>
  useQuery({
    queryKey: QK.taskTypes,
    queryFn: () => getTaskTypes(),
    staleTime: 5 * 60_000,
  });

export const useCreateTaskMutation = (patientId, date) => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => createPatientTask(payload),
    onSuccess: () => {
      if (patientId) {
        qc.invalidateQueries({ queryKey: QK.tasks(patientId, date) });
      }
    },
  });
};

export const useUpdateTaskMutation = (patientId, date) => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => updatePatientTask(payload),
    onSuccess: () => {
      if (patientId) {
        qc.invalidateQueries({ queryKey: QK.tasks(patientId, date) });
      }
    },
  });
};
