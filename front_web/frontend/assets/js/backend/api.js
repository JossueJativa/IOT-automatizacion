window.addEventListener("DOMContentLoaded", () => {
    const formLogin = document.getElementById("user-form-login");
    const formRegister = document.getElementById("user-form-register");

    formLogin.addEventListener("submit", async (e) => {
        e.preventDefault();

        const username = document.getElementById("login-username").value;
        const password = document.getElementById("login-password").value;

        try {
            const authData = await window.api.loadJson();
            const url = authData.API_URL;

            const response = await fetch(url + 'user/login/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, password })
            });      

            if (response.ok) {
                try {
                    const data = await response.json();
                    console.log(data);
                    alert('Inicio de sesión exitoso.');
                } catch (error) {
                    console.error('Error al parsear el JSON:', error);
                    alert('Error al procesar la respuesta del servidor.');
                }
            } else {
                alert('No se pudo procesar el inicio de sesión. Verifique sus credenciales.');
            }            
        } catch (error) {
            console.error('Error al cargar datos del JSON:', error);
            alert('No se pudo procesar el inicio de sesión.');
        }
    });

    formRegister.addEventListener("submit", async (e) => {
        e.preventDefault();

        const username = document.getElementById("signup-username").value;
        const email = document.getElementById("signup-email").value;
        const password = document.getElementById("signup-password").value;
        const confirm = document.getElementById("signup-confirm-password").value;

        if (password !== confirm) {
            alert('Las contraseñas no coinciden.');
            return;
        }

        try {
            const authData = await window.api.loadJson();
            const url = authData.API_URL;

            const response = await fetch(url + 'user/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, email, password, token_phone: null })
            });

            if (response.ok) {
                try {
                    const data = await response.json();
                    console.log(data);
                    alert('Registro exitoso.');
                } catch (error) {
                    console.error('Error al parsear el JSON:', error);
                    alert('Error al procesar la respuesta del servidor.');
                }
            } else {
                alert('No se pudo procesar el registro. Verifique sus credenciales.');
            }
        } catch (error) {
            console.error('Error al cargar datos del JSON:', error);
            alert('No se pudo procesar el registro.');
        }
    });
});