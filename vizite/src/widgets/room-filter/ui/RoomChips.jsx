import React, { useEffect, useRef, useState } from "react";
import styles from "./RoomChips.module.css";

/**
 * RoomChips
 * - rooms: [{ id, naziv, count? }]
 * - value: string (trenutno izabrana soba id) ili "" za Sve
 * - onChange: (id: string|"") => void
 * - loading: bool
 */
export function RoomChips({ rooms = [], value = "", onChange, loading }) {
  const wrapRef = useRef(null);
  const [canL, setCanL] = useState(false);
  const [canR, setCanR] = useState(false);

  const updateArrows = () => {
    const el = wrapRef.current;
    if (!el) return;
    setCanL(el.scrollLeft > 0);
    setCanR(el.scrollLeft + el.clientWidth < el.scrollWidth - 1);
  };

  useEffect(() => {
    updateArrows();
    const el = wrapRef.current;
    if (!el) return;
    const h = () => updateArrows();
    el.addEventListener("scroll", h, { passive: true });
    const ro = new ResizeObserver(h);
    ro.observe(el);
    return () => {
      el.removeEventListener("scroll", h);
      ro.disconnect();
    };
  }, []);

  const scrollBy = (dx) => {
    wrapRef.current?.scrollBy({ left: dx, behavior: "smooth" });
  };

  const handlePick = (v) => {
    if (loading) return;
    if (v === value) return;
    onChange?.(v);
  };

  return (
    <div className={styles.shell}>
      <button
        type="button"
        className={`${styles.scrollBtn} ${!canL ? styles.hidden : ""}`}
        onClick={() => scrollBy(-240)}
        aria-label="Skrol lijevo"
      >
        <svg viewBox="0 0 24 24" className={styles.icon} aria-hidden="true">
          <path
            d="M15 6l-6 6 6 6"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
          />
        </svg>
      </button>

      <div ref={wrapRef} className={styles.wrap} aria-label="Filter po sobi">
        <button
          type="button"
          className={`${styles.chip} ${value === "" ? styles.active : ""}`}
          onClick={() => handlePick("")}
          disabled={loading}
        >
          Sve
        </button>

        {rooms.map((r) => {
          const id = String(r.id);
          const label = r.naziv ?? `Soba ${id}`;
          const count = r.count;
          const active = value === id;
          return (
            <button
              key={id}
              type="button"
              className={`${styles.chip} ${active ? styles.active : ""}`}
              onClick={() => handlePick(id)}
              disabled={loading}
              title={label}
            >
              {label}
              {typeof count === "number" ? (
                <span className={styles.badge}>{count}</span>
              ) : null}
            </button>
          );
        })}
      </div>

      <button
        type="button"
        className={`${styles.scrollBtn} ${!canR ? styles.hidden : ""}`}
        onClick={() => scrollBy(240)}
        aria-label="Skrol desno"
      >
        <svg viewBox="0 0 24 24" className={styles.icon} aria-hidden="true">
          <path
            d="M9 6l6 6-6 6"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
          />
        </svg>
      </button>
    </div>
  );
}
