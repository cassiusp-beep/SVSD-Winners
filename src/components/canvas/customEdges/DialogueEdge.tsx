/**
 * DialogueEdge — Clean Directional Conduit with Docked Dialogue Chip
 * Solid tactile bus routing inspired by TouchDesigner data wires.
 */
import React, { useState } from 'react';
import { BaseEdge, EdgeLabelRenderer, EdgeProps, getBezierPath } from '@xyflow/react';
import { useBranchStore } from '../../../store/branchStore';

export interface DialogueEdgeData {
  label?: string;
  type?: 'led_to' | 'informed' | 'branched_from' | 'revived_from';
  dialogueSnippet?: string;
  speakerName?: string;
  makerColor?: string;
}

const MUTED = 'var(--muted, #9BA3B5)';
const BORDER = 'var(--border, #E2E0D8)';
const NODE_BG = 'var(--node, #FFFFFF)';
const TEXT = 'var(--text, #14171F)';
const TEXT_2 = 'var(--text-2, #5A6275)';

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

  const [isHovered, setIsHovered] = useState(false);
  const edgeData = data as DialogueEdgeData | undefined;

  const makerColor = edgeData?.makerColor || 'var(--maker-1, #0D8F5B)';
  const hasActivity = !!edgeData?.dialogueSnippet;

  return (
    <>
      {/* Base Line */}
      <BaseEdge
        path={edgePath}
        markerEnd={markerEnd}
        style={{
          ...style,
          stroke: makerColor,
          strokeWidth: isHovered ? 2.5 : 1.5,
          strokeOpacity: isHovered ? 1 : 0.65,
          transition: 'all 180ms ease',
        }}
      />

      {/* Docked Dialogue Chip */}
      {edgeData?.dialogueSnippet && (
        <EdgeLabelRenderer>
          <div
            style={{
              position: 'absolute',
              transform: `translate(-50%, -120%) translate(${labelX}px,${labelY}px)`,
              pointerEvents: 'all',
              zIndex: 15,
            }}
            className="nodrag nopan"
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
          >
            <div
              style={{
                backgroundColor: NODE_BG,
                border: `1px solid ${isHovered ? makerColor : BORDER}`,
                borderRadius: 6,
                padding: '4px 8px',
                fontSize: '9.5px',
                color: TEXT,
                maxWidth: 210,
                lineHeight: 1.35,
                transition: 'all 180ms ease',
                boxShadow: isHovered
                  ? '0 4px 12px rgba(0, 0, 0, 0.08)'
                  : '0 2px 6px rgba(0, 0, 0, 0.04)',
                display: 'flex',
                flexDirection: 'column',
                gap: 2,
              }}
            >
              {edgeData.label && (
                <div
                  style={{
                    fontSize: '7.5px',
                    fontWeight: 700,
                    color: makerColor,
                    textTransform: 'uppercase',
                    letterSpacing: '0.06em',
                  }}
                >
                  {edgeData.label}
                </div>
              )}
              <div style={{ color: TEXT_2, fontWeight: 500 }}>
                {edgeData.dialogueSnippet}
              </div>
            </div>
          </div>
        </EdgeLabelRenderer>
      )}
    </>
  );
};
