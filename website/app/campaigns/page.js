import Link from "next/link";
import { Heart, Target, Clock, ArrowRight } from "lucide-react";

export const metadata = {
  title: "Active Campaigns | HRAS",
  description: "Browse and support our active humanitarian relief campaigns worldwide.",
};

const CAMPAIGNS = [
  {
    id: "flood-relief-south",
    title: "Flood Relief in the South",
    category: "EMERGENCY",
    urgency: "High",
    raised: 15000,
    goal: 50000,
    daysLeft: 5,
    description: "Immediate emergency response for thousands displaced by unprecedented flash floods.",
    bgType: "gradient-red"
  },
  {
    id: "earthquake-recovery",
    title: "Earthquake Recovery",
    category: "EMERGENCY",
    urgency: "Critical",
    raised: 42000,
    goal: 100000,
    daysLeft: 12,
    description: "Rebuilding homes and providing critical medical supplies to affected regions.",
    bgType: "gradient-orange"
  },
  {
    id: "clean-water",
    title: "Clean Water Initiative",
    category: "SUSTAINABILITY",
    urgency: "Medium",
    raised: 8500,
    goal: 20000,
    daysLeft: 45,
    description: "Building solar-powered water filtration systems in remote villages.",
    bgType: "gradient-blue"
  },
  {
    id: "education-supplies",
    title: "Back to School Drive",
    category: "EDUCATION",
    urgency: "Low",
    raised: 3200,
    goal: 10000,
    daysLeft: 20,
    description: "Providing backpacks and essential learning materials to underprivileged children.",
    bgType: "gradient-green"
  }
];

export default function CampaignsPage() {
  return (
    <div className="page-wrapper pt-24" style={{ minHeight: '100vh', backgroundColor: 'var(--bg)' }}>
      {/* Header */}
      <section className="text-center" style={{ padding: '60px 20px 40px' }}>
        <div className="container">
          <h1 style={{ fontSize: '3.5rem', fontWeight: 800, marginBottom: '20px' }}>Active Campaigns</h1>
          <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)', maxWidth: '700px', margin: '0 auto' }}>
            Your support directly fuels these on-ground efforts. Choose a campaign to see live updates and transparency ledgers.
          </p>
        </div>
      </section>

      {/* Grid */}
      <section style={{ padding: '0 20px 100px' }}>
        <div className="container">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))', gap: '30px' }}>
            {CAMPAIGNS.map((campaign) => {
              const progress = Math.min((campaign.raised / campaign.goal) * 100, 100);
              
              return (
                <div key={campaign.id} className="glass-panel" style={{ 
                  borderRadius: '24px', 
                  overflow: 'hidden',
                  display: 'flex',
                  flexDirection: 'column',
                  transition: 'transform 0.3s ease, box-shadow 0.3s ease',
                  cursor: 'pointer'
                }}>
                  {/* Card Image Area (Gradient Placeholder for now) */}
                  <div style={{ 
                    height: '200px', 
                    background: campaign.bgType === 'gradient-red' ? 'linear-gradient(135deg, #ef4444, #991b1b)' : 
                               campaign.bgType === 'gradient-orange' ? 'linear-gradient(135deg, #f59e0b, #b45309)' :
                               campaign.bgType === 'gradient-blue' ? 'linear-gradient(135deg, #3b82f6, #1d4ed8)' :
                               'linear-gradient(135deg, #10b981, #047857)',
                    position: 'relative',
                    padding: '20px'
                  }}>
                    <span style={{ 
                      backgroundColor: 'rgba(255,255,255,0.2)', 
                      backdropFilter: 'blur(10px)',
                      color: 'white',
                      padding: '6px 12px',
                      borderRadius: '20px',
                      fontSize: '0.8rem',
                      fontWeight: 600,
                      letterSpacing: '1px'
                    }}>
                      {campaign.category}
                    </span>
                  </div>

                  {/* Card Content */}
                  <div style={{ padding: '30px', flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
                    <h3 style={{ fontSize: '1.5rem', marginBottom: '10px' }}>{campaign.title}</h3>
                    <p style={{ color: 'var(--text-secondary)', marginBottom: '25px', flexGrow: 1 }}>{campaign.description}</p>
                    
                    {/* Progress */}
                    <div style={{ marginBottom: '20px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '0.9rem' }}>
                        <span style={{ fontWeight: 600 }}>${campaign.raised.toLocaleString()} raised</span>
                        <span style={{ color: 'var(--text-secondary)' }}>of ${campaign.goal.toLocaleString()}</span>
                      </div>
                      <div style={{ width: '100%', height: '8px', backgroundColor: 'var(--bg-input)', borderRadius: '4px', overflow: 'hidden' }}>
                        <div style={{ 
                          width: `${progress}%`, 
                          height: '100%', 
                          backgroundColor: campaign.category === 'EMERGENCY' ? '#ef4444' : 'var(--primary)',
                          borderRadius: '4px'
                        }} />
                      </div>
                    </div>

                    {/* Meta */}
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '15px', borderTop: '1px solid var(--border)', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                        <Clock size={16} /> {campaign.daysLeft} days left
                      </div>
                      <button style={{ 
                        background: 'transparent', 
                        border: 'none', 
                        color: 'var(--primary)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '5px',
                        fontWeight: 600,
                        cursor: 'pointer'
                      }}>
                        Donate <ArrowRight size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>
    </div>
  );
}
