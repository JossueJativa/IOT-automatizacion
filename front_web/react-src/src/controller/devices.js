import axios from 'axios';
import { deviceAPI, deviceHistoryAPI, userAPI } from './api';

export const getDevice = async (deviceId) => {
    try {
        const response = await axios.get(
            `${deviceAPI}`,
            { headers: { 'Content-Type': 'application/json' } }
        );
        return response.data;
    } catch (error) {
        return error.response.data;
    }
}

export const getDevicesUser = async (userId) => {
    try {
        const response = await axios.get(
            `${userAPI}${userId}/`,
            { headers: { 'Content-Type': 'application/json' } }
        )
        const listDevices = response.data.devices;
        for (let i = 0; i < listDevices.length; i++) {
            const device = await getDevice(listDevices[i]);
            listDevices[i] = device;
        }
        return listDevices;
    } catch (error) {
        return error.response.data;
    }
}

export const getDeviceHistory = async (deviceId) => {
    try {
        const response = await axios.get(`${deviceAPI}${deviceId}/`);
        return response.data;
    } catch (error) {
        return { error: error.response.data };
    }
};

export const calculateEnergyCost = async (deviceId) => {
    try {
        const url = `${deviceAPI}generate_energy/?device_id=${deviceId}`;

        // Realizar la solicitud HTTP GET
        const response = await axios.get(url);

        if (response.status === 200) {
            const body = response.data;

            if (body.error) {
                return { error: 'Error al obtener el consumo de energía' };
            }

            const energyHour = body.energy_hour;
            const pricePerUnit = 0.15;
            let totalCost = 0;

            for (const hour in energyHour) {
                if (energyHour.hasOwnProperty(hour)) {
                    totalCost += energyHour[hour] * pricePerUnit;
                }
            }

            return {
                message: 'Costo de energía calculado con éxito',
                total_cost: totalCost,
                energy_hour: energyHour
            };
        } else {
            return { error: 'Error al obtener el dispositivo' };
        }
    } catch (error) {
        return { error: error.response?.data || 'Error desconocido' };
    }
};

export const getEnergy = async (deviceId) => {
    try {
        const response = await axios.get(`${deviceAPI}generate_energy/?device_id=${deviceId}`);
        return response.data;
    } catch (error) {
        return { error: error.response.data };
    }
};

export const updateHistory = async (deviceId, state, description) => {
    try {
        const response = await axios.post(`${deviceHistoryAPI}`, {
            state,
            description,
        });

        if (response.status === 201) {
            const historyId = response.data.id;
            const deviceResponse = await axios.get(`${deviceAPI}${deviceId}/`);
            const device = deviceResponse.data.device;
            const history = device.history || [];
            history.push(historyId);

            await axios.patch(`${deviceAPI}${deviceId}/`, {
                history,
            });

            return { success: "History updated successfully" };
        } else {
            return { error: "Error updating history" };
        }
    } catch (error) {
        return { error: error.response?.data || "Unknown error" };
    }
};