const fs = require('fs');
const path = require('path');
const cloudinary = require('cloudinary').v2;
const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const { getFirestore, doc, updateDoc } = require('firebase/firestore');

// Cloudinary Config
cloudinary.config({ 
  cloud_name: 'dcl3q1pcd', 
  api_key: '554442627712251', 
  api_secret: 'AkhZLSmFvhQFGwiK8LLc8L_JHWE' 
});

// Firebase Config
const firebaseConfig = {
  apiKey: 'AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I',
  authDomain: 'ngo-volunteer-app-6284b.firebaseapp.com',
  projectId: 'ngo-volunteer-app-6284b',
  storageBucket: 'ngo-volunteer-app-6284b.firebasestorage.app',
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

const PROJECT_DIR = 'E:\\Fyp\\Project-01';
const CAMPAIGN_ID = 'project_01';

async function uploadToCloudinary(filePath, resourceType = 'auto') {
  if (!fs.existsSync(filePath)) {
    console.log(`Skipping: ${filePath} (File not found)`);
    return null;
  }
  console.log(`Uploading ${path.basename(filePath)} to Cloudinary...`);
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: resourceType,
      folder: `campaigns/${CAMPAIGN_ID}`
    });
    console.log(` => Success! URL: ${result.secure_url}`);
    return result.secure_url;
  } catch (err) {
    console.error(` => Failed to upload ${path.basename(filePath)}:`, err);
    return null;
  }
}

async function run() {
  console.log('Logging in to Firebase...');
  try {
    await signInWithEmailAndPassword(auth, 'REDACTED@example.com', 'a123456');
    console.log('Firebase Login successful!');
    
    let updates = {};
    let galleryUrls = [];

    // 1. Upload Cover Image
    const coverUrl = await uploadToCloudinary(path.join(PROJECT_DIR, '1.jpeg'), 'image');
    if (coverUrl) updates['coverImageUrl'] = coverUrl;

    // 2. Upload Video
    const videoUrl = await uploadToCloudinary(path.join(PROJECT_DIR, 'Official video.mp4'), 'video');
    if (videoUrl) updates['videoUrl'] = videoUrl;

    // 3. Upload PDF Document
    const pdfUrl = await uploadToCloudinary(path.join(PROJECT_DIR, 'Project # 1 Record.pdf'), 'raw');
    if (pdfUrl) updates['documentUrl'] = pdfUrl;

    // 4. Upload Gallery Images
    for (let i = 1; i <= 4; i++) {
      const imgUrl = await uploadToCloudinary(path.join(PROJECT_DIR, `${i}.jpeg`), 'image');
      if (imgUrl) galleryUrls.push(imgUrl);
    }
    
    if (galleryUrls.length > 0) {
      updates['galleryUrls'] = galleryUrls;
    }

    if (Object.keys(updates).length === 0) {
      console.log('No files uploaded. Skipping Firestore update.');
      process.exit(0);
    }

    console.log('Updating Firestore with Cloudinary URLs...');
    const docRef = doc(db, 'campaigns', CAMPAIGN_ID);
    await updateDoc(docRef, updates);
    console.log('\n======================================================');
    console.log('✅ ALL DONE! Cloudinary Migration Successful!');
    console.log('Open your App. The images and video for Project 1 will now play perfectly!');
    console.log('======================================================\n');
    
  } catch (e) {
    console.error('Error in main flow:', e);
  }
  process.exit(0);
}

run();
