'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Star, Shield, Heart } from 'lucide-react';

const DUMMY_ACTIVITIES = [
  { id: 1, text: "Ali K. just donated $100 to Flood Relief", icon: Heart, color: "#ef4444" },
  { id: 2, text: "Sarah joined as a volunteer in Karachi", icon: Shield, color: "#3b82f6" },
  { id: 3, text: "New campaign launched: Winter Drive 2024", icon: Star, color: "#f59e0b" },
  { id: 4, text: "Anonymous donated $500", icon: Heart, color: "#ef4444" },
  { id: 5, text: "Team Beta deployed 500 ration packs", icon: Shield, color: "#10b981" },
];

export default function LiveTicker() {
  // Duplicate array to create seamless loop
  const duplicatedActivities = [...DUMMY_ACTIVITIES, ...DUMMY_ACTIVITIES, ...DUMMY_ACTIVITIES];

  return (
    <div style={{
      width: '100%',
      backgroundColor: 'var(--bg-surface)',
      borderBottom: '1px solid var(--border)',
      borderTop: '1px solid var(--border)',
      padding: '12px 0',
      overflow: 'hidden',
      display: 'flex',
      position: 'relative',
      zIndex: 10,
    }}>
      <div style={{
        position: 'absolute',
        left: 0,
        top: 0,
        bottom: 0,
        width: '100px',
        background: 'linear-gradient(to right, var(--bg-surface), transparent)',
        zIndex: 2
      }} />
      
      <motion.div
        initial={{ x: 0 }}
        animate={{ x: "-50%" }}
        transition={{
          repeat: Infinity,
          ease: "linear",
          duration: 30, // Adjust speed here
        }}
        style={{
          display: 'flex',
          whiteSpace: 'nowrap',
          gap: '40px',
          paddingRight: '40px',
        }}
      >
        {duplicatedActivities.map((activity, index) => {
          const Icon = activity.icon;
          return (
            <div key={`${activity.id}-${index}`} style={{
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              fontSize: '0.95rem',
              fontWeight: 600,
              color: 'var(--text-secondary)'
            }}>
              <div style={{
                width: '24px',
                height: '24px',
                borderRadius: '50%',
                backgroundColor: `${activity.color}20`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: activity.color
              }}>
                <Icon size={14} />
              </div>
              {activity.text}
            </div>
          );
        })}
      </motion.div>

      <div style={{
        position: 'absolute',
        right: 0,
        top: 0,
        bottom: 0,
        width: '100px',
        background: 'linear-gradient(to left, var(--bg-surface), transparent)',
        zIndex: 2
      }} />
    </div>
  );
}
