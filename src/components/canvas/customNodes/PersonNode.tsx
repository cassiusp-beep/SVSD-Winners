import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { SEED_USERS } from '../../../data/seedData';
import { branchStore } from '../../../store/branchStore';
import { Compass, Sparkles, Pin, PinOff, MoreHorizontal } from 'lucide-react';

interface PersonNodeProps {
  id: string;
  data: {
    userId: string;
    isPinned?: boolean;
    isGuest?: boolean;
    onRightClick?: (e: React.MouseEvent) => void;
  };
  selected?: boolean;
}

export const PersonNode = memo(({ data, selected }: PersonNodeProps) => {
  const user = SEED_USERS[data.userId] || SEED_USERS.elena;
  const isGuest = data.isGuest || data.userId === 'guest';

  const handleClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    // Left-click blooms Living Map & projects to the right
    branchStore.openNode('explore-node', 'right');
  };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    branchStore.openRadialMenu(e.clientX, e.clientY);
  };

  return (
    <div
      onClick={handleClick}
      onContextMenu={handleContextMenu}
      className={`branch-card ${selected ? 'ring-2' : ''}`}
      style={{
        width: 240,
        padding: '16px',
        backgroundColor: '#FFFFFF',
        borderColor: selected ? 'var(--color-ink)' : 'var(--color-border)',
        boxShadow: selected ? 'var(--shadow-popover)' : 'var(--shadow-card)',
        position: 'relative'
      }}
      tabIndex={0}
      role="button"
      aria-label={`Person node: ${user.name}. Left click to expand work, right click for profile menu.`}
    >
      {/* Handles for blooming connections */}
      <Handle type="source" position={Position.Left} id="left-source" style={{ background: '#767D73' }} />
      <Handle type="target" position={Position.Left} id="left-target" style={{ background: '#767D73' }} />
      <Handle type="source" position={Position.Right} id="right-source" style={{ background: '#767D73' }} />
      <Handle type="target" position={Position.Right} id="right-target" style={{ background: '#767D73' }} />

      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <img
          src={isGuest ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=128&q=80' : user.avatar}
          alt={user.name}
          style={{
            width: 48,
            height: 48,
            borderRadius: 'var(--radius-pill)',
            objectFit: 'cover',
            border: '2px solid var(--color-surface-subtle)'
          }}
        />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h3
              style={{
                fontFamily: 'var(--font-display)',
                fontSize: '15px',
                fontWeight: 600,
                color: 'var(--color-ink)',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis'
              }}
            >
              {isGuest ? 'Guest Explorer' : user.name}
            </h3>
            <button
              onClick={(e) => {
                e.stopPropagation();
                branchStore.openRadialMenu(e.clientX, e.clientY);
              }}
              className="nodrag"
              style={{
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: 'var(--color-ink-muted)',
                padding: '2px'
              }}
              aria-label="Profile actions"
            >
              <MoreHorizontal size={16} />
            </button>
          </div>
          <p
            style={{
              fontSize: '12px',
              color: 'var(--color-ink-muted)',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis'
            }}
          >
            {isGuest ? 'Browsing anonymously' : user.discipline}
          </p>
        </div>
      </div>

      <div style={{ marginTop: '12px', display: 'flex', alignItems: 'center', gap: '6px', flexWrap: 'wrap' }}>
        <span
          className="branch-chip"
          style={{
            backgroundColor: 'var(--color-surface-subtle)',
            color: 'var(--color-ink)',
            fontSize: '11px'
          }}
        >
          {isGuest ? 'Guest Mode' : 'Home Hub'}
        </span>
        {!isGuest && (
          <span
            className="branch-chip"
            style={{
              backgroundColor: 'var(--color-decision-tint)',
              color: 'var(--color-positive-ink)',
              fontSize: '11px'
            }}
          >
            {user.institution}
          </span>
        )}
      </div>

      <div
        style={{
          marginTop: '10px',
          paddingTop: '8px',
          borderTop: '1px solid var(--color-border-subtle)',
          fontSize: '11px',
          color: 'var(--color-ink-faint)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center'
        }}
      >
        <span>Right-click for Menu</span>
        <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
          Left = Me • Right = World
        </span>
      </div>
    </div>
  );
});

PersonNode.displayName = 'PersonNode';
