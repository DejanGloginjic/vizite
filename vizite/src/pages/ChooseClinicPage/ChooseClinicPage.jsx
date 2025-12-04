import React, { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Select } from 'antd';
import styles from './ChooseClinicPage.module.css';
import { useUserStoragesQuery } from '../../entities/storage/queries';
import ConfirmModal from '../../shared/ui/ConfirmModal/ConfirmModal';
import { useSession } from '../../app/providers/SessionContext';
import logo from '../../assets/logo.svg';
import { useSetWorkingLocation } from '../../entities/storage/queries';

function getUserNameFromSession(s) {
  if (!s) return '';
  return (
    s.ime_korisnika || s.potpis_korisnika || [s.ime, s.prezime].filter(Boolean).join(' ') || ''
  );
}

export default function ChooseClinicPage() {
  const navigate = useNavigate();
  const { session } = useSession() || { session: null };
  const userName = (getUserNameFromSession(session) || 'Korisnik').trim();

  const { data = [], isLoading, isError, error } = useUserStoragesQuery();
  const setWorkingLocationMutation = useSetWorkingLocation();

  const [selectedGroupId, setSelectedGroupId] = useState(null);
  const [selectedStorageId, setSelectedStorageId] = useState(null);
  const [logoutConfirmOpen, setLogoutConfirmOpen] = useState(false);

  // relativni logout URL:
  // /kis/vizite/dist/  ->  ../../pocetna.cfm  == /kis/pocetna.cfm
  const logoutHref =
    (typeof window !== 'undefined' && window.__LOGOUT_URL__) ||
    import.meta.env.VITE_LOGOUT_URL ||
    '../../pocetna.cfm';

  const groups = useMemo(() => (Array.isArray(data) ? data : []), [data]);

  const currentGroup = useMemo(
    () => groups.find((g) => String(g.id) === String(selectedGroupId)) || null,
    [groups, selectedGroupId],
  );

  const storages = useMemo(() => currentGroup?.skladista ?? [], [currentGroup]);

  const handleSelectGroup = (value) => {
    setSelectedGroupId(value);
    setSelectedStorageId(null);
  };

  const handleSelectStorage = (id) => {
    setSelectedStorageId(id);
  };

  const handleConfirmSelection = () => {
    if (!selectedGroupId || !selectedStorageId) return;

    const payload = {
      grupaId: Number(selectedGroupId),
      skladisteId: Number(selectedStorageId),
    };

    try {
      localStorage.setItem('vizite.clinicSelection', JSON.stringify(payload));
    } catch (_) {}

    setWorkingLocationMutation.mutate(payload, {
      onSuccess: () => {
        navigate('/patients', { replace: true });
      },
      onError: () => {
        // fallback – ipak idi na /, sesija se možda nije promijenila
        navigate('/', { replace: true });
      },
    });
  };

  const handleLogoutClick = () => {
    if (!logoutHref) {
      console.warn('Postavite VITE_LOGOUT_URL ili window.__LOGOUT_URL__');
      return;
    }
    setLogoutConfirmOpen(true);
  };

  const handleLogoutConfirm = () => {
    setLogoutConfirmOpen(false);
    if (logoutHref) {
      window.location.assign(logoutHref);
    }
  };

  const canConfirm = !!selectedGroupId && !!selectedStorageId;

  return (
    <div className={styles.shell}>
      {/* HEADER – isti layout kao globalni Header */}
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
            <div className={styles.userCard} title={userName} aria-label={userName}>
              <svg
                viewBox="0 0 24 24"
                className={styles.userIcon}
                width="22"
                height="22"
                aria-hidden="true"
              >
                <circle cx="12" cy="8" r="4" fill="none" stroke="currentColor" strokeWidth="1.8" />
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

            {/* ovdje na ovoj stranici dugme služi za odjavu / login */}
            <button
              type="button"
              className={styles.iconBtn}
              aria-label="Izlaz"
              title="Izlaz"
              onClick={handleLogoutClick}
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
      </header>

      {/* GLAVNI DIO – jedan Select + lista skladišta */}
      <main className={styles.main}>
        <section className={styles.panel}>
          <h1 className={styles.title}>Odabir lokacije rada</h1>

          {isLoading && <div className={styles.skel}>Učitavam podatke…</div>}

          {isError && (
            <div className={styles.err}>Greška pri učitavanju: {String(error?.message || '')}</div>
          )}

          {!isLoading && !isError && groups.length === 0 && (
            <div className={styles.empty}>Nemate dodijeljene organizacione jedinice.</div>
          )}

          {!isLoading && !isError && groups.length > 0 && (
            <>
              {/* 1) Select za skladiste grupu */}
              <div className={styles.field}>
                <label className={styles.label} htmlFor="group-select">
                  Klinika / organizaciona jedinica
                </label>
                <Select
                  id="group-select"
                  showSearch
                  placeholder="Odaberite kliniku"
                  className={styles.select}
                  value={selectedGroupId ?? undefined}
                  onChange={handleSelectGroup}
                  filterOption={(input, option) =>
                    (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                  }
                  options={groups.map((g) => ({
                    value: g.id,
                    label: g.mjesto ? `${g.naziv} · ${g.mjesto}` : g.naziv,
                  }))}
                />
              </div>

              {/* 2) Lista skladišta ispod */}
              <div className={styles.field}>
                <label className={styles.label}>Skladište</label>

                {selectedGroupId && storages.length === 0 && (
                  <div className={styles.emptyInline}>
                    Ova organizaciona jedinica nema definisana skladišta.
                  </div>
                )}

                {!selectedGroupId && (
                  <div className={styles.emptyInline}>Prvo izaberite kliniku.</div>
                )}

                {selectedGroupId && storages.length > 0 && (
                  <div className={styles.storageList}>
                    {storages.map((s) => {
                      const active = String(s.id) === String(selectedStorageId);
                      return (
                        <button
                          key={s.id}
                          type="button"
                          className={active ? styles.storageItemActive : styles.storageItem}
                          onClick={() => handleSelectStorage(s.id)}
                        >
                          <div className={styles.storageName}>{s.naziv}</div>
                          {s.adresa && <div className={styles.storageMeta}>{s.adresa}</div>}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            </>
          )}

          <div className={styles.footer}>
            <button
              type="button"
              className={styles.secondary}
              onClick={() => navigate('/', { replace: true })}
            >
              Odustani
            </button>
            <button
              type="button"
              className={canConfirm ? styles.primary : styles.primaryDisabled}
              disabled={!canConfirm}
              onClick={handleConfirmSelection}
            >
              Potvrdi
            </button>
          </div>
        </section>
      </main>

      {/* modal za odjavu / login */}
      <ConfirmModal
        open={logoutConfirmOpen}
        title="Da li ste sigurni da želite da se odjavite?"
        description=""
        confirmText="Odjavi me"
        cancelText="Odustani"
        onCancel={() => setLogoutConfirmOpen(false)}
        onConfirm={handleLogoutConfirm}
      />
    </div>
  );
}
