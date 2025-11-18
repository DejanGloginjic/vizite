import { cfcGet } from "../../shared/api/cfc";

export const getRooms = async () => {
  return await cfcGet("getRooms");
};
