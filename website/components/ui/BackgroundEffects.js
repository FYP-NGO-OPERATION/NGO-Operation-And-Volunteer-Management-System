'use client';

import React, { useEffect, useState } from 'react';

export default function BackgroundEffects() {
  const [mounted, setMounted] = useState(false);
  const [stars, setStars] = useState([]);

  useEffect(() => {
    setMounted(true);
    // Generate static stars once on mount to avoid hydration mismatch and keep CPU low
    const generatedStars = Array.from({ length: 20 }).map((_, i) => {
      const top = Math.random() * 100;
      const left = Math.random() * 100;
      const size = 3 + Math.random() * 4;
      const duration = 3 + Math.random() * 4;
      const delay = Math.random() * 5;
      
      const colors = [
        'rgba(255, 255, 255, 0.9)', 
        'rgba(255, 255, 150, 0.9)', 
        'rgba(150, 255, 255, 0.9)', 
        'rgba(150, 255, 150, 0.9)'
      ];
      const color = colors[i % colors.length];

      return { id: i, top, left, size, duration, delay, color };
    });
    setStars(generatedStars);
  }, []);

  return (
    <div style={{ 
      position: 'fixed', 
      top: 0, 
      left: 0, 
      width: '100vw', 
      height: '100vh', 
      zIndex: -1, 
      overflow: 'hidden', 
      pointerEvents: 'none',
      background: 'var(--bg-gradient)',
      transition: 'background 0.5s ease'
    }}>
      
      <style dangerouslySetInnerHTML={{__html: `
        .magical-star {
          position: absolute;
          border-radius: 50%;
          will-change: transform, opacity;
          animation: twinkle alternate infinite ease-in-out;
        }

        .slow-beam {
          position: absolute;
          border-radius: 50%;
          will-change: transform;
          opacity: 0.15;
        }

        @keyframes twinkle {
          0% { transform: scale(0.8); opacity: 0.1; }
          100% { transform: scale(1.5); opacity: 0.8; }
        }

        @keyframes beamMove1 {
          0% { transform: translate3d(-20vw, -20vh, 0); }
          50% { transform: translate3d(50vw, 30vh, 0) scale(1.2); }
          100% { transform: translate3d(-20vw, -20vh, 0); }
        }

        @keyframes beamMove2 {
          0% { transform: translate3d(80vw, 60vh, 0); }
          50% { transform: translate3d(-10vw, 10vh, 0) scale(1.1); }
          100% { transform: translate3d(80vw, 60vh, 0); }
        }
      `}} />

      {/* Slow Moving Beams (Zero Lag) */}
      <div className="slow-beam" style={{
        top: 0, left: 0, width: '100vw', height: '100vh',
        background: 'radial-gradient(circle, var(--magic-1) 0%, transparent 50%)',
        animation: 'beamMove1 50s linear infinite'
      }} />
      <div className="slow-beam" style={{
        top: 0, left: 0, width: '100vw', height: '100vh',
        background: 'radial-gradient(circle, var(--magic-2) 0%, transparent 50%)',
        animation: 'beamMove2 65s linear infinite'
      }} />

      {mounted && stars.map((star) => (
        <div 
          key={star.id}
          className="magical-star" 
          style={{
            top: `${star.top}vh`,
            left: `${star.left}vw`,
            width: star.size,
            height: star.size,
            backgroundColor: star.color,
            boxShadow: `0 0 ${star.size * 2}px ${star.size}px ${star.color.replace('0.9', '0.4')}`,
            animationDuration: `${star.duration}s`,
            animationDelay: `-${star.delay}s`
          }} 
        />
      ))}
      
      {/* Soft glass overlay to tie it together */}
      <div style={{
        position: 'absolute',
        inset: 0,
        backdropFilter: 'blur(2px)',
        WebkitBackdropFilter: 'blur(2px)',
        backgroundColor: 'rgba(0,0,0,0.05)',
      }} />
    </div>
  );
}
