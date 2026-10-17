import React, { memo } from 'react';
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
      imageUrl?: string;
    };
  };
}

export const PeerNode = memo(({ data }: PeerNodeProps) => {
  const { peer } = data;

  const defaultAvatar =
    peer.id === 'amina-diallo'
      ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=128&q=80'
      : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=128&q=80';

  const defaultImage =
    peer.id === 'amina-diallo'
      ? 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80' // Bioluminescent Algae
      : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80'; // Origami Acoustic Fold

  return (
    <div
      className="nodrag"
      style={{
        width: 240,
        backgroundColor: '#FFFFFF',
        border: '1px solid #E5E0D5',
        borderRadius: 14,
        overflow: 'hidden',
        color: '#191C24',
        boxShadow: '0 6px 20px rgba(24, 28, 38, 0.06), 0 1px 3px rgba(24, 28, 38, 0.04)',
        transition: 'all 0.25s ease',
      }}
    >
      <Handle type="source" position={Position.Right} id="peer-source" style={{ background: peer.accentColor, width: 8, height: 8 }} />
      <Handle type="target" position={Position.Left} id="peer-target" style={{ background: peer.accentColor, width: 8, height: 8 }} />

      {/* Thumbnail */}
      <div style={{ position: 'relative', width: '100%', height: 95, backgroundColor: '#F0EFEA' }}>
        <img
          src={peer.imageUrl || defaultImage}
          alt={peer.title}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
        <div
          style={{
            position: 'absolute',
            bottom: 6,
            left: 8,
            display: 'flex',
            alignItems: 'center',
            gap: 5,
            padding: '2px 6px',
            borderRadius: 4,
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
          }}
        >
          <img
            src={peer.avatarUrl || defaultAvatar}
            alt={peer.name}
            style={{ width: 14, height: 14, borderRadius: '50%' }}
          />
          <span style={{ fontSize: '9px', fontWeight: 600, color: '#191C24' }}>
            {peer.name} • {peer.institution}
          </span>
        </div>
      </div>

      <div style={{ padding: '10px 12px' }}>
        <h4 style={{ fontSize: '13px', fontWeight: 700, color: '#191C24', margin: '0 0 3px 0' }}>
          {peer.title}
        </h4>
        <p style={{ fontSize: '10.5px', color: '#5F667A', margin: 0, lineHeight: 1.4 }}>
          {peer.description}
        </p>
      </div>
    </div>
  );
});
