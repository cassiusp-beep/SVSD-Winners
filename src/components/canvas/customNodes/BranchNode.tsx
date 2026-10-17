/**
 * BranchNode — Contributor Lineage Operator Block (TouchDesigner Inspired)
 * Solid card showing collaborative contributor branch (Marcus Chen).
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
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
      isPrivate?: boolean;
    };
  };
  selected?: boolean;
}

const MAKER_2 = 'var(--maker-2, #E23D28)'; // Vermillion terracotta
const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const NODE_RAISED = 'var(--node-raised, #F4F3EE)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';

export const BranchNode = memo(({ data, selected }: BranchNodeProps) => {
  const state = useBranchStore();
  const { branch } = data;
  const isSelected = selected || state.selectedNodeId === branch.id;
  const [hovered, setHovered] = useState(false);
  const isActive = isSelected || hovered;

  const image =
    branch.imageUrl ||
    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=160&q=80';
  const avatarUrl =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=64&q=80';

  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className="nodrag"
      style={{
        position: 'relative',
        width: 220,
        backgroundColor: NODE_BG,
        borderRadius: 8,
        border: `1px solid ${isActive ? MAKER_2 : BORDER}`,
        boxShadow: isActive
          ? '0 4px 14px rgba(226, 61, 40, 0.12)'
          : '0 2px 6px rgba(0, 0, 0, 0.04)',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        pointerEvents: 'auto',
        transition: 'all 180ms ease',
      }}
    >
      <Handle
        type="target"
        position={Position.Left}
        id="branch-target"
        style={{ left: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Right}
        id="branch-source"
        style={{ right: -4, top: '50%' }}
      />

      {/* Operator Header */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '6px 10px',
          backgroundColor: '#E23D28',
          color: '#FFFFFF',
        }}
      >
        <span
          style={{
            fontSize: '8.5px',
            fontWeight: 800,
            letterSpacing: '0.06em',
            fontFamily: "'Space Grotesk', sans-serif",
          }}
        >
          BRANCHED RESPONSE
        </span>
        <span
          style={{
            fontSize: '8px',
            backgroundColor: 'rgba(255, 255, 255, 0.3)',
            padding: '1px 5px',
            borderRadius: 3,
            fontWeight: 700,
          }}
        >
          CONTRIBUTED
        </span>
      </div>

      {/* Content */}
      <div style={{ padding: '10px 12px', display: 'flex', gap: 10 }}>
        <img
          src={avatarUrl}
          alt={branch.creatorName}
          style={{
            width: 32,
            height: 32,
            borderRadius: 4,
            objectFit: 'cover',
            border: `1px solid ${BORDER}`,
          }}
        />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              fontSize: '11px',
              fontWeight: 700,
              color: TEXT,
              fontFamily: "'Space Grotesk', sans-serif",
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {branch.title}
          </div>
          <div
            style={{
              fontSize: '9px',
              color: TEXT_2,
              marginTop: 2,
            }}
          >
            {branch.creatorName} · {branch.date}
          </div>
          <div
            style={{
              fontSize: '9.5px',
              color: TEXT,
              marginTop: 4,
              lineHeight: 1.3,
            }}
          >
            &ldquo;{branch.intent}&rdquo;
          </div>
        </div>
      </div>
    </div>
  );
});
