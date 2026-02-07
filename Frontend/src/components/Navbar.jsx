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
        <nav className="navbar navbar-expand-lg navbar-floating sticky-top">
            <div className="container-fluid px-0">
                <Link to={"/"} className="navbar-brand fw-bold d-flex align-items-center font-premium">
                    <div className="bg-white text-dark rounded-pill me-2 d-flex align-items-center justify-content-center" style={{ width: '32px', height: '32px', fontSize: '18px' }}>
                        W
                    </div>
                    <span className="text-white fs-5">Workflow</span>
                </Link>

                <button className="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <i className="bi bi-list"></i>
                </button>

                <div className="collapse navbar-collapse" id="navbarNav">
                    <ul className="navbar-nav ms-4 me-auto">
                        <li className="nav-item">
                            <Link to={"/home"} className="nav-link nav-link-premium">Platform</Link>
                        </li>
                        {currentUser && currentUser.roles && currentUser.roles.includes("ROLE_ADMIN") && (
                            <li className="nav-item">
                                <Link to={"/admin/categories"} className="nav-link nav-link-premium text-primary fw-semibold">
                                    Console
                                </Link>
                            </li>
                        )}
                    </ul>

                    <div className="navbar-nav align-items-center gap-3">
                        {currentUser ? (
                            <>
                                <li className="nav-item d-none d-lg-block">
                                    <span className="text-muted small">Signed in as <span className="text-white fw-medium">{currentUser.username}</span></span>
                                </li>
                                <li className="nav-item">
                                    <button className="btn btn-secondary-premium border-0 py-2" onClick={logOut}>
                                        Logout
                                    </button>
                                </li>
                            </>
                        ) : (
                            <>
                                <li className="nav-item">
                                    <Link to={"/login"} className="nav-link-premium">Sign In</Link>
                                </li>
                                <li className="nav-item">
                                    <Link to={"/register"} className="btn-premium py-2">Get Started</Link>
                                </li>
                            </>
                        )}
                    </div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
