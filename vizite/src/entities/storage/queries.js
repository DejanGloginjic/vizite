// src/entities/storage/queries.js
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getUserStorages, setWorkingLocation } from './api';
import { QK } from '../../shared/lib/queryKeys';

export const useUserStoragesQuery = () =>
  useQuery({
    queryKey: QK?.userStorages ? QK.userStorages() : ['userStorages'],
    queryFn: getUserStorages,
    staleTime: 60_000,
  });

export const useSetWorkingLocation = () => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: setWorkingLocation,
    onSuccess: () => {
      // QK.session je već queryKey (['session']), ne funkcija
      qc.invalidateQueries({ queryKey: QK.session });
      qc.invalidateQueries({ queryKey: QK.rooms });
      // ako negdje još koristiš ['session'], ovo ih sve pokriva jer je isto
    },
  });
};
