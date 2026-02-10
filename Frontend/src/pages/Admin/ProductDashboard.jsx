import React, { useEffect, useState } from "react";
import categoryService from "../../services/category.service";
import productService from "../../services/product.service";
import authService from "../../services/auth.service";

const ProductDashboard = () => {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);
    const [form, setForm] = useState({
        productName: "",
        description: "",
        price: "",
        sku: "",
        categoryId: "",
        inventoryCount: ""
    });
    const [editingId, setEditingId] = useState(null);
    const [message, setMessage] = useState("");

    useEffect(() => {
        fetchProducts();
        fetchCategories();
    }, []);

    const fetchProducts = async () => {
        try {
            const res = await productService.getAll();
            // Defensive: ensure products is always an array
            if (Array.isArray(res.data)) {
                setProducts(res.data);
            } else if (res.data && Array.isArray(res.data.products)) {
                setProducts(res.data.products);
            } else {
                setProducts([]);
            }
        } catch (err) {
            setProducts([]);
            setMessage("Failed to load products");
        }
    };

    const fetchCategories = async () => {
        try {
            const res = await categoryService.getAllCategories();
            setCategories(res.data);
        } catch (err) {
            setMessage("Failed to load categories");
        }
    };

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage("");
        try {
            const payload = {
                productName: form.productName,
                description: form.description,
                price: parseFloat(form.price),
                sku: form.sku,
                category: { category_id: form.categoryId },
                inventoryCount: parseInt(form.inventoryCount)
            };
            if (editingId) {
                await productService.update(editingId, payload);
                setMessage("Product updated successfully");
            } else {
                await productService.create(payload);
                setMessage("Product created successfully");
            }
            setForm({
                productName: "",
                description: "",
                price: "",
                sku: "",
                categoryId: "",
                inventoryCount: ""
            });
            setEditingId(null);
            fetchProducts();
        } catch (err) {
            setMessage(err.response?.data?.message || "Operation failed");
        }
    };

    const handleEdit = (product) => {
        setForm({
            productName: product.productName,
            description: product.description,
            price: product.price,
            sku: product.sku,
            categoryId: product.category?.category_id || "",
            inventoryCount: product.inventoryCount
        });
        setEditingId(product.productId);
    };

    const handleDeactivate = async (id) => {
        try {
            await productService.deactivate(id);
            setMessage("Product deactivated");
            fetchProducts();
        } catch (err) {
            setMessage("Failed to deactivate product");
        }
    };

    return (
        <div className="container mt-4">
            <h2>Product Management</h2>
            {message && <div className="alert alert-info">{message}</div>}
            <form onSubmit={handleSubmit} className="mb-4">
                <div className="row">
                    <div className="col-md-4 mb-2">
                        <input
                            type="text"
                            className="form-control"
                            name="productName"
                            placeholder="Product Name"
                            value={form.productName}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="col-md-4 mb-2">
                        <input
                            type="text"
                            className="form-control"
                            name="sku"
                            placeholder="SKU"
                            value={form.sku}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="col-md-4 mb-2">
                        <input
                            type="number"
                            className="form-control"
                            name="price"
                            placeholder="Price"
                            value={form.price}
                            onChange={handleChange}
                            min="0"
                            step="0.01"
                            required
                        />
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-4 mb-2">
                        <input
                            type="number"
                            className="form-control"
                            name="inventoryCount"
                            placeholder="Inventory Count"
                            value={form.inventoryCount}
                            onChange={handleChange}
                            min="0"
                            required
                        />
                    </div>
                    <div className="col-md-4 mb-2">
                        <select
                            className="form-control"
                            name="categoryId"
                            value={form.categoryId}
                            onChange={handleChange}
                            required
                        >
                            <option value="">Select Category</option>
                            {categories.map((cat) => (
                                <option key={cat.category_id} value={cat.category_id}>
                                    {cat.category_name}
                                </option>
                            ))}
                        </select>
                    </div>
                    <div className="col-md-4 mb-2">
                        <input
                            type="text"
                            className="form-control"
                            name="description"
                            placeholder="Description"
                            value={form.description}
                            onChange={handleChange}
                        />
                    </div>
                </div>
                <button type="submit" className="btn btn-primary mt-2">
                    {editingId ? "Update Product" : "Add Product"}
                </button>
                {editingId && (
                    <button
                        type="button"
                        className="btn btn-secondary mt-2 ms-2"
                        onClick={() => {
                            setForm({
                                productName: "",
                                description: "",
                                price: "",
                                sku: "",
                                categoryId: "",
                                inventoryCount: ""
                            });
                            setEditingId(null);
                        }}
                    >
                        Cancel
                    </button>
                )}
            </form>
            <table className="table table-bordered">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>SKU</th>
                        <th>Price</th>
                        <th>Inventory</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {products.map((product) => (
                        <tr key={product.productId}>
                            <td>{product.productName}</td>
                            <td>{product.sku}</td>
                            <td>{product.price}</td>
                            <td>{product.inventoryCount}</td>
                            <td>{product.category?.category_name}</td>
                            <td>{product.status ? "Active" : "Inactive"}</td>
                            <td>
                                <button
                                    className="btn btn-sm btn-info me-2"
                                    onClick={() => handleEdit(product)}
                                    disabled={!product.status}
                                >
                                    Edit
                                </button>
                                {product.status && (
                                    <button
                                        className="btn btn-sm btn-danger"
                                        onClick={() => handleDeactivate(product.productId)}
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
    );
};

export default ProductDashboard;
