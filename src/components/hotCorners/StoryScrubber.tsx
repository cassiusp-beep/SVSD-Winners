import React, { useEffect } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { Play, Pause, SkipBack, SkipForward, Sparkles, BookOpen } from 'lucide-react';

export const StoryScrubber: React.FC = () => {
  const state = useBranchStore();
  const currentProject = state.projects.find(p => p.id === state.activeProjectId);
  const storyNodes = currentProject?.nodes || [];
  const totalSteps = storyNodes.length;
  const currentStep = state.activeStepIndex;
  const isPlaying = state.isPlayingStory;

  // Automated step progression when Play is toggled
  useEffect(() => {
    if (!isPlaying || totalSteps === 0) return;

    const timer = setInterval(() => {
      const current = branchStore.getState().activeStepIndex;
      if (current >= totalSteps) {
        branchStore.toggleStoryPlay(); // pause at end
      } else {
        branchStore.setActiveStepIndex(current + 1);
      }
    }, 2400);

    return () => clearInterval(timer);
  }, [isPlaying, totalSteps]);

  if (!currentProject || totalSteps === 0) return null;

  const currentNode = storyNodes.find(n => n.stepNumber === currentStep) || storyNodes[0];

  const handlePrev = () => {
    if (currentStep > 1) {
      branchStore.setActiveStepIndex(currentStep - 1);
    }
  };

  const handleNext = () => {
    if (currentStep < totalSteps) {
      branchStore.setActiveStepIndex(currentStep + 1);
    }
  };

  return (
    <div
      className="branch-card"
      style={{
        width: 380,
        maxWidth: 'calc(100vw - 32px)',
        padding: '12px 16px',
        backgroundColor: '#FFFFFF',
        boxShadow: 'var(--shadow-floating)',
        borderColor: 'var(--color-border)',
        display: 'flex',
        flexDirection: 'column',
        gap: '8px'
      }}
      role="region"
      aria-label="Story scrubber for active project"
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <BookOpen size={14} color="var(--color-ink)" />
          <span style={{ fontFamily: 'var(--font-display)', fontSize: '13px', fontWeight: 600 }}>
            Follow Its Story
          </span>
          <span style={{ fontSize: '11px', color: 'var(--color-ink-muted)', fontVariantNumeric: 'tabular-nums' }}>
            ({currentStep} of {totalSteps})
          </span>
        </div>

        {currentNode?.isTurningPoint && (
          <span
            className="branch-chip"
            style={{
              backgroundColor: '#FFF2F2',
              color: 'var(--color-error-ink)',
              fontSize: '10px'
            }}
          >
            Turning Point
          </span>
        )}
      </div>

      {/* Scrub bar with chapter ticks */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '4px', width: '100%', padding: '4px 0' }}>
        {storyNodes.map((n) => {
          const isActive = n.stepNumber === currentStep;
          const isPast = n.stepNumber < currentStep;
          return (
            <button
              key={n.id}
              onClick={() => branchStore.setActiveStepIndex(n.stepNumber)}
              style={{
                flex: 1,
                height: isActive ? 8 : 4,
                backgroundColor: isActive
                  ? 'var(--color-ink)'
                  : isPast
                    ? 'var(--color-control-border)'
                    : 'var(--color-border)',
                borderRadius: 'var(--radius-pill)',
                border: 'none',
                cursor: 'pointer',
                transition: 'all 0.15s ease'
              }}
              title={`Step ${n.stepNumber}: ${n.title}`}
              aria-label={`Jump to step ${n.stepNumber}: ${n.title}`}
            />
          );
        })}
      </div>

      {/* Control row */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <button
            onClick={handlePrev}
            disabled={currentStep <= 1}
            className="branch-btn branch-btn-secondary"
            style={{ padding: '4px 8px', fontSize: '11px', opacity: currentStep <= 1 ? 0.4 : 1 }}
            aria-label="Previous story step"
          >
            <SkipBack size={12} />
            <span>Prev</span>
          </button>

          <button
            onClick={() => branchStore.toggleStoryPlay()}
            className="branch-btn branch-btn-primary"
            style={{ padding: '4px 10px', fontSize: '11px' }}
            aria-label={isPlaying ? 'Pause story progression' : 'Play story progression'}
          >
            {isPlaying ? <Pause size={12} /> : <Play size={12} />}
            <span>{isPlaying ? 'Pause' : 'Play Story'}</span>
          </button>

          <button
            onClick={handleNext}
            disabled={currentStep >= totalSteps}
            className="branch-btn branch-btn-secondary"
            style={{ padding: '4px 8px', fontSize: '11px', opacity: currentStep >= totalSteps ? 0.4 : 1 }}
            aria-label="Next story step"
          >
            <span>Next</span>
            <SkipForward size={12} />
          </button>
        </div>

        <div style={{ fontSize: '11px', color: 'var(--color-ink)', fontWeight: 500, maxWidth: 140, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {currentNode?.title}
        </div>
      </div>
    </div>
  );
};
