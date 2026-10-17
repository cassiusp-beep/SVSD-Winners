import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { BookOpen, ExternalLink } from 'lucide-react';
import { useBranchStore } from '../../../store/branchStore';

interface SourceNodeProps {
  id: string;
  data: {
    source: {
      id: string;
      title: string;
      author: string;
      stepLabel?: string;
      imageUrl?: string;
    };
  };
  selected?: boolean;
}

export const SourceNode = memo(({ data, selected }: SourceNodeProps) => {
  const state = useBranchStore();
  const { source } = data;
  const isSelected = selected || state.selectedNodeId === source.id;

  const image =
    source.imageUrl ||
    'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=600&q=80';

  return (
    <div
      className="nodrag"
      style={{
        width: 250,
        backgroundColor: '#FFFFFF',
        border: isSelected ? '2px solid #0D8F5B' : '1px solid #E5E0D5',
        borderRadius: 14,
        overflow: 'hidden',
        color: '#191C24',
        boxShadow: '0 6px 20px rgba(24, 28, 38, 0.06), 0 1px 3px rgba(24, 28, 38, 0.04)',
        transition: 'all 0.25s ease',
      }}
    >
      <Handle type="target" position={Position.Left} id="source-target" style={{ background: '#0D8F5B', width: 8, height: 8 }} />
      <Handle type="source" position={Position.Right} id="source-source" style={{ background: '#0D8F5B', width: 8, height: 8 }} />

      {/* Loom Pitch Image */}
      <div style={{ position: 'relative', width: '100%', height: 100, backgroundColor: '#F0EFEA' }}>
        <img src={image} alt={source.title} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        <div
          style={{
            position: 'absolute',
            top: 6,
            left: 6,
            display: 'inline-flex',
            alignItems: 'center',
            gap: 4,
            padding: '2px 6px',
            borderRadius: 4,
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
            fontSize: '9px',
            fontWeight: 700,
            color: '#191C24',
            letterSpacing: '0.04em',
          }}
        >
          <BookOpen size={10} color="#0D8F5B" />
          <span>{source.stepLabel || 'SOURCE • STEP 2'}</span>
        </div>
      </div>

      <div style={{ padding: '10px 12px' }}>
        <h4 style={{ fontSize: '13px', fontWeight: 700, color: '#191C24', margin: '0 0 3px 0' }}>
          {source.title}
        </h4>
        <p style={{ fontSize: '10.5px', color: '#5F667A', margin: 0 }}>
          {source.author}
        </p>
      </div>
    </div>
  );
});
