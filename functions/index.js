const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().functions);
const bucket = admin.storage().bucket()

// sendgrid config
const SENDGRID_API_KEY = functions.config().sendgrid.key;
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(SENDGRID_API_KEY);

// This Cloud Function Updates Users State when user gets online & offline with last_seen time.
exports.userStatus = functions.database
  .ref("/users/{userId}/presence")
  .onUpdate(async (change, context) => {
    // Get the data written to Realtime Database
    const isOnline = change.after.val();

    // Get a reference to the Firestore document
    const userStatusFirestoreRef = admin.firestore().collection('Users').doc(context.params.userId);
    
    console.log(`status: ${isOnline}`);

    // Update the values on Firestore
    return userStatusFirestoreRef.update({
      presence: isOnline,
      last_seen: Date.now(),
    });
  });

// This Cloud Function sends new Message Push Notification to user.
exports.sendChatNotification = functions.firestore
    .document('/chats/{chatId}/messages/{msgId}')
    .onCreate(async (snap, context) => {
        console.log('----------------start function--------------------')
        console.log(context.params.chatId)
        const doc = snap.data()
        const idFrom = doc.sender_id
        const idTo = doc.receiver_id
        const contentMessage = doc.text
        var contentType = ""
        if (typeof doc.type !== 'undefined') {
            contentType = doc.type
        }
        console.log(contentType)

        // Get push token user to (receive)
        const ref = admin.firestore().collection('Users').doc(idTo)
        const userIdTo = await ref.get();
        const ref2 = admin.firestore().collection('Users').doc(idFrom)
        const userIdFrom = await ref2.get();
        console.log(userIdTo.data().pushToken);
        const payload = {
            notification: {
                title: contentType === 'Call' ? `You have missed a Call from  ${userIdFrom.data().UserName}` : contentType === 'req' ? `${userIdFrom.data().UserName} wants to call you!` : `You have a message from ${userIdFrom.data().UserName}`,
                body: contentMessage,
                badge: '1',
                sound: 'default'
            },
            data: {
                'senderName': userIdFrom.data().UserName,
                'senderPicture': userIdFrom.data().Pictures[0].url,
                'channel_id': context.params.chatId,
                "senderID":userIdFrom.data().userId,
                "type": contentType,
                "category": "${url}?destination=${data.destination}",
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            }
        }
        if (userIdTo.data().pushToken !== null) {
            if (userIdTo.data().isBlocked) {
                return console.log('User is Blocked by Admin!');
            } else {
                if (contentType === 'Call') {
                    return admin
                .messaging()
                .sendToDevice(userIdTo.data().pushToken, payload);
                } else {
                    if (userIdTo.data().isNotificationsEnabled != null) {
                        if (userIdTo.data().isNotificationsEnabled == true) {
                            return admin
                    .messaging()
                    .sendToDevice(userIdTo.data().pushToken, payload);
                        } else {
                            return console.log('User Turned Off the Notifications!');
                        }
                    } else {
                        return admin
                    .messaging()
                    .sendToDevice(userIdTo.data().pushToken, payload);
                    }
                }
            }
        } else {
            return console.log('Device Push Token Not Found!');
        }
    });

// This cloud function sends new match push notification to user.
exports.sendMatchNotification = functions.firestore
    .document('/Users/{userId}/Matches/{matchUserId}')
    .onCreate(async (snashot, context) => {
        const doc = snashot.data()
        const matchId = doc.Matches
        const matchwith = context.params.userId
        console.log('========')
        const matchUser = await admin.firestore().collection('Users').doc(matchId).get()
        const matchWithUser = await admin.firestore().collection('Users').doc(matchwith).get()
        const payload = {
            notification: {
                title: `It's a new match with ${matchWithUser.data().UserName}`,
                body: `Now you can start chat with ${matchWithUser.data().UserName}`,
                badge: '1',
                sound: 'default'
            }
        }
        if (matchUser.data().pushToken !== null) {
            if (matchUser.data().isNotificationsEnabled != null) {
                if (matchUser.data().isNotificationsEnabled == true) {
                    return admin
                    .messaging()
                    .sendToDevice(matchUser.data().pushToken, payload);
                } else {
                    return console.log('User Turned off the Notification!');
                }
            } else {
                return admin
                .messaging()
                .sendToDevice(matchUser.data().pushToken, payload);
            }
            
        } else {
            return console.log('Device Push Token Not Found!');
        }
    });

// This cloud function deletes all the inforation about the user as soon as user deletes the account.
exports.deleteInfo = functions.auth.user().onDelete(async (user) => {
    console.log('delete account triggered!');
    await bucket.deleteFiles({
        prefix: `${user.uid}/`
    });
    return console.log("User Images, Deleted!");
});


// Marketing Email Cloud Functions starts here

