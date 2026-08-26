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
    <footer className="footer">
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
            <p className="brand-fullname">Humanitarian Relief and Aid Society</p>
            <p className="footer-description">
              Empowering local volunteers and creating a direct, transparent impact in communities across Pakistan.
            </p>
            <div className="social-links">
              <a href="#" className="social-icon">Fb</a>
              <a href="#" className="social-icon">Tw</a>
              <a href="#" className="social-icon">Ig</a>
              <a href="#" className="social-icon">In</a>
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
        <div className="footer-bottom">
          <p>&copy; {new Date().getFullYear()} Humanitarian Relief and Aid Society. All rights reserved.</p>
          <div className="footer-legal">
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms of Service</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
