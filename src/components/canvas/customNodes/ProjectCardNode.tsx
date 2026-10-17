import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { Project } from '../../../types';
import { branchStore } from '../../../store/branchStore';
import { Compass, GitBranch, ArrowRight, Heart } from 'lucide-react';

interface ProjectCardNodeProps {
  id: string;
  data: {
    project: Project;
    isCurrentActive?: boolean;
  };
}

export const ProjectCardNode = memo(({ data }: ProjectCardNodeProps) => {
  const { project, isCurrentActive } = data;

  const handleOpenProject = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setActiveProject(project.id);
  };

  const handleToggleSave = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.toggleSaveProject(project.id);
  };

  return (
    <div
      onClick={handleOpenProject}
      className="branch-card"
      style={{
        width: 260,
        backgroundColor: '#FFFFFF',
        borderColor: isCurrentActive ? 'var(--color-ink)' : 'var(--color-border)',
        borderWidth: isCurrentActive ? 2 : 1,
        boxShadow: isCurrentActive ? 'var(--shadow-popover)' : 'var(--shadow-card)',
        position: 'relative'
      }}
      tabIndex={0}
      role="button"
      aria-label={`Project: ${project.title}`}
    >
      <Handle type="target" position={Position.Left} id="proj-target" style={{ background: '#767D73' }} />
      <Handle type="source" position={Position.Right} id="proj-source" style={{ background: '#767D73' }} />

      <div style={{ position: 'relative', width: '100%', height: 120, backgroundColor: 'var(--color-surface-subtle)' }}>
        <img
          src={project.heroMedia}
          alt={project.title}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
        <span
          className="branch-chip"
          style={{
            position: 'absolute',
            top: 8,
            left: 8,
            backgroundColor: project.status === 'stuck' ? 'var(--color-attention-bg)' : 'var(--color-surface)',
            color: project.status === 'stuck' ? 'var(--color-attention-ink)' : 'var(--color-ink)',
            fontSize: '10px'
          }}
        >
          {project.status === 'stuck' ? 'Has Open Gap' : 'Project Story'}
        </span>

        <button
          onClick={handleToggleSave}
          className="nodrag"
          style={{
            position: 'absolute',
            top: 8,
            right: 8,
            width: 28,
            height: 28,
            borderRadius: 'var(--radius-pill)',
            backgroundColor: 'rgba(255, 255, 255, 0.9)',
            border: 'none',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer'
          }}
          aria-label="Save for later"
        >
          <Heart size={14} color={project.isFavorite ? 'var(--color-error-ink)' : 'var(--color-ink-muted)'} fill={project.isFavorite ? 'var(--color-error-ink)' : 'none'} />
        </button>
      </div>

      <div style={{ padding: '12px' }}>
        <h4
          style={{
            fontFamily: 'var(--font-display)',
            fontSize: '14px',
            fontWeight: 600,
            color: 'var(--color-ink)',
            marginBottom: '4px'
          }}
        >
          {project.title}
        </h4>
        <p
          style={{
            fontSize: '12px',
            lineHeight: 1.35,
            color: 'var(--color-ink-muted)',
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden'
          }}
        >
          {project.startingQuestion}
        </p>
      </div>

      <div
        style={{
          padding: '8px 12px',
          borderTop: '1px solid var(--color-border-subtle)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: '11px'
        }}
      >
        <span style={{ color: 'var(--color-ink-muted)' }}>{project.creatorName}</span>
        <button
          onClick={handleOpenProject}
          className="branch-btn branch-btn-secondary nodrag"
          style={{ padding: '3px 8px', fontSize: '11px' }}
        >
          <span>Open Story</span>
          <ArrowRight size={12} />
        </button>
      </div>
    </div>
  );
});

ProjectCardNode.displayName = 'ProjectCardNode';
