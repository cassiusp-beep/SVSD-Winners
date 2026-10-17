import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { Layers } from 'lucide-react';
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
      heroMedia?: string;
    };
    isCurrentActive?: boolean;
  };
  selected?: boolean;
}

export const ProjectStoryNode = memo(({ data, selected }: ProjectStoryNodeProps) => {
  const state = useBranchStore();
  const { project } = data;
  const isSelected = selected || state.selectedNodeId === project.id || state.activeProjectId === project.id;
  const isTargeted = state.hoveredDropTargetId === project.id;

  const handleClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setActiveProject(project.id);
    branchStore.setViewMode('story');
  };

  const heroImage =
    project.heroMedia ||
    'https://images.unsplash.com/photo-1584992236310-6edddc08acff?auto=format&fit=crop&w=600&q=80';

  return (
    <div
      onClick={handleClick}
      className="nodrag"
      style={{
        width: 280,
        backgroundColor: '#FFFFFF',
        border: isSelected ? '2px solid #0D8F5B' : '1px solid #E5E0D5',
        borderRadius: 16,
        overflow: 'hidden',
        color: '#191C24',
        cursor: 'pointer',
        boxShadow: isTargeted
          ? '0 0 32px rgba(13, 143, 91, 0.4), 0 12px 28px rgba(0,0,0,0.1)'
          : isSelected
          ? '0 8px 28px rgba(13, 143, 91, 0.2), 0 2px 6px rgba(0,0,0,0.06)'
          : '0 6px 24px rgba(24, 28, 38, 0.08), 0 1px 3px rgba(24, 28, 38, 0.04)',
        transform: isTargeted ? 'scale(1.03)' : 'scale(1)',
        transition: 'all 0.25s cubic-bezier(0.16, 1, 0.3, 1)',
      }}
    >
      <Handle type="target" position={Position.Left} id="project-target" style={{ background: '#0D8F5B', width: 8, height: 8 }} />
      <Handle type="source" position={Position.Right} id="project-source" style={{ background: '#0D8F5B', width: 8, height: 8 }} />
      <Handle type="source" position={Position.Bottom} id="project-bottom" style={{ background: '#0D8F5B', width: 8, height: 8 }} />

      {/* Project Hero Artifact Media */}
      <div style={{ position: 'relative', width: '100%', height: 130, backgroundColor: '#F0EFEA' }}>
        <img
          src={heroImage}
          alt={project.title}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
        <div
          style={{
            position: 'absolute',
            top: 8,
            left: 8,
            padding: '3px 8px',
            borderRadius: 6,
            backgroundColor: 'rgba(255, 255, 255, 0.92)',
            backdropFilter: 'blur(4px)',
            fontSize: '9.5px',
            fontWeight: 700,
            color: '#0D8F5B',
            letterSpacing: '0.04em',
            boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
          }}
        >
          PROJECT STORY
        </div>
        <div
          style={{
            position: 'absolute',
            bottom: 8,
            right: 8,
            padding: '2px 6px',
            borderRadius: 4,
            backgroundColor: 'rgba(25, 28, 36, 0.75)',
            color: '#FFFFFF',
            fontSize: '9px',
            fontWeight: 600,
          }}
        >
          Elena Rostova
        </div>
      </div>

      {/* Content */}
      <div style={{ padding: '12px 14px' }}>
        <h3
          style={{
            fontSize: '15px',
            fontWeight: 700,
            color: '#191C24',
            margin: '0 0 4px 0',
            lineHeight: 1.25,
            letterSpacing: '-0.01em',
          }}
        >
          {project.title}
        </h3>

        <p
          style={{
            fontSize: '11px',
            color: '#5F667A',
            margin: '0 0 12px 0',
            lineHeight: 1.45,
          }}
        >
          {project.tagline}
        </p>

        {/* Footer info & Collaborator Chips */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            paddingTop: 8,
            borderTop: '1px solid #F0ECE4',
            fontSize: '10px',
            color: '#8E95A6',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <Layers size={12} color="#0D8F5B" />
            <span style={{ fontWeight: 600, color: '#191C24' }}>7 steps</span>
            <span>• 1 open gap</span>
          </div>

          {/* Collaborator Avatars */}
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <img
              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=64&q=80"
              alt="Elena"
              style={{ width: 18, height: 18, borderRadius: '50%', border: '1.5px solid #FFFFFF' }}
            />
            <img
              src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=64&q=80"
              alt="Marcus"
              style={{ width: 18, height: 18, borderRadius: '50%', border: '1.5px solid #FFFFFF', marginLeft: -5 }}
            />
          </div>
        </div>
      </div>
    </div>
  );
});
