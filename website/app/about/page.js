import Link from "next/link";
import { Heart, Globe, Users, ShieldCheck } from "lucide-react";

export const metadata = {
  title: "About Us | HRAS",
  description: "Learn about the Humanitarian Relief and Aid Society and our mission to empower volunteers and connect donors.",
};

export default function AboutPage() {
  return (
    <div className="page-wrapper pt-24">
      {/* Hero Section */}
      <section className="about-hero text-center" style={{ padding: '80px 20px' }}>
        <div className="container">
          <h1 style={{ fontSize: '4rem', fontWeight: 800, marginBottom: '20px', letterSpacing: '-0.02em' }}>Who We Are</h1>
          <p style={{ fontSize: '1.2rem', maxWidth: '800px', margin: '0 auto', color: 'var(--text-secondary)' }}>
            The <strong style={{ color: 'var(--text-primary)' }}>Humanitarian Relief and Aid Society (HRAS)</strong> is a global NGO dedicated to bridging the gap between generous donors and on-ground relief efforts through radical transparency and volunteer empowerment.
          </p>
        </div>
      </section>

      {/* Mission Section */}
      <section className="mission-section" style={{ padding: '60px 20px', backgroundColor: 'var(--bg-secondary)' }}>
        <div className="container" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '40px', alignItems: 'center' }}>
          <div className="mission-text">
            <h2 className="section-title" style={{ fontSize: '2.5rem', marginBottom: '20px' }}>Our Mission</h2>
            <p style={{ marginBottom: '15px', color: 'var(--text-secondary)' }}>
              In a world facing unprecedented crises, the traditional model of aid is too slow and opaque. HRAS was founded on a simple principle: <strong style={{ color: 'var(--text-primary)' }}>Impact should be immediate, measurable, and completely transparent.</strong>
            </p>
            <p style={{ marginBottom: '30px', color: 'var(--text-secondary)' }}>
              We empower local volunteers with our proprietary technology, allowing them to rapidly deploy resources to disaster zones while providing donors with real-time tracking of every dollar spent.
            </p>
            <ul className="core-values" style={{ listStyle: 'none', padding: 0, display: 'flex', flexDirection: 'column', gap: '15px' }}>
              <li style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                <div style={{ padding: '10px', borderRadius: '50%', backgroundColor: 'var(--glass-bg)', border: '1px solid var(--glass-border)' }}>
                  <ShieldCheck size={24} color="var(--primary)" />
                </div>
                <span><strong style={{ color: 'var(--text-primary)' }}>100% Transparency:</strong> Our public ledger tracks all funds.</span>
              </li>
              <li style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                <div style={{ padding: '10px', borderRadius: '50%', backgroundColor: 'var(--glass-bg)', border: '1px solid var(--glass-border)' }}>
                  <Globe size={24} color="var(--primary)" />
                </div>
                <span><strong style={{ color: 'var(--text-primary)' }}>Global Reach:</strong> Active in over 15 countries.</span>
              </li>
              <li style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                <div style={{ padding: '10px', borderRadius: '50%', backgroundColor: 'var(--glass-bg)', border: '1px solid var(--glass-border)' }}>
                  <Users size={24} color="var(--primary)" />
                </div>
                <span><strong style={{ color: 'var(--text-primary)' }}>Volunteer-Led:</strong> Driven by local communities.</span>
              </li>
            </ul>
          </div>
          <div className="mission-image-wrapper" style={{ display: 'grid', gap: '20px' }}>
            <div className="glass-panel" style={{ padding: '40px', textAlign: 'center', borderRadius: '20px' }}>
              <h3 style={{ fontSize: '3rem', color: 'var(--primary)', margin: 0 }}>50k+</h3>
              <p style={{ color: 'var(--text-secondary)', margin: 0, fontWeight: 500 }}>Verified Volunteers</p>
            </div>
            <div className="glass-panel" style={{ padding: '40px', textAlign: 'center', borderRadius: '20px' }}>
              <h3 style={{ fontSize: '3rem', color: 'var(--accent)', margin: 0 }}>$2.5M</h3>
              <p style={{ color: 'var(--text-secondary)', margin: 0, fontWeight: 500 }}>Total Aid Distributed</p>
            </div>
          </div>
        </div>
      </section>

      {/* Team/Join Section */}
      <section className="join-section text-center" style={{ padding: '100px 20px' }}>
        <h2 style={{ fontSize: '3rem', marginBottom: '20px' }}>Ready to make a difference?</h2>
        <p style={{ color: 'var(--text-secondary)', maxWidth: '600px', margin: '0 auto 40px auto' }}>Whether you want to contribute financially or physically on the ground, there is a place for you in the HRAS ecosystem.</p>
        <div style={{ display: 'flex', justifyContent: 'center', gap: '20px' }}>
          <Link href="/volunteer" className="btn btn-outline" style={{ padding: '15px 30px', fontSize: '1.1rem' }}>Become a Volunteer</Link>
          <Link href="/campaigns" className="btn btn-primary" style={{ padding: '15px 30px', fontSize: '1.1rem' }}><Heart size={20} /> Donate Now</Link>
        </div>
      </section>
    </div>
  );
}
