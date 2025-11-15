import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function App() {
  const [list, setList] = useState([]);
  useEffect(() => {
    axios.get(`${import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000'}/api/exhibitions`)
      .then(r => setList(r.data))
      .catch(err => console.warn(err));
  }, []);
  return (
    <div style={{ padding: 20 }}>
      <h1>Exhibitions</h1>
      {list.map(e => <div key={e.id}><strong>{e.title}</strong> — {e.venue}</div>)}
    </div>
  );
}
