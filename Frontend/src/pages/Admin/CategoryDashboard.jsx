import React, { useState, useEffect } from "react";
import CategoryService from "../../services/category.service";

const CategoryDashboard = () => {
    const [categories, setCategories] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [editMode, setEditMode] = useState(false);
    const [currentCategory, setCurrentCategory] = useState({ id: null, category_name: "", description: "" });
    const [message, setMessage] = useState("");

    useEffect(() => {
        loadCategories();
    }, []);

    const loadCategories = () => {
        CategoryService.getAllCategories().then(
            (response) => {
                setCategories(response.data);
            },
            (error) => {
                console.error("Error fetching categories", error);
            }
        );
    };

    const handleOpenModal = (category = { id: null, category_name: "", description: "" }) => {
        setCurrentCategory(category);
        setEditMode(!!category.category_id);
        setShowModal(true);
    };

    const handleCloseModal = () => {
        setShowModal(false);
        setMessage("");
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setCurrentCategory({ ...currentCategory, [name]: value });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        const apiCall = editMode
            ? CategoryService.updateCategory(currentCategory.category_id, currentCategory.category_name, currentCategory.description)
            : CategoryService.createCategory(currentCategory.category_name, currentCategory.description);

        apiCall.then(
            () => {
                loadCategories();
                handleCloseModal();
            },
            (error) => {
                setMessage(error.response?.data?.message || "An error occurred.");
            }
        );
    };

    const handleDeactivate = (id) => {
        if (window.confirm("WARNING: Please assign products to another category before deactivating. Are you sure?")) {
            CategoryService.deactivateCategory(id).then(
                () => {
                    loadCategories();
                },
                (error) => {
                    alert("Error deactivating category");
                }
            );
        }
    };

    return (
        <div className="container-fluid py-5 animate-slide-up" style={{ maxWidth: '1200px' }}>
            <div className="d-flex justify-content-between align-items-end mb-5">
                <div>
                    <h2 className="fw-bold mb-1 font-premium">Infrastructure Console</h2>
                    <p className="text-muted small mb-0">Management of global product categories and taxonomy systems</p>
                </div>
                <button className="btn-premium py-2 px-4 shadow-sm" onClick={() => handleOpenModal()}>
                    <span className="me-2">+</span> Initialize Category
                </button>
            </div>

            {categories.length === 0 ? (
                <div className="glass-card p-5 text-center border-dashed">
                    <p className="text-muted mb-0">No taxonomic data found. Initialize your first category to begin.</p>
                </div>
            ) : (
                <div className="glass-card overflow-hidden">
                    <div className="table-responsive">
                        <table className="table table-dark table-hover mb-0 align-middle">
                            <thead className="bg-white bg-opacity-5">
                                <tr>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted border-0" style={{ fontSize: '11px' }}>Taxonomy Name</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted border-0" style={{ fontSize: '11px' }}>Context Description</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted border-0" style={{ fontSize: '11px' }}>Deployment Status</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted border-0 text-end" style={{ fontSize: '11px' }}>Operations</th>
                                </tr>
                            </thead>
                            <tbody>
                                {categories.map((cat) => (
                                    <tr key={cat.category_id} className="border-bottom border-white border-opacity-5">
                                        <td className="px-4 py-4 fw-semibold text-white">{cat.category_name}</td>
                                        <td className="px-4 py-4 text-muted small">{cat.description || "No description provided"}</td>
                                        <td className="px-4 py-4">
                                            <span className={`badge-premium ${cat.status ? 'text-success' : 'text-danger'}`} style={{ background: cat.status ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)' }}>
                                                {cat.status ? '● Fully Operational' : '○ Decommissioned'}
                                            </span>
                                        </td>
                                        <td className="px-4 py-4 text-end">
                                            <button
                                                className="btn btn-secondary-premium btn-sm border-0 me-2"
                                                onClick={() => handleOpenModal(cat)}
                                                disabled={!cat.status}
                                            >
                                                Configure
                                            </button>
                                            {cat.status && (
                                                <button
                                                    className="btn btn-secondary-premium btn-sm border-0 text-danger"
                                                    onClick={() => handleDeactivate(cat.category_id)}
                                                >
                                                    Retire
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Modal for Create/Edit */}
            {showModal && (
                <div className="modal show d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(2, 6, 23, 0.85)', backdropFilter: 'blur(10px)' }}>
                    <div className="modal-dialog modal-dialog-centered">
                        <div className="glass-card p-5 w-100 mx-3 border border-white border-opacity-10">
                            <div className="d-flex justify-content-between align-items-center mb-5">
                                <h4 className="fw-bold m-0 font-premium">{editMode ? 'Update Configuration' : 'Provision Category'}</h4>
                                <button type="button" className="btn-close btn-close-white opacity-50" onClick={handleCloseModal}></button>
                            </div>
                            <form onSubmit={handleSubmit}>
                                {message && <div className="alert bg-danger bg-opacity-10 text-danger border-0 small mb-4">{message}</div>}
                                <div className="mb-4">
                                    <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Identifer (Name)</label>
                                    <input
                                        type="text"
                                        className="form-control form-control-premium text-white"
                                        name="category_name"
                                        value={currentCategory.category_name}
                                        onChange={handleInputChange}
                                        placeholder="e.g. Computing Systems"
                                        required
                                    />
                                </div>
                                <div className="mb-5">
                                    <label className="form-label small text-uppercase fw-bold text-muted" style={{ fontSize: '10px', letterSpacing: '0.05em' }}>Functional Scope (Description)</label>
                                    <textarea
                                        className="form-control form-control-premium text-white"
                                        name="description"
                                        rows="4"
                                        value={currentCategory.description}
                                        onChange={handleInputChange}
                                        placeholder="Describe the operational scope of this category..."
                                        maxLength="300"
                                    ></textarea>
                                </div>
                                <div className="d-flex gap-2 justify-content-end">
                                    <button type="button" className="btn btn-link text-muted text-decoration-none small" onClick={handleCloseModal}>Cancel</button>
                                    <button type="submit" className="btn-premium px-4 py-2">{editMode ? 'Apply Updates' : 'Confirm Provisioning'}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CategoryDashboard;
