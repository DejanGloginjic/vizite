// src/entities/patient/api.js
import { cfcGet } from '../../shared/api/cfc';
import { toISODate } from '../../shared/lib/date';

export const getPatients = async (roomId, date = toISODate()) => {
  // CFC: getPatients (?soba_id, ?date)
  const params = { date };
  if (roomId) params.soba_id = roomId;
  return await cfcGet('getPatients', params);
};

export const getPatientById = async (id) => {
  return await cfcGet('getPatientById', { patient_id: id });
};

export const getPatientByWirstband = async (id) => {
  return await cfcGet('getPatientByWirstband', { patient_id: id });
};
