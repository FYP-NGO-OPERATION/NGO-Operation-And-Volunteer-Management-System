'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

export default function BackgroundEffects() {
  const [mounted, setMounted] = useState(false);
  const [windowSize, setWindowSize] = useState({ width: 1000, height: 1000 });

  useEffect(() => {
    setMounted(true);
    setWindowSize({ width: window.innerWidth, height: window.innerHeight });
    
    const handleResize = () => setWindowSize({ width: window.innerWidth, height: window.innerHeight });
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  if (!mounted) return null;

  const orbs = [
    { color: 'var(--magic-1)', size: 600, blur: 120, duration: 25 },
    { color: 'var(--magic-2)', size: 800, blur: 150, duration: 35 },
    { color: 'var(--magic-3)', size: 700, blur: 130, duration: 30 },
    { color: 'var(--magic-1)', size: 500, blur: 100, duration: 20 },
  ];

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', zIndex: -1, overflow: 'hidden', pointerEvents: 'none' }}>
      
      {orbs.map((orb, i) => {
        // Generate random keyframes based on window size
        const xKeyframes = Array.from({ length: 5 }, () => Math.random() * windowSize.width - (orb.size / 2));
        const yKeyframes = Array.from({ length: 5 }, () => Math.random() * windowSize.height - (orb.size / 2));
        const opacityKeyframes = Array.from({ length: 5 }, () => Math.random() * 0.6 + 0.1); // 0.1 to 0.7

        return (
          <motion.div
            key={i}
            style={{
              position: 'absolute',
              width: orb.size,
              height: orb.size,
              background: `radial-gradient(circle, ${orb.color} 0%, transparent 70%)`,
              filter: `blur(${orb.blur}px)`,
              borderRadius: '50%',
              mixBlendMode: 'screen', // Makes colors pop better in dark mode
            }}
            initial={{
              x: xKeyframes[0],
              y: yKeyframes[0],
              opacity: 0,
            }}
            animate={{
              x: xKeyframes,
              y: yKeyframes,
              opacity: opacityKeyframes,
            }}
            transition={{
              duration: orb.duration,
              repeat: Infinity,
              repeatType: 'mirror',
              ease: "easeInOut",
            }}
          />
        );
      })}

      {/* Ambient noise overlay for texture */}
      <div style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        opacity: 0.04,
        backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E")',
        mixBlendMode: 'overlay',
      }} />
    </div>
  );
}
