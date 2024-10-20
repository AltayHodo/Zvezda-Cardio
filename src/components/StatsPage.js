import React, { useEffect, useState, useContext } from 'react';
import { Link } from 'react-router-dom';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../FirebaseConfig';
import { UserContext } from '../UserContext';

const StatsPage = () => {
  const { user } = useContext(UserContext);
  const [dailyStats, setDailyStats] = useState(null);
  const [lifetimeStats, setLifetimeStats] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchStats = async () => {
      try {
        if (user?.email) {
          const userDocRef = doc(db, 'users', user.email.toLowerCase());
          const userDocSnap = await getDoc(userDocRef);

          if (userDocSnap.exists()) {
            const userData = userDocSnap.data();
            setDailyStats(userData.dailyStats || 'No data available');
            setLifetimeStats(userData.lifetimeStats || 'No data available');
          } else {
            setError('No stats data found in Firestore');
          }
        }
      } catch (err) {
        setError(err.message);
      }
    };

    fetchStats();
  }, [user]);

  return (
    <div className="stats-container">
      <h1>Your Stats</h1>
      
      {error && <div className="error">{error}</div>}

      <div className="stats-section">
        <h2>Daily Stats</h2>
        {/* {dailyStats ? <p>{JSON.stringify(dailyStats)}</p> : <p>Loading...</p>} */}
      </div>

      <div className="stats-section">
        <h2>Lifetime Stats</h2>
        {/* {lifetimeStats ? <p>{JSON.stringify(lifetimeStats)}</p> : <p>Loading...</p>} */}
      </div>

      <Link to="/home" className="back-link">Back to Homepage</Link>
    </div>
  );
};

export default StatsPage;
