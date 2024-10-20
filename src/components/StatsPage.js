import React, { useEffect, useState, useContext } from 'react';
import { Link } from 'react-router-dom';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../FirebaseConfig';
import { UserContext } from '../UserContext';

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
            // Extract lifetime stats from Firestore document
            const { totalCalories, totalPoints, totalSteps } = userData;

            // Update state with lifetime stats
            setLifetimeStats({ totalCalories, totalPoints, totalSteps });

            // Save stats to localStorage for persistence
            localStorage.setItem(
              'stats',
              JSON.stringify({ totalCalories, totalPoints, totalSteps })
            );
          } else {
            setError('No stats data found in Firestore');
          }
        }
      } catch (err) {
        setError(err.message);
      }
    };

    // Load from localStorage if available
    const storedStats = JSON.parse(localStorage.getItem('stats'));
    if (storedStats) {
      setLifetimeStats(storedStats);
    } else {
      fetchStats();
    }
  }, [user]);

  return (
    <div className="stats-container">
      <h1>Your Stats</h1>
      
      {error && <div className="error">{error}</div>}

      <div className="stats-section">
        <h2>Lifetime Stats</h2>
        <p>Total Calories: {lifetimeStats.totalCalories}</p>
        <p>Total Points: {lifetimeStats.totalPoints}</p>
        <p>Total Steps: {lifetimeStats.totalSteps}</p>
      </div>

      <Link to="/home" className="back-link">Back to Homepage</Link>
    </div>
  );
};

export default StatsPage;
