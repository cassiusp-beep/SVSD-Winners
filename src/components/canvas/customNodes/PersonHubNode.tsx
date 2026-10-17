import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';
import { useBranchStore, branchStore } from '../../../store/branchStore';
import { Plus, Compass, Upload, GitFork } from 'lucide-react';

interface PersonHubNodeProps {
  id: string;
  data: {
    userId: string;
    isGuest?: boolean;
    isDocked?: boolean;
  };
  selected?: boolean;
}

export const PersonHubNode = memo(({ data, selected }: PersonHubNodeProps) => {
  const state = useBranchStore();
  const isGuest = data.isGuest || data.userId === 'guest';
  const isDocked = data.isDocked || state.isProfileDocked;
  const isTargeted = state.hoveredDropTargetId === 'person-hub';

  const handleStartProject = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.genesisProjectFromDrop('Haptic Weave', '3D Sensor Model');
  };

  const handleDropSource = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.genesisProjectFromDrop('Tactile Audio Matrix', 'AudioWorklet DSP');
  };

  const handleFindPlace = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setViewMode('story');
    branchStore.setActiveProject('haptic-weave');
    branchStore.setSelectedNodeId('hw-gap1');
  };

  const handleToggleExplore = (e: React.MouseEvent) => {
    e.stopPropagation();
    branchStore.setViewMode(state.viewMode === 'hub' ? 'story' : 'hub');
  };

  return (
    <div
      style={{
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: 144,
        height: 144,
        transition: 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)'
      }}
    >
      {/* Handles for connections */}
      <Handle type="source" position={Position.Left} id="left-source" style={{ opacity: 0 }} />
      <Handle type="target" position={Position.Left} id="left-target" style={{ opacity: 0 }} />
      <Handle type="source" position={Position.Right} id="right-source" style={{ opacity: 0 }} />
      <Handle type="target" position={Position.Right} id="right-target" style={{ opacity: 0 }} />
      <Handle type="source" position={Position.Top} id="top-source" style={{ opacity: 0 }} />
      <Handle type="source" position={Position.Bottom} id="bottom-source" style={{ opacity: 0 }} />

      {/* SVG Gooey Filter definition */}
      <svg width="0" height="0" style={{ position: 'absolute' }}>
        <defs>
          <filter id="hub-goo">
            <feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
            <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 19 -9" result="goo" />
            <feComposite in="SourceGraphic" in2="goo" operator="atop" />
          </filter>
        </defs>
      </svg>

      {/* Radial Option Satellites (Bulbing into center) */}
      {!isDocked && (
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          {/* Top Satellite: + Start Project */}
          <button
            onClick={handleStartProject}
            title="Start a new project (drag item in or click)"
            style={{
              position: 'absolute',
              top: -36,
              left: '50%',
              transform: 'translateX(-50%)',
              width: 38,
              height: 38,
              borderRadius: '50%',
              backgroundColor: '#1E2640',
              border: '1.5px solid #232B47',
              color: '#EEF1FA',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              pointerEvents: 'auto',
              boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
              transition: 'transform 0.2s ease, border-color 0.2s ease'
            }}
            onMouseEnter={e => {
              e.currentTarget.style.transform = 'translateX(-50%) scale(1.15)';
              e.currentTarget.style.borderColor = '#4FD8F0';
            }}
            onMouseLeave={e => {
              e.currentTarget.style.transform = 'translateX(-50%) scale(1)';
              e.currentTarget.style.borderColor = '#232B47';
            }}
          >
            <Plus size={18} />
          </button>

          {/* Right Satellite: Explore */}
          <button
            onClick={handleToggleExplore}
            title="Explore network & projects"
            style={{
              position: 'absolute',
              right: -36,
              top: '50%',
              transform: 'translateY(-50%)',
              width: 38,
              height: 38,
              borderRadius: '50%',
              backgroundColor: '#1E2640',
              border: '1.5px solid #232B47',
              color: '#EEF1FA',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              pointerEvents: 'auto',
              boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
              transition: 'transform 0.2s ease, border-color 0.2s ease'
            }}
            onMouseEnter={e => {
              e.currentTarget.style.transform = 'translateY(-50%) scale(1.15)';
              e.currentTarget.style.borderColor = '#4FD8F0';
            }}
            onMouseLeave={e => {
              e.currentTarget.style.transform = 'translateY(-50%) scale(1)';
              e.currentTarget.style.borderColor = '#232B47';
            }}
          >
            <Compass size={18} />
          </button>

          {/* Bottom Satellite: Drop Source */}
          <button
            onClick={handleDropSource}
            title="Drop or upload a source / 3D model"
            style={{
              position: 'absolute',
              bottom: -36,
              left: '50%',
              transform: 'translateX(-50%)',
              width: 38,
              height: 38,
              borderRadius: '50%',
              backgroundColor: '#1E2640',
              border: '1.5px solid #232B47',
              color: '#EEF1FA',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              pointerEvents: 'auto',
              boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
              transition: 'transform 0.2s ease, border-color 0.2s ease'
            }}
            onMouseEnter={e => {
              e.currentTarget.style.transform = 'translateX(-50%) scale(1.15)';
              e.currentTarget.style.borderColor = '#4FD8F0';
            }}
            onMouseLeave={e => {
              e.currentTarget.style.transform = 'translateX(-50%) scale(1)';
              e.currentTarget.style.borderColor = '#232B47';
            }}
          >
            <Upload size={18} />
          </button>

          {/* Left Satellite: Find Your Place / Branch */}
          <button
            onClick={handleFindPlace}
            title="Find your place (branch an open gap)"
            style={{
              position: 'absolute',
              left: -36,
              top: '50%',
              transform: 'translateY(-50%)',
              width: 38,
              height: 38,
              borderRadius: '50%',
              backgroundColor: '#1E2640',
              border: '1.5px solid #232B47',
              color: '#EEF1FA',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              pointerEvents: 'auto',
              boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
              transition: 'transform 0.2s ease, border-color 0.2s ease'
            }}
            onMouseEnter={e => {
              e.currentTarget.style.transform = 'translateY(-50%) scale(1.15)';
              e.currentTarget.style.borderColor = '#4FD8F0';
            }}
            onMouseLeave={e => {
              e.currentTarget.style.transform = 'translateY(-50%) scale(1)';
              e.currentTarget.style.borderColor = '#232B47';
            }}
          >
            <GitFork size={18} />
          </button>
        </div>
      )}

      {/* Central Circular Profile Hub */}
      <div
        style={{
          width: 140,
          height: 140,
          borderRadius: '50%',
          backgroundColor: '#151B30',
          border: isTargeted ? '3px solid #4FD8F0' : '2px solid #4FD8F0',
          boxShadow: isTargeted
            ? '0 0 36px rgba(79, 216, 240, 0.75)'
            : '0 0 24px rgba(79, 216, 240, 0.4)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
          cursor: 'grab',
          userSelect: 'none',
          padding: '12px',
          transform: isTargeted ? 'scale(1.08)' : 'scale(1)',
          transition: 'transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease'
        }}
      >
        <img
          src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80"
          alt="Elena Rostova"
          style={{
            width: 44,
            height: 44,
            borderRadius: '50%',
            objectFit: 'cover',
            border: '2px solid #4FD8F0',
            marginBottom: 6
          }}
        />
        <div style={{ fontSize: '12px', fontWeight: 600, color: '#EEF1FA', lineHeight: 1.2 }}>
          {isGuest ? 'Anonymous Maker' : 'Elena Rostova'}
        </div>
        <div style={{ fontSize: '10px', color: '#4FD8F0', opacity: 0.9, lineHeight: 1.2 }}>
          {isGuest ? 'Browse Mode' : '@elena_craft'}
        </div>
        <div style={{ fontSize: '9px', color: '#7A84A8', marginTop: 2 }}>
          {isGuest ? 'Click to login' : 'UC Berkeley MDes'}
        </div>
      </div>
    </div>
  );
});
