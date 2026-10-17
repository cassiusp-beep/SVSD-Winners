import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { StoryNode } from '../../../types';
import { branchStore } from '../../../store/branchStore';
import { 
  HelpCircle, 
  BookOpen, 
  FlaskConical, 
  GitCommit, 
  Compass, 
  GitBranch, 
  UserPlus, 
  RotateCcw,
  Sparkles,
  ExternalLink
} from 'lucide-react';

interface StoryStepNodeProps {
  id: string;
  data: {
    node: StoryNode;
    isActiveStep?: boolean;
    isSelected?: boolean;
  };
}

export const StoryStepNode = memo(({ data }: StoryStepNodeProps) => {
  const { node, isActiveStep, isSelected } = data;
  const isAbandoned = node.experimentStatus === 'abandoned';
  const isGap = node.type === 'gap';

  // Semantic styles based on node type
  let badgeBg = 'var(--color-surface-subtle)';
  let badgeColor = 'var(--color-ink)';
  let borderColor = 'var(--color-border)';
  let icon = <BookOpen size={13} />;

  switch (node.type) {
    case 'starting_question':
      badgeBg = 'var(--color-question-tint)';
      badgeColor = 'var(--color-ink)';
      icon = <HelpCircle size={13} />;
      break;
    case 'source':
      badgeBg = 'var(--color-surface-subtle)';
      badgeColor = 'var(--color-ink-muted)';
      icon = <BookOpen size={13} />;
      break;
    case 'experiment':
      badgeBg = 'var(--color-experiment-tint)';
      badgeColor = '#1F4765';
      icon = <FlaskConical size={13} />;
      break;
    case 'decision':
      badgeBg = 'var(--color-decision-tint)';
      badgeColor = 'var(--color-positive-ink)';
      icon = <GitCommit size={13} />;
      break;
    case 'gap':
      badgeBg = 'var(--color-attention-bg)';
      badgeColor = 'var(--color-attention-ink)';
      borderColor = 'var(--color-attention-ink)';
      icon = <Compass size={13} />;
      break;
    case 'chapter':
      badgeBg = 'var(--color-branch-tint)';
      badgeColor = '#4B367C';
      icon = <GitBranch size={13} />;
      break;
  }

  const handleNodeClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setSelectedNodeId(node.id);
  };

  const handleActionClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isGap) {
      // Open Help / Open Invite loop
      branchStore.openModal('help');
    } else {
      // Find Your Place modal
      branchStore.openModal('findYourPlace');
    }
  };

  return (
    <div
      onClick={handleNodeClick}
      className="branch-card"
      style={{
        width: 280,
        backgroundColor: isAbandoned ? '#F8F9F8' : '#FFFFFF',
        borderColor: isSelected 
          ? 'var(--color-ink)' 
          : isActiveStep 
            ? 'var(--color-focus)' 
            : borderColor,
        borderWidth: isSelected || isActiveStep ? 2 : 1,
        borderStyle: isGap ? 'dashed' : 'solid',
        opacity: isAbandoned && !isSelected ? 0.75 : 1,
        boxShadow: isSelected ? 'var(--shadow-popover)' : 'var(--shadow-card)',
        transform: isSelected ? 'scale(1.02)' : 'none',
        position: 'relative'
      }}
      tabIndex={0}
      role="button"
      aria-label={`Story node: ${node.title}, step ${node.stepNumber}`}
    >
      {/* Handles for left-to-right lineage */}
      <Handle type="target" position={Position.Left} id="step-target" style={{ background: '#767D73' }} />
      <Handle type="source" position={Position.Right} id="step-source" style={{ background: '#767D73' }} />

      {/* Header bar: Step count & Type badge */}
      <div style={{ padding: '12px 14px 8px 14px', borderBottom: '1px solid var(--color-border-subtle)' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
          <span style={{ fontSize: '11px', color: 'var(--color-ink-muted)', fontVariantNumeric: 'tabular-nums' }}>
            Step {node.stepNumber}
          </span>
          <span
            className="branch-chip"
            style={{
              backgroundColor: badgeBg,
              color: badgeColor,
              fontSize: '11px'
            }}
          >
            {icon}
            {node.type.replace('_', ' ').toUpperCase()}
          </span>
        </div>
        <h4
          style={{
            fontFamily: 'var(--font-display)',
            fontSize: '14px',
            fontWeight: 600,
            lineHeight: 1.3,
            color: 'var(--color-ink)'
          }}
        >
          {node.title}
        </h4>
      </div>

      {/* Main artifact visual preview */}
      {node.artifacts && node.artifacts.length > 0 && (
        <div style={{ position: 'relative', width: '100%', height: 110, overflow: 'hidden', backgroundColor: 'var(--color-surface-subtle)' }}>
          <img
            src={node.artifacts[0].url}
            alt={node.artifacts[0].caption}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover'
            }}
          />
          <div
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              padding: '4px 8px',
              backgroundColor: 'rgba(32, 36, 32, 0.75)',
              color: '#FFFFFF',
              fontSize: '10px',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis'
            }}
          >
            {node.artifacts[0].title}
          </div>
        </div>
      )}

      {/* Content description & turning point notes */}
      <div style={{ padding: '10px 14px' }}>
        {node.question && (
          <p style={{ fontSize: '13px', lineHeight: 1.4, color: 'var(--color-ink)', fontStyle: 'italic' }}>
            "{node.question}"
          </p>
        )}

        {node.hypothesis && (
          <div style={{ marginBottom: '6px' }}>
            <span style={{ fontSize: '10px', fontWeight: 600, textTransform: 'uppercase', color: 'var(--color-ink-muted)' }}>Hypothesis:</span>
            <p style={{ fontSize: '12px', lineHeight: 1.35, color: 'var(--color-ink)' }}>{node.hypothesis}</p>
          </div>
        )}

        {node.outcome && (
          <div style={{ marginBottom: '6px' }}>
            <span style={{ fontSize: '10px', fontWeight: 600, textTransform: 'uppercase', color: isAbandoned ? 'var(--color-error-ink)' : 'var(--color-ink-muted)' }}>
              {isAbandoned ? 'Abandoned Outcome:' : 'Outcome:'}
            </span>
            <p style={{ fontSize: '12px', lineHeight: 1.35, color: isAbandoned ? 'var(--color-error-ink)' : 'var(--color-ink)' }}>
              {node.outcome}
            </p>
          </div>
        )}

        {node.decisionRationale && (
          <p style={{ fontSize: '12px', lineHeight: 1.4, color: 'var(--color-ink)' }}>
            {node.decisionRationale}
          </p>
        )}

        {node.gapNeed && (
          <div style={{ padding: '8px', backgroundColor: 'var(--color-attention-bg)', borderRadius: 'var(--radius-control)', marginBottom: '6px' }}>
            <span style={{ fontSize: '11px', fontWeight: 600, color: 'var(--color-attention-ink)' }}>Collaborator Need:</span>
            <p style={{ fontSize: '12px', color: 'var(--color-attention-ink)', marginTop: '2px' }}>{node.gapNeed}</p>
          </div>
        )}

        {node.isTurningPoint && (
          <div
            style={{
              marginTop: '6px',
              padding: '6px 8px',
              backgroundColor: '#FFF2F2',
              borderRadius: 'var(--radius-control)',
              borderLeft: '3px solid var(--color-error-ink)',
              fontSize: '11px',
              color: '#8A2024'
            }}
          >
            <strong>Turning point:</strong> {node.turningPointNote}
          </div>
        )}
      </div>

      {/* Author & Action footer */}
      <div
        style={{
          padding: '8px 14px 10px 14px',
          borderTop: '1px solid var(--color-border-subtle)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: '11px'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span style={{ color: 'var(--color-ink-muted)' }}>By</span>
          <span style={{ fontWeight: 600, color: 'var(--color-ink)' }}>{node.authorName}</span>
        </div>

        <button
          onClick={handleActionClick}
          className={`branch-btn ${isGap ? 'branch-btn-attention' : 'branch-btn-secondary'}`}
          style={{ padding: '4px 10px', fontSize: '11px' }}
        >
          {isGap ? (
            <>
              <UserPlus size={12} />
              <span>Fill Gap</span>
            </>
          ) : isAbandoned ? (
            <>
              <RotateCcw size={12} />
              <span>Revive</span>
            </>
          ) : (
            <>
              <GitBranch size={12} />
              <span>Branch</span>
            </>
          )}
        </button>
      </div>
    </div>
  );
});

StoryStepNode.displayName = 'StoryStepNode';
