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
        <div className="container mt-5 py-4 animate-fade-in">
            <div className="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 className="fw-bold mb-1">Category Management</h2>
                    <p className="text-muted small">Manage your product groups and their availability</p>
                </div>
                <button className="btn btn-premium d-flex align-items-center" onClick={() => handleOpenModal()}>
                    <span className="me-2">+</span> Add Category
                </button>
            </div>

            {categories.length === 0 ? (
                <div className="glass-card p-5 text-center">
                    <p className="lead">No categories have been established yet.</p>
                </div>
            ) : (
                <div className="glass-card overflow-hidden shadow-lg border-0">
                    <div className="table-responsive">
                        <table className="table table-dark table-hover mb-0 align-middle">
                            <thead className="bg-dark-subtle">
                                <tr>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted">Category</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted">Description</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted">Availability</th>
                                    <th className="px-4 py-3 text-uppercase small fw-bold text-muted text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="border-top-0">
                                {categories.map((cat) => (
                                    <tr key={cat.category_id} className="border-bottom border-light-subtle">
                                        <td className="px-4 py-4 fw-medium">{cat.category_name}</td>
                                        <td className="px-4 py-4 text-muted small">{cat.description || "—"}</td>
                                        <td className="px-4 py-4">
                                            <span className={`badge rounded-pill px-3 py-2 ${cat.status ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}`}>
                                                {cat.status ? '● Active' : '○ Inactive'}
                                            </span>
                                        </td>
                                        <td className="px-4 py-4 text-end">
                                            <button
                                                className="btn btn-sm btn-outline-light border-0 me-2"
                                                onClick={() => handleOpenModal(cat)}
                                                disabled={!cat.status}
                                            >
                                                Edit
                                            </button>
                                            {cat.status && (
                                                <button
                                                    className="btn btn-sm btn-outline-danger border-0"
                                                    onClick={() => handleDeactivate(cat.category_id)}
                                                >
                                                    Deactivate
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
                <div className="modal show d-block animate-fade-in" tabIndex="-1" style={{ backgroundColor: 'rgba(15, 23, 42, 0.9)', backdropFilter: 'blur(8px)' }}>
                    <div className="modal-dialog modal-dialog-centered">
                        <div className="glass-card p-4 w-100 mx-3 border shadow-2xl">
                            <div className="d-flex justify-content-between align-items-center mb-4">
                                <h4 className="fw-bold m-0">{editMode ? 'Edit Configuration' : 'New Category'}</h4>
                                <button type="button" className="btn-close btn-close-white" onClick={handleCloseModal}></button>
                            </div>
                            <form onSubmit={handleSubmit}>
                                {message && <div className="alert bg-danger-subtle text-danger border-0 small mb-4">{message}</div>}
                                <div className="mb-4">
                                    <label className="form-label small text-uppercase fw-semibold text-muted">Display Name</label>
                                    <input
                                        type="text"
                                        className="form-control form-control-premium text-white"
                                        name="category_name"
                                        value={currentCategory.category_name}
                                        onChange={handleInputChange}
                                        placeholder="e.g. Infrastructure"
                                        required
                                    />
                                </div>
                                <div className="mb-4">
                                    <label className="form-label small text-uppercase fw-semibold text-muted">Summary Description</label>
                                    <textarea
                                        className="form-control form-control-premium text-white"
                                        name="description"
                                        rows="3"
                                        value={currentCategory.description}
                                        onChange={handleInputChange}
                                        placeholder="Briefly describe this category scope..."
                                        maxLength="300"
                                    ></textarea>
                                </div>
                                <div className="d-flex gap-2">
                                    <button type="submit" className="btn btn-premium flex-grow-1 py-2">{editMode ? 'Confirm Changes' : 'Initialize Category'}</button>
                                    <button type="button" className="btn btn-outline-secondary px-4" onClick={handleCloseModal}>Abort</button>
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
