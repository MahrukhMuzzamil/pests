const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

const db = admin.firestore();

function haversineMiles(lat1, lon1, lat2, lon2) {
  const R = 3958.8; // Earth radius in miles
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

exports.sendJobAlertEmails = functions.https.onCall(async (data, context) => {
  const jobId = data.jobId;
  if (!jobId) {
    throw new functions.https.HttpsError('invalid-argument', 'jobId is required');
  }

  const sendgridKey = process.env.SENDGRID_API_KEY || (await functions.config().sendgrid?.key);
  if (!sendgridKey) {
    throw new functions.https.HttpsError('failed-precondition', 'SENDGRID_API_KEY not configured');
  }
  sgMail.setApiKey(sendgridKey);

  const jobSnap = await db.collection('jobs').doc(jobId).get();
  if (!jobSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Job not found');
  }
  const job = jobSnap.data();

  const jobLat = job.latitude;
  const jobLon = job.longitude;

  const usersSnap = await db.collection('users')
    .where('accountType', '==', 'serviceProvider')
    .get();

  const emails = [];
  usersSnap.forEach(doc => {
    const user = doc.data();
    if (typeof user.latitude === 'number' && typeof user.longitude === 'number' && user.email) {
      const miles = haversineMiles(jobLat, jobLon, user.latitude, user.longitude);
      if (miles <= 100) {
        emails.push(user.email);
      }
    }
  });

  if (emails.length === 0) {
    return { delivered: 0 };
  }

  const msg = {
    to: emails,
    from: 'alerts@pests247.com',
    subject: `New Job: ${job.title}`,
    text: `${job.description}\nLocation: ${job.locationText}`,
    html: `<p>${job.description}</p><p><strong>Location:</strong> ${job.locationText}</p>`,
  };

  await sgMail.sendMultiple(msg);
  return { delivered: emails.length };
});