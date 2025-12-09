import { cfcGet } from "../../shared/api/cfc";

export const getProducts = (term = "", limit = 50) =>
  cfcGet("getProducts", term ? { term, limit } : { limit });
