import React, { createContext, useContext, useEffect } from 'react';
import { useSessionQuery } from '../../entities/session/queries';
import { ENV } from '../../shared/config/env';

const SessionCtx = createContext({ session: null, isMock: false });

const isSessionAuthenticated = (session) => {
  if (!session) return false;

  const loggedFlag = session.loggedin;
  const isLogged =
    typeof loggedFlag === 'string'
      ? loggedFlag.trim().toLowerCase() === 'true'
      : Boolean(loggedFlag);

  const hasUserId = session.id_korisnika !== undefined && session.id_korisnika !== null;

  return isLogged && hasUserId;
};

export function useSession() {
  return useContext(SessionCtx);
}

export function SessionProvider({ children }) {
  const { data, isLoading, isError, error } = useSessionQuery();
  const isAuthenticated = isSessionAuthenticated(data);
  const logoutUrl = ENV.LOGOUT_URL;

  useEffect(() => {
    if (!isError || !logoutUrl) return;
    window.location.replace(logoutUrl);
  }, [isError, logoutUrl]);

  useEffect(() => {
    if (isLoading || !logoutUrl) return;
    if (!isAuthenticated) {
      window.location.replace(logoutUrl);
    }
  }, [isLoading, isAuthenticated, logoutUrl]);

  if (isLoading) {
    return (
      <div
        style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: 18,
        }}
      >
        Učitavam sesiju…
      </div>
    );
  }
  if (isError) {
    if (logoutUrl) {
      return (
        <div
          style={{
            minHeight: '100vh',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 16,
            textAlign: 'center',
          }}
        >
          Preusmjeravam na logout...
        </div>
      );
    }

    return (
      <div
        style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#b00020',
          padding: 16,
          textAlign: 'center',
        }}
      >
        Greška pri učitavanju sesije: {String(error?.message || 'Nepoznata greška')}
      </div>
    );
  }

  if (!isAuthenticated) {
    if (logoutUrl) {
      return (
        <div
          style={{
            minHeight: '100vh',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 16,
            textAlign: 'center',
          }}
        >
          Preusmjeravam na login...
        </div>
      );
    }

    return null;
  }

  return (
    <SessionCtx.Provider value={{ session: data, isMock: ENV.USE_MOCK_SESSION }}>
      {ENV.USE_MOCK_SESSION ? (
        <div
          style={{
            position: 'fixed',
            bottom: 12,
            right: 12,
            background: 'rgba(58,160,255,.12)',
            border: '1px solid rgba(58,160,255,.4)',
            color: '#9ad0ff',
            padding: '6px 10px',
            borderRadius: 8,
            fontSize: 12,
          }}
        >
          MOCK session
        </div>
      ) : null}
      {children}
    </SessionCtx.Provider>
  );
}
