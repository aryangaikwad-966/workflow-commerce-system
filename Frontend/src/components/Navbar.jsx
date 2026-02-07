import React, { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import AuthService from "../services/auth.service";

const Navbar = () => {
    const [currentUser, setCurrentUser] = useState(undefined);
    const navigate = useNavigate();

    useEffect(() => {
        const user = AuthService.getCurrentUser();
        if (user) {
            setCurrentUser(user);
        }
    }, []);

    const logOut = () => {
        AuthService.logout();
        setCurrentUser(undefined);
        navigate("/login");
        window.location.reload();
    };

    return (
        <nav className="navbar navbar-expand-lg navbar-premium sticky-top">
            <div className="container-fluid">
                <Link to={"/"} className="navbar-brand fw-bold d-flex align-items-center">
                    <div className="bg-primary p-2 rounded-3 me-2" style={{ width: '35px', height: '35px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <span className="text-white">W</span>
                    </div>
                    <span className="bg-gradient-primary">Workflow</span>
                </Link>

                <button className="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span className="navbar-toggler-icon"></span>
                </button>

                <div className="collapse navbar-collapse" id="navbarNav">
                    <ul className="navbar-nav me-auto">
                        <li className="nav-item">
                            <Link to={"/home"} className="nav-link nav-link-premium">Home</Link>
                        </li>
                        {currentUser && currentUser.roles && currentUser.roles.includes("ROLE_ADMIN") && (
                            <li className="nav-item">
                                <Link to={"/admin/categories"} className="nav-link nav-link-premium text-warning">
                                    Management
                                </Link>
                            </li>
                        )}
                    </ul>

                    {currentUser ? (
                        <div className="navbar-nav align-items-center">
                            <li className="nav-item">
                                <div className="d-flex align-items-center bg-dark-subtle px-3 py-1 rounded-pill border border-secondary">
                                    <div className="bg-primary rounded-circle me-2" style={{ width: '8px', height: '8px' }}></div>
                                    <span className="text-light small">{currentUser.username}</span>
                                </div>
                            </li>
                            <li className="nav-item ms-lg-3">
                                <button className="btn btn-link nav-link nav-link-premium text-danger border-0 p-0" onClick={logOut}>
                                    Logout
                                </button>
                            </li>
                        </div>
                    ) : (
                        <div className="navbar-nav">
                            <li className="nav-item">
                                <Link to={"/login"} className="nav-link nav-link-premium">Login</Link>
                            </li>
                            <li className="nav-item ms-lg-2">
                                <Link to={"/register"} className="btn btn-premium">Get Started</Link>
                            </li>
                        </div>
                    )}
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
