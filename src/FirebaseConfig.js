import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyCRxFGLqM5tYoGHY9tvFwV1L9E75hb_Ens',
  authDomain: 'zvezda-cardio.firebaseapp.com',
  projectId: 'zvezda-cardio',
  storageBucket: 'zvezda-cardio.appspot.com',
  messagingSenderId: '325007941136',
  appId: '1:325007941136:ios:76d9c3a80b579f6d897495',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);