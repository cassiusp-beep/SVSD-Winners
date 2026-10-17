import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import {
  User as UserIcon,
  HelpCircle,
  Check,
  Play,
  ChevronLeft,
  ChevronRight,
  Sparkles,
  X,
  MessageSquare
} from 'lucide-react';

interface HotCornersHUDProps {
  onCenterHub?: () => void;
  onCenterStoryStep?: (stepIndex: number) => void;
}

export const HotCornersHUD: React.FC<HotCornersHUDProps> = ({
  onCenterHub,
  onCenterStoryStep
}) => {
  const state = useBranchStore();
  const [showHelpDrawer, setShowHelpDrawer] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);

  const activeProject = state.projects.find((p) => p.id === state.activeProjectId);
  const totalSteps = activeProject ? activeProject.nodes.length : 7;

  const handleStepPrev = (e: React.MouseEvent) => {
    e.stopPropagation();
    const next = Math.max(1, currentStep - 1);
    setCurrentStep(next);
    if (onCenterStoryStep) onCenterStoryStep(next);
  };

  const handleStepNext = (e: React.MouseEvent) => {
    e.stopPropagation();
    const next = Math.min(totalSteps, currentStep + 1);
    setCurrentStep(next);
    if (onCenterStoryStep) onCenterStoryStep(next);
  };

  return (
    <>
      {/* =========================================================================
          1. TOP-LEFT: Profile & Identity Hot Corner
          ========================================================================= */}
      <div
        style={{
          position: 'fixed',
          top: 20,
          left: 20,
          zIndex: 40,
        }}
      >
        <button
          onClick={onCenterHub}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 9,
            padding: '7px 14px',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E0D5',
            borderRadius: 30,
            color: '#191C24',
            cursor: 'pointer',
            boxShadow: '0 4px 16px rgba(24, 28, 38, 0.08)',
            transition: 'all 0.2s ease',
          }}
          onMouseEnter={(e) => (e.currentTarget.style.borderColor = '#0D8F5B')}
          onMouseLeave={(e) => (e.currentTarget.style.borderColor = '#E5E0D5')}
        >
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=64&q=80"
            alt="Elena"
            style={{ width: 22, height: 22, borderRadius: '50%', objectFit: 'cover' }}
          />
          <div style={{ textAlign: 'left' }}>
            <div style={{ fontSize: '11px', fontWeight: 700, color: '#191C24', lineHeight: 1.1 }}>
              Elena Rostova
            </div>
            <div style={{ fontSize: '9px', color: '#5F667A' }}>Profile</div>
          </div>
        </button>
      </div>

      {/* =========================================================================
          2. TOP-RIGHT: Help & Open Gaps Hot Corner
          ========================================================================= */}
      <div
        style={{
          position: 'fixed',
          top: 20,
          right: 20,
          zIndex: 40,
        }}
      >
        <button
          onClick={() => setShowHelpDrawer(!showHelpDrawer)}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 16px',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E0D5',
            borderRadius: 30,
            color: '#191C24',
            cursor: 'pointer',
            boxShadow: '0 4px 16px rgba(24, 28, 38, 0.08)',
            fontSize: '11.5px',
            fontWeight: 600,
            transition: 'all 0.2s ease',
          }}
          onMouseEnter={(e) => (e.currentTarget.style.borderColor = '#FF9F0A')}
          onMouseLeave={(e) => (e.currentTarget.style.borderColor = '#E5E0D5')}
        >
          <div style={{ position: 'relative' }}>
            <HelpCircle size={15} color="#191C24" />
            <span
              style={{
                position: 'absolute',
                top: -2,
                right: -2,
                width: 6,
                height: 6,
                borderRadius: '50%',
                backgroundColor: '#FF9F0A',
              }}
            />
          </div>
          <span>Help & Open Gaps</span>
        </button>
      </div>

      {/* =========================================================================
          3. BOTTOM-LEFT: Save & Persistence Hot Corner
          ========================================================================= */}
      <div
        style={{
          position: 'fixed',
          bottom: 20,
          left: 20,
          zIndex: 40,
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 7,
            padding: '7px 14px',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E0D5',
            borderRadius: 30,
            color: '#191C24',
            boxShadow: '0 4px 16px rgba(24, 28, 38, 0.08)',
            fontSize: '11px',
            fontWeight: 600,
          }}
        >
          <Check size={14} color="#0D8F5B" />
          <span>Saved</span>
        </div>
      </div>

      {/* =========================================================================
          4. BOTTOM-RIGHT: Story Scrubber & Narrative Progression
          ========================================================================= */}
      <div
        style={{
          position: 'fixed',
          bottom: 20,
          right: 20,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          gap: 6,
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E0D5',
            borderRadius: 30,
            boxShadow: '0 4px 16px rgba(24, 28, 38, 0.08)',
            overflow: 'hidden',
          }}
        >
          <button
            onClick={() => {
              branchStore.setViewMode('story');
              if (onCenterStoryStep) onCenterStoryStep(currentStep);
            }}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 7,
              padding: '8px 14px',
              backgroundColor: 'transparent',
              border: 'none',
              color: '#191C24',
              cursor: 'pointer',
              fontSize: '11.5px',
              fontWeight: 700,
            }}
          >
            <Play size={12} fill="#0D8F5B" color="#0D8F5B" />
            <span>Follow Story ({currentStep} of {totalSteps})</span>
          </button>

          <div style={{ width: 1, height: 16, backgroundColor: '#E5E0D5' }} />

          <button
            onClick={handleStepPrev}
            disabled={currentStep <= 1}
            style={{
              padding: '8px 10px',
              backgroundColor: 'transparent',
              border: 'none',
              color: currentStep <= 1 ? '#C4C8D4' : '#191C24',
              cursor: currentStep <= 1 ? 'default' : 'pointer',
            }}
          >
            <ChevronLeft size={14} />
          </button>

          <button
            onClick={handleStepNext}
            disabled={currentStep >= totalSteps}
            style={{
              padding: '8px 10px',
              backgroundColor: 'transparent',
              border: 'none',
              color: currentStep >= totalSteps ? '#C4C8D4' : '#191C24',
              cursor: currentStep >= totalSteps ? 'default' : 'pointer',
            }}
          >
            <ChevronRight size={14} />
          </button>
        </div>
      </div>

      {/* Slide-out Help & Open Gaps Panel */}
      {showHelpDrawer && (
        <div
          style={{
            position: 'fixed',
            top: 70,
            right: 20,
            width: 320,
            backgroundColor: '#FFFFFF',
            border: '1px solid #E5E0D5',
            borderRadius: 16,
            padding: '16px',
            boxShadow: '0 12px 36px rgba(24, 28, 38, 0.12)',
            zIndex: 50,
            color: '#191C24',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <HelpCircle size={15} color="#FF9F0A" />
              <h3 style={{ fontSize: '13px', fontWeight: 700, margin: 0 }}>Open Gaps & Calls for Help</h3>
            </div>
            <button
              onClick={() => setShowHelpDrawer(false)}
              style={{ background: 'none', border: 'none', color: '#5F667A', cursor: 'pointer' }}
            >
              <X size={15} />
            </button>
          </div>

          <div
            style={{
              padding: '12px',
              backgroundColor: '#FFFDF9',
              border: '1px solid #FEF3C7',
              borderRadius: 10,
              marginBottom: 10,
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
              <span style={{ fontSize: '11px', fontWeight: 700, color: '#B45309' }}>Audio-to-Haptic DSP</span>
              <span style={{ fontSize: '9px', color: '#B45309', fontWeight: 600 }}>Elena's Gap</span>
            </div>
            <p style={{ fontSize: '11px', color: '#5F667A', margin: '0 0 8px 0', lineHeight: 1.4 }}>
              Need voice pitch mapped to dual-frequency 175Hz / 235Hz LRA actuators.
            </p>
            <button
              onClick={() => {
                branchStore.setSelectedNodeId('hw-gap1');
                setShowHelpDrawer(false);
              }}
              style={{
                width: '100%',
                padding: '6px',
                backgroundColor: '#FF9F0A',
                border: 'none',
                borderRadius: 6,
                color: '#FFFFFF',
                fontSize: '10.5px',
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Focus on Canvas
            </button>
          </div>

          <p style={{ fontSize: '10px', color: '#8E95A6', margin: 0, lineHeight: 1.4 }}>
            In Branch, creators share unfinished work so interdisciplinary peers can bridge the gap without gatekeeping.
          </p>
        </div>
      )}
    </>
  );
};
