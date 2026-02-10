import React, { useState, useEffect } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import AuthService from "../services/auth.service";

const Navbar = () => {
    const [currentUser, setCurrentUser] = useState(undefined);
    const navigate = useNavigate();
    const location = useLocation();

    useEffect(() => {
        const user = AuthService.getCurrentUser();
        if (user) {
            setCurrentUser(user);
        }
    }, [location]);

    const logOut = () => {
        AuthService.logout();
        setCurrentUser(undefined);
        navigate("/login");
        window.location.reload();
    };

    const isAdmin = currentUser?.roles?.includes("ROLE_ADMIN");

    return (
        <nav className="navbar navbar-expand-lg navbar-white bg-white border-bottom sticky-top py-2">
            <div className="container">
                <Link to={"/"} className="navbar-brand fw-bold d-flex align-items-center">
                    <div className="bg-primary text-white rounded-3 me-2 d-flex align-items-center justify-content-center" style={{ width: '32px', height: '32px', fontSize: '16px' }}>
                        W
                    </div>
                    <span className="text-dark font-premium" style={{ letterSpacing: '-0.01em' }}>Workflow</span>
                </Link>

                <button className="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span className="navbar-toggler-icon"></span>
                </button>

                <div className="collapse navbar-collapse" id="navbarNav">
                    <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                        <li className="nav-item">
                            <Link to={"/home"} className={`nav-link-tech me-2 ${location.pathname === '/home' ? 'active' : ''}`}>
                                Home
                            </Link>
                        </li>
                        <li className="nav-item">
                            <Link to={"/products"} className={`nav-link-tech me-2 ${location.pathname === '/products' ? 'active' : ''}`}>
                                Product Catalog
                            </Link>
                        </li>
                        {isAdmin && (
                            <>
                                <li className="nav-item">
                                    <Link to={"/admin/categories"} className={`nav-link-tech ${location.pathname === '/admin/categories' ? 'active' : ''}`}>
                                        Category Management
                                    </Link>
                                </li>
                                <li className="nav-item">
                                    <Link to={"/admin/products"} className={`nav-link-tech ${location.pathname === '/admin/products' ? 'active' : ''}`}>
                                        Product Management
                                    </Link>
                                </li>
                            </>
                        )}
                    </ul>

                    <div className="navbar-nav align-items-center">
                        {currentUser ? (
                            <div className="d-flex align-items-center gap-3">
                                <span className="text-secondary small fw-medium">
                                    {currentUser.username} {isAdmin && <span className="badge bg-light text-primary border ms-1" style={{ fontSize: '10px' }}>ADMIN</span>}
                                </span>
                                <button className="btn-secondary-tech py-1 px-3 shadow-sm btn-sm" onClick={logOut}>
                                    Logout
                                </button>
                            </div>
                        ) : (
                            <div className="d-flex align-items-center gap-2">
                                <Link to={"/login"} className="nav-link-tech px-3">
                                    Login
                                </Link>
                                <Link to={"/register"} className="btn-primary-tech py-1 px-3 shadow-sm btn-sm">
                                    Register
                                </Link>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
