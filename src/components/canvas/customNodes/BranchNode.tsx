import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { GitFork } from 'lucide-react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

interface BranchNodeProps {
  id: string;
  data: {
    branch: {
      id: string;
      title: string;
      creatorName: string;
      creatorDiscipline?: string;
      intent: string;
      date?: string;
      accentColor?: string;
    };
  };
  selected?: boolean;
}

export const BranchNode = memo(({ data, selected }: BranchNodeProps) => {
  const state = useBranchStore();
  const { branch } = data;
  const isSelected = selected || state.selectedNodeId === branch.id;
  const accentColor = branch.accentColor || '#B8F35A'; // acid lime default for maker 3

  return (
    <div
      onClick={() => branchStore.setSelectedNodeId(branch.id)}
      style={{
        width: 250,
        backgroundColor: '#151B30',
        border: `1.5px solid ${accentColor}`,
        borderRadius: 14,
        padding: '14px 16px',
        color: '#EEF1FA',
        cursor: 'pointer',
        boxShadow: isSelected
          ? `0 0 20px ${accentColor}40`
          : '0 8px 24px rgba(0,0,0,0.4)',
        transition: 'all 0.25s ease'
      }}
    >
      <Handle type="target" position={Position.Left} id="branch-target" style={{ background: accentColor, opacity: 0.8 }} />
      <Handle type="source" position={Position.Right} id="branch-source" style={{ background: accentColor, opacity: 0.8 }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: accentColor }} />
          <span style={{ fontSize: '10px', fontWeight: 700, letterSpacing: '0.04em', color: accentColor, textTransform: 'uppercase' }}>
            BRANCH • {branch.creatorName.toUpperCase()}
          </span>
        </div>
        <span style={{ fontSize: '10px', color: '#7A84A8' }}>{branch.date || 'Oct 16'}</span>
      </div>

      <h4 style={{ fontSize: '14px', fontWeight: 600, color: '#EEF1FA', margin: '0 0 4px 0', lineHeight: 1.25 }}>
        {branch.title}
      </h4>

      <p style={{ fontSize: '11px', color: '#A3ACC7', margin: 0, lineHeight: 1.4 }}>
        {branch.intent}
      </p>
    </div>
  );
});
