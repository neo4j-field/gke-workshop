import React, { useState } from 'react'
import axios from 'axios'

export default function CreateUsers() {
  const [count, setCount]   = useState(1)
  const [seedUri, setSeedUri] = useState('')
  const [append, setAppend] = useState(true)
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)

  const downloadBlob = (data, filename, type) => {
    const blob = new Blob([data], { type })
    const url  = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href   = url
    link.download = filename
    link.click()
  }

  // Create → JSON → download + store
  const create = async () => {
    if (!append && !window.confirm('Existing users may be overwritten. Continue?')) return
    setLoading(true)
    try {
      const payload = { count, seed_uri: seedUri, append }
      const { data } = await axios.post('/users', payload)
      setResults(data)
      // auto-download JSON
      downloadBlob(JSON.stringify(data, null, 2), 'users.json', 'application/json')
    } catch (err) {
      console.error(err)
      alert('Error creating users')
    } finally {
      setLoading(false)
    }
  }

  // only CSV/PDF now
  const download = async (type) => {
    if (!results.length) return
    setLoading(true)
    try {
      const res = await axios.post(
          '/export',
          JSON.stringify(results),
          {
            headers: { Accept: type, 'Content-Type': 'application/json' },
            responseType: 'blob'
          }
      )
      downloadBlob(res.data, `users.${type==='application/pdf'?'pdf':'csv'}`, type)
    } catch {
      alert('Error downloading file')
    } finally {
      setLoading(false)
    }
  }

  return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold">Create Users</h1>
        <div className="flex items-center space-x-4">
          <label className="font-medium">Count:</label>
          <input
              type="number" min={1} value={count}
              onChange={e => setCount(+e.target.value)}
              className="border rounded px-2 py-1 w-20"
          />
          <label className="font-medium">Seed URI:</label>
          <input
              type="text" value={seedUri}
              onChange={e => setSeedUri(e.target.value)}
              placeholder="optional"
              className="border rounded px-2 py-1 flex-1"
          />
          <label className="flex items-center space-x-1">
            <input
                type="checkbox" checked={append}
                onChange={() => setAppend(a => !a)}
                className="form-checkbox"
            />
            <span>Append</span>
          </label>
          <button
              onClick={create} disabled={loading}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Creating...' : 'Create'}
          </button>
        </div>

        {results.length > 0 && (
            <>
              <div className="flex space-x-4">
                <button onClick={() => download('text/csv')} className="underline">Download CSV</button>
                <button onClick={() => download('application/pdf')} className="underline">Download PDF</button>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {results.map(r => (
                    <div key={r.user} className="bg-white shadow rounded p-4">
                      <div className="font-semibold">{r.user}</div>
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
