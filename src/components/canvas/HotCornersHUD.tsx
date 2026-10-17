import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { HelpCircle, Check, Play, Pause, ChevronRight, ChevronLeft, Sparkles, User, GitBranch } from 'lucide-react';

interface HotCornersHUDProps {
  onCenterHub: () => void;
  onCenterStoryStep?: (stepIndex: number) => void;
}

export const HotCornersHUD: React.FC<HotCornersHUDProps> = ({ onCenterHub, onCenterStoryStep }) => {
  const state = useBranchStore();
  const [showHelpPanel, setShowHelpPanel] = useState(false);
  const activeProject = state.projects.find(p => p.id === state.activeProjectId) || state.projects[0];
  const totalSteps = activeProject?.nodes.length || 7;

  const handleNextStep = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.nextStoryStep();
    if (onCenterStoryStep) onCenterStoryStep(state.activeStepIndex);
  };

  const handlePrevStep = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.prevStoryStep();
    if (onCenterStoryStep) onCenterStoryStep(state.activeStepIndex);
  };

  const handlePlayToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.toggleStoryPlay();
  };

  return (
    <>
      {/* 1. TOP-LEFT HOT CORNER: Profile & Workspace Anchor */}
      <div
        style={{
          position: 'fixed',
          top: 16,
          left: 16,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          gap: 10
        }}
      >
        <button
          onClick={() => {
            branchStore.setViewMode('hub');
            onCenterHub();
          }}
          title="Profile Hot Corner • Click to return to Home Hub"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '7px 14px 7px 8px',
            borderRadius: '9999px',
            backgroundColor: '#151B30',
            border: '1px solid #232B47',
            color: '#EEF1FA',
            boxShadow: '0 4px 20px rgba(0,0,0,0.5)',
            cursor: 'pointer',
            transition: 'border-color 0.2s ease, transform 0.2s ease'
          }}
          onMouseEnter={e => {
            e.currentTarget.style.borderColor = '#4FD8F0';
            e.currentTarget.style.transform = 'translateY(-1px)';
          }}
          onMouseLeave={e => {
            e.currentTarget.style.borderColor = '#232B47';
            e.currentTarget.style.transform = 'translateY(0)';
          }}
        >
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80"
            alt="Elena"
            style={{ width: 30, height: 30, borderRadius: '50%', objectFit: 'cover', border: '1.5px solid #4FD8F0' }}
          />
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start', textAlign: 'left' }}>
            <span style={{ fontSize: '13px', fontWeight: 600, color: '#EEF1FA', lineHeight: 1.2 }}>Elena Rostova</span>
            <span style={{ fontSize: '10px', color: '#7A84A8', lineHeight: 1 }}>Profile & Workspace</span>
          </div>
        </button>
      </div>

      {/* 2. TOP-RIGHT HOT CORNER: Help & Open Gaps */}
      <div
        style={{
          position: 'fixed',
          top: 16,
          right: 16,
          zIndex: 40,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-end',
          gap: 8
        }}
      >
        <button
          onClick={() => setShowHelpPanel(!showHelpPanel)}
          title="Help Hot Corner • Open invites & AI suggestions"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 14px',
            borderRadius: '9999px',
            backgroundColor: '#151B30',
            border: showHelpPanel ? '1px solid #FFB547' : '1px solid #232B47',
            color: '#EEF1FA',
            fontSize: '12px',
            fontWeight: 500,
            boxShadow: '0 4px 20px rgba(0,0,0,0.5)',
            cursor: 'pointer',
            transition: 'border-color 0.2s ease'
          }}
          onMouseEnter={e => e.currentTarget.style.borderColor = '#FFB547'}
          onMouseLeave={e => {
            if (!showHelpPanel) e.currentTarget.style.borderColor = '#232B47';
          }}
        >
          <div style={{ position: 'relative' }}>
            <HelpCircle size={16} color="#A3ACC7" />
            <span
              style={{
                position: 'absolute',
                top: -2,
                right: -2,
                width: 6,
                height: 6,
                borderRadius: '50%',
                backgroundColor: '#FFB547',
                boxShadow: '0 0 6px #FFB547'
              }}
            />
          </div>
          <span>Help & Open Gaps</span>
        </button>

        {/* On-Canvas Help Panel (People first, AI second) */}
        {showHelpPanel && (
          <div
            style={{
              width: 310,
              backgroundColor: '#151B30',
              border: '1px solid #232B47',
              borderRadius: 14,
              padding: '14px 16px',
              color: '#EEF1FA',
              boxShadow: '0 12px 32px rgba(0,0,0,0.6)',
              display: 'flex',
              flexDirection: 'column',
              gap: 12
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid #1E2640', paddingBottom: 8 }}>
              <span style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '0.04em', color: '#FFB547', textTransform: 'uppercase' }}>
                OPEN GAPS & COLLABORATION
              </span>
              <span style={{ fontSize: '10px', color: '#7A84A8' }}>1 active gap</span>
            </div>

            {/* People First: Open Invite */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '12px', fontWeight: 600 }}>
                <User size={13} color="#4FD8F0" />
                <span>Ask People (Open Invite)</span>
              </div>
              <div style={{ backgroundColor: '#1E2640', borderRadius: 8, padding: '8px 10px', fontSize: '11px', color: '#A3ACC7' }}>
                <div style={{ color: '#EEF1FA', fontWeight: 500, marginBottom: 2 }}>Audio-to-Haptic DSP</div>
                <div>Need voice pitch mapped to dual-frequency 175Hz / 235Hz LRA actuators.</div>
                <button
                  onClick={() => {
                    branchStore.createPrivateBranch(
                      'haptic-weave',
                      'hw-gap1',
                      'DSP Frequency Actuator Tuning',
                      'Audio DSP',
                      'Mapped speech pitch to LRA resonance.'
                    );
                    setShowHelpPanel(false);
                  }}
                  style={{
                    marginTop: 6,
                    padding: '3px 8px',
                    borderRadius: 4,
                    backgroundColor: 'rgba(255, 181, 71, 0.2)',
                    border: '1px solid rgba(255, 181, 71, 0.5)',
                    color: '#FFB547',
                    fontSize: '10px',
                    fontWeight: 600,
                    cursor: 'pointer'
                  }}
                >
                  Branch this Gap now
                </button>
              </div>
            </div>

            {/* AI Second: Option Toggle */}
            <div style={{ borderTop: '1px solid #1E2640', paddingTop: 8 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: '11px', color: '#C3C7DD' }}>
                  <Sparkles size={12} color="#C3C7DD" />
                  <span>AI Assistance (Optional)</span>
                </div>
                <input
                  type="checkbox"
                  checked={state.aiEnabled}
                  onChange={() => branchStore.toggleAi()}
                  style={{ cursor: 'pointer', accentColor: '#4FD8F0' }}
                />
              </div>
              <div style={{ fontSize: '10px', color: '#7A84A8', lineHeight: 1.3 }}>
                {state.aiEnabled
                  ? 'AI suggestions appear as pale dotted connectors on canvas. AI never modifies the canvas without your action.'
                  : 'AI is switched off. All exploration traces directly to human contributors.'}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* 3. BOTTOM-LEFT HOT CORNER: Constant Save Status */}
      <div
        style={{
          position: 'fixed',
          bottom: 16,
          left: 16,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          gap: 6,
          padding: '7px 14px',
          borderRadius: '9999px',
          backgroundColor: '#151B30',
          border: '1px solid #232B47',
          color: '#A3ACC7',
          fontSize: '12px',
          fontWeight: 500,
          boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
          userSelect: 'none'
        }}
      >
        <Check size={14} color="#B8F35A" />
        <span>{state.lastSavedAt}</span>
      </div>

      {/* 4. BOTTOM-RIGHT HOT CORNER: Follow Story & Scrubber */}
      <div
        style={{
          position: 'fixed',
          bottom: 16,
          right: 16,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          gap: 8
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '5px 8px 5px 12px',
            borderRadius: '9999px',
            backgroundColor: '#151B30',
            border: '1px solid #232B47',
            color: '#EEF1FA',
            boxShadow: '0 4px 20px rgba(0,0,0,0.5)'
          }}
        >
          <button
            onClick={handlePlayToggle}
            title={state.isPlayingStory ? 'Pause narrative story' : 'Play narrative story'}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 6,
              background: 'none',
              border: 'none',
              color: '#4FD8F0',
              fontSize: '12px',
              fontWeight: 600,
              cursor: 'pointer',
              padding: '4px 6px'
            }}
          >
            {state.isPlayingStory ? <Pause size={14} fill="#4FD8F0" /> : <Play size={14} fill="#4FD8F0" />}
            <span style={{ color: '#EEF1FA' }}>Follow Story ({state.activeStepIndex} of {totalSteps})</span>
          </button>

          <div style={{ display: 'flex', alignItems: 'center', gap: 2, borderLeft: '1px solid #232B47', paddingLeft: 6 }}>
            <button
              onClick={handlePrevStep}
              title="Previous chapter step"
              style={{
                width: 24,
                height: 24,
                borderRadius: '50%',
                background: '#1E2640',
                border: 'none',
                color: '#EEF1FA',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer'
              }}
            >
              <ChevronLeft size={14} />
            </button>
            <button
              onClick={handleNextStep}
              title="Next chapter step"
              style={{
                width: 24,
                height: 24,
                borderRadius: '50%',
                background: '#1E2640',
                border: 'none',
                color: '#EEF1FA',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer'
              }}
            >
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      </div>
    </>
  );
};
