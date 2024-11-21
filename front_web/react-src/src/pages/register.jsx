import { useState } from 'react';
import { FormControl, InputLabel, OutlinedInput, InputAdornment, IconButton, Alert } from "@mui/material";
import { Visibility, VisibilityOff } from "@mui/icons-material";
import { registerAPI } from '../controller/auth';
import '../assets/css/login.css'

export const Register = () => {
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [error, setError] = useState('');

    const handleUsernameChange = (e) => {
        setUsername(e.target.value);
    }

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    }

    const handlePasswordChange = (e) => {
        setPassword(e.target.value)
    }

    const handleConfirmPasswordChange = (e) => {
        setConfirmPassword(e.target.value)
    }

    const handleMouseDownPassword = (e) => {
        e.preventDefault();
    }

    const handleShowPassword = () => {
        setShowPassword(!showPassword);
    }

    const handleShowConfirmPassword = () => {
        setShowConfirmPassword(!showConfirmPassword);
    }

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!username || !email || !password || !confirmPassword) {
            setError('Por favor complete todos los campos');
            return;
        }

        if (password !== confirmPassword) {
            setError('Las contraseñas no coinciden');
            return;
        }

        const response = await registerAPI(
            username, email, password, confirmPassword
        );

        if (response.error) {
            setError(response.error);
            return;
        }
        window.location.href = '/';
    }

    return (
        <>
            <div className="center-box">
                <div className="login-box">
                    <h1>Registrarse</h1>
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
                            <InputLabel htmlFor="outlined-adornment-email">Email</InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-email"
                                type="text"
                                value={email}
                                onChange={handleEmailChange}
                                label="Email"
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

                        <FormControl sx={{ m: 1, width: '100%' }} variant="outlined">
                            <InputLabel htmlFor="outlined-adornment-confirm">Confirmar contraseña</InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-confirm"
                                type={showConfirmPassword ? 'text' : 'password'}
                                value={confirmPassword}
                                onChange={handleConfirmPasswordChange}
                                endAdornment={
                                    <InputAdornment position="end">
                                        <IconButton
                                            aria-label="toggle password visibility"
                                            onClick={handleShowConfirmPassword}
                                            onMouseDown={handleMouseDownPassword}
                                            edge="end"
                                        >
                                            {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                                        </IconButton>
                                    </InputAdornment>
                                }
                                label="Confirmar contraseña"
                            />
                        </FormControl>

                        <input type="submit" className='btn-login' value="Register" />
                    </form>

                    <div className="login-links">
                        <a href="/">Login</a>
                    </div>
                </div>
            </div>
        </>
    )
}