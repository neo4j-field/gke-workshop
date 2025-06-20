import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function UserList() {
    const [users, setUsers] = useState([])

    useEffect(() => {
        axios.get('/users')
            .then(res => setUsers(res.data))
            .catch(err => console.error(err))
    }, [])

    const deleteAll = async () => {
        if (!window.confirm('Delete ALL users, roles, and databases?')) return
        try {
            await axios.delete('/users')
            setUsers([])
        } catch (err) {
            console.error(err)
            alert('Failed to delete all users')
        }
    }

    const deleteUser = async (u) => {
        if (!window.confirm(`Delete ${u.user} with role and DB?`)) return
        try {
            await axios.delete(`/user/${u.user}`)
            setUsers(prev => prev.filter(x => x.user !== u.user))
        } catch (err) {
            console.error(err)
            alert(`Failed to delete user ${u.user}`)
        }
    }

    return (
        <div className="space-y-4">
            <button
                onClick={deleteAll}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
            >
                Delete All Users
            </button>
            <h1 className="text-2xl font-bold">Users</h1>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {users.map(u => (
                    <div key={u.user} className="bg-white shadow rounded p-4 flex justify-between items-center">
                        <div>
                            <div className="font-semibold">{u.user}</div>
                            <div className="text-gray-600">DB: {u.database}</div>
                        </div>
                        <button
                            onClick={() => deleteUser(u)}
                            className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                        >
                            Delete
                        </button>
                    </div>
                ))}
            </div>
        </div>
    )
}
