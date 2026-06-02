importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Firebase config: các giá trị __PLACEHOLDER__ sẽ được thay thế
// bởi CI/CD pipeline hoặc script build.
firebase.initializeApp({
  apiKey: "__FIREBASE_API_KEY__",
  authDomain: "__FIREBASE_AUTH_DOMAIN__",
  projectId: "__FIREBASE_PROJECT_ID__",
  storageBucket: "__FIREBASE_STORAGE_BUCKET__",
  messagingSenderId: "__FIREBASE_MESSAGING_SENDER_ID__",
  appId: "__FIREBASE_APP_ID__",
  measurementId: "__FIREBASE_MEASUREMENT_ID__"
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((message) => {
  const { title, body } = message.notification;
  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png'
  });
});
