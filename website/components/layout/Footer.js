import Link from "next/link";
import Image from "next/image";
import { Mail, Phone, MapPin, Heart } from "lucide-react";
import { db } from "../../lib/firebase";
import { doc, getDoc } from "firebase/firestore";
import "./Footer.css";

async function getFooterSettings() {
  try {
    const docRef = doc(db, 'website_content', 'settings');
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return docSnap.data();
    }
  } catch (error) {
    console.error("Error fetching footer settings:", error);
  }
  return {
    footerEmail: 'contact@hras-ngo.org.pk',
    footerPhone: '+92 (300) 123-4567',
    footerAddress: 'Lahore, Pakistan'
  };
}

export default async function Footer() {
  const settings = await getFooterSettings();

  return (
    <footer className="footer glass-panel" style={{ borderTop: '1px solid var(--magic-1)', marginTop: '40px' }}>
      <div className="container">
        <div className="footer-grid">
          
          {/* 1. Brand & About */}
          <div className="footer-brand-section">
            <Link href="/" className="footer-brand">
              <div className="logo-glow-wrapper-footer">
                <Image 
                  src="/logo.png" 
                  alt="HRAS Logo" 
                  width={48} 
                  height={48} 
                  style={{ objectFit: 'contain' }}
                />
              </div>
              <div className="brand-text-container-footer">
                <span className="brand-title-footer">HRAS</span>
                <span className="brand-subtitle-footer">Hamesha Rahen Aap Ke Sath</span>
              </div>
            </Link>
            <p className="footer-description">
              Empowering local volunteers and creating a direct, transparent impact in communities across Pakistan.
            </p>
            <div className="social-links">
              <a href="#" className="social-icon" aria-label="Facebook">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"></path></svg>
              </a>
              <a href="#" className="social-icon" aria-label="Twitter">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z"></path></svg>
              </a>
              <a href="#" className="social-icon" aria-label="Instagram">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
              </a>
              <a href="#" className="social-icon" aria-label="LinkedIn">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"></path><rect x="2" y="9" width="4" height="12"></rect><circle cx="4" cy="4" r="2"></circle></svg>
              </a>
            </div>
          </div>

          {/* 2. Quick Links */}
          <div className="footer-links-section">
            <h4 className="footer-heading">Quick Links</h4>
            <nav className="footer-nav">
              <Link href="/">Home</Link>
              <Link href="/campaigns">Active Campaigns</Link>
              <Link href="/transparency">Live Transparency Ledger</Link>
              <Link href="/about">About Us</Link>
              <Link href="/impact">Our Impact</Link>
            </nav>
          </div>

          {/* 3. Contact Us */}
          <div className="footer-contact-section">
            <h4 className="footer-heading">Contact Us</h4>
            <div className="contact-list">
              <div className="contact-item">
                <Mail size={18} className="contact-icon" />
                <span>{settings.footerEmail}</span>
              </div>
              <div className="contact-item">
                <Phone size={18} className="contact-icon" />
                <span>{settings.footerPhone}</span>
              </div>
              <div className="contact-item">
                <MapPin size={18} className="contact-icon" />
                <span>{settings.footerAddress}</span>
              </div>
            </div>
          </div>

          {/* 4. Action */}
          <div className="footer-action-section">
            <h4 className="footer-heading">Make a Difference</h4>
            <p className="footer-action-text">Join us in making Pakistan a better place.</p>
            <div className="footer-buttons">
              <Link href="/donate" className="btn btn-primary" style={{ width: '100%', marginBottom: '12px' }}>
                <Heart size={18} /> Donate Now
              </Link>
              <Link href="/volunteer" className="btn btn-outline" style={{ width: '100%' }}>
                Become a Volunteer
              </Link>
            </div>
          </div>

        </div>

        {/* Bottom Bar */}
        <div className="footer-bottom" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '24px' }}>
          <p className="copyright-text" style={{ textShadow: '0 0 10px var(--magic-1)' }}>
            &copy; {new Date().getFullYear()} HRAS. All rights reserved.
          </p>
          <div className="footer-legal" style={{ justifyContent: 'center' }}>
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms of Service</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
