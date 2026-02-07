

# 🧾 Technical Document

![Image](https://www.cs.fsu.edu/~myers/cop3331/notes/examples/UML/LeaveMessage.gif)

![Image](https://miro.medium.com/1%2Ajci9-EvG8xXV0TFFFVQBpQ.jpeg)

![Image](https://repository-images.githubusercontent.com/563231486/038a28f8-2ab0-409d-8df0-e7e434c8bbf4)

---

## 1. Technology Stack

### Frontend

* **React 18**
* Axios (API calls)
* Bootstrap / MUI (responsive UI)
* React Router (navigation)

### Backend

* **Java 17**
* **Spring Boot**
* Spring Security (JWT)
* Spring Data JPA (Hibernate)
* RESTful APIs

### Database

* PostgreSQL / MySQL (SQL)

### Deployment

* Frontend: Netlify / Vercel
* Backend: Render / Railway / Fly.io

---

## 2. Project Structure

### Backend (Spring Boot)

```
com.example.workflowcommerce
├── controller
├── service
│   ├── WorkflowService
│   ├── OrderService
│   └── PaymentService
├── security
├── model
│   ├── Order
│   ├── User
│   └── Payment
├── repository
├── dto
└── exception
```

### Frontend (React)

```
src/
├── components
├── pages
│   ├── Login
│   ├── UserDashboard
│   ├── AdminDashboard
│   └── OrderDetails
├── services (API calls)
└── routes
```

---

## 3. Core Data Models

### Order

```java
Order {
  id
  userId
  state (ENUM)
  totalAmount
  createdAt
}
```

### OrderState (ENUM)

```
CREATED
PAID
SHIPPED
DELIVERED
CANCELLED
REFUNDED
```

### Payment

```java
Payment {
  id
  orderId
  amount
  status
  timestamp
}
```

### AuditLog

```java
AuditLog {
  id
  orderId
  fromState
  toState
  actor
  timestamp
}
```

---

## 4. Workflow / State Machine Implementation (CORE)

### Transition Map (Central Rule Engine)

```java
Map<OrderState, Set<OrderState>> allowedTransitions;
```

Example:

```
CREATED → PAID, CANCELLED
PAID → SHIPPED, REFUNDED
SHIPPED → DELIVERED
```

### WorkflowService Logic

1. Fetch order
2. Read current state
3. Validate target state
4. Validate user role
5. Execute side-effects
6. Persist new state
7. Create audit log

❌ Any failure → exception thrown

---

## 5. REST API Specification

### Auth

* `POST /auth/register`
* `POST /auth/login`

### Orders

* `POST /orders` → create order
* `GET /orders/{id}`
* `GET /orders/user`
* `POST /orders/{id}/transition`

### Admin

* `GET /admin/orders`
* `POST /admin/orders/{id}/transition`

#### Transition Request Payload

```json
{
  "targetState": "PAID"
}
```

---

## 6. Frontend–Backend Interaction

### Frontend Logic

* Fetch order state
* Show allowed actions only
* Disable illegal buttons

Example:

```js
if (order.state === "CREATED") {
  showPayButton();
}
```

### Backend Safety

Even if frontend is bypassed:

* Backend **revalidates transitions**
* Invalid transitions are rejected

---

## 7. Security Implementation

### Authentication

* JWT issued on login
* Token sent via Authorization header

### Authorization

* Role checked per transition
* Example:

  * USER → PAY, CANCEL
  * ADMIN → SHIP, DELIVER, REFUND

---

## 8. Database Integrity

### Relationships

* User → Orders (1-N)
* Order → Payment (1-1)
* Order → AuditLog (1-N)

Foreign keys enforced via JPA annotations.

---

## 9. Error Handling

### Global Exception Handler

Handles:

* Invalid transition
* Unauthorized access
* Resource not found

Example response:

```json
{
  "error": "INVALID_TRANSITION",
  "message": "Cannot ship order before payment"
}
```

---

## 10. Testing Strategy

### Unit Tests

* WorkflowService transition validation
* Role permission checks

### Integration Tests

* End-to-end order lifecycle
* Invalid transition rejection

### Manual Tests

* UI button enable/disable
* Admin vs user behavior

---

## 11. Deployment & Configuration

### Environment Variables

```
DB_URL
DB_USERNAME
DB_PASSWORD
JWT_SECRET
```

### Deployment Flow

1. Push code to GitHub
2. Auto-deploy backend
3. Auto-deploy frontend
4. Public URL updated

---

## 12. Logging & Monitoring

* State transitions logged
* Errors logged centrally
* Audit logs used for demo & evaluation

---

## 13. Technical Justification (Evaluation Ready)

* Central workflow engine → correctness
* State enum → deterministic logic
* REST APIs → scalable integration
* JWT security → industry standard
* SQL DB → transactional consistency

---

## 14. Final Technical Summary

> This system implements a centralized workflow/state-machine engine to enforce deterministic order transitions, secure role-based actions, and maintain data consistency in a full-stack commerce application.

---


