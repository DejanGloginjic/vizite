import { useQuery } from '@tanstack/react-query';
import { getSession } from './api';
import { QK } from '../../shared/lib/queryKeys';

export function useSessionQuery() {
  return useQuery({
    queryKey: QK.session, // ✅ ovdje je array
    queryFn: getSession,
    staleTime: 60_000,
  });
}