// This Cloud Function sends welcome email to newly registered user.
exports.sendWelcomeEmail = functions.firestore
    .document('Users/{userId}')
    .onUpdate(async (change, context) => {
        const after = change.after.data();
        if(after.welcomemode == false){
            if(after.Email != null){
                const ref = admin.firestore().collection('Users').doc(context.params.userId)
                return await ref.get()
                .then(doc => {
                    const user = doc.data()
                    const msg = {
                        to: user.Email,
                        from: 'hello@loveafghan.com',
                        subject: 'Welcome to Love Afghan',
                        templateId: 'd-c3302b51ab6c4ebb88fa296429d8a7d2',
                        dynamic_template_data: {
                            name: user.UserName
                        }
                    };
                    return sgMail.send(msg)
                })
                .then(() => {
                    console.log('email sent!')
                    return change.after.ref.update({
                        welcomemode:true
                    });
                })
                .catch(err => console.log(err))
            }
        }
    });

// This Cloud Function sends Message Read Email if user is offline.
exports.sendMessageReadMail = functions.firestore
    .document('/chats/{chatId}/messages/{msgId}')
    .onUpdate(async (change, context) => {
        const doc = change.after.data()
        const idFrom = doc.sender_id
        const idTo = doc.receiver_id
        var contentType = ""
        if (typeof doc.type !== 'undefined') {
            contentType = doc.type
        }
        console.log(contentType)

        const ref = admin.firestore().collection('Users').doc(idTo)
        const userIdTo = await ref.get();
        const ref2 = admin.firestore().collection('Users').doc(idFrom)
        const userIdFrom = await ref2.get();
        if (doc.isRead) {
            if(contentType === 'Msg'){
                if(!userIdFrom.data().presence){
                    if(userIdFrom.data().Email != null){
                        if (userIdFrom.data().isEmailsEnabled != null) {
                            if (userIdFrom.data().isEmailsEnabled == true) {
                                const msg = {
                                    to: userIdFrom.data().Email,
                                    from: 'hello@loveafghan.com',
                                    subject: 'Your message was read',
                                    templateId: 'd-7ce127c378c84164b341c4e02622518f',
                                    dynamic_template_data: {
                                        name: userIdFrom.data().UserName,
                                        sname: userIdTo.data().UserName
                                    }
                                };
                                return sgMail.send(msg);
                            } else {
                                return console.log('User Turned Off the Emails!');
                            }
                        } else {
                            const msg = {
                                to: userIdFrom.data().Email,
                                from: 'hello@loveafghan.com',
                                subject: 'Your message was read',
                                templateId: 'd-7ce127c378c84164b341c4e02622518f',
                                dynamic_template_data: {
                                    name: userIdFrom.data().UserName,
                                    sname: userIdTo.data().UserName
                                }
                            };
                            return sgMail.send(msg);
                        }
                        
                    }
                }
            }
        }
        return console.log('Function Executed & finished!');
    });

// this cloud function sends new match Email to user.
exports.sendMatchEmail = functions.firestore
    .document('/Users/{userId}/Matches/{matchUserId}')
    .onCreate(async (snashot, context) => {
        const doc = snashot.data()
        const matchId = doc.Matches
        const matchwith = context.params.userId
        console.log('========')
        const matchUser = await admin.firestore().collection('Users').doc(matchId).get()
        const matchWithUser = await admin.firestore().collection('Users').doc(matchwith).get()

        console.log(matchUser.data().UserName)
        console.log(matchWithUser.data().UserName)

        if(matchWithUser.data().Email != null){
            if (matchWithUser.data().isEmailsEnabled != null) {
                if (matchWithUser.data().isEmailsEnabled == true) {
                    const msg = {
                        to: matchWithUser.data().Email,
                        from: 'hello@loveafghan.com',
                        subject: 'You have a new match!',
                        templateId: 'd-1954e9509ef24c8c96a2897e3936cc11',
                        dynamic_template_data: {
                            name: matchWithUser.data().UserName
                        }
                    };
                    return sgMail.send(msg);
                } else {
                    return console.log('User Turned Off the Emails!');
                }
            } else {
                const msg = {
                    to: matchWithUser.data().Email,
                    from: 'hello@loveafghan.com',
                    subject: 'You have a new match!',
                    templateId: 'd-1954e9509ef24c8c96a2897e3936cc11',
                    dynamic_template_data: {
                        name: matchWithUser.data().UserName
                    }
                };
                return sgMail.send(msg);
            }
            
        } else {
            return console.log('user email not found!');
        }
    });

