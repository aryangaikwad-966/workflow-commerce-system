import axios from "axios";
import authHeader from "./auth-header";

const API_URL = import.meta.env.VITE_API_URL || "https://workflow-commerce-system.onrender.com/api/auth/";
const CATEGORY_API_URL = API_URL.replace("/auth/", "/categories");

const getAllCategories = () => {
    console.log("DEBUG SERVICE: Requesting categories with headers:", authHeader());
    return axios.get(CATEGORY_API_URL, { headers: authHeader() })
        .catch(error => {
            console.error("DEBUG SERVICE: API Error Details:", {
                status: error.response?.status,
                headers: error.config?.headers,
                data: error.response?.data
            });
            throw error;
        });
};

const createCategory = (category_name, description) => {
    return axios.post(
        CATEGORY_API_URL,
        { category_name, description },
        { headers: authHeader() }
    );
};

const updateCategory = (id, category_name, description) => {
    return axios.put(
        CATEGORY_API_URL + "/" + id,
        { category_name, description },
        { headers: authHeader() }
    );
};

const deactivateCategory = (id) => {
    return axios.delete(CATEGORY_API_URL + "/" + id, { headers: authHeader() });
};

const CategoryService = {
    getAllCategories,
    createCategory,
    updateCategory,
    deactivateCategory,
};

export default CategoryService;
