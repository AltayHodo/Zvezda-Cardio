import React, { useState } from 'react';
import '../styles/SignUpPage.css';
import logo from '../assets/logo.png';

const SignUpPage = () => {
  const [form, setForm] = useState({ name: '', email: '', password: '', confirmPassword: '' });
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};

    // Full Name Validation
    if (!form.name || form.name.length < 2) {
      newErrors.name = 'Full Name must be at least 2 characters long';
    }

    // Email Validation
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!form.email || !emailPattern.test(form.email)) {
      newErrors.email = 'Enter a valid email address';
    }

    // Password Validation
    if (!form.password || form.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters long';
    }

    // Confirm Password Validation
    if (form.confirmPassword !== form.password) {
      newErrors.confirmPassword = 'Passwords do not match';
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
      // Handle form submission here
      console.log('Form submitted:', form);
      // Reset the form and errors
      setForm({ name: '', email: '', password: '', confirmPassword: '' });
      setErrors({});
    }
  };

  return (
    <div className="signup-container">
      <img src={logo} alt="Logo" className="logo" />
      <h2>Welcome!</h2>

      <form className="signup-form" onSubmit={handleSubmit}>
        <input
          type="text"
          name="name"
          placeholder="Full Name"
          value={form.name}
          onChange={handleChange}
        />
        {errors.name && <div className="error">{errors.name}</div>}

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

        <input
          type="password"
          name="confirmPassword"
          placeholder="Confirm Password"
          value={form.confirmPassword}
          onChange={handleChange}
        />
        {errors.confirmPassword && <div className="error">{errors.confirmPassword}</div>}

        <button type="submit" className="signup-button">Sign Up</button>
      </form>

      <div className="login-link">
        Already have an account? <a href="/login">Log in</a>
      </div>
    </div>
  );
};

export default SignUpPage;
