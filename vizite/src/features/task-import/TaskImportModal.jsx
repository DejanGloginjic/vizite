import React, { useMemo, useState } from "react";
import { createPortal } from "react-dom";
import dayjs from "dayjs";
import { message } from "antd";

import styles from "./TaskImportModal.module.css";
import { usePatientTasksQuery, useCloneTasksMutation } from "../../entities/task/queries";

const typeColor = (id) => {
  const n = Number(id);
  if (n === 3) return styles.typeTherapy;
  if (n === 5) return styles.typeTemp;
  if (n === 6) return styles.typePressure;
  if (n === 7) return styles.typePulse;
  if (n === 10) return styles.typeDiet;
  if (n === 14) return styles.typeTask;
  if (n === 13) return styles.typeNote;
  return styles.typeDefault;
};

export default function TaskImportModal({ open, onClose, patientId, targetDate }) {
  const yesterday = dayjs().subtract(1, "day").format("YYYY-MM-DD");
  const [sourceDate, setSourceDate] = useState(yesterday);
  const [target, setTarget] = useState(targetDate || dayjs().format("YYYY-MM-DD"));
  const [selected, setSelected] = useState({});

  const {
    data: sourceTasks = [],
    isLoading,
    isFetching,
    isError,
    error,
  } = usePatientTasksQuery(open ? patientId : null, sourceDate);

  const { mutateAsync: cloneTasks, isPending } = useCloneTasksMutation(patientId, target);

  const list = useMemo(() => (Array.isArray(sourceTasks) ? sourceTasks : []), [sourceTasks]);

  const toggle = (id) =>
    setSelected((m) => ({
      ...m,
      [id]: !m[id],
    }));

  const allSelected = list.length && list.every((t) => selected[t.id]);

  const toggleAll = () => {
    if (!list.length) return;
    if (allSelected) {
      setSelected({});
    } else {
      const m = {};
      list.forEach((t) => {
        if (t.id) m[t.id] = true;
      });
      setSelected(m);
    }
  };

  const selectedIds = useMemo(
    () => list.filter((t) => selected[t.id]).map((t) => t.id),
    [list, selected]
  );

  const handleImport = async () => {
    if (!selectedIds.length) {
      message.warning("Označite bar jedan zadatak za uvoz.");
      return;
    }
    try {
      await cloneTasks({
        patient_id: patientId,
        source_date: sourceDate,
        target_date: target,
        task_ids: selectedIds.join(","),
      });
      message.success("Zadaci su prebačeni na odabrani dan.");
      onClose?.();
    } catch (err) {
      message.error(err?.message || "Greška pri uvozu zadataka.");
    }
  };

  if (!open) return null;

  return createPortal(
    <div className={styles.overlay} role="dialog" aria-modal="true">
      <div className={styles.panel}>
        <header className={styles.header}>
          <div>
            <p className={styles.overline}>Uvezi zadatke</p>
            <h2 className={styles.title}>
              Prethodni dan / drugi datum
            </h2>
          </div>
          <button className={styles.closeBtn} onClick={onClose} aria-label="Zatvori">
            ×
          </button>
        </header>

        <div className={styles.controls}>
          <div className={styles.control}>
            <label className={styles.label}>Datum izvora</label>
            <input
              type="date"
              className={styles.input}
              value={sourceDate}
              onChange={(e) => setSourceDate(e.target.value)}
            />
          </div>
          <div className={styles.control}>
            <label className={styles.label}>Ciljni datum</label>
            <input
              type="date"
              className={styles.input}
              value={target}
              onChange={(e) => setTarget(e.target.value)}
            />
          </div>
          <button type="button" className={styles.toggleAll} onClick={toggleAll}>
            {allSelected ? "Poništi sve" : "Označi sve"}
          </button>
        </div>

        <div className={styles.listWrap}>
          {isLoading || isFetching ? (
            <div className={styles.state}>Učitavam zadatke…</div>
          ) : isError ? (
            <div className={styles.stateErr}>
              Greška: {String(error?.message || "")}
            </div>
          ) : !list.length ? (
            <div className={styles.state}>Nema zadataka za odabrani datum.</div>
          ) : (
            <ul className={styles.list}>
              {list.map((t) => {
                const time = t.datum ? dayjs(t.datum).format("HH:mm") : "";
                const badgeText = t.naziv || t.vrsta || "Zadatak";
                const val = t.vrijednost || t.kolicina || "";
                return (
                  <li key={t.id} className={styles.item}>
                    <label className={styles.itemLabel}>
                      <input
                        type="checkbox"
                        checked={!!selected[t.id]}
                        onChange={() => toggle(t.id)}
                      />
                      <span className={`${styles.badge} ${typeColor(t.id_vrste)}`}>
                        {badgeText}
                      </span>
                      {time ? <span className={styles.time}>{time}</span> : null}
                      {val ? <span className={styles.val}>{val}</span> : null}
                    </label>
                  </li>
                );
              })}
            </ul>
          )}
        </div>

        <div className={styles.actionBar}>
          <div className={styles.summary}>
            {selectedIds.length} od {list.length} označeno
          </div>
          <div className={styles.actions}>
            <button className={styles.secondary} onClick={onClose} type="button">
              Odustani
            </button>
            <button
              className={styles.primary}
              type="button"
              onClick={handleImport}
              disabled={!selectedIds.length || isPending}
            >
              {isPending ? "Prebacujem..." : "Prebaci zadatke"}
            </button>
          </div>
        </div>
      </div>
    </div>,
    document.body
  );
}
