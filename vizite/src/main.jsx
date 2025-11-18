import React from "react";
import ReactDOM from "react-dom/client";
import { Providers } from "./app/providers/Providers.jsx";
import AppRouter from "./app/providers/Router.jsx";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <Providers>
      <AppRouter />
    </Providers>
  </React.StrictMode>
);
