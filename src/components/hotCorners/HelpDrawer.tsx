import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { HelpCircle, X, Send, Compass, UserCheck } from 'lucide-react';

export const HelpDrawer: React.FC = () => {
  const state = useBranchStore();
  const currentProject = state.projects.find(p => p.id === state.activeProjectId);

  const [gapTitle, setGapTitle] = useState('Need Audio DSP / Mechatronics Bridge');
  const [needDescription, setNeedDescription] = useState(
    'Hardware LRAs are tuned to 175Hz and 235Hz. Need someone in Audio DSP or Creative Coding to build real-time speech frequency split algorithms so narrative words vibrate dynamically.'
  );
  const [discipline, setDiscipline] = useState('Creative Tech / Audio DSP');

  if (state.activeModal !== 'help') return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentProject) return;
    branchStore.postOpenInvite(currentProject.id, gapTitle, needDescription, discipline);
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
          width: 480,
          maxWidth: '100%',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="help-dialog-title"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Compass size={20} color="var(--color-attention-ink)" />
            <h3 id="help-dialog-title" style={{ fontFamily: 'var(--font-display)', fontSize: '18px', fontWeight: 600 }}>
              Ask for Help • Post Open Invite
            </h3>
          </div>
          <button
            onClick={() => branchStore.closeModal()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
            aria-label="Close dialog"
          >
            <X size={18} />
          </button>
        </div>

        <div style={{ padding: '10px 12px', backgroundColor: 'var(--color-attention-bg)', borderRadius: 'var(--radius-control)', marginBottom: '16px', fontSize: '12px', color: 'var(--color-attention-ink)', lineHeight: 1.4 }}>
          <strong>"Not permission to use it, help to iterate."</strong>
          <p style={{ marginTop: '2px' }}>
            When you post an invite, an open gap appears on your project story and enters the discovery feeds. When someone branches it, their work grows beside yours with full attribution. No approval queues.
          </p>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              Project
            </label>
            <input
              type="text"
              readOnly
              value={currentProject?.title || 'Active Project'}
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: 'var(--radius-control)',
                border: '1px solid var(--color-border)',
                backgroundColor: 'var(--color-surface-subtle)',
                fontSize: '13px',
                color: 'var(--color-ink)'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              Where could someone contribute? (Gap Title)
            </label>
            <input
              type="text"
              value={gapTitle}
              onChange={(e) => setGapTitle(e.target.value)}
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
              What is the obstacle / what has been tried?
            </label>
            <textarea
              rows={3}
              value={needDescription}
              onChange={(e) => setNeedDescription(e.target.value)}
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

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, marginBottom: '4px', color: 'var(--color-ink)' }}>
              Target Discipline
            </label>
            <select
              value={discipline}
              onChange={(e) => setDiscipline(e.target.value)}
              style={{
                width: '100%',
                padding: '8px 12px',
                borderRadius: 'var(--radius-control)',
                border: '1px solid var(--color-border)',
                fontSize: '13px',
                backgroundColor: '#FFFFFF',
                color: 'var(--color-ink)'
              }}
            >
              <option value="Creative Tech / Audio DSP">Creative Tech / Audio DSP</option>
              <option value="Mechatronics & Robotics">Mechatronics & Robotics</option>
              <option value="Sound Design & Acoustics">Sound Design & Acoustics</option>
              <option value="Material & Textile Fabrication">Material & Textile Fabrication</option>
              <option value="Computational Architecture">Computational Architecture</option>
            </select>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '12px' }}>
            <button
              type="button"
              onClick={() => branchStore.closeModal()}
              className="branch-btn branch-btn-secondary"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="branch-btn branch-btn-attention"
              style={{ fontWeight: 600 }}
            >
              <Send size={14} />
              <span>Post Open Invite</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
