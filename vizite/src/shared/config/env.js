// src/shared/config/env.js
const isProd = import.meta.env.PROD;

// Gdje je SPA hostovana (ti koristiš /ambulanta/vizite/react/)
const APP_BASE_PATH = "/ambulanta/vizite/react/";

// API endpoint (CFC). U prod RELATIVNO (isti origin → bez CORS-a).
// U dev direktno gađaš IP (potreban CORS na serveru za http://localhost:5173).
const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  (isProd
    ? "/ambulanta/vizite/vizite.cfc"
    : "https://172.18.1.70:7443/ambulanta/vizite/vizite.cfc");

export const ENV = {
  IS_PROD: isProd,
  APP_BASE_PATH,
  API_BASE_URL,
  REQUEST_TIMEOUT: Number(import.meta.env.VITE_REQUEST_TIMEOUT) || 15000,

  // mock sesija: default dev=on, prod=off (možeš override-ovati u .env)
  USE_MOCK_SESSION:
    (import.meta.env.VITE_USE_MOCK_SESSION ?? (isProd ? "0" : "1")) === "1",

  // opcionalno: kači URLTOKEN na requeste (ako tako držiš CF sesiju u dev-u)
  ATTACH_SESSION_URLTOKEN:
    (import.meta.env.VITE_ATTACH_SESSION_URLTOKEN ?? "0") === "1",
};

export const baseUrl = ENV.API_BASE_URL;
