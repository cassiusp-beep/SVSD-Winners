import React, { useState } from 'react';
import { 
  Plus, 
  Compass, 
  FileUp, 
  GitBranch, 
  HelpCircle, 
  Check, 
  Play, 
  Sparkles, 
  Radio, 
  Layers,
  ArrowRight
} from 'lucide-react';

export const LandingCanvasMockup: React.FC = () => {
  const [hoveredNode, setHoveredNode] = useState<string | null>(null);

  return (
    <div 
      className="night-lab-canvas"
      style={{
        width: '100vw',
        height: '100vh',
        position: 'relative',
        overflow: 'hidden',
        backgroundColor: 'var(--canvas)',
        backgroundImage: 'radial-gradient(var(--grid) 1px, transparent 1px)',
        backgroundSize: '24px 24px',
        color: 'var(--text)',
        fontFamily: "var(--font-sans, 'IBM Plex Sans', sans-serif)",
        userSelect: 'none'
      }}
    >
      {/* =====================================================================
          SVG CONNECTIONS & LIVE DIALOGUE LAYER
          ===================================================================== */}
      <svg 
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          pointerEvents: 'none',
          zIndex: 1
        }}
      >
        <defs>
          {/* Gradients for connection links */}
          <linearGradient id="link-maker1-gap" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="var(--maker-1)" stopOpacity="0.8" />
            <stop offset="100%" stopColor="var(--gap)" stopOpacity="0.8" />
          </linearGradient>
          <linearGradient id="link-gap-branch" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="var(--gap)" stopOpacity="0.8" />
            <stop offset="100%" stopColor="var(--maker-3)" stopOpacity="0.9" />
          </linearGradient>
          <filter id="glow-cyan" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="6" result="blur" />
            <feComposite in="SourceGraphic" in2="blur" operator="over" />
          </filter>
        </defs>

        {/* 1. Center Elena Hub -> Haptic Weave (maker-1 line) */}
        <path
          d="M 50% 50% Q 58% 44%, 66% 38%"
          fill="none"
          stroke="var(--maker-1)"
          strokeWidth="2"
          strokeOpacity="0.75"
        />

        {/* 2. Haptic Weave -> Source Node (idle/informed link) */}
        <path
          d="M 78% 34% Q 82% 26%, 86% 22%"
          fill="none"
          stroke="var(--muted)"
          strokeWidth="1.5"
          strokeOpacity="0.5"
          strokeDasharray="4 4"
        />

        {/* 3. Haptic Weave -> Open Gap Node (maker-1 to gap line) */}
        <path
          d="M 76% 40% Q 82% 48%, 82% 58%"
          fill="none"
          stroke="url(#link-maker1-gap)"
          strokeWidth="2"
          strokeOpacity="0.85"
        />

        {/* 4. Open Gap Node -> Marcus Branch (Acid Lime branch fork) */}
        <path
          d="M 79% 65% Q 72% 72%, 65% 75%"
          fill="none"
          stroke="url(#link-gap-branch)"
          strokeWidth="2.5"
          strokeOpacity="0.9"
        />

        {/* 5. Center Hub -> Amina Algae (maker-2 Coral link) */}
        <path
          d="M 45% 48% Q 34% 38%, 24% 35%"
          fill="none"
          stroke="var(--maker-2)"
          strokeWidth="1.5"
          strokeOpacity="0.4"
        />

        {/* 6. Center Hub -> Lucas Origami (maker-4 Violet link) */}
        <path
          d="M 46% 54% Q 36% 64%, 26% 70%"
          fill="none"
          stroke="var(--maker-4)"
          strokeWidth="1.5"
          strokeOpacity="0.4"
        />

        {/* Dialogue pulse traveling along connection (Gap -> Marcus branch) */}
        <circle r="4" fill="var(--dialogue)">
          <animateMotion 
            path="M 79% 65% Q 72% 72%, 65% 75%" 
            dur="3.2s" 
            repeatCount="indefinite" 
          />
        </circle>
        {/* Tail pulse trailing maker-3 color */}
        <circle r="6" fill="var(--maker-3)" opacity="0.6" filter="url(#glow-cyan)">
          <animateMotion 
            path="M 79% 65% Q 72% 72%, 65% 75%" 
            dur="3.2s" 
            repeatCount="indefinite" 
          />
        </circle>
      </svg>

      {/* =====================================================================
          LIVE DIALOGUE TEXT SNIPPETS ALONG CONNECTIONS
          ===================================================================== */}
      {/* Dialogue snippet on Elena -> Gap link */}
      <div 
        className="mobile-snippet-1"
        style={{
          position: 'absolute',
          left: '81%',
          top: '48%',
          transform: 'translate(-50%, -50%)',
          zIndex: 4,
          backgroundColor: 'var(--node-raised)',
          borderLeft: '2px solid var(--maker-1)',
          padding: '4px 8px',
          borderRadius: '4px',
          fontSize: '11px',
          color: 'var(--text-2)',
          maxWidth: '180px',
          lineHeight: '1.3',
          boxShadow: 'var(--shadow-card)',
          pointerEvents: 'none'
        }}
      >
        <span style={{ color: 'var(--maker-1)', fontWeight: 600 }}>Elena: </span>
        "Need DSP to map voice pitch into LRA pulses."
      </div>

      {/* Dialogue snippet on Marcus Branch connection */}
      <div 
        className="desktop-only"
        style={{
          position: 'absolute',
          left: '74%',
          top: '69%',
          transform: 'translate(-50%, -50%)',
          zIndex: 4,
          backgroundColor: 'var(--node-raised)',
          borderLeft: '2px solid var(--maker-3)',
          padding: '4px 8px',
          borderRadius: '4px',
          fontSize: '11px',
          color: 'var(--text-2)',
          maxWidth: '210px',
          lineHeight: '1.3',
          boxShadow: 'var(--shadow-card)',
          pointerEvents: 'none'
        }}
      >
        <span style={{ color: 'var(--maker-3)', fontWeight: 600 }}>Marcus: </span>
        "AudioWorklet splits speech syllables at &lt;8ms."
      </div>

      {/* =====================================================================
          CENTER: ELENA'S PROFILE HUB & BULBING RADIAL OPTIONS
          ===================================================================== */}
      <div
        className="mobile-profile-hub"
        style={{
          position: 'absolute',
          left: '50%',
          top: '50%',
          transform: 'translate(-50%, -50%)',
          zIndex: 10,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}
      >
        {/* Bulbing Radial Satellite: TOP (Start Project) */}
        <div
          style={{
            position: 'absolute',
            top: '-78px',
            width: '46px',
            height: '46px',
            borderRadius: '50%',
            backgroundColor: 'var(--node-raised)',
            border: '1.5px solid var(--text-2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--text)',
            cursor: 'pointer',
            transition: 'all 200ms ease',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}
          title="Start Project (Drag in sources or click)"
        >
          <Plus size={20} />
        </div>

        {/* Bulbing Radial Satellite: RIGHT (Explore Outward) */}
        <div
          style={{
            position: 'absolute',
            right: '-78px',
            width: '46px',
            height: '46px',
            borderRadius: '50%',
            backgroundColor: 'var(--node-raised)',
            border: '1.5px solid var(--text-2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--text)',
            cursor: 'pointer',
            transition: 'all 200ms ease',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}
          title="Explore Outward (Browse Living Network)"
        >
          <Compass size={20} />
        </div>

        {/* Bulbing Radial Satellite: BOTTOM (Drop Source) */}
        <div
          style={{
            position: 'absolute',
            bottom: '-78px',
            width: '46px',
            height: '46px',
            borderRadius: '50%',
            backgroundColor: 'var(--node-raised)',
            border: '1.5px solid var(--text-2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--text)',
            cursor: 'pointer',
            transition: 'all 200ms ease',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}
          title="Drop Source / Inspiration"
        >
          <FileUp size={20} />
        </div>

        {/* Bulbing Radial Satellite: LEFT (Find Your Place) */}
        <div
          style={{
            position: 'absolute',
            left: '-78px',
            width: '46px',
            height: '46px',
            borderRadius: '50%',
            backgroundColor: 'var(--node-raised)',
            border: '1.5px solid var(--text-2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--text)',
            cursor: 'pointer',
            transition: 'all 200ms ease',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}
          title="Find Your Place (Browse open projects to branch)"
        >
          <GitBranch size={20} />
        </div>

        {/* Core Profile Hub Circle */}
        <div
          style={{
            width: '144px',
            height: '144px',
            borderRadius: '50%',
            backgroundColor: 'var(--node)',
            backgroundImage: 'radial-gradient(circle, rgba(79, 216, 240, 0.35) 0%, rgba(21, 27, 48, 0.98) 72%)',
            border: '2px solid var(--maker-1)',
            boxShadow: '0 0 24px rgba(79, 216, 240, 0.35), inset 0 0 16px rgba(79, 216, 240, 0.2)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            textAlign: 'center',
            padding: '12px',
            cursor: 'pointer',
            transition: 'transform 200ms ease'
          }}
        >
          <div 
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              border: '2px solid var(--maker-1)',
              overflow: 'hidden',
              marginBottom: '6px'
            }}
          >
            <img 
              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80" 
              alt="Elena Rostova" 
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
            />
          </div>
          <div style={{ fontWeight: 600, fontSize: '13px', color: 'var(--text)' }}>
            Elena Rostova
          </div>
          <div style={{ fontSize: '10px', color: 'var(--maker-1)', letterSpacing: '0.02em', marginTop: '1px' }}>
            @elena_craft
          </div>
          <div style={{ fontSize: '9px', color: 'var(--text-2)', marginTop: '2px', maxWidth: '105px', lineHeight: '1.2' }}>
            UC Berkeley MDes
          </div>
        </div>
      </div>

      {/* =====================================================================
          SURROUNDING NODES IN THE NIGHT LAB
          ===================================================================== */}

      {/* 1. HERO PROJECT NODE: Haptic Weave (Elena, maker-1) */}
      <div
        className="mobile-hero-project"
        onMouseEnter={() => setHoveredNode('haptic')}
        onMouseLeave={() => setHoveredNode(null)}
        style={{
          position: 'absolute',
          left: '70%',
          top: '36%',
          transform: 'translate(-50%, -50%)',
          zIndex: 5,
          width: '240px',
          backgroundColor: hoveredNode === 'haptic' ? 'var(--node-raised)' : 'var(--node)',
          border: '1.5px solid var(--maker-1)',
          borderRadius: '16px',
          padding: '14px',
          boxShadow: hoveredNode === 'haptic' ? '0 0 20px rgba(79, 216, 240, 0.45)' : 'var(--shadow-card)',
          cursor: 'pointer',
          transition: 'all 200ms ease'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
          <span style={{ fontSize: '10px', color: 'var(--maker-1)', fontWeight: 600, letterSpacing: '0.04em' }}>
            PROJECT STORY • ELENA
          </span>
          <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--maker-1)' }} />
        </div>
        <div style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text)', marginBottom: '4px' }}>
          Haptic Weave
        </div>
        <div style={{ fontSize: '11px', color: 'var(--text-2)', lineHeight: '1.3', marginBottom: '10px' }}>
          Can woven electronic textiles convey emotion through micro-actuators without screens?
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '10px', color: 'var(--muted)' }}>
          <Layers size={12} />
          <span>7 steps • 1 open gap • 1 branch</span>
        </div>
      </div>

      {/* 2. SOURCE NODE: Benchmark Papers */}
      <div
        className="desktop-only"
        style={{
          position: 'absolute',
          left: '88%',
          top: '20%',
          transform: 'translate(-50%, -50%)',
          zIndex: 5,
          width: '180px',
          backgroundColor: 'var(--node)',
          border: '1.5px solid rgba(79, 216, 240, 0.6)',
          borderRadius: '12px',
          padding: '10px 12px',
          boxShadow: 'var(--shadow-card)',
          cursor: 'pointer'
        }}
      >
        <div style={{ fontSize: '9px', color: 'var(--text-2)', textTransform: 'uppercase', marginBottom: '4px' }}>
          SOURCE • STEP 2
        </div>
        <div style={{ fontSize: '12px', fontWeight: 500, color: 'var(--text)' }}>
          Tactile Aesthetics
        </div>
        <div style={{ fontSize: '10px', color: 'var(--muted)', marginTop: '2px' }}>
          Challis &amp; Edwards (4.8mm pitch)
        </div>
      </div>

      {/* 3. GLOWING GAP NODE: Audio-to-Haptic DSP (THE ONLY BREATHING ELEMENT) */}
      <div
        className="mobile-gap-badge"
        style={{
          position: 'absolute',
          left: '82%',
          top: '60%',
          transform: 'translate(-50%, -50%)',
          zIndex: 6,
          width: '210px',
          backgroundColor: 'var(--node)',
          border: '2px solid var(--gap)',
          borderRadius: '14px',
          padding: '12px',
          animation: 'gap-breathe 3s infinite ease-in-out',
          cursor: 'pointer'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '6px' }}>
          <span 
            style={{
              padding: '2px 6px',
              backgroundColor: 'rgba(255, 181, 71, 0.18)',
              borderRadius: '4px',
              fontSize: '9px',
              fontWeight: 700,
              color: 'var(--gap)',
              letterSpacing: '0.04em'
            }}
          >
            OPEN GAP
          </span>
          <span style={{ fontSize: '9px', color: 'var(--text-2)' }}>Mechatronics / Audio</span>
        </div>
        <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text)', marginBottom: '3px' }}>
          Audio-to-Haptic DSP
        </div>
        <div style={{ fontSize: '11px', color: 'var(--text-2)', lineHeight: '1.3' }}>
          Need voice pitch mapped to dual-frequency 175Hz / 235Hz LRA actuators.
        </div>
      </div>

      {/* 4. CONTRIBUTOR BRANCH: Marcus Chen (maker-3, Acid Lime) */}
      <div
        className="desktop-only"
        style={{
          position: 'absolute',
          left: '60%',
          top: '78%',
          transform: 'translate(-50%, -50%)',
          zIndex: 5,
          width: '230px',
          backgroundColor: 'var(--node-raised)',
          border: '1.5px solid var(--maker-3)',
          borderRadius: '14px',
          padding: '12px',
          boxShadow: '0 0 16px rgba(184, 243, 90, 0.25)',
          cursor: 'pointer'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--maker-3)' }} />
            <span style={{ fontSize: '10px', color: 'var(--maker-3)', fontWeight: 600 }}>
              BRANCH • MARCUS CHEN
            </span>
          </div>
          <span style={{ fontSize: '9px', color: 'var(--muted)' }}>Oct 16</span>
        </div>
        <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text)', marginBottom: '2px' }}>
          AudioWorklet DSP Bridge
        </div>
        <div style={{ fontSize: '11px', color: 'var(--text-2)', lineHeight: '1.3' }}>
          Branched from Elena's gap. Synthesizes formant filters into PWM signals in browser.
        </div>
      </div>

      {/* 5. PEER PROJECT: Bioluminescent Algae (Amina Diallo, maker-2 Coral) */}
      <div
        className="desktop-only"
        style={{
          position: 'absolute',
          left: '20%',
          top: '32%',
          transform: 'translate(-50%, -50%)',
          zIndex: 4,
          width: '210px',
          backgroundColor: 'var(--node)',
          border: '1.5px solid rgba(255, 122, 107, 0.6)',
          borderRadius: '14px',
          padding: '12px',
          boxShadow: 'var(--shadow-card)',
          opacity: 0.85,
          cursor: 'pointer'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '6px' }}>
          <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--maker-2)' }} />
          <span style={{ fontSize: '10px', color: 'var(--maker-2)', fontWeight: 600 }}>
            AMINA DIALLO • CCRMA
          </span>
        </div>
        <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text)', marginBottom: '2px' }}>
          Bioluminescent Algae
        </div>
        <div style={{ fontSize: '11px', color: 'var(--text-2)', lineHeight: '1.3' }}>
          Translating room acoustics into dinoflagellate glowing shear flow.
        </div>
      </div>

      {/* 6. PEER PROJECT: Kinetic Origami (Lucas Zhao, maker-4 Violet) */}
      <div
        className="desktop-only"
        style={{
          position: 'absolute',
          left: '22%',
          top: '72%',
          transform: 'translate(-50%, -50%)',
          zIndex: 4,
          width: '210px',
          backgroundColor: 'var(--node)',
          border: '1.5px solid rgba(169, 139, 255, 0.6)',
          borderRadius: '14px',
          padding: '12px',
          boxShadow: 'var(--shadow-card)',
          opacity: 0.85,
          cursor: 'pointer'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '6px' }}>
          <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--maker-4)' }} />
          <span style={{ fontSize: '10px', color: 'var(--maker-4)', fontWeight: 600 }}>
            LUCAS ZHAO • CED
          </span>
        </div>
        <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text)', marginBottom: '2px' }}>
          Origami Acoustic Baffles
        </div>
        <div style={{ fontSize: '11px', color: 'var(--text-2)', lineHeight: '1.3' }}>
          Parametric tessellations that fold to adjust room reverberation time.
        </div>
      </div>

      {/* =====================================================================
          HOT CORNERS (QUIETLY FRAMING THE WORK)
          ===================================================================== */}

      {/* 1. TOP-LEFT: Profile Corner */}
      <div
        style={{
          position: 'fixed',
          top: 16,
          left: 16,
          zIndex: 100,
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          padding: '6px 12px 6px 6px',
          backgroundColor: 'var(--node-raised)',
          border: '1px solid var(--grid)',
          borderRadius: 'var(--radius-pill)',
          boxShadow: 'var(--shadow-card)',
          cursor: 'pointer',
          opacity: 0.9
        }}
      >
        <div 
          style={{
            width: '28px',
            height: '28px',
            borderRadius: '50%',
            border: '1.5px solid var(--maker-1)',
            overflow: 'hidden'
          }}
        >
          <img 
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=64&q=80" 
            alt="Elena" 
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          <span style={{ fontSize: '12px', fontWeight: 600, color: 'var(--text)' }}>Elena Rostova</span>
          <span style={{ fontSize: '10px', color: 'var(--text-2)' }}>Profile &amp; Workspace</span>
        </div>
      </div>

      {/* 2. TOP-RIGHT: Help Corner (Carries small --gap dot when gap exists) */}
      <div
        style={{
          position: 'fixed',
          top: 16,
          right: 16,
          zIndex: 100,
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          padding: '8px 14px',
          backgroundColor: 'var(--node-raised)',
          border: '1px solid var(--grid)',
          borderRadius: 'var(--radius-pill)',
          boxShadow: 'var(--shadow-card)',
          cursor: 'pointer',
          opacity: 0.9
        }}
      >
        <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
          <HelpCircle size={16} color="var(--text-2)" />
          {/* Small pulsing --gap dot: link between 'stuck' and 'ask' */}
          <span 
            style={{
              position: 'absolute',
              top: '-3px',
              right: '-3px',
              width: '6px',
              height: '6px',
              borderRadius: '50%',
              backgroundColor: 'var(--gap)',
              boxShadow: '0 0 6px var(--gap)'
            }} 
          />
        </div>
        <span style={{ fontSize: '12px', color: 'var(--text)' }}>
          Help &amp; Open Gaps
        </span>
      </div>

      {/* 3. BOTTOM-LEFT: Save Corner */}
      <div
        style={{
          position: 'fixed',
          bottom: 16,
          left: 16,
          zIndex: 100,
          display: 'flex',
          alignItems: 'center',
          gap: '6px',
          padding: '6px 12px',
          backgroundColor: 'var(--node-raised)',
          border: '1px solid var(--grid)',
          borderRadius: 'var(--radius-pill)',
          boxShadow: 'var(--shadow-card)',
          color: 'var(--text-2)',
          fontSize: '11px',
          opacity: 0.85
        }}
      >
        <Check size={14} color="var(--text-2)" />
        <span>Saved just now</span>
      </div>

      {/* 4. BOTTOM-RIGHT: Story Corner */}
      <div
        style={{
          position: 'fixed',
          bottom: 16,
          right: 16,
          zIndex: 100,
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          padding: '8px 16px',
          backgroundColor: 'var(--node-raised)',
          border: '1.5px solid var(--maker-1)',
          borderRadius: 'var(--radius-pill)',
          boxShadow: '0 0 14px rgba(79, 216, 240, 0.25)',
          color: 'var(--text)',
          fontSize: '12px',
          fontWeight: 600,
          cursor: 'pointer'
        }}
      >
        <Play size={14} fill="var(--maker-1)" color="var(--maker-1)" />
        <span>Follow Story (1 of 7)</span>
        <ArrowRight size={14} color="var(--text-2)" />
      </div>

      {/* Mobile viewport adaptations */}
      <style>{`
        @media (max-width: 768px) {
          .desktop-only {
            display: none !important;
          }
          .mobile-hero-project {
            left: 50% !important;
            top: 72% !important;
            width: 320px !important;
          }
          .mobile-gap-badge {
            left: 50% !important;
            top: 86% !important;
            width: 320px !important;
          }
          .mobile-snippet-1 {
            left: 50% !important;
            top: 61% !important;
            max-width: 300px !important;
          }
          .mobile-profile-hub {
            top: 36% !important;
          }
          .mobile-svg-lines {
            display: none !important;
          }
        }
      `}</style>
    </div>
  );
};
