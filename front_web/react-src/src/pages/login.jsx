import { useState } from 'react';
import { FormControl, InputLabel, OutlinedInput, InputAdornment, IconButton, Alert } from "@mui/material";
import { Visibility, VisibilityOff } from "@mui/icons-material";
import '../assets/css/login.css'
import { loginAPI } from '../controller/auth';
import { jwtDecode } from 'jwt-decode'; // Add this import

export const Login = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');

    const handleUsernameChange = (e) => {
        setUsername(e.target.value);
    }

    const handlePasswordChange = (e) => {
        setPassword(e.target.value)
    }

    const handleMouseDownPassword = (e) => {
        e.preventDefault();
    }

    const handleShowPassword = () => {
        setShowPassword(!showPassword);
    }

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!username || !password) {
            setError('Por favor complete todos los campos');
            return;
        }

        const response = await loginAPI(username, password);

        if (response.error) {
            setError(response.error);
            return;
        }

        localStorage.setItem('refresh', response.refresh);
        localStorage.setItem('access', response.access);

        const decodedToken = jwtDecode(response.access);
        localStorage.setItem('userId', decodedToken.user_id);

        window.location.href = '/home';
    }

    return (
        <>
            <div className="center-box">
                <div className="login-box">
                    <h1>Iniciar Sección</h1>
                    <form onSubmit={handleSubmit}>
                        <FormControl sx={{ m: 1, width: '100%' }} variant="outlined">
                            {error && <Alert severity="error">{error}</Alert>}
                        </FormControl>
                        <FormControl sx={{ m: 1, width: '100%' }} variant="outlined">
                            <InputLabel htmlFor="outlined-adornment-username">Username</InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-username"
                                type="text"
                                value={username}
                                onChange={handleUsernameChange}
                                label="username"
                            />
                        </FormControl>
                        <FormControl sx={{ m: 1, width: '100%' }} variant="outlined">
                            <InputLabel htmlFor="outlined-adornment-password">Password</InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-password"
                                type={showPassword ? 'text' : 'password'}
                                value={password}
                                onChange={handlePasswordChange}
                                endAdornment={
                                    <InputAdornment position="end">
                                        <IconButton
                                            aria-label="toggle password visibility"
                                            onClick={handleShowPassword}
                                            onMouseDown={handleMouseDownPassword}
                                            edge="end"
                                        >
                                            {showPassword ? <VisibilityOff /> : <Visibility />}
                                        </IconButton>
                                    </InputAdornment>
                                }
                                label="Password"
                            />
                        </FormControl>
                        <input type="submit" className="btn-login" value="Login" />
                    </form>

                    <div className="login-links">
                        <a href="#">Forgot password?</a>
                        <a href="/register">Register</a>
                    </div>
                </div>
            </div>
        </>
    )
}
