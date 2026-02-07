import React, { useState } from "react";
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
        <div className="container animate-fade-in py-5">
            <div className="row justify-content-center">
                <div className="col-md-6">
                    <div className="glass-card p-5">
                        <div className="text-center mb-5">
                            <h2 className="fw-bold">{successful ? "Success!" : "Join the Platform"}</h2>
                            <p className="text-muted">Create your account to start managing workflows</p>
                        </div>

                        <form onSubmit={handleRegister}>
                            {!successful && (
                                <div className="animate-fade-in">
                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-semibold">Username</label>
                                        <input
                                            type="text"
                                            className="form-control form-control-premium"
                                            value={username}
                                            onChange={(e) => setUsername(e.target.value)}
                                            minLength={3}
                                            placeholder="ExampleUser"
                                            required
                                        />
                                    </div>

                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-semibold">Email</label>
                                        <input
                                            type="email"
                                            className="form-control form-control-premium"
                                            value={email}
                                            onChange={(e) => setEmail(e.target.value)}
                                            placeholder="user@example.com"
                                            required
                                        />
                                    </div>

                                    <div className="mb-3">
                                        <label className="form-label small text-uppercase fw-semibold">Password</label>
                                        <input
                                            type="password"
                                            className="form-control form-control-premium"
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            minLength={6}
                                            placeholder="••••••••"
                                            required
                                        />
                                    </div>

                                    <div className="mb-4">
                                        <label className="form-label small text-uppercase fw-semibold">Role</label>
                                        <select
                                            className="form-select form-control-premium"
                                            onChange={(e) => setRole([e.target.value])}
                                        >
                                            <option value="user">Standard User</option>
                                            <option value="admin">System Admin</option>
                                        </select>
                                    </div>

                                    <button className="btn btn-premium w-100 py-3 mb-4">Create Account</button>
                                </div>
                            )}

                            {message && (
                                <div className={`alert ${successful ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'} border-0 rounded-3 text-center p-3 animate-fade-in`} role="alert">
                                    {message}
                                    {successful && <div className="mt-3"><Link to="/login" className="btn btn-success btn-sm">Proceed to Login</Link></div>}
                                </div>
                            )}
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Register;
