import React from "react";
import { Link } from "react-router-dom";
import styles from "./NotFound.module.css";

export default function NotFound() {
  return (
    <section className={styles.wrap}>
      <h2 className={styles.h2}>404 – Stranica nije pronađena</h2>
      <p>Provjerite URL ili se vratite na početnu.</p>
      <div className={styles.actions}>
        <Link to="/">← Početna</Link>
      </div>
    </section>
  );
}
