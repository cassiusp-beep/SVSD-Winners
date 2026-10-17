import React from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { SEED_USERS } from '../../data/seedData';
import { StoryScrubber } from './StoryScrubber';
import { 
  User, 
  HelpCircle, 
  Bookmark, 
  BookOpen, 
  Sparkles, 
  LogOut, 
  LogIn,
  Sliders,
  Bell
} from 'lucide-react';

export const HotCorners: React.FC<{ onCenterPerson: () => void }> = ({ onCenterPerson }) => {
  const state = useBranchStore();
  const currentUser = SEED_USERS[state.currentUserId] || SEED_USERS.elena;
  const isGuest = state.currentUserId === 'guest';
  const unreadCount = state.notifications.filter(n => !n.read).length;

  return (
    <>
      {/* 1. TOP-LEFT HOT CORNER: Profile & Identity */}
      <div
        className="hotcorner-top-left"
        style={{
          position: 'fixed',
          top: 16,
          left: 16,
          zIndex: 1000,
          display: 'flex',
          alignItems: 'center',
          gap: '8px'
        }}
      >
        <div
          onClick={onCenterPerson}
          className="branch-card"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            padding: '6px 12px 6px 8px',
            cursor: 'pointer',
            backgroundColor: '#FFFFFF',
            borderRadius: 'var(--radius-pill)',
            boxShadow: 'var(--shadow-floating)'
          }}
          title="Profile Hot Corner • Click to center Home Hub"
          role="button"
          tabIndex={0}
        >
          <img
            src={isGuest ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=128&q=80' : currentUser.avatar}
            alt={currentUser.name}
            style={{ width: 28, height: 28, borderRadius: '50%', objectFit: 'cover' }}
          />
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontSize: '12px', fontWeight: 600, color: 'var(--color-ink)', lineHeight: 1.2 }}>
              {isGuest ? 'Guest' : currentUser.name.split(' ')[0]}
            </span>
            <span style={{ fontSize: '10px', color: 'var(--color-ink-muted)', lineHeight: 1 }}>
              {isGuest ? 'Browse Mode' : 'Home Hub'}
            </span>
          </div>
        </div>

        {/* Quick User Switcher for demo testing */}
        <div
          className="branch-card mobile-hide"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            padding: '4px 6px',
            backgroundColor: '#FFFFFF',
            borderRadius: 'var(--radius-pill)',
            fontSize: '11px'
          }}
        >
          <button
            onClick={() => branchStore.setCurrentUser('elena')}
            style={{
              padding: '2px 8px',
              borderRadius: 'var(--radius-pill)',
              border: 'none',
              background: state.currentUserId === 'elena' ? 'var(--color-ink)' : 'transparent',
              color: state.currentUserId === 'elena' ? '#FFFFFF' : 'var(--color-ink-muted)',
              cursor: 'pointer',
              fontWeight: 500
            }}
          >
            Elena
          </button>
          <button
            onClick={() => branchStore.setCurrentUser('marcus')}
            style={{
              padding: '2px 8px',
              borderRadius: 'var(--radius-pill)',
              border: 'none',
              background: state.currentUserId === 'marcus' ? 'var(--color-ink)' : 'transparent',
              color: state.currentUserId === 'marcus' ? '#FFFFFF' : 'var(--color-ink-muted)',
              cursor: 'pointer',
              fontWeight: 500
            }}
          >
            Marcus
          </button>
          <button
            onClick={() => branchStore.setCurrentUser(isGuest ? 'elena' : 'guest')}
            style={{
              padding: '2px 8px',
              borderRadius: 'var(--radius-pill)',
              border: 'none',
              background: isGuest ? 'var(--color-attention-ink)' : 'transparent',
              color: isGuest ? '#FFFFFF' : 'var(--color-ink-muted)',
              cursor: 'pointer',
              fontWeight: 500
            }}
          >
            {isGuest ? 'Exit Guest' : 'Guest'}
          </button>
        </div>

        {/* Notifications badge */}
        <button
          onClick={() => branchStore.openNode('notifications-node', 'left')}
          className="branch-card"
          style={{
            position: 'relative',
            width: 36,
            height: 36,
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: '#FFFFFF',
            border: '1px solid var(--color-border)',
            cursor: 'pointer'
          }}
          title="Notifications"
          aria-label="Quiet notifications"
        >
          <Bell size={16} color="var(--color-ink)" />
          {unreadCount > 0 && (
            <span
              style={{
                position: 'absolute',
                top: 2,
                right: 2,
                width: 8,
                height: 8,
                backgroundColor: 'var(--color-positive-ink)',
                borderRadius: '50%'
              }}
            />
          )}
        </button>

        {/* AI Flag Toggle */}
        <button
          onClick={() => branchStore.toggleAi()}
          className="branch-chip mobile-hide"
          style={{
            backgroundColor: state.aiEnabled ? 'var(--color-ai-tint)' : 'var(--color-surface)',
            color: state.aiEnabled ? '#6E1B3B' : 'var(--color-ink-muted)',
            border: `1px solid ${state.aiEnabled ? '#E4B5C6' : 'var(--color-border)'}`,
            cursor: 'pointer',
            boxShadow: 'var(--shadow-card)'
          }}
          title="AI as an Option: Toggle Ghost Nodes & Connection Explanations"
        >
          <Sparkles size={11} />
          <span>{state.aiEnabled ? 'AI Layer ON' : 'AI Layer OFF'}</span>
        </button>
      </div>

      {/* 2. TOP-RIGHT HOT CORNER: Help & Open Invite Loop */}
      <div
        className="hotcorner-top-right"
        style={{
          position: 'fixed',
          top: 16,
          right: 16,
          zIndex: 1000
        }}
      >
        <button
          onClick={() => branchStore.openModal('help')}
          className="branch-card"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '8px 14px',
            backgroundColor: 'var(--color-attention-bg)',
            borderColor: '#E2CCA6',
            color: 'var(--color-attention-ink)',
            cursor: 'pointer',
            borderRadius: 'var(--radius-pill)',
            fontWeight: 600,
            fontSize: '13px',
            boxShadow: 'var(--shadow-floating)'
          }}
          title="Help Hot Corner • Post Open Invite when stuck"
        >
          <HelpCircle size={16} />
          <span>I'm Stuck • Ask for Help</span>
        </button>
      </div>

      {/* 3. BOTTOM-LEFT HOT CORNER: Save & Private Drafts */}
      <div
        className="hotcorner-bottom-left"
        style={{
          position: 'fixed',
          bottom: 16,
          left: 16,
          zIndex: 1000
        }}
      >
        <button
          onClick={() => branchStore.openModal('save')}
          className="branch-card"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '8px 14px',
            backgroundColor: '#FFFFFF',
            cursor: 'pointer',
            borderRadius: 'var(--radius-pill)',
            fontSize: '13px',
            color: 'var(--color-ink)',
            boxShadow: 'var(--shadow-floating)'
          }}
          title="Save Hot Corner • Bookmarks & Private Drafts"
        >
          <Bookmark size={15} />
          <span>Saved ({state.savedProjectIds.length})</span>
        </button>
      </div>

      {/* 4. BOTTOM-RIGHT HOT CORNER: Story Scrubber */}
      <div
        className="hotcorner-bottom-right"
        style={{
          position: 'fixed',
          bottom: 16,
          right: 16,
          zIndex: 1000
        }}
      >
        <StoryScrubber />
      </div>
    </>
  );
};
