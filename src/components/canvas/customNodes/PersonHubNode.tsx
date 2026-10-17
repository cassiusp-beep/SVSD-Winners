import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';
import { FolderGit2, Users, Wrench, Sparkles, AlertCircle } from 'lucide-react';

interface PersonHubNodeProps {
  id: string;
  data: {
    userId: string;
    isGuest?: boolean;
    isDocked?: boolean;
  };
  selected?: boolean;
}

export const PersonHubNode = memo(({ data, selected }: PersonHubNodeProps) => {
  const state = useBranchStore();
  const [hoveredPetal, setHoveredPetal] = useState<string | null>(null);
  const isTargeted = state.hoveredDropTargetId === 'person-hub';

  const handlePetalClick = (type: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (type === 'projects') {
      branchStore.setActiveProject('haptic-weave');
      branchStore.setViewMode('story');
    } else if (type === 'gaps') {
      branchStore.setSelectedNodeId('hw-gap1');
    }
  };

  const petals = [
    { id: 'projects', label: 'Projects', angle: -135, icon: FolderGit2, count: '3' },
    { id: 'connections', label: 'Connections', angle: -45, icon: Users, count: '12' },
    { id: 'skills', label: 'Skills', angle: 40, icon: Wrench, count: '6' },
    { id: 'interests', label: 'Interests', angle: 90, icon: Sparkles, count: '8' },
    { id: 'gaps', label: 'Needs & Gaps', angle: 140, icon: AlertCircle, count: '1 open', isAmber: true },
  ];

  const petalDistance = 88;

  return (
    <div
      style={{
        position: 'relative',
        width: 280,
        height: 280,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        pointerEvents: 'none',
      }}
    >
      {/* Invisible Handles */}
      <Handle type="source" position={Position.Left} id="left-source" style={{ opacity: 0, left: 20 }} />
      <Handle type="target" position={Position.Left} id="left-target" style={{ opacity: 0, left: 20 }} />
      <Handle type="source" position={Position.Right} id="right-source" style={{ opacity: 0, right: 20 }} />
      <Handle type="target" position={Position.Right} id="right-target" style={{ opacity: 0, right: 20 }} />
      <Handle type="source" position={Position.Top} id="top-source" style={{ opacity: 0, top: 20 }} />
      <Handle type="source" position={Position.Bottom} id="bottom-source" style={{ opacity: 0, bottom: 20 }} />

      {/* Radiant Emerald Aura behind petals */}
      <div
        style={{
          position: 'absolute',
          width: 220,
          height: 220,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(13, 143, 91, 0.16) 0%, rgba(13, 143, 91, 0.04) 55%, transparent 75%)',
          filter: 'blur(10px)',
          pointerEvents: 'none',
        }}
      />

      {/* SVG Connecting Bridges between Center and Petals */}
      <svg
        width="280"
        height="280"
        style={{
          position: 'absolute',
          inset: 0,
          pointerEvents: 'none',
        }}
      >
        {petals.map((petal) => {
          const rad = (petal.angle * Math.PI) / 180;
          const x2 = 140 + Math.cos(rad) * petalDistance;
          const y2 = 140 + Math.sin(rad) * petalDistance;
          const isHovered = hoveredPetal === petal.id;
          const strokeColor = petal.isAmber ? '#FF9F0A' : '#0D8F5B';
          return (
            <line
              key={`line-${petal.id}`}
              x1={140}
              y1={140}
              x2={x2}
              y2={y2}
              stroke={strokeColor}
              strokeWidth={isHovered ? 4 : 2.5}
              strokeOpacity={isHovered ? 0.9 : 0.4}
              strokeLinecap="round"
              style={{ transition: 'all 0.25s ease' }}
            />
          );
        })}
      </svg>

      {/* Bulbing Petal Lobes */}
      {petals.map((petal) => {
        const rad = (petal.angle * Math.PI) / 180;
        const x = Math.cos(rad) * petalDistance;
        const y = Math.sin(rad) * petalDistance;
        const isHovered = hoveredPetal === petal.id;
        const borderColor = petal.isAmber ? '#FF9F0A' : '#0D8F5B';

        return (
          <div
            key={petal.id}
            onClick={(e) => handlePetalClick(petal.id, e)}
            onMouseEnter={() => setHoveredPetal(petal.id)}
            onMouseLeave={() => setHoveredPetal(null)}
            className="nodrag"
            style={{
              position: 'absolute',
              transform: `translate(${x}px, ${y}px) scale(${isHovered ? 1.08 : 1})`,
              width: 68,
              height: 68,
              borderRadius: '50%',
              backgroundColor: '#FFFFFF',
              border: `1.75px solid ${borderColor}`,
              boxShadow: isHovered
                ? `0 6px 20px ${borderColor}40, 0 2px 6px rgba(0,0,0,0.06)`
                : '0 4px 14px rgba(24, 28, 38, 0.08)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              pointerEvents: 'auto',
              transition: 'all 0.25s cubic-bezier(0.16, 1, 0.3, 1)',
              zIndex: 3,
            }}
          >
            <span
              style={{
                fontSize: '10px',
                fontWeight: 700,
                color: '#191C24',
                lineHeight: 1.1,
                textAlign: 'center',
              }}
            >
              {petal.label}
            </span>
            <span
              style={{
                fontSize: '8.5px',
                color: petal.isAmber ? '#D97706' : '#5F667A',
                fontWeight: 500,
                marginTop: 2,
              }}
            >
              {petal.count}
            </span>
          </div>
        );
      })}

      {/* Central Maker Profile Hub */}
      <div
        className="nodrag"
        style={{
          position: 'relative',
          width: 120,
          height: 120,
          borderRadius: '50%',
          backgroundColor: '#FFFFFF',
          border: '2.5px solid #0D8F5B',
          boxShadow: isTargeted
            ? '0 0 32px rgba(13, 143, 91, 0.45), 0 8px 24px rgba(0,0,0,0.12)'
            : '0 10px 30px rgba(13, 143, 91, 0.2), 0 2px 6px rgba(0,0,0,0.06)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          pointerEvents: 'auto',
          zIndex: 4,
          cursor: 'grab',
          transition: 'all 0.3s ease',
        }}
      >
        {/* Avatar Photo */}
        <div
          style={{
            width: 52,
            height: 52,
            borderRadius: '50%',
            overflow: 'hidden',
            border: '2px solid #FFFFFF',
            boxShadow: '0 2px 8px rgba(0,0,0,0.12)',
            marginBottom: 4,
          }}
        >
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80"
            alt="Elena Rostova"
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        </div>

        {/* Name and Department */}
        <div style={{ textAlign: 'center', padding: '0 4px' }}>
          <div style={{ fontSize: '11px', fontWeight: 700, color: '#191C24', lineHeight: 1.1 }}>
            Elena Rostova
          </div>
          <div style={{ fontSize: '8.5px', color: '#5F667A', fontWeight: 500, marginTop: 1 }}>
            UC Berkeley MDes
          </div>
        </div>
      </div>
    </div>
  );
});
