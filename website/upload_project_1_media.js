const fs = require('fs');
const path = require('path');
const { initializeApp } = require('firebase/app');
const { getStorage, ref, uploadBytes, getDownloadURL } = require('firebase/storage');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const { getFirestore, doc, updateDoc } = require('firebase/firestore');

const config = {
  apiKey: 'AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I',
  authDomain: 'ngo-volunteer-app-6284b.firebaseapp.com',
  projectId: 'ngo-volunteer-app-6284b',
  storageBucket: 'ngo-volunteer-app-6284b.firebasestorage.app',
};

const app = initializeApp(config);
const storage = getStorage(app);
const auth = getAuth(app);
const db = getFirestore(app);

const PROJECT_DIR = 'E:\\Fyp\\Project-01';
const CAMPAIGN_ID = 'project_01';

const filesToUpload = [
  { file: 'Official video.mp4', key: 'videoUrl' },
  { file: 'Project # 1 Record.pdf', key: 'documentUrl' },
  { file: '1.jpeg', key: 'coverImageUrl' }
];

async function run() {
  console.log('Logging in to Firebase...');
  try {
    await signInWithEmailAndPassword(auth, 'REDACTED@example.com', 'a123456');
    console.log('Login successful!');
    
    let updates = {};
    let galleryUrls = [];

    // Upload specific files
    for (let item of filesToUpload) {
      const filePath = path.join(PROJECT_DIR, item.file);
      if (fs.existsSync(filePath)) {
        console.log(`Uploading ${item.file}...`);
        const storageRef = ref(storage, `campaigns/${CAMPAIGN_ID}/${item.file}`);
        const buffer = fs.readFileSync(filePath);
        const data = new Uint8Array(buffer);
        await uploadBytes(storageRef, data);
        const url = await getDownloadURL(storageRef);
        updates[item.key] = url;
        console.log(` => Success!`);
      } else {
        console.log(`Skipping ${item.file} (Not found)`);
      }
    }

    // Upload gallery images
    for (let i = 1; i <= 4; i++) {
      const filename = `${i}.jpeg`;
      const filePath = path.join(PROJECT_DIR, filename);
      if (fs.existsSync(filePath)) {
        console.log(`Uploading gallery image ${filename}...`);
        const storageRef = ref(storage, `campaigns/${CAMPAIGN_ID}/gallery_${i}.jpeg`);
        const buffer = fs.readFileSync(filePath);
        const data = new Uint8Array(buffer);
        await uploadBytes(storageRef, data);
        const url = await getDownloadURL(storageRef);
        galleryUrls.push(url);
        console.log(` => Success!`);
      }
    }
    
    if (galleryUrls.length > 0) {
      updates['galleryUrls'] = galleryUrls;
    }

    console.log('Updating Firestore...');
    const docRef = doc(db, 'campaigns', CAMPAIGN_ID);
    await updateDoc(docRef, updates);
    console.log('ALL DONE! Media is now visible in the App!');
    
  } catch (e) {
    if (e.code === 'storage/unknown' || e.status_ === 404) {
      console.log('\n======================================================');
      console.log('❌ ERROR: FIREBASE STORAGE BUCKET DOES NOT EXIST!');
      console.log('Please go to Firebase Console -> Build -> Storage');
      console.log('Click "Get Started", accept the defaults, and try again.');
      console.log('======================================================\n');
    } else {
      console.error('Error:', e);
    }
  }
  process.exit(0);
}

run();
