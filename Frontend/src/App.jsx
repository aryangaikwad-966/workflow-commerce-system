import React from "react";
import { Routes, Route, Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

import Navbar from "./components/Navbar";
import Login from "./pages/Login/Login";
import Register from "./pages/Register/Register";
import CategoryDashboard from "./pages/Admin/CategoryDashboard";

const Home = () => (
  <div className="container min-vh-100 d-flex flex-column justify-content-center align-items-center text-center animate-slide-up">
    <div className="badge border border-primary text-primary px-3 py-2 rounded-pill mb-4 small fw-bold">
      AVAILABLE NOW: TASK 1 MODULE COMPLETE
    </div>
    <h1 className="display-2 fw-bold mb-4 font-premium" style={{ letterSpacing: '-0.02em', background: 'linear-gradient(to bottom, #fff 40%, #94a3b8 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
      Workflow-Driven<br />Commerce Infrastructure.
    </h1>
    <p className="lead text-muted mb-5 max-w-2xl mx-auto fs-5" style={{ maxWidth: '600px' }}>
      A state-of-the-art platform for managing complex ecommerce workflows
      with institutional-grade precision and real-time state tracking.
    </p>
    <div className="d-flex gap-3">
      <Link to="/register" className="btn-premium px-5 py-3 shadow-lg">Get Started</Link>
      <Link to="/login" className="btn-secondary-premium px-5 py-3">Sign In</Link>
    </div>
  </div>
);

const Footer = () => (
  <footer className="container py-5 mt-5 border-top border-secondary border-opacity-10 text-center">
    <p className="text-muted small mb-0">© 2026 Workflow Commerce. Engineered for high-performance commerce.</p>
  </footer>
);

function App() {
  return (
    <div>
      <div className="bg-mesh"></div>
      <Navbar />

      <div className="container">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/home" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/admin/categories" element={<CategoryDashboard />} />
        </Routes>
      </div>
      <Footer />
    </div>
  );
}

export default App;
