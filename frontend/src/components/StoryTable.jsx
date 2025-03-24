import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getAllStories } from '../api/storiesApi';

function StoryTable() {
    const [stories, setStories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchStories = async () => {
            try {
                const data = await getAllStories();
                setStories(Array.isArray(data) ? data : []);
                setLoading(false);
            } catch (err) {
                setError('Failed to load stories. Please try again later.');
                setLoading(false);
            }
        };

        fetchStories();
    }, []);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>{error}</div>;

    return (
        <div>
            <h2>Stories</h2>
            <Link to="/create">Create New Story</Link>
            {stories.length === 0 ? (
                <p>No stories available</p>
            ) : (
                <table style={tableStyle}>
                    <thead>
                        <tr>
                            <th style={thStyle}>ID</th>
                            <th style={thStyle}>Title</th>
                            <th style={thStyle}>Content</th>
                            <th style={thStyle}>Department</th>
                            <th style={thStyle}>Created At</th>
                            <th style={thStyle}>Updated At</th>
                            <th style={thStyle}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {stories.map((story) => (
                            <tr key={story.id} style={trStyle}>
                                <td style={tdStyle}>{story.id}</td>
                                <td style={tdStyle}>{story.title}</td>
                                <td style={tdStyle}>{story.content}</td>
                                <td style={tdStyle}>{story.department}</td>
                                <td style={tdStyle}>{new Date(story.createdAt).toLocaleString()}</td>
                                <td style={tdStyle}>{new Date(story.updatedAt).toLocaleString()}</td>
                                <td style={tdStyle}>
                                    <Link to={`/story/${story.id}`} style={linkStyle}>View</Link>{' '}
                                    <Link to={`/story/${story.id}/edit`} style={linkStyle}>Edit</Link>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

// Basic inline styles (you can move these to a CSS file)
const tableStyle = {
    width: '100%',
    borderCollapse: 'collapse',
    marginTop: '20px',
};

const thStyle = {
    border: '1px solid #ddd',
    padding: '8px',
    backgroundColor: '#f2f2f2',
    textAlign: 'left',
};

const tdStyle = {
    border: '1px solid #ddd',
    padding: '8px',
};

const trStyle = {
    '&:hover': { backgroundColor: '#f5f5f5' }, // Note: Hover won't work with inline styles; use CSS for this
};

const linkStyle = {
    marginRight: '10px',
    textDecoration: 'none',
    color: '#007bff',
};

export default StoryTable;