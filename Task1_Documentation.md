# End-User Documentation: Module-1 (Category Management)

## 1. Introduction
The Category Management module is the foundation of the Workflow Commerce System. It allows administrators to organize products into logical groups. This module includes robust security features, ensuring that only authorized administrators can modify the catalog structure.

## 2. Admin Features

### 2.1 Admin Login
To access category management, you must log in with an **ADMIN** account.
1. Navigate to the **Login** page.
2. Enter your Admin credentials.
3. Upon successful login, the **"Category Management"** link will appear in the navigation bar.

### 2.2 Category Dashboard
The Category Dashboard provides a comprehensive view of all categories in the system.
- **View Categories:** See the name, description, and current status (Active/Inactive) of all categories.
- **Search/Browse:** Categories are listed in a clear, responsive table format.

### 2.3 Create a New Category
1. Click the **"Add New Category"** button on the dashboard.
2. Enter a unique **Category Name**.
3. Provide a **Description** (optional, up to 300 characters).
4. Click **"Create"**.
*Validation: The system will prevent duplicate category names to maintain data integrity.*

### 2.4 Edit an Existing Category
1. Find the category you wish to modify in the dashboard list.
2. Click the **"Edit"** button.
3. Update the name or description in the popup form.
4. Click **"Save Changes"**.

### 2.5 Deactivate Category (Soft Delete)
The system uses a soft delete policy. Categories are never permanently removed from the database but are marked as **Inactive**.
1. Click the **"Deactivate"** button next to an active category.
2. **Warning Message:** A confirmation dialog will appear: *"Please assign products to another category before deactivating. Are you sure?"*
3. Click **OK** to confirm.
4. The category status will change to **Inactive**, and it will be disabled for future product assignments.

## 3. Security and Roles
- **Admin Role:** Full access to Create, Read, Update, and Deactivate categories.
- **User Role:** Can view the home page but cannot see or access the Category Management dashboard.
- **Unauthorized Access:** Any attempt to access `/api/categories` via API without an Admin token will result in a `403 Forbidden` error.

## 4. Technical Specifications
- **Base Backend URL:** `https://workflow-commerce-system.onrender.com`
- **Base Frontend URL:** `https://workflow-commerce-system.vercel.app/`
- **Soft Delete:** Implemented via the `status` column in the database.

---
*Note: Product assignment and order management are planned for future modules.*
