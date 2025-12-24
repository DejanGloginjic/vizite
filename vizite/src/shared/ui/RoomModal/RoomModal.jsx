import React from 'react';
import { LoadingOutlined, CloseOutlined } from '@ant-design/icons';
import styles from './RoomModal.module.css';

export function RoomModal({
  open,
  loading,
  rooms = [],
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
            <p className={styles.overline}>Filtriraj po sobi</p>
            <h3 className={styles.title}>Odaberite sobu</h3>
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
              <span className={styles.name}>Sve sobe</span>
              <span className={styles.count}>{totalCount}</span>
            </button>

            {loading ? (
              <div className={styles.state}>
                <LoadingOutlined /> Učitavanje soba...
              </div>
            ) : rooms.length === 0 ? (
              <div className={styles.state}>Nema soba za prikaz.</div>
            ) : (
              rooms.map((r) => {
                const id = String(r.id);
                const label = r.naziv ?? `Soba ${id}`;
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
                    <span className={styles.name}>{label}</span>
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
