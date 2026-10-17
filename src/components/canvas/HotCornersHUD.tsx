/**
 * HotCornersHUD — Four Quiet Corner Controls (Light Studio Drafting Bed)
 * Clean, tactile HUD elements anchored to corners with fine hairline borders.
 */
import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import {
  HelpCircle,
  Check,
  Play,
  ChevronLeft,
  ChevronRight,
  X,
} from 'lucide-react';

interface HotCornersHUDProps {
  onCenterHub?: () => void;
  onCenterStoryStep?: (stepIndex: number) => void;
}

const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const NODE_RAISED = 'var(--node-raised, #F4F3EE)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';
const MUTED = 'var(--muted, #9BA3B5)';
const MAKER_1 = 'var(--maker-1, #0D8F5B)';
const GAP = 'var(--gap, #FF9F0A)';
const GAP_DARK = 'var(--gap-dark, #D97706)';

const cornerPill = (hovered: boolean): React.CSSProperties => ({
  display: 'flex',
  alignItems: 'center',
  gap: 8,
  padding: '6px 14px',
  backgroundColor: NODE_BG,
  border: `1px solid ${hovered ? MAKER_1 : BORDER}`,
  borderRadius: 9999,
  color: TEXT,
  cursor: 'pointer',
  boxShadow: hovered
    ? '0 4px 14px rgba(0, 0, 0, 0.08)'
    : '0 1px 4px rgba(0, 0, 0, 0.04)',
  fontSize: '11px',
  fontWeight: 600,
  fontFamily: "'Space Grotesk', sans-serif",
  transition: 'all 180ms ease',
});

