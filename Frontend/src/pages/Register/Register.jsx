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
        <div className="col-md-12">
            <div className="card card-container p-4 mx-auto mt-5" style={{ maxWidth: "400px" }}>
                <h3 className="text-center mb-4">Register</h3>
                <form onSubmit={handleRegister}>
                    {!successful && (
                        <div>
                            <div className="form-group mb-3">
                                <label htmlFor="username">Username</label>
                                <input
                                    type="text"
                                    className="form-control"
                                    name="username"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    minLength={3}
                                    maxLength={20}
                                    required
                                />
                            </div>

                            <div className="form-group mb-3">
                                <label htmlFor="email">Email</label>
                                <input
                                    type="email"
                                    className="form-control"
                                    name="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                />
                            </div>

                            <div className="form-group mb-3">
                                <label htmlFor="password">Password</label>
                                <input
                                    type="password"
                                    className="form-control"
                                    name="password"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    minLength={6}
                                    maxLength={40}
                                    required
                                />
                            </div>

                            <div className="form-group mb-3">
                                <label htmlFor="role">Role</label>
                                <select
                                    className="form-control"
                                    onChange={(e) => setRole([e.target.value])}
                                >
                                    <option value="user">User</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>

                            <div className="form-group d-grid mb-3">
                                <button className="btn btn-success btn-block">Sign Up</button>
                            </div>
                        </div>
                    )}

                    {message && (
                        <div className="form-group">
                            <div
                                className={
                                    successful ? "alert alert-success" : "alert alert-danger"
                                }
                                role="alert"
              ) >
                            {message}
                        </div>
            </div>
          )}
        </form>
      </div >
    </div >
  );
};

export default Register;
