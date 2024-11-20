import axios from "axios";
import { userAPI } from "./api";

export const login = async (username, password) => {
    try {
        const response = await axios.post(`${userAPI}login`, { username, password });
        return response.data;
    } catch (error) {
        return error.response.data;
    }
}

export const register = async (username, email, password, confirm) => {
    if (!username || !email || !password || !confirm) {
        return { error: 'Por favor complete todos los campos' };
    }

    if (password !== confirm) {
        return { error: 'Las contraseñas no coinciden' };
    }

    try {
        const response = await axios.post(`${userAPI}`, { username, email, password, confirm, tokenPhone: '' });
        return response.data;
    } catch (error) {
        return error.response.data;
    }
}