export const HotCornersHUD: React.FC<HotCornersHUDProps> = ({
  onCenterHub,
  onCenterStoryStep,
}) => {
  const state = useBranchStore();
  const [showHelpDrawer, setShowHelpDrawer] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [hoveredCorner, setHoveredCorner] = useState<string | null>(null);

  const activeProject = state.projects.find((p) => p.id === state.activeProjectId);
  const totalSteps = activeProject ? activeProject.nodes.length : 7;

  const hasGap = state.projects.some((p) =>
    p.nodes.some((n) => n.type === 'gap')
  );

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
      {/* TOP-LEFT: Profile Corner */}
      <div style={{ position: 'fixed', top: 16, left: 16, zIndex: 40 }}>
        <button
          onClick={onCenterHub}
          onMouseEnter={() => setHoveredCorner('tl')}
          onMouseLeave={() => setHoveredCorner(null)}
          style={cornerPill(hoveredCorner === 'tl')}
        >
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=64&q=80"
            alt="Elena"
            style={{
              width: 20,
              height: 20,
              borderRadius: 4,
              objectFit: 'cover',
              border: `1px solid ${BORDER}`,
            }}
          />
          <div style={{ textAlign: 'left' }}>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                color: TEXT,
                lineHeight: 1.1,
              }}
            >
              Elena Rostova
            </div>
            <div style={{ fontSize: '8.5px', color: TEXT_2 }}>MDes Thesis Studio</div>
          </div>
        </button>
      </div>

      {/* TOP-RIGHT: Help Corner */}
      <div style={{ position: 'fixed', top: 16, right: 16, zIndex: 40 }}>
        <button
          onClick={() => setShowHelpDrawer(!showHelpDrawer)}
          onMouseEnter={() => setHoveredCorner('tr')}
          onMouseLeave={() => setHoveredCorner(null)}
          style={cornerPill(hoveredCorner === 'tr')}
        >
          <div style={{ position: 'relative' }}>
            <HelpCircle size={14} color={TEXT_2} />
            {hasGap && (
              <span
                style={{
                  position: 'absolute',
                  top: -2,
                  right: -2,
                  width: 6,
                  height: 6,
                  borderRadius: '50%',
                  backgroundColor: GAP,
                }}
              />
            )}
          </div>
          <span style={{ color: TEXT, fontSize: '10.5px' }}>Help & Open Gaps</span>
        </button>
      </div>

      {/* BOTTOM-LEFT: Save Status */}
      <div style={{ position: 'fixed', bottom: 16, left: 16, zIndex: 40 }}>
        <div
          onMouseEnter={() => setHoveredCorner('bl')}
          onMouseLeave={() => setHoveredCorner(null)}
          style={cornerPill(hoveredCorner === 'bl')}
        >
          <Check size={13} color={MAKER_1} />
          <span style={{ color: TEXT_2, fontSize: '10px' }}>Saved locally</span>
        </div>
      </div>

      {/* BOTTOM-RIGHT: Story Scrubber */}
      <div
        style={{
          position: 'fixed',
          bottom: 16,
          right: 16,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          backgroundColor: NODE_BG,
          border: `1px solid ${BORDER}`,
          borderRadius: 9999,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
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
            gap: 6,
            padding: '7px 14px',
            backgroundColor: 'transparent',
            border: 'none',
            color: TEXT,
            cursor: 'pointer',
            fontSize: '11px',
            fontWeight: 700,
            fontFamily: "'Space Grotesk', sans-serif",
          }}
        >
          <Play size={11} fill={MAKER_1} color={MAKER_1} />
          <span>
            Follow Story ({currentStep} of {totalSteps})
          </span>
        </button>

        <div style={{ width: 1, height: 16, backgroundColor: BORDER }} />

        <button
          onClick={handleStepPrev}
          disabled={currentStep <= 1}
          style={{
            padding: '7px 10px',
            backgroundColor: 'transparent',
            border: 'none',
            color: currentStep <= 1 ? MUTED : TEXT,
            cursor: currentStep <= 1 ? 'default' : 'pointer',
          }}
        >
          <ChevronLeft size={13} />
        </button>

        <button
          onClick={handleStepNext}
          disabled={currentStep >= totalSteps}
          style={{
            padding: '7px 10px',
            backgroundColor: 'transparent',
            border: 'none',
            color: currentStep >= totalSteps ? MUTED : TEXT,
            cursor: currentStep >= totalSteps ? 'default' : 'pointer',
          }}
        >
          <ChevronRight size={13} />
        </button>
      </div>

      {/* Help Drawer */}
      {showHelpDrawer && (
        <div
          style={{
            position: 'fixed',
            top: 60,
            right: 16,
            width: 290,
            backgroundColor: NODE_BG,
            border: `1px solid ${BORDER}`,
            borderRadius: 8,
            padding: '14px',
            boxShadow: '0 12px 32px rgba(0, 0, 0, 0.08)',
            zIndex: 50,
            color: TEXT,
          }}
        >
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginBottom: 10,
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <HelpCircle size={14} color={GAP_DARK} />
              <h3
                style={{
                  fontSize: '11.5px',
                  fontWeight: 700,
                  margin: 0,
                  color: TEXT,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                Open Gaps on Canvas
              </h3>
            </div>
            <button
              onClick={() => setShowHelpDrawer(false)}
              style={{ background: 'none', border: 'none', color: MUTED, cursor: 'pointer' }}
            >
              <X size={14} />
            </button>
          </div>

          <div
            style={{
              padding: '10px',
              backgroundColor: 'var(--gap-bg, #FFF9ED)',
              border: `1px solid rgba(217, 119, 6, 0.3)`,
              borderRadius: 6,
              marginBottom: 10,
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 4,
              }}
            >
              <span style={{ fontSize: '11px', fontWeight: 700, color: GAP_DARK }}>
                Audio-to-Haptic DSP
              </span>
              <span style={{ fontSize: '8px', color: TEXT_2 }}>Elena</span>
            </div>
            <p
              style={{
                fontSize: '10px',
                color: TEXT,
                margin: '0 0 8px 0',
                lineHeight: 1.35,
              }}
            >
              Need voice pitch mapped to dual-frequency 175Hz / 235Hz LRA actuators.
            </p>
            <button
              onClick={() => {
                branchStore.setSelectedNodeId('hw-gap1');
                setShowHelpDrawer(false);
              }}
              style={{
                width: '100%',
                padding: '4px',
                backgroundColor: GAP_DARK,
                border: 'none',
                borderRadius: 4,
                color: '#FFFFFF',
                fontSize: '9.5px',
                fontWeight: 700,
                cursor: 'pointer',
                fontFamily: "'Space Grotesk', sans-serif",
              }}
            >
              Focus on Canvas →
            </button>
          </div>

          <p style={{ fontSize: '9px', color: TEXT_2, margin: 0, lineHeight: 1.4 }}>
            In Branch, creators share unfinished work so interdisciplinary peers can bridge the gap without gatekeeping.
          </p>
        </div>
      )}
    </>
  );
};
