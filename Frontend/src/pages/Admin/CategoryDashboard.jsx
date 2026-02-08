import React, { useState, useEffect } from "react";
import CategoryService from "../../services/category.service";

const CategoryDashboard = () => {
    const [categories, setCategories] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [editMode, setEditMode] = useState(false);
    const [currentCategory, setCurrentCategory] = useState({ category_id: null, category_name: "", description: "" });
    const [message, setMessage] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        loadCategories();
    }, []);

    const loadCategories = () => {
        setLoading(true);
        CategoryService.getAllCategories().then(
            (response) => {
                setCategories(response.data);
                setLoading(false);
            },
            (err) => {
                console.error("Error fetching categories", err);
                setError("Failed to load categories. Please try again later.");
                setLoading(false);
            }
        );
    };

    const handleOpenModal = (category = { category_id: null, category_name: "", description: "" }) => {
        setCurrentCategory(category);
        setEditMode(!!category.category_id);
        setShowModal(true);
        setMessage("");
        setError("");
    };

    const handleCloseModal = () => {
        setShowModal(false);
        setMessage("");
        setError("");
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setCurrentCategory({ ...currentCategory, [name]: value });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        setError("");

        if (!currentCategory.category_name.trim()) {
            setError("Category name is required");
            return;
        }

        const apiCall = editMode
            ? CategoryService.updateCategory(currentCategory.category_id, currentCategory.category_name, currentCategory.description)
            : CategoryService.createCategory(currentCategory.category_name, currentCategory.description);

        apiCall.then(
            () => {
                const successMsg = editMode ? "Category updated successfully" : "Category created successfully";
                setMessage(successMsg);
                loadCategories();
                setTimeout(() => {
                    handleCloseModal();
                }, 1000);
            },
            (err) => {
                const errMsg = err.response?.data?.message || "An error occurred.";
                setError(errMsg);
            }
        );
    };

    const handleDeactivate = (id) => {
        if (window.confirm("Please assign products to another category before deactivating.")) {
            CategoryService.deactivateCategory(id).then(
                () => {
                    setMessage("Category deactivated successfully");
                    loadCategories();
                    setTimeout(() => setMessage(""), 3000);
                },
                (err) => {
                    setError("Error deactivating category");
                }
            );
        }
    };

    return (
        <div className="py-4 animate-fade-in">
            <div className="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 className="mb-1">Category Management</h2>
                    <p className="text-secondary small mb-0">Centralized taxonomy management and catalog organization</p>
                </div>
                <button className="btn-primary-tech shadow-sm" onClick={() => handleOpenModal()}>
                    + Add Category
                </button>
            </div>

            {message && (
                <div className="alert alert-success border-0 shadow-sm py-2 px-3 small d-flex justify-content-between align-items-center mb-4">
                    <span>{message}</span>
                    <button type="button" className="btn-close small" onClick={() => setMessage("")}></button>
                </div>
            )}

            {error && (
                <div className="alert alert-danger border-0 shadow-sm py-2 px-3 small d-flex justify-content-between align-items-center mb-4">
                    <span>{error}</span>
                    <button type="button" className="btn-close small" onClick={() => setError("")}></button>
                </div>
            )}

            <div className="admin-card overflow-hidden">
                <div className="table-responsive">
                    <table className="table-bigtech mb-0">
                        <thead>
                            <tr>
                                <th>Category Name</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Product Count</th>
                                <th className="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr>
                                    <td colSpan="5" className="text-center py-5">
                                        <div className="spinner-border spinner-border-sm text-primary me-2"></div>
                                        <span className="text-secondary">Loading taxonomic data...</span>
                                    </td>
                                </tr>
                            ) : categories.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="text-center py-5 text-secondary">
                                        No categories found. Click "Add Category" to get started.
                                    </td>
                                </tr>
                            ) : (
                                categories.map((cat) => (
                                    <tr key={cat.category_id}>
                                        <td className="fw-medium text-dark">{cat.category_name}</td>
                                        <td className="text-secondary small">
                                            {cat.description || <span className="text-muted italic">No description</span>}
                                        </td>
                                        <td>
                                            <span className={`status-badge ${cat.status ? 'status-active' : 'status-inactive'}`}>
                                                {cat.status ? 'Active' : 'Inactive'}
                                            </span>
                                        </td>
                                        <td>
                                            <span className="badge bg-light text-secondary border px-2 py-1">
                                                {cat.productCount || 0}
                                            </span>
                                        </td>
                                        <td className="text-end">
                                            <div className="d-flex justify-content-end gap-2">
                                                <button
                                                    className="btn btn-secondary-tech btn-sm py-1"
                                                    onClick={() => handleOpenModal(cat)}
                                                    disabled={!cat.status}
                                                >
                                                    Edit
                                                </button>
                                                <button
                                                    className="btn btn-danger-tech btn-sm py-1"
                                                    onClick={() => handleDeactivate(cat.category_id)}
                                                    disabled={!cat.status}
                                                >
                                                    Deactivate
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal for Create/Edit */}
            {showModal && (
                <div className="modal show d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0, 0, 0, 0.4)', backdropFilter: 'blur(4px)' }}>
                    <div className="modal-dialog modal-dialog-centered">
                        <div className="modal-content border-0 shadow-lg">
                            <div className="modal-header border-bottom-0 pt-4 px-4">
                                <h5 className="modal-title fw-bold">{editMode ? 'Update Category' : 'Add New Category'}</h5>
                                <button type="button" className="btn-close" onClick={handleCloseModal}></button>
                            </div>
                            <form onSubmit={handleSubmit}>
                                <div className="modal-body px-4 pb-4">
                                    {error && <div className="alert alert-danger py-2 px-3 small border-0 mb-3">{error}</div>}
                                    <div className="mb-3">
                                        <label className="form-label small fw-semibold text-secondary">Category Name <span className="text-danger">*</span></label>
                                        <input
                                            type="text"
                                            className="form-input-tech"
                                            name="category_name"
                                            value={currentCategory.category_name}
                                            onChange={handleInputChange}
                                            placeholder="e.g. Electronics"
                                            required
                                        />
                                    </div>
                                    <div className="mb-0">
                                        <label className="form-label small fw-semibold text-secondary">Description</label>
                                        <textarea
                                            className="form-input-tech"
                                            name="description"
                                            rows="3"
                                            value={currentCategory.description}
                                            onChange={handleInputChange}
                                            placeholder="Optional category description..."
                                        ></textarea>
                                    </div>
                                </div>
                                <div className="modal-footer border-top-0 px-4 pb-4 pt-0">
                                    <button type="button" className="btn-secondary-tech" onClick={handleCloseModal}>Cancel</button>
                                    <button type="submit" className="btn-primary-tech px-4">
                                        {editMode ? 'Save Changes' : 'Create Category'}
                                    </button>
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
