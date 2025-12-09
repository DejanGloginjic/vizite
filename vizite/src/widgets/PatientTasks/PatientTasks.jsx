import React, { useEffect, useMemo, useState } from 'react';
import styles from './PatientTasks.module.css';

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
  const [measureMap, setMeasureMap] = useState({});
  const [note, setNote] = useState('');

  const isDone = (t) => Number(t.status) === 1 || String(t.status) === '1' || t.uradjen === 1;

  const taskKey = (t, i) => String(t.id ?? `${t.id_vrste ?? 'vrsta'}_${t.datum ?? ''}_${i}`);

  // helpers
  const formatTime = (s) => {
    if (!s) return '';
    const m = String(s).match(/(?:\s|T)(\d{2}:\d{2})/);
    return m ? m[1] : '';
  };
  const buildValueText = (t) => {
    const name = t.d_vrijednost ?? t.vrijednost ?? '';
    const unit = t.d_jedinica ?? t.jedinica ?? '';
    const qty = t.kolicina;
    const isTherapy = Number(t.id_vrste) === 3;

    if (isTherapy) {
      const parts = [];
      if (name) parts.push(name);
      if (qty !== undefined && qty !== null && String(qty).trim() !== '') {
        const qtyStr = String(qty);
        parts.push(`Doza: ${qtyStr}${unit ? ` ${unit}` : ''}`);
      }
      if (!parts.length) return null;
      return parts.join(' · ');
    }

    const val = name || (qty !== null && qty !== undefined ? qty : '');
    if (val === '' || val === null || val === undefined) return null;
    return `${val}${unit ? ` ${unit}` : ''}`;
  };

  const needsMeasurement = (t) => {
    const typeId = Number(t.id_vrste);
    return (
      typeId === 3 || // terapija (doza)
      typeId === 5 || // temperatura
      typeId === 6 || // pritisak
      typeId === 7 || // puls
      Number(t.d_vrijednost_required) === 1
    );
  };

  const renderMeasurement = (t, key) => {
    const typeId = Number(t.id_vrste);
    if (isDone(t) || !checkedMap[key] || !needsMeasurement(t)) return null;
    const unit = t.d_jedinica ?? t.jedinica ?? '';
    const m = measureMap[key] || { v1: '', v2: '' };
    const setVal = (field, v) =>
      setMeasureMap((prev) => ({
        ...prev,
        [key]: { ...(prev[key] || {}), [field]: v },
      }));

    if (typeId === 6) {
      // pritisak: gornji/donji
      return (
        <div className={styles.measureBox}>
          <div className={styles.measureLabel}>Izmjereni pritisak</div>
          <div className={styles.pressureInputs}>
            <input
              type="number"
              inputMode="numeric"
              placeholder="120"
              value={m.v1}
              onChange={(e) => setVal('v1', e.target.value)}
              className={styles.measureInput}
            />
            <span className={styles.measureUnit}>/</span>
            <input
              type="number"
              inputMode="numeric"
              placeholder="80"
              value={m.v2}
              onChange={(e) => setVal('v2', e.target.value)}
              className={styles.measureInput}
            />
            <span className={styles.measureUnit}>{unit || 'mmHg'}</span>
          </div>
        </div>
      );
    }

    const placeholderMap = {
      5: '36.6',
      7: '72',
      3: 'Doza',
    };
    const labelMap = {
      3: 'Doza',
      5: 'Izmjerena temperatura',
      7: 'Izmjereni puls',
    };

    return (
      <div className={styles.measureBox}>
        <div className={styles.measureLabel}>{labelMap[typeId] || 'Izmjerena vrijednost'}</div>
        <div className={styles.measureInputs}>
          <input
            type="number"
            inputMode="decimal"
            placeholder={placeholderMap[typeId] || 'Vrijednost'}
            value={m.v1}
            onChange={(e) => setVal('v1', e.target.value)}
            className={styles.measureInput}
          />
          {unit ? <span className={styles.measureUnit}>{unit}</span> : null}
        </div>
      </div>
    );
  };

  // reset selection na promjenu tasks
  useEffect(() => {
    const init = {};
    const initMeasure = {};
    items.forEach((t, i) => {
      const key = taskKey(t, i);
      if (!isDone(t)) init[key] = false;
      const typeId = Number(t.id_vrste);
      const base = { v1: '', v2: '' };
      if (typeId === 3 && t.kolicina != null && t.kolicina !== '') {
        base.v1 = String(t.kolicina);
      }
      initMeasure[key] = base;
    });
    setCheckedMap(init);
    setMeasureMap(initMeasure);
  }, [items]);

  const toggle = (key) => setCheckedMap((m) => ({ ...m, [key]: !m[key] }));
  const selectedCount = useMemo(
    () => Object.values(checkedMap).filter(Boolean).length,
    [checkedMap],
  );
  const canSave = selectedCount > 0 || note.trim().length > 0;

  const handleSave = (e) => {
    e.preventDefault();
    const keyedItems = items.map((t, i) => [taskKey(t, i), t]);
    const completed = keyedItems.filter(([key]) => checkedMap[key]);
    const doneIds = completed.map(([key]) => key);
    const doneTasks = completed.map(([, task]) => task);
    const measurements = completed.map(([key, task]) => {
      const m = measureMap[key] || {};
      const entry = {
        task,
        id: task.id,
        id_vrste: task.id_vrste,
        value: m.v1 ?? '',
        value2: m.v2 ?? '',
        unit: task.d_jedinica ?? task.jedinica ?? '',
      };
      if (Number(task.id_vrste) === 3) {
        entry.kolicina = m.v1 ?? '';
      }
      return entry;
    });
    onSave?.({ doneIds, doneTasks, note, measurements });
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
            const refRange = t.d_ref_vrijednosti || '';
            const noteSingle = t.napomena || '';

            return (
              <li key={key} className={styles.item}>
                <div className={styles.left}>
                  <div className={styles.titleRow}>
                    <div className={styles.title}>{t.naziv ?? t.vrsta ?? 'Zadatak'}</div>
                    {time ? (
                      <span className={styles.timeWrap} title="Vrijeme">
                        <svg className={styles.timeIcon} viewBox="0 0 24 24" aria-hidden="true">
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
                      <span className={`${styles.detail} ${styles.em}`}>{valueText}</span>
                    ) : null}
                    {refRange ? <span className={styles.detail}>Ref: {refRange}</span> : null}
                    {noteSingle ? (
                      <span className={`${styles.detail} ${styles.noteOne}`} title={noteSingle}>
                        {noteSingle}
                      </span>
                    ) : null}
                  </div>

                  {renderMeasurement(t, key)}
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
                        <svg className={styles.tick} viewBox="0 0 24 24" aria-hidden="true">
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
            className={`${styles.saveBtnBig} ${!canSave ? styles.saveDisabled : ''}`}
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
