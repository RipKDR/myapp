// Firebase Web SDK Configuration
// This file contains the Firebase configuration for web deployment

import { initializeApp } from "https://www.gstatic.com/firebasejs/12.2.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/12.2.1/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/12.2.1/firebase-firestore.js";
import { getMessaging } from "https://www.gstatic.com/firebasejs/12.2.1/firebase-messaging.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/12.2.1/firebase-analytics.js";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyApnZHdnV4GcI8sCFRIkjCD8idR0U1BgNg",
  authDomain: "ndis-connect-91f11.firebaseapp.com",
  projectId: "ndis-connect-91f11",
  storageBucket: "ndis-connect-91f11.firebasestorage.app",
  messagingSenderId: "573485849448",
  appId: "1:573485849448:web:c5ac0d19f7c3fc2ebd94dd"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const messaging = getMessaging(app);
export const analytics = getAnalytics(app);

export default app;
