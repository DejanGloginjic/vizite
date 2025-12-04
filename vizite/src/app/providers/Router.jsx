// src/app/router/AppRouter.jsx
import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from '../layouts/AppLayout/AppLayout';
import PatientsPage from '../../pages/PatientsPage/PatientsPage';
import PatientVisitPage from '../../pages/PatientVisitPage/PatientVisitPage';
import NotFound from '../../pages/NotFound/NotFound';
import ChooseClinicPage from '../../pages/ChooseClinicPage/ChooseClinicPage';

export default function AppRouter() {
  return (
    <HashRouter>
      <Routes>
        {/* FULLSCREEN stranica BEZ AppLayout-a */}
        <Route index element={<ChooseClinicPage />} />

        {/* Sve ostale stranice unutar AppLayout-a (sa headerom) */}
        <Route element={<AppLayout />}>
          <Route path="patients" element={<PatientsPage />} />
          <Route path="patient/:id" element={<PatientVisitPage />} />
          <Route path="404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
        </Route>
      </Routes>
    </HashRouter>
  );
}
