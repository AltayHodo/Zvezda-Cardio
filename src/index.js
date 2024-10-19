import React from 'react';
import ReactDOM from 'react-dom/client';
import './style.css';

const App = () => {
  return (
    <div>
      <h1>Hello from React!</h1>
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);