// This Cloud Function sends Message Notification (& Email if user is offline) of new messages to users.
exports.sendNewMessageMail = functions.firestore
    .document('/chats/{chatId}/messages/{msgId}')
    .onCreate(async (snap, context) => {
    const doc = snap.data()
    const idFrom = doc.sender_id
    const idTo = doc.receiver_id
    const contentMessage = doc.text
    var contentType = ""
    if (typeof doc.type !== 'undefined') {
        contentType = doc.type
    }

    // Get push token user to (receive)
    const ref = admin.firestore().collection('Users').doc(idTo)
    const userIdTo = await ref.get();
    const ref2 = admin.firestore().collection('Users').doc(idFrom)
    const userIdFrom = await ref2.get();
    if(contentType === 'Msg'){
        if(!userIdTo.data().presence){
            if(userIdTo.data().Email != null){
                if (userIdTo.data().isEmailsEnabled != null) {
                    if (userIdTo.data().isEmailsEnabled == true) {
                        
                        const msg = {
                                to: userIdTo.data().Email,
                                from: 'hello@loveafghan.com',
                                subject: 'You have a new message.',
                                templateId: 'd-c1ed94b07cd948f186e4f6b0acad924f',
                                dynamic_template_data: {
                                    name: userIdTo.data().UserName,
                                    sname: userIdFrom.data().UserName
                                }
                            };
                        
                        return sgMail.send(msg);
                    } else {
                        return console.log('User Turned Off the Emails!');
                    }
                } else {
                    
                    const msg = {
                            to: userIdTo.data().Email,
                            from: 'hello@loveafghan.com',
                            subject: 'You have a new message.',
                            templateId: 'd-c1ed94b07cd948f186e4f6b0acad924f',
                            dynamic_template_data: {
                                name: userIdTo.data().UserName,
                                sname: userIdFrom.data().UserName
                            }
                        };
                    
                    return sgMail.send(msg);
                }
            }
        }
    }
    return console.log('Function Executed & Finished!');
});

// This Cloud Function sends Mail when user reports any other user.
exports.sendReportReceivedMail = functions.firestore
    .document('/Reports/{reportId}')
    .onCreate(async (snap, context) => {
        const doc = snap.data();
        const reporterId = doc.reported_by;
        const victimId = doc.victim_id;

        const ref = admin.firestore().collection('Users').doc(reporterId)
        const reporter = await ref.get();
        const ref2 = admin.firestore().collection('Users').doc(victimId)
        const victim = await ref2.get();

        if(reporter.data().Email != null) {
            if (reporter.data().isEmailsEnabled != null) {
                if (reporter.data().isEmailsEnabled == true) {
                    const msg = {
                        to: reporter.data().Email,
                        from: 'hello@loveafghan.com',
                        subject: 'Thanks for Reporting!',
                        templateId: 'd-ab5df6ce8e5b4b42acff89f8424a6b0e',
                        dynamic_template_data: {
                            name: reporter.data().UserName,
                            sname: victim.data().UserName
                        }
                    };
                return sgMail.send(msg);
                } else {
                    return console.log('User Turned Off the Emails!');
                }
            } else {
                const msg = {
                    to: reporter.data().Email,
                    from: 'hello@loveafghan.com',
                    subject: 'Thanks for Reporting!',
                    templateId: 'd-ab5df6ce8e5b4b42acff89f8424a6b0e',
                    dynamic_template_data: {
                        name: reporter.data().UserName,
                        sname: victim.data().UserName
                    }
                };
            return sgMail.send(msg);
            }

        } else {
            return console.log("Reporter Haven't Provided Email Address!");
        }
    });

// This Cloud Function sends new call request mail
exports.sendCallRequestMail = functions.firestore
    .document('/chats/{chatId}/messages/{msgId}')
    .onCreate(async (snap, context) => {
        const doc = snap.data()
        const idFrom = doc.sender_id
        const idTo = doc.receiver_id
        const contentMessage = doc.text
        var contentType = ""
        if (typeof doc.type !== 'undefined') {
            contentType = doc.type
        }

        // Get push token user to (receive)
        const ref = admin.firestore().collection('Users').doc(idTo)
        const userIdTo = await ref.get();
        const ref2 = admin.firestore().collection('Users').doc(idFrom)
        const userIdFrom = await ref2.get();
        if(contentType === 'req'){
            if(userIdTo.data().Email != null){
                if (userIdTo.data().isEmailsEnabled != null) {
                    if (userIdTo.data().isEmailsEnabled == true) {
                        if(contentMessage.includes("Audio")) {
                    
                            const msg = {
                                to: userIdTo.data().Email,
                                from: 'hello@loveafghan.com',
                                subject: 'Audio Call Request!',
                                templateId: 'd-9bbd580671b74cf6bbec84974f98bf12',
                                dynamic_template_data: {
                                    name: userIdTo.data().UserName,
                                    sname: userIdFrom.data().UserName
                                }
                            };
                            return sgMail.send(msg);
                        } else {
                            const msg = {
                                to: userIdTo.data().Email,
                                from: 'hello@loveafghan.com',
                                subject: 'Video Call Request!',
                                templateId: 'd-fcfc1b38763642a6951d71f0d7fb5c30',
                                dynamic_template_data: {
                                    name: userIdTo.data().UserName,
                                    sname: userIdFrom.data().UserName
                                }
                            };
                            return sgMail.send(msg);
                        }
                    } else {
                        return console.log('User Turned Off the Emails!');
                    }
                } else {
                    if(contentMessage.includes("Audio")) {
                    
                        const msg = {
                            to: userIdTo.data().Email,
                            from: 'hello@loveafghan.com',
                            subject: 'Audio Call Request!',
                            templateId: 'd-9bbd580671b74cf6bbec84974f98bf12',
                            dynamic_template_data: {
                                name: userIdTo.data().UserName,
                                sname: userIdFrom.data().UserName
                            }
                        };
                        return sgMail.send(msg);
                    } else {
                        const msg = {
                            to: userIdTo.data().Email,
                            from: 'hello@loveafghan.com',
                            subject: 'Video Call Request!',
                            templateId: 'd-fcfc1b38763642a6951d71f0d7fb5c30',
                            dynamic_template_data: {
                                name: userIdTo.data().UserName,
                                sname: userIdFrom.data().UserName
                            }
                        };
                        return sgMail.send(msg);
                    }
                }
                
            }
        }
        return console.log('Function Executed & Finished!');
    });

