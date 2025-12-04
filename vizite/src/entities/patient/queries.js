// src/entities/patient/queries.js
import { useQuery } from '@tanstack/react-query';
import {
  getPatients,
  getPatientById,
  getPatientByWirstband,
  getPatientDocuments,
  getPatientEpisodes,
} from './api';
import { QK } from '../../shared/lib/queryKeys';
import { toISODate } from '../../shared/lib/date';

export const usePatientsQuery = (roomId, date = toISODate()) =>
  useQuery({
    queryKey: QK?.patients
      ? QK.patients({ roomId: roomId ?? '', date })
      : ['patients', { roomId: roomId ?? '', date }],
    queryFn: () => getPatients(roomId, date),
    keepPreviousData: true,
    staleTime: 30_000,
  });

export const usePatientQuery = (id) =>
  useQuery({
    queryKey: QK?.patient ? QK.patient(id) : ['patient', id],
    queryFn: () => getPatientById(id),
    enabled: !!id,
    staleTime: 60_000,
  });

export const usePatientByWirstbandQuery = (id) =>
  useQuery({
    queryKey: QK?.patient ? QK.patient(id) : ['patient', id],
    queryFn: () => getPatientByWirstband(id),
    enabled: !!id,
    staleTime: 60_000,
  });

// 🔹 NOVO: dokumenti pacijenta
export const usePatientDocumentsQuery = (id, filters = {}) =>
  useQuery({
    queryKey: QK?.patientDocuments ? QK.patientDocuments(id) : ['patientDocuments', id],
    queryFn: () => getPatientDocuments(id, filters),
    enabled: !!id,
    staleTime: 30_000,
  });

export function usePatientEpisodesQuery(patientId) {
  return useQuery({
    queryKey: ['patient', 'episodes', patientId],
    queryFn: () => getPatientEpisodes(patientId),
    enabled: !!patientId,
    staleTime: 5 * 60 * 1000, // opcionalno – 5 min cache, jer se epizode ne mijenjaju svake sekunde
  });
}
