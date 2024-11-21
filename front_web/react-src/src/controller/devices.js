import axios from 'axios';
import { deviceAPI, userAPI } from './api';

export const getDevice = async ( deviceId ) => {
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

export const getDevicesUser = async ( userId ) => {
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