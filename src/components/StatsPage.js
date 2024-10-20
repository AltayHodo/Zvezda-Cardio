import React, { useEffect, useState, useContext } from 'react';
import { Link } from 'react-router-dom';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../FirebaseConfig';
import { UserContext } from '../UserContext';
import '../styles/StatsPage.css';  // Import the new CSS file

const StatsPage = () => {
  const { user } = useContext(UserContext);
  const [lifetimeStats, setLifetimeStats] = useState({
    totalCalories: 0,
    totalPoints: 0,
    totalSteps: 0
  });
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchStats = async () => {
      try {
        if (user?.email) {
          const userDocRef = doc(db, 'User', user.email.toLowerCase());
          const userDocSnap = await getDoc(userDocRef);

          if (userDocSnap.exists()) {
            const userData = userDocSnap.data();
            const { totalCalories, totalPoints, totalSteps } = userData;
            setLifetimeStats({ totalCalories, totalPoints, totalSteps });
            localStorage.setItem('stats', JSON.stringify({ totalCalories, totalPoints, totalSteps }));
          } else {
            setError('No stats data found in Firestore');
          }
        }
      } catch (err) {
        setError(err.message);
      }
    };

    const storedStats = JSON.parse(localStorage.getItem('stats'));
    if (storedStats) {
      setLifetimeStats(storedStats);
    } else {
      fetchStats();
    }
  }, [user]);

  return (
    <div className="stats-container">
      <h1>My Stats</h1>
      
      {error && <div className="error">{error}</div>}

      <div className="stats-section">
        <div className="stats-row">
          <div className="stat-label">Calories</div>
          <div className="stat-value">{lifetimeStats.totalCalories}</div>
        </div>
        <div className="stats-row">
          <div className="stat-label">Steps</div>
          <div className="stat-value">{lifetimeStats.totalSteps} steps</div>
        </div>
        <div className="stats-row">
          <div className="stat-label">Points Earned</div>
          <div className="stat-value">{lifetimeStats.totalPoints} points</div>
        </div>
      </div>

      <Link to="/home" className="back-link">Back to Homepage</Link>
    </div>
  );
};

export default StatsPage;
