import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

// Mock axios before any imports
vi.mock('axios', () => ({
    default: {
        create: vi.fn()
    }
}))

// Mock import.meta.env
const mockImportMeta = {
    env: {
        VITE_API_HOST: 'localhost',
        VITE_API_PORT: '8080'
    }
}

vi.stubGlobal('import', { meta: mockImportMeta })

describe('API Client', () => {
    let mockAxiosInstance
    let mockedAxios

    beforeEach(async () => {
        // Reset modules to ensure fresh imports
        vi.resetModules()

        // Reset to default env vars
        mockImportMeta.env.VITE_API_HOST = 'localhost'
        mockImportMeta.env.VITE_API_PORT = '8080'

        // Import axios after reset
        const axios = await import('axios')
        mockedAxios = axios.default

        // Create mock axios instance
        mockAxiosInstance = {
            get: vi.fn(),
            post: vi.fn(),
            put: vi.fn(),
            delete: vi.fn()
        }

        // Mock axios.create to return our mock instance
        mockedAxios.create.mockReturnValue(mockAxiosInstance)

        // Clear all mocks before each test
        vi.clearAllMocks()

        // Mock console.error
        vi.spyOn(console, 'error').mockImplementation(() => { })
    })

    afterEach(() => {
        // Restore all mocks
        vi.restoreAllMocks()
    })

    describe('Axios instance configuration', () => {
        it('should create axios instance with correct base URL and headers', async () => {
            // Import the module to trigger axios.create call
            await import('./storiesApi')

            expect(mockedAxios.create).toHaveBeenCalledWith({
                baseURL: 'http://localhost:8080/api/stories',
                headers: {
                    'Content-Type': 'application/json',
                },
            })
        })

        it('should use default values when environment variables are undefined', async () => {
            // Set undefined environment variables
            delete mockImportMeta.env.VITE_API_HOST
            delete mockImportMeta.env.VITE_API_PORT

            // Import the module to trigger axios.create call
            await import('./storiesApi')

            expect(mockedAxios.create).toHaveBeenCalledWith({
                baseURL: 'http://localhost:8080/api/stories',
                headers: {
                    'Content-Type': 'application/json',
                },
            })
        })
    })

    describe('getAllStories', () => {
        it('should fetch all stories successfully', async () => {
            const mockStories = [
                { id: 1, title: 'Story 1', content: 'Content 1' },
                { id: 2, title: 'Story 2', content: 'Content 2' }
            ]

            mockAxiosInstance.get.mockResolvedValue({ data: mockStories })

            const { getAllStories } = await import('./storiesApi')
            const result = await getAllStories()

            expect(mockAxiosInstance.get).toHaveBeenCalledWith('/')
            expect(result).toEqual(mockStories)
        })

        it('should handle errors when fetching stories', async () => {
            const mockError = new Error('Network error')
            mockAxiosInstance.get.mockRejectedValue(mockError)

            const { getAllStories } = await import('./storiesApi')
            await expect(getAllStories()).rejects.toThrow('Network error')
            expect(console.error).toHaveBeenCalledWith('Error fetching stories:', mockError)
        })
    })

    describe('getStoryById', () => {
        it('should fetch story by id successfully', async () => {
            const mockStory = { id: 1, title: 'Story 1', content: 'Content 1' }
            const storyId = 1

            mockAxiosInstance.get.mockResolvedValue({ data: mockStory })

            const { getStoryById } = await import('./storiesApi')
            const result = await getStoryById(storyId)

            expect(mockAxiosInstance.get).toHaveBeenCalledWith('/1')
            expect(result).toEqual(mockStory)
        })

        it('should handle errors when fetching story by id', async () => {
            const mockError = new Error('Story not found')
            const storyId = 999
            mockAxiosInstance.get.mockRejectedValue(mockError)

            const { getStoryById } = await import('./storiesApi')
            await expect(getStoryById(storyId)).rejects.toThrow('Story not found')
            expect(console.error).toHaveBeenCalledWith('Error fetching story with id 999:', mockError)
        })
    })

    describe('createStory', () => {
        it('should create story successfully', async () => {
            const newStory = { title: 'New Story', content: 'New Content' }
            const createdStory = { id: 3, ...newStory }

            mockAxiosInstance.post.mockResolvedValue({ data: createdStory })

            const { createStory } = await import('./storiesApi')
            const result = await createStory(newStory)

            expect(mockAxiosInstance.post).toHaveBeenCalledWith('/', newStory)
            expect(result).toEqual(createdStory)
        })

        it('should handle errors when creating story', async () => {
            const newStory = { title: 'New Story', content: 'New Content' }
            const mockError = new Error('Validation error')
            mockAxiosInstance.post.mockRejectedValue(mockError)

            const { createStory } = await import('./storiesApi')
            await expect(createStory(newStory)).rejects.toThrow('Validation error')
            expect(console.error).toHaveBeenCalledWith('Error creating story:', mockError)
        })
    })

    describe('updateStory', () => {
        it('should update story successfully', async () => {
            const storyId = 1
            const updatedData = { title: 'Updated Story', content: 'Updated Content' }

            mockAxiosInstance.put.mockResolvedValue({})

            const { updateStory } = await import('./storiesApi')
            await updateStory(storyId, updatedData)

            expect(mockAxiosInstance.put).toHaveBeenCalledWith('/1', updatedData)
        })

        it('should handle errors when updating story', async () => {
            const storyId = 1
            const updatedData = { title: 'Updated Story', content: 'Updated Content' }
            const mockError = new Error('Update failed')
            mockAxiosInstance.put.mockRejectedValue(mockError)

            const { updateStory } = await import('./storiesApi')
            await expect(updateStory(storyId, updatedData)).rejects.toThrow('Update failed')
            expect(console.error).toHaveBeenCalledWith('Error updating story with id 1:', mockError)
        })
    })

    describe('deleteStory', () => {
        it('should delete story successfully', async () => {
            const storyId = 1

            mockAxiosInstance.delete.mockResolvedValue({})

            const { deleteStory } = await import('./storiesApi')
            await deleteStory(storyId)

            expect(mockAxiosInstance.delete).toHaveBeenCalledWith('/1')
        })

        it('should handle errors when deleting story', async () => {
            const storyId = 1
            const mockError = new Error('Delete failed')
            mockAxiosInstance.delete.mockRejectedValue(mockError)

            const { deleteStory } = await import('./storiesApi')
            await expect(deleteStory(storyId)).rejects.toThrow('Delete failed')
            expect(console.error).toHaveBeenCalledWith('Error deleting story with id 1:', mockError)
        })
    })

    describe('getConnectionInfo', () => {
        it('should return correct connection info with default values', async () => {
            const { getConnectionInfo } = await import('./storiesApi')
            const result = getConnectionInfo()

            expect(result).toBe('http://localhost:8080')
        })
    })
})

