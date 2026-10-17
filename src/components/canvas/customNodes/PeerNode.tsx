import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

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
    };
  };
  selected?: boolean;
}

export const PeerNode = memo(({ data, selected }: PeerNodeProps) => {
  const state = useBranchStore();
  const { peer } = data;
  const isSelected = selected || state.selectedNodeId === peer.id;
  const isTargeted = state.hoveredDropTargetId === peer.id;

  return (
    <div
      onClick={() => branchStore.setSelectedNodeId(peer.id)}
      style={{
        width: 220,
        backgroundColor: '#151B30',
        border: `1.5px solid ${isTargeted ? peer.accentColor : '#232B47'}`,
        borderRadius: 14,
        padding: '12px 14px',
        color: '#EEF1FA',
        cursor: 'pointer',
        boxShadow: isTargeted
          ? `0 0 24px ${peer.accentColor}50`
          : isSelected
          ? `0 0 16px ${peer.accentColor}30`
          : '0 6px 20px rgba(0,0,0,0.4)',
        transform: isTargeted ? 'scale(1.05)' : 'scale(1)',
        transition: 'all 0.25s ease'
      }}
    >
      <Handle type="target" position={Position.Right} id="peer-target" style={{ background: peer.accentColor, opacity: 0.7 }} />
      <Handle type="source" position={Position.Right} id="peer-source" style={{ background: peer.accentColor, opacity: 0.7 }} />

      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 5 }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: peer.accentColor }} />
        <span style={{ fontSize: '10px', fontWeight: 700, letterSpacing: '0.04em', color: peer.accentColor, textTransform: 'uppercase' }}>
          {peer.name.toUpperCase()} • {peer.institution}
        </span>
      </div>

      <div style={{ fontSize: '13px', fontWeight: 600, color: '#EEF1FA', marginBottom: 3 }}>
        {peer.title}
      </div>

      <div style={{ fontSize: '11px', color: '#A3ACC7', lineHeight: 1.35 }}>
        {peer.description}
      </div>
    </div>
  );
});
