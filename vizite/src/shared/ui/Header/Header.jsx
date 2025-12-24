// src/shared/ui/Header/Header.jsx
import React, { useEffect, useMemo, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import styles from './Header.module.css';
import logo from '../../../assets/logo.svg';
import { useSession } from '../../../app/providers/SessionContext';
import { ENV } from '../../config/env';
import { useUserStoragesQuery } from '../../../entities/storage/queries';

export default function Header({ onOpenLocation }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { session } = useSession() || { session: null };

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
    const onCustom = () => {
      try {
        setSelection(JSON.parse(localStorage.getItem('vizite.clinicSelection')) || null);
      } catch {
        setSelection(null);
      }
    };
    window.addEventListener('storage', onStorage);
    window.addEventListener('vizite-selection-changed', onCustom);
    return () => {
      window.removeEventListener('storage', onStorage);
      window.removeEventListener('vizite-selection-changed', onCustom);
    };
  }, []);

  const grupaId = selection?.grupaId ?? session?.izabrana_grupa_skladista ?? null;
  const skladisteId = selection?.skladisteId ?? session?.izabrano_skladiste ?? null;

  const { data: groupsData = [], isLoading: groupsLoading } = useUserStoragesQuery();
  const groups = useMemo(() => (Array.isArray(groupsData) ? groupsData : []), [groupsData]);

  const activeGroup = useMemo(() => {
    if (!grupaId) return null;
    return groups.find((g) => String(g.id) === String(grupaId)) || null;
  }, [groups, grupaId]);

  const activeStorage = useMemo(() => {
    if (!skladisteId) return null;
    const fromGroup = activeGroup?.skladista?.find(
      (s) => String(s.id) === String(skladisteId),
    );
    if (fromGroup) return fromGroup;
    for (const g of groups) {
      const match = g?.skladista?.find((s) => String(s.id) === String(skladisteId));
      if (match) return match;
    }
    return null;
  }, [groups, activeGroup, skladisteId]);

  const hasSelection = Boolean(grupaId || skladisteId);
  const groupValue =
    activeGroup?.naziv || (groupsLoading ? 'Ucitavanje...' : grupaId ? 'ID ' + grupaId : '-');
  const storageValue =
    activeStorage?.naziv ||
    (groupsLoading ? 'Ucitavanje...' : skladisteId ? 'ID ' + skladisteId : '-');

  const logoutUrl =
    (typeof window !== 'undefined' && window.__LOGOUT_URL__) ||
    ENV.LOGOUT_URL ||
    '../../pocetna.cfm';

  const handleExit = () => {
    if (onOpenLocation) {
      onOpenLocation();
      return;
    }
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
            <span className={styles.appName}>Vizita</span>
          </Link>
        </div>

        <div className={styles.userArea}>
          <button
            type="button"
            className={styles.locationCard}
            onClick={() => (onOpenLocation ? onOpenLocation() : navigate('/'))}
            title="Promjena lokacije"
          >
            <span className={styles.locText}>
              {hasSelection ? (
                <>
                  <span className={styles.locPrimary}>{groupValue}</span>
                  <span className={styles.locSecondary}>{storageValue}</span>
                </>
              ) : (
                <span className={styles.locSingle}>Odaberite lokaciju</span>
              )}
            </span>
          </button>

          <button
            type="button"
            className={styles.iconBtn}
            onClick={handleExit}
            title="Login / promjena"
            aria-label="Login ili promjena lokacije"
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
