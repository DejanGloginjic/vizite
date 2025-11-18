import React from "react";
import Header from "../../../shared/ui/Header/Header";
import styles from "./AppLayout.module.css";
import { Outlet } from "react-router-dom";

/**
 * Opšti layout: sticky header + centriran sadržaj.
 * Sve stranice idu kao children.
 */
export default function AppLayout({ children }) {
  return (
    <div className={styles.shell}>
      <Header />
      <main className={styles.main}>
        <div className={styles.container}>
          <Outlet />
        </div>
      </main>
    </div>
  );
}
