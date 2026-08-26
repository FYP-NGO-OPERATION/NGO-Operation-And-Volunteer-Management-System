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
      <section className="section" style={{ position: 'relative', zIndex: 10, padding: '60px 0', marginTop: '-20px', overflow: 'hidden' }}>
        <style dangerouslySetInnerHTML={{__html: `
          .cyber-podium {
            position: absolute;
            bottom: 25%;
            left: 50%;
            transform: translateX(-50%);
            width: 100vw;
            height: 150px;
            background: radial-gradient(ellipse at top, rgba(16, 185, 129, 0.15) 0%, transparent 70%);
            border-top: 2px solid rgba(16, 185, 129, 0.4);
            box-shadow: 0 -10px 30px rgba(16, 185, 129, 0.2);
            z-index: 1;
            border-radius: 50% 50% 0 0 / 100% 100% 0 0;
          }
          
          .founders-img-wrapper {
            position: relative;
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            aspect-ratio: 16/9;
            z-index: 2;
            mix-blend-mode: screen; /* Removes black background */
            -webkit-mask-image: linear-gradient(to bottom, black 75%, transparent 95%);
            mask-image: linear-gradient(to bottom, black 75%, transparent 95%);
          }
          .founders-img-wrapper img {
            mix-blend-mode: screen;
          }

          .founders-title-container {
            position: relative;
            z-index: 3;
            margin-top: -40px; /* Pull text up into the fade */
          }
        `}} />
        
        {/* Animated Cyber Podium */}
        <div className="cyber-podium"></div>

        <div className="container text-center" style={{ position: 'relative', zIndex: 2 }}>
          
          {/* New Group Image */}
          <div className="founders-img-wrapper">
            <Image 
              src="/images/founders/group.jpg" 
              alt="HRAS Founders" 
              fill 
              style={{ objectFit: 'contain', objectPosition: 'bottom center' }} 
              priority
            />
          </div>

          <div className="founders-title-container">
            <h2 style={{ 
              fontSize: 'clamp(2.5rem, 5vw, 4rem)', 
              fontWeight: 900, 
              textTransform: 'uppercase', 
              letterSpacing: '4px',
              color: 'white',
              textShadow: '0 0 20px var(--magic-2), 0 0 40px var(--magic-1)',
              margin: 0
            }}>
              HRAS FOUNDERS
            </h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '1.2rem', marginTop: '10px' }}>
              The visionaries standing together for a better Pakistan.
            </p>
          </div>
        </div>
      </section>

      {/* 2. About & Stats with Glowing Cards */}
      <section className="section" style={{ backgroundColor: 'rgba(0,0,0,0.2)', position: 'relative', zIndex: 2, borderTop: '1px solid rgba(255,255,255,0.05)', padding: '80px 0' }}>
        <div className="container">
          
          {/* Centered About Text */}
          <div style={{ textAlign: 'center', maxWidth: '800px', margin: '0 auto 60px auto' }}>
            <div style={{ display: 'inline-block', padding: '8px 16px', backgroundColor: 'var(--bg-input)', borderRadius: '20px', color: 'var(--primary)', fontWeight: 700, fontSize: '0.85rem', letterSpacing: '1px', marginBottom: '24px' }}>
              WHO WE ARE
            </div>
            <h2 className="section-title">The HRAS Difference</h2>
            <p className="section-subtitle" style={{ margin: '0 auto 30px auto' }}>{settings.aboutText}</p>
            
            <Link href="/about" className="btn btn-outline">
              Learn More <ArrowRight size={18} />
            </Link>
          </div>

          {/* Magic Stats Grid - Fixed Alignment */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '24px', maxWidth: '1000px', margin: '0 auto' }}>
            
            <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <ShieldCheck size={36} color="var(--primary)" style={{ marginBottom: '16px' }} />
              <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px', lineHeight: 1 }}>{settings.stat1 || '100%'}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600, margin: 0 }}>Transparency</p>
            </GlowingCard>

            <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <Globe size={36} color="var(--magic-2)" style={{ marginBottom: '16px' }} />
              <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px', lineHeight: 1 }}>{settings.stat2 || '50k+'}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600, margin: 0 }}>Local Volunteers</p>
            </GlowingCard>

            <GlowingCard style={{ padding: '32px 24px', textAlign: 'center', borderRadius: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <TrendingUp size={36} color="var(--magic-3)" style={{ marginBottom: '16px' }} />
              <h3 style={{ fontSize: '2.5rem', fontWeight: 900, color: 'var(--text-primary)', marginBottom: '8px', lineHeight: 1 }}>{settings.stat3 || '$2.5M'}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: 600, margin: 0 }}>Total Aid Distributed</p>
            </GlowingCard>

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
