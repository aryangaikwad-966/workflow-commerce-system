# 🧾 Technical Specification: Workflow Commerce Core
> **Engineer-Facing Reference | Infrastructure Architecture v1.0**

---

## 1. Core Implementation Detail: Deterministic Workflow Engine
The system's distinguishing feature is the **Workflow Engine**, which encapsulates the state transition logic for commerce objects.

### 1.1 State Definition Enums
```java
public enum OrderState {
    CREATED,    // Initial entry point
    PAID,       // Post-financial settlement
    SHIPPED,    // Logistical dispatch
    DELIVERED,  // Final fulfillment
    CANCELLED,  // Terminal state - revoked
    REFUNDED    // Terminal state - reversed
}
```

### 1.2 Transition Matrix Verification
The engine enforces a **Positive-Only Transition Matrix**. Any transition not explicitly defined is rejected via a standardized `IllegalStateTransitionException`.

| Current State | Target State | Authorized Role | Requirement |
| :--- | :--- | :--- | :--- |
| `CREATED` | `PAID` | `ROLE_USER` | Valid Payment Intent |
| `CREATED` | `CANCELLED` | `ROLE_USER` | None |
| `PAID` | `SHIPPED` | `ROLE_ADMIN` | Logistics Token Generation |
| `PAID` | `REFUNDED` | `ROLE_ADMIN` | Reason Code |
| `SHIPPED` | `DELIVERED` | `ROLE_ADMIN` | Delivery confirmation |

---

## 2. Infrastructure Layer
### 2.1 Backend: Spring Boot 3 & Security
- **Auth Architecture**: Stateless JWT using `HS512` algorithm.
- **RBAC**: Enforced via `@PreAuthorize` at the Controller layer and granular checks in Service layers.
- **Persistence**: JPA/Hibernate with optimized indexing on `category_name` and `order_id`.

### 2.2 Frontend: High-Performance React
- **Rendering**: Vite SSR-compatible frontend architecture.
- **Interactions**: Axios interceptors for handling 401/403 errors and token injection.
- **State Driven UI**: Component rendering is gated by both Role and Entity State.

---

## 3. Data Schema: Entity Relationships
### 3.1 Primary Entities
- **User**: Identity root with multi-role capability.
- **Category (Task 1)**: Metadata root for products. Implements **Soft-Delete** via `status` bit.
- **Product**: Physical item inventory (Upcoming).
- **Order**: Workflow target containing state-delta history.
- **AuditLog**: Immutable append-only log of every transition.

### 3.2 Schema Diagram (Logical)
```
[User] 1 -- N [Order]
[Order] 1 -- 1 [Payment]
[Order] 1 -- N [AuditLog]
[Category] 1 -- N [Product]
```

---

## 4. Security Protocols
### 4.1 Token Lifecycle
- **Issue**: Upon successful `/api/auth/login`.
- **Validation**: Every request via `AuthTokenFilter`.
- **Authorization**: Roles prefixed with `ROLE_` as per Spring Security standards.

### 4.2 Error Handling Schema
Standardized JSON responses for technical failures:
```json
{
  "code": "WORKFLOW_ERROR_403",
  "status": "FORBIDDEN",
  "message": "Insufficient authority for SHIPPED transition."
}
```

---

## 5. Deployment Orchestration
### 5.1 Environment Configuration
- **Production**: PostgreSQL 15, Spring Boot Dockerized.
- **CI/CD**: Auto-deployment triggered by `git push` to `main`.
- **Environment Variables**:
    - `SPRING_DATASOURCE_URL`: Target DB.
    - `APP_JWT_SECRET`: 64-character signing key.

---
*Technical Custodian: System Architects Team*
