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
        <div className="container mt-4">
            <div className="d-flex justify-content-between align-items-center mb-4">
                <h2>Category Management</h2>
                <button className="btn btn-primary" onClick={() => handleOpenModal()}>Add New Category</button>
            </div>

            {categories.length === 0 ? (
                <div className="alert alert-info">No categories found.</div>
            ) : (
                <table className="table table-striped table-hover shadow-sm">
                    <thead className="table-dark">
                        <tr>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {categories.map((cat) => (
                            <tr key={cat.category_id}>
                                <td>{cat.category_name}</td>
                                <td>{cat.description}</td>
                                <td>
                                    <span className={`badge ${cat.status ? 'bg-success' : 'bg-danger'}`}>
                                        {cat.status ? 'Active' : 'Inactive'}
                                    </span>
                                </td>
                                <td>
                                    <button
                                        className="btn btn-sm btn-outline-primary me-2"
                                        onClick={() => handleOpenModal(cat)}
                                        disabled={!cat.status}
                                    >
                                        Edit
                                    </button>
                                    {cat.status && (
                                        <button
                                            className="btn btn-sm btn-outline-danger"
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
            )}

            {/* Modal for Create/Edit */}
            {showModal && (
                <div className="modal show d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
                    <div className="modal-dialog">
                        <div className="modal-content">
                            <div className="modal-header">
                                <h5 className="modal-title">{editMode ? 'Edit Category' : 'Create Category'}</h5>
                                <button type="button" className="btn-close" onClick={handleCloseModal}></button>
                            </div>
                            <form onSubmit={handleSubmit}>
                                <div className="modal-body">
                                    {message && <div className="alert alert-danger">{message}</div>}
                                    <div className="mb-3">
                                        <label className="form-label">Category Name</label>
                                        <input
                                            type="text"
                                            className="form-control"
                                            name="category_name"
                                            value={currentCategory.category_name}
                                            onChange={handleInputChange}
                                            required
                                        />
                                    </div>
                                    <div className="mb-3">
                                        <label className="form-label">Description</label>
                                        <textarea
                                            className="form-control"
                                            name="description"
                                            value={currentCategory.description}
                                            onChange={handleInputChange}
                                            maxLength="300"
                                        ></textarea>
                                    </div>
                                </div>
                                <div className="modal-footer">
                                    <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>Cancel</button>
                                    <button type="submit" className="btn btn-primary">{editMode ? 'Save Changes' : 'Create'}</button>
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
