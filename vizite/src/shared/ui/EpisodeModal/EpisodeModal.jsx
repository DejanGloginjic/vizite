import React from 'react';
import { LoadingOutlined, CloseOutlined } from '@ant-design/icons';
import styles from './EpisodeModal.module.css';

export function EpisodeModal({
  open,
  loading,
  episodes = [],
  selectedId,
  counts,
  totalCount = 0,
  onSelect,
  onClose,
}) {
  if (!open) return null;

  const getCount = (id) => {
    if (!counts) return 0;
    if (typeof counts.get === 'function') return counts.get(String(id)) ?? 0;
    return counts[id] ?? 0;
  };

  return (
    <div className={styles.overlay} role="dialog" aria-modal="true">
      <div className={styles.panel}>
        <div className={styles.header}>
          <div>
            <p className={styles.overline}>Filtriraj po epizodi</p>
            <h3 className={styles.title}>Odaberite epizodu</h3>
          </div>
          <button type="button" className={styles.close} onClick={onClose} aria-label="Zatvori">
            <CloseOutlined />
          </button>
        </div>

        <div className={styles.listWrap}>
          <div className={styles.list} role="list">
            <button
              type="button"
              className={`${styles.item} ${!selectedId ? styles.itemActive : ''}`}
              onClick={() => onSelect?.(null)}
            >
              <div className={styles.itemMain}>
                <span className={styles.name}>Sve epizode</span>
              </div>
              <span className={styles.count}>{totalCount}</span>
            </button>

            {loading ? (
              <div className={styles.state}>
                <LoadingOutlined /> Ucitavanje epizoda...
              </div>
            ) : episodes.length === 0 ? (
              <div className={styles.state}>Nema epizoda za prikaz.</div>
            ) : (
              episodes.map((ep) => {
                const id = String(ep.id);
                const label = ep.label ?? `Epizoda #${id}`;
                const range = ep.range ?? '';
                const c = getCount(id);
                const active = String(selectedId || '') === id;
                return (
                  <button
                    key={id}
                    type="button"
                    className={`${styles.item} ${active ? styles.itemActive : ''}`}
                    onClick={() => onSelect?.(id)}
                    role="listitem"
                  >
                    <div className={styles.itemMain}>
                      <span className={styles.name}>{label}</span>
                      {range ? <span className={styles.range}>{range}</span> : null}
                    </div>
                    <span className={styles.count}>{c}</span>
                  </button>
                );
              })
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
