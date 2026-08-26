import { Heart, Globe, Users, ShieldCheck } from "lucide-react";
import Link from "next/link";
import BackgroundEffects from "../../components/ui/BackgroundEffects";
import GlowingCard from "../../components/ui/GlowingCard";

export const metadata = {
  title: "About Us | HRAS",
  description: "Learn about the Humanitarian Relief and Aid Society and our mission to empower volunteers and connect donors.",
};

import { db } from "../../lib/firebase";
import { doc, getDoc } from "firebase/firestore";

async function getAboutSettings() {
  try {
    const docRef = doc(db, 'website_content', 'about_page');
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return docSnap.data();
    }
  } catch (error) {
    console.error("Error fetching about settings:", error);
  }
  
  // Fallbacks
  return {
    heroTitle: "Who We Are",
    heroSubtitle: "The Humanitarian Relief and Aid Society is a global NGO dedicated to bridging the gap between generous donors and on-ground relief efforts through radical transparency and volunteer empowerment.",
    missionTitle: "Our Mission",
    missionText: "In a world facing unprecedented crises, the traditional model of aid is too slow and opaque. HRAS was founded on a simple principle: Impact should be immediate, measurable, and completely transparent.",
    val1Title: "100% Transparency",
    val1Desc: "Our public ledger tracks all funds.",
    val2Title: "Global Reach",
    val2Desc: "Active in over 15 countries.",
    val3Title: "Volunteer-Led",
    val3Desc: "Driven by local communities.",
  };
}

export default async function AboutPage() {
  const content = await getAboutSettings();

  return (
    <div className="page-wrapper" style={{ position: 'relative', overflow: 'hidden' }}>
      <BackgroundEffects />
      
      {/* Hero Section */}
      <section className="about-hero text-center" style={{ padding: '120px 20px 80px', position: 'relative', zIndex: 10 }}>
        <div className="container">
          <h1 className="hero-title" style={{ fontSize: 'clamp(3rem, 8vw, 5rem)' }}>
            <span className="text-gradient-purple">{content.heroTitle}</span>
          </h1>
          <p className="hero-subtitle" style={{ fontSize: '1.2rem', maxWidth: '800px', margin: '0 auto', color: 'var(--text-secondary)' }}>
            {content.heroSubtitle}
          </p>
        </div>
      </section>

      {/* Mission Section */}
      <section className="mission-section" style={{ padding: '60px 20px', position: 'relative', zIndex: 10 }}>
        <div className="container" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '40px' }}>
          
          <GlowingCard>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'inline-flex', padding: '15px', borderRadius: '50%', background: 'rgba(20, 184, 166, 0.1)', border: '1px solid rgba(20, 184, 166, 0.3)', width: 'fit-content' }}>
                 <ShieldCheck size={32} color="var(--magic-1)" />
              </div>
              <h2 className="section-title" style={{ fontSize: '2.5rem', margin: 0 }}>
                 <span className="text-gradient-cyan">{content.missionTitle}</span>
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem', lineHeight: 1.6 }}>
                {content.missionText}
              </p>
            </div>
          </GlowingCard>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <GlowingCard>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '20px' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(168, 85, 247, 0.1)', border: '1px solid rgba(168, 85, 247, 0.3)' }}>
                  <ShieldCheck size={24} color="var(--magic-2)" />
                </div>
                <div>
                  <h3 style={{ color: 'var(--text-primary)', margin: '0 0 5px 0', fontSize: '1.2rem' }}>{content.val1Title}</h3>
                  <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{content.val1Desc}</p>
                </div>
              </div>
            </GlowingCard>

            <GlowingCard>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '20px' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(20, 184, 166, 0.1)', border: '1px solid rgba(20, 184, 166, 0.3)' }}>
                  <Globe size={24} color="var(--magic-1)" />
                </div>
                <div>
                  <h3 style={{ color: 'var(--text-primary)', margin: '0 0 5px 0', fontSize: '1.2rem' }}>{content.val2Title}</h3>
                  <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{content.val2Desc}</p>
                </div>
              </div>
            </GlowingCard>

            <GlowingCard>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '20px' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(56, 189, 248, 0.1)', border: '1px solid rgba(56, 189, 248, 0.3)' }}>
                  <Users size={24} color="var(--magic-3)" />
                </div>
                <div>
                  <h3 style={{ color: 'var(--text-primary)', margin: '0 0 5px 0', fontSize: '1.2rem' }}>{content.val3Title}</h3>
                  <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{content.val3Desc}</p>
                </div>
              </div>
            </GlowingCard>
          </div>
          
        </div>
      </section>

      {/* Team/Join Section */}
      <section className="join-section text-center" style={{ padding: '100px 20px', position: 'relative', zIndex: 10 }}>
        <h2 style={{ fontSize: 'clamp(2rem, 5vw, 3.5rem)', marginBottom: '20px' }}>Ready to make a <span className="text-gradient-purple">difference?</span></h2>
        <p style={{ color: 'var(--text-secondary)', maxWidth: '600px', margin: '0 auto 40px auto', fontSize: '1.1rem' }}>Whether you want to contribute financially or physically on the ground, there is a place for you in the HRAS ecosystem.</p>
        <div style={{ display: 'flex', justifyContent: 'center', gap: '20px', flexWrap: 'wrap' }}>
          <Link href="/volunteer" className="btn btn-outline" style={{ padding: '15px 30px', fontSize: '1.1rem' }}>Become a Volunteer</Link>
          <Link href="/campaigns" className="btn btn-primary" style={{ padding: '15px 30px', fontSize: '1.1rem' }}><Heart size={20} style={{marginRight: '8px'}} /> Donate Now</Link>
        </div>
      </section>
    </div>
  );
}
