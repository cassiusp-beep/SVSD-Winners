import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { Sparkles, GitBranch } from 'lucide-react';
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

export const GapNode = memo(({ data, selected }: GapNodeProps) => {
  const state = useBranchStore();
  const { gap } = data;
  const isSelected = selected || state.selectedNodeId === gap.id;

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
      style={{
        width: 260,
        backgroundColor: '#151B30',
        border: '1.5px solid #FFB547',
        borderRadius: 14,
        padding: '14px 16px',
        color: '#EEF1FA',
        cursor: 'pointer',
        boxShadow: '0 0 20px rgba(255, 181, 71, 0.4)',
        animation: 'gapBreathe 3s ease-in-out infinite',
        transition: 'all 0.25s ease'
      }}
    >
      <style>{`
        @keyframes gapBreathe {
          0%, 100% {
            box-shadow: 0 0 14px rgba(255, 181, 71, 0.35);
            border-color: rgba(255, 181, 71, 0.8);
          }
          50% {
            box-shadow: 0 0 28px rgba(255, 181, 71, 0.65);
            border-color: #FFB547;
          }
        }
      `}</style>

      <Handle type="target" position={Position.Left} id="gap-target" style={{ background: '#FFB547', opacity: 0.9 }} />
      <Handle type="source" position={Position.Right} id="gap-source" style={{ background: '#FFB547', opacity: 0.9 }} />
      <Handle type="source" position={Position.Bottom} id="gap-bottom" style={{ background: '#FFB547', opacity: 0.9 }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span
            style={{
              padding: '2px 6px',
              borderRadius: 4,
              backgroundColor: 'rgba(255, 181, 71, 0.15)',
              color: '#FFB547',
              fontSize: '10px',
              fontWeight: 700,
              letterSpacing: '0.04em',
              textTransform: 'uppercase'
            }}
          >
            OPEN GAP
          </span>
          <span style={{ fontSize: '10px', color: '#7A84A8' }}>
            {gap.disciplineTarget || 'Mechatronics / Audio'}
          </span>
        </div>
        <Sparkles size={12} color="#FFB547" />
      </div>

      <h4 style={{ fontSize: '14px', fontWeight: 600, color: '#EEF1FA', margin: '0 0 6px 0', lineHeight: 1.25 }}>
        {gap.title}
      </h4>

      <p style={{ fontSize: '11px', color: '#A3ACC7', margin: '0 0 10px 0', lineHeight: 1.4 }}>
        {gap.need}
      </p>

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: 8, borderTop: '1px solid #1E2640' }}>
        <span style={{ fontSize: '10px', color: '#7A84A8' }}>Unfilled need</span>
        <button
          onClick={handleBranchGap}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 4,
            padding: '3px 8px',
            borderRadius: 6,
            backgroundColor: 'rgba(255, 181, 71, 0.15)',
            border: '1px solid rgba(255, 181, 71, 0.4)',
            color: '#FFB547',
            fontSize: '10px',
            fontWeight: 600,
            cursor: 'pointer'
          }}
        >
          <GitBranch size={10} />
          <span>Branch This</span>
        </button>
      </div>
    </div>
  );
});
