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

// 🔹 NOVO: dokumenti pacijenta
export const getPatientDocuments = async (patientId, filters = {}) => {
  const params = {
    patient_id: patientId,
  };

  if (filters.dateFrom) params.date_from = filters.dateFrom;
  if (filters.dateTo) params.date_to = filters.dateTo;
  if (filters.episodeId) params.episode_id = filters.episodeId;

  return await cfcGet('getPatientDocuments', params);
};

export function getPatientEpisodes(patientId) {
  if (!patientId) return Promise.resolve([]);
  return http
    .get('', {
      method: 'lista_epizoda_pacijenta',
      pacijent_id: patientId,
    })
    .then((res) => res.data);
}
