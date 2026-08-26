import React from 'react';

export default function BackgroundEffects() {
  return (
    <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', zIndex: -1, overflow: 'hidden', pointerEvents: 'none' }}>
      
      <style dangerouslySetInnerHTML={{__html: `
        .orb {
          position: absolute;
          border-radius: 50%;
          mix-blend-mode: screen;
          will-change: transform, opacity;
        }

        /* 
          Using translate3d for hardware acceleration (GPU).
          No expensive CSS filters (like blur) are used. 
          The radial-gradient's soft edges simulate the blur with ~0% CPU cost.
        */
        @keyframes float-1 {
          0% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.1; }
          33% { transform: translate3d(20vw, 30vh, 0) scale(1.2); opacity: 0.5; }
          66% { transform: translate3d(-20vw, 10vh, 0) scale(0.8); opacity: 0.2; }
          100% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.1; }
        }

        @keyframes float-2 {
          0% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.2; }
          33% { transform: translate3d(-30vw, -20vh, 0) scale(0.9); opacity: 0.6; }
          66% { transform: translate3d(10vw, -40vh, 0) scale(1.1); opacity: 0.3; }
          100% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.2; }
        }

        @keyframes float-3 {
          0% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.1; }
          33% { transform: translate3d(40vw, -10vh, 0) scale(1.1); opacity: 0.4; }
          66% { transform: translate3d(-10vw, -30vh, 0) scale(0.9); opacity: 0.2; }
          100% { transform: translate3d(0, 0, 0) scale(1); opacity: 0.1; }
        }
      `}} />

      {/* Orb 1 - Emerald */}
      <div className="orb" style={{
        top: '-20vh',
        left: '-10vw',
        width: '80vw',
        height: '80vw',
        background: 'radial-gradient(circle, var(--magic-1) 0%, rgba(16, 185, 129, 0) 60%)',
        animation: 'float-1 30s ease-in-out infinite',
      }} />

      {/* Orb 2 - Cyan */}
      <div className="orb" style={{
        top: '30vh',
        right: '-20vw',
        width: '90vw',
        height: '90vw',
        background: 'radial-gradient(circle, var(--magic-2) 0%, rgba(56, 189, 248, 0) 60%)',
        animation: 'float-2 40s ease-in-out infinite',
      }} />

      {/* Orb 3 - Purple */}
      <div className="orb" style={{
        bottom: '-30vh',
        left: '10vw',
        width: '85vw',
        height: '85vw',
        background: 'radial-gradient(circle, var(--magic-3) 0%, rgba(168, 85, 247, 0) 60%)',
        animation: 'float-3 35s ease-in-out infinite',
      }} />
      
      {/* Optional: Lightweight static noise overlay for texture (if it still lags, this can be removed, but it's static so it's usually fine) */}
      <div style={{
        position: 'absolute',
        inset: 0,
        opacity: 0.03,
        backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E")',
        mixBlendMode: 'overlay',
      }} />
    </div>
  );
}
