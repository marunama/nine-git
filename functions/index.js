//const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const firestore = admin.firestore();

// プッシュ通知を送る関数
const sendPushMessage = function(token, title, body, badge) {

    const payload = {
        notification: {
            title: title,
            body: body,
            badge: badge,
            sound:"default"
        }
    };
    const option = {
        priority: "high"
    };
    // ここで実際に通知を送信している
    console.log("通知")
    admin.messaging().sendToDevice(token,payload,option);
}

// 新規依頼作時
exports.createMessage = functions.firestore.document('/chatRooms/{chatRooms}')
    .onWrite( async (snapshot, context) => {
        // ここチャットルームのデータが入っている(createdAt, latestMessageId, members)
        const chatInfo = snapshot.after.data()
        console.log("チャットルームの情報")
        console.log(chatInfo)

        const receiverFcmToken = chatInfo.membersfcm

        console.log("トークン")
        console.log(receiverFcmToken)
        

        
       
        
        

        // 受信者の情報にアクセスする
//        receiverRef.get().then(function(doc){
//                if (doc.exists === true) {
//                    // 受信者の情報を取得(name,fcmToken)
//                    const receiver = doc.data()
//                    const fcmToken = receiver["fcmToken"]
//                    const senderName = message["username"]
//                    const content = message["content"]
//                    // 通知のタイトル
//                    const title = `$senderName`
//                    // 通知の内容
//                    const body = `$content`
//                    sendPushMessage(fcmToken,title,body,"1");
//                    console.log("newMessage")
//                 } else {
//                    console.log("notExists")
//                }
        
        //admin.messaging().send(pushMessage("flfN7BQVfUUHhshDfmE477:APA91bEivfuzfyl7EzW8Elj22BIn0fI_zqvcEZYkXPr88lZXzvMKykUBM1gTBTFggNO9RCQdiHcqdox4rn2XXRlGMDwI0fSyuf27J1GxGTyorvIBmZEPxCnjZisCJqUrJE98-rIwUu6m", "テスト"))
        //admin.messaging().sendToDevice("flfN7BQVfUUHhshDfmE477:APA91bEivfuzfyl7EzW8Elj22BIn0fI_zqvcEZYkXPr88lZXzvMKykUBM1gTBTFggNO9RCQdiHcqdox4rn2XXRlGMDwI0fSyuf27J1GxGTyorvIBmZEPxCnjZisCJqUrJE98-rIwUu6m", payload);
        sendPushMessage("receiverFcmToken", "新着","新しいメッセージ","1");
})


//exports.updateMessage = functions.firestore.document('/chatRooms/wlV45KGLEDRElBAI4IFH/')
//    .onUpdate( async (snapshot, context) => {
//        // ここにmessageのデータが入っている(senderId,senderName,receiverId,content)
//        const message = snapshot.data()
//        console.log(message)
//        const receiverRef = firestore.collection("users").doc(message["email"]) // userにidが付与されていないようなので、一旦emailで誰に渡すのか判別するようにします。
//        console.log("receiverRef")
//        console.log(receiverRef)
//        // 受信者の情報にアクセスする
//        receiverRef.get().then(function(doc){
//                if (doc.exists === true) {
//                    // 受信者の情報を取得(name,fcmToken)
//                    const receiver = doc.data()
//                    const fcmToken = receiver["fcmToken"]
//                    const senderName = message["username"]
//                    const content = message["content"]
//                    // 通知のタイトル
//                    const title = `$senderName`
//                    // 通知の内容
//                    const body = `$content`
//                    sendPushMessage(fcmToken,title,body,"1");
//                    console.log("newMessage")
//                 } else {
//                    console.log("notExists")
//                }
//            })
//})

// exports.sendPushMessage = firestore
//   .collection("chatRooms")
//   .document("{chatRoomsDoId}")
//   .collection("messages")
//   .onWrite(async (change, _context) => {
//     const data = change.after.data();

//     // uidから通知先のユーザー情報を取得
//     const userRef = await admin
//       .firestore()
//       .collection("users")
//       .doc(data.uid);
//     const userDoc = await userRef.get();

//     if (userDoc.exists) {
//       const user = userDoc.data();
//       // 通知のタイトルと本文を設定
//       const payload = {
//         notification: {
//           title: `（好きなタイトルを入力）`,
//           body: data.message
//         }
//       };

//       /// プッシュ通知を送信
//       if (user.fcmToken) {
//         admin.messaging().sendToDevice(user.fcmToken, payload);
//       } else {
//         console.error("No Firebase Cloud Messaging Token.");
//       }
//     } else {
//       console.error("No User.");
//     }

//     return true;
//   });

