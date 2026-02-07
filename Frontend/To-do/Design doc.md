

# 📐 Technical Design Document (TDD)

![Image](https://silvrback.s3.amazonaws.com/uploads/99adc213-2c31-4017-903d-6da86aca8c23/fsm-orders_medium.png)

![Image](https://miro.medium.com/0%2AxuHRipbS0io0EYVl.png)

![Image](https://cdn-uk-01.visual-paradigm.com/node/on/w/huamscxt/rest/diagrams/shares/diagram/e0fe5e33-a0c0-4717-b2a7-2a02652efec0/preview?p=1)

---

## 1. System Overview

### System Type

Full-Stack E-Commerce System with **Workflow / State-Machine-Driven Backend**

### Core Design Principle

> All order-related actions are controlled by a **centralized workflow engine** that validates state transitions and enforces business rules.

This avoids scattered logic and prevents invalid operations.

---

## 2. High-Level Architecture

### Architecture Style

* **Layered Architecture**
* Backend-first, frontend as a consumer
* Stateless REST APIs

### Components

```
[ React Frontend ]
        |
        v
[ REST API Layer ]
        |
        v
[ Workflow / State Machine Engine ]
        |
        v
[ Business Services ]
        |
        v
[ SQL Database ]
```

---

## 3. Frontend Design

### Technology

* React
* Axios / Fetch API
* Bootstrap / MUI

### UI Structure

#### User Pages

* Login / Register
* Product List (minimal)
* Create Order
* My Orders
* Order Details (state + allowed actions)

#### Admin Pages

* Admin Login
* Orders Dashboard
* Order Action Panel
* Audit Log View

### UI Logic

* Buttons are **enabled/disabled** based on order state
* Invalid actions are hidden or blocked
* State shown clearly with labels

---

## 4. Backend Design

### Technology Stack

* Java 17
* Spring Boot
* Spring Security (JWT)
* JPA / Hibernate
* PostgreSQL / MySQL

---

## 5. Workflow / State Machine Engine (CORE)

### Order States

```
CREATED
PAID
SHIPPED
DELIVERED
CANCELLED
REFUNDED
```

### Transition Rules

| From    | To        | Allowed Role |
| ------- | --------- | ------------ |
| CREATED | PAID      | USER         |
| CREATED | CANCELLED | USER         |
| PAID    | SHIPPED   | ADMIN        |
| PAID    | REFUNDED  | ADMIN        |
| SHIPPED | DELIVERED | ADMIN        |

❌ Any other transition is rejected.

---

### Workflow Engine Responsibilities

* Validate current state
* Validate target state
* Validate role permissions
* Execute side effects
* Persist new state
* Record audit log

### Central Rule

> **No state change happens outside the workflow engine**

---

## 6. API Design

### Authentication APIs

* `POST /auth/register`
* `POST /auth/login`

### Order APIs

* `POST /orders`
* `GET /orders/{id}`
* `GET /orders/user`
* `POST /orders/{id}/transition`

### Admin APIs

* `GET /admin/orders`
* `POST /admin/orders/{id}/transition`

### Workflow Payload Example

```json
{
  "targetState": "PAID"
}
```

---

## 7. Database Design

### Tables

* `users`
* `roles`
* `products`
* `orders`
* `order_items`
* `payments`
* `audit_logs`

### Relationships

* User → Orders (1-N)
* Order → OrderItems (1-N)
* Order → Payment (1-1)
* Order → AuditLogs (1-N)

Foreign keys enforced for integrity.

---

## 8. Security Design

### Authentication

* JWT-based authentication
* Token validated on every request

### Authorization

* Role-based access control
* Role checked per state transition

### Example

* User cannot ship an order
* Admin cannot pay on behalf of user

---

## 9. Error Handling Strategy

* Centralized exception handling
* Clear error messages:

  * Invalid transition
  * Unauthorized action
  * Resource not found

Example:

```json
{
  "error": "INVALID_TRANSITION",
  "message": "Order cannot be shipped before payment"
}
```

---

## 10. Audit & Logging

### Audit Log Captures

* Order ID
* Previous state
* New state
* Actor (User/Admin/System)
* Timestamp
* Reason (if applicable)

Used for:

* Debugging
* Evaluation
* Demonstration

---

## 11. Deployment Design

### Deployment Strategy

* Backend deployed on cloud (Render / Railway / Fly.io)
* Frontend deployed on Netlify / Vercel
* Public URL accessible 24×7

### Environment Handling

* `.env` for secrets
* Separate dev & prod configs

---

## 12. Testing Strategy

### Unit Tests

* Workflow transition validation
* Role enforcement

### Integration Tests

* End-to-end order flow
* Invalid transition rejection

### Manual Testing

* UI button enable/disable
* Admin vs user actions

---

## 13. Non-Functional Design Considerations

* Scalability: stateless APIs
* Maintainability: centralized workflow logic
* Debuggability: audit logs + state history
* Usability: state-driven UI

---

## 14. Design Justification (For Evaluation)

Why state machine?

* Prevents illegal actions
* Improves correctness
* Simplifies maintenance
* Matches real-world systems (booking, fulfillment, banking)

---

## 15. Final Design Statement

> This system applies workflow/state-machine principles to commerce operations, ensuring deterministic behavior, role-controlled actions, and production-grade correctness.

---

