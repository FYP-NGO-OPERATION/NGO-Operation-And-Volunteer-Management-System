import HeroSlider from "../components/layout/HeroSlider";
import Link from "next/link";
import { Heart, Globe, TrendingUp, ShieldCheck, ArrowRight, Activity, Smartphone } from "lucide-react";
import Image from "next/image";
import { db } from "../lib/firebase";
import { doc, getDoc } from "firebase/firestore";
import LiveTicker from "../components/ui/LiveTicker";
import GlowingCard from "../components/ui/GlowingCard";
import TestimonialCarousel from "../components/ui/TestimonialCarousel";

export const revalidate = 60; // ISR 60s

async function getWebsiteSettings() {
  try {
    const docRef = doc(db, 'website_content', 'settings');
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return docSnap.data();
    }
  } catch (error) {
    console.error("Error fetching website settings:", error);
  }
  return {
    heroTitle: 'Grassroots Impact',
    heroSubtitle: 'Empowering local communities across Pakistan through direct, transparent volunteer action.',
    aboutText: 'We are a newly formed Pakistani NGO dedicated to making a real difference. We connect passionate local volunteers with urgent causes, ensuring 100% transparency.',
    stat1: '100%',
    stat2: 'Local',
    stat3: 'Impact'
  };
}

export default async function Home() {
  const settings = await getWebsiteSettings();

  return (
    <>
      {/* 1. Hero */}
      <HeroSlider title={settings.heroTitle} subtitle={settings.heroSubtitle} />
      
      {/* 1.5 Live Ticker */}
      <LiveTicker />

      {/* 1.8 Founders Group (Animated Background & 3D Effect) */}
      <section className="section" style={{ position: 'relative', zIndex: 10, padding: '40px 0', marginTop: '-20px', overflow: 'hidden' }}>
        <style dangerouslySetInnerHTML={{__html: `
          .cyber-lines-bg {
            position: absolute;
            bottom: 30%;
            left: 50%;
            transform: translateX(-50%);
            width: 100vw;
            height: 60%;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            align-items: center;
            z-index: 0;
            pointer-events: none;
          }
          .cyber-line {
            width: 100%;
            background: #10b981;
            margin-bottom: 25px;
            opacity: 0;
            animation: pulseLine 3s infinite alternate ease-in-out;
            border-radius: 50%;
          }
          .cyber-line:nth-child(1) { animation-delay: 0s; height: 2px; box-shadow: 0 0 10px #047857, 0 0 20px #047857; width: 60%; }
          .cyber-line:nth-child(2) { animation-delay: 0.5s; height: 3px; box-shadow: 0 0 15px #059669, 0 0 30px #059669; width: 80%; }
          .cyber-line:nth-child(3) { animation-delay: 1s; height: 4px; box-shadow: 0 0 20px #10b981, 0 0 40px #10b981; width: 100%; }
          .cyber-line:nth-child(4) { animation-delay: 1.5s; height: 6px; box-shadow: 0 0 30px #34d399, 0 0 60px #34d399; width: 120%; }
          
          @keyframes pulseLine {
            0% { opacity: 0.1; transform: scaleX(0.9) translateY(10px); filter: hue-rotate(0deg); }
            100% { opacity: 0.9; transform: scaleX(1.1) translateY(0px); filter: hue-rotate(20deg); }
          }
          
          .founders-group {
            display: flex;
            justify-content: center;
            align-items: flex-end;
            margin-bottom: 20px;
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 900px;
            margin: 0 auto 20px auto;
          }
        `}} />
        
        {/* Animated Lines Background */}
        <div className="cyber-lines-bg">
          <div className="cyber-line"></div>
          <div className="cyber-line"></div>
          <div className="cyber-line"></div>
          <div className="cyber-line"></div>
        </div>

        <div className="container text-center" style={{ position: 'relative', zIndex: 2 }}>
          
          {/* New Group Image */}
          <div className="founders-group">
            <div style={{ position: 'relative', width: '100%', aspectRatio: '16/9', filter: 'drop-shadow(0 20px 40px rgba(0,0,0,0.8))' }}>
              <Image 
                src="/images/founders/group.jpg" 
                alt="HRAS Founders" 
                fill 
                style={{ 
                  objectFit: 'contain', 
                  objectPosition: 'bottom center',
                  mixBlendMode: 'screen' /* Removes black background smoothly */
                }} 
              />
            </div>
          </div>

          <h2 style={{ 
            fontSize: 'clamp(2.5rem, 5vw, 4rem)', 
            fontWeight: 900, 
            textTransform: 'uppercase', 
            letterSpacing: '4px',
            color: 'white',
            textShadow: '0 0 20px var(--magic-2), 0 0 40px var(--magic-1)',
            margin: 0,
            position: 'relative',
            zIndex: 3
          }}>
            HRAS FOUNDERS
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '1.2rem', marginTop: '10px', position: 'relative', zIndex: 3 }}>
            The visionaries standing together for a better Pakistan.
          </p>
        </div>
      </section>

      {/* 2. About & Stats with Glowing Cards */}
      <section className="section" style={{ backgroundColor: 'transparent', position: 'relative', zIndex: 2 }}>
        <div className="container">
          <div className="flex-between" style={{ flexWrap: 'wrap', gap: '60px', alignItems: 'flex-start' }}>
            
            {/* Left: About Text */}
            <div style={{ flex: '1 1 500px' }}>
              <div style={{ display: 'inline-block', padding: '8px 16px', backgroundColor: 'var(--bg-input)', borderRadius: '20px', color: 'var(--primary)', fontWeight: 700, fontSize: '0.85rem', letterSpacing: '1px', marginBottom: '24px' }}>
                WHO WE ARE
              </div>
              <h2 className="section-title">The HRAS Difference</h2>
              <p className="section-subtitle">{settings.aboutText}</p>
              
              <Link href="/about" className="btn btn-outline">
                Learn More <ArrowRight size={18} />
              </Link>
            </div>

            {/* Right: Magic Stats Grid */}
            <div style={{ flex: '1 1 400px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
              
              <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px' }}>
                <ShieldCheck size={36} color="var(--primary)" style={{ margin: '0 auto 16px' }} />
                <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px' }}>{settings.stat1 || '100%'}</h3>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600 }}>Transparency</p>
              </GlowingCard>

              <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px', transform: 'translateY(24px)' }}>
                <Globe size={36} color="var(--magic-2)" style={{ margin: '0 auto 16px' }} />
                <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px' }}>{settings.stat2 || '50k+'}</h3>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600 }}>Volunteers</p>
              </GlowingCard>

              <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px', gridColumn: 'span 2' }}>
                <TrendingUp size={36} color="var(--magic-3)" style={{ margin: '0 auto 16px' }} />
                <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px' }}>{settings.stat3 || '$2.5M'}</h3>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600 }}>Total Aid Distributed</p>
              </GlowingCard>

            </div>
          </div>
        </div>
      </section>

      {/* 2.5 Testimonials (Voices from the Ground) */}
      <section className="section" style={{ position: 'relative', zIndex: 2 }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: '60px' }}>
            <h2 className="section-title">Voices from the Ground</h2>
            <p className="section-subtitle" style={{ margin: '0 auto' }}>Real stories from the people making it happen.</p>
          </div>
          <TestimonialCarousel />
        </div>
      </section>

      {/* 3. Urgent Appeals Preview */}
      <section className="section" style={{ backgroundColor: 'transparent' }}>
        <div className="container">
          <div className="flex-between" style={{ marginBottom: '48px', flexWrap: 'wrap', gap: '20px' }}>
            <div>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', color: '#ef4444', fontWeight: 700, fontSize: '0.85rem', letterSpacing: '1px', marginBottom: '16px' }}>
                <Activity className="animate-pulse" size={18} /> URGENT ACTION
              </div>
              <h2 className="section-title" style={{ margin: 0 }}>Active Disaster Appeals</h2>
            </div>
            <Link href="/campaigns" className="btn btn-outline">
              View All Appeals <ArrowRight size={18} />
            </Link>
          </div>

          <GlowingCard style={{ display: 'flex', flexWrap: 'wrap', padding: 0, borderRadius: '32px' }}>
            <div style={{ flex: '1 1 400px', position: 'relative', minHeight: '400px' }}>
              <Image 
                src="https://images.unsplash.com/photo-1547683905-f686c993bbf5?q=80&w=2070&auto=format&fit=crop" 
                alt="Flood Relief" 
                fill 
                style={{ objectFit: 'cover' }} 
              />
            </div>
            <div style={{ flex: '1 1 400px', padding: '48px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
              <h3 style={{ fontSize: '2.25rem', fontWeight: 800, marginBottom: '16px', color: 'var(--text-primary)' }}>Devastating Floods in the South</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem', lineHeight: 1.6, marginBottom: '32px' }}>
                Thousands have been displaced overnight due to unprecedented flash floods. Our ground teams are actively deploying life-saving rations and medical kits.
              </p>
              
              <div style={{ marginBottom: '32px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', fontWeight: 700, fontSize: '1.1rem' }}>
                  <span style={{ color: 'var(--primary)' }}>$45,200 raised</span>
                  <span style={{ color: 'var(--text-hint)' }}>$100,000 goal</span>
                </div>
                <div style={{ width: '100%', height: '12px', backgroundColor: 'var(--bg-input)', borderRadius: '6px', overflow: 'hidden' }}>
                  <div style={{ width: '45%', height: '100%', backgroundColor: '#ef4444', borderRadius: '6px' }}></div>
                </div>
              </div>
              
              <Link href="/campaigns" className="btn btn-primary" style={{ backgroundColor: '#ef4444', color: 'white' }}>
                <Heart size={20} /> Donate Immediately
              </Link>
            </div>
          </GlowingCard>
        </div>
      </section>

      {/* 4. App CTA */}
      <section style={{ position: 'relative', padding: '120px 0', overflow: 'hidden' }}>
        <Image 
          src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop" 
          alt="App Background" 
          fill 
          style={{ objectFit: 'cover', zIndex: 0 }} 
        />
        <div style={{ position: 'absolute', inset: 0, backgroundColor: 'rgba(0,0,0,0.85)', zIndex: 1 }}></div>
        
        <div className="container" style={{ position: 'relative', zIndex: 2, display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '80px' }}>
          <div style={{ flex: '1 1 500px' }}>
            <h2 style={{ fontSize: '3.5rem', fontWeight: 900, color: 'white', marginBottom: '24px', lineHeight: 1.1, letterSpacing: '-0.02em' }}>
              Take Impact Everywhere.
            </h2>
            <p style={{ fontSize: '1.25rem', color: 'rgba(255,255,255,0.8)', marginBottom: '48px', lineHeight: 1.6 }}>
              Download the revolutionary HRAS Volunteer App. Manage campaigns, track live transparency ledgers, and coordinate global relief efforts from your pocket.
            </p>
            <Link href="/download" className="btn btn-primary" style={{ padding: '16px 32px', fontSize: '1.1rem', backgroundColor: 'var(--magic-2)' }}>
              <Smartphone size={24} /> Get the App
            </Link>
          </div>
          
          <div style={{ flex: '1 1 300px', display: 'flex', justifyContent: 'center' }}>
            {/* Device Mockup */}
            <div style={{ 
              width: '300px', 
              height: '600px', 
              backgroundColor: '#111', 
              borderRadius: '48px', 
              border: '12px solid #222',
              boxShadow: '0 30px 60px -12px rgba(0, 0, 0, 0.8), 0 0 40px rgba(56, 189, 248, 0.3)',
              position: 'relative',
              overflow: 'hidden',
              display: 'flex',
              flexDirection: 'column'
            }}>
              <div style={{ position: 'absolute', top: 0, left: '50%', transform: 'translateX(-50%)', width: '140px', height: '30px', backgroundColor: '#222', borderBottomLeftRadius: '16px', borderBottomRightRadius: '16px', zIndex: 10 }}></div>
              <div style={{ flex: 1, background: 'linear-gradient(to bottom, var(--primary-dark), #111)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '32px', textAlign: 'center' }}>
                 <div className="logo-glow-wrapper" style={{ marginBottom: '24px' }}>
                   <Image src="/logo.png" alt="Logo" width={40} height={40} style={{ objectFit: 'contain' }} />
                 </div>
                 <h3 style={{ color: 'white', fontSize: '1.75rem', fontWeight: 800, marginBottom: '16px' }}>HRAS Admin</h3>
                 <div style={{ width: '100%', height: '8px', backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: '4px', margin: '16px 0' }}></div>
                 <div style={{ width: '70%', height: '8px', backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: '4px', marginBottom: '16px' }}></div>
                 <div style={{ width: '90%', height: '8px', backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: '4px' }}></div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
