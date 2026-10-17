import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { Sparkles, GitBranch, AlertCircle } from 'lucide-react';
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
      className="nodrag"
      style={{
        position: 'relative',
        width: 270,
        backgroundColor: '#FFFDF9',
        border: '2px solid #FF9F0A',
        borderRadius: 16,
        padding: '14px 16px',
        color: '#191C24',
        cursor: 'pointer',
        boxShadow: '0 0 32px rgba(255, 159, 10, 0.35), 0 8px 24px rgba(24, 28, 38, 0.08)',
        animation: 'amberPortalBreathe 3s ease-in-out infinite',
        transition: 'all 0.25s ease',
      }}
    >
      <style>{`
        @keyframes amberPortalBreathe {
          0%, 100% {
            box-shadow: 0 0 20px rgba(255, 159, 10, 0.3), 0 6px 20px rgba(0,0,0,0.06);
            border-color: #FF9F0A;
          }
          50% {
            box-shadow: 0 0 36px rgba(255, 159, 10, 0.55), 0 8px 26px rgba(0,0,0,0.09);
            border-color: #F59E0B;
          }
        }
      `}</style>

      <Handle type="target" position={Position.Left} id="gap-target" style={{ background: '#FF9F0A', width: 8, height: 8 }} />
      <Handle type="source" position={Position.Right} id="gap-source" style={{ background: '#FF9F0A', width: 8, height: 8 }} />
      <Handle type="source" position={Position.Bottom} id="gap-bottom" style={{ background: '#FF9F0A', width: 8, height: 8 }} />

      {/* Header Badge */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 4,
            padding: '3px 8px',
            borderRadius: 6,
            backgroundColor: '#FEF3C7',
            color: '#B45309',
            fontSize: '9.5px',
            fontWeight: 700,
            letterSpacing: '0.04em',
            textTransform: 'uppercase',
          }}
        >
          <AlertCircle size={11} color="#B45309" />
          <span>OPEN GAP</span>
        </div>
        <span style={{ fontSize: '10px', color: '#B45309', fontWeight: 600 }}>
          {gap.disciplineTarget || 'Mechatronics'}
        </span>
      </div>

      {/* Title */}
      <h3
        style={{
          fontSize: '15px',
          fontWeight: 700,
          color: '#191C24',
          margin: '0 0 6px 0',
          lineHeight: 1.25,
        }}
      >
        {gap.title}
      </h3>

      {/* Need Description */}
      <p
        style={{
          fontSize: '11.5px',
          color: '#5F667A',
          margin: '0 0 12px 0',
          lineHeight: 1.45,
          fontStyle: 'italic',
        }}
      >
        "{gap.need}"
      </p>

      {/* Action to Branch */}
      <button
        onClick={handleBranchGap}
        style={{
          width: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 6,
          padding: '7px 12px',
          borderRadius: 8,
          backgroundColor: '#FF9F0A',
          border: 'none',
          color: '#FFFFFF',
          fontSize: '11px',
          fontWeight: 700,
          cursor: 'pointer',
          boxShadow: '0 2px 8px rgba(255, 159, 10, 0.4)',
          transition: 'all 0.2s ease',
        }}
        onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#F59E0B')}
        onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#FF9F0A')}
      >
        <GitBranch size={12} color="#FFFFFF" />
        <span>Branch to Help</span>
      </button>
    </div>
  );
});
