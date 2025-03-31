# ⚡️ React Boilerplate with Auth, Modals & API Integration

This project provides a **clean and fully operational React + Vite boilerplate** for frontend apps requiring authentication, modal-based login/signup, and clean API integration.

---

## 📁 Features

- **React + Vite** for fast and modular development
- **Context-based state** for Auth, Modals and Toasts
- **Axios** with global interceptors
- **Manual toast system** (no external library)
- **Basic styling with `App.css` and reset**
- **Single source of truth for routes**
- **Error handling simplified and centralized**

---

<details>
<summary>✅ Authentication System</summary>

- JWT token stored in a **cookie**
- `AuthProvider` exposes `token`, `userData`, `handleLogin`, `handleLogout`
- Auth state initialized on app boot (from cookie + localStorage)
- Auto-persistence of user data
- Login and signup modals fully functional
</details>

---

<details>
<summary>✅ Modal Management</summary>

- `ModalProvider` controls state of login/signup modals
- Simple API: `openLoginModal()`, `openSignupModal()`, `closeModals()`
- Modal components are **reusable and styled**
- Triggered from the header or anywhere else
</details>

---

<details>
<summary>✅ API Client</summary>

- Axios instance with:
  - base URL from `VITE_API_URL`
  - auth token automatically added to headers
- API services for login/signup already abstracted
- Interceptors to catch global errors (401, 500…)
</details>

---

<details>
<summary>✅ Toast Notification System</summary>

- Lightweight toast system (`useToast`)
- Success, error, and warning variants
- Auto-dismiss after 3 seconds
- Styled and responsive (no dependencies)
</details>

---

<details>
<summary>✅ Layout & Loader</summary>

- `Layout` component with:
  - Sticky header
  - Centered loader (visible on auth init)
  - Page modals (signup/login) always active
- `Loader` styled to fit layout space, under header
</details>

---

<details>
<summary>✅ Routing & 404</summary>

- Centralized `routes.js` for path constants
- 404 fallback page included (`NotFound`)
- Routes wrapped in `Layout`
</details>

---

<details>
<summary>✅ Error Handling</summary>

- Central function `handleApiError(error)` returns clear user messages
- Applied in every `catch` block dealing with API calls
- Non-axios errors fall through cleanly
</details>
