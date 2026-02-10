import React, { useEffect, useState } from "react";
import publicCategoryService from "../../services/publicCategory.service";
import publicProductService from "../../services/publicProduct.service";

const ProductCatalog = () => {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);
    const [selectedCategory, setSelectedCategory] = useState("all");
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchCategories();
        fetchProducts();
    }, []);

    const fetchCategories = async () => {
        try {
            const res = await publicCategoryService.getAll();
            setCategories(res.data.filter(cat => cat.status));
        } catch (err) {
            console.error("Failed to load categories", err);
        }
    };

    const fetchProducts = async () => {
        try {
            setLoading(true);
            const res = await publicProductService.getAll();
            // Filter only active products
            const activeProducts = Array.isArray(res.data) ? res.data : [];
            setProducts(activeProducts);
        } catch (err) {
            console.error("Failed to load products", err);
            setProducts([]);
        } finally {
            setLoading(false);
        }
    };

    const filteredProducts = selectedCategory === "all"
        ? products
        : products.filter(product => product.category?.category_id === parseInt(selectedCategory));

    const groupedProducts = categories.reduce((acc, category) => {
        const categoryProducts = filteredProducts.filter(
            product => product.category?.category_id === category.category_id
        );
        if (categoryProducts.length > 0) {
            acc[category.category_name] = categoryProducts;
        }
        return acc;
    }, {});

    if (loading) {
        return (
            <div className="container py-5">
                <div className="text-center">
                    <div className="spinner-border text-primary" role="status">
                        <span className="visually-hidden">Loading...</span>
                    </div>
                    <p className="mt-3">Loading products...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="container py-5">
            <div className="row mb-4">
                <div className="col-12">
                    <h2 className="mb-4">Product Catalog</h2>

                    {/* Category Filter */}
                    <div className="mb-4">
                        <label htmlFor="categoryFilter" className="form-label fw-bold">
                            Filter by Category:
                        </label>
                        <select
                            id="categoryFilter"
                            className="form-select"
                            value={selectedCategory}
                            onChange={(e) => setSelectedCategory(e.target.value)}
                        >
                            <option value="all">All Categories</option>
                            {categories.map((category) => (
                                <option key={category.category_id} value={category.category_id}>
                                    {category.category_name}
                                </option>
                            ))}
                        </select>
                    </div>
                </div>
            </div>

            {Object.keys(groupedProducts).length === 0 ? (
                <div className="text-center py-5">
                    <div className="admin-card p-5 d-inline-block shadow-sm">
                        <h4 className="text-secondary mb-3">No Products Available</h4>
                        <p className="text-muted">
                            {selectedCategory === "all"
                                ? "There are currently no active products in the catalog."
                                : "There are no products in this category."
                            }
                        </p>
                    </div>
                </div>
            ) : (
                Object.entries(groupedProducts).map(([categoryName, categoryProducts]) => (
                    <div key={categoryName} className="mb-5">
                        <h3 className="mb-4 border-bottom pb-2">
                            {categoryName}
                            <span className="badge bg-secondary ms-2">{categoryProducts.length}</span>
                        </h3>

                        <div className="row">
                            {categoryProducts.map((product) => (
                                <div key={product.productId} className="col-md-6 col-lg-4 mb-4">
                                    <div className="card h-100 shadow-sm">
                                        <div className="card-body">
                                            <h5 className="card-title">{product.productName}</h5>
                                            <p className="card-text text-muted small">
                                                SKU: {product.sku}
                                            </p>
                                            <p className="card-text">
                                                {product.description || "No description available"}
                                            </p>
                                            <div className="d-flex justify-content-between align-items-center">
                                                <span className="h5 text-primary mb-0">
                                                    ${product.price}
                                                </span>
                                                <span className={`badge ${product.inventoryCount > 10 ? 'bg-success' : product.inventoryCount > 0 ? 'bg-warning' : 'bg-danger'}`}>
                                                    {product.inventoryCount > 0 ? `In Stock (${product.inventoryCount})` : 'Out of Stock'}
                                                </span>
                                            </div>
                                        </div>
                                        <div className="card-footer bg-light">
                                            <small className="text-muted">
                                                Category: {product.category?.category_name}
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                ))
            )}
        </div>
    );
};

export default ProductCatalog;
