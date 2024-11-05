import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter as Router } from 'react-router-dom';
import { ThirdwebProvider } from "thirdweb/react";

import App from "./App";
import { TransactionProvider } from "./context/TransactionContext";

import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
    <ThirdwebProvider>
      <Router>
        <TransactionProvider>
          <App />
        </TransactionProvider>
      </Router>
    </ThirdwebProvider>
);
