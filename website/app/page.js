"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { Heart, Users, Activity, ArrowRight } from "lucide-react";
import "./page.css";

export default function Home() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { duration: 0.8, ease: "easeOut" },
    },
  };

  return (
    <div className="home-page">
      {/* ─── HERO SECTION ─── */}
      <section className="hero-section">
        <div className="hero-background">
          <div className="glow-orb orb-1"></div>
          <div className="glow-orb orb-2"></div>
        </div>

        <motion.div 
          className="container hero-container"
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          <motion.div variants={itemVariants} className="hero-badge badge-primary">
            <span className="pulse-dot"></span>
            Making Real Impact Worldwide
          </motion.div>
          
          <motion.h1 variants={itemVariants} className="hero-title">
            Humanity <span className="text-gradient">Requires</span> Active Support
          </motion.h1>
          
          <motion.p variants={itemVariants} className="hero-subtitle">
            HRAS is a non-profit organization dedicated to bringing hope, relief, and sustainable solutions to communities in need. 
            Join our transparent ecosystem of donors and volunteers.
          </motion.p>
          
          <motion.div variants={itemVariants} className="hero-actions">
            <Link href="/campaigns" className="btn btn-primary btn-lg glass-panel">
              <Heart size={20} />
              Donate to a Cause
            </Link>
            <Link href="/download" className="btn btn-outline btn-lg">
              <Users size={20} />
              Become a Volunteer
            </Link>
          </motion.div>
        </motion.div>
      </section>

      {/* ─── IMPACT STATS SECTION ─── */}
      <section className="section stats-section">
        <div className="container">
          <motion.div 
            className="stats-grid"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            {[
              { label: "Active Volunteers", value: "2,500+", icon: <Users size={32} className="stat-icon text-accent" /> },
              { label: "Campaigns Completed", value: "150+", icon: <Activity size={32} className="stat-icon text-primary" /> },
              { label: "Lives Impacted", value: "50,000+", icon: <Heart size={32} className="stat-icon text-error" /> }
            ].map((stat, i) => (
              <div key={i} className="stat-card glass-panel">
                <div className="stat-icon-wrapper">
                  {stat.icon}
                </div>
                <h3 className="stat-value text-gradient">{stat.value}</h3>
                <p className="stat-label">{stat.label}</p>
              </div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* ─── FEATURED CAMPAIGNS PREVIEW ─── */}
      <section className="section featured-section">
        <div className="container">
          <div className="section-header">
            <h2 className="text-gradient">Active Missions</h2>
            <p>Support our urgent relief efforts happening right now across the globe.</p>
          </div>
          
          <div className="featured-grid">
            {/* Placeholder for Campaign Cards - Will be dynamic later */}
            {[1, 2, 3].map((item) => (
              <motion.div 
                key={item} 
                className="campaign-card glass-card"
                whileHover={{ y: -10 }}
                transition={{ duration: 0.3 }}
              >
                <div className="campaign-image placeholder-img"></div>
                <div className="campaign-content">
                  <div className="badge badge-info">Emergency Relief</div>
                  <h3>Winter Survival Kits</h3>
                  <p>Providing essential winter supplies to vulnerable families facing extreme cold.</p>
                  
                  <div className="progress-container">
                    <div className="progress-stats">
                      <span>Raised: <strong>$12,500</strong></span>
                      <span>Goal: $20,000</span>
                    </div>
                    <div className="progress-bar">
                      <div className="progress-fill" style={{ width: '62%' }}></div>
                    </div>
                  </div>
                  
                  <Link href="/campaigns/1" className="btn btn-primary full-width mt-4">
                    Donate Now <ArrowRight size={16} />
                  </Link>
                </div>
              </motion.div>
            ))}
          </div>
          
          <div className="view-all-container">
            <Link href="/campaigns" className="btn btn-outline">
              View All Campaigns
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
