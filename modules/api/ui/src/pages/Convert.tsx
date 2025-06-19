import React, { useState } from 'react'
import axios from 'axios'

export default function Convert() {
    const [file, setFile] = useState(null)
    const [data, setData] = useState(null)
    const [error, setError] = useState('')
    const [loading, setLoading] = useState(false)

    // handle file selection
    const handleFile = async (e) => {
        setError('')
        const f = e.target.files[0]
        if (!f) return
        try {
            const text = await f.text()
            const json = JSON.parse(text)
            if (!Array.isArray(json)) throw new Error('Expected JSON array')
            setData(json)
        } catch (err) {
            setError('Invalid JSON file')
            setData(null)
        }
    }

    const download = async (type) => {
        if (!data) return
        setLoading(true)
        try {
            if (type === 'application/json') {
                const blob = new Blob([JSON.stringify(data, null, 2)], { type })
                const url = URL.createObjectURL(blob)
                const link = document.createElement('a')
                link.href = url
                link.download = 'data.json'
                link.click()
            } else {
                const res = await axios.post('/export', JSON.stringify(data), {
                    headers: { Accept: type, 'Content-Type': 'application/json' },
                    responseType: 'blob'
                })
                const blob = new Blob([res.data], { type })
                const url = URL.createObjectURL(blob)
                const link = document.createElement('a')
                link.href = url
                link.download = `data.${type === 'application/pdf' ? 'pdf' : 'csv'}`
                link.click()
            }
        } catch {
            setError('Conversion failed')
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold">Convert User JSON to CSV / PDF</h1>
            {error && <div className="text-red-600">{error}</div>}
            <input type="file" accept="application/json" onChange={handleFile} />
            {data && (
                <div className="flex space-x-4">
                    <button
                        onClick={() => download('application/json')}
                        className="underline"
                        disabled={loading}
                    >
                        Download JSON
                    </button>
                    <button
                        onClick={() => download('text/csv')}
                        className="underline"
                        disabled={loading}
                    >
                        Download CSV
                    </button>
                    <button
                        onClick={() => download('application/pdf')}
                        className="underline"
                        disabled={loading}
                    >
                        Download PDF
                    </button>
                </div>
            )}
        </div>
    )
}
