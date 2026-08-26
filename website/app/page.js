"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { Heart, Users, Activity, ArrowRight, ShieldCheck, Download, Smartphone } from "lucide-react";
import HeroSlider from "../components/layout/HeroSlider";
import "./page.css";
import Image from "next/image";

export default function Home() {
  return (
    <div className="home-page">
      {/* ─── HERO SECTION (AUTO-SLIDER) ─── */}
      <HeroSlider />

      {/* ─── URGENT APPEALS SECTION ─── */}
      <section className="section urgent-section">
        <div className="container">
          <div className="section-header">
            <h2 style={{ color: 'var(--error)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px' }}>
              <span className="pulse-dot"></span> Urgent Disaster Appeals
            </h2>
            <p>Immediate emergencies require rapid response. Help us deploy aid today.</p>
          </div>
          
          <div className="featured-grid">
            {[
              { id: 1, title: 'Flood Relief in South', raised: 15000, goal: 50000, image: 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&q=80' },
              { id: 2, title: 'Earthquake Emergency', raised: 42000, goal: 100000, image: 'https://images.unsplash.com/photo-1571260899304-425dea5cfd47?auto=format&fit=crop&q=80' }
            ].map((campaign) => (
              <motion.div 
                key={campaign.id} 
                className="campaign-card glass-card urgent-card"
                whileHover={{ y: -5 }}
              >
                <div className="campaign-image" style={{ backgroundImage: `url(${campaign.image})` }}></div>
                <div className="campaign-content">
                  <div className="badge badge-urgent">EMERGENCY</div>
                  <h3 style={{ marginTop: '10px' }}>{campaign.title}</h3>
                  <div className="progress-container">
                    <div className="progress-stats">
                      <span>Raised: <strong>${campaign.raised}</strong></span>
                      <span>Goal: ${campaign.goal}</span>
                    </div>
                    <div className="progress-bar">
                      <div className="progress-fill" style={{ width: `${(campaign.raised/campaign.goal)*100}%`, backgroundColor: 'var(--error)' }}></div>
                    </div>
                  </div>
                  <Link href={`/donate?campaign=${campaign.id}`} className="btn btn-primary full-width mt-4" style={{ backgroundColor: 'var(--error)' }}>
                    Donate Immediately <ArrowRight size={16} />
                  </Link>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── TRANSPARENCY LEDGER ─── */}
      <section className="section transparency-section" style={{ backgroundColor: 'var(--bg-secondary)' }}>
        <div className="container">
          <div className="transparency-content" style={{ display: 'flex', gap: '40px', alignItems: 'center', flexWrap: 'wrap' }}>
            <div style={{ flex: '1 1 400px' }}>
              <ShieldCheck size={48} color="var(--primary)" style={{ marginBottom: '20px' }} />
              <h2>100% Transparency Ledger</h2>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', marginBottom: '20px' }}>
                We believe in complete financial transparency. Every dollar donated is tracked and publicly displayed on our transparent ledger. You can see exactly where your money goes.
              </p>
              <Link href="/transparency" className="btn btn-outline">
                View Live Ledger
              </Link>
            </div>
            <div className="stats-grid" style={{ flex: '1 1 400px' }}>
              <div className="stat-card glass-panel" style={{ padding: '30px' }}>
                <h3 className="stat-value text-gradient">$2.5M+</h3>
                <p className="stat-label">Total Donations Raised</p>
              </div>
              <div className="stat-card glass-panel" style={{ padding: '30px' }}>
                <h3 className="stat-value text-gradient">$2.5M+</h3>
                <p className="stat-label">Total Funds Deployed</p>
              </div>
              <div className="stat-card glass-panel" style={{ padding: '30px', gridColumn: '1 / -1' }}>
                <h3 className="stat-value" style={{ color: 'var(--success)' }}>0%</h3>
                <p className="stat-label">Admin Fees Deducted (Admin costs covered separately)</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ─── THE ECOSYSTEM (How it works) ─── */}
      <section className="section ecosystem-section">
        <div className="container">
          <div className="section-header">
            <h2>The HRAS Ecosystem</h2>
            <p>How we bridge the gap between generosity and on-ground impact.</p>
          </div>
          <div className="ecosystem-steps" style={{ display: 'flex', gap: '30px', flexWrap: 'wrap', justifyContent: 'center' }}>
            {[
              { title: "1. You Donate", icon: <Heart size={40} />, desc: "Securely donate via the website or mobile app." },
              { title: "2. Volunteers Act", icon: <Users size={40} />, desc: "Our verified volunteers receive funds and purchase supplies." },
              { title: "3. Impact Delivered", icon: <Activity size={40} />, desc: "Supplies are delivered to those in need, tracked with photo evidence." }
            ].map((step, idx) => (
              <div key={idx} className="step-card" style={{ flex: '1 1 250px', textAlign: 'center', padding: '30px' }}>
                <div style={{ display: 'inline-flex', padding: '20px', borderRadius: '50%', backgroundColor: 'rgba(26,107,60,0.1)', color: 'var(--primary)', marginBottom: '20px' }}>
                  {step.icon}
                </div>
                <h3>{step.title}</h3>
                <p style={{ color: 'var(--text-secondary)' }}>{step.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── APP DOWNLOAD CTA ─── */}
      <section className="section download-section" style={{ background: 'linear-gradient(135deg, var(--primary), var(--primary-dark))', color: 'white' }}>
        <div className="container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '40px' }}>
          <div style={{ flex: '1 1 500px' }}>
            <h2 style={{ color: 'white', marginBottom: '20px' }}>Take Impact Everywhere You Go</h2>
            <p style={{ fontSize: '1.2rem', marginBottom: '30px', opacity: 0.9 }}>
              Download the HRAS Volunteer app to manage campaigns, track live transparency ledgers, and coordinate relief efforts directly from your phone.
            </p>
            <div style={{ display: 'flex', gap: '15px' }}>
              <button className="btn" style={{ backgroundColor: 'white', color: 'var(--primary)' }}>
                <Download size={20} /> Download for Android
              </button>
            </div>
          </div>
          <div style={{ flex: '1 1 300px', display: 'flex', justifyContent: 'center' }}>
            <Smartphone size={180} opacity={0.2} />
          </div>
        </div>
      </section>
    </div>
  );
}
