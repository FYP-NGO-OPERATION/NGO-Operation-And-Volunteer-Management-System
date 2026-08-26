'use client';

import React, { useRef, useState } from 'react';

export default function GlowingCard({ children, className = '', style = {} }) {
  const divRef = useRef(null);
  const [isFocused, setIsFocused] = useState(false);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [opacity, setOpacity] = useState(0);

  const handleMouseMove = (e) => {
    if (!divRef.current || isFocused) return;

    const div = divRef.current;
    const rect = div.getBoundingClientRect();

    setPosition({ x: e.clientX - rect.left, y: e.clientY - rect.top });
  };

  const handleFocus = () => {
    setIsFocused(true);
    setOpacity(1);
  };

  const handleBlur = () => {
    setIsFocused(false);
    setOpacity(0);
  };

  const handleMouseEnter = () => {
    setOpacity(1);
  };

  const handleMouseLeave = () => {
    setOpacity(0);
  };

  return (
    <div
      ref={divRef}
      onMouseMove={handleMouseMove}
      onFocus={handleFocus}
      onBlur={handleBlur}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      className={`glass-panel ${className}`}
      style={{
        position: 'relative',
        overflow: 'hidden',
        border: '1px solid var(--glass-border)',
        ...style
      }}
    >
      <div
        style={{
          position: 'absolute',
          pointerEvents: 'none',
          inset: 0,
          opacity: opacity,
          transition: 'opacity 0.3s',
          background: `radial-gradient(600px circle at ${position.x}px ${position.y}px, var(--glow-color), transparent 40%)`,
          zIndex: 0,
        }}
      />
      <div style={{ position: 'relative', zIndex: 1, height: '100%' }}>
        {children}
      </div>
    </div>
  );
}
