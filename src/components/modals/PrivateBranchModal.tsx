import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { SEED_USERS } from '../../data/seedData';
import { Lock, X, GitBranch, ArrowLeft, Check, Trash2, Code2 } from 'lucide-react';

export const PrivateBranchModal: React.FC = () => {
  const state = useBranchStore();
  const currentProject = state.projects.find(p => p.id === state.activeProjectId);
  const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
  const selectedNode = currentProject?.nodes.find(n => n.id === state.selectedNodeId) || currentProject?.nodes[0];

  const [branchTitle, setBranchTitle] = useState('WebAudio Frequency Modulator');
  const [branchIntent, setBranchIntent] = useState(
    'Mapped voice formant frequencies (175Hz for vowels, 235Hz for consonants) into PWM control signals for Elena’s dual LRAs, achieving 8ms latency.'
  );
  const [skill, setSkill] = useState('WebAudio & DSP Synthesis');

  if (state.activeModal !== 'privateBranch') return null;

  const handleKeepAndAddChapter = (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentProject || !selectedNode) return;
    branchStore.keepPrivateBranch(currentProject.id, selectedNode.id, branchTitle, branchIntent, skill);
  };

  const handleDiscard = () => {
    if (confirm('Discard this private draft and return to Home Hub? The original project was not touched.')) {
      branchStore.closeModal();
    }
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
          width: 540,
          maxWidth: '100%',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="branch-dialog-title"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '4px',
                padding: '3px 8px',
                backgroundColor: 'var(--color-surface-subtle)',
                borderRadius: 'var(--radius-pill)',
                fontSize: '11px',
                fontWeight: 600,
                color: 'var(--color-ink)'
              }}
            >
              <Lock size={11} />
              Private draft
            </span>
            <h3 id="branch-dialog-title" style={{ fontFamily: 'var(--font-display)', fontSize: '17px', fontWeight: 600 }}>
              Try It Privately
            </h3>
          </div>
          <button
            onClick={() => branchStore.closeModal()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Reassurance banner: The original is never touched */}
        <div
          style={{
            padding: '10px 14px',
            backgroundColor: 'var(--color-branch-tint)',
            borderRadius: 'var(--radius-control)',
            marginBottom: '16px',
            fontSize: '12px',
            color: '#341A59',
            lineHeight: 1.4
          }}
        >
          <strong>"The original is never touched."</strong>
          <p style={{ marginTop: '2px' }}>
            Branched from: <em>{currentProject?.title} • {selectedNode?.title}</em>.
            Your draft remains private until you choose to keep it. Keeping adds an offshoot chapter credited to {currentUser.name}.
          </p>
        </div>

        <form onSubmit={handleKeepAndAddChapter} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              Branch Chapter Title
            </label>
            <input
              type="text"
              value={branchTitle}
              onChange={(e) => setBranchTitle(e.target.value)}
              required
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: 'var(--radius-control)',
                border: '1px solid var(--color-border)',
                fontSize: '13px',
                color: 'var(--color-ink)'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              Offered Skill / Medium
            </label>
            <input
              type="text"
              value={skill}
              onChange={(e) => setSkill(e.target.value)}
              required
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: 'var(--radius-control)',
                border: '1px solid var(--color-border)',
                fontSize: '13px',
                color: 'var(--color-ink)'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              What did your branch discover or build? (Narrative Turning Point)
            </label>
            <textarea
              rows={3}
              value={branchIntent}
              onChange={(e) => setBranchIntent(e.target.value)}
              required
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: 'var(--radius-control)',
                border: '1px solid var(--color-border)',
                fontSize: '13px',
                color: 'var(--color-ink)',
                resize: 'vertical'
              }}
            />
          </div>

          {/* Artifact preview in sandbox */}
          <div style={{ padding: '10px 12px', backgroundColor: 'var(--color-surface-subtle)', borderRadius: 'var(--radius-control)', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Code2 size={24} color="var(--color-ink)" />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '12px', fontWeight: 600 }}>AudioWorklet DSP Pipeline</div>
              <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>JavaScript AudioWorklet • 8ms latency achieved</div>
            </div>
            <span className="branch-chip" style={{ backgroundColor: 'var(--color-surface)', fontSize: '10px' }}>
              Draft Ready
            </span>
          </div>

          {/* Actions: Discard, Try Again, Keep and Add Chapter */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '14px', paddingTop: '12px', borderTop: '1px solid var(--color-border-subtle)' }}>
            <button
              type="button"
              onClick={handleDiscard}
              className="branch-btn"
              style={{ color: 'var(--color-error-ink)', padding: '6px 12px', fontSize: '12px' }}
            >
              <Trash2 size={13} />
              <span>Discard draft</span>
            </button>

            <div style={{ display: 'flex', gap: '8px' }}>
              <button
                type="button"
                onClick={() => branchStore.closeModal()}
                className="branch-btn branch-btn-secondary"
                style={{ fontSize: '12px' }}
              >
                Keep Drafting
              </button>
              <button
                type="submit"
                className="branch-btn branch-btn-primary"
                style={{ fontSize: '12px' }}
              >
                <Check size={14} />
                <span>Keep and Add Chapter</span>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
