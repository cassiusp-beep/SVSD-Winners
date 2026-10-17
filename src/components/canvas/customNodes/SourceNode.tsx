import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { BookOpen } from 'lucide-react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

interface SourceNodeProps {
  id: string;
  data: {
    source: {
      id: string;
      title: string;
      author: string;
      stepLabel?: string;
    };
  };
  selected?: boolean;
}

export const SourceNode = memo(({ data, selected }: SourceNodeProps) => {
  const state = useBranchStore();
  const { source } = data;
  const isSelected = selected || state.selectedNodeId === source.id;

  return (
    <div
      onClick={() => branchStore.setSelectedNodeId(source.id)}
      style={{
        width: 190,
        backgroundColor: '#151B30',
        border: '1px solid #232B47',
        borderRadius: 10,
        padding: '10px 12px',
        color: '#EEF1FA',
        cursor: 'pointer',
        boxShadow: isSelected ? '0 0 16px rgba(79, 216, 240, 0.25)' : '0 4px 16px rgba(0,0,0,0.4)',
        transition: 'all 0.2s ease'
      }}
    >
      <Handle type="target" position={Position.Left} id="source-target" style={{ background: '#7A84A8', opacity: 0.6 }} />
      <Handle type="source" position={Position.Right} id="source-source" style={{ background: '#7A84A8', opacity: 0.6 }} />

      <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginBottom: 4 }}>
        <BookOpen size={10} color="#7A84A8" />
        <span style={{ fontSize: '9px', fontWeight: 700, letterSpacing: '0.06em', color: '#7A84A8', textTransform: 'uppercase' }}>
          {source.stepLabel || 'SOURCE • STEP 2'}
        </span>
      </div>

      <div style={{ fontSize: '12px', fontWeight: 600, color: '#EEF1FA', marginBottom: 2 }}>
        {source.title}
      </div>

      <div style={{ fontSize: '10px', color: '#7A84A8' }}>
        {source.author}
      </div>
    </div>
  );
});
