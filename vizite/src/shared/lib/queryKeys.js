// src/shared/lib/queryKeys.js
export const QK = {
  rooms: ['rooms'],
  patients: ({ roomId = '', date = '' } = {}) => ['patients', { roomId, date }],
  patient: (id) => ['patient', id],
  tasks: (id, date) => ['tasks', { id, date: date || 'today' }],
  session: ['session'],
  // 🔹 NOVO:
  patientDocuments: (id) => ['patientDocuments', id],
};
