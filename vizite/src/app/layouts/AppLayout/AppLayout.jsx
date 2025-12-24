import React, { useEffect, useMemo, useState } from "react";
import { Outlet, useNavigate, useLocation } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import Header from "../../../shared/ui/Header/Header";
import styles from "./AppLayout.module.css";
import { useUserStoragesQuery, useSetWorkingLocation } from "../../../entities/storage/queries";
import LocationModal from "../../../shared/ui/LocationModal/LocationModal";
import { ENV } from "../../../shared/config/env";
import { useSession } from "../../providers/SessionContext";

/**
 * Opšti layout: sticky header + centriran sadržaj.
 * Sve stranice idu kao children.
 */
export default function AppLayout({ children }) {
  const navigate = useNavigate();
  const loc = useLocation();
  const qc = useQueryClient();
  const { session } = useSession() || { session: null };
  const { data: groupsData = [], isLoading, isError } = useUserStoragesQuery();
  const setWorkingLocationMutation = useSetWorkingLocation();

  const hasValidSelection = (sel) =>
    sel &&
    Number(sel.grupaId) > 0 &&
    Number(sel.skladisteId) > 0 &&
    !Number.isNaN(Number(sel.grupaId)) &&
    !Number.isNaN(Number(sel.skladisteId));

  const sessionSelection = useMemo(() => {
    const gid = session?.izabrana_grupa_skladista;
    const sid = session?.izabrano_skladiste;
    const candidate = { grupaId: gid, skladisteId: sid };
    return hasValidSelection(candidate) ? { grupaId: Number(gid), skladisteId: Number(sid) } : null;
  }, [session?.izabrana_grupa_skladista, session?.izabrano_skladiste]);

  const [selection, setSelection] = useState(() => {
    try {
      const stored = JSON.parse(localStorage.getItem("vizite.clinicSelection"));
      if (hasValidSelection(stored)) return stored;
    } catch {
      /* ignore */
    }
    return null;
  });

  const [modalOpen, setModalOpen] = useState(() => {
    if (hasValidSelection(selection)) return false;
    if (sessionSelection) return false;
    return true;
  });
  const [activeGroupId, setActiveGroupId] = useState(
    () => selection?.grupaId || sessionSelection?.grupaId || null
  );

  const groups = useMemo(() => (Array.isArray(groupsData) ? groupsData : []), [groupsData]);
  const storages = useMemo(() => {
    const g = groups.find((x) => String(x.id) === String(activeGroupId));
    return g?.skladista || [];
  }, [groups, activeGroupId]);

  const handleSelect = (grupaId, skladisteId) => {
    if (!grupaId || !skladisteId) return;
    const payload = { grupaId: Number(grupaId), skladisteId: Number(skladisteId) };
    setSelection(payload);
    localStorage.setItem("vizite.clinicSelection", JSON.stringify(payload));
    window.dispatchEvent(new Event("vizite-selection-changed"));

    setWorkingLocationMutation.mutate(payload, {
      onSettled: () => {
        qc.invalidateQueries({ queryKey: ["patients"] });
        qc.invalidateQueries({ queryKey: ["rooms"] });
        setModalOpen(false);
        if (loc.pathname !== "/patients") {
          navigate("/patients", { replace: true });
        } else {
          qc.invalidateQueries({ queryKey: ["patients"] });
        }
      },
    });
  };

  // ako postoji izbor u sesiji, primijeni ga i ne otvaraj modal
  useEffect(() => {
    if (!selection && sessionSelection) {
      setSelection(sessionSelection);
      localStorage.setItem("vizite.clinicSelection", JSON.stringify(sessionSelection));
      window.dispatchEvent(new Event("vizite-selection-changed"));
      setActiveGroupId(sessionSelection.grupaId);
      setModalOpen(false);
    }
  }, [selection, sessionSelection]);

  // ako sesija nema validne vrijednosti (0/prazno), primoraj izbor
  useEffect(() => {
    const sessionInvalid =
      session &&
      (!session?.izabrana_grupa_skladista ||
        !session?.izabrano_skladiste ||
        Number(session?.izabrana_grupa_skladista) === 0 ||
        Number(session?.izabrano_skladiste) === 0);
    if (sessionInvalid) {
      setSelection(null);
      setActiveGroupId(null);
      setModalOpen(true);
    }
  }, [session?.izabrana_grupa_skladista, session?.izabrano_skladiste, session]);

  return (
    <div className={styles.shell}>
      <Header onOpenLocation={() => setModalOpen(true)} />
      <main className={styles.main}>
        <div className={styles.container}>
          <Outlet />
        </div>
      </main>

      <LocationModal
        open={modalOpen}
        loading={isLoading}
        error={isError}
        groups={groups}
        activeGroupId={activeGroupId}
        onSelectGroup={(id) => setActiveGroupId(id)}
        onSelectStorage={(sid) => handleSelect(activeGroupId || groups[0]?.id, sid)}
        onClose={() => setModalOpen(false)}
        logoutUrl={
          (typeof window !== "undefined" && window.__LOGOUT_URL__) || ENV.LOGOUT_URL || "../../pocetna.cfm"
        }
      />
    </div>
  );
}
