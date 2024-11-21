import { useEffect } from 'react'
import { Routes, Route } from 'react-router-dom'
import { Login } from './pages/login'
import { Register } from './pages/register'

// Import filesystem namespace
import { filesystem } from "@neutralinojs/lib"
import { Home } from './pages/home'

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
        <Route path='/home' element={<Home />} />
      </Routes>
    </div>
  );
}

export default App;