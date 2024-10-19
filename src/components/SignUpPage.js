import React, { useState } from 'react';
import '../styles/SignUpPage.css';
import logo from '../assets/logo.png'

const SignUpPage = () => {
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [error, setError] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Add validation logic here
    if (!form.name || !form.email || !form.password) {
      setError('All fields are required');
    } else {
      setError('');
      // Handle form submission
      console.log('Form submitted:', form);
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
        <input
          type="email"
          name="email"
          placeholder="Email address"
          value={form.email}
          onChange={handleChange}
        />
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={form.password}
          onChange={handleChange}
        />
        {error && <div className="error">{error}</div>}

        <button type="submit" className="signup-button">Sign Up</button>
      </form>

      <div className="login-link">
        Already have an account? <a href="/login">Log in</a>
      </div>
    </div>
  );
};

export default SignUpPage;
