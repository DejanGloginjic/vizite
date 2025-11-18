// src/entities/patient/queries.js
import { useQuery } from '@tanstack/react-query';
import { getPatients, getPatientById, getPatientByWirstband } from './api';
import { QK } from '../../shared/lib/queryKeys';
import { toISODate } from '../../shared/lib/date';

export const usePatientsQuery = (roomId, date = toISODate()) =>
  useQuery({
    // ako QK.patients već postoji, prosledi objekat; u suprotnom koristi inline ključ
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
