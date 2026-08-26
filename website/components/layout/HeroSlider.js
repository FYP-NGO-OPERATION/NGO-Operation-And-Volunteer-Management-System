'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';

const slides = [
  {
    id: 1,
    image: 'https://images.unsplash.com/photo-1593113512531-50be16c0bca9?auto=format&fit=crop&q=80',
    title: 'Humanity Requires Active Support',
    subtitle: 'Together, we can bring hope and relief to those who need it most.',
    primaryCta: 'Donate Now',
    secondaryCta: 'Volunteer With Us',
  },
  {
    id: 2,
    image: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&q=80',
    title: 'Empowering Communities',
    subtitle: '100% of your donations go directly to our active campaigns.',
    primaryCta: 'View Campaigns',
    secondaryCta: 'Learn More',
  },
  {
    id: 3,
    image: 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb0?auto=format&fit=crop&q=80',
    title: 'Respond to Emergencies',
    subtitle: 'Join our rapid response teams providing critical aid on the ground.',
    primaryCta: 'Join Team',
    secondaryCta: 'See Impact',
  }
];

export default function HeroSlider() {
  const [currentSlide, setCurrentSlide] = useState(0);

  // Auto-play every 3 seconds
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev === slides.length - 1 ? 0 : prev + 1));
    }, 3000);
    return () => clearInterval(timer);
  }, []);

  const nextSlide = () => {
    setCurrentSlide(currentSlide === slides.length - 1 ? 0 : currentSlide + 1);
  };

  const prevSlide = () => {
    setCurrentSlide(currentSlide === 0 ? slides.length - 1 : currentSlide - 1);
  };

  return (
    <div className="hero-slider" style={{ position: 'relative', height: '100vh', width: '100vw', overflow: 'hidden', marginLeft: 'calc(-50vw + 50%)' }}>
      
      {/* Slides */}
      {slides.map((slide, index) => (
        <div 
          key={slide.id}
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            height: '100%',
            opacity: index === currentSlide ? 1 : 0,
            transition: 'opacity 1s ease-in-out',
            zIndex: index === currentSlide ? 1 : 0
          }}
        >
          {/* Background Image */}
          <div 
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              backgroundImage: `url(${slide.image})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
            }}
          />
          
          {/* Dark Overlay Gradient for text readability */}
          <div 
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              background: 'linear-gradient(to bottom, rgba(0,0,0,0.3) 0%, rgba(15, 17, 16, 0.8) 100%)',
            }}
          />

          {/* Content */}
          <div className="container" style={{ position: 'relative', height: '100%', display: 'flex', flexDirection: 'column', justifyContent: 'center', zIndex: 2 }}>
            <div style={{ maxWidth: '800px' }}>
              <h1 style={{ 
                fontSize: 'clamp(2.5rem, 5vw, 4.5rem)', 
                fontWeight: '800', 
                color: '#ffffff',
                lineHeight: '1.1',
                marginBottom: '1rem',
                textShadow: '0 4px 12px rgba(0,0,0,0.3)'
              }}>
                {slide.title}
              </h1>
              <p style={{ 
                fontSize: 'clamp(1rem, 2vw, 1.25rem)', 
                color: 'rgba(255,255,255,0.9)', 
                marginBottom: '2rem',
                maxWidth: '600px'
              }}>
                {slide.subtitle}
              </p>
              <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                <Link href="/donate" style={{
                  padding: '0.75rem 2rem',
                  backgroundColor: 'var(--accent)',
                  color: '#000',
                  fontWeight: '600',
                  borderRadius: 'var(--radius-full)',
                  transition: 'var(--transition-base)',
                  display: 'inline-block'
                }}
                onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
                onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
                >
                  {slide.primaryCta}
                </Link>
                <Link href="/volunteer" className="glass-panel" style={{
                  padding: '0.75rem 2rem',
                  color: '#fff',
                  fontWeight: '600',
                  borderRadius: 'var(--radius-full)',
                  transition: 'var(--transition-base)',
                  display: 'inline-block',
                  border: '1px solid rgba(255,255,255,0.3)'
                }}
                onMouseOver={(e) => {
                  e.currentTarget.style.transform = 'translateY(-2px)';
                  e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.1)';
                }}
                onMouseOut={(e) => {
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.backgroundColor = 'transparent';
                }}
                >
                  {slide.secondaryCta}
                </Link>
              </div>
            </div>
          </div>
        </div>
      ))}

      {/* Navigation Arrows */}
      <button 
        onClick={prevSlide}
        style={{
          position: 'absolute',
          left: '20px',
          top: '50%',
          transform: 'translateY(-50%)',
          background: 'rgba(255,255,255,0.2)',
          border: 'none',
          color: 'white',
          width: '50px',
          height: '50px',
          borderRadius: '50%',
          cursor: 'pointer',
          zIndex: 10,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backdropFilter: 'blur(4px)'
        }}
      >
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
      </button>

      <button 
        onClick={nextSlide}
        style={{
          position: 'absolute',
          right: '20px',
          top: '50%',
          transform: 'translateY(-50%)',
          background: 'rgba(255,255,255,0.2)',
          border: 'none',
          color: 'white',
          width: '50px',
          height: '50px',
          borderRadius: '50%',
          cursor: 'pointer',
          zIndex: 10,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backdropFilter: 'blur(4px)'
        }}
      >
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg>
      </button>

      {/* Dots */}
      <div style={{
        position: 'absolute',
        bottom: '30px',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        gap: '10px',
        zIndex: 10
      }}>
        {slides.map((_, index) => (
          <button
            key={index}
            onClick={() => setCurrentSlide(index)}
            style={{
              width: index === currentSlide ? '30px' : '10px',
              height: '10px',
              borderRadius: '5px',
              background: index === currentSlide ? 'var(--accent)' : 'rgba(255,255,255,0.5)',
              border: 'none',
              cursor: 'pointer',
              transition: 'all 0.3s ease'
            }}
            aria-label={`Go to slide ${index + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
