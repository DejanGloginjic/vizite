import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useParams, useSearchParams } from 'react-router-dom';
import { Tabs, Button, message } from 'antd';
import { LoadingOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';

import styles from './PatientVisitPage.module.css';

import {
  usePatientQuery,
  usePatientDocumentsQuery,
  usePatientEpisodesQuery, // NOVO: epizode pacijenta
} from '../../entities/patient/queries';
import { usePatientTasksQuery, useUpdateTaskMutation } from '../../entities/task/queries';
import { toISODate } from '../../shared/lib/date';
import PatientHeader from '../../widgets/PatientHeader/PatientHeader';
import PatientTasks from '../../widgets/PatientTasks/PatientTasks';
import { ENV } from '../../shared/config/env';
import TaskCreateModal from '../../features/task-create/TaskCreateModal'; // NOVO
import TaskImportModal from '../../features/task-import/TaskImportModal';
import { EpisodeModal } from '../../shared/ui/EpisodeModal/EpisodeModal';

const DEFAULT_DOC_SIZE = { width: 794, height: 1123 }; // A4 @ 96dpi

export default function PatientVisitPage() {
  const { id } = useParams();
  const [sp, setSp] = useSearchParams();
  const today = toISODate();
  const date = sp.get('date') || today;

  const [episodeFilter, setEpisodeFilter] = useState(''); // '' = sve
  const [taskModalOpen, setTaskModalOpen] = useState(false);
  const [importModalOpen, setImportModalOpen] = useState(false);
  const [episodeModalOpen, setEpisodeModalOpen] = useState(false);

  // === viewer state (fullscreen prikaz dokumenta) ===
  const [viewerOpen, setViewerOpen] = useState(false);
  const [viewerDocs, setViewerDocs] = useState([]); // trenutna grupa dokumenata
  const [viewerIndex, setViewerIndex] = useState(0);
  const [touchStartX, setTouchStartX] = useState(null);
  const [docScale, setDocScale] = useState(1);
  const [docSize, setDocSize] = useState(DEFAULT_DOC_SIZE);
  const [docLoading, setDocLoading] = useState(false);
  const docViewerBodyRef = useRef(null);
  const docViewerIframeRef = useRef(null);

  const {
    data: patient,
    isLoading: patientLoading,
    isError: patientError,
    error: patientErr,
  } = usePatientQuery(id);

  const {
    data: tasks = [],
    isLoading: tasksLoading,
    isFetching: tasksFetching,
    isError: tasksError,
    error: tasksErr,
  } = usePatientTasksQuery(id, date);
  const { mutateAsync: updateTask } = useUpdateTaskMutation(id, date);

  const {
    data: rawDocs = [],
    isLoading: docsLoading,
    isError: docsError,
    error: docsErr,
  } = usePatientDocumentsQuery(id);

  // NOVO: sve epizode pacijenta (za dropdown)
  const { data: episodesData = [], isLoading: episodesLoading } = usePatientEpisodesQuery(id);

  const setDateValue = useCallback(
    (nextIso) => {
      const iso = dayjs(nextIso).format('YYYY-MM-DD');
      setSp(iso && iso !== today ? { date: iso } : {}); // danas bez query parametra
    },
    [setSp, today],
  );

  const onChangeDate = (e) => {
    const v = e.target.value;
    setDateValue(v || today);
  };

  const handleSaveTasks = useCallback(
    async ({ doneTasks = [], measurements = [] }) => {
      if (!doneTasks.length) return;

      const measById = new Map();
      (measurements || []).forEach((m) => {
        if (m?.id) measById.set(String(m.id), m);
      });

      try {
        const ops = doneTasks.map((task) => {
          if (!task?.id) {
            throw new Error('Zadatak nema ID (task_id), ne mogu ga oznaciti.');
          }
          const typeId = Number(task.id_vrste);
          const requiresVal = Number(task.d_vrijednost_required) === 1;
          const m = measById.get(String(task.id));

          let vrijednost = task.vrijednost || '';
          let jedinica = task.d_jedinica || task.jedinica || '';
          let kolicina = task.kolicina;

          if (typeId === 6) {
            const v1 = m?.value || '';
            const v2 = m?.value2 || '';
            if (!v1 || !v2) {
              throw new Error('Unesite sistolni i dijastolni pritisak.');
            }
            vrijednost = `${v1}/${v2}`;
            jedinica = m?.unit || jedinica || 'mmHg';
          } else if (typeId !== 3 && m && m.value) {
            vrijednost = m.value;
            if (m.unit) jedinica = m.unit;
          }

          if (requiresVal && !String(vrijednost || '').trim()) {
            throw new Error(
              `Zadatak "${task.naziv || task.vrsta || ''}" zahtijeva unos vrijednosti.`,
            );
          }

          if (typeId === 3 && m && m.kolicina !== undefined) {
            kolicina = m.kolicina;
          }

          const parsedQty = (() => {
            const raw = kolicina;
            if (raw === undefined || raw === null) return null;
            const s = String(raw).trim();
            if (!s.length) return null;
            const n = Number(s.replace(',', '.'));
            return Number.isNaN(n) ? null : n;
          })();

          const payload = {
            task_id: task.id,
            status: 1,
            vrijednost,
            jedinica,
          };
          if (Number.isFinite(parsedQty)) {
            payload.kolicina = parsedQty;
          }

          return updateTask(payload);
        });

        await Promise.all(ops);
        message.success('Zadaci su oznaceni kao izvrseni.');
      } catch (err) {
        message.error(err?.message || 'Greska pri azuriranju zadataka.');
      }
    },
    [updateTask],
  );

  // === priprema dokumenata ===
  const docs = useMemo(() => (Array.isArray(rawDocs) ? rawDocs : []), [rawDocs]);

  // mapa epizoda iz posebnog upita: id -> {label, range}
  const episodesMap = useMemo(() => {
    const map = new Map();
    for (const ep of episodesData || []) {
      const idEp = ep.id_epizode ?? ep.id;
      if (!idEp) continue;

      const broj = ep.broj_epizode || ep.broj || null;
      const datumOd = ep.datum_od || ep.od || null;
      const datumDo = ep.datum_do || ep.do || null;

      const labelParts = [];
      if (broj) labelParts.push(`Epizoda ${broj}`);
      else labelParts.push(`Epizoda #${idEp}`);

      const fmt = (d) => (d ? dayjs(d).format('DD.MM.YYYY') : '');
      const odStr = fmt(datumOd);
      const doStr = fmt(datumDo);

      let range = '';
      if (odStr && doStr) range = `${odStr} – ${doStr}`;
      else if (odStr) range = `od ${odStr}`;
      else if (doStr) range = `do ${doStr}`;

      map.set(idEp, {
        label: labelParts.join(' · '),
        range,
      });
    }
    return map;
  }, [episodesData]);

  // opcije za epizode (filter po epizodi)
  const episodeOptions = useMemo(() => {
    const opts = [];

    // iz mapa epizoda (iz posebnog query-ja)
    for (const [idEp, meta] of episodesMap.entries()) {
      opts.push({
        value: String(idEp),
        label: meta.label + (meta.range ? ` (${meta.range})` : ''),
      });
    }

    // fallback – ako nema epizoda u posebnom upitu, probaj iz dokumenata
    if (!opts.length && docs.length) {
      const temp = new Map();
      for (const d of docs) {
        const eid = d.id_epizode;
        if (!eid) continue;
        if (!temp.has(eid)) {
          const parts = [];
          if (d.broj_epizode) parts.push(`Epizoda ${d.broj_epizode}`);
          const fmt = (dt) => (dt ? dayjs(dt).format('DD.MM.YYYY') : '');
          const odStr = fmt(d.datum_od);
          const doStr = fmt(d.datum_do);
          if (odStr && doStr) parts.push(`${odStr} – ${doStr}`);
          else if (odStr) parts.push(`od ${odStr}`);
          else if (doStr) parts.push(`do ${doStr}`);
          temp.set(eid, parts.join(' · ') || `Epizoda #${eid}`);
        }
      }
      for (const [idEp, label] of temp.entries()) {
        opts.push({ value: String(idEp), label });
      }
    }

    return opts;
  }, [episodesMap, docs]);

  const episodeCounts = useMemo(() => {
    const m = new Map();
    for (const d of docs) {
      const key = d.id_epizode ? String(d.id_epizode) : 'NO_EPISODE';
      m.set(key, (m.get(key) || 0) + 1);
    }
    return m;
  }, [docs]);

  const episodesList = useMemo(() => {
    const list = episodeOptions.map((opt) => {
      const key = String(opt.value);
      const meta = episodesMap.get(Number(opt.value)) || episodesMap.get(opt.value);
      return {
        id: key,
        label: meta?.label || String(opt.label),
        range: meta?.range || '',
      };
    });
    const hasNoEpisode = docs.some((d) => !d.id_epizode);
    if (hasNoEpisode) {
      list.push({ id: 'NO_EPISODE', label: 'Bez epizode', range: '' });
    }
    return list;
  }, [episodeOptions, docs, episodesMap]);

  // filter dokumenata po epizodi
  const filteredDocs = useMemo(() => {
    if (!episodeFilter) return docs;
    if (episodeFilter === 'NO_EPISODE') {
      return docs.filter((d) => !d.id_epizode);
    }
    return docs.filter((d) => String(d.id_epizode || '') === String(episodeFilter));
  }, [docs, episodeFilter]);

  const formatDocDateTime = (dt) => {
    if (!dt) return '';
    return dayjs(dt).format('DD.MM.YYYY HH:mm');
  };

  const formatDate = (dt) => {
    if (!dt) return '';
    return dayjs(dt).format('DD.MM.YYYY');
  };

  // grupisanje dokumenata po epizodi, header: "Epizoda X" + datum od–do
  const groupedDocs = useMemo(() => {
    if (!filteredDocs.length) return [];

    const byEpisode = new Map();

    for (const d of filteredDocs) {
      const key = d.id_epizode || 'NO_EPISODE';
      if (!byEpisode.has(key)) byEpisode.set(key, []);
      byEpisode.get(key).push(d);
    }

    return Array.from(byEpisode.entries()).map(([episodeId, items]) => {
      let label = '';
      let range = '';

      if (episodeId === 'NO_EPISODE') {
        label = 'Bez epizode';
      } else {
        const meta = episodesMap.get(episodeId);
        if (meta) {
          label = meta.label;
          range = meta.range;
        } else {
          // fallback iz samih dokumenata
          const sample = items[0] || {};
          const broj = sample.broj_epizode;
          label = broj ? `Epizoda ${broj}` : `Epizoda #${episodeId}`;

          const odStr = formatDate(sample.datum_od);
          const doStr = formatDate(sample.datum_do);
          if (odStr && doStr) range = `${odStr} – ${doStr}`;
          else if (odStr) range = `od ${odStr}`;
          else if (doStr) range = `do ${doStr}`;
        }
      }

      return {
        episodeId,
        label,
        range,
        docs: items,
      };
    });
  }, [filteredDocs, episodesMap]);

  // === VIEWER logika ===

  const openDocViewer = (docsList, index) => {
    if (!docsList || !docsList.length) return;
    setViewerDocs(docsList);
    setViewerIndex(index);
    setViewerOpen(true);
  };

  const closeDocViewer = () => {
    setViewerOpen(false);
  };

  const showPrevDoc = () => {
    setViewerIndex((prev) => (prev > 0 ? prev - 1 : prev));
  };

  const showNextDoc = () => {
    setViewerIndex((prev) => (prev < viewerDocs.length - 1 ? prev + 1 : prev));
  };

  const handleTouchStart = (e) => {
    if (!viewerOpen) return;
    setTouchStartX(e.touches[0].clientX);
  };

  const handleTouchEnd = (e) => {
    if (!viewerOpen || touchStartX == null) return;
    const dx = e.changedTouches[0].clientX - touchStartX;
    const threshold = 50; // px
    if (dx > threshold) {
      // swipe right -> prethodni dokument
      showPrevDoc();
    } else if (dx < -threshold) {
      // swipe left -> sljedeći dokument
      showNextDoc();
    }
    setTouchStartX(null);
  };

  const updateFitScale = useCallback(() => {
    if (!viewerOpen) return;
    const bodyEl = docViewerBodyRef.current;
    if (!bodyEl) return;

    const rect = bodyEl.getBoundingClientRect();
    const baseWidth = docSize.width || DEFAULT_DOC_SIZE.width;
    const baseHeight = docSize.height || DEFAULT_DOC_SIZE.height;
    if (!rect.width || !rect.height || !baseWidth || !baseHeight) return;

    const nextFit = Math.min(rect.width / baseWidth, rect.height / baseHeight, 1);
    setDocScale(nextFit);
  }, [docSize.height, docSize.width, viewerOpen]);

  const handleIframeLoad = useCallback(() => {
    const iframe = docViewerIframeRef.current;
    if (!iframe) return;

    let next = DEFAULT_DOC_SIZE;
    try {
      const doc = iframe.contentDocument || iframe.contentWindow?.document;
      if (doc) {
        const docEl = doc.documentElement;
        const body = doc.body;
        const width = Math.max(
          docEl?.scrollWidth || 0,
          body?.scrollWidth || 0,
          docEl?.clientWidth || 0,
        );
        const height = Math.max(
          docEl?.scrollHeight || 0,
          body?.scrollHeight || 0,
          docEl?.clientHeight || 0,
        );
        if (width && height) {
          next = { width, height };
        }
      }
    } catch (err) {
      // Cross-origin or non-HTML content; keep default size.
    }
    setDocSize(next);
    setDocLoading(false);
  }, []);

  const currentDoc =
    viewerOpen && viewerDocs.length
      ? viewerDocs[Math.min(viewerIndex, viewerDocs.length - 1)]
      : null;

  useEffect(() => {
    if (!viewerOpen) return;
    setDocScale(1);
    setDocSize(DEFAULT_DOC_SIZE);
    setDocLoading(true);
  }, [viewerIndex, viewerOpen]);

  useEffect(() => {
    if (!viewerOpen) return;
    updateFitScale();
  }, [docSize, updateFitScale, viewerOpen]);

  useEffect(() => {
    if (!viewerOpen) return;
    const onResize = () => updateFitScale();
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, [updateFitScale, viewerOpen]);

  const buildDocUrl = (doc) => {
    if (!doc) return '';
    const docId = doc.id_dokumenta || doc.id;
    const epId = doc.id_epizode;
    const formId = doc.id_forme || doc.forma_id;
    if (!docId || !epId || !formId || !id) return '';

    const base = ENV.DOC_VIEWER_BASE_URL; // sada iz env-a

    const params = new URLSearchParams({
      id_pacijenta: String(id),
      id_epizode: String(epId),
      id_forme: String(formId),
      id_dokumenta: String(docId),
      tip_export: '1',
      noprint: '1',
    });

    return `${base}?${params.toString()}`;
  };

  const selectedEpisode = episodeFilter
    ? episodesList.find((ep) => String(ep.id) === String(episodeFilter))
    : null;
  const selectedEpisodeLabel = episodeFilter
    ? selectedEpisode?.label ||
      (episodeFilter === 'NO_EPISODE' ? 'Bez epizode' : `Epizoda #${episodeFilter}`)
    : '';
  const selectedEpisodeCount = episodeFilter
    ? episodeCounts.get(String(episodeFilter)) ?? 0
    : docs.length;

  const tabItems = [
    {
      key: 'tasks',
      label: 'Zadaci',
      children: (
        <div>
          {/* Header reda: "Zadaci" + datum u istom redu */}
          <div className={styles.tasksHeaderRow}>
            <div className={styles.tasksTitleRow}>
              <button
                type="button"
                className={styles.addBtn}
                onClick={() => setTaskModalOpen(true)}
              >
                Dodaj
              </button>
              <button
                type="button"
                className={styles.secondaryBtn}
                onClick={() => setImportModalOpen(true)}
              >
                Uvezi
              </button>
            </div>

            <div className={styles.dateRow}>
              <input
                id="visit-date"
                type="date"
                className={styles.date}
                value={date}
                onChange={onChangeDate}
                aria-label="Odaberite datum posjete"
              />
              {tasksFetching && !tasksLoading ? (
                <span className={styles.dim}>osvježavam…</span>
              ) : null}
            </div>
          </div>

          {tasksLoading ? (
            <div className={styles.skel}>Učitavam zadatke…</div>
          ) : tasksError ? (
            <div className={styles.err}>
              Greška pri učitavanju zadataka: {String(tasksErr?.message || '')}
            </div>
          ) : (
            <PatientTasks tasks={tasks} onSave={handleSaveTasks} />
          )}
        </div>
      ),
    },
    {
      key: 'docs',
      label: 'Dokumenti',
      children: (
        <div className={styles.docsSection}>
          <div className={styles.docsHeaderRow}>
            <Button
              className={styles.episodeSelectBtn}
              icon={episodesLoading ? <LoadingOutlined /> : null}
              onClick={() => setEpisodeModalOpen(true)}
            >
              <span className={styles.episodeSelectText}>
                {episodeFilter
                  ? `${selectedEpisodeLabel} (${selectedEpisodeCount})`
                  : 'Sve epizode'}
              </span>
            </Button>
          </div>

          {docsLoading ? (
            <div className={styles.skel}>Učitavam dokumente…</div>
          ) : docsError ? (
            <div className={styles.err}>
              Greška pri učitavanju dokumenata: {String(docsErr?.message || '')}
            </div>
          ) : groupedDocs.length === 0 ? (
            <div className={styles.skel}>Nema dokumenata za ovog pacijenta.</div>
          ) : (
            <div className={styles.docsList}>
              {groupedDocs.map((group) => (
                <div key={group.episodeId} className={styles.docsGroup}>
                  <div className={styles.docsGroupHeader}>
                    <span className={styles.docsGroupTitle}>{group.label}</span>
                    {group.range && <span className={styles.docsGroupRange}>{group.range}</span>}
                  </div>

                  {group.docs.map((d, idxInGroup) => {
                    const title = d.naslov || d.sazetak || `Dokument #${d.id}`;

                    const authorName =
                      d.korisnik_potpis || d.korisnik_ime_prezime || d.korisnik || '';
                    const authorTitle = d.korisnik_titula || d.korisnik_titula_puna || '';
                    const author =
                      authorTitle && authorName
                        ? `${authorTitle} ${authorName}`
                        : authorName || authorTitle || '';

                    const metaLine = `${formatDocDateTime(d.datum_kreiranja)} · ${
                      d.skladiste_grupa_naziv || 'Nepoznata organizaciona jedinica'
                    } (${d.skladiste_id || '–'})`;

                    return (
                      <article
                        key={d.id}
                        className={styles.docCard}
                        onClick={() => openDocViewer(group.docs, idxInGroup)}
                      >
                        <div className={styles.docMain}>
                          <div className={styles.docTitleRow}>
                            <div className={styles.docTitle}>{title}</div>
                            {author && <div className={styles.docAuthor}>{author}</div>}
                          </div>
                          <div className={styles.docMeta}>{metaLine}</div>
                        </div>
                      </article>
                    );
                  })}
                </div>
              ))}
            </div>
          )}
        </div>
      ),
    },
  ];

  return (
    <section className={styles.wrap}>
      {/* Header: samo PatientHeader bez dodatnog “oblaka” */}
      <div className={styles.header}>
        {patientLoading ? (
          <div className={styles.skel}>Učitavam pacijenta…</div>
        ) : patientError ? (
          <div className={styles.err}>
            Greška pri učitavanju pacijenta: {String(patientErr?.message || '')}
          </div>
        ) : (
          <PatientHeader patient={patient} visitDate={date} />
        )}
      </div>

      <Tabs
        className={styles.tabsRoot}
        defaultActiveKey="tasks"
        items={tabItems}
        destroyInactiveTabPane={false}
      />

      <TaskCreateModal
        open={taskModalOpen}
        onClose={() => setTaskModalOpen(false)}
        patientId={id}
        defaultDate={date}
      />
      <TaskImportModal
        open={importModalOpen}
        onClose={() => setImportModalOpen(false)}
        patientId={id}
        targetDate={date}
      />

      <EpisodeModal
        open={episodeModalOpen}
        loading={episodesLoading || docsLoading}
        episodes={episodesList}
        selectedId={episodeFilter}
        totalCount={docs.length}
        counts={episodeCounts}
        onSelect={(id) => {
          setEpisodeFilter(id || '');
          setEpisodeModalOpen(false);
        }}
        onClose={() => setEpisodeModalOpen(false)}
      />

      {/* === FULLSCREEN VIEWER ZA DOKUMENTE === */}
      {viewerOpen && currentDoc && (
        <div className={styles.docViewerOverlay}>
          <div className={styles.docViewerPanel}>
            <div
              className={styles.docViewerHeader}
              onTouchStart={handleTouchStart}
              onTouchEnd={handleTouchEnd}
            >
              <div className={styles.docViewerDate}>
                {formatDocDateTime(currentDoc.datum_kreiranja)}
              </div>

              <div className={styles.docViewerNav}>
                <button
                  type="button"
                  className={styles.docViewerNavBtn}
                  onClick={showPrevDoc}
                  disabled={viewerIndex === 0}
                >
                  ‹
                </button>
                <span className={styles.docViewerCounter}>
                  {viewerIndex + 1} / {viewerDocs.length}
                </span>
                <button
                  type="button"
                  className={styles.docViewerNavBtn}
                  onClick={showNextDoc}
                  disabled={viewerIndex >= viewerDocs.length - 1}
                >
                  ›
                </button>
                <button type="button" className={styles.docViewerCloseBtn} onClick={closeDocViewer}>
                  Zatvori
                </button>
              </div>
            </div>

            <div className={styles.docViewerBody}>
              <div className={styles.docViewerScroll} ref={docViewerBodyRef}>
                <div
                  className={styles.docViewerStage}
                  style={{
                    width: `${Math.max(1, docSize.width * docScale)}px`,
                    height: `${Math.max(1, docSize.height * docScale)}px`,
                  }}
                >
                  <div
                    className={styles.docViewerFrame}
                    style={{
                      width: `${Math.max(1, docSize.width)}px`,
                      height: `${Math.max(1, docSize.height)}px`,
                      transform: `scale(${docScale})`,
                    }}
                  >
                    <iframe
                      title="Dokument pacijenta"
                      className={styles.docViewerIframe}
                      src={buildDocUrl(currentDoc)}
                      ref={docViewerIframeRef}
                      onLoad={handleIframeLoad}
                      onError={() => setDocLoading(false)}
                    />
                  </div>
                </div>
              </div>
              {docLoading && (
                <div className={styles.docViewerLoading} aria-live="polite">
                  <div className={styles.docViewerSpinner} />
                  <span className={styles.docViewerLoadingText}>Ucitavam dokument...</span>
                </div>
              )}
              <div
                className={`${styles.docViewerSwipeZone} ${styles.docViewerSwipeZoneLeft}`}
                onTouchStart={handleTouchStart}
                onTouchEnd={handleTouchEnd}
                onClick={showPrevDoc}
              />
              <div
                className={`${styles.docViewerSwipeZone} ${styles.docViewerSwipeZoneRight}`}
                onTouchStart={handleTouchStart}
                onTouchEnd={handleTouchEnd}
                onClick={showNextDoc}
              />
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
