const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onEntryAdded = functions.firestore
    .document('entries/{entryId}')
    .onCreate((snapshot, context) => {
        const entryData = snapshot.data();
        const entryId = entryData.entryId;

        // TODO: Implement your logic here to send notifications or perform other actions based on the entry ID.
        console.log(`New entry added with ID: ${entryId}`);
        return null;
    });
