import React, { useState } from "react";
import { Link } from "react-router-dom";
import AuthService from "../../services/auth.service";

const Register = () => {
    const [username, setUsername] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [role, setRole] = useState(["user"]);
    const [successful, setSuccessful] = useState(false);
    const [message, setMessage] = useState("");

    const handleRegister = (e) => {
        e.preventDefault();
        setMessage("");
        setSuccessful(false);

        AuthService.register(username, email, password, role).then(
            (response) => {
                setMessage(response.data.message);
                setSuccessful(true);
            },
            (error) => {
                const resMessage =
                    (error.response &&
                        error.response.data &&
                        error.response.data.message) ||
                    error.message ||
                    error.toString();

                setMessage(resMessage);
                setSuccessful(false);
            }
        );
    };

    return (
        <div className="container min-vh-100 d-flex align-items-center justify-content-center animate-slide-up py-5">
            <div className="row w-100 justify-content-center">
                <div className="col-md-6 col-lg-5">
                    <div className="glass-card p-5">
                        <div className="text-center mb-5">
                            <h2 className="fw-bold font-premium">{successful ? "Success!" : "Identity Creation"}</h2>
                            <p className="text-muted small">Establish your presence in the workflow system</p>
                        </div>

                        <form onSubmit={handleRegister}>
                            {!successful && (
                                <div className="animate-slide-up">
                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Access ID (Username)</label>
                                        <input
                                            type="text"
                                            className="form-control form-control-premium text-white"
                                            value={username}
                                            onChange={(e) => setUsername(e.target.value)}
                                            minLength={3}
                                            placeholder="Example: JohnDoe"
                                            required
                                        />
                                    </div>

                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Email Address</label>
                                        <input
                                            type="email"
                                            className="form-control form-control-premium text-white"
                                            value={email}
                                            onChange={(e) => setEmail(e.target.value)}
                                            placeholder="john@example.com"
                                            required
                                        />
                                    </div>

                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Security Key (Password)</label>
                                        <input
                                            type="password"
                                            className="form-control form-control-premium text-white"
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            minLength={6}
                                            placeholder="••••••••"
                                            required
                                        />
                                    </div>

                                    <div className="mb-4">
                                        <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Selection Role</label>
                                        <select
                                            className="form-select form-control-premium text-white"
                                            onChange={(e) => setRole([e.target.value])}
                                            style={{ cursor: 'pointer' }}
                                        >
                                            <option value="user">Standard Agent</option>
                                            <option value="admin">System Architect (Admin)</option>
                                        </select>
                                    </div>

                                    <button className="btn-premium w-100 py-3 mb-4">Initialize Provisioning</button>
                                </div>
                            )}

                            {message && (
                                <div className={`alert ${successful ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border-0 rounded-3 text-center p-3 animate-slide-up`} role="alert">
                                    {message}
                                    {successful && (
                                        <div className="mt-3">
                                            <Link to="/login" className="btn-premium py-2 text-decoration-none">Proceed to Terminal</Link>
                                        </div>
                                    )}
                                </div>
                            )}

                            {!successful && (
                                <p className="text-center text-muted small mt-2">
                                    Already registered? <Link to="/login" className="text-white text-decoration-none fw-medium">Sign in here</Link>
                                </p>
                            )}
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Register;
