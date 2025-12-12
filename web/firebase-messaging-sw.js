importScripts("https://www.gstatic.com/firebasejs/9.1.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.1.0/firebase-messaging-compat.js");

// Initialize the Firebase app in the service worker by passing the generated config
// from firebase_options.dart (manually copied here as SW cannot import Dart)
// Config for: Web / Prod
const firebaseConfig = {
    apiKey: 'AIzaSyCtDaQ_H_JZC8-akF25X7t69XxeR-nar6k',
    appId: '1:244100597067:web:15eb8ad33c8220505654ce',
    messagingSenderId: '244100597067',
    projectId: 'sicv-flutter',
    authDomain: 'sicv-flutter.firebaseapp.com',
    storageBucket: 'sicv-flutter.firebasestorage.app',
};

firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png' // Asegúrate de que este icono exista en web/icons
    };

    return self.registration.showNotification(notificationTitle,
        notificationOptions);
});
