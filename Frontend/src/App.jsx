import React from "react";
import { Routes, Route, Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

import Navbar from "./components/Navbar";
import Login from "./pages/Login/Login";
import Register from "./pages/Register/Register";

const Home = () => (
  <div className="container mt-5">
    <header className="jumbotron text-center">
      <h3>Welcome to Workflow Commerce System</h3>
      <p>Please login or register to manage your orders.</p>
    </header>
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
        </Routes>
      </div>
    </div>
  );
}

export default App;
