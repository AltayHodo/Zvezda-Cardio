import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './styles/General.css';
import SignUpPage from './components/SignUpPage';
import LogInPage from './components/LogInPage';
import HomePage from './components/HomePage';
import StatsPage from './components/StatsPage';
import { UserProvider } from './UserContext';  

const App = () => {
  return (
    <UserProvider>
      <Router>
        <Routes>
          <Route path="/signup" element={<SignUpPage />} />
          <Route path="/login" element={<LogInPage />} />
          <Route path="/home" element={<HomePage />} />
          <Route path="/stats" element={<StatsPage />} />
          <Route path="*" element={<SignUpPage />} />  {/* Default route */}
        </Routes>
      </Router>
    </UserProvider>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
