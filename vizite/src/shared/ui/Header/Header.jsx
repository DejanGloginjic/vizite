import React, { useState } from "react";
import { Link } from "react-router-dom";
import styles from "./Header.module.css";
import logo from "../../../assets/logo.svg";
import { useSession } from "../../../app/providers/SessionContext";
import ConfirmModal from "../ConfirmModal/ConfirmModal";

function getUserNameFromSession(s) {
  if (!s) return "";
  return (
    s.ime_korisnika ||
    s.potpis_korisnika ||
    [s.ime, s.prezime].filter(Boolean).join(" ") ||
    ""
  );
}

export default function Header() {
  const { session } = useSession() || { session: null };
  const userName = (getUserNameFromSession(session) || "Korisnik").trim();

  const logoutHref =
    (typeof window !== "undefined" && window.__LOGOUT_URL__) ||
    import.meta.env.VITE_LOGOUT_URL ||
    null;

  const [confirmOpen, setConfirmOpen] = useState(false);

  const handleConfirm = () => {
    setConfirmOpen(false);
    if (logoutHref) window.location.assign(logoutHref);
    else console.warn("Postavite VITE_LOGOUT_URL ili window.__LOGOUT_URL__");
  };

  return (
    <header className={styles.header}>
      <div className={styles.inner}>
        <div className={styles.brandWrap}>
          <Link to="/" className={styles.brandLink} aria-label="Početna">
            <img src={logo} alt="" className={styles.logo} />
            <div className={styles.brandText}>
              <span className={styles.appRoot}>eAmbulanta</span>
              <span className={styles.dot}>·</span>
              <span className={styles.appName}>Vizita</span>
            </div>
          </Link>
        </div>

        <div className={styles.userArea}>
          <div
            className={styles.userCard}
            title={userName}
            aria-label={userName}
          >
            <svg
              viewBox="0 0 24 24"
              className={styles.userIcon}
              width="22"
              height="22"
              aria-hidden="true"
            >
              <circle
                cx="12"
                cy="8"
                r="4"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.8"
              />
              <path
                d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.8"
                strokeLinecap="round"
              />
            </svg>
            <div className={styles.userName} title={userName}>
              {userName}
            </div>
          </div>

          <button
            type="button"
            className={styles.iconBtn}
            aria-label="Izlaz"
            title="Izlaz"
            onClick={() => setConfirmOpen(true)}
          >
            <svg
              viewBox="0 0 24 24"
              className={styles.icon}
              width="20"
              height="20"
              aria-hidden="true"
            >
              <path
                d="M10 7V5a2 2 0 0 1 2-2h6v18h-6a2 2 0 0 1-2-2v-2"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.6"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
              <path
                d="M15 12H3m0 0 3-3m-3 3 3 3"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.6"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </button>
        </div>
      </div>

      <ConfirmModal
        open={confirmOpen}
        title="Da li ste sigurni da želite da se odjavite?"
        description=""
        confirmText="Odjavi me"
        cancelText="Odustani"
        onCancel={() => setConfirmOpen(false)}
        onConfirm={handleConfirm}
      />
    </header>
  );
}
