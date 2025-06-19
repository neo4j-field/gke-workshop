import React from 'react'
import { Routes, Route, Link, Navigate } from 'react-router-dom'
import CreateUsers from './pages/CreateUsers'
import UserList from './pages/UserList'
import Login from './pages/Login'
import { useAuth } from './context/AuthProvider'

export default function App() {
    const { token, logout } = useAuth()
    return (
        <div className="min-h-screen bg-gray-100">
            <header className="bg-white shadow">
                <nav className="container mx-auto px-4 py-4 flex space-x-6">
                    {token ? (
                        <>
                            <Link to="/" className="text-lg font-semibold text-gray-700 hover:text-blue-500">
                                Create Users
                            </Link>
                            <Link to="/users" className="text-lg font-semibold text-gray-700 hover:text-blue-500">
                                Users
                            </Link>
                            <button onClick={logout} className="ml-auto text-red-500">
                                Logout
                            </button>
                        </>
                    ) : (
                        <Link to="/login" className="text-lg font-semibold text-gray-700 hover:text-blue-500">
                            Login
                        </Link>
                    )}
                </nav>
            </header>
            <main className="container mx-auto px-4 py-6">
                <Routes>
                    <Route path="/login" element={<Login />} />
                    <Route path="/" element={token ? <CreateUsers /> : <Navigate to="/login" />} />
                    <Route path="/users" element={token ? <UserList /> : <Navigate to="/login" />} />
                    <Route path="*" element={<Navigate to={token ? '/' : '/login'} />} />
                </Routes>
            </main>
        </div>
    )
}
