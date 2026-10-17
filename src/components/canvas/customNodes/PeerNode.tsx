/**
 * PeerNode — Collaborator Maker Badge (TouchDesigner / Studio Inspired)
 * Compact maker badge card on the left personal/network space.
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';

interface PeerNodeProps {
  id: string;
  data: {
    peer: {
      id: string;
      name: string;
      institution: string;
      title: string;
      description: string;
      accentColor: string;
      avatarUrl?: string;
    };
  };
}

const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const NODE_RAISED = 'var(--node-raised, #F4F3EE)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';

export const PeerNode = memo(({ data }: PeerNodeProps) => {
  const { peer } = data;
  const [hovered, setHovered] = useState(false);

  const avatarUrl =
    peer.id === 'amina-diallo'
      ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=128&q=80'
      : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=128&q=80';

  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className="nodrag"
      style={{
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        backgroundColor: hovered ? NODE_RAISED : NODE_BG,
        borderRadius: 6,
        border: `1px solid ${hovered ? peer.accentColor : BORDER}`,
        padding: '5px 9px 5px 5px',
        boxShadow: hovered
          ? '0 4px 12px rgba(0, 0, 0, 0.08)'
          : '0 1px 4px rgba(0, 0, 0, 0.03)',
        cursor: 'pointer',
        pointerEvents: 'auto',
        transition: 'all 180ms ease',
      }}
    >
      <Handle
        type="source"
        position={Position.Right}
        id="peer-source"
        style={{ right: -4, top: '50%' }}
      />
      <Handle
        type="target"
        position={Position.Left}
        id="peer-target"
        style={{ left: -4, top: '50%' }}
      />

      <img
        src={peer.avatarUrl || avatarUrl}
        alt={peer.name}
        style={{
          width: 28,
          height: 28,
          borderRadius: 4,
          objectFit: 'cover',
          border: `1px solid ${BORDER}`,
        }}
      />

      <div style={{ display: 'flex', flexDirection: 'column' }}>
        <span
          style={{
            fontSize: '10.5px',
            fontWeight: 700,
            color: TEXT,
            fontFamily: "'Space Grotesk', sans-serif",
            lineHeight: 1.1,
          }}
        >
          {peer.name}
        </span>
        <span
          style={{
            fontSize: '8.5px',
            color: peer.accentColor,
            fontWeight: 600,
            marginTop: 1,
          }}
        >
          {peer.institution}
        </span>
      </div>
    </div>
  );
});
