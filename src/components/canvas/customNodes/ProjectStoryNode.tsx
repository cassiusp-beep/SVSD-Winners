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
      nodesCount?: number;
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

  return (
    <div
      onClick={handleClick}
      style={{
        width: 250,
        backgroundColor: '#151B30',
        border: isSelected ? '1.5px solid #4FD8F0' : '1px solid #232B47',
        borderRadius: 14,
        padding: '14px 16px',
        color: '#EEF1FA',
        cursor: 'pointer',
        boxShadow: isTargeted
          ? '0 0 28px rgba(79, 216, 240, 0.5)'
          : isSelected
          ? '0 0 20px rgba(79, 216, 240, 0.25)'
          : '0 8px 24px rgba(0,0,0,0.5)',
        transform: isTargeted ? 'scale(1.05)' : 'scale(1)',
        transition: 'all 0.25s cubic-bezier(0.16, 1, 0.3, 1)'
      }}
    >
      <Handle type="target" position={Position.Left} id="project-target" style={{ background: '#4FD8F0', opacity: 0.8 }} />
      <Handle type="source" position={Position.Right} id="project-source" style={{ background: '#4FD8F0', opacity: 0.8 }} />
      <Handle type="source" position={Position.Bottom} id="project-bottom" style={{ background: '#4FD8F0', opacity: 0.8 }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
        <span style={{ fontSize: '10px', fontWeight: 700, letterSpacing: '0.06em', color: '#4FD8F0', textTransform: 'uppercase' }}>
          PROJECT STORY • {project.creatorName.split(' ')[0]}
        </span>
        <span style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: '#4FD8F0' }} />
      </div>

      <h3 style={{ fontSize: '15px', fontWeight: 600, color: '#EEF1FA', margin: '0 0 4px 0', lineHeight: 1.25 }}>
        {project.title}
      </h3>

      <p style={{ fontSize: '11px', color: '#A3ACC7', margin: '0 0 10px 0', lineHeight: 1.4 }}>
        {project.tagline}
      </p>

      <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '10px', color: '#7A84A8', paddingTop: 8, borderTop: '1px solid #1E2640' }}>
        <Layers size={12} color="#7A84A8" />
        <span>7 steps • {project.openGapsCount} open gap • {project.branchesCount} branch</span>
      </div>
    </div>
  );
});
