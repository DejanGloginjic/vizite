import React, { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import dayjs from 'dayjs';
import { message } from 'antd';

import styles from './TaskCreateModal.module.css';
import {
  useCreateTaskMutation,
  useTaskTypesQuery,
  useDietsQuery,
} from '../../entities/task/queries';
import { useProductsQuery } from '../../entities/product/queries';

const TYPE_IDS = {
  THERAPY: 3,
  TEMP: 5,
  PRESSURE: 6,
  PULSE: 7,
  DIET: 10,
  NOTE: 13,
  TASK: 14,
  DIAG: 15,
};

const MEAL_OPTIONS = [
  { value: 'dorucak', label: 'DORUČAK' },
  { value: 'rucak', label: 'RUČAK' },
  { value: 'vecera', label: 'VEČERA' },
];

const DIET_OPTIONS = [
  { value: '', label: '... IZABERITE DIJETU' },
  { value: 'Standard', label: 'Standard' },
  { value: 'Laka', label: 'Laka' },
  { value: 'Dijabetička', label: 'Dijabetička' },
  { value: 'Bez glutena', label: 'Bez glutena' },
  { value: 'Bez laktoze', label: 'Bez laktoze' },
  { value: 'Po preporuci ljekara', label: 'Po preporuci ljekara' },
];

const REPEAT_OPTIONS = ['1', '2', '3', '4', '5', '6', 'multi'];

const formatDateTimeForServer = (dt) =>
  dayjs(dt).isValid() ? dayjs(dt).format('YYYY-MM-DD HH:mm:ss') : '';

export default function TaskCreateModal({ open, onClose, patientId, defaultDate }) {
  const todayStr = (defaultDate && String(defaultDate)) || dayjs().format('YYYY-MM-DD');
  const [startAt, setStartAt] = useState(`${todayStr}T${dayjs().format('HH:mm')}`);
  const [typeId, setTypeId] = useState(null);
  const [repeatChoice, setRepeatChoice] = useState('1');
  const [customRepeat, setCustomRepeat] = useState('7');
  const [repeatEveryHours, setRepeatEveryHours] = useState('6');
  const [note, setNote] = useState('');

  // vrijednosti po vrsti
  const [therapyName, setTherapyName] = useState('');
  const [therapyDose, setTherapyDose] = useState('1');
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [productTerm, setProductTerm] = useState('');
  const [productSheetOpen, setProductSheetOpen] = useState(false);
  const [dietSheetOpen, setDietSheetOpen] = useState(false);

  const [tempValue, setTempValue] = useState('');
  const [pressureSys, setPressureSys] = useState('');
  const [pressureDia, setPressureDia] = useState('');
  const [pulseValue, setPulseValue] = useState('');

  const [dietId, setDietId] = useState('');
  const [dietType, setDietType] = useState('');
  const [dietSearch, setDietSearch] = useState('');
  const [meal, setMeal] = useState(MEAL_OPTIONS[0].value);

  const [taskText, setTaskText] = useState('');
  const [observationText, setObservationText] = useState('');

  const [markDone, setMarkDone] = useState(false);

  const { data: types = [], isLoading: typesLoading } = useTaskTypesQuery();
  const { data: diets = [], isLoading: dietsLoading } = useDietsQuery();
  const { mutateAsync: createTask, isPending } = useCreateTaskMutation(patientId, defaultDate);

  // debounce za pretragu proizvoda
  const [debouncedTerm, setDebouncedTerm] = useState('');
  useEffect(() => {
    const t = setTimeout(() => setDebouncedTerm(productTerm.trim()), 220);
    return () => clearTimeout(t);
  }, [productTerm]);

  const shouldLoadProducts =
    productSheetOpen || productTerm.trim().length >= 2 || therapyName.trim().length >= 2;
  const {
    data: products = [],
    isFetching: productsLoading,
    refetch: refetchProducts,
  } = useProductsQuery(debouncedTerm, shouldLoadProducts);

  // reset kada se modal otvori
  useEffect(() => {
    if (!open) return;
    const base = `${todayStr}T${dayjs().format('HH:mm')}`;
    setStartAt(base);
    setRepeatChoice('1');
    setCustomRepeat('7');
    setRepeatEveryHours('6');
    setNote('');
    setTherapyName('');
    setTherapyDose('1');
    setSelectedProduct(null);
    setTempValue('');
    setPressureSys('');
    setPressureDia('');
    setPulseValue('');
    setDietId('');
    setDietType('');
    setDietSearch('');
    setDietSheetOpen(false);
    setMeal(MEAL_OPTIONS[0].value);
    setTaskText('');
    setObservationText('');
    setMarkDone(false);
  }, [open, todayStr]);

  // odabir default vrste kada stignu sifrarnici
  useEffect(() => {
    if (!open) return;
    if (typeId) return;
    const available = (types || []).filter((t) => t.d_ukljuceno !== 0);
    const prefer = available.find((t) => t.id === TYPE_IDS.THERAPY) || available[0];
    if (prefer) setTypeId(prefer.id);
  }, [open, typeId, types]);

  // fokus trapping i zabrana scroll-a
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  const activeTypes = useMemo(() => (types || []).filter((t) => t.d_ukljuceno !== 0), [types]);

  const currentType = useMemo(
    () => activeTypes.find((t) => t.id === typeId) || activeTypes[0],
    [activeTypes, typeId],
  );

  useEffect(() => {
    setMarkDone(false);
  }, [typeId]);

  const repeatCount = useMemo(() => {
    if (currentType?.id === TYPE_IDS.DIET) return 1;
    if (repeatChoice === 'multi') {
      const n = Number(customRepeat || 0);
      return n > 0 ? n : 1;
    }
    const n = Number(repeatChoice || 1);
    return n > 0 ? n : 1;
  }, [customRepeat, repeatChoice, currentType]);

  const occurrenceList = useMemo(() => {
    if (!startAt) return [];
    const start = dayjs(startAt);
    if (!start.isValid()) return [];
    const intervalHours = Number(repeatEveryHours || 0);
    const list = [];
    for (let i = 0; i < repeatCount; i += 1) {
      const dt =
        i === 0 || repeatCount === 1 ? start : start.add(Math.max(intervalHours, 1) * i, 'hour');
      list.push(dt);
    }
    return list;
  }, [repeatCount, repeatEveryHours, startAt]);

  const formatOccurrence = (d) =>
    dayjs(d).isValid()
      ? currentType?.id === TYPE_IDS.DIET
        ? dayjs(d).format('DD.MM.YYYY')
        : dayjs(d).format('DD.MM. HH:mm')
      : '';

  const typeLabel = (t) => t?.naziv || t?.opis || 'Vrsta';
  const isDiet = currentType?.id === TYPE_IDS.DIET;

  const dietOptions = useMemo(() => {
    const opts = [...DIET_OPTIONS];
    if (Array.isArray(diets)) {
      diets.forEach((d) => {
        const label =
          d.dijeta_naz || d.dijeta_skraceni_naz || d.dijeta_sif || `Dijeta #${d.dijeta_id}`;
        opts.push({
          value: String(d.dijeta_id),
          label,
        });
      });
    }
    return opts;
  }, [diets]);

  const filteredDietOptions = useMemo(() => {
    if (!dietSearch.trim()) return dietOptions;
    const term = dietSearch.toLowerCase();
    return dietOptions.filter((o) => (o.label || '').toLowerCase().includes(term));
  }, [dietOptions, dietSearch]);

  const selectDiet = (opt) => {
    if (!opt) return;
    setDietId(String(opt.value));
    setDietType(opt.label || '');
    setDietSearch(opt.label || '');
    setDietSheetOpen(false);
  };

  const canSubmit =
    !!patientId && !!currentType && !!occurrenceList.length && !typesLoading && !isPending;

  const handleSelectProduct = (p) => {
    setSelectedProduct(p);
    if (p?.ime) setTherapyName(p.ime);
    setProductSheetOpen(false);
  };

  const buildPayloads = () => {
    if (!patientId) throw new Error('Nedostaje pacijent.');
    if (!currentType) throw new Error('Odaberite vrstu zadatka.');
    if (!occurrenceList.length) throw new Error('Nedostaje vrijeme zadatka.');

    const base = {
      patient_id: patientId,
      vrsta_id: currentType.id,
    };
    if (note.trim()) base.napomena = note.trim();

    const payloads = [];
    const commonStatus = markDone ? 1 : 0;

    const pushPayload = (dt, extra) => {
      payloads.push({
        ...base,
        datum: formatDateTimeForServer(dt),
        ...extra,
      });
    };

    const cleanedNumber = (v) => {
      if (v === null || v === undefined) return null;
      const s = String(v).trim().replace(',', '.');
      if (s === '') return null;
      return s;
    };

    if (currentType.id === TYPE_IDS.THERAPY) {
      if (!therapyName.trim()) throw new Error('Unesite naziv lijeka/terapije.');
      occurrenceList.forEach((dt) =>
        pushPayload(dt, {
          vrijednost: therapyName.trim(),
          kolicina: cleanedNumber(therapyDose),
          id_ref: selectedProduct?.id,
          status: 0,
        }),
      );
    } else if (currentType.id === TYPE_IDS.TEMP) {
      occurrenceList.forEach((dt) => {
        const val = cleanedNumber(tempValue);
        const status = val ? 1 : commonStatus;
        if (status === 1 && !val) {
          throw new Error('Unesite izmjerenu temperaturu ili iskljucite oznaci kao izvrseno.');
        }
        pushPayload(dt, {
          vrijednost: val || '',
          jedinica: '°C',
          status,
        });
      });
    } else if (currentType.id === TYPE_IDS.PRESSURE) {
      occurrenceList.forEach((dt) => {
        const sys = cleanedNumber(pressureSys);
        const dia = cleanedNumber(pressureDia);
        const hasVal = sys && dia;
        const status = hasVal ? 1 : commonStatus;
        if (status === 1 && (!sys || !dia)) {
          throw new Error('Unesite i gornji i donji pritisak.');
        }
        pushPayload(dt, {
          vrijednost: hasVal ? `${sys}/${dia}` : '',
          jedinica: 'mmHg',
          status,
        });
      });
    } else if (currentType.id === TYPE_IDS.PULSE) {
      occurrenceList.forEach((dt) => {
        const val = cleanedNumber(pulseValue);
        const status = val ? 1 : commonStatus;
        if (status === 1 && !val) {
          throw new Error(
            'Unesite izmjereni puls ili ostavite prazno ako zadatak jos nije izvrsen.',
          );
        }
        pushPayload(dt, {
          vrijednost: val || '',
          jedinica: '/min',
          status,
        });
      });
    } else if (currentType.id === TYPE_IDS.DIET) {
      if (!dietId) throw new Error('Odaberite dijetu.');
      const mealLabel = MEAL_OPTIONS.find((m) => m.value === meal)?.label || 'OBROK';
      const diet = dietType || 'Dijeta';
      occurrenceList.forEach((dt) => {
        const dateOnly = dayjs(dt).startOf('day');
        pushPayload(dateOnly, {
          vrijednost: `${diet} - ${mealLabel}`,
          id_ref: Number(dietId),
          napomena: note.trim(),
          status: 0,
        });
      });
    } else if (currentType.id === TYPE_IDS.TASK) {
      if (!taskText.trim()) throw new Error('Opis zadatka je obavezan.');
      occurrenceList.forEach((dt) =>
        pushPayload(dt, {
          vrijednost: taskText.trim(),
          status: commonStatus,
        }),
      );
    } else if (currentType.id === TYPE_IDS.NOTE) {
      if (!observationText.trim()) throw new Error('Upišite opis zapažanja.');
      occurrenceList.forEach((dt) =>
        pushPayload(dt, {
          vrijednost: observationText.trim(),
          status: commonStatus,
        }),
      );
    } else {
      // fallback za druge tipove
      occurrenceList.forEach((dt) =>
        pushPayload(dt, {
          status: commonStatus,
        }),
      );
    }

    return payloads;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const payloads = buildPayloads();
      await Promise.all(payloads.map((p) => createTask(p)));
      message.success('Zadaci su kreirani.');
      onClose?.();
    } catch (err) {
      message.error(err?.message || 'Greška pri kreiranju zadatka.');
    }
  };

  if (!open) return null;

  return createPortal(
    <div className={styles.overlay} role="dialog" aria-modal="true">
      <div className={styles.panel}>
        <header className={styles.header}>
          <div>
            <p className={styles.overline}>Novi zadatak</p>
            <h2 className={styles.title}>
              {currentType ? typeLabel(currentType) : 'Odabir vrste'}
            </h2>
          </div>
          <button type="button" className={styles.closeBtn} onClick={onClose} aria-label="Zatvori">
            ×
          </button>
        </header>

        <form className={styles.body} onSubmit={handleSubmit}>
          <section className={styles.section}>
            <div className={styles.sectionHead}>
              <div>
                <p className={styles.sectionOver}>Vrsta zadatka</p>
                <h3 className={styles.sectionTitle}>Šta treba uraditi?</h3>
              </div>
              {typesLoading && <span className={styles.muted}>Učitavam šifrarnik…</span>}
            </div>
            <div className={styles.typeGrid}>
              {activeTypes.map((t) => {
                const active = t.id === typeId;
                return (
                  <button
                    key={t.id}
                    type="button"
                    className={`${styles.typeCard} ${active ? styles.typeCardActive : ''}`}
                    onClick={() => setTypeId(t.id)}
                  >
                    <span className={styles.typeName}>{typeLabel(t)}</span>
                  </button>
                );
              })}
            </div>
          </section>

          {/* Dinamički dio po vrsti */}
          {currentType?.id === TYPE_IDS.THERAPY && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Terapija</p>
                  <h3 className={styles.sectionTitle}>Lijek i doza</h3>
                </div>
                <button
                  type="button"
                  className={styles.outlineBtn}
                  onClick={() => {
                    setProductSheetOpen(true);
                    refetchProducts();
                  }}
                >
                  Lista lijekova
                </button>
              </div>

              <label className={styles.fieldLabel}>Naziv lijeka</label>
              <input
                className={styles.input}
                list="productOptions"
                value={therapyName}
                onChange={(e) => {
                  const val = e.target.value;
                  setTherapyName(val);
                  setProductTerm(val);
                  if (val && products.length) {
                    const match = products.find(
                      (p) => (p.ime || '').toLowerCase() === val.toLowerCase(),
                    );
                    if (match) {
                      handleSelectProduct(match);
                    } else {
                      setSelectedProduct(null);
                    }
                  } else {
                    setSelectedProduct(null);
                  }
                }}
                placeholder="npr. Bensedin 5mg"
                required
              />
              {therapyName.trim().length >= 2 && !!products.length ? (
                <datalist id="productOptions">
                  {products.map((p) => (
                    <option key={p.id} value={p.ime || ''} />
                  ))}
                </datalist>
              ) : null}

              <label className={styles.fieldLabel}>Količina / doza (opciono)</label>
              <input
                className={styles.input}
                type="number"
                min="0"
                step="0.1"
                value={therapyDose}
                onChange={(e) => setTherapyDose(e.target.value)}
                placeholder="npr. 1"
              />

              {selectedProduct ? (
                <div className={styles.selectedBox}>
                  <div>
                    <p className={styles.smallLabel}>Odabrani lijek</p>
                    <p className={styles.selectedTitle}>{selectedProduct.ime}</p>
                    <p className={styles.muted}>
                      Šifra: {selectedProduct.sifra || '—'} · Jedinica:{' '}
                      {selectedProduct.jedmj || '—'}
                    </p>
                  </div>
                  <button
                    type="button"
                    className={styles.clearBtn}
                    onClick={() => setSelectedProduct(null)}
                  >
                    Ukloni
                  </button>
                </div>
              ) : null}
            </section>
          )}

          <section className={styles.section}>
            <div className={styles.sectionHead}>
              <div>
                <p className={styles.sectionOver}>Raspored</p>
                <h3 className={styles.sectionTitle}>Kada?</h3>
              </div>
            </div>

            <label className={styles.fieldLabel}>
              {isDiet ? 'Datum' : 'Datum i vrijeme početka'}
            </label>
            <input
              className={styles.input}
              type={isDiet ? 'date' : 'datetime-local'}
              value={isDiet ? startAt?.slice(0, 10) : startAt}
              onChange={(e) =>
                isDiet
                  ? setStartAt(e.target.value ? `${e.target.value}T00:00` : '')
                  : setStartAt(e.target.value)
              }
              required
            />

            {!isDiet ? (
              <div className={styles.repeatRow}>
                <div className={styles.repeatGroup}>
                  <p className={styles.fieldLabel}>Broj ponavljanja</p>
                  <div className={styles.chips}>
                    {REPEAT_OPTIONS.map((opt) => (
                      <button
                        type="button"
                        key={opt}
                        className={`${styles.chip} ${
                          repeatChoice === opt ? styles.chipActive : ''
                        }`}
                        onClick={() => setRepeatChoice(opt)}
                      >
                        {opt === 'multi' ? 'Više termina' : `${opt}x`}
                      </button>
                    ))}
                  </div>
                </div>

                {repeatChoice === 'multi' ? (
                  <div className={styles.inlineField}>
                    <label className={styles.fieldLabel}>Ukupno termina</label>
                    <input
                      className={styles.input}
                      type="number"
                      min="2"
                      value={customRepeat}
                      onChange={(e) => setCustomRepeat(e.target.value)}
                    />
                  </div>
                ) : null}

                {repeatCount > 1 ? (
                  <div className={styles.inlineField}>
                    <label className={styles.fieldLabel}>Na svako koliko sati</label>
                    <input
                      className={styles.input}
                      type="number"
                      min="1"
                      value={repeatEveryHours}
                      onChange={(e) => setRepeatEveryHours(e.target.value)}
                    />
                  </div>
                ) : null}

                <div className={styles.schedulePreview}>
                  <p className={styles.muted}>Planirana vremena</p>
                  <div className={styles.badgeRow}>
                    {occurrenceList.map((dt, idx) => (
                      <span key={idx} className={styles.badge}>
                        {formatOccurrence(dt)}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            ) : null}
          </section>

          {currentType?.id === TYPE_IDS.TEMP && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Temperatura</p>
                  <h3 className={styles.sectionTitle}>Plan mjerenja</h3>
                </div>
              </div>
              <div className={styles.inlineField}>
                <label className={styles.fieldLabel}>Izmjerena temperatura (opciono)</label>
                <div className={styles.valueRow}>
                  <input
                    className={styles.input}
                    type="number"
                    step="0.1"
                    inputMode="decimal"
                    value={tempValue}
                    onChange={(e) => setTempValue(e.target.value)}
                    placeholder="36.6"
                  />
                  <span className={styles.unit}>°C</span>
                </div>
              </div>
              <label className={styles.switchLine}>
                <input
                  type="checkbox"
                  checked={markDone}
                  onChange={(e) => setMarkDone(e.target.checked)}
                />
                <span>Označi kao već izvršeno</span>
              </label>
            </section>
          )}

          {currentType?.id === TYPE_IDS.PRESSURE && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Arterijski pritisak</p>
                  <h3 className={styles.sectionTitle}>Plan mjerenja</h3>
                </div>
              </div>
              <label className={styles.fieldLabel}>Izmjereni pritisak (opciono)</label>
              <div className={styles.pressureRow}>
                <input
                  className={styles.input}
                  type="number"
                  inputMode="numeric"
                  placeholder="120"
                  value={pressureSys}
                  onChange={(e) => setPressureSys(e.target.value)}
                />
                <span className={styles.unit}>/</span>
                <input
                  className={styles.input}
                  type="number"
                  inputMode="numeric"
                  placeholder="80"
                  value={pressureDia}
                  onChange={(e) => setPressureDia(e.target.value)}
                />
                <span className={styles.unit}>mmHg</span>
              </div>
              <label className={styles.switchLine}>
                <input
                  type="checkbox"
                  checked={markDone}
                  onChange={(e) => setMarkDone(e.target.checked)}
                />
                <span>Označi kao već izvršeno</span>
              </label>
            </section>
          )}

          {currentType?.id === TYPE_IDS.PULSE && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Puls</p>
                  <h3 className={styles.sectionTitle}>Plan mjerenja</h3>
                </div>
              </div>
              <div className={styles.inlineField}>
                <label className={styles.fieldLabel}>Izmjereni puls (opciono)</label>
                <div className={styles.valueRow}>
                  <input
                    className={styles.input}
                    type="number"
                    inputMode="numeric"
                    placeholder="72"
                    value={pulseValue}
                    onChange={(e) => setPulseValue(e.target.value)}
                  />
                  <span className={styles.unit}>/min</span>
                </div>
              </div>
              <label className={styles.switchLine}>
                <input
                  type="checkbox"
                  checked={markDone}
                  onChange={(e) => setMarkDone(e.target.checked)}
                />
                <span>Označi kao već izvršeno</span>
              </label>
            </section>
          )}

          {currentType?.id === TYPE_IDS.DIET && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Dijeta</p>
                  <h3 className={styles.sectionTitle}>Naziv i obrok</h3>
                </div>
                <button
                  type="button"
                  className={styles.outlineBtn}
                  onClick={() => setDietSheetOpen(true)}
                >
                  Lista dijeta
                </button>
              </div>
              <label className={styles.fieldLabel}>Naziv dijete</label>
              <div className={styles.inlineField}>
                <div className={styles.inlineGrow}>
                  <input
                    className={styles.input}
                    type="text"
                    placeholder="Pretraži dijetu"
                    value={dietSearch}
                    list="dietOptionsList"
                    onChange={(e) => {
                      const val = e.target.value;
                      setDietSearch(val);
                      const match = val
                        ? filteredDietOptions.find(
                            (o) => (o.label || '').toLowerCase() === val.toLowerCase(),
                          )
                        : null;
                      if (match) {
                        selectDiet(match);
                      } else {
                        setDietId('');
                        setDietType('');
                      }
                    }}
                  />
                  {!!dietSearch.trim().length && (
                    <datalist id="dietOptionsList" style={{ width: '100%' }}>
                      {filteredDietOptions
                        .filter((o) => o.value)
                        .map((opt) => (
                          <option key={opt.value} value={opt.label} />
                        ))}
                    </datalist>
                  )}
                </div>
              </div>

              <label className={styles.fieldLabel}>Obrok</label>
              <div className={styles.selectLike}>
                <select
                  className={styles.select}
                  value={meal}
                  onChange={(e) => setMeal(e.target.value)}
                >
                  {MEAL_OPTIONS.map((m) => (
                    <option key={m.value} value={m.value}>
                      {m.label}
                    </option>
                  ))}
                </select>
              </div>
            </section>
          )}

          {currentType?.id === TYPE_IDS.TASK && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Zadatak</p>
                  <h3 className={styles.sectionTitle}>Opis zadatka</h3>
                </div>
              </div>
              <textarea
                className={styles.textarea}
                rows={3}
                placeholder="npr. Promijeniti zavoj"
                value={taskText}
                onChange={(e) => setTaskText(e.target.value)}
              />
            </section>
          )}

          {currentType?.id === TYPE_IDS.NOTE && (
            <section className={styles.section}>
              <div className={styles.sectionHead}>
                <div>
                  <p className={styles.sectionOver}>Zapažanje</p>
                  <h3 className={styles.sectionTitle}>Beleška</h3>
                </div>
              </div>
              <textarea
                className={styles.textarea}
                rows={3}
                placeholder="Upišite zapažanje"
                value={observationText}
                onChange={(e) => setObservationText(e.target.value)}
              />
            </section>
          )}

          <section className={styles.section}>
            <label className={styles.fieldLabel}>Napomena (opciono)</label>
            <textarea
              className={styles.textarea}
              rows={3}
              placeholder="Dodaj kratku napomenu"
              value={note}
              onChange={(e) => setNote(e.target.value)}
            />
          </section>

          <div className={styles.actionBar}>
            <button type="button" className={styles.secondaryBtn} onClick={onClose}>
              Odustani
            </button>
            <button type="submit" className={styles.primaryBtn} disabled={!canSubmit}>
              {isPending ? 'Spašavam...' : 'Sačuvaj zadatke'}
            </button>
          </div>
        </form>

        {/* Sheet za lijekove */}
        {productSheetOpen ? (
          <div className={styles.sheet}>
            <div className={styles.sheetHeader}>
              <h4 className={styles.sheetTitle}>Lijekovi</h4>
              <button
                type="button"
                className={styles.closeBtn}
                onClick={() => setProductSheetOpen(false)}
                aria-label="Zatvori listu lijekova"
              >
                ×
              </button>
            </div>
            <input
              className={styles.input}
              placeholder="Traži po nazivu, šifri ili ATC"
              value={productTerm}
              onChange={(e) => setProductTerm(e.target.value)}
            />
            <div className={styles.productsList}>
              {productsLoading ? (
                <div className={styles.muted}>Pretražujem…</div>
              ) : !products?.length ? (
                <div className={styles.muted}>Nema rezultata.</div>
              ) : (
                products.map((p) => (
                  <button
                    type="button"
                    key={p.id}
                    className={styles.productCard}
                    onClick={() => handleSelectProduct(p)}
                  >
                    <div className={styles.productTitle}>{p.ime}</div>
                    <div className={styles.productMeta}>
                      Šifra: {p.sifra || '—'} · ATC: {p.atc || '—'} · Jed: {p.jedmj || '—'}
                    </div>
                  </button>
                ))
              )}
            </div>
          </div>
        ) : null}

        {dietSheetOpen ? (
          <div className={styles.sheet}>
            <div className={styles.sheetHeader}>
              <h4 className={styles.sheetTitle}>Dijete</h4>
              <button
                type="button"
                className={styles.closeBtn}
                onClick={() => setDietSheetOpen(false)}
                aria-label="Zatvori listu dijeta"
              >
                ×
              </button>
            </div>
            <input
              className={styles.input}
              placeholder="Traži dijetu"
              value={dietSearch}
              onChange={(e) => setDietSearch(e.target.value)}
            />
            <div className={styles.productsList}>
              {dietsLoading ? (
                <div className={styles.muted}>Pretražujem…</div>
              ) : !filteredDietOptions.filter((o) => o.value).length ? (
                <div className={styles.muted}>Nema rezultata.</div>
              ) : (
                filteredDietOptions
                  .filter((o) => o.value)
                  .map((opt) => (
                    <button
                      type="button"
                      key={opt.value}
                      className={styles.productCard}
                      onClick={() => selectDiet(opt)}
                    >
                      <div className={styles.productTitle}>{opt.label}</div>
                    </button>
                  ))
              )}
            </div>
          </div>
        ) : null}
      </div>
    </div>,
    document.body,
  );
}
