"use client";

import Link from "next/link";
import { Shield, Mail, Phone, MapPin } from "lucide-react";
import "./Footer.css";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer glass-panel">
      <div className="container footer-container">
        <div className="footer-grid">
          {/* Brand */}
          <div className="footer-brand">
            <Link href="/" className="footer-logo">
              <Shield className="logo-icon" size={32} />
              <span className="logo-text">HRAS</span>
            </Link>
            <p className="footer-description">
              Humanitarian Relief and Aid Society. Empowering volunteers and connecting donors to make a real, transparent impact in communities worldwide.
            </p>
            <div className="social-links">
              <a href="#" aria-label="Facebook">Fb</a>
              <a href="#" aria-label="Twitter">Tw</a>
              <a href="#" aria-label="Instagram">Ig</a>
              <a href="#" aria-label="LinkedIn">In</a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="footer-links">
            <h3>Quick Links</h3>
            <ul>
              <li><Link href="/">Home</Link></li>
              <li><Link href="/campaigns">Active Campaigns</Link></li>
              <li><Link href="/transparency">Transparency Ledger</Link></li>
              <li><Link href="/about">About Us</Link></li>
            </ul>
          </div>

          {/* Contact */}
          <div className="footer-contact">
            <h3>Contact Us</h3>
            <ul>
              <li>
                <Mail size={16} className="contact-icon" />
                <a href="mailto:contact@hras-ngo.org">contact@hras-ngo.org</a>
              </li>
              <li>
                <Phone size={16} className="contact-icon" />
                <span>+92 (300) 123-4567</span>
              </li>
              <li>
                <MapPin size={16} className="contact-icon" />
                <span>123 Relief Street, Future City, PK</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="footer-bottom">
          <p>&copy; {currentYear} Humanitarian Relief and Aid Society (HRAS). All rights reserved.</p>
          <div className="footer-legal">
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms of Service</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
