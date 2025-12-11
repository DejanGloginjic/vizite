import React, { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Select } from 'antd';
import styles from './ChooseClinicPage.module.css';
import { useUserStoragesQuery } from '../../entities/storage/queries';
import { useSetWorkingLocation } from '../../entities/storage/queries';
import Header from '../../shared/ui/Header/Header';

export default function ChooseClinicPage() {
  const navigate = useNavigate();

  const { data = [], isLoading, isError, error } = useUserStoragesQuery();
  const setWorkingLocationMutation = useSetWorkingLocation();

  const [selectedGroupId, setSelectedGroupId] = useState(null);
  const [selectedStorageId, setSelectedStorageId] = useState(null);
  const groups = useMemo(() => (Array.isArray(data) ? data : []), [data]);
  const groupsCount = groups.length;

  const currentGroup = useMemo(
    () => groups.find((g) => String(g.id) === String(selectedGroupId)) || null,
    [groups, selectedGroupId],
  );

  const storages = useMemo(() => currentGroup?.skladista ?? [], [currentGroup]);

  const handleSelectGroup = (value) => {
    setSelectedGroupId(value);
    setSelectedStorageId(null);
  };

  const handleConfirmSelection = (storageId) => {
    const sid = storageId ?? selectedStorageId;
    if (!selectedGroupId || !sid) return;

    const payload = {
      grupaId: Number(selectedGroupId),
      skladisteId: Number(sid),
    };

    try {
      localStorage.setItem('vizite.clinicSelection', JSON.stringify(payload));
    } catch (_) {}

    setWorkingLocationMutation.mutate(payload, {
      onSuccess: () => {
        navigate('/patients', { replace: true });
      },
      onError: () => {
        // fallback – ipak idi na /, sesija se možda nije promijenila
        navigate('/', { replace: true });
      },
    });
  };

  const handleSelectStorage = (id) => {
    setSelectedStorageId(id);
    handleConfirmSelection(id);
  };

  // auto odaberi jedinu grupu ako je samo jedna
  React.useEffect(() => {
    if (groupsCount === 1 && !selectedGroupId) {
      const only = groups[0];
      if (only?.id != null) setSelectedGroupId(only.id);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [groupsCount]);

  return (
    <div className={styles.shell}>
      {/* HEADER – isti layout kao globalni Header */}
      <Header />

      {/* GLAVNI DIO – responsive odabir grupe + skladišta */}
      <main className={styles.main}>
        <section className={styles.panel}>
          <h1 className={styles.title}>Odabir lokacije rada</h1>

          {isLoading && <div className={styles.skel}>Učitavam podatke…</div>}

          {isError && (
            <div className={styles.err}>Greška pri učitavanju: {String(error?.message || '')}</div>
          )}

          {!isLoading && !isError && groups.length === 0 && (
            <div className={styles.empty}>Nemate dodijeljene organizacione jedinice.</div>
          )}

          {!isLoading && !isError && groups.length > 0 && (
            <>
              {/* 1) Odabir grupe: lista (<=3) ili dropdown (>=4) */}
              <div className={styles.field}>
                <label className={styles.label} htmlFor="group-select">
                  Klinika / organizaciona jedinica
                </label>
                {groupsCount > 3 ? (
                  <Select
                    id="group-select"
                    showSearch
                    placeholder="Odaberite kliniku"
                    className={styles.select}
                    value={selectedGroupId ?? undefined}
                    onChange={handleSelectGroup}
                    filterOption={(input, option) =>
                      (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                    }
                    options={groups.map((g) => ({
                      value: g.id,
                      label: g.mjesto ? `${g.naziv} · ${g.mjesto}` : g.naziv,
                    }))}
                  />
                ) : (
                  <div className={styles.groupList}>
                    {groups.map((g) => {
                      const active = String(g.id) === String(selectedGroupId);
                      const cls = active ? styles.storageItemActive : styles.storageItem;
                      const meta = g.mjesto || g.opis || '';
                      return (
                        <button
                          key={g.id}
                          type="button"
                          className={`${cls} ${styles.groupItem}`}
                          onClick={() => handleSelectGroup(g.id)}
                        >
                          <div className={styles.storageName}>{g.naziv}</div>
                          {meta && <div className={styles.storageMeta}>{meta}</div>}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* 2) Lista skladišta ispod */}
              <div className={styles.field}>
                <label className={styles.label}>Skladište</label>

                {selectedGroupId && storages.length === 0 && (
                  <div className={styles.emptyInline}>
                    Ova organizaciona jedinica nema definisana skladišta.
                  </div>
                )}

                {!selectedGroupId && (
                  <div className={styles.emptyInline}>Prvo izaberite kliniku.</div>
                )}

                {selectedGroupId && storages.length > 0 && (
                  <div className={styles.storageList}>
                    {storages.map((s) => {
                      const active = String(s.id) === String(selectedStorageId);
                      const meta = [s.adresa, s.mjesto, s.napomena].filter(Boolean).join(' | ');
                      return (
                        <button
                          key={s.id}
                          type="button"
                          className={active ? styles.storageItemActive : styles.storageItem}
                          onClick={() => handleSelectStorage(s.id)}
                        >
                          <div className={styles.storageName}>{s.naziv}</div>
                          {meta && <div className={styles.storageMeta}>{meta}</div>}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            </>
          )}

        </section>
      </main>

    </div>
  );
}
