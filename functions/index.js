const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
const db = admin.firestore();

// Configure via Firestore config document or env var
async function getSendgridKey() {
  try {
    const snap = await db.collection('config').doc('email').get();
    if (snap.exists) {
      const data = snap.data();
      if (data && data.sendgridApiKey) return data.sendgridApiKey;
    }
  } catch (_) {}
  return process.env.SENDGRID_API_KEY || '';
}

function milesBetween(lat1, lon1, lat2, lon2) {
  const R = 3958.8; // miles
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

exports.onJobCreatedEmailProviders = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snap, context) => {
    const job = snap.data();
    const lat = Number(job.latitude || 0);
    const lon = Number(job.longitude || 0);
    if (!lat || !lon) return;

    const sendgridKey = await getSendgridKey();
    if (!sendgridKey) return;
    sgMail.setApiKey(sendgridKey);

    // Fetch providers with coords
    const usersSnap = await db.collection('users').where('accountType', '==', 'serviceProvider').get();
    const toEmail = [];
    usersSnap.forEach((doc) => {
      const data = doc.data();
      const info = data.companyInfo || {};
      const plat = Number(info.latitude || 0);
      const plon = Number(info.longitude || 0);
      const email = data.email;
      if (!email || !plat || !plon) return;
      const dist = milesBetween(lat, lon, plat, plon);
      if (dist <= 100) {
        toEmail.push(email);
      }
    });

    if (toEmail.length === 0) return;

    const msg = {
      to: toEmail,
      from: { email: 'alerts@pests247.com', name: 'Pests247 Alerts' },
      subject: `New nearby job: ${job.title || 'Pest control job'}`,
      text: `${job.description || ''}\nLocation: ${job.city || ''}, ${job.state || ''} ${job.postalCode || ''}`,
    };
    await sgMail.send(msg, false);
  });


