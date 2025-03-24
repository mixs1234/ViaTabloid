import React from 'react'
import StoryTable from '../components/StoryTable'
import { getConnectionInfo } from '../api/storiesApi'

const HomePage = () => {
    return (
        <div>
            <h1>ViaTabloid</h1>
            <p>Welcome to ViaTabloid, a simple web application to manage stories.</p>
            <StoryTable />

            <p>Connection String</p>
            <p>{getConnectionInfo()}</p>
        </div>
    )
}

export default HomePage