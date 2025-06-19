// src/pages/Login.tsx
import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthProvider'

export default function Login() {
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [localError, setLocalError] = useState('')
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLocalError('')
    setLoading(true)
    try {
      // login() now performs the server check
      await login(input)
      navigate('/')
    } catch (err) {
      setLocalError('Invalid token')
    } finally {
      setLoading(false)
    }
  }

  return (
      <div className="max-w-md mx-auto mt-20 p-6 bg-white shadow rounded">
        <h1 className="text-xl font-bold mb-4">Login</h1>
        {localError && <div className="text-red-600 mb-4">{localError}</div>}
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
              type="text"
              placeholder="Enter token"
              value={input}
              onChange={e => setInput(e.target.value)}
              className="w-full border rounded px-3 py-2"
              required
          />
          <button
              type="submit"
              disabled={loading}
              className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700 disabled:opacity-50"
          >
            {loading ? 'Verifying...' : 'Login'}
          </button>
        </form>
      </div>
  )
}
