/**
 * SourceNode — Asset SOP Capsule Operator
 * Compact capsule/pill shape for reference and validation assets.
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
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

const MAKER_1 = 'var(--maker-1, #0D8F5B)';
const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const NODE_RAISED = 'var(--node-raised, #F4F3EE)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';

export const SourceNode = memo(({ data, selected }: SourceNodeProps) => {
  const state = useBranchStore();
  const { source } = data;
  const isSelected = selected || state.selectedNodeId === source.id;
  const [hovered, setHovered] = useState(false);
  const isActive = isSelected || hovered;

  const image =
    source.imageUrl ||
    'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=160&q=80';

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
        backgroundColor: isActive ? NODE_RAISED : NODE_BG,
        borderRadius: 20,
        border: `1px solid ${isActive ? MAKER_1 : BORDER}`,
        padding: '4px 10px 4px 4px',
        boxShadow: isActive
          ? '0 4px 12px rgba(13, 143, 91, 0.12)'
          : '0 1px 4px rgba(0, 0, 0, 0.04)',
        cursor: 'pointer',
        pointerEvents: 'auto',
        transition: 'all 180ms ease',
      }}
    >
      <Handle
        type="target"
        position={Position.Left}
        id="source-target"
        style={{ left: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Right}
        id="source-source"
        style={{ right: -4, top: '50%' }}
      />

      {/* Asset Preview Thumbnail */}
      <img
        src={image}
        alt={source.title}
        style={{
          width: 26,
          height: 26,
          borderRadius: 14,
          objectFit: 'cover',
          border: `1px solid ${BORDER}`,
        }}
      />

      {/* Label and Tag */}
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        <span
          style={{
            fontSize: '7.5px',
            fontWeight: 700,
            color: MAKER_1,
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
          }}
        >
          {source.stepLabel || 'SOURCE · VALIDATION'}
        </span>
        <span
          style={{
            fontSize: '10px',
            fontWeight: 600,
            color: TEXT,
            fontFamily: "'Space Grotesk', sans-serif",
            lineHeight: 1.1,
          }}
        >
          {source.title}
        </span>
      </div>
    </div>
  );
});
