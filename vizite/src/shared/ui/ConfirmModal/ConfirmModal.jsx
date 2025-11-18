import React, { useEffect, useRef } from "react";
import { createPortal } from "react-dom";
import styles from "./ConfirmModal.module.css";

export default function ConfirmModal({
  open,
  title = "Potvrda",
  description = "",
  confirmText = "Potvrdi",
  cancelText = "Odustani",
  onConfirm,
  onCancel,
}) {
  const dialogRef = useRef(null);
  const firstBtnRef = useRef(null);

  useEffect(() => {
    if (!open) return;
    firstBtnRef.current?.focus();

    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    const onKey = (e) => {
      if (e.key === "Escape") onCancel?.();
      if (e.key === "Tab" && dialogRef.current) {
        const f = dialogRef.current.querySelectorAll(
          'button,[href],[tabindex]:not([tabindex="-1"])'
        );
        if (!f.length) return;
        const first = f[0],
          last = f[f.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };

    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [open, onCancel]);

  if (!open) return null;

  const onOverlayClick = (e) => {
    if (e.target === e.currentTarget) onCancel?.();
  };

  return createPortal(
    <div
      className={styles.overlay}
      role="dialog"
      aria-modal="true"
      aria-labelledby="cm-title"
      aria-describedby="cm-desc"
      onMouseDown={onOverlayClick}
    >
      <div className={styles.modal} ref={dialogRef}>
        <h3 id="cm-title" className={styles.title}>
          {title}
        </h3>
        {description ? (
          <p id="cm-desc" className={styles.text}>
            {description}
          </p>
        ) : null}
        <div className={styles.actions}>
          <button
            ref={firstBtnRef}
            type="button"
            className={`${styles.btn} ${styles.btnGhost}`}
            onClick={onCancel}
          >
            {cancelText}
          </button>
          <button
            type="button"
            className={`${styles.btn} ${styles.btnDanger}`}
            onClick={onConfirm}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
}
