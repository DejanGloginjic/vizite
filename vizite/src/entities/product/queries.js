import { useQuery } from "@tanstack/react-query";
import { getProducts } from "./api";
import { QK } from "../../shared/lib/queryKeys";

export const useProductsQuery = (term, enabled = true) =>
  useQuery({
    queryKey: QK.products(term),
    queryFn: () => getProducts(term),
    enabled,
    staleTime: 5 * 60_000,
    keepPreviousData: true,
  });
