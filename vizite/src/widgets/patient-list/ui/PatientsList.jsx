import React, { useRef } from "react";
import { useVirtualizer } from "@tanstack/react-virtual";
import PatientItem from "./PatientItem";
import styles from "./patients-list.module.css";

export default function PatientsList({
  patients = [],
  loading,
  onPrefetch,
  statusMap, // { [id]: 'open'|'done'|'none' } (opciono)
}) {
  const parentRef = useRef(null);
  const count = patients.length;

  const rowVirtualizer = useVirtualizer({
    count,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 60, // kompaktnije, ali dovoljno za avatar
    overscan: 8,
    measureElement: (el) => el.getBoundingClientRect().height,
  });

  const virtualItems = rowVirtualizer.getVirtualItems();

  if (loading) {
    return (
      <div className={styles.virtualScroll} ref={parentRef}>
        <div className={styles.skeleton}>
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className={styles.skelRow} />
          ))}
        </div>
      </div>
    );
  }

  if (!count) {
    return <div className={styles.empty}>Nema pacijenata za prikaz.</div>;
  }

  return (
    <div ref={parentRef} className={styles.virtualScroll}>
      <div
        style={{ height: rowVirtualizer.getTotalSize(), position: "relative" }}
      >
        {virtualItems.map((vRow) => {
          const p = patients[vRow.index];
          return (
            <div
              key={vRow.key}
              ref={rowVirtualizer.measureElement}
              className={styles.virtualRow}
              style={{
                transform: `translateY(${vRow.start}px)`,
                height: vRow.size,
              }}
            >
              <PatientItem
                patient={p}
                onPrefetch={onPrefetch}
                status={statusMap?.[p?.id]}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
