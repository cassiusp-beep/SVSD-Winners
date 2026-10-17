import React, { useState } from 'react';
import { BaseEdge, EdgeLabelRenderer, EdgeProps, getBezierPath } from '@xyflow/react';
import { MessageSquare, Sparkles } from 'lucide-react';
import { useBranchStore } from '../../../store/branchStore';

export interface DialogueEdgeData {
  label?: string;
  type?: 'led_to' | 'informed' | 'branched_from' | 'revived_from';
  dialogueSnippet?: string;
  aiRelevance?: string;
  makerColor?: string;
}

export const DialogueEdge: React.FC<EdgeProps<any>> = ({
  id,
  sourceX,
  sourceY,
  targetX,
  targetY,
  sourcePosition,
  targetPosition,
  style = {},
  markerEnd,
  data
}) => {
  const [edgePath, labelX, labelY] = getBezierPath({
    sourceX,
    sourceY,
    sourcePosition,
    targetX,
    targetY,
    targetPosition
  });

  const state = useBranchStore();
  const [isHovered, setIsHovered] = useState(false);
  const edgeData = data as DialogueEdgeData | undefined;

  const isBranched = edgeData?.type === 'branched_from';
  const makerColor = edgeData?.makerColor || (isBranched ? '#B8F35A' : '#4FD8F0');

  return (
    <>
      <style>{`
        @keyframes dashTravel {
          from {
            stroke-dashoffset: 24;
          }
          to {
            stroke-dashoffset: 0;
          }
        }
      `}</style>

      {/* Base Path */}
      <BaseEdge
        path={edgePath}
        markerEnd={markerEnd}
        style={{
          ...style,
          stroke: isHovered ? makerColor : '#232B47',
          strokeWidth: isHovered ? 2.5 : 1.75,
          transition: 'stroke 0.2s ease, stroke-width 0.2s ease'
        }}
      />

      {/* Animated Traveling Pulse Path */}
      <path
        d={edgePath}
        fill="none"
        stroke={makerColor}
        strokeWidth={1.5}
        strokeDasharray="4, 16"
        style={{
          animation: 'dashTravel 1.6s linear infinite',
          opacity: isHovered ? 1 : 0.65
        }}
      />

      {/* Mounted Dialogue Label / Snippet */}
      {edgeData?.dialogueSnippet && (
        <EdgeLabelRenderer>
          <div
            style={{
              position: 'absolute',
              transform: `translate(-50%, -120%) translate(${labelX}px,${labelY}px)`,
              pointerEvents: 'all',
              zIndex: 10
            }}
            className="nodrag nopan"
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
          >
            <div
              style={{
                backgroundColor: '#151B30',
                border: isHovered ? `1px solid ${makerColor}` : '1px solid #232B47',
                borderRadius: 8,
                padding: '6px 10px',
                fontSize: '11px',
                color: '#EEF1FA',
                boxShadow: isHovered
                  ? `0 0 16px ${makerColor}40`
                  : '0 4px 16px rgba(0,0,0,0.5)',
                maxWidth: 210,
                lineHeight: 1.35,
                transition: 'all 0.2s ease'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginBottom: 2 }}>
                <MessageSquare size={10} color={makerColor} />
                <span style={{ fontSize: '9px', fontWeight: 700, color: makerColor, textTransform: 'uppercase' }}>
                  {edgeData.label || 'DIALOGUE'}
                </span>
              </div>
              <div style={{ fontSize: '11px', color: '#EEF1FA' }}>
                {edgeData.dialogueSnippet}
              </div>
              {state.aiEnabled && edgeData.aiRelevance && (
                <div style={{ fontSize: '9px', color: '#C3C7DD', marginTop: 4, borderTop: '1px solid #1E2640', paddingTop: 3 }}>
                  <Sparkles size={8} style={{ display: 'inline', marginRight: 3 }} />
                  {edgeData.aiRelevance}
                </div>
              )}
            </div>
          </div>
        </EdgeLabelRenderer>
      )}
    </>
  );
};
