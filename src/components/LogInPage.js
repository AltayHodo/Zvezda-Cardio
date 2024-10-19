import React, { useState } from 'react';
import '../styles/SignUpPage.css';  
import logo from '../assets/logo.png';

const LogInPage = () => {
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};

    // Email Validation
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!form.email || !emailPattern.test(form.email)) {
      newErrors.email = 'Enter a valid email address';
    }

    // Password Validation
    if (!form.password || form.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters long';
    }

    setErrors(newErrors);
    // Return true if no errors
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validate()) {
      // Handle login logic here
      console.log('Login form submitted:', form);
      // Reset the form and errors
      setForm({ email: '', password: '' });
      setErrors({});
    }
  };

  return (
    <div className="login-container">
      <img src={logo} alt="Logo" className="logo" />
      <h2>Welcome Back!</h2>

      <form className="login-form" onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"
          placeholder="Email address"
          value={form.email}
          onChange={handleChange}
        />
        {errors.email && <div className="error">{errors.email}</div>}

        <input
          type="password"
          name="password"
          placeholder="Password"
          value={form.password}
          onChange={handleChange}
        />
        {errors.password && <div className="error">{errors.password}</div>}

        <button type="submit" className="login-button">Log In</button>
      </form>

      <div className="signup-link">
        Don't have an account? <a href="/signup">Sign up</a>
      </div>
    </div>
  );
};

export default LogInPage;
