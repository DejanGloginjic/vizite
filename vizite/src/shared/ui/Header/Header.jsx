// src/shared/ui/Header/Header.jsx
import React, { useEffect, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import styles from './Header.module.css';
import logo from '../../../assets/logo.svg';
import { useSession } from '../../../app/providers/SessionContext';
import { ENV } from '../../config/env';

function getUserNameFromSession(s) {
  if (!s) return '';
  return (
    s.ime_korisnika || s.potpis_korisnika || [s.ime, s.prezime].filter(Boolean).join(' ') || ''
  );
}

function getInitials(name) {
  if (!name) return '?';
  const parts = name.trim().split(/\s+/);
  if (!parts.length) return '?';
  const first = parts[0]?.[0] || '';
  const last = parts[parts.length - 1]?.[0] || '';
  return (first + last).toUpperCase() || first.toUpperCase() || '?';
}

export default function Header() {
  const navigate = useNavigate();
  const location = useLocation();
  const { session } = useSession() || { session: null };
  const userName = (getUserNameFromSession(session) || 'Korisnik').trim();
  const clientName = session?.naziv_klijenta || '';

  const [selection, setSelection] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('vizite.clinicSelection')) || null;
    } catch {
      return null;
    }
  });

  useEffect(() => {
    const onStorage = (e) => {
      if (e.key === 'vizite.clinicSelection') {
        setSelection(e.newValue ? JSON.parse(e.newValue) : null);
      }
    };
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, []);

  const grupaId = selection?.grupaId ?? session?.izabrana_grupa_skladista ?? null;
  const skladisteId = selection?.skladisteId ?? session?.izabrano_skladiste ?? null;
  const initials = getInitials(userName);

  const locationLabel =
    grupaId || skladisteId
      ? `Grupa ${grupaId ?? '—'} · Skladište ${skladisteId ?? '—'}`
      : 'Odaberite lokaciju';

  const logoutUrl =
    (typeof window !== 'undefined' && window.__LOGOUT_URL__) ||
    ENV.LOGOUT_URL ||
    '../../pocetna.cfm';

  const handleExit = () => {
    const onChoose = location.pathname === '/' || location.pathname === '/choose';
    if (onChoose) {
      if (logoutUrl) {
        window.location.assign(logoutUrl);
      }
      return;
    }
    navigate('/');
  };

  return (
    <header className={styles.header}>
      <div className={styles.inner}>
        <div className={styles.brandWrap}>
          <Link to="/" className={styles.brandLink} aria-label="Početna">
            <img src={logo} alt="Vizita" className={styles.logo} />
            <div className={styles.brandText}>
              <span className={styles.appName}>Vizita</span>
              {clientName ? <span className={styles.clientName}>{clientName}</span> : null}
            </div>
          </Link>
        </div>

        <div className={styles.userArea}>
          <button
            type="button"
            className={styles.locationCard}
            onClick={() => navigate('/')}
            title="Promjena lokacije"
          >
            <span className={styles.locDot} aria-hidden />
            <span className={styles.locText}>{locationLabel}</span>
          </button>

          <div className={styles.userCard} title={userName} aria-label={userName}>
            <span className={styles.userBadge} aria-hidden>
              {initials}
            </span>
            <div className={styles.userName} title={userName}>
              {userName}
            </div>
          </div>

          <button
            type="button"
            className={styles.iconBtn}
            onClick={handleExit}
            title="Izlaz / promjena lokacije"
            aria-label="Izlaz ili promjena lokacije"
          >
            <svg viewBox="0 0 24 24" className={styles.icon} aria-hidden="true">
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
    </header>
  );
}
