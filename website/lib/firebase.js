import { initializeApp, getApps } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Same Firebase project as the mobile app
const firebaseConfig = {
  apiKey: 'AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I',
  authDomain: 'ngo-volunteer-app-6284b.firebaseapp.com',
  projectId: 'ngo-volunteer-app-6284b',
  storageBucket: 'ngo-volunteer-app-6284b.firebasestorage.app',
  messagingSenderId: '169049198995',
  appId: '1:169049198995:web:0607882aa56553c71a1866',
  measurementId: 'G-FV601C4KBT',
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export default app;
