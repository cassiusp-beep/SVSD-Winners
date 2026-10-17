import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { GitBranch, Terminal } from 'lucide-react';
import { useBranchStore } from '../../../store/branchStore';

interface BranchNodeProps {
  id: string;
  data: {
    branch: {
      id: string;
      title: string;
      creatorName: string;
      intent: string;
      date: string;
      accentColor?: string;
      imageUrl?: string;
    };
  };
  selected?: boolean;
}

export const BranchNode = memo(({ data, selected }: BranchNodeProps) => {
  const state = useBranchStore();
  const { branch } = data;
  const isSelected = selected || state.selectedNodeId === branch.id;
  const accentColor = branch.accentColor || '#2563EB';

  const image =
    branch.imageUrl ||
    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=600&q=80';

  return (
    <div
      className="nodrag"
      style={{
        width: 270,
        backgroundColor: '#FFFFFF',
        border: `1.5px solid ${accentColor}`,
        borderRadius: 14,
        overflow: 'hidden',
        color: '#191C24',
        boxShadow: '0 6px 24px rgba(24, 28, 38, 0.08), 0 1px 3px rgba(24, 28, 38, 0.04)',
        transition: 'all 0.25s ease',
      }}
    >
      <Handle type="target" position={Position.Left} id="branch-target" style={{ background: accentColor, width: 8, height: 8 }} />
      <Handle type="source" position={Position.Right} id="branch-source" style={{ background: accentColor, width: 8, height: 8 }} />

      {/* DSP Hardware Image */}
      <div style={{ position: 'relative', width: '100%', height: 110, backgroundColor: '#F0EFEA' }}>
        <img src={image} alt={branch.title} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        <div
          style={{
            position: 'absolute',
            top: 6,
            left: 6,
            display: 'inline-flex',
            alignItems: 'center',
            gap: 4,
            padding: '2px 7px',
            borderRadius: 4,
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
            fontSize: '9px',
            fontWeight: 700,
            color: accentColor,
            letterSpacing: '0.04em',
          }}
        >
          <GitBranch size={10} color={accentColor} />
          <span>BRANCHED CHAPTER</span>
        </div>
        <div
          style={{
            position: 'absolute',
            bottom: 6,
            right: 6,
            padding: '2px 6px',
            borderRadius: 4,
            backgroundColor: 'rgba(25, 28, 36, 0.8)',
            color: '#FFFFFF',
            fontSize: '9px',
            fontWeight: 600,
          }}
        >
          {branch.date}
        </div>
      </div>

      <div style={{ padding: '12px 14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <img
            src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=64&q=80"
            alt={branch.creatorName}
            style={{ width: 18, height: 18, borderRadius: '50%' }}
          />
          <span style={{ fontSize: '11px', fontWeight: 600, color: '#191C24' }}>
            {branch.creatorName}
          </span>
          <span style={{ fontSize: '10px', color: '#8E95A6' }}>• EECS</span>
        </div>

        <h4 style={{ fontSize: '14px', fontWeight: 700, color: '#191C24', margin: '0 0 4px 0', lineHeight: 1.25 }}>
          {branch.title}
        </h4>

        <p style={{ fontSize: '11px', color: '#5F667A', margin: '0 0 8px 0', lineHeight: 1.4 }}>
          {branch.intent}
        </p>

        {/* Code / Technical Pill */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 5,
            padding: '4px 8px',
            borderRadius: 6,
            backgroundColor: '#F3F4F6',
            fontSize: '9.5px',
            fontFamily: 'monospace',
            color: '#374151',
          }}
        >
          <Terminal size={10} color="#6B7280" />
          <span>AudioWorkletProcessor: formant 175/235Hz</span>
        </div>
      </div>
    </div>
  );
});
