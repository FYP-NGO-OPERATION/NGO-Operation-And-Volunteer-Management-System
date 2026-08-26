"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { Heart, ArrowRight } from "lucide-react";
import "./HeroSlider.css";

const SLIDES = [
  {
    id: 1,
    title: "Respond to Emergencies",
    subtitle: "Join our rapid response teams providing critical aid on the ground in disaster zones.",
    image: "https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?q=80&w=2070&auto=format&fit=crop", 
  },
  {
    id: 2,
    title: "Empower Communities",
    subtitle: "Provide clean water, education, and sustainable infrastructure to those in need.",
    image: "https://images.unsplash.com/photo-1593113565694-c6b87e248b4f?q=80&w=2070&auto=format&fit=crop", 
  },
  {
    id: 3,
    title: "Radical Transparency",
    subtitle: "Track every single dollar you donate through our live, public financial ledger.",
    image: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=2070&auto=format&fit=crop",
  },
];

export default function HeroSlider() {
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrent((prev) => (prev === SLIDES.length - 1 ? 0 : prev + 1));
    }, 3000); // 3 seconds as requested
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="hero-slider-wrapper">
      <AnimatePresence initial={false}>
        <motion.div
          key={current}
          className="hero-slide-bg"
          initial={{ opacity: 0, scale: 1.05 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 1.2, ease: "easeInOut" }}
        >
          <Image
            src={SLIDES[current].image}
            alt={SLIDES[current].title}
            fill
            priority
            style={{ objectFit: 'cover' }}
            sizes="100vw"
            quality={90}
          />
          {/* Advanced Dark Overlay for perfect text contrast */}
          <div className="hero-overlay"></div>
        </motion.div>
      </AnimatePresence>

      <div className="hero-content container">
        <AnimatePresence mode="wait">
          <motion.div
            key={current}
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -30 }}
            transition={{ duration: 0.5, ease: "easeOut", staggerChildren: 0.1 }}
            className="hero-text-block"
          >
            <motion.h1 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="hero-title"
            >
              {SLIDES[current].title}
            </motion.h1>
            
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="hero-subtitle"
            >
              {SLIDES[current].subtitle}
            </motion.p>
            
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="hero-actions"
            >
              <Link href="/volunteer" className="btn btn-primary" style={{ padding: '16px 32px', fontSize: '1.1rem' }}>
                Join the Team
              </Link>
              <Link href="/campaigns" className="btn btn-outline hero-btn-glass" style={{ padding: '16px 32px', fontSize: '1.1rem', color: 'white', borderColor: 'rgba(255,255,255,0.5)' }}>
                Donate Now <ArrowRight size={18} />
              </Link>
            </motion.div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Modern Indicators */}
      <div className="hero-indicators">
        {SLIDES.map((_, idx) => (
          <button
            key={idx}
            className={`indicator-dot ${current === idx ? "active" : ""}`}
            onClick={() => setCurrent(idx)}
            aria-label={`Go to slide ${idx + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
