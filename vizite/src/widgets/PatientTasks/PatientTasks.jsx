import React, { useEffect, useMemo, useState } from "react";
import styles from "./PatientTasks.module.css";

/**
 * PatientTasks
 * - tasks: Array<{
 *     id?, id_vrste?, naziv?, vrsta?, status?, uradjen?,
 *     vrijednost?, kolicina?, jedinica?,
 *     d_vrijednost?, d_jedinica?, d_ref_vrijednosti?,
 *     napomena?, datum?
 *   }>
 * - onSave?: (payload: { doneIds: string[], note: string }) => void
 */
export default function PatientTasks({ tasks = [], onSave }) {
  const items = useMemo(() => tasks || [], [tasks]);

  const [checkedMap, setCheckedMap] = useState({});
  const [note, setNote] = useState("");

  const isDone = (t) =>
    Number(t.status) === 1 || String(t.status) === "1" || t.uradjen === 1;

  const taskKey = (t, i) =>
    String(t.id ?? `${t.id_vrste ?? "vrsta"}_${t.datum ?? ""}_${i}`);

  // helpers
  const formatTime = (s) => {
    if (!s) return "";
    const m = String(s).match(/(?:\s|T)(\d{2}:\d{2})/);
    return m ? m[1] : "";
  };
  const buildValueText = (t) => {
    const v =
      t.d_vrijednost ?? t.vrijednost ?? (t.kolicina != null ? t.kolicina : "");
    const u = t.d_jedinica ?? t.jedinica ?? "";
    if (v === "" || v === null || v === undefined) return null;
    return `${v}${u ? ` ${u}` : ""}`;
  };

  // reset selection na promjenu tasks
  useEffect(() => {
    const init = {};
    items.forEach((t, i) => {
      const key = taskKey(t, i);
      if (!isDone(t)) init[key] = false;
    });
    setCheckedMap(init);
  }, [items]);

  const toggle = (key) => setCheckedMap((m) => ({ ...m, [key]: !m[key] }));
  const selectedCount = useMemo(
    () => Object.values(checkedMap).filter(Boolean).length,
    [checkedMap]
  );
  const canSave = selectedCount > 0 || note.trim().length > 0;

  const handleSave = (e) => {
    e.preventDefault();
    const keyedItems = items.map((t, i) => [taskKey(t, i), t]);
    const completed = keyedItems.filter(([key]) => checkedMap[key]);
    const doneIds = completed.map(([key]) => key);
    const doneTasks = completed.map(([, task]) => task);
    onSave?.({ doneIds, doneTasks, note });
  };

  return (
    <form className={styles.form} onSubmit={handleSave}>
      {items.length ? (
        <ul className={styles.list}>
          {items.map((t, i) => {
            const key = taskKey(t, i);
            const done = isDone(t);

            const time = formatTime(t.datum);
            const valueText = buildValueText(t);
            const refRange = t.d_ref_vrijednosti || "";
            const noteSingle = t.napomena || "";

            return (
              <li key={key} className={styles.item}>
                <div className={styles.left}>
                  <div className={styles.titleRow}>
                    <div className={styles.title}>
                      {t.naziv ?? t.vrsta ?? "Zadatak"}
                    </div>
                    {time ? (
                      <span className={styles.timeWrap} title="Vrijeme">
                        <svg
                          className={styles.timeIcon}
                          viewBox="0 0 24 24"
                          aria-hidden="true"
                        >
                          <circle
                            cx="12"
                            cy="12"
                            r="8"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="1.5"
                          />
                          <path
                            d="M12 8v5l3 2"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="1.5"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          />
                        </svg>
                        <span className={styles.time}>{time}</span>
                      </span>
                    ) : null}
                  </div>

                  <div className={styles.detailsRow}>
                    {valueText ? (
                      <span className={`${styles.detail} ${styles.em}`}>
                        {valueText}
                      </span>
                    ) : null}
                    {refRange ? (
                      <span className={styles.detail}>Ref: {refRange}</span>
                    ) : null}
                    {noteSingle ? (
                      <span
                        className={`${styles.detail} ${styles.noteOne}`}
                        title={noteSingle}
                      >
                        {noteSingle}
                      </span>
                    ) : null}
                  </div>
                </div>

                <div className={styles.right}>
                  {done ? (
                    // ✅ samo zelena kvačica (bez okvira/pozadine)
                    <span className={styles.doneCheck} title="Urađeno">
                      <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path
                          d="M6 12.5l4 4 8-9"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.6"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    </span>
                  ) : (
                    <label className={styles.prettyCheck} aria-label="Označi">
                      <input
                        type="checkbox"
                        className={styles.checkboxInput}
                        checked={!!checkedMap[key]}
                        onChange={() => toggle(key)}
                      />
                      <span className={styles.checkboxControl} aria-hidden>
                        <svg
                          className={styles.tick}
                          viewBox="0 0 24 24"
                          aria-hidden="true"
                        >
                          <path d="M6 12.5l4 4 8-9" />
                        </svg>
                      </span>
                    </label>
                  )}
                </div>
              </li>
            );
          })}
        </ul>
      ) : (
        <div className={styles.empty}>Nema zadataka za odabrani dan.</div>
      )}

      <div className={styles.noteWrap}>
        <label className={styles.noteLabel}>Napomena (opciono)</label>
        <textarea
          className={styles.note}
          rows={3}
          placeholder="Upišite napomenu…"
          value={note}
          onChange={(e) => setNote(e.target.value)}
        />
      </div>

      <div className={styles.stickyBar}>
        <div className={styles.stickyInner}>
          <div className={styles.summary}>
            {selectedCount > 0 ? (
              <span className={styles.selText}>{selectedCount} označeno</span>
            ) : (
              <span className={styles.dim}>Ništa nije označeno</span>
            )}
          </div>
          <button
            className={`${styles.saveBtnBig} ${
              !canSave ? styles.saveDisabled : ""
            }`}
            type="submit"
            disabled={!canSave}
          >
            Sačuvaj
          </button>
        </div>
      </div>
    </form>
  );
}
