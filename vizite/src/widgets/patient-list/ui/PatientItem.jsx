import React, { useCallback, useMemo } from 'react';
import { Link } from 'react-router-dom';
import styles from './patients-list.module.css';

function resolveStatus(p, explicit) {
  let s =
    explicit ?? p?.task_state ?? p?.tasks_state ?? p?.zadaci_status ?? p?.status_zadataka ?? null;

  if (s != null) {
    const v = String(s).toLowerCase();
    if (['overdue', 'late', 'expired', 'kasni', '3'].includes(v)) return 'overdue';
    if (['open', 'todo', 'pending', 'nedovrseni', 'active', '1'].includes(v)) return 'open';
    if (['done', 'completed', 'zavrseni', '2'].includes(v)) return 'done';
    if (['none', '0', 'no'].includes(v)) return 'none';
  }

  const total = p?.task_total ?? p?.tasks_total ?? p?.zadaci_ukupno ?? null;
  const done = p?.task_done ?? p?.tasks_done ?? p?.zadaci_gotovo ?? null;
  const overdue = p?.task_overdue ?? p?.tasks_overdue ?? p?.zadaci_kasne ?? 0;

  if (typeof total === 'number') {
    if (total === 0) return 'none';
    if (Number(overdue) > 0) return 'overdue';
    if (typeof done === 'number' && done >= total) return 'done';
    return 'open';
  }
  if (Number(overdue) > 0) return 'overdue';
  return 'none';
}

function getAvatarUrl(p) {
  return p?.slika_url || p?.slika || p?.photo_url || p?.avatar_url || null;
}
function getInitials(p) {
  const a = (p?.prezime || '').trim();
  const b = (p?.ime || '').trim();
  const i1 = a ? a[0] : '';
  const i2 = b ? b[0] : '';
  return (i1 + i2).toUpperCase() || '?';
}

export default function PatientItem({ patient, onPrefetch, status }) {
  const p = patient || {};
  const state = resolveStatus(p, status);

  const room =
    p?.soba ?? p?.soba_naziv ?? p?.sobaNaziv ?? (p?.soba_id ? `Soba ${p.soba_id}` : null);

  const bed = p?.broj_kreveta ?? p?.krevet ?? p?.krevet_broj ?? p?.brojKreveta ?? null;

  const avatarUrl = getAvatarUrl(p);
  const initials = useMemo(() => getInitials(p), [p?.ime, p?.prezime]);

  const handlePrefetch = useCallback(() => {
    if (p?.id) onPrefetch?.(p.id);
  }, [p?.id, onPrefetch]);

  return (
    <Link
      to={`/patient/${p.id}`}
      className={styles.itemLink}
      onMouseEnter={handlePrefetch}
      onTouchStart={handlePrefetch}
    >
      {/* status traka — potpuno priljubljena uz lijevu ivicu */}
      <span
        className={`${styles.flag} ${
          state === 'overdue'
            ? styles.flagOverdue
            : state === 'open'
            ? styles.flagOpen
            : state === 'done'
            ? styles.flagDone
            : styles.flagNone
        }`}
        aria-hidden="true"
      />

      {/* avatar */}
      <div className={styles.avatar} aria-hidden={!!avatarUrl}>
        {avatarUrl ? <img src={avatarUrl} alt="" loading="lazy" /> : <span>{initials}</span>}
      </div>

      {/* ime/prezime */}
      <div className={styles.name} title={`${p.prezime ?? ''} ${p.ime ?? ''}`}>
        {p.prezime} {p.ime}
      </div>

      {/* desna meta: soba • krevet */}
      <div className={styles.metaRight}>
        {room ? <span>{room.toString().startsWith('Soba') ? room : `${room}`}</span> : null}
        {bed ? <span>Krevet {bed}</span> : null}
      </div>

      {/* strelica */}
      <span className={styles.chev} aria-hidden="true">
        ›
      </span>
    </Link>
  );
}
