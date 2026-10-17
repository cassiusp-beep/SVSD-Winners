import React from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { SEED_USERS } from '../../data/seedData';
import { X, Sliders, Bell, Users, Compass, BookOpen, GitBranch } from 'lucide-react';

export const MobileSheet: React.FC = () => {
  const state = useBranchStore();
  const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
  const currentProject = state.projects.find(p => p.id === state.activeProjectId);

  if (!state.mobileSheetOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(32, 36, 32, 0.4)',
        zIndex: 2200,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-end'
      }}
      onClick={() => branchStore.toggleMobileSheet(false)}
    >
      <div
        className="branch-card"
        style={{
          width: '100%',
          maxHeight: '75vh',
          backgroundColor: '#FFFFFF',
          borderTopLeftRadius: '20px',
          borderTopRightRadius: '20px',
          padding: '20px',
          overflowY: 'auto',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <img
              src={currentUser.avatar}
              alt={currentUser.name}
              style={{ width: 32, height: 32, borderRadius: '50%', objectFit: 'cover' }}
            />
            <div>
              <div style={{ fontSize: '13px', fontWeight: 600 }}>{currentUser.name}</div>
              <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)' }}>{currentUser.discipline}</div>
            </div>
          </div>
          <button
            onClick={() => branchStore.toggleMobileSheet(false)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Section 1: Personal (Left Items) */}
        <div style={{ marginBottom: '16px' }}>
          <div style={{ fontSize: '11px', fontWeight: 600, color: 'var(--color-ink-muted)', textTransform: 'uppercase', marginBottom: '8px' }}>
            Personal & Network
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
            <button
              onClick={() => {
                branchStore.openNode('notifications-node', 'left');
                branchStore.toggleMobileSheet(false);
              }}
              className="branch-btn branch-btn-secondary"
              style={{ justifyContent: 'flex-start', padding: '8px 10px', fontSize: '12px' }}
            >
              <Bell size={14} />
              <span>Notifications ({state.notifications.filter(n => !n.read).length})</span>
            </button>
            <button
              onClick={() => {
                branchStore.openNode('network-node', 'left');
                branchStore.toggleMobileSheet(false);
              }}
              className="branch-btn branch-btn-secondary"
              style={{ justifyContent: 'flex-start', padding: '8px 10px', fontSize: '12px' }}
            >
              <Users size={14} />
              <span>Network Ring</span>
            </button>
          </div>
        </div>

        {/* Section 2: Active Story */}
        {currentProject && (
          <div style={{ marginBottom: '16px' }}>
            <div style={{ fontSize: '11px', fontWeight: 600, color: 'var(--color-ink-muted)', textTransform: 'uppercase', marginBottom: '8px' }}>
              Current Project Story
            </div>
            <div style={{ padding: '12px', backgroundColor: 'var(--color-surface-subtle)', borderRadius: 'var(--radius-control)' }}>
              <div style={{ fontSize: '13px', fontWeight: 600 }}>{currentProject.title}</div>
              <p style={{ fontSize: '11px', color: 'var(--color-ink-muted)', margin: '4px 0 8px 0' }}>
                {currentProject.startingQuestion}
              </p>
              <div style={{ display: 'flex', gap: '6px' }}>
                <button
                  onClick={() => {
                    branchStore.openModal('findYourPlace');
                    branchStore.toggleMobileSheet(false);
                  }}
                  className="branch-btn branch-btn-primary"
                  style={{ flex: 1, padding: '6px 10px', fontSize: '11px' }}
                >
                  <GitBranch size={12} />
                  <span>Branch Project</span>
                </button>
                <button
                  onClick={() => {
                    branchStore.openModal('help');
                    branchStore.toggleMobileSheet(false);
                  }}
                  className="branch-btn branch-btn-attention"
                  style={{ flex: 1, padding: '6px 10px', fontSize: '11px' }}
                >
                  <span>Post Open Invite</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Section 3: Discovery */}
        <div>
          <button
            onClick={() => {
              branchStore.openModal('tinder');
              branchStore.toggleMobileSheet(false);
            }}
            className="branch-btn branch-btn-secondary"
            style={{ width: '100%', justifyContent: 'center', padding: '10px' }}
          >
            <Compass size={16} />
            <span>Open Tinder Style Swipe Deck</span>
          </button>
        </div>
      </div>
    </div>
  );
};
