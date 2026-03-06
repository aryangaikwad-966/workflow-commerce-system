# FlowForge

A production-grade **workflow orchestration engine** built with Spring Boot and React. This platform implements a domain-independent state machine architecture for managing transactional lifecycles, enforcing business rules, and providing operational visibility across distributed commerce operations.

> **Architectural Focus**: This is not a traditional storefront application. It is an **internal operations platform** designed for workflow lifecycle management, state machine governance, and business process orchestration—similar to how companies like Stripe, Square, and Uber build internal operational systems for transaction processing and fulfillment pipelines.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Workflow Engine Design](#workflow-engine-design)
4. [Operational Modules](#operational-modules)
5. [Technology Stack](#technology-stack)
6. [Database Architecture](#database-architecture)
7. [Security Model](#security-model)
8. [Operations Dashboard](#operations-dashboard)
9. [Example Workflow Lifecycle](#example-workflow-lifecycle)
10. [Deployment Architecture](#deployment-architecture)
11. [Running Locally](#running-locally)
12. [API Reference](#api-reference)
13. [Future Improvements](#future-improvements)

---

## Project Overview

### What This System Does

FlowForge provides:

- **Centralized Workflow Orchestration**: A domain-independent workflow engine that manages state transitions for any business entity
- **Business Rule Enforcement**: Validation layer that prevents invalid state transitions (e.g., cannot ship without payment confirmation)
- **Complete Audit Trail**: Every state change is logged with actor, role, timestamp, and contextual comments
- **Role-Based Transition Authorization**: Fine-grained control over which roles can perform specific state transitions
- **Operations Visibility**: Real-time dashboards for monitoring workflow instances, transaction pipelines, and system health

### Core Design Principles

| Principle | Implementation |
|-----------|----------------|
| **State Machine Governance** | All entity lifecycle transitions follow explicitly defined state machines |
| **Domain Independence** | Workflow engine is decoupled from business entities—reusable for orders, payments, shipments, or any custom domain |
| **Fail-Safe Transitions** | Business rules are validated before state changes; invalid operations are rejected with clear error context |
| **Audit-First Architecture** | Immutable audit logs capture every workflow event for compliance and debugging |
| **Eventual Consistency** | Async event-driven architecture supports scalable, decoupled processing |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                           │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   ┌─────────────────────────┐              ┌─────────────────────────────────────┐  │
│   │   Operations Console    │              │      External Integrations          │  │
│   │   (React + Bootstrap)   │              │      (REST API Consumers)           │  │
│   │   - Workflow Dashboard  │              │      - Payment Gateways             │  │
│   │   - Audit Log Viewer    │              │      - Shipping Providers           │  │
│   │   - Entity Management   │              │      - Notification Services        │  │
│   └───────────┬─────────────┘              └─────────────────┬───────────────────┘  │
│               │                                              │                      │
└───────────────┼──────────────────────────────────────────────┼──────────────────────┘
                │                                              │
                ▼                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              API GATEWAY LAYER                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   ┌───────────────────────────────────────────────────────────────────────────────┐ │
│   │                        Spring Security Filter Chain                           │ │
│   │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐   │ │
│   │   │ CORS Filter │ → │ JWT Filter  │ → │ Auth Filter │ → │ Exception Handler│   │ │
│   │   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────────┘   │ │
│   └───────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              SERVICE LAYER                                          │
├───────────────────────────┬─────────────────────────────────────────────────────────┤
│                           │                                                         │
│   WORKFLOW ENGINE CORE    │              DOMAIN SERVICES                            │
│   ┌─────────────────────┐ │   ┌───────────────────────────────────────────────────┐ │
│   │WorkflowEngineService│ │   │ OrderService  │ PaymentService │ ShippingService │ │
│   │  - State Management │ │   │               │                │                 │ │
│   │  - Transition Logic │ │   │ CartService   │ CouponService  │ ReviewService   │ │
│   │  - Audit Logging    │ │   │               │                │                 │ │
│   └─────────┬───────────┘ │   └───────────────────────────────────────────────────┘ │
│             │             │                                                         │
│   ┌─────────▼───────────┐ │   ┌───────────────────────────────────────────────────┐ │
│   │OrderWorkflowRule    │ │   │         WorkflowIntegrationService               │ │
│   │    Validator        │◀┼───│   (Bridge between domain services and engine)     │ │
│   │  - Business Rules   │ │   └───────────────────────────────────────────────────┘ │
│   │  - Payment Check    │ │                                                         │
│   │  - Shipping Check   │ │                                                         │
│   └─────────────────────┘ │                                                         │
│                           │                                                         │
└───────────────────────────┴─────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              PERSISTENCE LAYER                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   WORKFLOW SCHEMA                           DOMAIN SCHEMA                           │
│   ┌─────────────────────────────────┐       ┌─────────────────────────────────────┐ │
│   │ workflow_definitions            │       │ orders          │ payments          │ │
│   │ workflow_states                 │       │ order_items     │ shipping          │ │
│   │ workflow_transitions            │       │ products        │ categories        │ │
│   │ workflow_instances              │       │ customers       │ coupons           │ │
│   │ workflow_logs                   │       │ cart            │ reviews           │ │
│   └─────────────────────────────────┘       └─────────────────────────────────────┘ │
│                                                                                     │
│                          ┌─────────────────────────┐                                │
│                          │  MySQL / PostgreSQL     │                                │
│                          │  (HikariCP Pool: 20)    │                                │
│                          └─────────────────────────┘                                │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Architectural Layers

| Layer | Responsibility | Key Components |
|-------|----------------|----------------|
| **Client Layer** | Operations console, external API consumers | React SPA, REST clients |
| **API Gateway** | Authentication, authorization, request routing | Spring Security, JWT, Global Exception Handler |
| **Service Layer** | Business logic, workflow orchestration | WorkflowEngineService, Domain Services |
| **Persistence Layer** | Data access, transaction management | Spring Data JPA, HikariCP, MySQL/PostgreSQL |

---

## Workflow Engine Design

The workflow engine is the core component of this system. It implements a **finite state machine (FSM)** pattern that:

1. Defines valid states for each workflow type
2. Specifies allowed transitions between states
3. Enforces role-based authorization for transitions
4. Validates business rules before state changes
5. Maintains an immutable audit log

### Core Entities

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW ENGINE DATA MODEL                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   ┌────────────────────────────────────────────────────────────────────────────┐    │
│   │                        WorkflowDefinition                                  │    │
│   │   - id, name, description, entityType, active                              │    │
│   │   - Defines the blueprint for a workflow (e.g., "OrderLifecycleWorkflow") │    │
│   └───────────────────────────┬────────────────────────────────────────────────┘    │
│                               │                                                     │
│          ┌────────────────────┼────────────────────┐                                │
│          ▼                    ▼                    ▼                                │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────────────┐                │
│   │WorkflowState │     │WorkflowState │     │ WorkflowTransition   │                │
│   │  - CREATED   │     │  - PAID      │     │  - fromState         │                │
│   │  - isInitial │     │  - isTerminal│     │  - toState           │                │
│   │  - color     │     │  - color     │     │  - allowedRoles      │                │
│   └──────────────┘     └──────────────┘     │  - requiresComment   │                │
│                                             │  - actionName        │                │
│                                             └──────────────────────┘                │
│                                                                                     │
│   ┌────────────────────────────────────────────────────────────────────────────┐    │
│   │                        WorkflowInstance                                    │    │
│   │   - id, workflowId, entityType, entityId, currentStateId, isCompleted     │    │
│   │   - Runtime instance tracking a specific entity through its lifecycle      │    │
│   └───────────────────────────┬────────────────────────────────────────────────┘    │
│                               │                                                     │
│                               ▼                                                     │
│   ┌────────────────────────────────────────────────────────────────────────────┐    │
│   │                          WorkflowLog                                       │    │
│   │   - id, instanceId, fromState, toState, actor, actorRole, comment, timestamp│   │
│   │   - Immutable audit record of every state transition                       │    │
│   └────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### State Transition Flow

```java
/**
 * Transition execution sequence:
 * 
 * 1. Load workflow instance
 * 2. Validate instance is not completed
 * 3. Validate target state exists in workflow definition
 * 4. Validate transition is defined (fromState → toState)
 * 5. Check role authorization (allowedRoles contains actorRole)
 * 6. Check comment requirement (if transition.requiresComment)
 * 7. Execute business rule validation (OrderWorkflowRuleValidator)
 * 8. Update instance.currentState
 * 9. If terminal state, mark instance as completed
 * 10. Persist WorkflowLog entry
 * 11. Emit domain event (async)
 */
public WorkflowInstanceDTO transition(Long instanceId, String targetState, 
                                       String actor, String actorRole, String comment)
```

### Business Rule Validation

The `OrderWorkflowRuleValidator` enforces domain-specific invariants:

| Target State | Business Rule | Validation |
|--------------|---------------|------------|
| `PAID` | Payment must exist and be completed | Check `payments` table for `COMPLETED` status |
| `PROCESSING` | Order must be paid | Verify payment record exists |
| `SHIPPED` | Shipping record must exist | Check `shipping` table |
| `DELIVERED` | Shipment must be in transit | Verify shipping status |
| `REFUNDED` | Must be in refundable state | Check current state is `PAID`, `PROCESSING`, or `DELIVERED` |

```java
// Example: Cannot transition to PAID without completed payment
private void validatePaymentExists(Long orderId) {
    Optional<Payment> payment = paymentRepository.findByOrder(order);
    
    if (payment.isEmpty()) {
        throw new BusinessRuleViolationException(
            "NO_PAYMENT_RECORD", "PAID",
            "Cannot mark order as PAID: No payment record exists.");
    }
    
    if (!isPaymentCompleted(payment.get().getPaymentStatus())) {
        throw new BusinessRuleViolationException(
            "PAYMENT_NOT_COMPLETED", "PAID",
            "Payment status is '" + status + "'. Must be COMPLETED first.");
    }
}
```

---

## Operational Modules

The system manages the following domain entities through the workflow engine. Each module represents an **operational domain** rather than a storefront feature.

| Module | Purpose | Workflow Integration |
|--------|---------|---------------------|
| **Order Management** | Transaction lifecycle orchestration | Primary workflow entity with full state machine |
| **Payment Management** | Payment processing and reconciliation | Triggers `PAYMENT_PENDING → PAID` transition |
| **Shipping Management** | Fulfillment pipeline tracking | Sequential status flow: `Shipped → In Transit → Delivered` |
| **Category Management** | Product taxonomy operations | Administrative operations |
| **Product Management** | Inventory and catalog operations | Administrative operations |
| **Customer Management** | Account lifecycle operations | User provisioning and RBAC |
| **Cart Management** | Session state management | Pre-order operations |
| **Wishlist Management** | Customer preference tracking | Analytics operations |
| **Review Management** | Content moderation pipeline | Rating aggregation |
| **Coupon Management** | Promotion lifecycle operations | Discount rule engine |

### Module Architecture

Each operational module follows a consistent layered pattern:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Controller    │ ──▶ │    Service      │ ──▶ │   Repository    │
│   (REST API)    │     │ (Business Logic)│     │   (JPA/SQL)     │
└─────────────────┘     └────────┬────────┘     └─────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │ WorkflowIntegration │
                        │    Service          │
                        └─────────────────┘
```

---

## Technology Stack

### Backend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Runtime** | Java | 17 LTS | Core platform |
| **Framework** | Spring Boot | 3.2.2 | Application framework |
| **Security** | Spring Security | 6.x | Authentication & authorization |
| **JWT** | jjwt | 0.11.5 | Token-based authentication |
| **ORM** | Spring Data JPA / Hibernate | 6.x | Object-relational mapping |
| **Database** | MySQL / PostgreSQL | 8.x / 15.x | Relational persistence |
| **Connection Pool** | HikariCP | 5.x | High-performance connection pooling |
| **API Docs** | springdoc-openapi | 2.3.0 | OpenAPI 3.0 documentation |
| **Monitoring** | Spring Actuator | 3.2.x | Health checks and metrics |
| **Validation** | Jakarta Validation | 3.0 | Request/entity validation |

### Frontend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Framework** | React | 19.x | UI component framework |
| **Build Tool** | Vite | 6.x | Fast development server |
| **Styling** | Bootstrap | 5.3.x | CSS framework |
| **HTTP Client** | Axios | 1.x | REST API client |
| **Routing** | React Router | 7.x | Client-side routing |

### Infrastructure

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend Hosting** | Render | Container deployment |
| **Frontend Hosting** | Vercel | Static site deployment |
| **Database** | Render PostgreSQL / Local MySQL | Managed database |

---

## Database Architecture

### Schema Overview

```sql
-- Workflow Engine Tables (Domain-Independent)
┌──────────────────────────────────────────────────────────────────────────────┐
│  workflow_definitions    │  Workflow blueprints (OrderLifecycle, Payment)   │
│  workflow_states         │  Valid states within each workflow               │
│  workflow_transitions    │  Allowed state-to-state transitions with roles   │
│  workflow_instances      │  Active workflow executions per entity           │
│  workflow_logs           │  Immutable audit trail of all state changes      │
└──────────────────────────────────────────────────────────────────────────────┘

-- Domain Entity Tables
┌──────────────────────────────────────────────────────────────────────────────┐
│  orders / order_items    │  Transaction records                             │
│  payments                │  Payment processing records                      │
│  shipping                │  Fulfillment tracking                            │
│  products / categories   │  Catalog data                                    │
│  users / roles           │  Identity and access control                     │
│  cart / cart_items       │  Session state                                   │
│  wishlists               │  Customer preferences                            │
│  reviews                 │  Customer feedback                               │
│  coupons                 │  Promotion rules                                 │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Entity Relationships

```
WorkflowDefinition (1) ◀─────────────────────────────(N) WorkflowState
WorkflowDefinition (1) ◀─────────────────────────────(N) WorkflowTransition
WorkflowDefinition (1) ◀─────────────────────────────(N) WorkflowInstance
WorkflowInstance   (1) ◀─────────────────────────────(N) WorkflowLog
WorkflowTransition (N) ─── fromState ───────────────▶(1) WorkflowState
WorkflowTransition (N) ─── toState ─────────────────▶(1) WorkflowState

Order              (1) ◀───── entityId (ORDER) ─────(0-1) WorkflowInstance
Payment            (N) ◀───────────────────────────────(1) Order
Shipping           (N) ◀───────────────────────────────(1) Order
OrderItem          (N) ────────────────────────────────(1) Order
Order              (N) ────────────────────────────────(1) User
```

### Database Indexes

The schema includes strategic indexes for workflow query performance:

```sql
-- WorkflowInstance indexes
CREATE INDEX idx_instance_workflow ON workflow_instances(workflow_id);
CREATE INDEX idx_instance_entity ON workflow_instances(entity_type, entity_id);
CREATE INDEX idx_instance_state ON workflow_instances(current_state_id);
CREATE INDEX idx_instance_created ON workflow_instances(created_at);

-- WorkflowLog indexes
CREATE INDEX idx_log_instance ON workflow_logs(workflow_instance_id);
CREATE INDEX idx_log_timestamp ON workflow_logs(timestamp);
```

### Connection Pool Configuration

```properties
# HikariCP Production Settings
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000
```

---

## Security Model

### Authentication Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │ ──▶ │  /api/auth  │ ──▶ │ UserDetails │ ──▶ │   JWT       │
│   Login     │     │  /signin    │     │   Service   │     │   Token     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                          ┌────────────────────────────────────────┘
                          ▼
              ┌─────────────────────────┐
              │  Authorization Header   │
              │  Bearer <jwt_token>     │
              └─────────────────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │  JwtAuthTokenFilter     │
              │  - Validate token       │
              │  - Extract claims       │
              │  - Set SecurityContext  │
              └─────────────────────────┘
```

### Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| `ROLE_USER` | View own orders, create orders, update profile, view workflow status |
| `ROLE_ADMIN` | All user permissions + manage all entities, execute workflow transitions, view audit logs, access operations dashboard |

### Workflow Transition Authorization

Each workflow transition specifies which roles are allowed to execute it:

```java
// Example: Only ADMIN can transition to REFUNDED
WorkflowTransition refundTransition = new WorkflowTransition(
    workflow, paidState, refundedState,
    "Refund Order", "ROLE_ADMIN",  // Only admins can refund
    true  // Requires comment
);
```

### JWT Configuration

```properties
workflow.app.jwtSecret=${JWT_SECRET:...}
workflow.app.jwtExpirationMs=${JWT_EXPIRATION_MS:86400000}  # 24 hours
```

---

## Operations Dashboard

The Operations Dashboard is an **internal console** for platform administrators to monitor and manage workflow operations.

### Dashboard Capabilities

| Feature | Description |
|---------|-------------|
| **Workflow Statistics** | Real-time counts by workflow state, completion rates |
| **Active Instances** | Table of all in-progress workflow executions |
| **Instance Details** | Visual timeline of state transitions with audit data |
| **Transition Actions** | Execute allowed state transitions with comments |
| **Audit Log Search** | Filter and search historical workflow events |
| **Entity Management** | CRUD operations for all operational modules |
| **System Health** | Actuator endpoints for monitoring |

### Visual Timeline Component

The workflow details page displays a vertical timeline showing:

- Current state (highlighted)
- Completed states (checkmarks)
- State transition timestamps
- Actor and role for each transition
- Comments and contextual data

```
    ○ CREATED
    │   Created by: customer@email.com
    │   2024-03-07 10:15:23
    │
    ○ PAYMENT_PENDING
    │   Action: Checkout Initiated
    │   2024-03-07 10:15:24
    │
    ● PAID  ← Current State
    │   Action: Payment Confirmed
    │   Actor: payment-gateway (SYSTEM)
    │   2024-03-07 10:16:01
    │
    ○ PROCESSING (pending)
    ○ SHIPPED (pending)
    ○ DELIVERED (pending)
```

---

## Example Workflow Lifecycle

### Order Lifecycle State Machine

```
                                    ┌─────────────┐
                                    │   CREATED   │ (Initial State)
                                    └──────┬──────┘
                                           │ Customer initiates checkout
                                           ▼
                              ┌────────────────────────┐
                              │    PAYMENT_PENDING     │
                              └───────────┬────────────┘
                    Payment failed        │              Payment completed
                         ┌────────────────┼────────────────────┐
                         ▼                ▼                    │
                  ┌─────────────┐  ┌─────────────┐            │
                  │  CANCELLED  │  │    PAID     │◀───────────┘
                  │  (Terminal) │  └──────┬──────┘
                  └─────────────┘         │ Admin starts processing
                                          ▼
                              ┌────────────────────────┐
                              │      PROCESSING        │
                              └───────────┬────────────┘
                                          │ Shipping created
                                          ▼
                              ┌────────────────────────┐
                              │        SHIPPED         │
                              └───────────┬────────────┘
                    Returned/Issue        │              Delivery confirmed
                         ┌────────────────┼────────────────────┐
                         ▼                                     ▼
                  ┌─────────────┐                     ┌─────────────┐
                  │  REFUNDED   │                     │  DELIVERED  │
                  │  (Terminal) │                     │  (Terminal) │
                  └─────────────┘                     └─────────────┘
```

### Transition Rules

| From State | To State | Allowed Roles | Business Rule |
|------------|----------|---------------|---------------|
| CREATED | PAYMENT_PENDING | USER, ADMIN | Automatic on checkout |
| PAYMENT_PENDING | PAID | SYSTEM, ADMIN | Payment record must exist with COMPLETED status |
| PAYMENT_PENDING | CANCELLED | USER, ADMIN | Optional: requires comment |
| PAID | PROCESSING | ADMIN | Payment must be confirmed |
| PROCESSING | SHIPPED | ADMIN | Shipping record must exist |
| SHIPPED | DELIVERED | ADMIN | Shipping status must be "Delivered" |
| PAID, PROCESSING, DELIVERED | REFUNDED | ADMIN | Requires comment |

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PRODUCTION DEPLOYMENT                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                           VERCEL (Frontend)                             │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │  React SPA                                                      │   │   │
│   │   │  - Static assets served via CDN                                 │   │   │
│   │   │  - Environment: VITE_API_URL=https://api.render.com             │   │   │
│   │   └─────────────────────────────────────────────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                        │
│                                        │ HTTPS                                  │
│                                        ▼                                        │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                           RENDER (Backend)                              │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │  Spring Boot Application                                        │   │   │
│   │   │  - Docker container                                             │   │   │
│   │   │  - Auto-scaling enabled                                         │   │   │
│   │   │  - Health check: /actuator/health                               │   │   │
│   │   └─────────────────────────────────────────────────────────────────┘   │   │
│   │                                    │                                    │   │
│   │                                    │ JDBC                               │   │
│   │                                    ▼                                    │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │  PostgreSQL (Render Managed)                                    │   │   │
│   │   │  - Automated backups                                            │   │   │
│   │   │  - Connection pooling via HikariCP                              │   │   │
│   │   └─────────────────────────────────────────────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Deployment Files

**Backend (render.yaml)**
```yaml
services:
  - type: web
    name: flowforge-api
    env: docker
    dockerfilePath: ./Backend/Dockerfile
    envVars:
      - key: DB_URL
        fromDatabase:
          name: workflow-db
          property: connectionString
      - key: JWT_SECRET
        generateValue: true
```

**Frontend (vercel.json)**
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/" }],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" }
      ]
    }
  ]
}
```

---

## Running Locally

### Prerequisites

- **Java 17+** (OpenJDK or Oracle JDK)
- **Node.js 18+** (with npm)
- **MySQL 8+** or **PostgreSQL 15+**
- **Maven 3.8+** (or use included wrapper)

### Backend Setup

```bash
# 1. Clone repository
git clone https://github.com/your-org/flowforge.git
cd flowforge

# 2. Configure database connection
# Edit Backend/src/main/resources/application.properties
# Or set environment variables:
export DB_URL=jdbc:mysql://localhost:3306/workflow_commerce
export DB_USERNAME=root
export DB_PASSWORD=your_password

# 3. Start backend
cd Backend
./mvnw spring-boot:run

# Backend will be available at http://localhost:8080
# Swagger UI: http://localhost:8080/swagger-ui.html
# Health check: http://localhost:8080/actuator/health
```

### Frontend Setup

```bash
# 1. Install dependencies
cd Frontend
npm install

# 2. Configure API endpoint
# Create .env file:
echo "VITE_API_URL=http://localhost:8080/api" > .env

# 3. Start development server
npm run dev

# Frontend will be available at http://localhost:5173
```

### Default Credentials

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | ROLE_ADMIN |
| `user` | `user123` | ROLE_USER |

---

## API Reference

### Workflow Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/workflow/definitions` | List all workflow definitions |
| `GET` | `/api/workflow/definitions/{name}` | Get workflow by name with states/transitions |
| `GET` | `/api/workflow/definitions/{id}/stats` | Get workflow statistics |
| `GET` | `/api/workflow/instances` | List all active workflow instances |
| `GET` | `/api/workflow/instances/{id}` | Get instance details with logs |
| `GET` | `/api/workflow/instances/{id}/transitions` | Get allowed transitions for user role |
| `POST` | `/api/workflow/instances/{id}/transition` | Execute state transition |
| `GET` | `/api/workflow/instances/entity/{type}/{id}` | Get instance by entity |
| `GET` | `/api/workflow/logs/recent` | Get recent audit log entries |
| `POST` | `/api/workflow/migrate/orders` | Create workflow instances for legacy orders |

### Example: Execute Transition

```bash
curl -X POST 'http://localhost:8080/api/workflow/instances/1/transition' \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "targetState": "PROCESSING",
    "comment": "Payment verified, starting fulfillment"
  }'
```

### Response

```json
{
  "id": 1,
  "workflowName": "OrderLifecycleWorkflow",
  "entityType": "ORDER",
  "entityId": 42,
  "currentState": {
    "stateName": "PROCESSING",
    "displayName": "Processing",
    "color": "#17a2b8"
  },
  "isCompleted": false,
  "allowedTransitions": [
    {
      "actionName": "Ship Order",
      "toStateName": "SHIPPED"
    }
  ],
  "logs": [...]
}
```

---

## Future Improvements

### Planned Enhancements

| Category | Enhancement | Description |
|----------|-------------|-------------|
| **Workflow Engine** | Parallel States | Support for concurrent state branches |
| **Workflow Engine** | Conditional Transitions | Rule-based automatic transitions |
| **Workflow Engine** | Timer Events | Scheduled state changes (e.g., auto-cancel after 24h) |
| **Observability** | Distributed Tracing | OpenTelemetry integration |
| **Observability** | Metrics Dashboard | Prometheus + Grafana |
| **Scalability** | Event Sourcing | Full event-driven architecture |
| **Scalability** | Message Queue | Kafka/RabbitMQ for async processing |
| **Security** | OAuth2/OIDC | External identity provider support |
| **Operations** | Workflow Designer UI | Visual workflow definition editor |
| **Operations** | SLA Monitoring | Track workflow completion times |

### Technical Debt

- [ ] Add comprehensive integration tests for workflow transitions
- [ ] Implement cache invalidation for workflow definition updates
- [ ] Add request correlation IDs for distributed tracing
- [ ] Implement rate limiting per endpoint
- [ ] Add database migration tool (Flyway/Liquibase)

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/workflow-timers`)
3. Commit changes (`git commit -m 'Add timer-based transitions'`)
4. Push to branch (`git push origin feature/workflow-timers`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License.

---

<p align="center">
  <strong>FlowForge</strong><br>
  Enterprise-grade workflow orchestration for transactional lifecycle management
</p>
