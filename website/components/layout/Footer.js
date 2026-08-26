import Link from "next/link";
import Image from "next/image";
import { Mail, Phone, MapPin, Heart } from "lucide-react";
import "./Footer.css";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-grid">
          
          {/* Brand & About */}
          <div className="footer-brand">
            <Link href="/" className="footer-logo" style={{ display: 'flex', alignItems: 'center', textDecoration: 'none', color: 'inherit', marginBottom: '20px' }}>
              <div style={{
                backgroundColor: 'white',
                borderRadius: '50%',
                overflow: 'hidden',
                width: 45,
                height: 45,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 0 15px 3px rgba(251, 191, 36, 0.4)', // Amber glow
                transition: 'all 0.3s ease'
              }}>
                <Image 
                  src="/logo.png" 
                  alt="HRAS Logo" 
                  width={45} 
                  height={45} 
                  style={{ objectFit: 'contain', filter: 'brightness(1.1)' }}
                />
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', marginLeft: '12px' }}>
                <span className="logo-text" style={{ fontSize: '1.4rem', fontWeight: 800, lineHeight: 1 }}>HRAS</span>
                <span style={{ fontSize: '0.65rem', fontWeight: 600, color: 'var(--accent)', letterSpacing: '0.5px', marginTop: '2px' }}>Hamesha Rahen Aap Ke Sath</span>
              </div>
            </Link>
            <p className="brand-fullname" style={{ marginTop: '-10px' }}>Humanitarian Relief and Aid Society</p>
            <p className="footer-description">
              Empowering local volunteers and connecting global donors to make a real, completely transparent impact in communities worldwide.
            </p>
            <div className="social-links" style={{ gap: '10px' }}>
              <a href="#" className="social-icon" aria-label="Facebook">Fb</a>
              <a href="#" className="social-icon" aria-label="Twitter">Tw</a>
              <a href="#" className="social-icon" aria-label="Instagram">Ig</a>
              <a href="#" className="social-icon" aria-label="LinkedIn">In</a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="footer-links">
            <h4 className="footer-heading">Quick Links</h4>
            <ul>
              <li><Link href="/">Home</Link></li>
              <li><Link href="/campaigns">Active Campaigns</Link></li>
              <li><Link href="/transparency">Live Transparency Ledger</Link></li>
              <li><Link href="/about">About Us</Link></li>
              <li><Link href="/impact">Our Impact</Link></li>
            </ul>
          </div>

          {/* Contact Info */}
          <div className="footer-contact">
            <h4 className="footer-heading">Contact Us</h4>
            <ul>
              <li>
                <Mail size={18} className="contact-icon" />
                <a href="mailto:contact@hras-ngo.org">contact@hras-ngo.org</a>
              </li>
              <li>
                <Phone size={18} className="contact-icon" />
                <span>+92 (300) 123-4567</span>
              </li>
              <li>
                <MapPin size={18} className="contact-icon" />
                <span>123 Relief Street, Future City, PK</span>
              </li>
            </ul>
          </div>
          
          {/* CTA Area */}
          <div className="footer-cta">
             <h4 className="footer-heading">Make a Difference</h4>
             <p style={{ color: 'var(--text-secondary)', marginBottom: '15px', fontSize: '0.9rem' }}>Join thousands of others in our mission.</p>
             <Link href="/campaigns" className="btn btn-primary full-width" style={{ display: 'flex', justifyContent: 'center' }}>
               <Heart size={16} /> Donate Now
             </Link>
             <div style={{ marginTop: '15px' }}>
               <Link href="/volunteer" className="btn btn-outline full-width" style={{ display: 'flex', justifyContent: 'center' }}>
                 Become a Volunteer
               </Link>
             </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p>&copy; {new Date().getFullYear()} Humanitarian Relief and Aid Society. All rights reserved.</p>
          <div className="footer-bottom-links">
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms of Service</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
