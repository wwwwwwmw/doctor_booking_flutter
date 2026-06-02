importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDNq70t5nxxQ6iJf9UKTh52qDtMy2epHBM",
  authDomain: "doctor-booking-74033.firebaseapp.com",
  projectId: "doctor-booking-74033",
  storageBucket: "doctor-booking-74033.firebasestorage.app",
  messagingSenderId: "375092795192",
  appId: "1:375092795192:web:a22abde6bb4973918693cd",
  measurementId: "G-D80CTR9HC8"
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((message) => {
  const { title, body } = message.notification;
  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png'
  });
});
