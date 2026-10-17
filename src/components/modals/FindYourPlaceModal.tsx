import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { SEED_USERS } from '../../data/seedData';
import { 
  Compass, 
  X, 
  Bookmark, 
  Wrench, 
  RotateCcw, 
  GitBranch, 
  Sparkles,
  ArrowRight
} from 'lucide-react';

export const FindYourPlaceModal: React.FC = () => {
  const state = useBranchStore();
  const currentProject = state.projects.find(p => p.id === state.activeProjectId);
  const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
  const selectedNode = currentProject?.nodes.find(n => n.id === state.selectedNodeId) || currentProject?.nodes[0];

  const [aiSuggestionDismissed, setAiSuggestionDismissed] = useState(false);

  if (state.activeModal !== 'findYourPlace') return null;

  const handleSaveForLater = () => {
    if (currentProject) {
      branchStore.toggleSaveProject(currentProject.id);
      branchStore.closeModal();
    }
  };

  const handleStartBranch = (skill: string) => {
    branchStore.openModal('privateBranch');
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(32, 36, 32, 0.4)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 2000,
        padding: '16px'
      }}
      onClick={() => branchStore.closeModal()}
    >
      <div
        className="branch-card"
        style={{
          width: 520,
          maxWidth: '100%',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="find-place-title"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Compass size={20} color="var(--color-ink)" />
            <h3 id="find-place-title" style={{ fontFamily: 'var(--font-display)', fontSize: '18px', fontWeight: 600 }}>
              Find Your Place in this Story
            </h3>
          </div>
          <button
            onClick={() => branchStore.closeModal()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Focal node context */}
        <div style={{ padding: '12px', backgroundColor: 'var(--color-surface-subtle)', borderRadius: 'var(--radius-control)', marginBottom: '16px' }}>
          <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)', textTransform: 'uppercase', fontWeight: 600 }}>
            Anchoring onto:
          </div>
          <div style={{ fontSize: '14px', fontWeight: 600, color: 'var(--color-ink)', marginTop: '2px' }}>
            {selectedNode?.title || currentProject?.title}
          </div>
          <p style={{ fontSize: '12px', color: 'var(--color-ink-muted)', marginTop: '4px' }}>
            {selectedNode?.gapNeed || selectedNode?.hypothesis || selectedNode?.decisionRationale || currentProject?.startingQuestion}
          </p>
        </div>

        {/* 4 Established Choices */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '16px' }}>
          {/* Choice 1: Start a New Branch */}
          <button
            onClick={() => handleStartBranch('Creative Tech & Sound')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'space-between', padding: '12px 14px', textAlign: 'left' }}
          >
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
              <GitBranch size={16} color="var(--color-ink)" style={{ marginTop: 2 }} />
              <div>
                <div style={{ fontSize: '13px', fontWeight: 600 }}>Start a New Branch</div>
                <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>
                  Try a private draft. The original project is never touched.
                </div>
              </div>
            </div>
            <ArrowRight size={14} color="var(--color-ink-muted)" />
          </button>

          {/* Choice 2: Contribute a Skill */}
          <button
            onClick={() => handleStartBranch('Audio DSP & Frequency Synthesis')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'space-between', padding: '12px 14px', textAlign: 'left' }}
          >
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
              <Wrench size={16} color="var(--color-ink)" style={{ marginTop: 2 }} />
              <div>
                <div style={{ fontSize: '13px', fontWeight: 600 }}>Contribute a Skill ({currentUser.skills[0] || 'Technical'})</div>
                <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>
                  Offer your expertise to bridge Elena's open haptic frequency gap.
                </div>
              </div>
            </div>
            <ArrowRight size={14} color="var(--color-ink-muted)" />
          </button>

          {/* Choice 3: Revive an Experiment */}
          <button
            onClick={() => handleStartBranch('Thermal Actuation Alternatives')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'space-between', padding: '12px 14px', textAlign: 'left' }}
          >
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
              <RotateCcw size={16} color="var(--color-ink)" style={{ marginTop: 2 }} />
              <div>
                <div style={{ fontSize: '13px', fontWeight: 600 }}>Revive an Experiment</div>
                <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>
                  Pick up the abandoned Nichrome thermal wire test with a new approach.
                </div>
              </div>
            </div>
            <ArrowRight size={14} color="var(--color-ink-muted)" />
          </button>

          {/* Choice 4: Save for Later */}
          <button
            onClick={handleSaveForLater}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'space-between', padding: '12px 14px', textAlign: 'left' }}
          >
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
              <Bookmark size={16} color="var(--color-ink)" style={{ marginTop: 2 }} />
              <div>
                <div style={{ fontSize: '13px', fontWeight: 600 }}>Save for Later</div>
                <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>
                  Pin this project to your personal shelf for when inspiration strikes.
                </div>
              </div>
            </div>
            <ArrowRight size={14} color="var(--color-ink-muted)" />
          </button>
        </div>

        {/* Optional AI: Suggest Where I Fit */}
        {!aiSuggestionDismissed && (
          <div
            style={{
              padding: '12px 14px',
              backgroundColor: 'var(--color-ai-tint)',
              border: '1px solid #E8B9CC',
              borderRadius: 'var(--radius-control)',
              fontSize: '12px'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
              <span
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '4px',
                  fontWeight: 600,
                  color: '#6E1B3B',
                  fontSize: '11px'
                }}
              >
                <Sparkles size={12} />
                Suggest Where I Fit • Optional AI
              </span>
              <button
                onClick={() => setAiSuggestionDismissed(true)}
                style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '11px', color: '#6E1B3B' }}
              >
                Dismiss
              </button>
            </div>
            <p style={{ color: '#4A1527', lineHeight: 1.35 }}>
              AI analysis of your profile: You have WebAudio and DSP skills in common with Elena's unfilled Step 6 gap. Would you like to test a frequency-division filter branch?
            </p>
            <div style={{ marginTop: '8px', display: 'flex', gap: '8px' }}>
              <button
                onClick={() => handleStartBranch('WebAudio FFT Filter')}
                className="branch-btn"
                style={{
                  padding: '4px 10px',
                  fontSize: '11px',
                  backgroundColor: '#FFFFFF',
                  color: '#6E1B3B',
                  border: '1px solid #E8B9CC'
                }}
              >
                Adopt Suggestion
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
