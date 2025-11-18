import { cfcGet } from "../../shared/api/cfc";

export const getPatientTasks = (patient_id, date) =>
  cfcGet("getPatientTasks", date ? { patient_id, date } : { patient_id });
