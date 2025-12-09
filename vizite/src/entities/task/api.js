import { cfcGet, cfcPost } from "../../shared/api/cfc";

export const getPatientTasks = (patient_id, date) =>
  cfcGet("getPatientTasks", date ? { patient_id, date } : { patient_id });

export const getTaskTypes = () => cfcGet("getTaskTypes");

export const createPatientTask = (payload) =>
  cfcPost("createPatientTask", payload);

export const updatePatientTask = (payload) =>
  cfcPost("updatePatientTask", payload);

export const clonePatientTasks = (payload) =>
  cfcPost("clonePatientTasks", payload);
