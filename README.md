# Workflow / State-Machine-Driven Commerce System

A production-grade full-stack commerce system where all order actions are governed by an explicit state machine.

## 🚀 Features (Task 1 Complete)
- **Secure Authentication**: JWT-based login and registration.
- **Role-Based Access Control (RBAC)**: Distinct permissions for `USER` and `ADMIN`.
- **Dual Database Support**: Seemless transition from local MySQL to production PostgreSQL.
- **Responsive UI**: Built with React and Bootstrap 5.

## 🛠️ Technology Stack
- **Frontend**: React 18, Axios, React Router, Bootstrap.
- **Backend**: Java 17, Spring Boot 3.2, Spring Security, Hibernate.
- **Database**: PostgreSQL (Production), MySQL (Local).
- **Deployment**: Render (Backend), Vercel (Frontend).

## 📂 Project Structure
- `/Backend`: Spring Boot application.
- `/Frontend`: React application.

## ⚙️ Setup & Installation

### Backend
1. Configure `.env` with your DB credentials.
2. Run `./mvnw spring-boot:run`.

### Frontend
1. Run `npm install`.
2. Run `npm run dev`.

---
*This project is part of a full-stack internship module.*
