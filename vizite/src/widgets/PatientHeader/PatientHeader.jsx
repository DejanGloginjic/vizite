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

  const rhSign = (() => {
    if (p.rh_faktor === null || p.rh_faktor === undefined || p.rh_faktor === "") {
      return "";
    }
    const raw = String(p.rh_faktor);
    if (raw === "1") return "+";
    if (raw === "0") return "-";
    if (raw === "+" || raw === "-") return raw;
    return "";
  })();

  const krvLabel = p.krvna_grupa ? `${p.krvna_grupa}${rhSign}` : "";
  const dobValue = dobHuman
    ? `${dobHuman}${years !== null ? ` (${years} god)` : ""}`
    : "";

  const infoItems = [
    { label: "Datum rodjenja", value: dobValue, icon: "calendar" },
    { label: "JMBG", value: jmbg, mono: true, icon: "id" },
    { label: "Krvna grupa", value: krvLabel },
  ].filter((item) => item.value);

  return (
    <section className={styles.card}>
      <div className={styles.top}>
        <h2 className={styles.name} title={imePrezime}>
          {imePrezime}
        </h2>
      </div>

      {infoItems.length ? (
        <div className={styles.metaGrid}>
          {infoItems.map((item) => (
            <div
              key={item.label}
              className={styles.metaItem}
              title={`${item.label}: ${item.value}`}
            >
              {item.icon ? (
                <span
                  className={styles.metaCompact}
                  aria-label={`${item.label}: ${item.value}`}
                >
                  <span className={styles.metaIcon} aria-hidden="true">
                    {item.icon === "calendar" ? (
                      <svg viewBox="0 0 24 24" focusable="false" aria-hidden="true">
                        <path
                          d="M7 3v3M17 3v3M4 8h16M6 6h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2z"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="1.6"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    ) : (
                      <svg viewBox="0 0 24 24" focusable="false" aria-hidden="true">
                        <path
                          d="M4 6a2 2 0 0 1 2-2h9l5 5v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6z"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="1.6"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                        <path
                          d="M9 12h6M9 15h6M9 9h2"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="1.6"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    )}
                  </span>
                  <span className={item.mono ? styles.metaValueMono : styles.metaValue}>
                    {item.value}
                  </span>
                </span>
              ) : (
                <>
                  <span className={styles.metaLabel}>{item.label}</span>
                  <span
                    className={item.mono ? styles.metaValueMono : styles.metaValue}
                  >
                    {item.value}
                  </span>
                </>
              )}
            </div>
          ))}
        </div>
      ) : null}
    </section>
  );
}
