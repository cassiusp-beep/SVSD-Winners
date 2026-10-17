import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { branchStore } from '../../../store/branchStore';
import { Compass, Flame, Shuffle, Layers, Pin, PinOff, X, ArrowRight } from 'lucide-react';

interface ExploreNodeProps {
  id: string;
  data: {
    isPinned?: boolean;
  };
}

export const ExploreNode = memo(({ id, data }: ExploreNodeProps) => {
  const isPinned = data.isPinned;

  const handleOpenTinder = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.openModal('tinder');
  };

  const handleShuffle = (e: React.MouseEvent) => {
    e.stopPropagation();
    const state = branchStore.getState();
    const otherProjects = state.projects.filter(p => p.id !== state.activeProjectId);
    if (otherProjects.length > 0) {
      const random = otherProjects[Math.floor(Math.random() * otherProjects.length)];
      branchStore.setActiveProject(random.id);
    }
  };

  return (
    <div
      className="branch-card"
      style={{
        width: 290,
        padding: '16px',
        backgroundColor: '#FFFFFF',
        borderColor: 'var(--color-border)',
        boxShadow: 'var(--shadow-floating)'
      }}
    >
      <Handle type="target" position={Position.Left} id="explore-target" style={{ background: '#767D73' }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Compass size={16} color="var(--color-ink)" />
          <h4 style={{ fontFamily: 'var(--font-display)', fontSize: '14px', fontWeight: 600 }}>
            Explore & Discover
          </h4>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <button
            onClick={() => branchStore.togglePinNode(id)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: isPinned ? 'var(--color-ink)' : 'var(--color-ink-muted)' }}
          >
            {isPinned ? <Pin size={14} fill="var(--color-ink)" /> : <PinOff size={14} />}
          </button>
          <button
            onClick={() => branchStore.closeNode(id)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: 'var(--color-ink-muted)' }}
          >
            <X size={14} />
          </button>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <button
          onClick={handleOpenTinder}
          className="branch-btn branch-btn-secondary"
          style={{ justifyContent: 'space-between', width: '100%', padding: '10px 12px' }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Flame size={16} color="#E65100" />
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '12px', fontWeight: 600 }}>Tinder Style Feed</div>
              <div style={{ fontSize: '10px', color: 'var(--color-ink-muted)' }}>Swipe on Open Invites & gaps</div>
            </div>
          </div>
          <ArrowRight size={14} />
        </button>

        <button
          onClick={handleShuffle}
          className="branch-btn branch-btn-secondary"
          style={{ justifyContent: 'space-between', width: '100%', padding: '10px 12px' }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Shuffle size={16} color="var(--color-focus)" />
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '12px', fontWeight: 600 }}>Shuffle</div>
              <div style={{ fontSize: '10px', color: 'var(--color-ink-muted)' }}>Stumble upon an unfinished idea</div>
            </div>
          </div>
          <ArrowRight size={14} />
        </button>
      </div>

      <p style={{ marginTop: '12px', fontSize: '11px', color: 'var(--color-ink-faint)', textAlign: 'center' }}>
        No accounts needed to browse • Wandering by design
      </p>
    </div>
  );
});

ExploreNode.displayName = 'ExploreNode';
