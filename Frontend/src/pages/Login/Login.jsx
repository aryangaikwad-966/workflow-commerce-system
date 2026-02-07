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
        <div className="container animate-fade-in py-5">
            <div className="row justify-content-center">
                <div className="col-md-5">
                    <div className="glass-card p-5">
                        <div className="text-center mb-5">
                            <h2 className="fw-bold">Welcome Back</h2>
                            <p className="text-muted">Sign in to your account to continue</p>
                        </div>
                        <form onSubmit={handleLogin}>
                            <div className="mb-3">
                                <label className="form-label small text-uppercase fw-semibold">Username</label>
                                <input
                                    type="text"
                                    className="form-control form-control-premium"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    placeholder="Enter your username"
                                    required
                                />
                            </div>

                            <div className="mb-4">
                                <label className="form-label small text-uppercase fw-semibold">Password</label>
                                <input
                                    type="password"
                                    className="form-control form-control-premium"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="••••••••"
                                    required
                                />
                            </div>

                            <button className="btn btn-premium w-100 py-3 mb-3" disabled={loading}>
                                {loading ? (
                                    <span className="spinner-border spinner-border-sm"></span>
                                ) : "Sign In"}
                            </button>

                            {message && (
                                <div className="alert bg-danger-subtle text-danger border-0 rounded-3 small text-center" role="alert">
                                    {message}
                                </div>
                            )}
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Login;
