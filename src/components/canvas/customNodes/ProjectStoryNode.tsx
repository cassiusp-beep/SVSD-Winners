/**
 * ProjectStoryNode — TouchDesigner COMP Container Operator Block
 * Solid color card with clear parameter readouts, media preview, and distinct ports.
 */
import React, { memo, useState } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';

interface ProjectStoryNodeProps {
  id: string;
  data: {
    project: {
      id: string;
      title: string;
      tagline: string;
      creatorName: string;
      openGapsCount: number;
      branchesCount: number;
      makerColor?: string;
    };
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

export const ProjectStoryNode = memo(({ data, selected }: ProjectStoryNodeProps) => {
  const state = useBranchStore();
  const { project } = data;
  const isSelected = selected || state.selectedNodeId === project.id || state.activeProjectId === project.id;
  const isTargeted = state.hoveredDropTargetId === project.id;
  const [hovered, setHovered] = useState(false);

  const handleClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setActiveProject(project.id);
    branchStore.setViewMode('story');
  };

  return (
    <div
      onClick={handleClick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className="nodrag"
      style={{
        position: 'relative',
        width: 260,
        backgroundColor: NODE_BG,
        borderRadius: 8,
        border: `1px solid ${isTargeted ? MAKER_1 : isSelected ? MAKER_1 : BORDER}`,
        boxShadow: isTargeted
          ? '0 6px 20px rgba(13, 143, 91, 0.18)'
          : hovered
          ? '0 4px 14px rgba(0, 0, 0, 0.08)'
          : '0 2px 6px rgba(0, 0, 0, 0.04)',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        pointerEvents: 'auto',
        cursor: 'pointer',
        transition: 'all 200ms ease',
      }}
    >
      {/* React Flow Ports */}
      <Handle
        type="target"
        position={Position.Left}
        id="project-target"
        style={{ left: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Right}
        id="project-source"
        style={{ right: -4, top: '50%' }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="project-bottom"
        style={{ bottom: -4, left: '50%' }}
      />

      {/* Operator Header Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '6px 10px',
          backgroundColor: '#0D8F5B',
          color: '#FFFFFF',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span
            style={{
              fontSize: '9px',
              fontWeight: 800,
              letterSpacing: '0.08em',
              fontFamily: "'Space Grotesk', sans-serif",
            }}
          >
            PROJECT COMP
          </span>
          <span style={{ opacity: 0.6 }}>·</span>
          <span style={{ fontSize: '9px', opacity: 0.9 }}>{project.creatorName}</span>
        </div>
        <span
          style={{
            fontSize: '8px',
            backgroundColor: 'rgba(255, 255, 255, 0.25)',
            padding: '1px 5px',
            borderRadius: 3,
            fontWeight: 700,
          }}
        >
          ACTIVE
        </span>
      </div>

      {/* Project Thumbnail Window */}
      <div
        style={{
          width: '100%',
          height: 90,
          overflow: 'hidden',
          backgroundColor: '#EAE8E1',
          position: 'relative',
        }}
      >
        <img
          src="https://images.unsplash.com/photo-1584992236310-6edddc08acff?auto=format&fit=crop&w=360&q=80"
          alt={project.title}
          style={{
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            opacity: 0.92,
            transition: 'transform 300ms ease',
            transform: hovered ? 'scale(1.03)' : 'scale(1)',
          }}
        />
        <div
          style={{
            position: 'absolute',
            bottom: 6,
            left: 8,
            backgroundColor: 'rgba(20, 23, 31, 0.75)',
            backdropFilter: 'blur(4px)',
            color: '#FFFFFF',
            fontSize: '8.5px',
            padding: '2px 6px',
            borderRadius: 3,
            fontWeight: 600,
          }}
        >
          Elena Rostova · MDes Thesis
        </div>
      </div>

      {/* Title & Tagline Body */}
      <div style={{ padding: '10px 12px' }}>
        <div
          style={{
            fontSize: '13px',
            fontWeight: 700,
            color: TEXT,
            fontFamily: "'Space Grotesk', sans-serif",
            lineHeight: 1.25,
          }}
        >
          {project.title}
        </div>
        <div
          style={{
            fontSize: '10.5px',
            color: TEXT_2,
            marginTop: 4,
            lineHeight: 1.35,
          }}
        >
          {project.tagline}
        </div>
      </div>

      {/* Operator Metadata Footer */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '6px 12px',
          borderTop: `1px solid ${BORDER}`,
          backgroundColor: NODE_RAISED,
          fontSize: '9px',
          color: TEXT_2,
        }}
      >
        <span>Lineage: 7 steps</span>
        {project.openGapsCount > 0 && (
          <span
            style={{
              color: GAP_COLOR,
              fontWeight: 700,
              display: 'flex',
              alignItems: 'center',
              gap: 4,
            }}
          >
            <span
              style={{
                width: 6,
                height: 6,
                borderRadius: '50%',
                backgroundColor: 'var(--gap, #FF9F0A)',
              }}
            />
            {project.openGapsCount} Open Question
          </span>
        )}
      </div>
    </div>
  );
});
