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
      <div className="container h-full">
        <div className="navbar-content">
          {/* 1. Left - Logo */}
          <Link href="/" className="navbar-brand">
            <div className="logo-glow-wrapper">
              <Image 
                src="/logo.png" 
                alt="HRAS Logo" 
                width={45} 
                height={45} 
                style={{ objectFit: 'contain' }}
              />
            </div>
            <div className="brand-text-container">
              <span className="brand-title">HRAS</span>
              <span className="brand-subtitle">Hamesha Rahen Aap Ke Sath</span>
            </div>
          </Link>

          {/* 2. Center - Navigation Links */}
          <nav className="navbar-links desktop-only">
            {navLinks.map((link) => (
              <Link key={link.name} href={link.href} className="nav-link">
                {link.name}
              </Link>
            ))}
          </nav>

          {/* 3. Right - Actions */}
          <div className="navbar-actions desktop-only">
            {mounted && (
              <button 
                onClick={toggleTheme} 
                className="theme-toggle" 
                aria-label="Toggle Dark Mode"
              >
                {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
              </button>
            )}
            <Link href="/volunteer" className="btn btn-outline">
              Volunteer
            </Link>
            <Link href="/donate" className="btn btn-primary">
              <Heart size={18} /> Donate
            </Link>
          </div>

          {/* Mobile Toggle */}
          <div className="mobile-toggle-container mobile-only">
            {mounted && (
              <button 
                onClick={toggleTheme} 
                className="theme-toggle" 
                aria-label="Toggle Dark Mode"
              >
                {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
              </button>
            )}
            <button
              className="mobile-menu-btn"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
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
                <Link href="/volunteer" className="btn btn-outline" style={{ width: '100%' }}>
                  Volunteer
                </Link>
                <Link href="/donate" className="btn btn-primary" style={{ width: '100%' }}>
                  <Heart size={18} /> Donate Now
                </Link>
              </div>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  );
}
