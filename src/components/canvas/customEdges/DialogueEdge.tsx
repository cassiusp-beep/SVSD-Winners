import React, { useState } from 'react';
import { BaseEdge, EdgeLabelRenderer, EdgeProps, getBezierPath } from '@xyflow/react';
import { MessageSquare, Sparkles } from 'lucide-react';
import { useBranchStore } from '../../../store/branchStore';

export interface DialogueEdgeData {
  label?: string;
  type?: 'led_to' | 'informed' | 'branched_from' | 'revived_from';
  dialogueSnippet?: string;
  speakerName?: string;
  speakerAvatar?: string;
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
  data,
}) => {
  const [edgePath, labelX, labelY] = getBezierPath({
    sourceX,
    sourceY,
    sourcePosition,
    targetX,
    targetY,
    targetPosition,
  });

  const state = useBranchStore();
  const [isHovered, setIsHovered] = useState(false);
  const edgeData = data as DialogueEdgeData | undefined;

  const isBranched = edgeData?.type === 'branched_from';
  const makerColor = edgeData?.makerColor || (isBranched ? '#E23D28' : '#0D8F5B');

  return (
    <>
      <style>{`
        @keyframes markerPulse {
          from {
            stroke-dashoffset: 24;
          }
          to {
            stroke-dashoffset: 0;
          }
        }
      `}</style>

      {/* Saturated Whiteboard Marker Conduit Line */}
      <BaseEdge
        path={edgePath}
        markerEnd={markerEnd}
        style={{
          ...style,
          stroke: makerColor,
          strokeWidth: isHovered ? 3.5 : 2.5,
          strokeOpacity: isHovered ? 1 : 0.85,
          transition: 'all 0.2s ease',
        }}
      />

      {/* Animated Traveling Pulse Path */}
      <path
        d={edgePath}
        fill="none"
        stroke="#FFFFFF"
        strokeWidth={1.5}
        strokeDasharray="4, 14"
        style={{
          animation: 'markerPulse 1.4s linear infinite',
          opacity: 0.9,
        }}
      />

      {/* Living Dialogue Speech Bubble / Margin Note */}
      {edgeData?.dialogueSnippet && (
        <EdgeLabelRenderer>
          <div
            style={{
              position: 'absolute',
              transform: `translate(-50%, -130%) translate(${labelX}px,${labelY}px)`,
              pointerEvents: 'all',
              zIndex: 15,
            }}
            className="nodrag nopan"
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
          >
            <div
              style={{
                position: 'relative',
                backgroundColor: '#FFFFFF',
                border: `1.75px solid ${makerColor}`,
                borderRadius: 10,
                padding: '6px 10px',
                fontSize: '11px',
                color: '#191C24',
                boxShadow: isHovered
                  ? `0 6px 20px ${makerColor}30, 0 2px 6px rgba(0,0,0,0.06)`
                  : '0 4px 16px rgba(24, 28, 38, 0.1)',
                maxWidth: 200,
                lineHeight: 1.35,
                transition: 'all 0.2s ease',
              }}
            >
              {/* Dialogue Header */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginBottom: 3 }}>
                <span
                  style={{
                    fontSize: '9px',
                    fontWeight: 700,
                    color: makerColor,
                    textTransform: 'uppercase',
                    letterSpacing: '0.04em',
                  }}
                >
                  {edgeData.label || 'DIALOGUE'}
                </span>
              </div>

              {/* Quote Snippet */}
              <div style={{ fontSize: '11px', color: '#191C24', fontWeight: 500 }}>
                {edgeData.dialogueSnippet}
              </div>

              {/* Optional AI Layer */}
              {state.aiEnabled && edgeData.aiRelevance && (
                <div
                  style={{
                    fontSize: '9px',
                    color: '#6B7280',
                    marginTop: 4,
                    borderTop: '1px solid #E5E7EB',
                    paddingTop: 3,
                  }}
                >
                  <Sparkles size={8} style={{ display: 'inline', marginRight: 3, color: '#9CA3AF' }} />
                  {edgeData.aiRelevance}
                </div>
              )}

              {/* Pointer Arrow Tail */}
              <div
                style={{
                  position: 'absolute',
                  bottom: -6,
                  left: '50%',
                  transform: 'translateX(-50%) rotate(45deg)',
                  width: 10,
                  height: 10,
                  backgroundColor: '#FFFFFF',
                  borderRight: `1.75px solid ${makerColor}`,
                  borderBottom: `1.75px solid ${makerColor}`,
                }}
              />
            </div>
          </div>
        </EdgeLabelRenderer>
      )}
    </>
  );
};
