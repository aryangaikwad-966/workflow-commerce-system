# Internship Assignment Submission: Module 1 (Category Management)

## 1. Github Repository Link
- [https://github.com/your-username/workflow-commerce-system](https://github.com/your-username/workflow-commerce-system)

## 2. URL of Module Hosted on Free Server
- **Backend (Render):** [https://workflow-commerce-system.onrender.com](https://workflow-commerce-system.onrender.com)
- **Frontend (Vercel):** [https://workflow-commerce-system.vercel.app](https://workflow-commerce-system.vercel.app)

## 3. End User Documentation for Module 1

### Introduction
The Category Management module is the foundation of the Workflow Commerce System. It allows administrators to organize products into logical groups. This module includes robust security features, ensuring that only authorized administrators can modify the catalog structure.

### Admin Features
- **Admin Login:** Log in with an ADMIN account to access category management.
- **Category Dashboard:** View, search, and browse all categories in a responsive table.
- **Create Category:** Add new categories with unique names and optional descriptions.
- **Edit Category:** Update category name or description.
- **Deactivate Category:** Soft delete (mark as inactive) with confirmation and warning.

### Security and Roles
- **Admin Role:** Full access to create, read, update, and deactivate categories.
- **User Role:** Can view the home page but cannot access category management.
- **Unauthorized Access:** API access to `/api/categories` without an admin token returns 403 Forbidden.

### Technical Details
- **Backend:** Spring Boot, JWT Auth, MySQL/PostgreSQL, Docker.
- **Frontend:** React, Vite, Bootstrap, Role-based UI.
- **Soft Delete:** Implemented via the `status` column in the database.

### How to Use
1. Register a new user or log in as admin.
2. Access the Category Management dashboard from the navigation bar.
3. Add, edit, or deactivate categories as needed.
4. Only admins can manage categories; users have restricted access.

### Deployment
- Backend and frontend are deployed on free cloud services (Render, Vercel).
- All code is available on Github for review.

---
*For screenshots and step-by-step usage, see the attached documentation or visit the live demo links above.*

---

**Prepared by:** [Your Name]
**Date:** 8 February 2026

---

*This PDF is generated as part of the internship assignment submission for Module 1.*
