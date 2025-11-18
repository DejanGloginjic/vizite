// src/pages/PatientVisitPage/PatientVisitPage.jsx
import React from 'react';
import { useParams, useSearchParams } from 'react-router-dom';
import styles from './PatientVisitPage.module.css';
import { usePatientQuery } from '../../entities/patient/queries';
import { usePatientTasksQuery } from '../../entities/task/queries';
import { toISODate } from '../../shared/lib/date';
import PatientHeader from '../../widgets/PatientHeader/PatientHeader';
import PatientTasks from '../../widgets/PatientTasks/PatientTasks';

export default function PatientVisitPage() {
  const { id } = useParams();
  const [sp, setSp] = useSearchParams();
  const today = toISODate();
  const date = sp.get('date') || today;

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

  const onChangeDate = (e) => {
    const v = e.target.value;
    setSp(v && v !== today ? { date: v } : {}); // danas bez query parametra
  };

  return (
    <section className={styles.wrap}>
      {/* JEDAN okvir: pacijent lijevo, datum desno */}
      <div className={styles.headerCard}>
        <div className={styles.patientCol}>
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

        <div className={styles.dateCol}>
          <label className={styles.dateLabel} htmlFor="visit-date">
            Datum posjete
          </label>
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
      </div>

      <h3 className={styles.h3}>Zadaci za dan</h3>

      {tasksLoading ? (
        <div className={styles.skel}>Učitavam zadatke…</div>
      ) : tasksError ? (
        <div className={styles.err}>
          Greška pri učitavanju zadataka: {String(tasksErr?.message || '')}
        </div>
      ) : (
        <PatientTasks tasks={tasks} />
      )}
    </section>
  );
}
