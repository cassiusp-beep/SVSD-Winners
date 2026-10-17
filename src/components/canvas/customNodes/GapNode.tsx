/**
 * GapNode — Small Dot Pin that Enlarges on Hover (Per User Specification)
 * Sits unobtrusively on the conduit, expanding into an actionable parameter card when hovered or clicked.
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

interface GapNodeProps {
  id: string;
  data: {
    gap: {
      id: string;
      title: string;
      need: string;
      disciplineTarget?: string;
      projectId?: string;
    };
  };
  selected?: boolean;
}

const GAP = 'var(--gap, #FF9F0A)';
const GAP_DARK = 'var(--gap-dark, #D97706)';
const GAP_BG = 'var(--gap-bg, #FFF9ED)';
const BORDER = 'var(--border, #E2E0D8)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';

export const GapNode = memo(({ data, selected }: GapNodeProps) => {
  const state = useBranchStore();
  const { gap } = data;
  const isSelected = selected || state.selectedNodeId === gap.id;
  const [isHovered, setIsHovered] = useState(false);

  const isOpen = isHovered || isSelected;

  const handleBranchGap = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.createPrivateBranch(
      gap.projectId || 'haptic-weave',
      gap.id,
      'DSP Actuator Resonance',
      'Mechatronics / Audio DSP',
      'Tune resonant frequency for haptic actuators.'
    );
  };

  return (
    <div
      onClick={() => branchStore.setSelectedNodeId(gap.id)}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      className="nodrag"
      style={{
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        pointerEvents: 'auto',
        cursor: 'pointer',
      }}
    >
      <Handle
        type="target"
        position={Position.Left}
        id="gap-target"
        style={{ left: isOpen ? -4 : 4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Right}
        id="gap-source"
        style={{ right: isOpen ? -4 : 4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="gap-bottom"
        style={{ bottom: isOpen ? -4 : 4, left: '50%' }}
      />

      {!isOpen ? (
        /* Small Dot State (Default) — cleanly enlarged slightly on focus */
        <div
          style={{
            width: 20,
            height: 20,
            borderRadius: '50%',
            backgroundColor: GAP,
            border: '2px solid #FFFFFF',
            boxShadow: '0 2px 6px rgba(217, 119, 6, 0.3)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#FFFFFF',
            fontSize: '11px',
            fontWeight: 800,
            fontFamily: "'Space Grotesk', sans-serif",
            transition: 'all 200ms cubic-bezier(0.16, 1, 0.3, 1)',
            transform: 'scale(1)',
          }}
          title={gap.title}
        >
          ?
        </div>
      ) : (
        /* Expanded Parameter Card State (Enlarges on Hover) */
        <div
          style={{
            width: 240,
            backgroundColor: GAP_BG,
            borderRadius: 8,
            border: `1.5px solid ${GAP_DARK}`,
            boxShadow: '0 8px 24px rgba(217, 119, 6, 0.16)',
            display: 'flex',
            flexDirection: 'column',
            overflow: 'hidden',
            animation: 'fadeIn 180ms cubic-bezier(0.16, 1, 0.3, 1)',
            zIndex: 10,
          }}
        >
          {/* Header */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '6px 10px',
              backgroundColor: GAP,
              color: '#FFFFFF',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <span
                style={{
                  fontSize: '9px',
                  fontWeight: 800,
                  letterSpacing: '0.06em',
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                UNFILLED NEED
              </span>
            </div>
            <span
              style={{
                fontSize: '8px',
                backgroundColor: 'rgba(255, 255, 255, 0.3)',
                padding: '1px 5px',
                borderRadius: 3,
                fontWeight: 700,
              }}
            >
              OPEN GAP
            </span>
          </div>

          {/* Content */}
          <div style={{ padding: '10px 12px' }}>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                color: GAP_DARK,
                fontFamily: "'Space Grotesk', sans-serif",
              }}
            >
              {gap.title}
            </div>
            <div
              style={{
                fontSize: '10px',
                color: TEXT,
                marginTop: 4,
                lineHeight: 1.35,
              }}
            >
              Elena: &ldquo;{gap.need}&rdquo;
            </div>
            {gap.disciplineTarget && (
              <div
                style={{
                  fontSize: '8.5px',
                  color: TEXT_2,
                  marginTop: 6,
                  fontWeight: 600,
                }}
              >
                Discipline: {gap.disciplineTarget}
              </div>
            )}
          </div>

          {/* Action Footer */}
          <div
            style={{
              padding: '6px 10px',
              backgroundColor: '#FFF4E0',
              borderTop: `1px solid rgba(217, 119, 6, 0.2)`,
              display: 'flex',
              justifyContent: 'flex-end',
            }}
          >
            <button
              onClick={handleBranchGap}
              style={{
                padding: '4px 10px',
                borderRadius: 4,
                backgroundColor: GAP_DARK,
                border: 'none',
                color: '#FFFFFF',
                fontSize: '9px',
                fontWeight: 700,
                cursor: 'pointer',
                fontFamily: "'Space Grotesk', sans-serif",
                transition: 'opacity 150ms ease',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.opacity = '0.9')}
              onMouseLeave={(e) => (e.currentTarget.style.opacity = '1')}
            >
              Branch to Help →
            </button>
          </div>
        </div>
      )}
    </div>
  );
});
