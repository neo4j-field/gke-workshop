// src/context/AuthProvider.tsx
import React, { createContext, useContext, useState } from 'react'
import axios from 'axios'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [token, setToken] = useState(localStorage.getItem('token') || '')
  const [error, setError] = useState('')

  const login = async (newToken) => {
    // Attempt to verify on the server first
    axios.defaults.headers.common['Authorization'] = `Bearer ${newToken}`
    try {
      await axios.post('/login', {})       // empty body
      // success!
      localStorage.setItem('token', newToken)
      setToken(newToken)
      setError('')
    } catch (e) {
      // invalid token
      delete axios.defaults.headers.common['Authorization']
      setError('Invalid token')
      throw e
    }
  }

  const logout = () => {
    localStorage.removeItem('token')
    delete axios.defaults.headers.common['Authorization']
    setToken('')
    setError('')
  }

  // On mount, if we have a token, set the header
  if (token && !axios.defaults.headers.common['Authorization']) {
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
  }

  return (
      <AuthContext.Provider value={{ token, login, logout, error }}>
        {children}
      </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
