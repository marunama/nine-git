const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


exports.sendPushMessage = functions.firestore
  .collection("chatRooms")
  .document("{charroomDoId}")
  .collection("messages")
  .onWrite(async (change, _context) => {
    const data = change.after.data();

    // uidから通知先のユーザー情報を取得
    const userRef = await admin
      .firestore()
      .collection("users")
      .doc(data.uid);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      const user = userDoc.data();
      // 通知のタイトルと本文を設定
      const payload = {
        notification: {
          title: `（新着）`,
          body: data.message
        }
      };

      /// プッシュ通知を送信
      if (user.fcmToken) {
        admin.messaging().sendToDevice(user.fcmToken, payload);
      } else {
        console.error("No Firebase Cloud Messaging Token.");
      }
    } else {
      console.error("No User.");
    }

    return true;
  });