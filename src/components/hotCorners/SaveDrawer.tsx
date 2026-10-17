import React from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { Bookmark, X, ArrowRight, Heart, ExternalLink } from 'lucide-react';

export const SaveDrawer: React.FC = () => {
  const state = useBranchStore();

  if (state.activeModal !== 'save') return null;

  const savedProjects = state.projects.filter(p => state.savedProjectIds.includes(p.id));

  const handleSelect = (projectId: string) => {
    branchStore.setActiveProject(projectId);
    branchStore.closeModal();
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
          width: 440,
          maxWidth: '100%',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="save-dialog-title"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Bookmark size={20} color="var(--color-ink)" />
            <h3 id="save-dialog-title" style={{ fontFamily: 'var(--font-display)', fontSize: '18px', fontWeight: 600 }}>
              Saved Projects & Drafts
            </h3>
          </div>
          <button
            onClick={() => branchStore.closeModal()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
          >
            <X size={18} />
          </button>
        </div>

        <p style={{ fontSize: '12px', color: 'var(--color-ink-muted)', marginBottom: '16px' }}>
          Projects bookmarked for future experimentation. Private drafts stay local and isolated until kept.
        </p>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxHeight: '320px', overflowY: 'auto' }}>
          {savedProjects.length === 0 ? (
            <p style={{ fontSize: '13px', color: 'var(--color-ink-muted)', textAlign: 'center', padding: '24px 0' }}>
              No saved projects yet. Click the heart icon on any project card to bookmark it.
            </p>
          ) : (
            savedProjects.map((p) => (
              <div
                key={p.id}
                onClick={() => handleSelect(p.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  padding: '10px 12px',
                  borderRadius: 'var(--radius-control)',
                  border: '1px solid var(--color-border)',
                  backgroundColor: 'var(--color-surface)',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease'
                }}
              >
                <img
                  src={p.heroMedia}
                  alt={p.title}
                  style={{ width: 44, height: 44, borderRadius: 'var(--radius-media)', objectFit: 'cover' }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--color-ink)' }}>{p.title}</div>
                  <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>By {p.creatorName} • {p.creatorDiscipline}</div>
                </div>
                <ArrowRight size={14} color="var(--color-ink-muted)" />
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
