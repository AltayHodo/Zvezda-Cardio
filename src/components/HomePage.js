import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { UserContext } from '../UserContext';
import '../styles/HomePage.css';

const HomePage = () => {
  const { user } = useContext(UserContext);

  return (
    <div className="homepage-container">
      <h1>Welcome, {user?.name}!</h1>
      <div className="links">
        <Link to="/stats" className="stats-link">
          View Your Stats
        </Link>
        <Link to="/leaderboard" className="leaderboard-link">
          View Leaderboard
        </Link>
      </div>
    </div>
  );
};

export default HomePage;
