import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import { AuthProvider } from './context/AuthProvider'
import './index.css'

const container = document.getElementById('root')
if (!container) throw new Error('Root container missing')
const root = ReactDOM.createRoot(container)

root.render(
    <React.StrictMode>
        <AuthProvider>
            <BrowserRouter>
                <App />
            </BrowserRouter>
        </AuthProvider>
    </React.StrictMode>
)
