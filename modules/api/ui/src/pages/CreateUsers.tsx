// src/pages/CreateUsers.tsx
import React, { useState } from 'react'
import axios from 'axios'

export default function CreateUsers() {
  const [count, setCount] = useState(1)
  const [seedUri, setSeedUri] = useState('')
  const [append, setAppend] = useState(true)
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)

  // Create users and always get JSON back
  const create = async () => {
    if (!append) {
      const msg = 'Existing users may be overwritten. Continue?'
      if (!window.confirm(msg)) return
    }
    setLoading(true)
    try {
      const payload = { count, seed_uri: seedUri, append }
      const { data } = await axios.post('/users', payload)
      setResults(data)
    } catch (err) {
      console.error(err)
      alert('Error creating users')
    } finally {
      setLoading(false)
    }
  }

  // Download in various formats by sending JSON to /export
  const download = async (type) => {
    if (!results.length) return
    const config = {
      headers: { Accept: type, 'Content-Type': 'application/json' },
      responseType: type === 'application/json' ? undefined : 'blob'
    }
    const body = JSON.stringify(results)
    try {
      if (type === 'application/json') {
        // direct JSON download
        const blob = new Blob([body], { type })
        const url = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = 'users.json'
        link.click()
      } else {
        // CSV or PDF via backend
        const res = await axios.post('/export', body, config)
        const blob = new Blob([res.data], { type })
        const url = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = `users.${type === 'application/pdf' ? 'pdf' : 'csv'}`
        link.click()
      }
    } catch (err) {
      console.error(err)
      alert('Error downloading file')
    }
  }

  return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold">Create Users</h1>
        <div className="flex flex-wrap items-center space-x-4">
          <label className="font-medium">Count:</label>
          <input
              type="number"
              min={1}
              value={count}
              onChange={e => setCount(Number(e.target.value))}
              className="border rounded px-2 py-1 w-20"
          />
          <label className="font-medium">Seed URI:</label>
          <input
              type="text"
              value={seedUri}
              onChange={e => setSeedUri(e.target.value)}
              placeholder="optional"
              className="border rounded px-2 py-1 flex-1"
          />
          <label className="flex items-center space-x-1">
            <input
                type="checkbox"
                checked={append}
                onChange={() => setAppend(a => !a)}
                className="form-checkbox"
            />
            <span>Append</span>
          </label>
          <button
              onClick={create}
              disabled={loading}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Creating...' : 'Create'}
          </button>
        </div>

        {results.length > 0 && (
            <>
              <div className="flex space-x-4">
                <button onClick={() => download('application/json')} className="underline">
                  Download JSON
                </button>
                <button onClick={() => download('text/csv')} className="underline">
                  Download CSV
                </button>
                <button onClick={() => download('application/pdf')} className="underline">
                  Download PDF
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {results.map(r => (
                    <div key={r.user} className="bg-white shadow rounded p-4">
                      <div className="font-semibold text-gray-800">{r.user}</div>
                      <div className="text-gray-600">{r.password}</div>
                      <div className="text-gray-600">{r.database}</div>
                    </div>
                ))}
              </div>
            </>
        )}
      </div>
  )
}
