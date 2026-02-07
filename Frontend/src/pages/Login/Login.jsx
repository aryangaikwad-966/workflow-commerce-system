import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import AuthService from "../../services/auth.service";

const Login = () => {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");

    const navigate = useNavigate();

    const handleLogin = (e) => {
        e.preventDefault();
        setMessage("");
        setLoading(true);

        AuthService.login(username, password).then(
            () => {
                navigate("/home");
                window.location.reload();
            },
            (error) => {
                const resMessage =
                    (error.response &&
                        error.response.data &&
                        error.response.data.message) ||
                    error.message ||
                    error.toString();

                setLoading(false);
                setMessage(resMessage);
            }
        );
    };

    return (
        <div className="container min-vh-100 d-flex align-items-center justify-content-center animate-slide-up">
            <div className="row w-100 justify-content-center">
                <div className="col-md-5 col-lg-4">
                    <div className="glass-card p-5">
                        <div className="text-center mb-5">
                            <h2 className="fw-bold font-premium">Sign In</h2>
                            <p className="text-muted small">Access the Workflow Console</p>
                        </div>
                        <form onSubmit={handleLogin}>
                            <div className="mb-3">
                                <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Username</label>
                                <input
                                    type="text"
                                    className="form-control form-control-premium text-white"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    placeholder="Enter username"
                                    required
                                />
                            </div>

                            <div className="mb-4">
                                <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Password</label>
                                <input
                                    type="password"
                                    className="form-control form-control-premium text-white"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="••••••••"
                                    required
                                />
                            </div>

                            <button className="btn-premium w-100 py-3 mb-4" disabled={loading}>
                                {loading ? (
                                    <span className="spinner-border spinner-border-sm"></span>
                                ) : "Authenticate"}
                            </button>

                            {message && (
                                <div className="alert bg-danger bg-opacity-10 text-danger border-0 rounded-3 small text-center py-2" role="alert">
                                    {message}
                                </div>
                            )}

                            <p className="text-center text-muted small mt-2">
                                New here? <Link to="/register" className="text-white text-decoration-none fw-medium">Create account</Link>
                            </p>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Login;
