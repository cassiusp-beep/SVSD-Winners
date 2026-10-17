import React, { useState } from 'react';
import { useBranchStore, branchStore } from '../../store/branchStore';
import { X, Heart, RotateCcw, Compass, ArrowRight, GitBranch } from 'lucide-react';

export const TinderDeck: React.FC = () => {
  const state = useBranchStore();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [history, setHistory] = useState<number[]>([]);

  if (state.activeModal !== 'tinder') return null;

  // Collect all open gaps from all projects
  const cards = state.projects.flatMap(p => 
    p.gaps.map(g => ({
      ...g,
      project: p
    }))
  );

  const currentCard = cards[currentIndex];

  const handlePass = () => {
    if (currentIndex < cards.length) {
      setHistory(prev => [...prev, currentIndex]);
      setCurrentIndex(prev => prev + 1);
    }
  };

  const handleInterested = () => {
    if (!currentCard) return;
    setHistory(prev => [...prev, currentIndex]);
    // Set active project and open Find Your Place
    branchStore.setActiveProject(currentCard.project.id);
    branchStore.setSelectedNodeId(currentCard.sourceNodeId);
    branchStore.closeModal();
    branchStore.openModal('findYourPlace');
  };

  const handleUndo = () => {
    if (history.length > 0) {
      const prev = history[history.length - 1];
      setHistory(prevList => prevList.slice(0, -1));
      setCurrentIndex(prev);
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(32, 36, 32, 0.4)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 2000,
        padding: '16px'
      }}
      onClick={() => branchStore.closeModal()}
    >
      <div
        className="branch-card"
        style={{
          width: 440,
          maxWidth: '100%',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          boxShadow: 'var(--shadow-popover)'
        }}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="tinder-dialog-title"
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Compass size={18} color="var(--color-ink)" />
            <h3 id="tinder-dialog-title" style={{ fontFamily: 'var(--font-display)', fontSize: '17px', fontWeight: 600 }}>
              Tinder Style • Open Invites Feed
            </h3>
          </div>
          <button
            onClick={() => branchStore.closeModal()}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-ink-muted)' }}
          >
            <X size={18} />
          </button>
        </div>

        {currentCard ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {/* Card preview */}
            <div
              style={{
                borderRadius: 'var(--radius-card)',
                overflow: 'hidden',
                border: '1px solid var(--color-border)',
                backgroundColor: 'var(--color-surface)'
              }}
            >
              <div style={{ height: 180, position: 'relative' }}>
                <img
                  src={currentCard.project.heroMedia}
                  alt={currentCard.project.title}
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
                <span
                  className="branch-chip"
                  style={{
                    position: 'absolute',
                    top: 10,
                    left: 10,
                    backgroundColor: 'var(--color-attention-bg)',
                    color: 'var(--color-attention-ink)',
                    fontSize: '11px',
                    fontWeight: 600
                  }}
                >
                  Target: {currentCard.disciplineTarget}
                </span>
              </div>

              <div style={{ padding: '16px' }}>
                <div style={{ fontSize: '11px', color: 'var(--color-ink-muted)', marginBottom: '4px' }}>
                  Project by {currentCard.project.creatorName} ({currentCard.project.creatorDiscipline})
                </div>
                <h4 style={{ fontFamily: 'var(--font-display)', fontSize: '16px', fontWeight: 600, color: 'var(--color-ink)', marginBottom: '6px' }}>
                  {currentCard.title}
                </h4>
                <p style={{ fontSize: '13px', lineHeight: 1.4, color: 'var(--color-ink)' }}>
                  {currentCard.need}
                </p>
              </div>
            </div>

            {/* Swipe Controls: Pass, Undo, Interested */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '16px', marginTop: '6px' }}>
              <button
                onClick={handlePass}
                className="branch-card"
                style={{
                  width: 52,
                  height: 52,
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: '#FFFFFF',
                  cursor: 'pointer',
                  border: '1px solid var(--color-border)'
                }}
                title="Pass (Swipe Left)"
                aria-label="Pass on this invite"
              >
                <X size={22} color="var(--color-ink-muted)" />
              </button>

              <button
                onClick={handleUndo}
                disabled={history.length === 0}
                className="branch-card"
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: '#FFFFFF',
                  cursor: history.length > 0 ? 'pointer' : 'default',
                  opacity: history.length > 0 ? 1 : 0.4,
                  border: '1px solid var(--color-border)'
                }}
                title="Undo last swipe"
                aria-label="Undo last swipe"
              >
                <RotateCcw size={16} color="var(--color-ink-muted)" />
              </button>

              <button
                onClick={handleInterested}
                className="branch-card"
                style={{
                  width: 56,
                  height: 56,
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: 'var(--color-ink)',
                  cursor: 'pointer',
                  border: 'none',
                  boxShadow: 'var(--shadow-floating)'
                }}
                title="Interested • Join or Branch (Swipe Right)"
                aria-label="Interested in this invite"
              >
                <GitBranch size={22} color="#FFFFFF" />
              </button>
            </div>
          </div>
        ) : (
          <div style={{ textAlign: 'center', padding: '32px 0' }}>
            <p style={{ fontSize: '14px', fontWeight: 600, color: 'var(--color-ink)', marginBottom: '8px' }}>
              You've viewed all current Open Invites!
            </p>
            <p style={{ fontSize: '12px', color: 'var(--color-ink-muted)', marginBottom: '16px' }}>
              Explore the graph to discover more unfinished student projects.
            </p>
            {history.length > 0 && (
              <button onClick={handleUndo} className="branch-btn branch-btn-secondary" style={{ fontSize: '12px' }}>
                <RotateCcw size={14} />
                <span>Undo Last Swipe</span>
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
