// src/pages/PatientsPage/PatientsPage.jsx
import React, { useMemo, useState, useEffect, useRef } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { Button, Input, Select, message } from 'antd';
import { SearchOutlined } from '@ant-design/icons';

import styles from './PatientsPage.module.css';

import { useRoomsQuery } from '../../entities/room/queries';
import { usePatientsQuery } from '../../entities/patient/queries';
import { getPatientById, getPatientByWirstband } from '../../entities/patient/api';
import { usePrefetchPatient } from '../../features/patient-prefetch/usePrefetchPatient';
import { PatientsList } from '../../widgets/patient-list';
import { toISODate } from '../../shared/lib/date';

// helper za mapiranje pacijenta na sobu (bivši RoomFilter)
function extractRoomId(p, roomsByName, roomsById) {
  let raw = p?.soba_id ?? p?.sobaId ?? p?.room_id ?? p?.roomId ?? p?.soba ?? null;

  if (typeof raw === 'number') return String(raw);
  if (typeof raw === 'string') {
    const s = raw.trim();
    if (/^\d+$/.test(s)) return s;
    const m = s.match(/(\d{1,6})$/);
    if (m && roomsById.has(m[1])) return m[1];
    const byName = roomsByName.get(s.toLowerCase());
    if (byName) return byName;
  }

  const name = p?.soba_naziv ?? p?.sobaNaziv ?? null;
  if (name) {
    const byName = roomsByName.get(String(name).toLowerCase());
    if (byName) return byName;
  }
  return null;
}

export default function PatientsPage() {
  const [params, setParams] = useSearchParams();
  const navigate = useNavigate();

  const selectedRoom = params.get('room') || '';
  const today = toISODate();

  const [searchId, setSearchId] = useState('');
  const [searchLoading, setSearchLoading] = useState(false);
  const inputRef = useRef(null);

  // ============== SIGURNI NIZOVI (sprječava crash app) ==============

  const roomsResp = useRoomsQuery();
  const rooms = Array.isArray(roomsResp.data) ? roomsResp.data : [];
  const roomsLoading = roomsResp.isLoading;

  const patientsResp = usePatientsQuery(selectedRoom || undefined, today);
  const patients = Array.isArray(patientsResp.data) ? patientsResp.data : [];
  const patientsLoading = patientsResp.isLoading;
  const isFetching = patientsResp.isFetching;
  const isError = patientsResp.isError;
  const error = patientsResp.error;

  const allPatientsResp = usePatientsQuery(undefined, today);
  const allPatients = Array.isArray(allPatientsResp.data) ? allPatientsResp.data : [];

  // --------------------------------------------------------

  const onChangeRoom = (value) => {
    if (value) setParams({ room: value });
    else setParams({});
  };

  const prefetch = usePrefetchPatient();
  const onPrefetch = (id) => id && prefetch(id);

  const items = useMemo(() => patients, [patients]);

  // ---------------- MAPE SOBA ----------------
  const roomsByName = useMemo(() => {
    const m = new Map();
    for (const r of rooms) {
      const label = (r.naziv ?? `Soba ${r.id}`).toString().toLowerCase();
      m.set(label, String(r.id));
    }
    return m;
  }, [rooms]);

  const roomsById = useMemo(() => {
    const m = new Map();
    for (const r of rooms) m.set(String(r.id), r);
    return m;
  }, [rooms]);

  // ---------------- BROJ PACIJENATA PO SOBAMA ----------------
  const counts = useMemo(() => {
    const m = new Map();
    for (const p of allPatients) {
      const id = extractRoomId(p, roomsByName, roomsById);
      if (!id) continue;
      m.set(id, (m.get(id) || 0) + 1);
    }
    return m;
  }, [allPatients, roomsByName, roomsById]);

  const totalPatients = allPatients.length;

  // ---------------- FOKUS NA SEARCH ----------------
  useEffect(() => {
    if (inputRef.current && typeof inputRef.current.focus === 'function') {
      inputRef.current.focus();
    }
  }, []);

  // ---------------- PRETRAGA PACIJENTA ----------------
  const handleSearchPatient = async (value) => {
    const raw = (value ?? searchId).trim();
    if (!raw) {
      message.warning('Unesi ID pacijenta za pretragu.');
      return;
    }

    if (!/^\d+$/.test(raw)) {
      message.warning('ID pacijenta mora biti broj.');
      return;
    }

    setSearchLoading(true);
    try {
      const data = await getPatientByWirstband(raw);

      if (data && data.id) {
        navigate(`/patient/${data.id}`);
      } else {
        message.warning('Pacijent sa zadatim ID-om nije pronađen.');
      }
    } catch (err) {
      console.error(err);
      message.error('Došlo je do greške pri pretrazi pacijenta.');
    } finally {
      setSearchLoading(false);
    }
  };

  // auto-trigger kada dužina >= 14
  const handleSearchChange = (e) => {
    const next = e.target.value;
    const nextTrimmed = next.trim();

    setSearchId(next);

    if (!searchLoading && nextTrimmed.length >= 14 && searchId.trim().length < 14) {
      handleSearchPatient(nextTrimmed);
    }
  };

  return (
    <section className={styles.wrap}>
      <div className={styles.topbar}>
        <h2 className={styles.h2}>Pacijenti</h2>

        <div className={styles.filters}>
          {/* pretraga pacijenta po ID-u */}
          <Input.Search
            ref={inputRef}
            className={styles.patientSearch}
            placeholder="ID pacijenta"
            allowClear
            enterButton={<Button type="primary" icon={<SearchOutlined />} />}
            value={searchId}
            onChange={handleSearchChange}
            onSearch={handleSearchPatient}
            loading={searchLoading}
          />

          {/* filter soba */}
          <Select
            className={styles.roomSelect}
            placeholder="Sve sobe"
            allowClear
            disabled={roomsLoading}
            loading={roomsLoading}
            value={selectedRoom || undefined}
            onChange={(value) => onChangeRoom(value || '')}
            optionFilterProp="label"
            optionLabelProp="label"
            showSearch
          >
            {rooms.map((r) => {
              const id = String(r.id);
              const label = r.naziv ?? `Soba ${id}`;
              const count = counts.get(id) ?? 0;
              return (
                <Select.Option key={id} value={id} label={label}>
                  {`${label} (${count})`}
                </Select.Option>
              );
            })}
          </Select>
        </div>
      </div>

      {isError ? (
        <div className={styles.error}>Greška: {String(error?.message || 'Nepoznata greška')}</div>
      ) : (
        <PatientsList
          patients={items}
          loading={patientsLoading || isFetching}
          onPrefetch={onPrefetch}
        />
      )}
    </section>
  );
}
