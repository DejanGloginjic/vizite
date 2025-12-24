import React, { useEffect, useMemo, useState } from 'react';
import styles from './LocationModal.module.css';

export default function LocationModal({
  open,
  loading,
  error,
  groups = [],
  activeGroupId,
  onSelectGroup,
  onSelectStorage,
  onClose,
  logoutUrl,
}) {
  const [search, setSearch] = useState('');
  const [isMobile, setIsMobile] = useState(false);
  const [mobileStep, setMobileStep] = useState('group'); // group | storage

  const filteredGroups = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!term) return groups;
    return groups.filter((g) => {
      const label = `${g.naziv || ''} ${g.mjesto || ''}`.toLowerCase();
      return label.includes(term);
    });
  }, [search, groups]);

  const storages = useMemo(() => {
    const g = groups.find((x) => String(x.id) === String(activeGroupId));
    return g?.skladista || [];
  }, [activeGroupId, groups]);

  useEffect(() => {
    const update = () => setIsMobile(typeof window !== 'undefined' ? window.innerWidth <= 640 : false);
    update();
    window.addEventListener('resize', update);
    return () => window.removeEventListener('resize', update);
  }, []);

  useEffect(() => {
    if (open) {
      setMobileStep('group');
    }
  }, [open]);

  if (!open) return null;

  return (
    <div className={styles.overlay} role="dialog" aria-modal="true">
      <div className={styles.panel}>
        <div className={styles.header}>
          <div>
            <p className={styles.overline}>Odabir lokacije rada</p>
            <h3 className={styles.title}>
              {isMobile && mobileStep === 'storage' ? 'Odaberite skladište' : 'Klinika i skladište'}
            </h3>
          </div>
          <button type="button" className={styles.close} onClick={onClose} aria-label="Zatvori">
            ×
          </button>
        </div>

        {loading ? (
          <div className={styles.state}>Učitavam podatke…</div>
        ) : error ? (
          <div className={styles.stateErr}>Greška pri učitavanju lokacija.</div>
        ) : isMobile ? (
          <>
            {mobileStep === 'group' ? (
              <>
                <div className={styles.searchRow}>
                  <input
                    type="search"
                    className={styles.search}
                    placeholder="Pretraga klinika"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    autoFocus
                  />
                </div>
                <div className={styles.list} role="list">
                  {filteredGroups.length === 0 ? (
                    <div className={styles.empty}>Nema rezultata.</div>
                  ) : (
                    filteredGroups.map((g) => {
                      const active = String(g.id) === String(activeGroupId);
                      const cls = active ? styles.itemActive : styles.item;
                      const meta = g.mjesto || g.opis || '';
                      return (
                        <button
                          key={g.id}
                          type="button"
                          className={cls}
                          onClick={() => {
                            onSelectGroup(g.id);
                            setMobileStep('storage');
                          }}
                          role="listitem"
                        >
                          <span className={styles.itemName}>{g.naziv}</span>
                          {meta && <span className={styles.itemMeta}>{meta}</span>}
                        </button>
                      );
                    })
                  )}
                </div>
              </>
            ) : (
              <>
                <div className={styles.mobileBar}>
                  <div className={styles.mobileMeta}>
                    {groups.find((x) => String(x.id) === String(activeGroupId))?.naziv || ''}
                  </div>
                </div>
                <div className={styles.list} role="list">
                  {!activeGroupId ? (
                    <div className={styles.empty}>Odaberite kliniku.</div>
                  ) : storages.length === 0 ? (
                    <div className={styles.empty}>Nema definisanih skladišta.</div>
                  ) : (
                    storages.map((s) => {
                      const meta = [s.adresa, s.mjesto, s.napomena].filter(Boolean).join(' | ');
                      return (
                        <button
                          key={s.id}
                          type="button"
                          className={styles.item}
                          onClick={() => {
                            onSelectStorage(s.id);
                            setMobileStep('group');
                          }}
                          role="listitem"
                        >
                          <span className={styles.itemName}>{s.naziv}</span>
                          {meta && <span className={styles.itemMeta}>{meta}</span>}
                        </button>
                      );
                    })
                  )}
                </div>
              </>
            )}
          </>
        ) : (
          <>
            <div className={styles.searchRow}>
              <input
                type="search"
                className={styles.search}
                placeholder="Pretraga klinika"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                autoFocus={!isMobile}
                inputMode="search"
              />
            </div>

            <div className={styles.columns}>
              <div className={styles.column}>
                <p className={styles.columnTitle}>Klinike</p>
                <div className={styles.list} role="list">
                  {filteredGroups.length === 0 ? (
                    <div className={styles.empty}>Nema rezultata.</div>
                  ) : (
                    filteredGroups.map((g) => {
                      const active = String(g.id) === String(activeGroupId);
                      const cls = active ? styles.itemActive : styles.item;
                      const meta = g.mjesto || g.opis || '';
                      return (
                        <button
                          key={g.id}
                          type="button"
                          className={cls}
                          onClick={() => onSelectGroup(g.id)}
                          role="listitem"
                        >
                          <span className={styles.itemName}>{g.naziv}</span>
                          {meta && <span className={styles.itemMeta}>{meta}</span>}
                        </button>
                      );
                    })
                  )}
                </div>
              </div>

              <div className={styles.column}>
                <p className={styles.columnTitle}>Skladišta</p>
                <div className={styles.list} role="list">
                  {!activeGroupId ? (
                    <div className={styles.empty}>Odaberite kliniku.</div>
                  ) : storages.length === 0 ? (
                    <div className={styles.empty}>Nema definisanih skladišta.</div>
                  ) : (
                    storages.map((s) => {
                      const meta = [s.adresa, s.mjesto, s.napomena].filter(Boolean).join(' | ');
                      return (
                        <button
                          key={s.id}
                          type="button"
                          className={styles.item}
                          onClick={() => onSelectStorage(s.id)}
                          role="listitem"
                        >
                          <span className={styles.itemName}>{s.naziv}</span>
                          {meta && <span className={styles.itemMeta}>{meta}</span>}
                        </button>
                      );
                    })
                  )}
                </div>
              </div>
            </div>
          </>
        )}

        <div className={styles.footer}>
          {isMobile && mobileStep === 'storage' ? (
            <button
              type="button"
              className={styles.backBtn}
              onClick={() => setMobileStep('group')}
            >
              ← Promijeni kliniku
            </button>
          ) : null}
        {logoutUrl ? (
          <button
            type="button"
            className={styles.exitBtn}
            onClick={() => window.location.assign(logoutUrl)}
          >
            Izađi iz aplikacije
          </button>
        ) : null}
      </div>
      </div>
    </div>
  );
}
