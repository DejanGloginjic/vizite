import React from "react";
import styles from "./PatientHeader.module.css";
import { calcAge, formatDateHuman } from "../../shared/lib/date";

export default function PatientHeader({ patient, visitDate }) {
  const p = patient || {};

  const imePrezime =
    [p.prezime, p.ime].filter(Boolean).join(" ") || "Nepoznato ime";

  const dobHuman = p.datum_rodjenja ? formatDateHuman(p.datum_rodjenja) : "";
  const years =
    p.datum_rodjenja != null
      ? calcAge(p.datum_rodjenja, visitDate || new Date())
      : null;

  const jmbg = p.jmbg || "";
  const upozorenje = p.upozorenje || "";

  // akcent na lijevoj ivici samo ako postoji upozorenje
  const accent = upozorenje ? "#ef4444" : "transparent";

  return (
    <section className={styles.card} style={{ ["--accent"]: accent }}>
      <div className={styles.top}>
        {/* Ime + (datum rođenja i godine) u istom redu */}
        <div className={styles.nameLine} title={imePrezime}>
          <h2 className={styles.name}>{imePrezime}</h2>
          {dobHuman ? (
            <span className={styles.inlineDob}>
              {dobHuman}
              {years !== null ? (
                <span className={styles.age}> ({years} god)</span>
              ) : null}
            </span>
          ) : null}
        </div>

        {upozorenje ? (
          <span className={styles.warnTag} title={upozorenje}>
            {upozorenje}
          </span>
        ) : null}
      </div>

      {/* JMBG ispod, diskretno */}
      {jmbg ? <div className={styles.jmbgLine}>{jmbg}</div> : null}
    </section>
  );
}
