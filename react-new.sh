#!/bin/bash

# 🏁 Nom du projet
PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Veuillez spécifier un nom de projet : ./react-new mon-app"
  exit 1
fi

echo "🎬 Création du projet Vite + React : $PROJECT_NAME"
npm create vite@latest "$PROJECT_NAME" -- --template react
cd "$PROJECT_NAME" || exit 1

# 📦 Dépendances utiles à installer
DEPENDENCIES=(axios react-router-dom js-cookie)

echo "📦 Installation des dépendances..."
yarn add "${DEPENDENCIES[@]}"

# 🧹 Nettoyage des fichiers inutiles générés par Vite
rm -f public/vite.svg
rm -rf src/assets
rm -f src/index.css

# 📁 Création des dossiers de structure
mkdir -p src/components src/pages src/hooks src/routes src/stores src/utils src/contexts src/api src/components/SignupModal src/components/LoginModal src/components/Layout src/components/Header src/pages/Home

# 🎨 App.css
cat > src/App.css <<EOF
:root {
  --primary-color: #e62429;
  --secondary-color: #202020;
  --font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

body {
  font-family: var(--font-family);
  background-color: #fff;
  color: var(--secondary-color);
  line-height: 1.6;
}

h1, h2, h3, h4 {
  color: var(--primary-color);
  margin-bottom: 1rem;
}

p {
  margin-bottom: 1rem;
}

a {
  color: var(--primary-color);
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

button,
input,
select,
textarea {
  font-family: inherit;
}
EOF

# ⚛️ App.jsx
cat > src/App.jsx <<EOF
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import "./App.css";

// Providers
import { AuthProvider } from "./contexts/AuthContext";
import { ModalProvider } from "./contexts/ModalContext";

// UI Components
import Layout from "./components/Layout/Layout";
import SignupModal from "./components/SignupModal/SignupModal";
import LoginModal from "./components/LoginModal/LoginModal";

// Pages
import Home from "./pages/Home/Home";

const App = () => {
  return (
    <AuthProvider>
      <ModalProvider>
        <Router>
          <SignupModal />
          <LoginModal />
          <Routes>
            <Route element={<Layout />}>
              <Route path="/" element={<Home />} />
            </Route>
          </Routes>
        </Router>
      </ModalProvider>
    </AuthProvider>
  );
};

export default App;
EOF


# 🔌 main.jsx
cat > src/main.jsx <<EOF
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./App.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# 🧽 reset.css dans public/
cat > public/reset.css <<EOF
/* http://meyerweb.com/eric/tools/css/reset/ */
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}
body {
  line-height: 1;
}
ol, ul {
  list-style: none;
}
blockquote, q {
  quotes: none;
}
blockquote::before, blockquote::after,
q::before, q::after {
  content: '';
  content: none;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
}
EOF

# 🧾 index.html
cat > index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${PROJECT_NAME}</title>
    <link rel="stylesheet" href="/reset.css" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# ⚙️ config.js
UPPER_NAME=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_' )

cat > src/config.js <<EOF
export const API_URL = "http://localhost:3000"; // à adapter
export const ${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME = "${PROJECT_NAME}_auth_token";
EOF

# AuthContext.jsx
cat > src/contexts/AuthContext.jsx <<EOF
import { createContext, useContext, useState } from "react";
import Cookies from "js-cookie";
import { ${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME } from "../config";

// Création du contexte
const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [token, setToken] = useState(Cookies.get(${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME) || null);
  const [userData, setUserData] = useState(() => {
    const stored = localStorage.getItem("userData");
    return stored ? JSON.parse(stored) : null;
  });

  const handleLogin = (token, userData) => {
    Cookies.set(${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME, token, { expires: 3 });
    localStorage.setItem("userData", JSON.stringify(userData));
    setToken(token);
    setUserData(userData);
  };

  const handleLogout = () => {
    Cookies.remove(${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME);
    localStorage.removeItem("userData");
    setToken(null);
    setUserData(null);
  };

  return (
    <AuthContext.Provider value={{ token, userData, setUserData, handleLogin, handleLogout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
EOF

# ModalContext.jsx
cat > src/contexts/ModalContext.jsx <<EOF
import { createContext, useContext, useState } from "react";

const ModalContext = createContext();

export const ModalProvider = ({ children }) => {
  const [activeModal, setActiveModal] = useState(null); // "login", "signup", or null

  const openSignupModal = () => setActiveModal("signup");
  const openLoginModal = () => setActiveModal("login");
  const closeModals = () => setActiveModal(null);

  return (
    <ModalContext.Provider
      value={{
        isSignupModalOpen: activeModal === "signup",
        isLoginModalOpen: activeModal === "login",
        openSignupModal,
        openLoginModal,
        closeModals,
      }}
    >
      {children}
    </ModalContext.Provider>
  );
};

export const useModal = () => {
  const context = useContext(ModalContext);
  if (!context) {
    throw new Error("useModal must be used within a ModalProvider");
  }
  return context;
};
EOF

# api/client.js
cat > src/api/client.js <<EOF
import axios from "axios";
import Cookies from "js-cookie";
import { ${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME } from "../config";

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

apiClient.interceptors.request.use((config) => {
  const token = Cookies.get(${UPPER_NAME}_AUTH_TOKEN_COOKIE_NAME);
  if (token) {
    config.headers.Authorization = \`Bearer \${token}\`;
  }
  return config;
});

export default apiClient;
EOF


# api/auth.js
cat > src/api/auth.js <<EOF
import api from "./client";

export const signup = async (payload) => {
  const response = await api.post("/api/auth/signup", payload);
  return response.data;
};

export const login = async (payload) => {
  const response = await api.post("/api/auth/login", payload);
  return response.data;
};
EOF

# SignupModal.jsx
cat > src/components/SignupModal/SignupModal.jsx <<EOF
import { useState } from "react";
import { signup } from "../../api/auth";
import { useAuth } from "../../contexts/AuthContext";
import { useModal } from "../../contexts/ModalContext";
import "./SignupModal.css";

const SignupModal = () => {
  const { isSignupModalOpen, openLoginModal, closeModals } = useModal();
  const { handleLogin } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  if (!isSignupModalOpen) return null;

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");

    try {
      const data = await signup({ email, password });

      if (data.token && data.user) {
        handleLogin(data.token, data.user);
        handleClose();
      } else {
        setError("Aucun token reçu.");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Une erreur est survenue.");
    }
  };

  const handleClose = () => {
    setEmail("");
    setPassword("");
    setError("");
    closeModals();
  };

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={handleClose}>
          ✖
        </button>
        <h2>S'inscrire</h2>
        <form className="modal-form" onSubmit={handleSubmit}>
          <input
            type="email"
            placeholder="Adresse email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <input
            type="password"
            placeholder="Mot de passe"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          <p className="newsletter-info">
            En m'inscrivant je confirme avoir lu et accepté les{" "}
            <a href="#">Termes & Conditions</a> et{" "}
            <a href="#">Politique de Confidentialité</a>. <br />
            Je confirme avoir au moins 18 ans.
          </p>

          {error && <p className="error-message">{error}</p>}

          <button type="submit">S'inscrire</button>

          <p className="modal-footer">
            Tu as déjà un compte ?{" "}
            <span
              className="switch-modal"
              onClick={() => {
                handleClose();
                openLoginModal();
              }}
            >
              Connecte-toi ici
            </span>
          </p>
        </form>
      </div>
    </div>
  );
};

export default SignupModal;
EOF

# SignupModal.css
cat > src/components/SignupModal/SignupModal.css <<EOF
.modal-overlay {
  position: fixed;
  top: 0px;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.modal-content {
  background: var(--secondary-color);
  padding: 30px;
  border-radius: 8px;
  box-shadow: 20px 50px 50px rgba(0, 0, 0, 0.8);
  position: relative;
  width: 400px;
  max-height: 75vh;
  overflow-y: auto;
}

.modal-close {
  position: absolute;
  top: 10px;
  right: 10px;
  border: none;
  background: transparent;
  font-size: 20px;
  cursor: pointer;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
  align-items: center;
}

.modal-form input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ccc;
  border-radius: 5px;
  font-size: 16px;
}

.modal-form label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  width: 100%;
  white-space: nowrap;
  opacity: 0.65;
  margin-top: 10px;
}

.modal-form label input[type="checkbox"] {
  margin-right: 5px;
  height: 20px;
  width: 20px;
  margin-right: 20px;
}

.modal-form button {
  width: 50%;
  background-color: var(--primary-color);
  color: white;
  font-size: 16px;
  padding: 10px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  margin-top: 10px;
}

.modal-form button:hover {
  opacity: 0.8;
}

.modal-content h2 {
  text-align: center;
  margin-bottom: 30px;
  font-size: 30px;
}

.newsletter-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.newsletter-info {
  font-size: 12px;
  color: #8b8b8b;
  margin-top: 4px;
}

.modal-footer {
  color: white;
}

.switch-modal {
  color: var(--primary-color);
  cursor: pointer;
  text-decoration: none;
}

.switch-modal:hover {
  text-decoration: underline;
}

.error-message {
  color: red;
  font-size: 14px;
  margin-bottom: 10px;
  text-align: center;
}
EOF

# LoginModal.jsx
cat > src/components/LoginModal/LoginModal.jsx <<EOF
import { useState } from "react";
import { login } from "../../api/auth";
import { useAuth } from "../../contexts/AuthContext";
import { useModal } from "../../contexts/ModalContext";
import "./LoginModal.css";

const LoginModal = () => {
  const { isLoginModalOpen, openSignupModal, closeModals } = useModal();
  const { handleLogin } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  if (!isLoginModalOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    try {
      const data = await login({ email, password });

      if (data.token && data.user) {
        handleLogin(data.token, data.user);
        handleClose();
      } else {
        setError("Aucun token reçu.");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Une erreur est survenue.");
    }
  };

  const handleClose = () => {
    setEmail("");
    setPassword("");
    setError("");
    closeModals();
  };

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={handleClose}>
          ✖
        </button>
        <h2>Se connecter</h2>
        <form className="modal-form" onSubmit={handleSubmit}>
          <input
            type="email"
            placeholder="Adresse email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <input
            type="password"
            placeholder="Mot de passe"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          {error && <p className="error-message">{error}</p>}

          <button type="submit">Se connecter</button>

          <p className="modal-footer">
            Pas encore de compte ?{" "}
            <span
              className="switch-modal"
              onClick={() => {
                handleClose();
                openSignupModal();
              }}
            >
              Inscris-toi !
            </span>
          </p>
        </form>
      </div>
    </div>
  );
};

export default LoginModal;
EOF

# LoginModal.css
cat > src/components/LoginModal/LoginModal.css <<EOF
@import "../SignupModal/SignupModal.css";
EOF

# Layout.jsx
cat > src/components/Layout/Layout.jsx <<EOF
import Header from "../Header/Header";
import SignupModal from "../SignupModal/SignupModal";
import LoginModal from "../LoginModal/LoginModal";
import { Outlet } from "react-router-dom";

const Layout = () => {
  return (
    <>
      <Header />
      <SignupModal />
      <LoginModal />
      <Outlet />
    </>
  );
};

export default Layout;
EOF

# Header.jsx
cat > src/components/Header/Header.jsx <<EOF
import "./Header.css";
import Logo from "./Logo";
import AuthButtons from "./AuthButtons";

const Header = () => {
  return (
    <header className="header">
      <Logo />
      <AuthButtons />
    </header>
  );
};

export default Header;
EOF

# Header.css
cat > src/components/Header/Header.css <<EOF
.header {
  position: sticky;
  top: 0;
  z-index: 10;

  height: var(--header-height);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  margin-bottom: 30px;
  box-shadow: 0 3px 8px rgba(0, 0, 0, 1);

  background-color: var(--primary-color);
  overflow: hidden;
  flex-wrap: wrap;
  gap: 2em;
}

/* Assure que le contenu du header passe bien au-dessus */
.header > * {
  position: relative;
  z-index: 1;
}
EOF

# AuthButtons.jsx
cat > src/components/Header/AuthButtons.jsx <<EOF
import { useModal } from "../../contexts/ModalContext";
import { useAuth } from "../../contexts/AuthContext";
import "./AuthButtons.css";

const AuthButtons = () => {
  const { openLoginModal, openSignupModal } = useModal();
  const { token, handleLogout } = useAuth();

  return (
    <div className="auth-buttons">
      {token ? (
        <>
          <button
            type="button"
            className="auth-btn logout"
            onClick={handleLogout}
          >
            Logout
          </button>
        </>
      ) : (
        <>
          <button
            type="button"
            className="auth-btn login"
            onClick={openLoginModal}
          >
            Login
          </button>
          <button
            type="button"
            className="auth-btn signup"
            onClick={openSignupModal}
          >
            Signup
          </button>
        </>
      )}
    </div>
  );
};

export default AuthButtons;
EOF

# AuthButtons.css
cat > src/components/Header/AuthButtons.css <<EOF
.auth-buttons {
  display: flex;
  gap: 0.5rem;
}

.auth-btn {
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 3px;
  cursor: pointer;
  font-weight: 700;
  font-size: 1.3rem;
  border: none;
}

.auth-btn.login {
  background-color: var(--secondary-color);
}

.auth-btn.signup {
  background-color: var(--primary-color);
}

.auth-btn:hover {
  background-color: white;
  color: var(--secondary-color);
}

.auth-btn.logout {
  background-color: black;
}

.auth-btn.logout:hover {
  background-color: white;
  color: var(--secondary-color);
}
EOF

# Home.jsx
cat > src/pages/Home/Home.jsx <<EOF
import { useAuth } from "../../contexts/AuthContext";
import "./Home.css";

const Home = () => {
  const { userData } = useAuth();

  return (
    <div className="home">
      <h1>Bienvenue sur ${PROJECT_NAME} !</h1>
      {userData ? (
        <p className="welcome">Heureux de te revoir, {userData.firstName || userData.email} 👋</p>
      ) : (
        <p className="welcome">Connecte-toi ou crée un compte pour commencer à jouer !</p>
      )}
    </div>
  );
};

export default Home;
EOF

# Home.css
cat > src/pages/Home/Home.css <<EOF
.home {
  text-align: center;
  padding: 2rem;
}

.home h1 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  color: var(--primary-color);
}

.welcome {
  font-size: 1.2rem;
  color: var(--secondary-color);
}
EOF

# Logo.jsx
cat > src/components/Header/Logo.jsx <<EOF
import "./Logo.css";
import { Link } from "react-router-dom";

const Logo = () => {
  return (
    <Link className="logo-link" to="/">
      <img
        src="/logo-marvel-nicosek.png"
        alt="Marvel by NicoSek"
        className="logo"
      />
    </Link>
  );
};

export default Logo;
EOF

# Logo.css
cat > src/components/Header/Logo.css <<EOF
.logo-link {
  display: block;
  height: 100%;
}

.logo {
  height: 100%;
  width: auto;
  display: block;
}
EOF




# .env
cat > .env <<EOF
VITE_API_URL=http://localhost:3000
EOF

# .gitignore
cat > .gitignore <<EOF
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# Runtime
node_modules
dist
dist-ssr
*.local
.cache
.coverage
coverage

# Env & config
.env
.env.local
.env.*.local

# Vite / Parcel / Turbopack
.vite
.parcel-cache
.turbo

# System
.DS_Store

# IDEs / Editors
.vscode/*
!.vscode/extensions.json
.idea
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# macOS
.AppleDouble
.LSOverride

# Thumbs.db (Windows)
Thumbs.db
Desktop.ini
EOF


echo "✅ Projet React + Vite initialisé avec succès 🎉"
echo "📂 Dossier créé : $PROJECT_NAME"
