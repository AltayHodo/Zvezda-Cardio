import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { UserContext } from '../UserContext';

const HomePage = () => {
  const { user } = useContext(UserContext);

  return (
    <div className="homepage-container">
      <h1>Welcome, {user?.name}!</h1>
      <Link to="/stats" className="stats-link">View Your Stats</Link>
    </div>
  );
};

export default HomePage;
