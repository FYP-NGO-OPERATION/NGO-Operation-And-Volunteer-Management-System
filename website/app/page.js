import HeroSlider from "../components/layout/HeroSlider";
import Link from "next/link";
import { Heart, Globe, TrendingUp, ShieldCheck, ArrowRight, Activity, Smartphone } from "lucide-react";
import Image from "next/image";

export default function Home() {
  return (
    <>
      {/* 1. Hero Slider (Full Screen) */}
      <HeroSlider />

      {/* 2. Urgent Appeals (Modern Bento Grid) */}
      <section className="section" style={{ backgroundColor: 'var(--bg)', position: 'relative', zIndex: 2 }}>
        <div className="container">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '40px' }}>
            <div>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', color: '#ef4444', fontWeight: 600, marginBottom: '10px' }}>
                <Activity className="animate-pulse" size={20} /> Urgent Action Required
              </div>
              <h2 className="section-title" style={{ margin: 0, fontSize: '2.5rem' }}>Active Disaster Appeals</h2>
            </div>
            <Link href="/campaigns" className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              View All <ArrowRight size={16} />
            </Link>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px' }}>
            {/* Primary Appeal */}
            <div className="glass-panel" style={{ borderRadius: '24px', overflow: 'hidden', gridColumn: '1 / -1' }}>
              <div style={{ display: 'flex', flexWrap: 'wrap' }}>
                <div style={{ flex: '1 1 400px', position: 'relative', minHeight: '300px' }}>
                  <Image 
                    src="https://images.unsplash.com/photo-1547683905-f686c993bbf5?q=80&w=2070&auto=format&fit=crop" 
                    alt="Flood Relief" 
                    fill 
                    style={{ objectFit: 'cover' }} 
                  />
                  <div style={{ position: 'absolute', top: '20px', left: '20px', backgroundColor: '#ef4444', color: 'white', padding: '6px 12px', borderRadius: '20px', fontSize: '0.8rem', fontWeight: 700, letterSpacing: '1px' }}>
                    EMERGENCY RESPONSE
                  </div>
                </div>
                <div style={{ flex: '1 1 400px', padding: '40px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                  <h3 style={{ fontSize: '2rem', marginBottom: '15px' }}>Devastating Floods in the South</h3>
                  <p style={{ color: 'var(--text-secondary)', marginBottom: '30px', fontSize: '1.1rem', lineHeight: 1.6 }}>
                    Thousands have been displaced overnight due to unprecedented flash floods. Our ground teams are actively deploying life-saving rations and medical kits.
                  </p>
                  
                  <div style={{ marginBottom: '30px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px', fontWeight: 600 }}>
                      <span style={{ color: 'var(--primary)' }}>$45,200 raised</span>
                      <span style={{ color: 'var(--text-hint)' }}>$100,000 goal</span>
                    </div>
                    <div style={{ width: '100%', height: '10px', backgroundColor: 'var(--bg-input)', borderRadius: '5px', overflow: 'hidden' }}>
                      <div style={{ width: '45%', height: '100%', backgroundColor: '#ef4444', borderRadius: '5px' }}></div>
                    </div>
                  </div>
                  
                  <Link href="/campaigns" className="btn btn-primary" style={{ backgroundColor: '#ef4444', border: 'none', padding: '16px', fontSize: '1.1rem', textAlign: 'center' }}>
                    <Heart size={18} style={{ display: 'inline', marginRight: '8px', verticalAlign: 'text-bottom' }} />
                    Donate Immediately
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. The HRAS Difference (Transparency & Impact) */}
      <section className="section" style={{ backgroundColor: 'var(--bg-secondary)', padding: '100px 0' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: '60px', maxWidth: '800px', margin: '0 auto 60px' }}>
            <h2 style={{ fontSize: '3rem', fontWeight: 800, marginBottom: '20px' }}>The HRAS Difference</h2>
            <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)' }}>
              We've re-engineered the charity model. Utilizing mobile technology to empower locals, and blockchain-inspired public ledgers to guarantee absolute transparency.
            </p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '30px' }}>
            <div className="glass-panel" style={{ padding: '40px', borderRadius: '24px', textAlign: 'center' }}>
              <div style={{ width: '80px', height: '80px', backgroundColor: 'rgba(26, 107, 60, 0.1)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px', color: 'var(--primary)' }}>
                <ShieldCheck size={40} />
              </div>
              <h3 style={{ fontSize: '1.5rem', marginBottom: '15px' }}>100% Transparency</h3>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '25px', lineHeight: 1.6 }}>
                0% admin fees deducted from your donation. Every transaction is visible on our live public ledger.
              </p>
              <Link href="/transparency" style={{ color: 'var(--primary)', fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: '5px' }}>
                View Live Ledger <ArrowRight size={16} />
              </Link>
            </div>

            <div className="glass-panel" style={{ padding: '40px', borderRadius: '24px', textAlign: 'center' }}>
              <div style={{ width: '80px', height: '80px', backgroundColor: 'rgba(232, 168, 56, 0.1)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px', color: 'var(--accent)' }}>
                <Globe size={40} />
              </div>
              <h3 style={{ fontSize: '1.5rem', marginBottom: '15px' }}>Global Volunteer Network</h3>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '25px', lineHeight: 1.6 }}>
                We bypass expensive intermediaries by directly funding and empowering verified local volunteers via our app.
              </p>
              <Link href="/about" style={{ color: 'var(--accent)', fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: '5px' }}>
                Meet the Team <ArrowRight size={16} />
              </Link>
            </div>

            <div className="glass-panel" style={{ padding: '40px', borderRadius: '24px', textAlign: 'center' }}>
              <div style={{ width: '80px', height: '80px', backgroundColor: 'rgba(26, 107, 60, 0.1)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px', color: 'var(--primary)' }}>
                <TrendingUp size={40} />
              </div>
              <h3 style={{ fontSize: '1.5rem', marginBottom: '15px' }}>Verified Impact</h3>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '25px', lineHeight: 1.6 }}>
                Receive photo evidence and direct reports from the ground the moment your specific donation is deployed.
              </p>
              <Link href="/impact" style={{ color: 'var(--primary)', fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: '5px' }}>
                See the Impact <ArrowRight size={16} />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* 4. App Download CTA (Premium Image Background instead of solid block) */}
      <section style={{ position: 'relative', padding: '120px 20px', overflow: 'hidden' }}>
        <Image 
          src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop" 
          alt="App Background" 
          fill 
          style={{ objectFit: 'cover', zIndex: 0 }} 
        />
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(15, 17, 16, 0.85)', zIndex: 1 }}></div>
        
        <div className="container" style={{ position: 'relative', zIndex: 2, display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '60px' }}>
          <div style={{ flex: '1 1 500px' }}>
            <h2 style={{ fontSize: '3rem', fontWeight: 800, color: 'white', marginBottom: '20px', lineHeight: 1.2 }}>
              Take Impact Everywhere You Go.
            </h2>
            <p style={{ fontSize: '1.2rem', color: 'rgba(255,255,255,0.8)', marginBottom: '40px', lineHeight: 1.6 }}>
              Download the revolutionary HRAS Volunteer App. Manage your campaigns, track live transparency ledgers, and coordinate global relief efforts directly from your pocket.
            </p>
            <div style={{ display: 'flex', gap: '20px' }}>
              <Link href="/download" className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '16px 32px', fontSize: '1.1rem' }}>
                <Smartphone size={24} /> Get the App
              </Link>
            </div>
          </div>
          
          <div style={{ flex: '1 1 300px', display: 'flex', justifyContent: 'center' }}>
            {/* Mockup Frame */}
            <div style={{ 
              width: '280px', 
              height: '560px', 
              backgroundColor: '#000', 
              borderRadius: '40px', 
              border: '8px solid #333',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
              position: 'relative',
              overflow: 'hidden',
              display: 'flex',
              flexDirection: 'column'
            }}>
              <div style={{ position: 'absolute', top: 0, left: '50%', transform: 'translateX(-50%)', width: '120px', height: '25px', backgroundColor: '#333', borderBottomLeftRadius: '15px', borderBottomRightRadius: '15px', zIndex: 10 }}></div>
              <div style={{ flex: 1, backgroundColor: 'var(--primary)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '20px', textAlign: 'center' }}>
                 <div style={{ width: '60px', height: '60px', backgroundColor: 'white', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '20px' }}>
                   <Image src="/logo.png" alt="Logo" width={40} height={40} />
                 </div>
                 <h3 style={{ color: 'white', fontSize: '1.5rem', marginBottom: '10px' }}>HRAS Volunteer</h3>
                 <div style={{ width: '100%', height: '8px', backgroundColor: 'rgba(255,255,255,0.3)', borderRadius: '4px', margin: '20px 0' }}></div>
                 <div style={{ width: '80%', height: '8px', backgroundColor: 'rgba(255,255,255,0.3)', borderRadius: '4px' }}></div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
