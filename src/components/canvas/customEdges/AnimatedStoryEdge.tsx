import React, { useState } from 'react';
import { BaseEdge, EdgeLabelRenderer, EdgeProps, getBezierPath } from '@xyflow/react';
import { Sparkles, MessageSquare, Info } from 'lucide-react';
import { branchStore } from '../../../store/branchStore';

export interface AnimatedStoryEdgeData {
  label?: string;
  type?: 'led_to' | 'informed' | 'branched_from' | 'revived_from';
  dialogueSnippet?: string;
  aiRelevance?: string;
}

export const AnimatedStoryEdge: React.FC<EdgeProps<any>> = ({
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

  const [isHovered, setIsHovered] = useState(false);
  const [showAiPopover, setShowAiPopover] = useState(false);

  const edgeData = data as AnimatedStoryEdgeData | undefined;
  const state = branchStore.getState();
  const isAiGlobal = state.aiEnabled;

  const isBranched = edgeData?.type === 'branched_from';
  const strokeColor = isBranched ? '#7A62A6' : '#60665F';
  const strokeWidth = isBranched ? 2.5 : 1.75;
  const strokeDash = isBranched ? '5,5' : 'none';

  return (
    <>
      <BaseEdge
        path={edgePath}
        markerEnd={markerEnd}
        style={{
          ...style,
          stroke: strokeColor,
          strokeWidth,
          strokeDasharray: strokeDash,
          transition: 'stroke 0.2s ease, stroke-width 0.2s ease'
        }}
      />

      <EdgeLabelRenderer>
        <div
          style={{
            position: 'absolute',
            transform: `translate(-50%, -50%) translate(${labelX}px,${labelY}px)`,
            pointerEvents: 'all',
            zIndex: 1000
          }}
          className="nodrag nopan"
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={() => setIsHovered(false)}
        >
          {/* Main edge tag */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
              padding: '3px 8px',
              backgroundColor: isBranched ? 'var(--color-branch-tint)' : '#FFFFFF',
              border: `1px solid ${isHovered ? 'var(--color-ink)' : 'var(--color-border)'}`,
              borderRadius: 'var(--radius-pill)',
              fontSize: '11px',
              color: 'var(--color-ink)',
              boxShadow: isHovered ? 'var(--shadow-floating)' : 'var(--shadow-card)',
              cursor: 'pointer',
              userSelect: 'none',
              transition: 'all 0.15s ease'
            }}
            onClick={() => setShowAiPopover(!showAiPopover)}
          >
            {edgeData?.dialogueSnippet && <MessageSquare size={10} color="var(--color-ink-muted)" />}
            <span style={{ fontWeight: 500 }}>{edgeData?.label || 'connected'}</span>
            {(isAiGlobal || edgeData?.aiRelevance) && (
              <span
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '2px',
                  backgroundColor: 'var(--color-ai-tint)',
                  padding: '1px 5px',
                  borderRadius: 'var(--radius-pill)',
                  fontSize: '9px',
                  fontWeight: 600,
                  color: '#6E1B3B'
                }}
                title="AI Connection Relevance layer available"
              >
                <Sparkles size={8} />
                AI
              </span>
            )}
          </div>

          {/* Live Dialogue Snippet overlay (on hover) */}
          {isHovered && edgeData?.dialogueSnippet && !showAiPopover && (
            <div
              style={{
                position: 'absolute',
                top: '100%',
                left: '50%',
                transform: 'translateX(-50%) translateY(4px)',
                width: 220,
                padding: '8px 10px',
                backgroundColor: 'rgba(32, 36, 32, 0.92)',
                color: '#FFFFFF',
                borderRadius: 'var(--radius-control)',
                fontSize: '11px',
                lineHeight: 1.35,
                boxShadow: 'var(--shadow-floating)',
                pointerEvents: 'none'
              }}
            >
              <div style={{ fontSize: '9px', textTransform: 'uppercase', color: '#B4BCB3', marginBottom: '2px', display: 'flex', alignItems: 'center', gap: '3px' }}>
                <MessageSquare size={9} />
                Live Dialogue
              </div>
              {edgeData.dialogueSnippet}
            </div>
          )}

          {/* AI Connection Relevance Explanation Layer */}
          {(showAiPopover || (isAiGlobal && isHovered)) && edgeData?.aiRelevance && (
            <div
              style={{
                position: 'absolute',
                bottom: '100%',
                left: '50%',
                transform: 'translateX(-50%) translateY(-6px)',
                width: 250,
                padding: '10px 12px',
                backgroundColor: '#FFFFFF',
                border: '1.5px solid #E4B5C6',
                borderRadius: 'var(--radius-card)',
                boxShadow: 'var(--shadow-popover)',
                fontSize: '11px',
                lineHeight: 1.4,
                color: 'var(--color-ink)'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '4px' }}>
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    backgroundColor: 'var(--color-ai-tint)',
                    color: '#6E1B3B',
                    padding: '2px 6px',
                    borderRadius: 'var(--radius-pill)',
                    fontSize: '10px',
                    fontWeight: 600
                  }}
                >
                  <Sparkles size={10} />
                  AI Connection Relevance
                </span>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setShowAiPopover(false);
                  }}
                  style={{ background: 'none', border: 'none', fontSize: '10px', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
                >
                  Dismiss
                </button>
              </div>
              <p style={{ marginTop: '4px', color: 'var(--color-ink)' }}>
                {edgeData.aiRelevance}
              </p>
            </div>
          )}
        </div>
      </EdgeLabelRenderer>
    </>
  );
};
