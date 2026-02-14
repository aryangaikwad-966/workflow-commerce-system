import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import orderService from "../../services/order.service";
import { useCart } from "../../contexts/CartContext";
import AuthService from "../../services/auth.service";

const Cart = () => {
    const [shippingAddress, setShippingAddress] = useState("");
    const [message, setMessage] = useState("");
    const [user, setUser] = useState(null);
    const { cart, updateQuantity, removeFromCart, clearCart, getTotalPrice } = useCart();
    const navigate = useNavigate();

    // Check if user is authenticated for checkout
    useEffect(() => {
        const currentUser = AuthService.getCurrentUser();
        setUser(currentUser);
    }, []);

    // Handle pending checkout after login
    useEffect(() => {
        const pendingCheckout = localStorage.getItem('pendingCheckout');
        if (pendingCheckout && user) {
            const { shippingAddress: savedAddress, cart: savedCart } = JSON.parse(pendingCheckout);
            setShippingAddress(savedAddress);
            localStorage.removeItem('pendingCheckout');
            setMessage("Logged in successfully! You can now place your order.");
        }
    }, [user?.id]);


    const handleCheckout = async (e) => {
        e.preventDefault();
        if (cart.length === 0) {
            setMessage("Your cart is empty");
            return;
        }
        if (!shippingAddress.trim()) {
            setMessage("Please enter a shipping address");
            return;
        }

        // Check if user is authenticated before placing order
        if (!user) {
            // Store cart data for after login
            localStorage.setItem('pendingCheckout', JSON.stringify({
                shippingAddress,
                cart
            }));
            setMessage("Redirecting to login...");
            setTimeout(() => navigate("/login"), 1000);
            return;
        }

        try {
            const orderData = {
                items: cart.map(item => ({
                    productId: item.productId,
                    quantity: item.quantity
                })),
                shippingAddress: shippingAddress
            };

            await orderService.createOrder(orderData);
            setMessage("Order placed successfully!");
            clearCart();
            setShippingAddress("");
            setTimeout(() => navigate("/orders"), 2000);

        } catch (err) {
            setMessage(err.response?.data?.message || "Failed to place order");
        }
    };

    return (
        <div className="container py-5">
            <div className="row">
                <div className="col-md-8">
                    <h2 className="mb-4">Shopping Cart</h2>
                    {message && <div className="alert alert-info">{message}</div>}

                    {cart.length === 0 ? (
                        <div className="admin-card p-5 text-center shadow-sm">
                            <h4 className="text-secondary mb-3">Your cart is empty</h4>
                            <p className="text-muted">Add some products to get started!</p>
                            <button
                                className="btn-primary-tech px-4 py-2"
                                onClick={() => navigate("/products")}
                            >
                                Browse Products
                            </button>
                        </div>
                    ) : (
                        <div className="admin-card p-4 shadow-sm">
                            <div className="table-responsive">
                                <table className="table">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>SKU</th>
                                            <th>Price</th>
                                            <th>Quantity</th>
                                            <th>Total</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {cart.map((item) => (
                                            <tr key={item.productId}>
                                                <td>{item.productName}</td>
                                                <td>{item.sku}</td>
                                                <td>${item.price.toFixed(2)}</td>
                                                <td>
                                                    <div className="input-group" style={{ width: '100px' }}>
                                                        <input
                                                            type="number"
                                                            className="form-control"
                                                            min="1"
                                                            value={item.quantity}
                                                            onChange={(e) => updateQuantity(item.productId, parseInt(e.target.value))}
                                                        />
                                                    </div>
                                                </td>
                                                <td>${(item.price * item.quantity).toFixed(2)}</td>
                                                <td>
                                                    <button
                                                        className="btn btn-sm btn-danger"
                                                        onClick={() => removeFromCart(item.productId)}
                                                    >
                                                        Remove
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>

                            <div className="mt-4">
                                <h4>Total: ${getTotalPrice().toFixed(2)}</h4>
                            </div>
                        </div>
                    )}
                </div>

                <div className="col-md-4">
                    <div className="admin-card p-4 shadow-sm">
                        <h4 className="mb-4">Checkout</h4>

                        <form onSubmit={handleCheckout}>
                            <div className="mb-3">
                                <label htmlFor="shippingAddress" className="form-label">
                                    Shipping Address
                                </label>
                                <textarea
                                    id="shippingAddress"
                                    className="form-control"
                                    rows="3"
                                    value={shippingAddress}
                                    onChange={(e) => setShippingAddress(e.target.value)}
                                    placeholder="Enter your complete shipping address"
                                    required
                                />
                            </div>

                            <div className="mb-3">
                                <h5>Order Summary</h5>
                                <div className="border rounded p-3 bg-light">
                                    <div className="d-flex justify-content-between mb-2">
                                        <span>Items ({cart.length}):</span>
                                        <span>${getTotalPrice().toFixed(2)}</span>
                                    </div>
                                    <div className="d-flex justify-content-between">
                                        <span>Shipping:</span>
                                        <span>FREE</span>
                                    </div>
                                    <hr />
                                    <div className="d-flex justify-content-between fw-bold">
                                        <span>Total:</span>
                                        <span>${getTotalPrice().toFixed(2)}</span>
                                    </div>
                                </div>
                            </div>

                            {!user ? (
                                <div className="alert alert-warning">
                                    <h6 className="alert-heading">Login Required</h6>
                                    <p className="mb-2">Please log in to place your order.</p>
                                    <button
                                        className="btn-primary-tech btn-sm w-100"
                                        onClick={() => navigate("/login")}
                                    >
                                        Login to Checkout
                                    </button>
                                </div>
                            ) : (
                                <button
                                    type="submit"
                                    className="btn-primary-tech w-100 py-2"
                                    disabled={cart.length === 0}
                                >
                                    Place Order
                                </button>
                            )}
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Cart;
