import { useEffect } from 'react'
import { Routes, Route } from 'react-router-dom'
import { Login } from './pages/login'
import { Register } from './pages/register'

// Import filesystem namespace
import { filesystem } from "@neutralinojs/lib"

function App() {
  useEffect(() => {
    filesystem.readDirectory('./').then((data) => {
      console.log(data)
    }).catch((err) => {
      console.log(err)
    })
  }, [])

  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/register" element={<Register />} />
      </Routes>
    </div>
  );
}

export default App;