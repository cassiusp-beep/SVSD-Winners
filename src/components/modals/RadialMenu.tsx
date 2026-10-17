import React, { useEffect, useRef } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { 
  Sliders, 
  Bell, 
  Users, 
  Compass, 
  PlusCircle, 
  FileText, 
  LogOut,
  X
} from 'lucide-react';

export const RadialMenu: React.FC = () => {
  const state = useBranchStore();
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') branchStore.closeRadialMenu();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  if (!state.radialMenu?.isOpen) return null;

  const { x, y } = state.radialMenu;

  const handleAction = (action: string) => {
    branchStore.closeRadialMenu();
    switch (action) {
      case 'settings':
        branchStore.openNode('settings-node', 'left');
        break;
      case 'notifications':
        branchStore.openNode('notifications-node', 'left');
        break;
      case 'network':
        branchStore.openNode('network-node', 'left');
        break;
      case 'explore':
        branchStore.openNode('explore-node', 'right');
        break;
      case 'newStory':
        branchStore.openModal('help');
        break;
      case 'logout':
        branchStore.setCurrentUser('guest');
        break;
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 2500,
        backgroundColor: 'rgba(32, 36, 32, 0.15)'
      }}
      onClick={() => branchStore.closeRadialMenu()}
    >
      <div
        ref={menuRef}
        className="branch-card"
        style={{
          position: 'absolute',
          left: Math.min(x, window.innerWidth - 300),
          top: Math.min(y, window.innerHeight - 340),
          width: 280,
          padding: '16px',
          backgroundColor: '#FFFFFF',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="menu"
        aria-label="Profile radial context menu"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
          <span style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', color: 'var(--color-ink-muted)' }}>
            Spatial Actions
          </span>
          <button
            onClick={() => branchStore.closeRadialMenu()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
          >
            <X size={14} />
          </button>
        </div>

        {/* Spatial Groups: Left (Me) vs Right (The World) */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
          <div style={{ fontSize: '10px', fontWeight: 600, color: 'var(--color-ink-muted)', marginTop: '4px' }}>
            ← BLOOM LEFT (Personal & Network)
          </div>
          <button
            onClick={() => handleAction('settings')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px' }}
          >
            <Sliders size={14} />
            <span>Settings & Profile</span>
          </button>
          <button
            onClick={() => handleAction('notifications')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px' }}
          >
            <Bell size={14} />
            <span>Quiet Notifications</span>
          </button>
          <button
            onClick={() => handleAction('network')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px' }}
          >
            <Users size={14} />
            <span>Collaborator Network (Ring/List)</span>
          </button>

          <div style={{ fontSize: '10px', fontWeight: 600, color: 'var(--color-ink-muted)', marginTop: '10px' }}>
            → BLOOM RIGHT (Work & Discovery)
          </div>
          <button
            onClick={() => handleAction('explore')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px' }}
          >
            <Compass size={14} />
            <span>Explore & Feeds</span>
          </button>
          <button
            onClick={() => handleAction('newStory')}
            className="branch-btn branch-btn-secondary"
            style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px' }}
          >
            <PlusCircle size={14} />
            <span>New Story / Ask for Help</span>
          </button>

          <div style={{ borderTop: '1px solid var(--color-border-subtle)', marginTop: '8px', paddingTop: '8px' }}>
            <button
              onClick={() => handleAction('logout')}
              className="branch-btn"
              style={{ justifyContent: 'flex-start', padding: '6px 10px', fontSize: '12px', width: '100%', color: 'var(--color-error-ink)' }}
            >
              <LogOut size={14} />
              <span>Switch to Guest / Log Out</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
