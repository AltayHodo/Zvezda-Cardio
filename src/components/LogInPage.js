import React, { useState } from 'react';
import '../styles/SignUpPage.css';
import logo from '../assets/logo.png';
import { auth, db } from '../FirebaseConfig';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

const LogInPage = () => {
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState('');
  const [userData, setUserData] = useState(null);  // To store user data from Firestore

  const validate = () => {
    const newErrors = {};
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!form.email || !emailPattern.test(form.email)) {
      newErrors.email = 'Enter a valid email address';
    }
    if (!form.password || form.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters long';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (validate()) {
      try {
        const userCredential = await signInWithEmailAndPassword(auth, form.email, form.password);
        const user = userCredential.user;

        const userDocRef = doc(db, 'User', user.uid);
        const userDocSnap = await getDoc(userDocRef);

        if (userDocSnap.exists()) {
          const userData = userDocSnap.data();
          setUserData(userData);  
          setSuccess(`Welcome back, ${userData.name}!`);
        } else {
          setErrors({ firebase: 'No user data found in Firestore' });
        }

        setForm({ email: '', password: '' });
      } catch (error) {
        setErrors({ firebase: error.message });
      }
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

        {errors.firebase && <div className="error">{errors.firebase}</div>}
        {success && <div className="success">{success}</div>}
        {userData && <div className="user-data">Name: {userData.name}</div>}

        <button type="submit" className="login-button">Log In</button>
      </form>

      <div className="signup-link">
        Don't have an account? <a href="/signup">Sign up</a>
      </div>
    </div>
  );
};

export default LogInPage;