// Integration-style tests (optional)
describe('API Client Integration', () => {
    let mockAxiosInstance
    let mockedAxios

    beforeEach(async () => {
        vi.resetModules()

        const axios = await import('axios')
        mockedAxios = axios.default

        mockAxiosInstance = {
            get: vi.fn(),
            post: vi.fn(),
            put: vi.fn(),
            delete: vi.fn()
        }

        mockedAxios.create.mockReturnValue(mockAxiosInstance)
        vi.clearAllMocks()
    })

    it('should handle complete CRUD operations flow', async () => {
        // Mock responses for each operation
        const newStory = { title: 'Test Story', content: 'Test Content' }
        const createdStory = { id: 1, ...newStory }
        const updatedStory = { ...createdStory, title: 'Updated Title' }

        mockAxiosInstance.post.mockResolvedValueOnce({ data: createdStory })
        mockAxiosInstance.get.mockResolvedValueOnce({ data: createdStory })
        mockAxiosInstance.put.mockResolvedValueOnce({})
        mockAxiosInstance.delete.mockResolvedValueOnce({})

        // Import functions
        const { createStory, getStoryById, updateStory, deleteStory } = await import('./storiesApi')

        // Test the flow
        const created = await createStory(newStory)
        expect(created).toEqual(createdStory)

        const fetched = await getStoryById(1)
        expect(fetched).toEqual(createdStory)

        await updateStory(1, updatedStory)
        expect(mockAxiosInstance.put).toHaveBeenCalledWith('/1', updatedStory)

        await deleteStory(1)
        expect(mockAxiosInstance.delete).toHaveBeenCalledWith('/1')
    })
})