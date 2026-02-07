import React from "react";
import { Routes, Route, Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

import Navbar from "./components/Navbar";
import Login from "./pages/Login/Login";
import Register from "./pages/Register/Register";
import CategoryDashboard from "./pages/Admin/CategoryDashboard";

const Home = () => (
  <div className="container mt-5 py-5 animate-fade-in text-center">
    <div className="row justify-content-center">
      <div className="col-lg-8">
        <h1 className="display-3 fw-bold mb-4" style={{ background: 'linear-gradient(135deg, #fff 0%, #94a3b8 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
          Next-Gen Workflow Commerce
        </h1>
        <p className="lead text-muted mb-5 fs-4">
          The only state-machine driven platform designed for precision,
          scalability, and institutional-grade commerce operations.
        </p>
        <div className="d-flex justify-content-center gap-3">
          <Link to="/register" className="btn btn-premium px-5 py-3">Explore Now</Link>
          <Link to="/login" className="btn btn-outline-light px-5 py-3 rounded-3">Sign In</Link>
        </div>
      </div>
    </div>
  </div>
);

function App() {
  return (
    <div>
      <Navbar />

      <div className="container mt-3">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/home" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/admin/categories" element={<CategoryDashboard />} />
        </Routes>
      </div>
    </div>
  );
}

export default App;
