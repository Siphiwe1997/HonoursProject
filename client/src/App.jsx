import React from "react";

import { Navbar, Welcome, Footer} from "./components";

const App = () => (
  <div className="min-h-screen">
    <div className="gradient-bg-welcome">
      <Navbar />
      <Welcome />
      <Footer />
    </div>
  </div>
);

export default App;
