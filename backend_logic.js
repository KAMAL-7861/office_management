/**
 * Cloud Function: checkLateArrival
 * Trigger: onCreate in 'attendance' collection
 */

// exports.checkLateArrival = functions.firestore
//     .document('attendance/{id}')
//     .onCreate(async (snapshot, context) => {
//         const data = snapshot.data();
//         const checkInTime = data.checkIn.toDate();
//         const cutoffTime = new Date(checkInTime);
//         cutoffTime.setHours(9, 0, 0); // 9:00 AM cutoff

//         if (checkInTime > cutoffTime) {
//             await snapshot.ref.update({ status: 'late' });
//             
//             // Send push notification to HR/Manager
//             const payload = {
//                 notification: {
//                     title: 'Late Arrival',
//                     body: `${data.userName} checked in late at ${checkInTime.toLocaleTimeString()}`
//                 }
//             };
//             await admin.messaging().sendToTopic('admin_notifications', payload);
//         }
//     });

/**
 * Cloud Function: preventDuplicateCheckIn
 * Trigger: onCreate in 'attendance' collection
 * Logic: Check if user already has a check-in for the same date.
 */
