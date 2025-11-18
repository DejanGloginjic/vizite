import axios from "axios";
import { baseUrl, ENV } from "../config/env";

export const http = axios.create({
  baseURL: baseUrl,
  withCredentials: true,
  timeout: ENV.REQUEST_TIMEOUT,
});

// Jednostavna obrada grešaka
http.interceptors.response.use(
  (res) => res,
  (err) =>
    Promise.reject(
      new Error(
        err?.response?.data?.message || err.message || "Greška na mreži"
      )
    )
);
