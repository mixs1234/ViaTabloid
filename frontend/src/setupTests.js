import '@testing-library/jest-dom'
import { beforeAll, vi } from 'vitest'

beforeAll(() => {
    vi.stubGlobal('import', {
        meta: {
            env: {
                VITE_API_HOST: 'localhost',
                VITE_API_PORT: '8080'
            }
        }
    })
})

