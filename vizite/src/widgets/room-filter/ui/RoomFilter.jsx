import React, { useEffect, useMemo, useState } from "react";
import styles from "./room-filter.module.css";

/** Normalizacija soba iz pacijenta (imaš više naziva na backendu) */
function extractRoomId(p, roomsByName, roomsById) {
  let raw =
    p?.soba_id ?? p?.sobaId ?? p?.room_id ?? p?.roomId ?? p?.soba ?? null;

  if (typeof raw === "number") return String(raw);
  if (typeof raw === "string") {
    const s = raw.trim();
    if (/^\d+$/.test(s)) return s; // “101”
    const m = s.match(/(\d{1,6})$/); // “Soba 101” -> “101”
    if (m && roomsById.has(m[1])) return m[1];
    const byName = roomsByName.get(s.toLowerCase());
    if (byName) return byName;
  }
  const name = p?.soba_naziv ?? p?.sobaNaziv ?? null;
  if (name) {
    const byName = roomsByName.get(String(name).toLowerCase());
    if (byName) return byName;
  }
  return null;
}

/** Hook: media query (client only) */
function useMediaQuery(query, fallback = false) {
  const [match, setMatch] = useState(fallback);
  useEffect(() => {
    if (typeof window === "undefined" || !window.matchMedia) return;
    const mql = window.matchMedia(query);
    const onChange = () => setMatch(mql.matches);
    onChange();
    mql.addEventListener?.("change", onChange);
    return () => mql.removeEventListener?.("change", onChange);
  }, [query]);
  return match;
}

/**
 * Adaptivni RoomFilter:
 *  - ≤900px: native <select>
 *  - >900px: chipovi
 */
export default function RoomFilter({
  rooms = [],
  patientsAll = [],
  loading = false,
  value,
  onChange,
}) {
  const isNarrow = useMediaQuery("(max-width: 900px)", true);

  const roomsByName = useMemo(() => {
    const m = new Map();
    for (const r of rooms) {
      const label = (r.naziv ?? `Soba ${r.id}`).toString().toLowerCase();
      m.set(label, String(r.id));
    }
    return m;
  }, [rooms]);

  const roomsById = useMemo(() => {
    const m = new Map();
    for (const r of rooms) m.set(String(r.id), r);
    return m;
  }, [rooms]);

  // Brojači po sobi – računaj iz kompletnog skupa
  const counts = useMemo(() => {
    const m = new Map();
    for (const p of patientsAll || []) {
      const id = extractRoomId(p, roomsByName, roomsById);
      if (!id) continue;
      m.set(id, (m.get(id) || 0) + 1);
    }
    return m;
  }, [patientsAll, roomsByName, roomsById]);

  const total = patientsAll?.length ?? 0;

  // === Telefon/tablet (narrow) -> native select ===
  if (isNarrow) {
    return (
      <div className={styles.selectWrap}>
        <label className={styles.selectLabel}>Soba</label>
        <select
          className={styles.select}
          disabled={loading}
          value={value || ""}
          onChange={(e) => onChange?.(e.target.value)}
        >
          <option value="">{`Sve (${total})`}</option>
          {rooms.map((r) => {
            const id = String(r.id);
            const label = r.naziv ?? `Soba ${id}`;
            const count = counts.get(id) ?? 0;
            return (
              <option key={id} value={id}>
                {`${label} (${count})`}
              </option>
            );
          })}
        </select>
      </div>
    );
  }

  // === Desktop -> chipovi ===
  return (
    <div className={styles.wrap} aria-label="Filter soba">
      <div className={styles.chipsRow}>
        <button
          type="button"
          className={`${styles.chip} ${!value ? styles.active : ""}`}
          disabled={loading}
          onClick={() => onChange?.("")}
        >
          <span className={styles.chipLabel}>Svi</span>
          <span className={styles.countBubble}>{total}</span>
        </button>

        <div className={styles.scroller} role="listbox" aria-label="Sobe">
          {rooms.map((r) => {
            const id = String(r.id);
            const isActive = value === id;
            const count = counts.get(id) ?? 0;
            return (
              <button
                key={id}
                type="button"
                role="option"
                aria-selected={isActive}
                className={`${styles.chip} ${isActive ? styles.active : ""}`}
                disabled={loading}
                onClick={() => onChange?.(id)}
                title={r.naziv ?? `Soba ${id}`}
              >
                <span className={styles.chipLabel}>
                  {r.naziv ?? `Soba ${id}`}
                </span>
                <span className={styles.countBubble}>{count}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