// This Cloud Function sends mail, If the user does not open the app within a week,
exports.sendInActiveMail = functions.pubsub.schedule('0 19 * * FRI')
    .onRun(async (context) => {
        const matchesRef = admin.firestore().collection('Users');
        const time = admin.firestore.Timestamp.now().toMillis - 604800;
        const thistime = admin.firestore.Timestamp.fromMillis(time);
        const snapshot = await matchesRef.where('last_seen', '<=', thistime).get();
        if (snapshot.empty) {
          return console.log('No matching documents.');
        } else {
            snapshot.forEach(doc => {
                if(doc.data().Email != null) {
                    if (doc.data().isEmailsEnabled != null) {
                        if (doc.data().isEmailsEnabled == true) {
                            const msg = {
                                to: doc.data().Email,
                                from: 'hello@loveafghan.com',
                                subject: 'Matches Waiting For You!',
                                templateId: 'd-575c61e1e211405589642689c0465f28',
                                dynamic_template_data: {
                                    name: doc.data().UserName,
                                }
                            };
                        return sgMail.send(msg);
                        } else {
                            return console.log('User Turned Off the Emails!');
                        }
                    } else {
                        const msg = {
                            to: doc.data().Email,
                            from: 'hello@loveafghan.com',
                            subject: 'Matches Waiting For You!',
                            templateId: 'd-575c61e1e211405589642689c0465f28',
                            dynamic_template_data: {
                                name: doc.data().UserName,
                            }
                        };
                        return sgMail.send(msg);
                    }
                    
                } else {
                    return console.log("User doesn't have email!");
                }
            });
        }
    });

// This Cloud Function sends mail, If user has several matches and user has not reviewed/message their messages. 
exports.sendUnseenMatchMail = functions.pubsub.schedule('* * * * *')
    .timeZone('America/Los_Angeles')
    .onRun(async (context) => {
        const querySnapshot = await admin.firestore().collectionGroup('Matches').where('isRead', '==', false).get();
        if (querySnapshot.empty) {
          return console.log('No matching documents.');
        } else {
            querySnapshot.forEach((doc) => {
                console.log(doc.id);
            });
            return console.log("Done! all catched!");
        }  
});

// This Cloud Function sends mail, 
// exports.sendInCompleteProfileMail = functions.pubsub.schedule('0 0 1-30/3 * *')
//     .timeZone('America/Los_Angeles')
//     .onRun((context) => {
//         const matchesRef = admin.firestore().collection('Users');
        
//         const snapshot = await matchesRef.where('timestamp', '<=', admin.firestore.Timestamp.fromMillis(time)).where('ed', '!=', null).get();
//         if (snapshot.empty) {
//           console.log('No matching documents.');
//           return;
//         }  
//         snapshot.forEach(doc => {
//             if(doc.Email != null) {
//                 const msg = {
//                         to: doc.Email,
//                         from: 'hello@loveafghan.com',
//                         subject: 'Your Profile is Incomplete!',
//                         templateId: 'd-8e03a6f6ebc64e0d872602bb33bf4233',
//                         dynamic_template_data: {
//                             name: doc.UserName,
//                         }
//                     };
//                 sgMail.send(msg);
//             }
//         });
//     // check the profile editInfo node, if it is not complete then check the timestamp if it is longer then or equal to 3 days then send mail.
//     return console.log('This will be run everyday! (daily!)');
// });