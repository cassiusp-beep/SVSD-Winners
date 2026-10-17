/**
 * PersonHubNode — Studio Identity Operator Card (TouchDesigner Inspired)
 * Replaces tacky circular glowing rings with a solid, structured operator card.
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

interface PersonHubNodeProps {
  id: string;
  data: {
    userId: string;
    isGuest?: boolean;
    isDocked?: boolean;
  };
  selected?: boolean;
}

const MAKER_1 = 'var(--maker-1, #0D8F5B)';
const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const NODE_RAISED = 'var(--node-raised, #F4F3EE)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';
const GAP_COLOR = 'var(--gap-dark, #D97706)';

export const PersonHubNode = memo(({ data, selected }: PersonHubNodeProps) => {
  const state = useBranchStore();
  const [activeTab, setActiveTab] = useState<string>('projects');
  const isTargeted = state.hoveredDropTargetId === 'person-hub';

  const handleTabClick = (tabId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setActiveTab(tabId);
    if (tabId === 'projects') {
      branchStore.setActiveProject('haptic-weave');
      branchStore.setViewMode('story');
    } else if (tabId === 'gaps') {
      branchStore.setSelectedNodeId('hw-gap1');
    }
  };

  return (
    <div
      className="nodrag"
      style={{
        position: 'relative',
        width: 240,
        backgroundColor: NODE_BG,
        borderRadius: 8,
        border: `1px solid ${isTargeted ? MAKER_1 : selected ? MAKER_1 : BORDER}`,
        boxShadow: isTargeted
          ? '0 6px 20px rgba(13, 143, 91, 0.18)'
          : selected
          ? '0 4px 16px rgba(0, 0, 0, 0.08)'
          : '0 2px 8px rgba(0, 0, 0, 0.04)',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        pointerEvents: 'auto',
        cursor: 'grab',
        transition: 'all 200ms ease',
      }}
    >
      {/* React Flow Handles */}
      <Handle
        type="target"
        position={Position.Left}
        id="left-target"
        style={{ left: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Left}
        id="left-source"
        style={{ left: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Right}
        id="right-source"
        style={{ right: -4, top: '50%' }}
      />
      <Handle
        type="target"
        position={Position.Right}
        id="right-target"
        style={{ right: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="bottom-source"
        style={{ bottom: -4, left: '50%' }}
      />

      {/* Operator Header Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '8px 12px',
          backgroundColor: NODE_RAISED,
          borderBottom: `1px solid ${BORDER}`,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div
            style={{
              width: 8,
              height: 8,
              borderRadius: 2,
              backgroundColor: MAKER_1,
            }}
          />
          <span
            style={{
              fontSize: '10px',
              fontWeight: 700,
              letterSpacing: '0.06em',
              textTransform: 'uppercase',
              color: TEXT_2,
              fontFamily: "'Space Grotesk', sans-serif",
            }}
          >
            MAKER HUB
          </span>
        </div>
        <span
          style={{
            fontSize: '9px',
            color: MAKER_1,
            fontWeight: 600,
            padding: '2px 6px',
            borderRadius: 4,
            backgroundColor: 'rgba(13, 143, 91, 0.1)',
          }}
        >
          LIVE STUDIO
        </span>
      </div>

      {/* Main Profile Info */}
      <div style={{ padding: '12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <img
          src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80"
          alt="Elena Rostova"
          style={{
            width: 44,
            height: 44,
            borderRadius: 6,
            objectFit: 'cover',
            border: `1px solid ${BORDER}`,
          }}
        />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              fontSize: '13px',
              fontWeight: 700,
              color: TEXT,
              fontFamily: "'Space Grotesk', sans-serif",
              lineHeight: 1.2,
            }}
          >
            Elena Rostova
          </div>
          <div
            style={{
              fontSize: '10px',
              color: TEXT_2,
              marginTop: 2,
              display: 'flex',
              alignItems: 'center',
              gap: 6,
            }}
          >
            <span>UC Berkeley MDes</span>
            <span style={{ color: BORDER }}>·</span>
            <span>Spatial & Textiles</span>
          </div>
        </div>
      </div>

      {/* Modular Operator Parameters (Replaces Round Lobes) */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(4, 1fr)',
          borderTop: `1px solid ${BORDER}`,
          backgroundColor: '#FCFCF9',
        }}
      >
        {[
          { id: 'projects', label: 'Projects', val: '3' },
          { id: 'network', label: 'Network', val: '12' },
          { id: 'gaps', label: 'Needs', val: '1', alert: true },
          { id: 'skills', label: 'Skills', val: '6' },
        ].map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={(e) => handleTabClick(item.id, e)}
              style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '8px 4px',
                border: 'none',
                borderRight: `1px solid ${BORDER}`,
                backgroundColor: isActive ? NODE_RAISED : 'transparent',
                cursor: 'pointer',
                transition: 'background-color 150ms ease',
              }}
            >
              <span
                style={{
                  fontSize: '8.5px',
                  color: TEXT_2,
                  fontWeight: 500,
                  textTransform: 'uppercase',
                }}
              >
                {item.label}
              </span>
              <span
                style={{
                  fontSize: '11px',
                  fontWeight: 700,
                  color: item.alert ? GAP_COLOR : isActive ? MAKER_1 : TEXT,
                  marginTop: 2,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                {item.val}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
});
