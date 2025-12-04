// src/entities/storage/api.js
import { cfcGet, cfcPost } from '../../shared/api/cfc';

// već imaš ovo ili slično
export const getUserStorages = async () => {
  return await cfcGet('lista_skladista_korisnika');
};

// NOVO: postavljanje lokacije rada u sesiji na backendu
export const setWorkingLocation = async ({ grupaId, skladisteId }) => {
  return await cfcPost('setWorkingLocation', {
    grupa_id: grupaId,
    skladiste_id: skladisteId,
  });
};
