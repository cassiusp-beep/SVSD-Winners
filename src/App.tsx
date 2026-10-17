import React, { useEffect, useRef } from 'react';
import { CanvasEngine } from './components/canvas/CanvasEngine';
import { HotCorners } from './components/hotCorners/HotCorners';
import { RadialMenu } from './components/modals/RadialMenu';
import { FindYourPlaceModal } from './components/modals/FindYourPlaceModal';
import { PrivateBranchModal } from './components/modals/PrivateBranchModal';
import { HelpDrawer } from './components/hotCorners/HelpDrawer';
import { SaveDrawer } from './components/hotCorners/SaveDrawer';
import { TinderDeck } from './components/modals/TinderDeck';
import { MobileSheet } from './components/mobile/MobileSheet';
import { useBranchStore, branchStore } from './store/branchStore';
import { Menu, Smartphone } from 'lucide-react';

export const App: React.FC = () => {
  const state = useBranchStore();
  const reactFlowInstance = useRef<any>(null);

  // Center person node helper
  const handleCenterPerson = () => {
    if (reactFlowInstance.current) {
      reactFlowInstance.current.setCenter(0, 220, { zoom: 0.9, duration: 600 });
    }
  };

  // Keyboard navigation & accessibility handlers
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Escape closes open modals or menus
      if (e.key === 'Escape') {
        if (state.activeModal) {
          branchStore.closeModal();
        } else if (state.radialMenu) {
          branchStore.closeRadialMenu();
        } else {
          branchStore.closeUnpinnedNodes();
        }
      }

      // Arrow navigation for story steps when no modal is open
      if (!state.activeModal && !state.radialMenu) {
        if (e.key === 'ArrowRight') {
          const currentProject = state.projects.find(p => p.id === state.activeProjectId);
          if (currentProject && state.activeStepIndex < currentProject.nodes.length) {
            branchStore.setActiveStepIndex(state.activeStepIndex + 1);
          }
        } else if (e.key === 'ArrowLeft') {
          if (state.activeStepIndex > 1) {
            branchStore.setActiveStepIndex(state.activeStepIndex - 1);
          }
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [state.activeModal, state.radialMenu, state.activeStepIndex, state.activeProjectId, state.projects]);

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative', overflow: 'hidden' }}>
      {/* Main Canvas Engine */}
      <CanvasEngine onEngineReady={(flow) => { reactFlowInstance.current = flow; }} />

      {/* Persistent Hot Corners (Profile, Help, Save, Story) */}
      <HotCorners onCenterPerson={handleCenterPerson} />

      {/* Modals & Popovers */}
      <RadialMenu />
      <FindYourPlaceModal />
      <PrivateBranchModal />
      <HelpDrawer />
      <SaveDrawer />
      <TinderDeck />
      <MobileSheet />

      {/* Mobile drawer quick toggle trigger (for phones or touch emulation) */}
      <div
        className="mobile-drawer-toggle"
        style={{
          position: 'fixed',
          bottom: 16,
          left: '50%',
          transform: 'translateX(-50%)',
          zIndex: 1000,
          display: 'flex',
          gap: '8px'
        }}
      >
        <button
          onClick={() => branchStore.toggleMobileSheet()}
          className="branch-card"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            padding: '6px 12px',
            backgroundColor: '#FFFFFF',
            borderRadius: 'var(--radius-pill)',
            fontSize: '11px',
            color: 'var(--color-ink)',
            cursor: 'pointer',
            boxShadow: 'var(--shadow-floating)'
          }}
          title="Mobile drawer view (390px adaptation)"
        >
          <Smartphone size={14} />
          <span>Phone Drawer</span>
        </button>
      </div>
    </div>
  );
};
