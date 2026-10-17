import React, { useState, memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { SEED_USERS } from '../../../data/seedData';
import { branchStore } from '../../../store/branchStore';
import { Users, LayoutGrid, List, Pin, PinOff, X, Star } from 'lucide-react';

interface NetworkNodeProps {
  id: string;
  data: {
    isPinned?: boolean;
  };
}

export const NetworkNode = memo(({ id, data }: NetworkNodeProps) => {
  const [viewMode, setViewMode] = useState<'ring' | 'list'>('ring');
  const [favoriteIds, setFavoriteIds] = useState<string[]>(['marcus']);
  const isPinned = data.isPinned;

  const collaborators = [SEED_USERS.marcus, SEED_USERS.amina, SEED_USERS.lucas];

  const handleSelectCollaborator = (userId: string) => {
    // Clicking a collaborator opens their person node beside yours or shows their work
    branchStore.setCurrentUser(userId);
  };

  const toggleFavorite = (userId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setFavoriteIds(prev =>
      prev.includes(userId) ? prev.filter(x => x !== userId) : [...prev, userId]
    );
  };

  return (
    <div
      className="branch-card"
      style={{
        width: 300,
        padding: '16px',
        backgroundColor: '#FFFFFF',
        borderColor: 'var(--color-border)',
        boxShadow: 'var(--shadow-floating)'
      }}
    >
      <Handle type="source" position={Position.Right} id="network-source" style={{ background: '#767D73' }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Users size={16} color="var(--color-ink)" />
          <h4 style={{ fontFamily: 'var(--font-display)', fontSize: '14px', fontWeight: 600 }}>
            Collaborators Network
          </h4>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          {/* Ring / List toggle */}
          <button
            onClick={() => setViewMode(viewMode === 'ring' ? 'list' : 'ring')}
            className="nodrag"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '3px',
              padding: '3px 6px',
              fontSize: '11px',
              background: 'var(--color-surface-subtle)',
              border: '1px solid var(--color-border)',
              borderRadius: 'var(--radius-pill)',
              cursor: 'pointer'
            }}
          >
            {viewMode === 'ring' ? <List size={12} /> : <LayoutGrid size={12} />}
            <span>{viewMode === 'ring' ? 'List' : 'Ring'}</span>
          </button>
          <button
            onClick={() => branchStore.togglePinNode(id)}
            className="nodrag"
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: isPinned ? 'var(--color-ink)' : 'var(--color-ink-muted)' }}
          >
            {isPinned ? <Pin size={14} fill="var(--color-ink)" /> : <PinOff size={14} />}
          </button>
          <button
            onClick={() => branchStore.closeNode(id)}
            className="nodrag"
            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px', color: 'var(--color-ink-muted)' }}
          >
            <X size={14} />
          </button>
        </div>
      </div>

      {viewMode === 'ring' ? (
        <div
          style={{
            position: 'relative',
            height: 180,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'var(--color-surface-subtle)',
            borderRadius: 'var(--radius-card)',
            overflow: 'hidden'
          }}
        >
          {/* Inner ring circle */}
          <div
            style={{
              position: 'absolute',
              width: 130,
              height: 130,
              borderRadius: '50%',
              border: '1px dashed var(--color-border)',
              pointerEvents: 'none'
            }}
          />

          {/* Center indicator */}
          <div style={{ fontSize: '11px', color: 'var(--color-ink-faint)', textAlign: 'center', pointerEvents: 'none' }}>
            Inner Ring: Favorites
          </div>

          {/* Radial positioned collaborator nodes */}
          {collaborators.map((c, i) => {
            const isFav = favoriteIds.includes(c.id);
            const angle = (i * (2 * Math.PI)) / collaborators.length - Math.PI / 2;
            const radius = isFav ? 45 : 70;
            const x = Math.cos(angle) * radius;
            const y = Math.sin(angle) * radius;

            return (
              <div
                key={c.id}
                onClick={() => handleSelectCollaborator(c.id)}
                className="nodrag"
                style={{
                  position: 'absolute',
                  transform: `translate(${x}px, ${y}px)`,
                  cursor: 'pointer',
                  textAlign: 'center',
                  transition: 'all 0.2s ease'
                }}
                title={`${c.name} (${c.discipline}) - Click to switch view`}
              >
                <div style={{ position: 'relative', display: 'inline-block' }}>
                  <img
                    src={c.avatar}
                    alt={c.name}
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: '50%',
                      border: isFav ? '2px solid var(--color-ink)' : '2px solid #FFFFFF',
                      boxShadow: 'var(--shadow-card)',
                      objectFit: 'cover'
                    }}
                  />
                  {isFav && (
                    <div
                      style={{
                        position: 'absolute',
                        bottom: -2,
                        right: -2,
                        backgroundColor: '#FFFFFF',
                        borderRadius: '50%',
                        padding: 1
                      }}
                    >
                      <Star size={10} fill="#E5A11A" color="#E5A11A" />
                    </div>
                  )}
                </div>
                <div style={{ fontSize: '10px', fontWeight: 600, color: 'var(--color-ink)' }}>
                  {c.name.split(' ')[0]}
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
          {collaborators.map((c) => {
            const isFav = favoriteIds.includes(c.id);
            return (
              <div
                key={c.id}
                onClick={() => handleSelectCollaborator(c.id)}
                className="nodrag"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '8px 10px',
                  borderRadius: 'var(--radius-control)',
                  backgroundColor: 'var(--color-surface-subtle)',
                  cursor: 'pointer'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <img
                    src={c.avatar}
                    alt={c.name}
                    style={{ width: 28, height: 28, borderRadius: '50%', objectFit: 'cover' }}
                  />
                  <div>
                    <div style={{ fontSize: '12px', fontWeight: 600 }}>{c.name}</div>
                    <div style={{ fontSize: '10px', color: 'var(--color-ink-muted)' }}>{c.discipline}</div>
                  </div>
                </div>
                <button
                  onClick={(e) => toggleFavorite(c.id, e)}
                  className="nodrag"
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
                >
                  <Star size={14} fill={isFav ? '#E5A11A' : 'none'} color={isFav ? '#E5A11A' : 'var(--color-ink-muted)'} />
                </button>
              </div>
            );
          })}
        </div>
      )}

      <p style={{ marginTop: '10px', fontSize: '11px', color: 'var(--color-ink-muted)', textAlign: 'center' }}>
        Click any maker to view their anchored story beside yours.
      </p>
    </div>
  );
});

NetworkNode.displayName = 'NetworkNode';
