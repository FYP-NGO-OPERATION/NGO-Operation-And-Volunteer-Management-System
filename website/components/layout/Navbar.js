"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useTheme } from "next-themes";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Heart, Sun, Moon } from "lucide-react";
import "./Navbar.css";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { name: "Campaigns", href: "/campaigns" },
    { name: "Our Impact", href: "/impact" },
    { name: "Transparency", href: "/transparency" },
    { name: "About", href: "/about" },
  ];

  const toggleTheme = () => {
    setTheme(theme === "dark" ? "light" : "dark");
  };

  return (
    <motion.header
      className={`navbar ${scrolled ? "navbar-scrolled" : ""}`}
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
    >
      <div className="navbar-container">
        {/* Logo */}
        <Link href="/" className="logo-container" style={{ display: 'flex', alignItems: 'center', textDecoration: 'none', color: 'inherit' }}>
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

        {/* Desktop Nav */}
        <nav className="navbar-links desktop-only">
          {navLinks.map((link) => (
            <Link key={link.name} href={link.href} className="nav-link">
              {link.name}
            </Link>
          ))}
        </nav>

        {/* Desktop Actions */}
        <div className="navbar-actions desktop-only">
          {mounted && (
            <button 
              onClick={toggleTheme} 
              className="theme-toggle" 
              aria-label="Toggle Dark Mode"
              style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', cursor: 'pointer', padding: '8px' }}
            >
              {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
            </button>
          )}
          <Link href="/volunteer" className="btn btn-outline">
            Volunteer
          </Link>
          <Link href="/donate" className="btn btn-primary glass-panel">
            <Heart size={18} />
            Donate
          </Link>
        </div>

        {/* Mobile Toggle */}
        <div className="mobile-actions mobile-only" style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          {mounted && (
            <button 
              onClick={toggleTheme} 
              className="theme-toggle" 
              aria-label="Toggle Dark Mode"
              style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', cursor: 'pointer' }}
            >
              {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
            </button>
          )}
          <button
            className="mobile-toggle"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            className="mobile-menu glass-panel mobile-only"
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
          >
            <nav className="mobile-nav-links">
              {navLinks.map((link) => (
                <Link
                  key={link.name}
                  href={link.href}
                  className="mobile-nav-link"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  {link.name}
                </Link>
              ))}
              <div className="mobile-nav-actions">
                <Link href="/volunteer" className="btn btn-outline full-width">
                  Become a Volunteer
                </Link>
                <Link href="/donate" className="btn btn-primary full-width">
                  <Heart size={18} />
                  Donate Now
                </Link>
              </div>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  );
}
