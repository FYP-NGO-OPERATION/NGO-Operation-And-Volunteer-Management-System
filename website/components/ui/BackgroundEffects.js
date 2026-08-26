'use client';

import React, { useEffect, useState } from 'react';

export default function BackgroundEffects() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', zIndex: -1, overflow: 'hidden', pointerEvents: 'none' }}>
      
      {/* Orb 1 - Emerald */}
      <div style={{
        position: 'absolute',
        top: '-10%',
        left: '-10%',
        width: '50vw',
        height: '50vw',
        background: 'radial-gradient(circle, var(--magic-1) 0%, transparent 60%)',
        filter: 'blur(80px)',
        animation: 'orb-float-1 20s ease-in-out infinite alternate',
      }} />

      {/* Orb 2 - Cyan */}
      <div style={{
        position: 'absolute',
        top: '40%',
        right: '-10%',
        width: '60vw',
        height: '60vw',
        background: 'radial-gradient(circle, var(--magic-2) 0%, transparent 70%)',
        filter: 'blur(100px)',
        animation: 'orb-float-2 25s ease-in-out infinite alternate',
      }} />

      {/* Orb 3 - Purple */}
      <div style={{
        position: 'absolute',
        bottom: '-20%',
        left: '20%',
        width: '70vw',
        height: '70vw',
        background: 'radial-gradient(circle, var(--magic-3) 0%, transparent 70%)',
        filter: 'blur(120px)',
        animation: 'orb-float-3 30s ease-in-out infinite alternate',
      }} />

      {/* Ambient noise overlay for texture */}
      <div style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        opacity: 0.03,
        backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E")',
        mixBlendMode: 'overlay',
      }} />
    </div>
  );
}
