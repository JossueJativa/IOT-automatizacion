import axios from "axios";
import { homeAssistantAPI, deviceAPI } from "./api";

export const getHomeAssistant = async ( deviceId ) => {
    try {
        const response = await axios.get(
            `${deviceAPI}${deviceId}/`,
            { headers: { 'Content-Type': 'application/json' } }
        );
        const data = response.data;
        return data['device']['homeassistant'];
    } catch (error) {
        return error.response.data;
    }
}

export const createHomeAssistant = async (  url, token ) => {
    try {
        const response = await axios.post(
            `${homeAssistantAPI}`,
            { url, token },
            { headers: { 'Content-Type': 'application/json' } }
        );
        return response.data;
    } catch (error) {
        return error.response.data;
    }
}