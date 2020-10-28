import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToDevice = functions.firestore
  .document('requests/{requestsID}')
  .onCreate(async snapshot => {

    const message = snapshot.data();

    const querySnapshot = await db
      .collection('users')
      .doc(message.receiveID)
      .collection('tokens')
      .get();

      const tokens = querySnapshot.docs.map(snap => snap.id);

      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: 'Admin',
          body: `Calling...`,
          icon: 'your-icon-url',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          sound: 'calling.mp3',
        }
      };

      return fcm.sendToDevice(tokens, payload);
  });