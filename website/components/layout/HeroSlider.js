"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import { ArrowRight, Users } from "lucide-react";
import "./HeroSlider.css";

const SLIDES = [
  {
    id: 1,
    image: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=2070&auto=format&fit=crop",
  },
  {
    id: 2,
    image: "https://images.unsplash.com/photo-1593113565694-c6f87e675622?q=80&w=2070&auto=format&fit=crop",
  },
  {
    id: 3,
    image: "https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?q=80&w=2070&auto=format&fit=crop",
  },
];

export default function HeroSlider({ title, subtitle }) {
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrent((prev) => (prev === SLIDES.length - 1 ? 0 : prev + 1));
    }, 5000); 
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="hero-slider-wrapper">
      <AnimatePresence mode="wait">
        <motion.div
          key={current}
          initial={{ opacity: 0, scale: 1.05 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          className="hero-slide-image"
        >
          <Image
            src={SLIDES[current].image}
            alt="Hero Background"
            fill
            priority
            style={{ objectFit: 'cover' }}
          />
          <div className="hero-overlay"></div>
        </motion.div>
      </AnimatePresence>

      <div className="hero-content">
        <div className="container">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            key={`content-${current}`}
          >
            <h1 className="hero-title">{title}</h1>
            <p className="hero-subtitle">{subtitle}</p>
            
            <div className="hero-actions">
              <Link href="/volunteer" className="btn btn-primary" style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '16px 32px' }}>
                <Users size={20} /> Join the Team
              </Link>
              <Link href="/campaigns" className="btn btn-outline" style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '16px 32px', color: 'white', borderColor: 'rgba(255,255,255,0.3)' }}>
                Donate Now <ArrowRight size={20} />
              </Link>
            </div>
          </motion.div>
        </div>
      </div>
      
      {/* Dots Indicator */}
      <div className="hero-dots">
        {SLIDES.map((_, idx) => (
          <button
            key={idx}
            onClick={() => setCurrent(idx)}
            className={`dot ${idx === current ? 'active' : ''}`}
            aria-label={`Go to slide ${idx + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
