'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Quote } from 'lucide-react';
import Image from 'next/image';

const TESTIMONIALS = [
  {
    id: 1,
    quote: "Seeing the exact moment my donation bought food for a family in need completely changed my perspective on charity.",
    author: "Michael T.",
    role: "Regular Donor",
    image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=150&h=150"
  },
  {
    id: 2,
    quote: "Being a volunteer on the ground and reporting back instantly via the app ensures our work is seen and trusted.",
    author: "Ayesha R.",
    role: "Field Volunteer",
    image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=150&h=150"
  },
  {
    id: 3,
    quote: "The 100% transparency model is revolutionary. Finally, an NGO that shows the ledger openly to the world.",
    author: "David Chen",
    role: "Philanthropist",
    image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150&h=150"
  }
];

export default function TestimonialCarousel() {
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % TESTIMONIALS.length);
    }, 6000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div style={{ position: 'relative', width: '100%', maxWidth: '800px', margin: '0 auto', height: '350px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <AnimatePresence mode="wait">
        <motion.div
          key={currentIndex}
          initial={{ opacity: 0, y: 20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: -20, scale: 0.95 }}
          transition={{ duration: 0.5, ease: "easeOut" }}
          style={{ width: '100%', position: 'absolute' }}
        >
          <div className="glass-panel" style={{ padding: '48px', borderRadius: '32px', textAlign: 'center', position: 'relative' }}>
            <Quote size={48} color="var(--primary)" style={{ opacity: 0.2, position: 'absolute', top: '24px', left: '24px' }} />
            
            <p style={{ fontSize: '1.5rem', fontWeight: 600, color: 'var(--text-primary)', lineHeight: 1.6, marginBottom: '32px', fontStyle: 'italic' }}>
              "{TESTIMONIALS[currentIndex].quote}"
            </p>
            
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '16px' }}>
              <div style={{ width: '60px', height: '60px', borderRadius: '50%', overflow: 'hidden', position: 'relative', border: '2px solid var(--primary)' }}>
                <Image src={TESTIMONIALS[currentIndex].image} alt={TESTIMONIALS[currentIndex].author} fill style={{ objectFit: 'cover' }} />
              </div>
              <div style={{ textAlign: 'left' }}>
                <h4 style={{ margin: 0, fontSize: '1.1rem', fontWeight: 800, color: 'var(--text-primary)' }}>{TESTIMONIALS[currentIndex].author}</h4>
                <p style={{ margin: 0, fontSize: '0.9rem', color: 'var(--primary)' }}>{TESTIMONIALS[currentIndex].role}</p>
              </div>
            </div>
          </div>
        </motion.div>
      </AnimatePresence>

      <div style={{ position: 'absolute', bottom: '-40px', display: 'flex', gap: '8px' }}>
        {TESTIMONIALS.map((_, idx) => (
          <button
            key={idx}
            onClick={() => setCurrentIndex(idx)}
            style={{
              width: idx === currentIndex ? '32px' : '8px',
              height: '8px',
              borderRadius: '4px',
              backgroundColor: idx === currentIndex ? 'var(--primary)' : 'var(--text-hint)',
              border: 'none',
              transition: 'all 0.3s ease',
              cursor: 'pointer',
              padding: 0
            }}
          />
        ))}
      </div>
    </div>
  );
}
