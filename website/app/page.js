import styles from "./page.module.css";

export default function Home() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1 style={{ color: '#2E7D32', fontSize: '48px', marginBottom: '8px' }}>
            HRAS NGO
          </h1>
          <h2 style={{ color: '#555', fontWeight: '500' }}>
            Hamesha Rahein Apke Saath
          </h2>
          <p style={{ marginTop: '20px' }}>
            Welcome to the public portal for the HRAS Volunteer Management System.
            <br />
            Our unified platform empowers volunteers and transparency in donations.
          </p>
        </div>
        
        <div className={styles.ctas} style={{ marginTop: '40px' }}>
          <div style={{ padding: '12px 24px', background: '#2E7D32', color: 'white', borderRadius: '8px', fontWeight: 'bold' }}>
            Public Portal Coming Soon (FYP-02)
          </div>
          <div style={{ padding: '12px 24px', border: '1px solid #ccc', borderRadius: '8px', fontWeight: 'bold' }}>
            Admin App Active
          </div>
        </div>
      </main>
    </div>
  );
}
