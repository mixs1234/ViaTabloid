import axios from 'axios';

// Base URL constructed from environment variables
const API_HOST = import.meta.env.VITE_API_HOST || 'localhost';
const API_PORT = import.meta.env.VITE_API_PORT || '8080';
const BASE_URL = `http://${API_HOST}:${API_PORT}/api/stories`;

// Create an axios instance with default config
const apiClient = axios.create({
    baseURL: BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// API helper functions
export const getAllStories = async () => {
    try {
        const response = await apiClient.get('/');
        return response.data; // Returns array of stories
    } catch (error) {
        console.error('Error fetching stories:', error);
        throw error; // Let the caller handle the error
    }
};

export const getStoryById = async (id) => {
    try {
        const response = await apiClient.get(`/${id}`);
        return response.data; // Returns single story
    } catch (error) {
        console.error(`Error fetching story with id ${id}:`, error);
        throw error;
    }
};

export const createStory = async (storyData) => {
    try {
        const response = await apiClient.post('/', storyData);
        return response.data; // Returns created story
    } catch (error) {
        console.error('Error creating story:', error);
        throw error;
    }
};

export const updateStory = async (id, storyData) => {
    try {
        await apiClient.put(`/${id}`, storyData);
        // No content returned, so return nothing or a success indicator if needed
    } catch (error) {
        console.error(`Error updating story with id ${id}:`, error);
        throw error;
    }
};

export const deleteStory = async (id) => {
    try {
        await apiClient.delete(`/${id}`);
        // No content returned
    } catch (error) {
        console.error(`Error deleting story with id ${id}:`, error);
        throw error;
    }
};

export const getConnectionInfo = () => {
    return `http://${API_HOST}:${API_PORT}`;
}