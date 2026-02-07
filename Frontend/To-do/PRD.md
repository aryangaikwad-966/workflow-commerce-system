

# 📄 Product Requirements Document (PRD)

## 1. Product Overview

**Product Name:** Workflow / State-Machine-Driven Commerce System
**Type:** Full-Stack Web Application
**Domain:** E-Commerce (Order Management & Workflow Control)

### Purpose

To build a commerce system where **all order-related actions are governed by an explicit workflow/state machine**, ensuring correctness, security, and maintainability.

---

## 2. Problem Statement

Traditional e-commerce systems often rely on scattered conditional logic (`if/else`) to manage order states, leading to:

* Invalid actions (e.g., refund before payment)
* Inconsistent order data
* Difficult debugging and maintenance

There is a need for a **deterministic, rule-driven workflow system** that enforces valid transitions and blocks illegal actions.

---

## 3. Goals & Objectives

* Enforce **strict order lifecycle rules**
* Prevent invalid business actions
* Provide **clear visibility** of order states
* Build a **real-world, production-oriented backend**
* Fully comply with internship requirements (A→Z)

---

## 4. Scope

### In Scope

* User & Admin workflows
* Order lifecycle management using a state machine
* Payment, cancellation, refund, and fulfillment flows
* Role-based access control
* Live deployment and documentation

### Out of Scope

* AI-based recommendations
* Advanced UI animations
* Multi-vendor marketplace logic

---

## 5. User Roles

### User

* Register / Login
* Create order
* Make payment
* View order status
* Cancel order (only in allowed states)

### Admin

* View all orders
* Ship orders
* Mark orders as delivered
* Force refunds (with reason)
* View audit logs

---

## 6. Workflow / State Machine Design

### Order States

* `CREATED`
* `PAID`
* `SHIPPED`
* `DELIVERED`
* `CANCELLED`
* `REFUNDED`

### Allowed Transitions

* `CREATED → PAID`
* `CREATED → CANCELLED`
* `PAID → SHIPPED`
* `PAID → REFUNDED`
* `SHIPPED → DELIVERED`

❌ All other transitions are blocked by backend validation.

---

## 7. Functional Requirements

### Backend

* REST APIs for all operations
* Centralized Workflow Engine:

  * Validates transitions
  * Enforces role permissions
* JWT-based authentication
* Role-based authorization
* SQL database with proper relationships
* Audit logging for state changes

### Frontend

* React-based UI
* User Dashboard (My Orders, Status)
* Admin Dashboard (All Orders, Actions)
* Navigation bar (Login, Register, Orders, Dashboard)
* Responsive and consistent UI
* Buttons enabled/disabled based on order state

---

## 8. Database Requirements

### Tables

* User
* Role
* Product
* Order
* Payment
* AuditLog

### Relationships

* User → Orders (one-to-many)
* Order → Products (many-to-many)
* Order → Payment (one-to-one)

---

## 9. Non-Functional Requirements

* Responsive UI (desktop & mobile)
* Clean and intuitive UX
* Secure APIs
* Maintainable codebase
* Clear documentation
* High availability via live deployment

---

## 10. GitHub & Dev Workflow

* Single GitHub repository
* Modular commits after each task
* Meaningful commit messages
* Proper `README.md`
* Code pushed after every module

---

## 11. Deployment

* Live deployment on cloud platform
* Publicly accessible URL
* Redeployment after each major module
* Application available 24×7 for evaluation

---

## 12. Documentation

* End-user documentation
* Step-by-step usage guide
* Screenshots of UI flows
* State diagrams
* Setup & configuration instructions

---

## 13. Internship Alignment

* Modular task-based development
* Submission per module
* Mentor review & approval
* Project mock evaluation
* Live demo & explanation
* Certification upon successful completion

---

## 14. Success Metrics

* All internship requirements satisfied
* All mentor approvals received
* Successful mock evaluation
* Fully working deployed system
* Clear demonstration of workflow correctness

---

## 15. Risks & Mitigation

| Risk                | Mitigation                     |
| ------------------- | ------------------------------ |
| Invalid transitions | Central workflow validation    |
| UI confusion        | State-based button control     |
| Evaluation issues   | Clear diagrams & documentation |

---

## 16. Final Statement

This project demonstrates **real-world backend engineering maturity** by enforcing deterministic workflows in a commerce system, aligning perfectly with internship objectives and postgraduate expectations.

---


