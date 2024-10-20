import React, { useEffect, useState } from 'react';
import { collection, getDocs, query, orderBy } from 'firebase/firestore';
import { db } from '../FirebaseConfig';
import { Link } from 'react-router-dom';
import '../styles/Leaderboard.css';  

const LeaderboardPage = () => {
  const [users, setUsers] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        // Query all users from Firestore and order by totalPoints in descending order
        const usersRef = collection(db, 'User');
        const q = query(usersRef, orderBy('totalPoints', 'desc'));
        const querySnapshot = await getDocs(q);

        // Extract user data and store it in the state
        const usersList = [];
        querySnapshot.forEach((doc) => {
          usersList.push(doc.data());
        });

        setUsers(usersList);
      } catch (err) {
        setError('Error fetching users: ' + err.message);
      }
    };

    fetchUsers();
  }, []);

  return (
    <div className="leaderboard-container">
      <h1>Leaderboard</h1>
      
      {error && <div className="error">{error}</div>}

      <table className="leaderboard-table">
        <thead>
          <tr>
            <th>Rank</th>
            <th>Name</th>
            <th>Total Points</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user, index) => (
            <tr key={user.email}>
              <td>{index + 1}</td>
              <td>{user.name}</td>
              <td>{user.totalPoints}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <Link to="/home" className="back-link">Back to Homepage</Link>
    </div>
  );
};

export default LeaderboardPage;
